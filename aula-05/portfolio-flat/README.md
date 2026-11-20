# Infraestrutura TechNova — Aula 05: RDS + Remote State

Infraestrutura completa da TechNova com camada de dados persistente (Amazon RDS PostgreSQL) e state do Terraform protegido remotamente (S3 + DynamoDB). Provisionado com Terraform no AWS Academy Learner Lab.

---

## Diagrama da Arquitetura

```
                          INTERNET
                              │
                   ┌──────────▼──────────┐
                   │   Internet Gateway  │
                   │   (technova-igw)    │
                   └──────────┬──────────┘
                              │
┌─────────────────────────────▼──────────────────────────────────────────┐
│  VPC: 10.0.0.0/16  (technova-vpc)  — us-east-1                        │
│                                                                        │
│  ┌──────── Subnet Pública ─────────────────────────────────┐           │
│  │  10.0.1.0/24  |  AZ: us-east-1a                         │           │
│  │  ┌─────────────────────────────────────────────────┐    │           │
│  │  │  EC2 t2.micro  (technova-api-server)            │    │           │
│  │  │  SG: 22 (SSH) + 3000 (API)                      │    │           │
│  │  │  Node.js 18 + psql client                       │    │           │
│  │  │  LabInstanceProfile                             │    │           │
│  │  └──────────────────┬──────────────────────────────┘    │           │
│  └─────────────────────┼─────────────────────────────────┘ │           │
│                        │ porta 5432                          │           │
│  ┌──────── Subnet Privada 1 ───────────────────────────┐    │           │
│  │  10.0.2.0/24  |  AZ: us-east-1a                     │    │           │
│  │  ┌────────────────────────────────────────────────┐ │    │           │
│  │  │  RDS PostgreSQL 15  (technova-db)              │ │    │           │
│  │  │  db.t3.micro  |  20 GB gp2                     │ │    │           │
│  │  │  multi_az=false  |  storage_encrypted=true     │ │    │           │
│  │  │  SG: porta 5432 apenas do EC2 SG               │ │    │           │
│  │  └────────────────────────────────────────────────┘ │    │           │
│  └─────────────────────────────────────────────────────┘    │           │
│                                                             │           │
│  ┌──────── Subnet Privada 2 ───────────────────────────┐    │           │
│  │  10.0.4.0/24  |  AZ: us-east-1b                     │    │           │
│  │  (DB Subnet Group — 2ª AZ obrigatória)               │    │           │
│  └─────────────────────────────────────────────────────┘    │           │
└────────────────────────────────────────────────────────────────────────┘

FORA DA VPC — Remote State:
┌───────────────────────────────┐   ┌──────────────────────────────┐
│  S3 Bucket                    │   │  DynamoDB Table              │
│  technova-terraform-state-xxxx│   │  technova-terraform-locks    │
│  ✅ Versionamento habilitado   │   │  hash_key: LockID (String)   │
│  ✅ AES256 encriptação         │   │  billing: PAY_PER_REQUEST    │
│  ✅ Block Public Access        │   │                              │
│  aula-05/terraform.tfstate ◄──┼───┼── backend "s3"               │
└───────────────────────────────┘   └──────────────────────────────┘
```

---

## Recursos Criados

| Recurso | Nome | Função |
|---------|------|--------|
| `aws_vpc` | technova-vpc | Rede virtual isolada (10.0.0.0/16) |
| `aws_subnet` (pública) | technova-public-subnet | EC2 com acesso à internet |
| `aws_subnet` (privada 1) | technova-private-subnet-1 | RDS, AZ-a |
| `aws_subnet` (privada 2) | technova-private-subnet-2 | DB Subnet Group, AZ-b |
| `aws_internet_gateway` | technova-igw | Saída para internet |
| `aws_route_table` | technova-public-rt | Rota 0.0.0.0/0 → IGW |
| `aws_security_group` (EC2) | technova-ec2-sg | SSH (22) + API (3000) |
| `aws_security_group` (RDS) | technova-rds-sg | PostgreSQL (5432) do EC2 |
| `aws_db_subnet_group` | technova-db-subnet-group | Agrupa 2 subnets privadas |
| `aws_db_instance` | technova-db | PostgreSQL 15, db.t3.micro |
| `aws_instance` | technova-api-server | EC2 t2.micro com API |
| `aws_key_pair` | technova-key-aula05 | SSH para EC2 |
| **Backend** | | |
| `aws_s3_bucket` | technova-terraform-state-xxxx | State remoto |
| `aws_dynamodb_table` | technova-terraform-locks | Locking do state |

---

## Pré-requisitos

- AWS CLI instalado e configurado
- Terraform ≥ 1.0
- Acesso ao AWS Academy Learner Lab

---

## Como Usar

### 1. Configurar credenciais do AWS Academy

```bash
# Criar aws-creds.sh com os valores do Learner Lab (está no .gitignore)
source aws-creds.sh
aws sts get-caller-identity
```

### 2. Criar o backend primeiro (S3 + DynamoDB)

