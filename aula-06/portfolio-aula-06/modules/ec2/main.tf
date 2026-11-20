# modules/ec2/main.tf
# Módulo EC2 — instância reutilizável com AMI, tipo, subnet e SGs configuráveis

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile

  # User data é opcional — string vazia = sem script de inicialização
  user_data = var.user_data != "" ? var.user_data : null

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_volume_size
    delete_on_termination = true

    tags = {
      Name        = "${var.project_name}-${var.environment}-${var.instance_name}-disk"
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.instance_name}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
