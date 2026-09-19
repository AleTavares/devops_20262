# outputs.tf

output "s3_bucket_name" {
  description = "Nome do bucket S3 para o Terraform state"
  value       = aws_s3_bucket.state.id
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3"
  value       = aws_s3_bucket.state.arn
}

output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB usada para locking do state"
  value       = aws_dynamodb_table.locks.name
}
