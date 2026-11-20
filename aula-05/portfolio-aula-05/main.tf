# main.tf — Data sources compartilhados
# Aula 05: RDS e Remote State — TechNova

# Busca AZs disponíveis na região dinamicamente
# Evita fixar "us-east-1a" e "us-east-1b" hard-coded
data "aws_availability_zones" "available" {
  state = "available"
}

# Busca AMI mais recente do Amazon Linux 2023
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
