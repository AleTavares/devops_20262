# environments/staging/main.tf
# Ambiente STAGING — mesmos módulos do dev, CIDRs e nomes diferentes
# Demonstra o poder dos módulos: 0 código novo, apenas variáveis diferentes

locals {
  project_name = "technova"
  environment  = "staging"
  aws_region   = "us-east-1"
}

# ─── DATA SOURCES ─────────────────────────────────────────────────────────────

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

resource "tls_private_key" "staging" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "staging" {
  key_name   = "${local.project_name}-${local.environment}-key"
  public_key = tls_private_key.staging.public_key_openssh

  tags = {
    Name = "${local.project_name}-${local.environment}-key"
  }
}

resource "local_file" "staging_private_key" {
  content         = tls_private_key.staging.private_key_pem
  filename        = "${path.module}/technova-staging.pem"
  file_permission = "0400"
}

# =============================================================
# MÓDULO 1 — VPC
# ÚNICO valor diferente do dev: vpc_cidr e os CIDRs das subnets (10.1.x.x)
# =============================================================

module "vpc" {
  source = "../../modules/vpc"

  project_name = local.project_name
  environment  = local.environment
  vpc_cidr     = "10.1.0.0/16"   # ← Diferente do dev (10.0.0.0/16)

  subnets = {
    "public-1"  = { cidr = "10.1.1.0/24", az = "${local.aws_region}a", type = "public" }
    "public-2"  = { cidr = "10.1.2.0/24", az = "${local.aws_region}b", type = "public" }
    "private-1" = { cidr = "10.1.3.0/24", az = "${local.aws_region}a", type = "private" }
    "private-2" = { cidr = "10.1.4.0/24", az = "${local.aws_region}b", type = "private" }
  }
}

# =============================================================
# MÓDULO 2a — Security Group da API
# =============================================================

module "api_sg" {
  source = "../../modules/security-group"

  name         = "api-sg"
  description  = "Security Group para API TechNova staging — SSH e porta 3000"
  vpc_id       = module.vpc.vpc_id   # ← COMPOSIÇÃO
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
# =============================================================

module "rds_sg" {
  source = "../../modules/security-group"

  name         = "rds-sg"
  description  = "Security Group para RDS staging — PostgreSQL apenas da API"
  vpc_id       = module.vpc.vpc_id   # ← COMPOSIÇÃO
  project_name = local.project_name
  environment  = local.environment

  ingress_rules = [
    {
      port         = 5432
      protocol     = "tcp"
      description  = "PostgreSQL-from-API"
      cidr_blocks  = []
      source_sg_id = module.api_sg.sg_id   # ← COMPOSIÇÃO
    }
  ]
}

# =============================================================
# MÓDULO 3 — EC2
# =============================================================

module "api_server" {
  source = "../../modules/ec2"

  instance_name        = "api-server"
  instance_type        = "t2.micro"
  ami_id               = data.aws_ami.amazon_linux_2023.id
  subnet_id            = module.vpc.public_subnet_ids[0]   # ← COMPOSIÇÃO
  security_group_ids   = [module.api_sg.sg_id]             # ← COMPOSIÇÃO
  key_name             = aws_key_pair.staging.key_name
  iam_instance_profile = "LabInstanceProfile"
  project_name         = local.project_name
  environment          = local.environment

  user_data = <<-EOT
    #!/bin/bash
    yum update -y
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    yum install -y nodejs postgresql15
    echo "TechNova Staging API instalada" >> /var/log/setup.log
  EOT
}

# =============================================================
# MÓDULO 4 — RDS
# ÚNICO valor diferente do dev: db_name = technova_staging
# =============================================================

module "database" {
  source = "../../modules/rds"

  project_name       = local.project_name
  environment        = local.environment
  db_name            = "technova_staging"   # ← Diferente do dev (technova_dev)
  db_username        = "technova_admin"
  db_password        = var.db_password
  subnet_ids         = module.vpc.private_subnet_ids   # ← COMPOSIÇÃO
  security_group_ids = [module.rds_sg.sg_id]           # ← COMPOSIÇÃO
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
}
