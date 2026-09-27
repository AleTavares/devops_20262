terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }

  backend "s3" {
    bucket         = "prova-primeiro-bimestre-tfstate-6325032"
    key            = "prova-primeiro-bimestre/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "prova-primeiro-bimestre-tf-locks-6325032"
    encrypt        = true
  }
}

provider "aws" {
  region = var.regiao
}
