terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }

  # Backend remoto: crie o bucket e a tabela ANTES (pasta infra/backend/),
  # depois preencha os valores abaixo e rode `terraform init`.
  backend "s3" {
    bucket         = "SUBSTITUA-bucket-tfstate-6325032"
    key            = "prova-primeiro-bimestre/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "SUBSTITUA-tf-locks-6325032"
    encrypt        = true
  }
}

provider "aws" {
  region = var.regiao
}
