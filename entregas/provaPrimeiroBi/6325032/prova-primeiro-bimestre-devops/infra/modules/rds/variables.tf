variable "nome_projeto" {
  type = string
}

variable "subnets_privadas_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "engine_version" {
  type    = string
  default = "16.4"
}

variable "alocated_storage_gb" {
  type    = number
  default = 20
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
  description = "Senha do banco (defina via terraform.tfvars, nunca commitada)"
  type        = string
  sensitive   = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
