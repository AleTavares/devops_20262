# modules/rds/outputs.tf

output "db_endpoint" {
  description = "Endpoint completo do RDS (host:porta)"
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "Hostname do RDS (sem porta)"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Porta do RDS"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Nome do banco de dados"
  value       = aws_db_instance.this.db_name
}

output "db_identifier" {
  description = "Identificador da instância RDS"
  value       = aws_db_instance.this.identifier
}
