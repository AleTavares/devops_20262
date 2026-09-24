resource "aws_iam_user" "juliana_santos" {
  name = "juliana.santos"
  tags = {
    Project   = "TechNova"
    Team      = "Development"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_user" "rafael_oliveira" {
  name = "rafael.oliveira"
  tags = {
    Project   = "TechNova"
    Team      = "Development and Platform Engineering"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_user" "lucas_intern" {
  name = "lucas.intern"
  tags = {
    Project   = "TechNova"
    Team      = "Development"
    ManagedBy = "Terraform"
  }
}
