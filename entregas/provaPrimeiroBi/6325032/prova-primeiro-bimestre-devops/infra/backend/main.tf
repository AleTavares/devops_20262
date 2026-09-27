# Cria o bucket S3 (versionado + criptografado) e a tabela DynamoDB (lock)
# usados como backend remoto pelo Terraform em infra/. Rode este projeto
# UMA VEZ, antes de configurar o backend "s3" em infra/providers.tf.

resource "aws_s3_bucket" "tfstate" {
  bucket = var.bucket_tfstate_nome
  tags   = merge(var.tags, { Name = var.bucket_tfstate_nome })
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "locks" {
  name         = var.tabela_lock_nome
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(var.tags, { Name = var.tabela_lock_nome })
}
