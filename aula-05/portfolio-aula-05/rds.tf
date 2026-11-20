# rds.tf — RDS PostgreSQL, DB Subnet Group e Security Group
# Aula 05: RDS e Remote State — TechNova

# =============================================================
# DB SUBNET GROUP
# REQUISITO AWS: subnets em pelo menos 2 AZs diferentes
# =============================================================

resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Subnet group para RDS TechNova — subnets privadas em 2 AZs"
  subnet_ids  = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# =============================================================
# SECURITY GROUP DO RDS
# Porta 5432 apenas do Security Group do EC2 (least privilege)
# =============================================================

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Permite PostgreSQL (5432) apenas do EC2 da aplicação"
  vpc_id      = aws_vpc.main.id

  # Melhor prática: referenciar o SG do EC2 em vez do CIDR da VPC inteira
  # Só a instância EC2 com o SG correto pode acessar o banco
  ingress {
    description     = "PostgreSQL from EC2 app only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# =============================================================
# INSTÂNCIA RDS POSTGRESQL
# =============================================================

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-db"

  # Engine — PostgreSQL 15
  engine         = "postgres"
  engine_version = "15"

  # Capacidade — Free Tier
  instance_class    = var.db_instance_class  # db.t3.micro
  allocated_storage = var.db_allocated_storage # 20 GB
  storage_type      = "gp2"

  # Banco de dados
  db_name  = var.db_name       # technova
  username = var.db_username   # technova_admin
  password = var.db_password   # via terraform.tfvars (sensitive)
  port     = 5432

  # Rede — subnets privadas, sem IP público
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false  # NUNCA expor RDS à internet

  # Alta disponibilidade — desligada para Free Tier
  # multi_az = true dobra o custo (instância standby na outra AZ)
  multi_az = false

  # Backup automático
  backup_retention_period = 7           # 7 dias de retenção
  backup_window           = "03:00-04:00" # Janela de backup (UTC)

  # Manutenção
  maintenance_window = "sun:04:00-sun:05:00"

  # Segurança — encriptação em repouso
  storage_encrypted = true

  # Para laboratório: não criar snapshot ao destruir
  # Em PRODUÇÃO: sempre use skip_final_snapshot = false
  skip_final_snapshot = true

  # Performance Insights desligado para Free Tier
  performance_insights_enabled = false

  # Garante que a rede esteja pronta antes do RDS
  depends_on = [aws_db_subnet_group.main, aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-rds"
  }
}
