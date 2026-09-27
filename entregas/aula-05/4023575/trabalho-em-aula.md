# Trabalho em Aula — Aula 05: RDS e Remote State
**Aluno:** Emilly Santos
**Data:** 12/09/2026

## Parte 1 — Análise dos Incidentes

### Cenário A: Perda de Dados
1. **Por que os dados foram perdidos:** Os dados do banco estavam salvos localmente no armazenamento efêmero da própria instância EC2 (ou em memória), em vez de um serviço gerenciado de banco de dados persistente.
2. **Outros cenários de perda (mín. 3):** 
   - Falha física de hardware do host subjacente da AWS.
   - Encerramento ou recriação da instância EC2 via Terraform.
   - Esgotamento de espaço em disco no volume EBS da EC2.
3. **Por que "não reiniciar" não resolve:** Servidores são recursos descartáveis em arquiteturas de nuvem (*pets vs cattle*). Falhas de hardware e manutenções automáticas da AWS ocorrem de forma imprevisível.
4. **Dados em memória vs persistentes:** Dados em memória (RAM/disco local de EC2 sem backup) duram apenas enquanto o processo/instância está rodando; dados persistentes (RDS/EBS com backup) são desacoplados da camada de computação e sobreviverão a falhas ou reinicializações.

### Cenário B: Perda do State
1. **O que acontece com terraform plan sem state:** O Terraform não encontra o mapeamento entre o código local e os recursos reais já criados na AWS, assumindo que nada existe e tentando recriar toda a infraestrutura do zero.
2. **Risco de terraform apply nessa situação:** Falhas de execução por conflito de nomes de recursos existentes ou sobrescrita/duplicação não planejada da infraestrutura na conta AWS.
3. **Terraform import como solução de emergência:** O comando `terraform import` permite reassociar manualmente recursos existentes na AWS ao arquivo de estado do Terraform, mas é um processo lento e sujeito a erros.
4. **Como prevenir:** Utilizar **Remote State** configurando um backend remoto no S3 com versionamento habilitado e controle de trava (*state locking*) via DynamoDB.

---

## Parte 2 — Design da Arquitetura

text
┌─────────────────────────────────────────────────────────────────────────────┐
│ AWS Cloud                                                                   │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ VPC (10.0.0.0/16)                                                     │  │
│  │                                                                       │  │
│  │  ┌── Subnet Pública ──────────────┐  ┌── Subnet Privada ───────────┐  │  │
│  │  │ AZ: us-east-1a               │  │ AZ: us-east-1a                │  │  │
│  │  │ EC2 (API Node.js)            │  │ RDS PostgreSQL (Primary)      │  │  │
│  │  └──────────────────────────────┘  └───────────────────────────────┘  │  │
│  │                                      ┌── Subnet Privada ───────────┐  │  │
│  │                                      │ AZ: us-east-1b                │  │  │
│  │                                      │ (DB Subnet Group standby)   │  │  │
│  │                                      └───────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ┌── Armazenamento de Estado (Fora da VPC) ──────────────────────────────┐  │
│  │ S3 Bucket (terraform.tfstate encriptado)                              │  │
│  │ DynamoDB Table (LockID para trava de concorrência)                    │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘


- **Componentes acessíveis da internet:** Subnet pública contendo a instância EC2 da API (via Internet Gateway).
- **Componentes isolados:** Subnets privadas contendo o banco de dados RDS PostgreSQL e a camada de dados.
- **Por que RDS precisa de 2 AZs:** O serviço AWS RDS exige um *DB Subnet Group* abrangendo pelo menos duas Zonas de Disponibilidade (AZs) distintas para garantir suporte a alta disponibilidade e failover automático, mesmo se a opção Multi-AZ estiver desativada no momento.

---

## Parte 3 — Discussão: Conflito Simultâneo

- **Cenários reais onde isso ocorreria:** Dois desenvolvedores rodando `terraform apply` simultaneamente em suas máquinas locais, ou um pipeline automatizado de CI/CD executando um *deploy* ao mesmo tempo em que um operador aplica um ajuste manual via linha de comando.
- **Impacto de um state corrompido:** Perda de rastreabilidade de recursos, falhas em deploys subsequentes e risco de exclusão inadvertida de infraestrutura crítica em produção.
- **Como locking resolve:** O DynamoDB grava uma trava (*lock*) no momento em que um usuário inicia uma operação de leitura/escrita no estado. Se outro usuário tentar executar um comando simultâneo, o Terraform recusa a execução até que a trava seja liberada pela primeira operação.
