# modules/vpc/main.tf
# Módulo VPC — VPC + subnets dinâmicas (for_each) + IGW + Route Tables

# ─── VPC ────────────────────────────────────────────────────────────────────

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ─── INTERNET GATEWAY ────────────────────────────────────────────────────────

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ─── SUBNETS (for_each) ──────────────────────────────────────────────────────
# Cria todas as subnets do mapa de uma só vez, identificadas por chave nomeada.
# Vantagem sobre count: remover uma subnet específica não reindexará as demais.

resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  # map_public_ip_on_launch = true apenas para subnets públicas
  map_public_ip_on_launch = each.value.type == "public" ? true : false

  tags = {
    Name        = "${var.project_name}-${var.environment}-${each.key}"
    Type        = each.value.type
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ─── ROUTE TABLE PÚBLICA ────────────────────────────────────────────────────

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ─── ASSOCIAÇÕES — apenas subnets públicas ───────────────────────────────────
# Filtra somente as subnets de type == "public" para associar à RT pública

resource "aws_route_table_association" "public" {
  for_each = {
    for k, v in var.subnets : k => v if v.type == "public"
  }

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public.id
}
