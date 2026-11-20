# providers.tf — Configuração do Terraform, providers e backend remoto
# Aula 05: RDS e Remote State — TechNova

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }

  # Backend S3 — Remote State
  # O bucket e a tabela DynamoDB são criados pela pasta backend/
  # Substitua os valores abaixo pelos outputs do `terraform apply` em backend/
  # Após substituir, rode: terraform init -migrate-state
  backend "s3" {
    bucket         = "SUBSTITUIR-PELO-BUCKET-DO-BACKEND"
    key            = "aula-05/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "technova-terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "TechNova"
      Environment = "development"
      ManagedBy   = "Terraform"
      Aula        = "05"
      Owner       = var.owner_ra
    }
  }
}
