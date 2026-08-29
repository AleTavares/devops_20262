data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Policy 1: S3 Read (developers)
resource "aws_iam_policy" "s3_read" {
  name        = "${var.ra}-technova-s3-read"
  description = "Permite leitura de buckets S3 technova-*"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::technova-*",
          "arn:aws:s3:::technova-*/*"
        ]
      }
    ]
  })
  tags = local.common_tags
}

resource "aws_iam_group_policy_attachment" "developers_s3_read" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.s3_read.arn
}

# Policy 2: EC2 Start/Stop + S3 Full (platform-eng)
resource "aws_iam_policy" "ec2_s3_full" {
  name        = "${var.ra}-technova-ec2-s3-full"
  description = "Permite gerenciamento de EC2 com base em tags e acesso full S3"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "s3:*"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Project" = "TechNova"
          }
        }
      }
    ]
  })
  tags = local.common_tags
}

resource "aws_iam_group_policy_attachment" "platform_eng_ec2_s3_full" {
  group      = aws_iam_group.platform_eng.name
  policy_arn = aws_iam_policy.ec2_s3_full.arn
}

# Policy 3: Deny Destructive (developers)
resource "aws_iam_policy" "deny_destructive" {
  name        = "${var.ra}-technova-deny-destructive"
  description = "Deny explicito para operacoes destrutivas como Delete e Terminate"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Deny"
        Action   = [
          "ec2:TerminateInstances",
          "s3:DeleteBucket",
          "s3:DeleteObject"
        ]
        Resource = "*"
      }
    ]
  })
  tags = local.common_tags
}

resource "aws_iam_group_policy_attachment" "developers_deny_destructive" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.deny_destructive.arn
}
