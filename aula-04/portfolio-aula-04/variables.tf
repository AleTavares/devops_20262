# variables.tf - Variáveis do projeto TechNova VPC + EC2 Multi-AZ

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
  description = "RA do aluno - usado nas tags Owner"
  type        = string
  default     = "1120245"
}

# ─── VPC ────────────────────────────────────────────────────────────────────

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC principal"
  type        = string
  default     = "10.0.0.0/16"
}

# ─── Subnets ─────────────────────────────────────────────────────────────────

variable "public_subnet_cidrs" {
  description = "Lista de CIDRs para as 2 subnets públicas (uma por AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Lista de CIDRs para as 2 subnets privadas (uma por AZ)"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Lista de Availability Zones para distribuir as subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ─── EC2 ──────────────────────────────────────────────────────────────────────

variable "instance_type" {
  description = "Tipo de instância EC2 (sempre t2.micro para Free Tier)"
  type        = string
  default     = "t2.micro"
}

variable "root_volume_size" {
  description = "Tamanho do disco raiz em GB"
  type        = number
  default     = 8
}

variable "api_port" {
  description = "Porta em que a API Node.js escuta"
  type        = number
  default     = 3000
}

# ─── IAM (AWS Academy) ───────────────────────────────────────────────────────

variable "instance_profile_name" {
  description = "Nome do Instance Profile pré-existente no AWS Academy Learner Lab"
  type        = string
  default     = "LabInstanceProfile"
}
