# Laboratório Parte 1 — RDS com Terraform

## Missão

Adicionar a camada de dados persistentes à infraestrutura da TechNova: provisionar um banco de dados PostgreSQL gerenciado (Amazon RDS) em subnets privadas, e conectar o EC2 ao banco para provar que os dados sobrevivem a reinicializações.

**Duração:** ~120 minutos

**Resultado esperado:** Uma instância RDS PostgreSQL acessível apenas pelo EC2 dentro da VPC, com dados persistentes.

---

## Pré-requisitos

- AWS CLI configurado (`aws sts get-caller-identity` funciona)
- Terraform instalado (`terraform version` funciona)
- Conhecimento de VPC, subnets e EC2 (Aula 04)
- Editor de texto preparado

> **⚠️ Atenção:** A criação do RDS leva **5-10 minutos**. Isso é normal — o `terraform apply` ficará esperando nesse passo. Use esse tempo para revisar o código ou ler a documentação.

---

## Parte 1 — Setup do Projeto (10 min)

### 1.1 Criar diretório do lab

```bash
mkdir -p ~/labs/aula-05-rds
cd ~/labs/aula-05-rds
```

### 1.2 Criar arquivo providers.tf

```hcl
# providers.tf

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

### 1.3 Criar arquivo variables.tf

```hcl
# variables.tf

variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto (usado em tags e nomes)"
  type        = string
  default     = "technova"
}

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_username" {
  description = "Username do banco de dados RDS"
  type        = string
  default     = "technova_admin"
}

variable "db_password" {
  description = "Password do banco de dados RDS"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "technova"
}
```

### 1.4 Criar arquivo terraform.tfvars

```hcl
# terraform.tfvars

aws_region  = "us-east-1"
db_password = "TechNova2025Segura!"
```

> **⚠️ IMPORTANTE:** Adicione `terraform.tfvars` ao `.gitignore`! Ele contém a senha do banco.

### 1.5 Criar .gitignore

```
# .gitignore
.terraform/
*.tfstate
*.tfstate.backup
terraform.tfvars
*.pem
```

### 1.6 Inicializar Terraform

```bash
terraform init
```

---

## Parte 2 — Infraestrutura de Rede (VPC) (15 min)

Precisamos de uma VPC com:
- 1 subnet pública (para o EC2)
- 2 subnets privadas em AZs diferentes (para o DB Subnet Group)

### 2.1 Criar arquivo vpc.tf

```hcl
# vpc.tf

# Data source para buscar AZs disponíveis
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
    Aula    = "05"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

# Subnet Pública (para EC2) - AZ 1
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-subnet"
    Project = var.project_name
    Type    = "public"
  }
}

# Subnet Privada 1 (para RDS) - AZ 1
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name    = "${var.project_name}-private-subnet-1"
    Project = var.project_name
    Type    = "private"
  }
}

# Subnet Privada 2 (para RDS) - AZ 2 (OBRIGATÓRIO: AZ diferente!)
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name    = "${var.project_name}-private-subnet-2"
    Project = var.project_name
    Type    = "private"
  }
}

# Route Table Pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}

# Associar Route Table à Subnet Pública
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

**Ponto-chave:** Note que `private_1` está em `names[0]` (us-east-1a) e `private_2` está em `names[1]` (us-east-1b). O DB Subnet Group **exige** AZs diferentes.

---

## Parte 3 — DB Subnet Group (10 min)

### 3.1 Criar arquivo rds.tf (começando com o DB Subnet Group)

```hcl
# rds.tf

# DB Subnet Group - REQUER subnets em 2+ AZs diferentes
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name    = "${var.project_name}-db-subnet-group"
    Project = var.project_name
  }
}
```

**O que está acontecendo:**
- O DB Subnet Group agrupa as 2 subnets privadas (em AZs diferentes)
- O RDS será posicionado em uma delas
- Se ativarmos Multi-AZ no futuro, o standby ficará na outra

---

## Parte 4 — Security Group para RDS (10 min)

### 4.1 Adicionar Security Group ao rds.tf

```hcl
# Security Group para RDS (adicionar ao rds.tf)
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security Group para RDS - permite PostgreSQL apenas da VPC"
  vpc_id      = aws_vpc.main.id

  # Entrada: PostgreSQL (5432) apenas de dentro da VPC
  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Saída: nenhuma (RDS não precisa acessar internet)
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-rds-sg"
    Project = var.project_name
  }
}
```

**Segurança:**
- Porta 5432 aberta **apenas** para o CIDR da VPC (10.0.0.0/16)
- Nenhum acesso externo (internet) ao banco de dados
- O RDS ficará em subnet privada (sem rota para IGW)

---

## Parte 5 — Criar Instância RDS (25 min)

