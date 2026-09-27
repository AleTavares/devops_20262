# Este projeto é aplicado ANTES do infra/ principal, com state local mesmo
# (afinal, ele CRIA o backend remoto que o infra/ principal vai usar).

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

provider "aws" {
  region = var.regiao
}
