# Assume Role Policy para o EC2
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Role para uso de serviços
resource "aws_iam_role" "ec2_app_role" {
  name               = "technova-ec2-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags = {
    Project   = "TechNova"
    ManagedBy = "Terraform"
    Purpose   = "Security"
  }
}

# Permissões do Role (EC2 acessando S3)
data "aws_iam_policy_document" "ec2_app_s3_policy_doc" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::technova-app-data-*",
      "arn:aws:s3:::technova-app-data-*/*"
    ]
  }
}

resource "aws_iam_role_policy" "ec2_app_s3_policy" {
  name   = "technova-ec2-s3-access"
  role   = aws_iam_role.ec2_app_role.id
  policy = data.aws_iam_policy_document.ec2_app_s3_policy_doc.json
}

# Instance Profile (Vincula a Role a Instância EC2)
resource "aws_iam_instance_profile" "ec2_app_profile" {
  name = "technova-ec2-app-profile"
  role = aws_iam_role.ec2_app_role.name
}
