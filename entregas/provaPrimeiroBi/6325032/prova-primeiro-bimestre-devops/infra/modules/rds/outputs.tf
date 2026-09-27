output "endpoint" {
  description = "Endpoint completo (host:porta)"
  value       = aws_db_instance.postgres.endpoint
}

output "host" {
  value = aws_db_instance.postgres.address
}

output "port" {
  value = aws_db_instance.postgres.port
}
