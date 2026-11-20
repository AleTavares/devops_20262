# environments/staging/outputs.tf

output "vpc_id" {
  description = "ID da VPC staging"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.vpc.private_subnet_ids
}

output "api_sg_id" {
  description = "ID do Security Group da API"
  value       = module.api_sg.sg_id
}

output "rds_sg_id" {
  description = "ID do Security Group do RDS"
  value       = module.rds_sg.sg_id
}

output "ec2_public_ip" {
  description = "IP público do servidor API"
  value       = module.api_server.public_ip
}

output "api_url" {
  description = "URL da API"
  value       = "http://${module.api_server.public_ip}:3000"
}

output "ssh_command" {
  description = "Comando SSH para conectar ao EC2"
  value       = "ssh -i ${path.module}/technova-staging.pem ec2-user@${module.api_server.public_ip}"
}

output "rds_endpoint" {
  description = "Endpoint do RDS"
  value       = module.database.db_endpoint
}

output "psql_command" {
  description = "Comando psql para conectar ao RDS (execute de dentro do EC2)"
  value       = "psql -h ${module.database.db_address} -U technova_admin -d technova_staging -p ${module.database.db_port}"
}