### 5.1 Adicionar a instância RDS ao rds.tf

```hcl
# Instância RDS PostgreSQL (adicionar ao rds.tf)
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-db"

  # Engine
  engine         = "postgres"
  engine_version = "15"

  # Capacidade (Free Tier)
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  # Banco de dados
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  # Rede
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  # Alta disponibilidade (desligada para Free Tier)
  multi_az = false

  # Backup
  backup_retention_period = 7
  backup_window           = "03:00-04:00"

  # Manutenção
  maintenance_window = "sun:04:00-sun:05:00"

  # Encriptação
  storage_encrypted = true

  # Deletar sem snapshot final (para lab - NÃO faça isso em produção!)
  skip_final_snapshot = true

  # Performance Insights (desligado para Free Tier)
  performance_insights_enabled = false

  tags = {
    Name    = "${var.project_name}-rds"
    Project = var.project_name
    Aula    = "05"
  }
}
```

> **⚠️ IMPORTANTE:** O `terraform apply` deste recurso levará **5-10 minutos**. Isso é normal! O RDS precisa provisionar o hardware, instalar o PostgreSQL, configurar rede, etc. Tenha paciência.

**Configurações Free Tier:**
- `instance_class = "db.t3.micro"` — elegível ao Free Tier
- `allocated_storage = 20` — 20 GB (limite Free Tier)
- `multi_az = false` — Multi-AZ não é Free Tier
- `skip_final_snapshot = true` — para labs (em produção, sempre tire snapshot antes de deletar)

---

## Parte 6 — Conectar EC2 ao RDS (20 min)

### 6.1 Criar arquivo ec2.tf

```hcl
# ec2.tf

# Data source para AMI Amazon Linux 2023 mais recente
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key Pair (use sua chave existente ou crie uma nova)
resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-key"
  public_key = file("~/.ssh/id_rsa.pub")

  tags = {
    Name    = "${var.project_name}-key"
    Project = var.project_name
  }
}

# Security Group para EC2
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security Group para EC2 - SSH e API"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "API Node.js"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-ec2-sg"
    Project = var.project_name
  }
}

# Instância EC2
resource "aws_instance" "api" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.main.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y postgresql15
  EOF

  tags = {
    Name    = "${var.project_name}-api"
    Project = var.project_name
    Aula    = "05"
  }
}
```

> **Nota sobre Key Pair:** Se você não tem `~/.ssh/id_rsa.pub`, gere com `ssh-keygen -t rsa -b 4096`. Alternativamente, crie o key pair manualmente no console AWS e use `key_name = "nome-existente"` sem o recurso `aws_key_pair`.

### 6.2 Testar conexão EC2 → RDS

Após o `terraform apply` completar:

```bash
# 1. Conectar ao EC2 via SSH
ssh -i ~/.ssh/id_rsa ec2-user@<IP_PUBLICO_EC2>

# 2. Testar conexão ao RDS (de dentro do EC2)
psql -h <RDS_ENDPOINT> -U technova_admin -d technova -p 5432

# Quando pedir senha, digite: TechNova2025Segura!
```

Se a conexão funcionar, você verá o prompt do PostgreSQL:
```
technova=>
```

**Se não conectar, verifique:**
- Security Group do RDS permite porta 5432 do CIDR da VPC?
- EC2 está na mesma VPC que o RDS?
- Endpoint do RDS está correto? (use `terraform output`)

---

## Parte 7 — Criar Tabela e Inserir Dados (15 min)

### 7.1 Criar tabela de pedidos

Dentro do `psql` (conectado ao RDS):

```sql
-- Criar tabela de pedidos
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inserir dados de teste
INSERT INTO orders (customer_name, product, quantity, total) VALUES
    ('Maria Silva', 'Laptop TechNova Pro', 1, 4599.90),
    ('João Santos', 'Monitor 27"', 2, 2398.00),
    ('Ana Costa', 'Teclado Mecânico', 3, 897.00);

-- Verificar dados
SELECT * FROM orders;
```

### 7.2 Provar persistência

```sql
-- Sair do psql
\q
```

```bash
# Sair do EC2
exit

# Reiniciar o EC2 (simular manutenção)
aws ec2 reboot-instances --instance-ids <INSTANCE_ID>

# Esperar ~1 minuto, reconectar
ssh -i ~/.ssh/id_rsa ec2-user@<IP_PUBLICO_EC2>

# Reconectar ao RDS
psql -h <RDS_ENDPOINT> -U technova_admin -d technova -p 5432

# Verificar: DADOS AINDA ESTÃO LÁ!
SELECT * FROM orders;
```

**Resultado esperado:** Os 3 pedidos continuam no banco. O RDS é independente do EC2 — reiniciar, terminar ou substituir o EC2 não afeta os dados.

