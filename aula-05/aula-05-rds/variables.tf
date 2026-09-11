# variables.tf

variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto (usado em tags e nomes)"
  type        = string
  default     = "technova"
}

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_username" {
  description = "Username do banco de dados RDS"
  type        = string
  default     = "technova_admin"
}

variable "db_password" {
  description = "Password do banco de dados RDS"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "technova"
}

variable "ssh_public_key_path" {
  description = "Caminho para a chave pública SSH usada no EC2"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
