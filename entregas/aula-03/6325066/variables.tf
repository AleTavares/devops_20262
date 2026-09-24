variable "project_name" {
  type    = string
  default = "TechNova"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "aluno" {
  type    = string
  default = "Maximus Ponciano"
}

variable "ra" {
  type    = string
  default = "6325066"
}

variable "disciplina" {
  type    = string
  default = "DevOps - UniFAAT 2026-2"
}

variable "aula" {
  type    = string
  default = "03"
}

locals {
  common_tags = {
    Project    = var.project_name
    ManagedBy  = "Terraform"
    Aluno      = var.aluno
    RA         = var.ra
    Disciplina = var.disciplina
    Aula       = var.aula
  }
}
