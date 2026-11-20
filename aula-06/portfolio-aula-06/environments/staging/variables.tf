# environments/staging/variables.tf

variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "db_password" {
  description = "Senha do banco de dados staging (fornecer via terraform.tfvars)"
  type        = string
  sensitive   = true
}
