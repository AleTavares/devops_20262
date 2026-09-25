# Trabalho em Aula — Aula 05: RDS e Remote State

**Aluno:** Henri da Silva Despezzi
**RA:** 6325064 
**Data:** 10/09/2026

---

## Parte 1 — Análise dos Incidentes

### Cenário A: Perda de Dados

1. **Por que os dados foram perdidos:**
   Os dados estavam armazenados localmente na própria instância EC2 (em memória RAM ou em disco efémero/local sem persistência externa) ou no banco de dados local SQLite/memória do processo da aplicação. Quando a instância foi reiniciada para manutenção programada, todo o estado efêmero e o armazenamento em memória foram destruídos.

2. **Outros cenários de perda (mín. 3):**
   * **Falha de hardware da AWS:** Um problema na máquina física subjacente que hospeda a instância EC2 pode forçar o encerramento do servidor sem chance de recuperação.
   * **Terminação acidental do EC2:** Um usuário ou script com permissão de acesso no Console AWS/API pode encerrar a instância por engano.
   * **Atualização de versão/Auto Scaling:** Eventos de *Auto Scaling* ou substituição de instâncias durante um deploy automatizado destroem as instâncias antigas e sobem instâncias limpas do zero.

3. **Por que "não reiniciar" não resolve:**
   Instâncias de computação em nuvem (como EC2) foram projetadas para serem efêmeras e tratadas como "gado, não como animais de estimação" (*cattle, not pets*). Reinicializações, manutenções do provedor, falhas físicas e necessidades de *patching* de segurança são inevitáveis. Contar que uma instância nunca será reiniciada gera extrema fragilidade e impossibilita atualizações de sistema.

4. **Dados em memória vs persistentes:**
   * **Dados em memória (Voláteis):** Armazenados temporariamente na memória RAM para acesso ultra-rápido durante a execução do processo. Desaparecem imediatamente se a aplicação parar, reiniciar ou perder energia.
   * **Dados persistentes (Não-voláteis):** Armazenados em serviços projetados para durabilidade de longo prazo (como bancos de dados gerenciados RDS, volumes EBS ou S3). Sobrevivem a reinicializações de servidores, falhas de sistema e reimplantações de aplicação.

---

### Cenário B: Perda do State

1. **O que acontece com terraform plan sem state:**
   Como o arquivo `terraform.tfstate` contendo o mapeamento dos recursos existentes foi perdido, o Terraform assume que nada do que está no código foi provisionado ainda. Ao rodar `terraform plan`, o Terraform tentará recriar **toda a infraestrutura do zero** (EC2, VPC, Security Groups, etc.).

2. **Risco de terraform apply nessa situação:**
   O risco é de falha por conflitos de nomes/recursos já existentes na nuvem (ex: erro ao tentar criar um Security Group ou VPC que já existem na AWS) ou, no pior dos cenários, de tentar recriar recursos e gerar custos duplicados, acessos quebrados e sobreposição indesejada de infraestrutura.

3. **Terraform import como solução de emergência:**
   Sim, o comando `terraform import` permite reconectar um recurso real já existente na AWS de volta ao estado do Terraform. Porém, ele exige que cada recurso seja importado manualmente, um a um, e não recria os blocos de código automaticamente, exigindo um processo trabalhoso de reconstrução do estado.

4. **Como prevenir:**
   Configurar um **Backend Remoto** para o Terraform utilizando um bucket **AWS S3** com versionamento habilitado para armazenar o arquivo de estado (`terraform.tfstate`) de forma centralizada e segura na nuvem, acoplado ao **AWS DynamoDB** para o controle de concorrência (*state locking*).

---

## Parte 2 — Design da Arquitetura

```text
AWS Cloud
│
├── S3 Bucket: technova-tfstate (fora da VPC - Remote State)
├── DynamoDB Table: tfstate-locks (fora da VPC - State Locking)
│
└── VPC (ex: 10.0.0.0/16)
    ├── Internet Gateway (IGW)
    │
    ├── Availability Zone 1 (us-east-1a)
    │   ├── Subnet Pública (10.0.1.0/24)
    │   │   └── EC2 Instance (API TechNova)
    │   │       └── Security Group: EC2-SG (Inbound: 22/SSH, 3000/App da Internet)
    │   │
    │   └── Subnet Privada A (10.0.2.0/24)
    │       └── RDS PostgreSQL (DB Instance Principal)
    │           └── DB Subnet Group (abrange Subnet Privada A e B)
    │           └── Security Group: DB-SG (Inbound: 5432 apenas do EC2-SG)
    │
    └── Availability Zone 2 (us-east-1b)
        └── Subnet Privada B (10.0.3.0/24)
            └── DB Subnet Group (Reserva de IP/AZ para o RDS)

```

* **Componentes acessíveis da internet:**
* A **Subnet Pública** e a instância **EC2** (através do Internet Gateway e liberada pelas portas 22 e 3000 no Security Group).


* **Componentes isolados:**
* As **Subnets Privadas (A e B)** e o **RDS PostgreSQL**, que não possuem rotas para a internet nem IP público.
* Os recursos de backend do Terraform (**S3 Bucket** e **DynamoDB**), gerenciados fora da VPC com controles de acesso IAM restritos.


* **Por que RDS precisa de 2 AZs:**
O serviço AWS RDS exige a criação de um **DB Subnet Group** composto por pelo menos 2 Subnets em **Zone de Disponibilidade (AZs) distintas**. Isso garante a arquitetura pronta para alta disponibilidade (Multi-AZ), permitindo que a AWS aloque IPs de contingência e realize o *failover* do banco para outra AZ caso ocorra uma falha física na AZ principal.

---

## Parte 3 — Discussão: Conflito Simultâneo

* **Cenários reais onde isso ocorreria:**
* Duas automações em paralelo: Um pipeline de **CI/CD** (GitHub Actions / GitLab CI) rodando um `terraform apply` automático na branch principal ao mesmo tempo em que um engenheiro roda `terraform apply` manualmente de seu computador.
* Múltiplos membros da equipe alterando o código simultaneamente em tarefas diferentes sem coordenação centralizada.


* **Impacto de um state corrompido:**
* Perda da rastreabilidade da infraestrutura, onde o Terraform não sabe mais quais recursos existem.
* Possibilidade de exclusões inadvertidas de recursos críticos em produção (*downtime* não planejado).
* Necessidade de intervenção manual complexa para corrigir e sincronizar o arquivo de estado com a real infraestrutura na AWS.


* **Como locking resolve:**
O **DynamoDB** atua como um mecanismo de trava (*lock*). Quando o *Dev A* executa `terraform apply`, o Terraform cria uma entrada na tabela do DynamoDB com a chave do estado. Se o *Dev B* tentar executar qualquer comando que altere o estado simultaneamente, o Terraform consulta o DynamoDB, identifica o bloqueio ativo e nega a execução até que a operação do *Dev A* seja finalizada e o *lock* liberado.

```

```