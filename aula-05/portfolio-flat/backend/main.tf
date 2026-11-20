# backend/main.tf — Infraestrutura de Remote State: S3 + DynamoDB
# IMPORTANTE: Aplicar ANTES do projeto principal
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
  }
  # Este projeto NÃO usa backend remoto (ele CRIA o backend)
  # O state dele fica local — isso é intencional
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "TechNova"
      Purpose   = "Terraform Remote State"
      ManagedBy = "Terraform"
      Aula      = "05"
    }
  }
}

# Sufixo aleatório para nome globalmente único do bucket
resource "random_id" "suffix" {
  byte_length = 4
}
