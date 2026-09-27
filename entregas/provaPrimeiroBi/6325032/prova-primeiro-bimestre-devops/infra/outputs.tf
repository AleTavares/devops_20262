output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ec2_ip_publico" {
  value = module.ec2.ip_publico
}

output "url_api" {
  description = "URL da API na EC2 (ex.: http://<ip>:3000/health)"
  value       = module.ec2.url_api
}

output "rds_endpoint" {
  value = module.rds.endpoint
}
