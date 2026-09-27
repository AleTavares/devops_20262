variable "nome_projeto" {
  description = "Prefixo usado no nome dos recursos"
  type        = string
}

variable "cidr_vpc" {
  description = "Bloco CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability Zones a usar (2 AZs)"
  type        = list(string)
}

variable "cidrs_publicas" {
  description = "Blocos CIDR das sub-redes públicas (1 por AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "cidrs_privadas" {
  description = "Blocos CIDR das sub-redes privadas (1 por AZ)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "tags" {
  description = "Tags padrão aplicadas a todos os recursos"
  type        = map(string)
  default     = {}
}
