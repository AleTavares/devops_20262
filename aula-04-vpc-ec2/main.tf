# main.tf - Recursos de rede da TechNova

# =============================================================
# VPC
# =============================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}
# =============================================================
# SUBNETS
# =============================================================

# Subnet Pública - para recursos que precisam de acesso à internet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
    Type = "public"
  }
}
# Subnet Privada - para recursos internos (banco de dados, cache)
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.project_name}-private-subnet"
    Type = "private"
  }
}
# =============================================================
# INTERNET GATEWAY
# =============================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}
# =============================================================
# ROUTE TABLES
# =============================================================

# Route Table para a subnet pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Rota para a internet via Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}
# Associação: Route Table Pública ↔ Subnet Pública
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
# =============================================================
# SECURITY GROUPS
# =============================================================

# Security Group para a API (EC2 na subnet pública)
resource "aws_security_group" "api" {
  name        = "${var.project_name}-api-sg"
  description = "Security group para a API TechNova - permite HTTP e SSH"
  vpc_id      = aws_vpc.main.id

  # SSH - acesso para administração
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Em produção, restringir ao seu IP!
  }

  # API Node.js - acesso público
  ingress {
    description = "API Node.js"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Saída - permitir todo tráfego de saída
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-api-sg"
  }
}
# Security Group para o banco de dados (subnet privada)
resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Security group para o banco de dados - acesso apenas da VPC"
  vpc_id      = aws_vpc.main.id

  # PostgreSQL - acesso apenas de dentro da VPC
  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # Apenas tráfego interno da VPC (10.0.0.0/16)
  }

  # Saída - permitir todo tráfego de saída
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

# =============================================================
# DATA SOURCE — AMI Amazon Linux 2023 (mais recente)
# =============================================================

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
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# =============================================================
# KEY PAIR — Chave SSH para acesso à instância
# =============================================================

resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-key"
  public_key = file("~/.ssh/technova-key.pub")

  tags = {
    Name = "${var.project_name}-key"
  }
}

# =============================================================
# EC2 INSTANCE — API TechNova
# =============================================================

resource "aws_instance" "api" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.api.id]
  key_name               = aws_key_pair.main.key_name
  iam_instance_profile   = "LabInstanceProfile"

  user_data = file("user_data.sh")

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-api-ec2"
  }
}
