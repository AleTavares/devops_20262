output "sg_ec2_id" {
  value = aws_security_group.ec2.id
}

output "sg_rds_id" {
  value = aws_security_group.rds.id
}
