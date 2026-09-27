# outputs.tf - Valores exportados após a criação

output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID da subnet pública"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID da subnet privada"
  value       = aws_subnet.private.id
}

output "api_security_group_id" {
  description = "ID do Security Group da API"
  value       = aws_security_group.api.id
}

output "db_security_group_id" {
  description = "ID do Security Group do banco de dados"
  value       = aws_security_group.db.id
}

output "internet_gateway_id" {
  description = "ID do Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "ec2_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.api.public_ip
}

output "ec2_public_dns" {
  description = "DNS público da instância EC2"
  value       = aws_instance.api.public_dns
}

output "ssh_command" {
  description = "Comando SSH para conectar na instância"
  value       = "ssh -i ~/.ssh/technova-key ec2-user@${aws_instance.api.public_ip}"
}

output "api_url" {
  description = "URL da API TechNova"
  value       = "http://${aws_instance.api.public_ip}:3000"
}
