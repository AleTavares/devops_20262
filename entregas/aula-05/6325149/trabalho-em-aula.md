# Trabalho em Aula — Aula 05: RDS e Remote State

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 12/10/2026

## Parte 1 — Análise dos Incidentes

### Cenário A: Perda de Dados

1. **Por que os dados foram perdidos:** os pedidos ficavam na memória do processo da API (ou no disco da própria instância EC2). Quando a instância reiniciou, o processo foi encerrado e a memória foi descartada; os dados nunca foram gravados em um armazenamento persistente e independente da instância.
2. **Outros cenários de perda (mín. 3):**
   - *Terminate* da instância (manual, erro humano ou `terraform destroy`/`apply` que a recria), principalmente com disco efêmero (instance store) ou volume com `delete_on_termination`.
   - Falha de hardware do host ou indisponibilidade da AZ.
   - Auto Scaling ou deploy de uma nova AMI substituindo a instância por outra "limpa".
   - Crash/restart do processo Node (OOM, exceção não tratada) ou novo deploy da aplicação.
3. **Por que "não reiniciar" não resolve:** a AWS faz manutenção programada, instâncias falham e deploys exigem reinício; evitar reiniciar não é controlável nem escalável. A solução é desacoplar os dados da instância (o servidor de aplicação deve ser descartável e os dados ficam em um serviço próprio, como o RDS).
4. **Dados em memória vs persistentes:** dados em memória (RAM) existem só enquanto o processo/instância está de pé e somem em qualquer reinício. Dados persistentes são gravados em armazenamento durável (disco replicado, banco gerenciado como o RDS com backups) e sobrevivem a reinícios e a trocas de instância.

### Cenário B: Perda do State

1. **O que acontece com `terraform plan` sem state:** o Terraform não sabe que nada existe, então compara o código com um state vazio e planeja **criar todos os recursos do zero**, mesmo que já existam na AWS.
2. **Risco de `terraform apply` nessa situação:** criaria recursos duplicados ou falharia por conflito de nomes/recursos já existentes (ex.: Security Group, subnets), podendo gerar custo e uma infraestrutura inconsistente. Além disso, os recursos antigos ficariam órfãos, fora do controle do Terraform.
3. **Terraform import como solução de emergência:** `terraform import <endereço> <id>` associa um recurso já existente na AWS a um bloco do código e o grava no novo state. É preciso importar um a um (e ajustar o código até o `plan` ficar sem diferenças), por isso é trabalhoso e é um remendo, não a solução definitiva.
4. **Como prevenir:** usar **remote state** em bucket S3 (com versionamento e criptografia) e **locking com DynamoDB**, em vez de `terraform.tfstate` local no laptop. Assim o state é compartilhado, tem histórico para recuperação e não depende de uma máquina.

## Parte 2 — Design da Arquitetura

```
                          INTERNET
                              │
                       ┌──────┴──────┐
                       │   Internet  │
                       │   Gateway   │
                       └──────┬──────┘
┌─────────────────────────────┼───────────────────────────────────────────────┐
│ VPC 10.0.0.0/16             │                                               │
│                             │                                               │
│  ┌─ us-east-1a ────────────┼──────────┐        ┌─ us-east-1b ───────────┐   │
│  │                          │          │        │                        │   │
│  │  Subnet pública 10.0.1.0/24         │        │                        │   │
│  │  ┌────────────────────────────┐     │        │                        │   │
│  │  │ EC2 (API Node.js)          │     │        │                        │   │
│  │  │ SG-EC2: 22, 3000 (internet)│     │        │                        │   │
│  │  └────────────┬───────────────┘     │        │                        │   │
│  │               │ porta 5432          │        │                        │   │
│  │               │ (dentro da VPC)     │        │                        │   │
│  │  Subnet privada 10.0.2.0/24         │        │ Subnet privada         │   │
│  │  ┌────────────▼───────────────┐     │        │ 10.0.3.0/24            │   │
│  │  │ RDS PostgreSQL             │     │        │ (DB Subnet Group)      │   │
│  │  │ SG-RDS: 5432 só do SG-EC2  │     │        │                        │   │
│  │  └────────────────────────────┘     │        │                        │   │
│  └─────────────────────────────────────┘        └────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘

        FORA DA VPC (serviços regionais gerenciados)
        ┌────────────────────────────┐   ┌─────────────────────────────┐
        │ S3 Bucket                  │   │ DynamoDB Table              │
        │ (terraform.tfstate)        │   │ (lock do state: LockID)     │
        └────────────────────────────┘   └─────────────────────────────┘
```

- **Componentes acessíveis da internet:** a subnet pública, com o Internet Gateway e a EC2 (somente as portas 22 e 3000 liberadas pelo Security Group).
- **Componentes isolados:** o RDS e as subnets privadas (sem rota para o Internet Gateway; o Security Group do RDS aceita a porta 5432 apenas do Security Group da EC2). O S3 e o DynamoDB ficam fora da VPC e são acessados via API da AWS com credenciais IAM, não pela internet aberta.
- **Fluxo de conexão:** a API na EC2 conecta no RDS pela porta 5432, dentro da VPC, usando o endpoint do RDS; o banco nunca é exposto à internet.
- **Por que RDS precisa de 2 AZs:** o *DB Subnet Group* exige subnets em pelo menos 2 Availability Zones, mesmo com Multi-AZ desligado. É um requisito da AWS que permite, quando o Multi-AZ é ativado, provisionar a réplica standby em outra AZ e fazer failover, além de dar flexibilidade para recriar a instância em outra AZ.

## Parte 3 — Discussão: Conflito Simultâneo

- **Cenários reais onde isso ocorreria:** dois devs aplicando ao mesmo tempo; um pipeline de CI/CD rodando `terraform apply` enquanto um dev roda `apply` manual; dois pipelines disparados por merges em sequência; um apply interrompido (queda de rede) e outro iniciado em seguida.
- **Impacto de um state corrompido:** o Terraform passa a ter uma visão errada da infraestrutura: pode "esquecer" recursos (que ficam órfãos e geram custo), tentar recriar ou destruir recursos existentes, ou perder alterações de um dev (como a mudança do `instance_type`). Recuperar exige restaurar uma versão anterior do state (por isso o versionamento do S3) ou fazer `terraform import` recurso a recurso.
- **Como locking resolve:** com o backend S3 + DynamoDB, antes de qualquer operação que escreve no state o Terraform adquire um lock (item na tabela com o `LockID`). Quem chega depois é **bloqueado** e espera/falha com mensagem de lock, e só lê o state atualizado depois que o primeiro libera. As operações passam a ser serializadas e as duas mudanças (instance_type e Security Group) são preservadas.
