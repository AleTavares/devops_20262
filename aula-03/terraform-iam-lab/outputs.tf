output "iam_users" {
  description = "Nomes dos usuários criados"
  value = [
    aws_iam_user.juliana_santos.name,
    aws_iam_user.rafael_oliveira.name,
    aws_iam_user.lucas_intern.name
  ]
}

output "iam_groups" {
  description = "Grupos criados"
  value = [
    aws_iam_group.developers.name,
    aws_iam_group.platform_eng.name,
    aws_iam_group.interns.name
  ]
}

output "developer_policy_arn" {
  value = aws_iam_policy.developer_policy.arn
}

output "platform_policy_arn" {
  value = aws_iam_policy.platform_policy.arn
}

output "intern_policy_arn" {
  value = aws_iam_policy.intern_policy.arn
}

output "ec2_app_role_arn" {
  value = aws_iam_role.ec2_app_role.arn
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_app_profile.name
}
