# modules/vpc/outputs.tf

output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block da VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Lista de IDs das subnets públicas"
  value = [
    for k, s in aws_subnet.this : s.id
    if var.subnets[k].type == "public"
  ]
}

output "private_subnet_ids" {
  description = "Lista de IDs das subnets privadas"
  value = [
    for k, s in aws_subnet.this : s.id
    if var.subnets[k].type == "private"
  ]
}

output "all_subnet_ids" {
  description = "Mapa completo: chave → ID da subnet"
  value       = { for k, s in aws_subnet.this : k => s.id }
}

output "internet_gateway_id" {
  description = "ID do Internet Gateway"
  value       = aws_internet_gateway.main.id
}
