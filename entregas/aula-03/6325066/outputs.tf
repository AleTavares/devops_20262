output "users" {
  description = "Nomes dos usuarios criados"
  value       = [
    aws_iam_user.juliana.name,
    aws_iam_user.rafael.name,
    aws_iam_user.lucas.name
  ]
}

output "groups" {
  description = "Nomes dos grupos criados"
  value       = [
    aws_iam_group.developers.name,
    aws_iam_group.platform_eng.name
  ]
}

output "policy_arns" {
  description = "ARNs das policies criadas"
  value       = {
    s3_read          = aws_iam_policy.s3_read.arn
    ec2_s3_full      = aws_iam_policy.ec2_s3_full.arn
    deny_destructive = aws_iam_policy.deny_destructive.arn
  }
}

output "role_arn" {
  description = "ARN da role criada"
  value       = aws_iam_role.ec2_role.arn
}
