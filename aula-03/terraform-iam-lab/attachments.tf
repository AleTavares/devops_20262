# Juliana -> Developers
resource "aws_iam_user_group_membership" "juliana_membership" {
  user   = aws_iam_user.juliana_santos.name
  groups = [aws_iam_group.developers.name]
}

# Rafael -> Developers + Platform Eng
resource "aws_iam_user_group_membership" "rafael_membership" {
  user = aws_iam_user.rafael_oliveira.name
  groups = [
    aws_iam_group.developers.name,
    aws_iam_group.platform_eng.name
  ]
}

# Lucas -> Interns
resource "aws_iam_user_group_membership" "lucas_membership" {
  user   = aws_iam_user.lucas_intern.name
  groups = [aws_iam_group.interns.name]
}

# Attach Policies to Groups
resource "aws_iam_group_policy_attachment" "dev_policy_attach" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developer_policy.arn
}

resource "aws_iam_group_policy_attachment" "platform_policy_attach" {
  group      = aws_iam_group.platform_eng.name
  policy_arn = aws_iam_policy.platform_policy.arn
}

resource "aws_iam_group_policy_attachment" "intern_policy_attach" {
  group      = aws_iam_group.interns.name
  policy_arn = aws_iam_policy.intern_policy.arn
}
