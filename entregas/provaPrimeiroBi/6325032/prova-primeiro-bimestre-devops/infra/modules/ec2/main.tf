# Módulo EC2: instância na sub-rede pública, com LabInstanceProfile
# (sem criar IAM próprio) e user_data que instala Docker, clona o repositório
# e sobe o container da API conectado ao RDS.

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "api" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = var.instance_profile_name
  key_name                    = var.chave_ssh_nome

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    repo_url    = var.repo_url
    repo_branch = var.repo_branch
    db_host     = var.db_host
    db_port     = var.db_port
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
    app_port    = var.app_port
  })

  tags = merge(var.tags, { Name = "${var.nome_projeto}-ec2-api" })
}
