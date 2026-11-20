# ec2.tf — EC2, Security Group e Key Pair
# Aula 05: RDS e Remote State — TechNova

# =============================================================
# SECURITY GROUP DO EC2
# =============================================================

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Permite SSH (22) e API Node.js (3000)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Em produção: restringir ao IP do admin
  }

  ingress {
    description = "API Node.js"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound (npm, yum, RDS)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# =============================================================
# KEY PAIR — gerado automaticamente pelo Terraform
# =============================================================

resource "tls_private_key" "technova" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-key-aula05"
  public_key = tls_private_key.technova.public_key_openssh

  tags = {
    Name = "${var.project_name}-key-aula05"
  }
}

# Salva chave privada localmente (está no .gitignore)
resource "local_file" "private_key" {
  content         = tls_private_key.technova.private_key_pem
  filename        = "${path.module}/technova-aula05.pem"
  file_permission = "0400"
}

# =============================================================
# INSTÂNCIA EC2
# =============================================================

resource "aws_instance" "api" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.ec2_instance_type # t2.micro
  key_name               = aws_key_pair.main.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = "LabInstanceProfile" # AWS Academy Learner Lab

  # User Data: instala Node.js 18, PostgreSQL client e API Express
  user_data = file("${path.module}/user_data.sh")

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true

    tags = {
      Name = "${var.project_name}-api-disk"
    }
  }

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-api-server"
  }
}
