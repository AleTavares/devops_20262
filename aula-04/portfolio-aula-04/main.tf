# main.tf - Infraestrutura completa TechNova: VPC Multi-AZ + EC2
# Aula 04 — VPC, Networking e EC2 na AWS

# =============================================================
# DATA SOURCES
# =============================================================

# Busca a AMI mais recente do Amazon Linux 2023 (sem fixar ID por região)
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
# SUBNETS — 4 no total, distribuídas em 2 AZs
# =============================================================

# Subnets Públicas (2): uma por AZ — onde ficará o EC2 e, no futuro, o ALB
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet-${count.index + 1}"
    Type        = "public"
    AZ          = var.availability_zones[count.index]
    Owner       = var.owner_ra
  }
}

# Subnets Privadas (2): uma por AZ — onde ficará o banco de dados no futuro
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  # map_public_ip_on_launch omitido (default false) — sem IP público

  tags = {
    Name        = "${var.project_name}-private-subnet-${count.index + 1}"
    Type        = "private"
    AZ          = var.availability_zones[count.index]
    Owner       = var.owner_ra
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

# Route Table pública: direciona todo tráfego externo para o IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associar a Route Table pública às DUAS subnets públicas
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

  # aws_route_table_association não suporta tags nativamente na API da AWS
}

# Subnets privadas usam a Route Table padrão da VPC (apenas rota local)
# Sem associação explícita = sem acesso à internet — comportamento desejado

# =============================================================
# SECURITY GROUPS
# =============================================================

# Security Group da API — EC2 na subnet pública
resource "aws_security_group" "api" {
  name        = "${var.project_name}-api-sg"
  description = "Permite SSH (22) e acesso a API Node.js (3000) — TechNova"
  vpc_id      = aws_vpc.main.id

  # SSH — administração remota
  # Em produção: restringir ao IP do administrador (ex: "203.0.113.50/32")
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # API Node.js — acesso público
  ingress {
    description = "API Node.js"
    from_port   = var.api_port
    to_port     = var.api_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: todo tráfego de saída permitido (para npm install, yum update, etc.)
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

# Security Group do Banco de Dados — subnet privada (preparação para o futuro)
resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Permite PostgreSQL (5432) apenas de dentro da VPC — TechNova"
  vpc_id      = aws_vpc.main.id

  # PostgreSQL — exclusivamente tráfego interno da VPC
  ingress {
    description = "PostgreSQL from VPC only"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Egress: saída permitida para atualizações (via NAT Gateway no futuro)
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
# KEY PAIR — chave SSH para acesso ao EC2
# =============================================================

# Gera o par de chaves RSA localmente via Terraform (provider tls)
resource "tls_private_key" "technova" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Registra a chave pública na AWS
resource "aws_key_pair" "technova" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.technova.public_key_openssh

  tags = {
    Name = "${var.project_name}-key"
  }
}

# Salva a chave privada localmente para uso com SSH
# ATENÇÃO: o arquivo .pem está no .gitignore — nunca versionar
resource "local_file" "private_key" {
  content         = tls_private_key.technova.private_key_pem
  filename        = "${path.module}/technova-key.pem"
  file_permission = "0400"
}

# =============================================================
# EC2 INSTANCE — API TechNova
# =============================================================

resource "aws_instance" "api" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id # primeira subnet pública (AZ-a)
  vpc_security_group_ids = [aws_security_group.api.id]
  key_name               = aws_key_pair.technova.key_name

  # Instance Profile:
  # O TF.md pede IAM Role com AmazonS3ReadOnlyAccess — em ambiente de produção,
  # criaríamos aws_iam_role + aws_iam_instance_profile com essa permissão.
  # No AWS Academy Learner Lab, a criação de IAM Roles é bloqueada por policy.
  # Usamos o LabInstanceProfile pré-existente (contém a LabRole com S3 incluso).
  # Referência: laboratorio-parte2.md, seção troubleshooting "AccessDenied em iam:CreateRole"
  iam_instance_profile = var.instance_profile_name

  # User Data: script de inicialização (instala Node.js 18 + API Express)
  user_data = file("${path.module}/user_data.sh")

  # Disco raiz: 8 GB SSD gp2 (dentro do Free Tier de 30 GB)
  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_volume_size
    delete_on_termination = true

    tags = {
      Name        = "${var.project_name}-api-disk"
      Project     = "TechNova"
      Environment = "development"
      ManagedBy   = "Terraform"
      Owner       = var.owner_ra
    }
  }

  # Garante que o IGW exista antes de criar a instância
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-api-server"
  }
}
