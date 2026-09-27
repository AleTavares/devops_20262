variable "regiao" {
  type    = string
  default = "us-east-1"
}

variable "bucket_tfstate_nome" {
  description = "Nome global único do bucket S3 para o remote state"
  type        = string
  default     = "prova-primeiro-bimestre-tfstate-6325032"
}

variable "tabela_lock_nome" {
  description = "Nome da tabela DynamoDB usada para lock do state"
  type        = string
  default     = "prova-primeiro-bimestre-tf-locks-6325032"
}

variable "tags" {
  type = map(string)
  default = {
    Projeto    = "prova-primeiro-bimestre-devops"
    Disciplina = "DevOps"
    Ambiente   = "learner-lab"
  }
}
