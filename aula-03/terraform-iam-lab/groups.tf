resource "aws_iam_group" "developers" {
  name = "technova-developers"
}

resource "aws_iam_group" "platform_eng" {
  name = "technova-platform-eng"
}

resource "aws_iam_group" "interns" {
  name = "technova-interns"
}