```bash
cd backend/
terraform init
terraform plan
terraform apply
# Anote os outputs: s3_bucket_name e dynamodb_table_name
```

### 3. Atualizar o providers.tf com o bucket gerado

No arquivo `providers.tf`, substitua `SUBSTITUIR-PELO-BUCKET-DO-BACKEND` pelo valor de `s3_bucket_name` do passo anterior.

### 4. Criar terraform.tfvars com a senha (nunca commitar)

```bash
cat > terraform.tfvars <<EOF
db_password = "SuaSenhaSegura123!"
EOF
```

### 5. Inicializar com backend remoto

```bash
cd ..  # volta para portfolio-aula-05/
terraform init  # configura o backend S3
# Se já tinha state local: terraform init -migrate-state
```

### 6. Aplicar

```bash
terraform plan
terraform apply
# Aguarde 5-10 minutos para o RDS provisionar
```

### 7. Testar conexão EC2 → RDS

```bash
export EC2_IP=$(terraform output -raw ec2_public_ip)
export RDS_HOST=$(terraform output -raw rds_address)

# SSH no EC2
ssh -i ./technova-aula05.pem ec2-user@$EC2_IP

# Dentro do EC2 — conectar ao RDS
psql -h $RDS_HOST -U technova_admin -d technova -p 5432
```

### 8. Criar tabela e dados de teste

```sql
-- Dentro do psql (conectado ao RDS):
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  customer_name VARCHAR(100) NOT NULL,
  product VARCHAR(100) NOT NULL,
  quantity INTEGER NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO orders (customer_name, product, quantity, total) VALUES
  ('Maria Silva', 'Laptop TechNova Pro', 1, 4599.90),
  ('João Santos', 'Monitor 27"', 2, 2398.00),
  ('Ana Costa', 'Teclado Mecânico', 3, 897.00);

SELECT * FROM orders;
\q
```

### 9. Verificar state no S3

```bash
aws s3 ls s3://$(cd backend && terraform output -raw s3_bucket_name)/aula-05/
```

### 10. Destruir após evidências

```bash
# 1. Destruir infraestrutura principal
terraform destroy

# 2. Esvaziar bucket (inclui versões do state)
BUCKET=$(cd backend && terraform output -raw s3_bucket_name)
aws s3 rm s3://$BUCKET --recursive

# 3. Destruir backend
cd backend/
terraform destroy
```

---

## Decisões Técnicas

**Por que RDS em vez de PostgreSQL no EC2?**  
RDS gerencia patches, backups automáticos, failover e monitoramento. A TechNova é uma equipe pequena sem DBA — terceirizar a operação do banco para a AWS é a decisão correta. Self-managed só faria sentido com requisitos muito específicos de configuração de SO.

**Por que DB Subnet Group precisa de 2 AZs?**  
Requisito obrigatório da AWS, mesmo com `multi_az = false`. Garante que o banco pode ser movido entre AZs durante manutenção e prepara a infraestrutura para ativar Multi-AZ no futuro sem recriar o grupo.

**Por que o SG do RDS referencia o SG do EC2 em vez do CIDR da VPC?**  
Least privilege: em vez de permitir qualquer recurso em `10.0.0.0/16` (incluindo futuras lambdas, outros EC2s, etc.), apenas instâncias com o Security Group `technova-ec2-sg` podem acessar o banco. Se a lista de quem pode acessar o banco crescer, é só adicionar o SG ao ingress — mais seguro e auditável.

**Por que backend separado (pasta `backend/`)?**  
O clássico "chicken-and-egg": o bucket S3 precisa existir antes de configurar o backend que vai guardar o state do projeto principal. Separar em dois projetos Terraform resolve isso: o backend tem state local (aceitável, é infra de bootstrap) e o projeto principal tem state remoto no S3 criado pelo backend.

**Por que `force_destroy = true` no bucket S3?**  
Em laboratório, facilita a limpeza total. Em produção, `force_destroy = false` protege contra destruição acidental do histórico de states.

---

## Estrutura de Arquivos

```
portfolio-aula-05/
├── providers.tf    # Backend S3 + provider AWS
├── variables.tf    # Todas as variáveis
├── main.tf         # Data sources (AMI, AZs)
├── vpc.tf          # VPC, subnets, IGW, route tables
├── rds.tf          # DB Subnet Group, SG RDS, instância RDS
├── ec2.tf          # SG EC2, Key Pair, instância EC2
├── outputs.tf      # 10 outputs com comandos prontos
├── user_data.sh    # Script de boot: Node.js 18 + psql + API
├── .gitignore      # Exclui .tfstate, .pem, tfvars, aws-creds.sh
├── README.md       # Este arquivo
└── backend/
    ├── main.tf       # Provider + random_id para nome único
    ├── s3.tf         # Bucket S3 com versionamento + encriptação + block public
    ├── dynamodb.tf   # Tabela DynamoDB com partition key LockID
    └── outputs.tf    # bucket_name, table_name, backend_config pronto
```
