# outputs.tf

output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "rds_endpoint" {
  description = "Endpoint de conexão do RDS"
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

output "ec2_public_ip" {
  description = "IP público do EC2"
  value       = aws_instance.api.public_ip
}

output "connection_string" {
  description = "String de conexão PostgreSQL (sem senha)"
  value       = "psql -h ${aws_db_instance.main.address} -U ${var.db_username} -d ${var.db_name} -p ${aws_db_instance.main.port}"
}
