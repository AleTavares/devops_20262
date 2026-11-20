# variables.tf — Variáveis do projeto TechNova Aula 05

variable "aws_region" {
  description = "Região AWS para criar os recursos"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto (usado em tags e nomes de recursos)"
  type        = string
  default     = "technova"
}

variable "owner_ra" {
  description = "RA do aluno — usado nas tags Owner"
  type        = string
  default     = "1120245"
}

# ─── VPC ────────────────────────────────────────────────────────────────────

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# ─── RDS ─────────────────────────────────────────────────────────────────────

variable "db_name" {
  description = "Nome do banco de dados PostgreSQL"
  type        = string
  default     = "technova"
}

variable "db_username" {
  description = "Username administrador do RDS"
  type        = string
  default     = "technova_admin"
}

variable "db_password" {
  description = "Senha do banco de dados RDS (use terraform.tfvars — nunca commitar)"
  type        = string
  sensitive   = true
  # Sem default — deve ser fornecida via terraform.tfvars ou variável de ambiente
}

variable "db_instance_class" {
  description = "Tipo de instância RDS (sempre db.t3.micro para Free Tier)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Armazenamento em GB (20 GB = Free Tier)"
  type        = number
  default     = 20
}

# ─── EC2 ──────────────────────────────────────────────────────────────────────

variable "ec2_instance_type" {
  description = "Tipo de instância EC2 (sempre t2.micro para Free Tier)"
  type        = string
  default     = "t2.micro"
}
