# Trabalho em Aula — Aula 05: RDS e Remote State

**Aluno:** weslley lucas 
**RA:** 6325226
**Data:** 14/09/2026

## Parte 1 — Análise dos Incidentes

### Cenário A: Perda de Dados

1. **Por que os dados foram perdidos:** os 5 pedidos existiam apenas na memória RAM do processo
   da API rodando no EC2. Não havia nenhum banco de dados persistente por trás — quando o
   sistema operacional reiniciou (manutenção programada da AWS), o processo foi encerrado e o
   conteúdo da memória foi descartado junto.
2. **Outros cenários de perda (mín. 3):**
   - A instância EC2 é terminada (manualmente ou por Auto Scaling substituindo-a por outra).
   - Um deploy novo da aplicação, que exige restart do processo, sem nenhuma etapa de persistência.
   - A instância cai por falha de hardware do host físico da AWS (fora do controle do usuário) e é
     recriada em outro host.
3. **Por que "não reiniciar" não resolve:** reinícios de EC2 não são opcionais — a AWS periodicamente
   faz manutenção de host, patches de hipervisor, ou substitui instâncias em Auto Scaling. Nenhuma
   dessas ações pede permissão à aplicação. Depender de "o servidor nunca reiniciar" é depender de algo
   fora do controle do time, então não é uma solução, é só adiar o problema.
4. **Dados em memória vs persistentes:** dados em memória existem apenas enquanto o processo que os
   criou está rodando — são voláteis, desaparecem no primeiro restart. Dados persistentes são gravados
   em um meio que sobrevive independentemente do processo/instância que os gerou (disco, e no caso de
   produção, um banco de dados gerenciado como o RDS), continuando disponíveis mesmo depois de reinícios,
   terminações ou substituições da camada de aplicação.

### Cenário B: Perda do State

1. **O que acontece com `terraform plan` sem o state:** o Terraform não tem como saber o que já existe
   na AWS — sem `terraform.tfstate`, ele parte do princípio de que o estado atual é "nada provisionado".
   O `plan` mostra a criação de toda a infraestrutura do zero (VPC, EC2, RDS, etc.), mesmo que ela já
   exista rodando na conta.
2. **Risco de rodar `terraform apply` nessa situação:** o Terraform tentaria criar recursos com os
   mesmos nomes/configurações dos que já existem. Alguns provedores rejeitam a criação por conflito de
   nome único (ex: bucket S3), mas outros (como VPC, EC2) simplesmente criam recursos duplicados —
   gerando infraestrutura órfã, custo dobrado e nenhum controle real sobre o que está de fato em produção.
3. **`terraform import` como solução de emergência:** sim, existe. `terraform import` associa um recurso
   já existente na AWS a um resource block já escrito no código, reconstruindo a entrada correspondente
   no state sem recriar nada. É trabalhoso (precisa ser feito recurso por recurso, e o código `.tf` já
   tem que descrever a infraestrutura corretamente), mas evita destruir e recriar tudo.
4. **Como prevenir:** usar remote state desde o início — backend S3 com versionamento (permite reverter
   para uma versão anterior do state) e DynamoDB para locking, em vez de manter o `terraform.tfstate`
   apenas no laptop de uma pessoa. Com o state no S3, a perda do laptop de um dev não afeta o mapa da
   infraestrutura, que continua acessível a qualquer membro autorizado do time.

## Parte 2 — Design da Arquitetura

```
                              Internet
                                 │
                          [Internet Gateway]
                                 │
                    Route Table pública (0.0.0.0/0 → IGW)
                                 │
                           AZ us-east-1a
                    ┌─────────────────────────┐
                    │ Subnet pública           │
                    │ 10.0.1.0/24              │
                    │  EC2 (API + psql client) │
                    │  SG: 22 (SSH), 3000 (API)│
                    └────────────┬─────────────┘
                                 │ porta 5432 (SG rds ← SG ec2)
        ┌────────────────────────┴───────────────────────┐
        │                                                 │
  AZ us-east-1a                                     AZ us-east-1b
┌─────────────────────────┐                     ┌─────────────────────────┐
│ Subnet privada            │                     │ Subnet privada           │
│ 10.0.2.0/24              │                     │ 10.0.4.0/24              │
│ (sem rota p/ IGW)         │                     │ (sem rota p/ IGW)         │
└─────────────────────────┘                     └─────────────────────────┘
              └──────────────── DB Subnet Group ────────────────┘
                                 │
                        RDS PostgreSQL (db.t3.micro)
                        publicly_accessible = false

VPC: 10.0.0.0/16

Fora da VPC:
  S3 Bucket (state, versionado + criptografado + Block Public Access)
  DynamoDB Table (lock, partition key "LockID")
```

- **Componentes acessíveis da internet:** apenas o EC2, via porta 22 (SSH) e 3000 (API) —
  a única instância na subnet pública, com rota para o Internet Gateway.
- **Componentes isolados:** o RDS, em duas subnets privadas sem rota para o IGW; o próprio S3 e o
  DynamoDB do remote state também não estão dentro da VPC — são serviços regionais acessados via API
  da AWS, protegidos por IAM e Block Public Access, não por posição de rede.
- **Por que o RDS precisa de 2 AZs mesmo sem Multi-AZ:** é uma exigência da própria AWS para criar o
  DB Subnet Group — mesmo com `multi_az = false`, o Subnet Group precisa cobrir pelo menos duas AZs,
  deixando a infraestrutura pronta para habilitar Multi-AZ no futuro (o standby precisaria de uma AZ
  diferente da instância primária) sem precisar redesenhar a rede.

## Parte 3 — Discussão: Conflito Simultâneo

- **Cenários reais onde isso ocorreria:** um pipeline de CI/CD rodando `terraform apply` automaticamente
  a cada merge, enquanto um dev roda `apply` manualmente no laptop para testar uma mudança local; ou
  dois desenvolvedores do mesmo time aplicando alterações diferentes na mesma infraestrutura sem
  coordenar horário entre si — comum quando a equipe cresce e a comunicação informal ("avisa no chat
  antes de rodar apply") deixa de ser suficiente.
- **Impacto de um state corrompido:** o Terraform passa a ter uma visão incorreta da infraestrutura
  real — pode achar que um recurso não existe (e tentar recriá-lo, duplicando) ou que existe com uma
  configuração diferente da real (e tentar "corrigir" algo que na verdade já está certo). Na prática,
  o time perde a confiança no `plan`/`apply` e frequentemente precisa reconstruir o state manualmente
  via `terraform import`, recurso por recurso.
- **Como o locking resolve:** o DynamoDB funciona como uma trava exclusiva sobre o state. Antes de
  qualquer leitura/escrita, o Terraform tenta criar um registro de lock na tabela; se já existe um,
  a segunda execução fica bloqueada esperando até o primeiro `apply` terminar e liberar o lock. Isso
  serializa as operações — garante que a segunda execução sempre lê o state já atualizado pela
  primeira, em vez de sobrescrevê-lo com uma versão desatualizada.
