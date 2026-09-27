# Módulo RDS: PostgreSQL em sub-redes privadas, não acessível publicamente,
# armazenamento criptografado, e acessível apenas pelo SG da EC2 (via regra
# criada no módulo security-group).

resource "aws_db_subnet_group" "privado" {
  name       = "${var.nome_projeto}-rds-subnet-group"
  subnet_ids = var.subnets_privadas_ids

  tags = merge(var.tags, { Name = "${var.nome_projeto}-rds-subnet-group" })
}

resource "aws_db_instance" "postgres" {
  identifier     = "${var.nome_projeto}-rds"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.alocated_storage_gb
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_user
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.privado.name
  vpc_security_group_ids = [var.security_group_id]
  publicly_accessible    = false
  multi_az               = false

  # Learner Lab: sem valor em produção manter snapshot; aqui priorizamos
  # destruir rápido e sem travas ao final do laboratório.
  skip_final_snapshot = true
  deletion_protection = false

  backup_retention_period = 0

  tags = merge(var.tags, { Name = "${var.nome_projeto}-rds" })
}
