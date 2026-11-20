# environments/dev/main.tf
# Ambiente DEV — chama os 4 módulos e demonstra composição completa

locals {
  project_name = "technova"
  environment  = "dev"
  aws_region   = "us-east-1"
}

# ─── DATA SOURCES ─────────────────────────────────────────────────────────────

# AMI mais recente do Amazon Linux 2023
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Key pair gerado automaticamente
resource "tls_private_key" "dev" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "dev" {
  key_name   = "${local.project_name}-${local.environment}-key"
  public_key = tls_private_key.dev.public_key_openssh

  tags = {
    Name = "${local.project_name}-${local.environment}-key"
  }
}

resource "local_file" "dev_private_key" {
  content         = tls_private_key.dev.private_key_pem
  filename        = "${path.module}/technova-dev.pem"
  file_permission = "0400"
}

# =============================================================
# MÓDULO 1 — VPC (com for_each para subnets dinâmicas)
# =============================================================

module "vpc" {
  source = "../../modules/vpc"

  project_name = local.project_name
  environment  = local.environment
  vpc_cidr     = "10.0.0.0/16"

  subnets = {
    # Subnets públicas — EC2 e recursos com acesso à internet
    "public-1" = { cidr = "10.0.1.0/24", az = "${local.aws_region}a", type = "public" }
    "public-2" = { cidr = "10.0.2.0/24", az = "${local.aws_region}b", type = "public" }

    # Subnets privadas — RDS (2 AZs obrigatórias para DB Subnet Group)
    "private-1" = { cidr = "10.0.3.0/24", az = "${local.aws_region}a", type = "private" }
    "private-2" = { cidr = "10.0.4.0/24", az = "${local.aws_region}b", type = "private" }
  }
}

# =============================================================
# MÓDULO 2a — Security Group da API
# Composição: usa module.vpc.vpc_id (output do módulo VPC)
# =============================================================

module "api_sg" {
  source = "../../modules/security-group"

  name         = "api-sg"
  description  = "Security Group para API TechNova dev — SSH e porta 3000"
  vpc_id       = module.vpc.vpc_id   # ← COMPOSIÇÃO: output do módulo VPC
  project_name = local.project_name
  environment  = local.environment

  ingress_rules = [
    {
      port        = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 3000
      protocol    = "tcp"
      description = "API-NodeJS"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# =============================================================
# MÓDULO 2b — Security Group do RDS
# Porta 5432 apenas do SG da API (least privilege)
# =============================================================

module "rds_sg" {
  source = "../../modules/security-group"

  name         = "rds-sg"
  description  = "Security Group para RDS dev — PostgreSQL apenas da API"
  vpc_id       = module.vpc.vpc_id   # ← COMPOSIÇÃO
  project_name = local.project_name
  environment  = local.environment

  ingress_rules = [
    {
      port         = 5432
      protocol     = "tcp"
      description  = "PostgreSQL-from-API"
      cidr_blocks  = []
      source_sg_id = module.api_sg.sg_id  # ← COMPOSIÇÃO: output do módulo API SG
    }
  ]
}

# =============================================================
# MÓDULO 3 — EC2
# Composição: subnet_id e sg_ids vêm dos módulos VPC e SG
# =============================================================

module "api_server" {
  source = "../../modules/ec2"

  instance_name        = "api-server"
  instance_type        = "t2.micro"
  ami_id               = data.aws_ami.amazon_linux_2023.id
  subnet_id            = module.vpc.public_subnet_ids[0]    # ← COMPOSIÇÃO: output VPC
  security_group_ids   = [module.api_sg.sg_id]              # ← COMPOSIÇÃO: output SG
  key_name             = aws_key_pair.dev.key_name
  iam_instance_profile = "LabInstanceProfile"
  project_name         = local.project_name
  environment          = local.environment

  user_data = <<-EOT
    #!/bin/bash
    yum update -y
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    yum install -y nodejs postgresql15
    echo "TechNova Dev API instalada" >> /var/log/setup.log
  EOT
}

# =============================================================
# MÓDULO 4 — RDS
# Composição: subnet_ids e sg_ids vêm dos módulos VPC e SG
# =============================================================

module "database" {
  source = "../../modules/rds"

  project_name       = local.project_name
  environment        = local.environment
  db_name            = "technova_dev"
  db_username        = "technova_admin"
  db_password        = var.db_password
  subnet_ids         = module.vpc.private_subnet_ids        # ← COMPOSIÇÃO: output VPC (privadas)
  security_group_ids = [module.rds_sg.sg_id]                # ← COMPOSIÇÃO: output RDS SG
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
}
