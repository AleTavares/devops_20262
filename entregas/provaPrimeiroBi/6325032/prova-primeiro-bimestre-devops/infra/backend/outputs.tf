output "bucket_tfstate_nome" {
  value = var.bucket_tfstate_nome
}

output "tabela_lock_nome" {
  value = aws_dynamodb_table.locks.name
}
