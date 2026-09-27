# Módulo VPC: cria a VPC, 2 sub-redes públicas + 2 privadas (2 AZs) e
# Internet Gateway. Sem NAT Gateway de propósito: o RDS na sub-rede privada
# não precisa de saída para a internet (só é acessado pelo SG da EC2 na 5432),
# e o NAT Gateway tem custo por hora — evitável no orçamento do Learner Lab.

resource "aws_vpc" "principal" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.nome_projeto}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.principal.id
  tags   = merge(var.tags, { Name = "${var.nome_projeto}-igw" })
}

# --- Sub-redes públicas (uma por AZ) ---
resource "aws_subnet" "publicas" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = var.cidrs_publicas[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, { Name = "${var.nome_projeto}-publica-${var.azs[count.index]}" })
}

# --- Sub-redes privadas (uma por AZ) ---
resource "aws_subnet" "privadas" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.principal.id
  cidr_block        = var.cidrs_privadas[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(var.tags, { Name = "${var.nome_projeto}-privada-${var.azs[count.index]}" })
}

# --- Route table pública -> Internet Gateway ---
resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.principal.id
  tags   = merge(var.tags, { Name = "${var.nome_projeto}-rt-publica" })
}

resource "aws_route" "publica_para_internet" {
  route_table_id         = aws_route_table.publica.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "publicas" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.publicas[count.index].id
  route_table_id = aws_route_table.publica.id
}

# --- Route table privada: só a rota local (implícita), sem saída à internet ---
resource "aws_route_table" "privada" {
  vpc_id = aws_vpc.principal.id
  tags   = merge(var.tags, { Name = "${var.nome_projeto}-rt-privada" })
}

resource "aws_route_table_association" "privadas" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.privadas[count.index].id
  route_table_id = aws_route_table.privada.id
}
