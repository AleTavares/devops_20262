variable "nome_projeto" {
  type = string
}

variable "subnet_id" {
  description = "Sub-rede pública onde a instância vai rodar"
  type        = string
}

variable "security_group_id" {
  type = string
}

variable "instance_profile_name" {
  description = "Nome do instance profile do Learner Lab (LabInstanceProfile)"
  type        = string
  default     = "LabInstanceProfile"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "chave_ssh_nome" {
  description = "Nome do Key Pair (EC2) já existente na região, para acesso SSH (opcional)"
  type        = string
  default     = null
}

variable "repo_url" {
  description = "URL pública (https) do repositório Git com o código da API (app/)"
  type        = string
}

variable "repo_branch" {
  type    = string
  default = "main"
}

variable "db_host" {
  description = "Endpoint do RDS (vem do módulo rds)"
  type        = string
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "tags" {
  type    = map(string)
  default = {}
}
