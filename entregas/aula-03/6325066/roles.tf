# Trust Policy for EC2
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Role
resource "aws_iam_role" "ec2_role" {
  name               = "${var.ra}-technova-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = local.common_tags
}

# Permissions Policy for Role
resource "aws_iam_policy" "ec2_role_policy" {
  name        = "${var.ra}-technova-ec2-role-policy"
  description = "Permite EC2 ler e gravar em technova-app-data-*"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::technova-app-data-*",
          "arn:aws:s3:::technova-app-data-*/*"
        ]
      }
    ]
  })
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ec2_role_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_role_policy.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.ra}-technova-ec2-profile"
  role = aws_iam_role.ec2_role.name
  tags = local.common_tags
}
