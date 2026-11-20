# modules/vpc/variables.tf

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto (usado em tags e nomes)"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

# Mapa de subnets — chave = nome, valor = objeto com cidr, az e type
# Exemplo:
# subnets = {
#   "public-1"  = { cidr = "10.0.1.0/24", az = "us-east-1a", type = "public" }
#   "private-1" = { cidr = "10.0.3.0/24", az = "us-east-1a", type = "private" }
# }
variable "subnets" {
  description = "Mapa de subnets a criar. type deve ser 'public' ou 'private'."
  type = map(object({
    cidr = string
    az   = string
    type = string
  }))
}
