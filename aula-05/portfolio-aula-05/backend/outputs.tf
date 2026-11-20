# backend/outputs.tf — Valores necessários para configurar o backend no projeto principal

output "s3_bucket_name" {
  description = "Nome do bucket S3 — usar em providers.tf do projeto principal"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB — usar em providers.tf do projeto principal"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "backend_config" {
  description = "Bloco backend pronto para colar no providers.tf do projeto principal"
  value       = <<-EOT
    backend "s3" {
      bucket         = "${aws_s3_bucket.terraform_state.id}"
      key            = "aula-05/terraform.tfstate"
      region         = "us-east-1"
      encrypt        = true
      dynamodb_table = "${aws_dynamodb_table.terraform_locks.name}"
    }
  EOT
}
