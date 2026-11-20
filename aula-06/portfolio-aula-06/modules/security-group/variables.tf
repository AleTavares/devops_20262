# modules/security-group/variables.tf

variable "name" {
  description = "Nome do Security Group"
  type        = string
}

variable "description" {
  description = "Descrição do Security Group"
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "ID da VPC onde o Security Group será criado"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto (usado em tags)"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

# Lista de regras de entrada — genérica para qualquer tipo de SG
# Exemplo para SG de API:
# ingress_rules = [
#   { port = 22,   protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "SSH" },
#   { port = 3000, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "API" }
# ]
# Exemplo para SG de RDS (usando source_sg em vez de cidr):
# ingress_rules = [
#   { port = 5432, protocol = "tcp", source_sg_id = "<sg-id>", description = "PostgreSQL from API" }
# ]
variable "ingress_rules" {
  description = "Lista de regras de ingress (cidr_blocks OU source_sg_id)"
  type = list(object({
    port        = number
    protocol    = string
    description = string
    # Apenas um dos dois deve ser preenchido por regra:
    cidr_blocks  = optional(list(string), [])
    source_sg_id = optional(string, "")
  }))
  default = []
}
