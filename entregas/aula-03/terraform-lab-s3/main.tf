# =============================================
# Lab Parte 1: Primeiro recurso Terraform na AWS
# TechNova - Infraestrutura como Código
# =============================================

# Bucket S3 para armazenar dados da TechNova
resource "aws_s3_bucket" "technova_lab" {
  bucket = "technova-lab-emilly-santos-2024"   # ⚠️ Substitua SEU-NOME

  tags = {
    Name        = "technova-lab"
    Environment = "development"
    Project     = "TechNova"
    ManagedBy   = "Terraform"
    Aula        = "03"
  }
}

# Bloquear acesso público (boa prática de segurança)
resource "aws_s3_bucket_public_access_block" "technova_lab_block" {
  bucket = aws_s3_bucket.technova_lab.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Habilitar versionamento no bucket
resource "aws_s3_bucket_versioning" "technova_lab_versioning" {
  bucket = aws_s3_bucket.technova_lab.id

  versioning_configuration {
    status = "Enabled"
  }
}
