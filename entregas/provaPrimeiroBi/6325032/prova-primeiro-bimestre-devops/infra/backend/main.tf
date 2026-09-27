# Backend auxiliar do Terraform:
# cria a tabela DynamoDB usada para lock do state.
#
# O bucket S3 já foi criado no AWS Learner Lab via AWS CLI porque
# a SCP do laboratório bloqueia a chamada GetObjectLockConfiguration
# usada pelo recurso aws_s3_bucket do provider Terraform.

resource "aws_dynamodb_table" "locks" {
  name         = var.tabela_lock_nome
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(var.tags, {
    Name = var.tabela_lock_nome
  })
}
