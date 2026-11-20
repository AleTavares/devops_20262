# modules/rds/variables.tf

variable "project_name" {
  description = "Nome do projeto (usado em tags e identificadores)"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "db_username" {
  description = "Username administrador do RDS"
  type        = string
}

variable "db_password" {
  description = "Senha do banco de dados (use terraform.tfvars — nunca commitar)"
  type        = string
  sensitive   = true
}

variable "subnet_ids" {
  description = "Lista de IDs das subnets privadas para o DB Subnet Group (mínimo 2, em AZs diferentes)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Lista de IDs dos Security Groups para o RDS"
  type        = list(string)
}

variable "instance_class" {
  description = "Classe da instância RDS (sempre db.t3.micro para Free Tier)"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Armazenamento em GB (20 = Free Tier)"
  type        = number
  default     = 20
}
