# Módulo Security Group: menor privilégio.
# - SG da EC2: libera 22 (SSH) e 3000 (API) de entrada; tudo liberado de saída.
# - SG do RDS: libera 5432 apenas a partir do SG da EC2 (não do mundo).

resource "aws_security_group" "ec2" {
  name        = "${var.nome_projeto}-sg-ec2"
  description = "Permite SSH e acesso a API da EC2"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_ssh_permitido]
  }

  ingress {
    description = "API HTTP"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.nome_projeto}-sg-ec2" })
}

resource "aws_security_group" "rds" {
  name        = "${var.nome_projeto}-sg-rds"
  description = "Permite Postgres (5432) apenas a partir do SG da EC2"
  vpc_id      = var.vpc_id

  egress {
    description = "Todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.nome_projeto}-sg-rds" })
}

# Regra separada (em vez de bloco "ingress" inline) para referenciar o SG da
# EC2 como origem, sem criar dependência circular entre os dois SGs.
resource "aws_security_group_rule" "rds_desde_ec2" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.ec2.id
  description              = "Postgres apenas a partir da EC2 da API"
}
