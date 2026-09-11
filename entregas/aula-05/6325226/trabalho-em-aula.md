# Trabalho em Aula — Aula 05: RDS e Remote State

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 09/09/2026

## Parte 1 — Análise dos Incidentes

### Cenário A: Perda de Dados

1. **Por que os dados foram perdidos:** a API armazenava os pedidos em memória (RAM) do processo Node.js rodando no EC2. Memória é volátil — ao reiniciar o processo/instância, tudo que não foi persistido em disco ou em um banco externo desaparece.
2. **Outros cenários de perda (mín. 3):**
   - `terraform destroy` seguido de `terraform apply` (a instância é recriada do zero)
   - Auto Scaling substituindo a instância por uma nova (scale-in/scale-out ou health check falhando)
   - Crash da aplicação (exceção não tratada derruba o processo e o systemd/PM2 reinicia do zero)
   - Patch/manutenção agendada da AWS que reinicia a instância
3. **Por que "não reiniciar o EC2" não é solução válida:** reinícios acontecem por motivos fora do nosso controle (manutenção da AWS, falha de hardware, Auto Scaling, deploy de nova versão). Depender de "nunca reiniciar" não é uma estratégia de engenharia, é só adiar o problema até o primeiro imprevisto.
4. **Dados em memória vs persistentes:** dados em memória existem só enquanto o processo está rodando — vivem no espaço de RAM do EC2. Dados persistentes são gravados em um meio que sobrevive ao ciclo de vida do processo/instância (disco, ou melhor ainda, um serviço de banco de dados externo como o RDS), independente do que aconteça com o servidor de aplicação.

### Cenário B: Perda do State

1. **O que acontece com `terraform plan` sem o state:** o Terraform não tem como comparar "o que existe" com "o que o código pede" — sem o `.tfstate`, ele assume que nada foi criado ainda e propõe recriar toda a infraestrutura do zero, mesmo que ela já exista rodando na AWS.
2. **Risco de `terraform apply` nessa situação:** o Terraform tentaria criar recursos duplicados (nova VPC, novo RDS, etc.) por cima dos que já existem, gerando conflito de nomes/CIDRs, recursos órfãos cobrando na conta, e uma bagunça de infraestrutura que não bate mais com o código.
3. **`terraform import` como solução de emergência:** sim, é possível "reimportar" cada recurso existente para um state novo, um a um, informando o ID real na AWS (`terraform import aws_instance.api i-0abc123...`). Funciona, mas é lento, manual e propenso a erro — é remediação, não prevenção.
4. **Como prevenir:** nunca deixar o `terraform.tfstate` só na máquina de uma pessoa. Usar backend remoto (S3 + DynamoDB) desde o início do projeto, para que o state fique centralizado, versionado e acessível a toda a equipe.

## Parte 2 — Design da Arquitetura

```text
                         Internet
                            │
                    ┌───────┴────────┐
                    │ Internet Gateway│
                    └───────┬────────┘
                            │
                 VPC 10.0.0.0/16
        ┌───────────────────┼────────────────────┐
        │           Subnet Pública (AZ-a)         │
        │        EC2 t2.micro (SG: 22, 3000)      │
        │                    │                    │
        │           psql :5432 (dentro da VPC)    │
        │                    ▼                    │
        │  Subnet Privada 1 (AZ-a)  Subnet Privada 2 (AZ-b)
        │        └────────────┬───────────┘       │
        │             DB Subnet Group              │
        │           RDS PostgreSQL (SG: 5432        │
        │           apenas do SG do EC2)            │
        └────────────────────────────────────────────┘

  (fora da VPC, serviços regionais da AWS)
   S3 Bucket (terraform.tfstate, versionado, encriptado)
   DynamoDB Table (LockID) — locking do apply
```

- **Componentes acessíveis da internet:** apenas o EC2, via Internet Gateway + Route Table pública, nas portas 22 (SSH) e 3000 (API). O S3 e o DynamoDB são serviços gerenciados da AWS, acessados via API/IAM, não pela rede da VPC.
- **Componentes isolados:** o RDS, nas duas subnets privadas — sem rota para o Internet Gateway e sem IP público (`publicly_accessible = false`). Só é alcançável de dentro da VPC, e o Security Group do RDS só libera a porta 5432 para o Security Group do EC2.
- **Por que o RDS precisa de 2 AZs mesmo sem Multi-AZ:** é um requisito da própria AWS para o DB Subnet Group — mesmo com `multi_az = false`, a infraestrutura de subnets precisa estar preparada para que, se o Multi-AZ for ativado no futuro, exista uma segunda AZ pronta para hospedar o standby. Também dá resiliência: se uma AZ inteira cair, existe uma subnet alternativa já provisionada.

## Parte 3 — Discussão: Conflito Simultâneo

