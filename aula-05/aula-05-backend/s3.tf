# s3.tf

# Sufixo aleatório para garantir nome de bucket globalmente único
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# KMS key para encriptação SSE-KMS do state
resource "aws_kms_key" "state" {
  description             = "KMS key para encriptação do Terraform state (${var.project_name})"
  deletion_window_in_days = 7

  tags = {
    Project = "TechNova"
    Purpose = "Terraform Remote State"
  }
}

resource "aws_s3_bucket" "state" {
  bucket = "${var.project_name}-terraform-state-${random_id.bucket_suffix.hex}"

  # Lab: permite destroy mesmo com objetos. Em produção, prevent_destroy = true.
  force_destroy = true

  tags = {
    Project = "TechNova"
    Purpose = "Terraform Remote State"
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.state.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
