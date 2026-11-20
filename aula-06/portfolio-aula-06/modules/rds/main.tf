# modules/rds/main.tf
# Módulo RDS — DB Subnet Group + instância PostgreSQL

# ─── DB SUBNET GROUP ─────────────────────────────────────────────────────────
# OBRIGATÓRIO: subnets em pelo menos 2 AZs diferentes

resource "aws_db_subnet_group" "this" {
  name        = "${var.project_name}-${var.environment}-db-subnet-group"
  description = "Subnet group para RDS ${var.environment}"
  subnet_ids  = var.subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-subnet-group"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ─── INSTÂNCIA RDS ───────────────────────────────────────────────────────────

resource "aws_db_instance" "this" {
  identifier = "${var.project_name}-${var.environment}-db"

  # Engine
  engine         = "postgres"
  engine_version = "15"

  # Capacidade — Free Tier
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp2"

  # Banco
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  # Rede — subnets privadas, sem IP público
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = false

  # Sem Multi-AZ para Free Tier
  multi_az = false

  # Backup
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  # Segurança
  storage_encrypted = true

  # Para laboratório — em produção: skip_final_snapshot = false
  skip_final_snapshot          = true
  performance_insights_enabled = false

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
