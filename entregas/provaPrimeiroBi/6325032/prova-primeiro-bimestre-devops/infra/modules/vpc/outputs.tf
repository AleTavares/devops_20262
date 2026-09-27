output "vpc_id" {
  value = aws_vpc.principal.id
}

output "subnets_publicas_ids" {
  value = aws_subnet.publicas[*].id
}

output "subnets_privadas_ids" {
  value = aws_subnet.privadas[*].id
}
