variable "regiao" {
  description = "Região AWS obrigatória do Learner Lab"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.regiao == "us-east-1"
    error_message = "O AWS Academy Learner Lab exige a região us-east-1."
  }
}

variable "nome_projeto" {
  type    = string
  default = "reservas-6325032"
}

variable "azs" {
  description = "2 Availability Zones de us-east-1"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_profile_name" {
  type    = string
  default = "LabInstanceProfile"
}

variable "chave_ssh_nome" {
  description = "Key Pair já existente na conta (crie um no console EC2 > Key Pairs antes do apply)"
  type        = string
}

variable "repo_url" {
  description = "URL pública https do seu repositório prova-primeiro-bimestre-devops"
  type        = string
}

variable "repo_branch" {
  type    = string
  default = "main"
}

variable "db_name" {
  type    = string
  default = "reservas"
}

variable "db_user" {
  type    = string
  default = "postgres"
}

variable "db_password" {
  description = "Senha do RDS — defina em terraform.tfvars (nunca commitado)"
  type        = string
  sensitive   = true
}

variable "tags" {
  type = map(string)
  default = {
    Projeto    = "prova-primeiro-bimestre-devops"
    Disciplina = "DevOps"
    Ambiente   = "learner-lab"
  }
}
