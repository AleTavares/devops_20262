# backend/s3.tf — Bucket S3 para armazenar o Terraform state
# Aula 05: RDS e Remote State — TechNova

# Bucket S3 com nome globalmente único
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "technova-terraform-state-${random_id.suffix.hex}"
  force_destroy = true # Permite destruir mesmo com objetos (lab)

  tags = {
    Name = "technova-terraform-state-${random_id.suffix.hex}"
  }
}

# Versionamento — permite rollback do state para versão anterior
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encriptação server-side — protege senhas e dados sensíveis no state
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # SSE-S3 (sem custo adicional no Academy)
    }
    bucket_key_enabled = true
  }
}

# Block Public Access — garante que o state NUNCA seja público
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Ownership controls (necessário antes de ACLs em buckets novos)
resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
