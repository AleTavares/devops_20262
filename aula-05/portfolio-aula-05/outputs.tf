# outputs.tf — Outputs após terraform apply
# Aula 05: RDS e Remote State — TechNova

# =============================================================
# VPC
# =============================================================

output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

# =============================================================
# RDS
# =============================================================

output "rds_endpoint" {
  description = "Endpoint completo do RDS (host:porta)"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "Hostname do RDS (sem porta)"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "Porta do RDS"
  value       = aws_db_instance.main.port
}

output "rds_database_name" {
  description = "Nome do banco de dados"
  value       = aws_db_instance.main.db_name
}

output "rds_identifier" {
  description = "Identificador da instância RDS"
  value       = aws_db_instance.main.identifier
}

# =============================================================
# EC2
# =============================================================

output "ec2_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.api.public_ip
}

output "ec2_public_dns" {
  description = "DNS público da instância EC2"
  value       = aws_instance.api.public_dns
}

# =============================================================
# COMANDOS PRONTOS PARA USO
# =============================================================

output "ssh_command" {
  description = "Comando SSH para conectar ao EC2"
  value       = "ssh -i ${path.module}/technova-aula05.pem ec2-user@${aws_instance.api.public_ip}"
}

output "psql_command" {
  description = "Comando psql para conectar ao RDS a partir do EC2 (execute de dentro do EC2)"
  value       = "psql -h ${aws_db_instance.main.address} -U ${var.db_username} -d ${var.db_name} -p ${aws_db_instance.main.port}"
}

output "connection_string" {
  description = "String de conexão PostgreSQL completa"
  value       = "postgresql://${var.db_username}@${aws_db_instance.main.address}:${aws_db_instance.main.port}/${var.db_name}"
  # Não inclui a senha (sensitive) — adicionar manualmente ao usar
}

output "api_url" {
  description = "URL da API TechNova"
  value       = "http://${aws_instance.api.public_ip}:3000"
}

output "private_key_path" {
  description = "Caminho local da chave privada SSH (NÃO versionar)"
  value       = "${path.module}/technova-aula05.pem"
  sensitive   = true
}
