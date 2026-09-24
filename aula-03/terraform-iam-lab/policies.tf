# Política para Desenvolvedores
data "aws_iam_policy_document" "developer_policy_doc" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::technova-dados-*",
      "arn:aws:s3:::technova-dados-*/*"
    ]
  }
}

resource "aws_iam_policy" "developer_policy" {
  name        = "technova-developer-policy"
  description = "Acesso de leitura para S3 (Desenvolvedores)"
  policy      = data.aws_iam_policy_document.developer_policy_doc.json
  tags = {
    Project   = "TechNova"
    ManagedBy = "Terraform"
    Purpose   = "Security"
  }
}

# Política para Platform Engineering (EC2 com Tag Condition)
data "aws_iam_policy_document" "platform_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:RebootInstances"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = ["TechNova"]
    }
  }
}

resource "aws_iam_policy" "platform_policy" {
  name        = "technova-platform-policy"
  description = "Gerenciar EC2 da TechNova"
  policy      = data.aws_iam_policy_document.platform_policy_doc.json
  tags = {
    Project   = "TechNova"
    ManagedBy = "Terraform"
    Purpose   = "Security"
  }
}

# Política para Interns (ReadOnly com Deny Explícito)
data "aws_iam_policy_document" "intern_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:ListBucket", "ec2:Describe*"]
    resources = ["*"]
  }

  statement {
    effect = "Deny"
    actions = [
      "s3:DeleteObject",
      "s3:DeleteBucket",
      "ec2:TerminateInstances"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "intern_policy" {
  name        = "technova-intern-policy"
  description = "Somente leitura com deny explícito de exclusão"
  policy      = data.aws_iam_policy_document.intern_policy_doc.json
  tags = {
    Project   = "TechNova"
    ManagedBy = "Terraform"
    Purpose   = "Security"
  }
}