- **Cenários reais onde isso ocorreria:** um pipeline de CI/CD rodando `terraform apply` automaticamente a cada merge, ao mesmo tempo que um desenvolvedor roda `apply` manualmente da sua máquina para testar uma mudança local; ou dois desenvolvedores no mesmo time aplicando alterações diferentes no mesmo ambiente sem avisar um ao outro.
- **Impacto de um state corrompido:** o Terraform perde a correspondência entre o que está no código e o que existe de fato na AWS — outputs ficam inconsistentes, o próximo `plan` pode propor destruir ou recriar recursos que na verdade já estão corretos, e recursos aplicados por um dos dois "somem" do controle do Terraform mesmo continuando a existir (e a gerar custo) na conta.
- **Como o locking resolve:** o DynamoDB garante que só uma execução de `apply` por vez consegue escrever no state (via o item de lock com `LockID`). Quem tentar rodar `apply` enquanto outro processo segura o lock recebe um erro (`Error acquiring the state lock`) e precisa esperar — assim as duas mudanças são aplicadas em sequência, sobre o state mais atualizado, em vez de uma sobrescrever silenciosamente a outra.

## Parte 4 — Reflexão: Spec-Driven vs Manual

> **Nota de transparência:** o laboratório pede o uso do Kiro em modo Spec para o Lab 2. Não usei o Kiro — usei o Claude Code como assistente de IA para gerar o código de `aula-05-backend/` (S3 + DynamoDB). O Lab 1 (`aula-05-rds/`, VPC + RDS + EC2) eu tentei escrever manualmente seguindo o roteiro. A comparação abaixo é entre "eu escrevendo na mão" (Lab 1) e "IA generativa gerando o código" (Lab 2, com Claude Code no lugar do Kiro) — não é uma avaliação do fluxo específico de Spec do Kiro (requisitos → design → tarefas), que não cheguei a executar.

### 4.1 Comparar com o Lab Parte 1

| Aspecto | Lab 1 (manual) | Lab 2 (IA-assistido, Claude no lugar do Kiro) |
|---------|---------------|---------------------------------------------|
| Tempo para ter o código pronto | Bem mais lento — precisei ler a documentação do provider AWS, entender cada bloco (VPC, subnets, SGs, RDS) e testar aos poucos | Rápido — o código do backend (bucket S3 + tabela DynamoDB) saiu pronto em poucos minutos |
| Quantidade de erros de sintaxe | Tive alguns erros de digitação/referência entre recursos (ex: nome de subnet errado, atributo inexistente) que só apareciam no `terraform plan` | Nenhum erro de sintaxe — o HCL gerado já veio válido de primeira |
| Você entendeu o que foi gerado? | Sim, bem entendido — escrevi linha por linha e errei o suficiente para entender o porquê de cada bloco | Entendi a estrutura geral (bucket versionado, encriptado, bloqueado a acesso público + tabela com partition key LockID), mas não critiquei linha a linha como fiz no Lab 1 |
| Precisou corrigir algo do que foi gerado? | Sim, várias vezes (nomes de recursos, referências de SG, CIDRs) | Não precisei corrigir nada manualmente no código gerado |
| Qual abordagem preferiu? | Prefiro para aprender de verdade — errar no Lab 1 foi o que me fez entender VPC/SG/RDS | Prefiro para tarefas repetitivas/conhecidas onde já sei o que validar (ex: backend S3+Dynamo é um padrão bem conhecido) |

### 4.2 Quando usar Spec/IA vs Manual?

- **IA generativa funciona melhor para:** infraestrutura nova e "padrão de mercado" (como o backend S3+DynamoDB do Lab 2) — é um padrão bem documentado, então a IA acerta de primeira e eu só preciso revisar, não inventar do zero.
- **Manual é mais adequado para:** partes onde preciso realmente aprender o conceito (como fiz no Lab 1 com VPC/subnets/RDS) ou fazer ajuste fino/debugging — errar na mão foi o que fixou o aprendizado de rede e segurança.
- **Risco de aceitar o código sem validar:** no meu caso, aceitei o backend do Claude sem revisar cada linha com o mesmo cuidado do Lab 1. O risco ficou claro na prática: o código do backend tem uma limitação real da conta do AWS Academy (bloqueio de permissão no bucket S3, ver relatório de execução) que só descobri ao tentar aplicar de verdade — se eu nunca tivesse rodado o `apply`, teria entregado um código que "parece certo" mas não funciona nessa conta.

### 4.3 O que a IA acertou e errou?

- **Acertou:** estrutura de arquivos separada por responsabilidade (`s3.tf`, `dynamodb.tf`, `variables.tf`, `outputs.tf`), `.gitignore` correto (`.tfstate`, `.tfvars`, `.pem` ignorados), outputs úteis (nome do bucket, ARN, nome da tabela), configuração de segurança do S3 (versionamento, encriptação KMS, bloqueio de acesso público) tecnicamente correta.
- **Errou/Omitiu:** o código em si não tem erro — o problema é que o AWS Provider do Terraform sempre tenta ler a configuração de Object Lock do bucket S3, e a conta do AWS Academy Learner Lab bloqueia essa chamada por política organizacional (SCP). Isso não é algo que o Kiro ou o Claude poderiam ter evitado escrevendo o `.tf` de forma diferente — é uma restrição de permissão da conta, fora do controle do código.
- **Precisou de intervenção:** sim — tive que rodar `aws s3api put-bucket-versioning/encryption/public-access-block` manualmente pela CLI para aplicar no bucket o que o Terraform não conseguiu aplicar via `apply`/`import` nessa conta. Documentei o problema e a solução no `relatorio-execucao.md`.
