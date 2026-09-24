# dynamodb.tf

resource "aws_dynamodb_table" "locks" {
  name         = "${var.project_name}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Project = "TechNova"
    Purpose = "Terraform Remote State"
  }
}
