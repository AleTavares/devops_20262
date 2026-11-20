# outputs.tf - Valores exportados após terraform apply

# =============================================================
# VPC
# =============================================================

output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "Bloco CIDR da VPC"
  value       = aws_vpc.main.cidr_block
}

# =============================================================
# SUBNETS
# =============================================================

output "public_subnet_ids" {
  description = "Lista de IDs das subnets públicas (2 AZs)"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Lista de IDs das subnets privadas (2 AZs)"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas"
  value       = aws_subnet.private[*].cidr_block
}

# =============================================================
# INTERNET GATEWAY & ROUTE TABLE
# =============================================================

output "internet_gateway_id" {
  description = "ID do Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "ID da Route Table pública"
  value       = aws_route_table.public.id
}

# =============================================================
# SECURITY GROUPS
# =============================================================

output "api_security_group_id" {
  description = "ID do Security Group da API"
  value       = aws_security_group.api.id
}

output "db_security_group_id" {
  description = "ID do Security Group do banco de dados"
  value       = aws_security_group.db.id
}

# =============================================================
# EC2
# =============================================================

output "ec2_instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.api.id
}

output "ec2_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.api.public_ip
}

output "ec2_public_dns" {
  description = "DNS público da instância EC2"
  value       = aws_instance.api.public_dns
}

output "ec2_availability_zone" {
  description = "Availability Zone onde a instância foi criada"
  value       = aws_instance.api.availability_zone
}

output "ami_id" {
  description = "ID da AMI utilizada (Amazon Linux 2023)"
  value       = data.aws_ami.amazon_linux_2023.id
}

# =============================================================
# URLs E COMANDOS — prontos para usar
# =============================================================

output "api_url" {
  description = "URL completa da API TechNova"
  value       = "http://${aws_instance.api.public_ip}:3000"
}

output "api_health_url" {
  description = "URL do health check da API"
  value       = "http://${aws_instance.api.public_ip}:3000/health"
}

output "ssh_command" {
  description = "Comando SSH para conectar à instância (aguarde ~2 min após apply)"
  value       = "ssh -i ${path.module}/technova-key.pem ec2-user@${aws_instance.api.public_ip}"
}

output "curl_test_commands" {
  description = "Comandos curl para testar a API após inicialização"
  value = <<-EOT
    # Aguarde ~3 minutos após o apply para o User Data concluir
    curl http://${aws_instance.api.public_ip}:3000
    curl http://${aws_instance.api.public_ip}:3000/health
    curl http://${aws_instance.api.public_ip}:3000/orders
  EOT
}

output "private_key_path" {
  description = "Caminho local da chave privada SSH (NÃO versionar no Git)"
  value       = "${path.module}/technova-key.pem"
  sensitive   = true
}
