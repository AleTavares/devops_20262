# Groups
resource "aws_iam_group" "developers" {
  name = "${var.ra}-technova-developers"
}

resource "aws_iam_group" "platform_eng" {
  name = "${var.ra}-technova-platform-eng"
}

# Users
resource "aws_iam_user" "juliana" {
  name = "${var.ra}-juliana-dev"
  tags = local.common_tags
}

resource "aws_iam_user" "rafael" {
  name = "${var.ra}-rafael-platform"
  tags = local.common_tags
}

resource "aws_iam_user" "lucas" {
  name = "${var.ra}-lucas-intern"
  tags = local.common_tags
}

# Memberships
resource "aws_iam_user_group_membership" "juliana_membership" {
  user = aws_iam_user.juliana.name
  groups = [
    aws_iam_group.developers.name
  ]
}

resource "aws_iam_user_group_membership" "rafael_membership" {
  user = aws_iam_user.rafael.name
  groups = [
    aws_iam_group.developers.name,
    aws_iam_group.platform_eng.name
  ]
}

resource "aws_iam_user_group_membership" "lucas_membership" {
  user = aws_iam_user.lucas.name
  groups = [
    aws_iam_group.developers.name
  ]
}
