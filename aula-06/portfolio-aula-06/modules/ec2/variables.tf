# modules/ec2/variables.tf

variable "instance_name" {
  description = "Nome da instância EC2 (usado no tag Name)"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "ID da AMI (Amazon Machine Image)"
  type        = string
}

variable "subnet_id" {
  description = "ID da subnet onde a instância será criada"
  type        = string
}

variable "security_group_ids" {
  description = "Lista de IDs dos Security Groups"
  type        = list(string)
}

variable "key_name" {
  description = "Nome do Key Pair para acesso SSH"
  type        = string
}

variable "iam_instance_profile" {
  description = "Nome do Instance Profile IAM (use LabInstanceProfile no AWS Academy)"
  type        = string
  default     = "LabInstanceProfile"
}

variable "user_data" {
  description = "Script de inicialização (opcional)"
  type        = string
  default     = ""
}

variable "root_volume_size" {
  description = "Tamanho do disco raiz em GB"
  type        = number
  default     = 8
}

variable "project_name" {
  description = "Nome do projeto (usado em tags)"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}
