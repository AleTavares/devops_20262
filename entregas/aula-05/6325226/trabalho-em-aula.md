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
