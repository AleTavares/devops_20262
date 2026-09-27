variable "nome_projeto" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "cidr_ssh_permitido" {
  description = "CIDR permitido para SSH (22). Restrinja ao seu IP em vez de 0.0.0.0/0 quando possível."
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  type    = map(string)
  default = {}
}