```
 id | customer_name |      product       | quantity |  total  |         created_at
----+---------------+--------------------+----------+---------+----------------------------
  1 | Maria Silva   | Laptop TechNova Pro|        1 | 4599.90 | 2025-01-15 10:30:00.000000
  2 | João Santos   | Monitor 27"        |        2 | 2398.00 | 2025-01-15 10:30:00.000000
  3 | Ana Costa     | Teclado Mecânico   |        3 |  897.00 | 2025-01-15 10:30:00.000000
```

---

## Parte 8 — Variables e Outputs (10 min)

### 8.1 Criar arquivo outputs.tf

```hcl
# outputs.tf

output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "rds_endpoint" {
  description = "Endpoint de conexão do RDS"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "Hostname do RDS (sem porta)"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "Porta do RDS"
  value       = aws_db_instance.main.port
}

output "rds_database_name" {
  description = "Nome do banco de dados"
  value       = aws_db_instance.main.db_name
}

output "ec2_public_ip" {
  description = "IP público do EC2"
  value       = aws_instance.api.public_ip
}

output "connection_string" {
  description = "String de conexão PostgreSQL (sem senha)"
  value       = "psql -h ${aws_db_instance.main.address} -U ${var.db_username} -d ${var.db_name} -p ${aws_db_instance.main.port}"
}
```

### 8.2 Verificar outputs

```bash
terraform output

# Resultado esperado:
# rds_endpoint = "technova-db.cxyz123.us-east-1.rds.amazonaws.com:5432"
# rds_address = "technova-db.cxyz123.us-east-1.rds.amazonaws.com"
# ec2_public_ip = "54.123.45.67"
# connection_string = "psql -h technova-db.cxyz123... -U technova_admin -d technova -p 5432"
```

---

## Parte 9 — Terraform Destroy (5 min)

### 9.1 Destruir a infraestrutura

```bash
terraform destroy
```

Terraform vai listar todos os recursos a serem destruídos. Digite `yes` para confirmar.

> **⚠️ Nota:** A destruição do RDS também leva alguns minutos. Como usamos `skip_final_snapshot = true`, não será criado snapshot final (em produção, nunca pule o snapshot!).

### 9.2 Verificar destruição

```bash
# Verificar que não há mais recursos
terraform state list
# Deve retornar vazio
```

---

## Troubleshooting

### Problema: "DB Subnet Group doesn't meet availability zone coverage requirement"

**Causa:** As subnets no DB Subnet Group estão na mesma AZ.

**Solução:** Garanta que as duas subnets privadas estão em AZs diferentes:
```hcl
# Subnet 1 em AZ "a"
availability_zone = data.aws_availability_zones.available.names[0]

# Subnet 2 em AZ "b"
availability_zone = data.aws_availability_zones.available.names[1]
```

### Problema: RDS demora muito para criar

**Isso é normal!** RDS leva 5-10 minutos para provisionar. O Terraform mostra:
```
aws_db_instance.main: Still creating... [5m0s elapsed]
aws_db_instance.main: Still creating... [6m0s elapsed]
```

Não cancele o apply — aguarde.

### Problema: "Connection refused" ao tentar psql do EC2

**Verificações:**
1. Security Group do RDS permite porta 5432?
2. A origem no ingress é o CIDR da VPC (10.0.0.0/16)?
3. O EC2 está na mesma VPC?
4. O endpoint está correto? (`terraform output rds_endpoint`)
5. O PostgreSQL client está instalado? (`sudo yum install -y postgresql15`)

### Problema: "psql: command not found"

```bash
# Instalar cliente PostgreSQL no Amazon Linux 2023
sudo yum install -y postgresql15
```

### Problema: "FATAL: password authentication failed"

Verifique se a senha no `terraform.tfvars` corresponde à que você está digitando. A senha é case-sensitive.

---

## Checklist de Validação

Antes de prosseguir para o Laboratório Parte 2, verifique:

- [ ] VPC criada com CIDR 10.0.0.0/16
- [ ] 1 subnet pública (EC2 com IP público)
- [ ] 2 subnets privadas em AZs diferentes
- [ ] DB Subnet Group com as 2 subnets privadas
- [ ] Security Group do RDS permite apenas porta 5432 da VPC
- [ ] RDS PostgreSQL db.t3.micro criado e available
- [ ] EC2 consegue conectar ao RDS via psql
- [ ] Dados inseridos no banco (3 pedidos de teste)
- [ ] Dados persistem após reboot do EC2
- [ ] Outputs mostram endpoint e IP corretamente
- [ ] `terraform destroy` executado com sucesso

> **Próximo passo:** Laboratório Parte 2 — Proteger o state com S3 + DynamoDB