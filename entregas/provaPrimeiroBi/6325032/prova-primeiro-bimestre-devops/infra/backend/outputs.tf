output "bucket_tfstate_nome" {
  value = aws_s3_bucket.tfstate.bucket
}

output "tabela_lock_nome" {
  value = aws_dynamodb_table.locks.name
}
