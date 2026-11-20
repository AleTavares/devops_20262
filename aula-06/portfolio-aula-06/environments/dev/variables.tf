# environments/dev/variables.tf

variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "db_password" {
  description = "Senha do banco de dados dev (fornecer via terraform.tfvars)"
  type        = string
  sensitive   = true
}
