# backend/dynamodb.tf — Tabela DynamoDB para locking do Terraform state
# Aula 05: RDS e Remote State — TechNova

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "technova-terraform-locks"
  billing_mode = "PAY_PER_REQUEST" # Sem capacidade provisionada — paga por uso

  # OBRIGATÓRIO: partition key deve ser exatamente "LockID" (String)
  # O Terraform usa esse campo para registrar quem está executando o apply
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S" # String
  }

  tags = {
    Name = "technova-terraform-locks"
  }
}
