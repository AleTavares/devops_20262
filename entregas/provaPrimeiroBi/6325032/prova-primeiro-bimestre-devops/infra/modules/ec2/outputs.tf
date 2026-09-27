output "instance_id" {
  value = aws_instance.api.id
}

output "ip_publico" {
  value = aws_instance.api.public_ip
}

output "url_api" {
  value = "http://${aws_instance.api.public_ip}:${var.app_port}"
}
