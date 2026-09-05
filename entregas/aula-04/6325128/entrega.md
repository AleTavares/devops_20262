# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Felipe Damasceno 
**RA:** 6325128  
**Data:** 03/09/2026

## Repositório

- URL: https://github.com/FelipeDesda/unifaat-devops-portfolio

## Evidências

- [x] VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs
- [x] Internet Gateway + Route Tables configurados
- [x] Security Groups com menor privilégio
- [x] EC2 t2.micro com User Data (API rodando)
- [x] Instance Profile com IAM Role
- [x] Tags em todos os recursos
- [x] `terraform-plan-output.txt` com evidência do plano
- [x] README com diagrama da arquitetura
- [x] `terraform destroy` executado após evidências

## Evidência da API Rodando

felip@SHASHUMGA:~/ADS/DEVOPS/unifaat-devops-portfolio/aula-04$ node --version && aws sts get-caller-identity
v18.19.1
{
    "UserId": "AROAVMO447UEWYI5M5A5E:user5369375=Felipe_Damasceno",
    "Account": "370367331593",
    "Arn": "arn:aws:sts::370367331593:assumed-role/voclabs/user5369375=Felipe_Damasceno"
}

felip@SHASHUMGA:~/ADS/DEVOPS/unifaat-devops-portfolio/aula-04$ curl http://$(terraform outputcurl http://$(terraform output -raw ec2_public_ip):3000
{"status":"ok","app":"technova-api","message":"API no ar!"}

felip@SHASHUMGA:~/ADS/DEVOPS/unifaat-devops-portfolio/aula-04$ curl http://$(terraform output -raw ec2_public_ip):3000/health
{"status":"ok","app":"technova-api","message":"API no ar!"}


felip@SHASHUMGA:~/ADS/DEVOPS/unifaat-devops-portfolio/aula-04$ terraform destroy
tls_private_key.technova: Refreshing state... [id=9c2a05884f63141e95e6b126ad910398d6e200e2]
local_sensitive_file.private_key: Refreshing state... [id=fd3d63720a5c8d6a00017455e694831e393e8c0a]
data.aws_iam_instance_profile.lab: Reading...
data.aws_ami.amazon_linux_2023: Reading...
aws_key_pair.technova: Refreshing state... [id=technova-key]
aws_vpc.main: Refreshing state... [id=vpc-0024c5f6d6e1ef0bb]
data.aws_iam_instance_profile.lab: Read complete after 1s [id=AIPAVMO447UEW465MBXRM]
data.aws_ami.amazon_linux_2023: Read complete after 4s [id=ami-0ac62d2d72afdce51]
aws_internet_gateway.main: Refreshing state... [id=igw-0ee83b2a184a51c39]
aws_security_group.db: Refreshing state... [id=sg-09ce89c013df82a8a]
aws_subnet.public[1]: Refreshing state... [id=subnet-05f3fd55e98607f26]
aws_security_group.api: Refreshing state... [id=sg-0919ef3be038cb5c2]
aws_subnet.private[0]: Refreshing state... [id=subnet-05f29338aef9b157c]
aws_subnet.public[0]: Refreshing state... [id=subnet-0ad220c50e34a51b8]
aws_subnet.private[1]: Refreshing state... [id=subnet-0d417bbd1c7730525]
aws_route_table.public: Refreshing state... [id=rtb-0a02d88f9f590046c]
aws_instance.api: Refreshing state... [id=i-00ca3244a3cba00d7]
aws_route_table_association.public[0]: Refreshing state... [id=rtbassoc-0061886c1bd5c6332]
aws_route_table_association.public[1]: Refreshing state... [id=rtbassoc-0e6c577d1afee08bd]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_instance.api will be destroyed
  - resource "aws_instance" "api" {
      - ami                                  = "ami-0ac62d2d72afdce51" -> null
      - arn                                  = "arn:aws:ec2:us-east-1:370367331593:instance/i-00ca3244a3cba00d7" -> null
      - associate_public_ip_address          = true -> null
      - availability_zone                    = "us-east-1a" -> null
      - cpu_core_count                       = 1 -> null
      - cpu_threads_per_core                 = 1 -> null
      - disable_api_stop                     = false -> null
      - disable_api_termination              = false -> null
      - ebs_optimized                        = false -> null
      - get_password_data                    = false -> null
      - hibernation                          = false -> null
      - iam_instance_profile                 = "LabInstanceProfile" -> null
      - id                                   = "i-00ca3244a3cba00d7" -> null
      - instance_initiated_shutdown_behavior = "stop" -> null
      - instance_state                       = "running" -> null
      - instance_type                        = "t2.micro" -> null
      - ipv6_address_count                   = 0 -> null
      - ipv6_addresses                       = [] -> null
      - key_name                             = "technova-key" -> null
      - monitoring                           = false -> null
      - placement_partition_number           = 0 -> null
      - primary_network_interface_id         = "eni-0267f387f7883900a" -> null
      - private_dns                          = "ip-10-0-1-136.ec2.internal" -> null
      - private_ip                           = "10.0.1.136" -> null
      - public_dns                           = "ec2-13-220-53-134.compute-1.amazonaws.com" -> null
      - public_ip                            = "13.220.53.134" -> null
      - secondary_private_ips                = [] -> null
      - security_groups                      = [] -> null
      - source_dest_check                    = true -> null
      - subnet_id                            = "subnet-0ad220c50e34a51b8" -> null
      - tags                                 = {
          - "Name" = "technova-ec2-api"
        } -> null
      - tags_all                             = {
          - "Environment" = "development"
          - "ManagedBy"   = "Terraform"
          - "Name"        = "technova-ec2-api"
          - "Owner"       = "6325128"
          - "Project"     = "TechNova"
        } -> null
      - tenancy                              = "default" -> null
      - user_data                            = "317d729ad26a51306b77323d81e40c62a5e2b52f" -> null
      - user_data_replace_on_change          = true -> null
      - vpc_security_group_ids               = [
          - "sg-0919ef3be038cb5c2",
        ] -> null
        # (6 unchanged attributes hidden)

      - capacity_reservation_specification {
          - capacity_reservation_preference = "open" -> null
        }

      - cpu_options {
          - core_count       = 1 -> null
          - threads_per_core = 1 -> null
            # (1 unchanged attribute hidden)
        }

      - credit_specification {
          - cpu_credits = "standard" -> null
        }

      - enclave_options {
          - enabled = false -> null
        }

      - maintenance_options {
          - auto_recovery = "default" -> null
        }

      - metadata_options {
          - http_endpoint               = "enabled" -> null
          - http_protocol_ipv6          = "disabled" -> null
          - http_put_response_hop_limit = 2 -> null
          - http_tokens                 = "required" -> null
          - instance_metadata_tags      = "disabled" -> null
        }

      - private_dns_name_options {
          - enable_resource_name_dns_a_record    = false -> null
          - enable_resource_name_dns_aaaa_record = false -> null
          - hostname_type                        = "ip-name" -> null
        }

      - root_block_device {
          - delete_on_termination = true -> null
          - device_name           = "/dev/xvda" -> null
          - encrypted             = false -> null
          - iops                  = 3000 -> null
          - tags                  = {
              - "Name" = "technova-ec2-root-volume"
            } -> null
          - tags_all              = {
              - "Environment" = "development"
              - "ManagedBy"   = "Terraform"
              - "Name"        = "technova-ec2-root-volume"
              - "Owner"       = "6325128"
              - "Project"     = "TechNova"
            } -> null
          - throughput            = 125 -> null
          - volume_id             = "vol-09051227af665f369" -> null
          - volume_size           = 30 -> null
          - volume_type           = "gp3" -> null
            # (1 unchanged attribute hidden)
        }
    }

  # aws_internet_gateway.main will be destroyed
  - resource "aws_internet_gateway" "main" {
      - arn      = "arn:aws:ec2:us-east-1:370367331593:internet-gateway/igw-0ee83b2a184a51c39" -> null
      - id       = "igw-0ee83b2a184a51c39" -> null
      - owner_id = "370367331593" -> null
      - tags     = {
          - "Name" = "technova-igw"
        } -> null
      - tags_all = {
          - "Environment" = "development"
          - "ManagedBy"   = "Terraform"
          - "Name"        = "technova-igw"
          - "Owner"       = "6325128"
          - "Project"     = "TechNova"
        } -> null
      - vpc_id   = "vpc-0024c5f6d6e1ef0bb" -> null
    }

  # aws_key_pair.technova will be destroyed
  - resource "aws_key_pair" "technova" {
      - arn             = "arn:aws:ec2:us-east-1:370367331593:key-pair/technova-key" -> null
      - fingerprint     = "e8:fc:0d:6f:42:a6:f5:70:c8:d8:9e:c9:2b:46:b2:96" -> null
      - id              = "technova-key" -> null
      - key_name        = "technova-key" -> null
      - key_pair_id     = "key-07bfa6e3ef63d9d8a" -> null
      - key_type        = "rsa" -> null
      - public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDsrbHJM2jdBp+sYKdd9F0Yx1f8ZqZvGCnDtDULF2xzoIaVuUkrcKE+BYPX9mWZTNqGjjBfSawZ+H4XU875AGI1ONZjTsy7DL9xKrBTjnpAb9HtxC+s9yLaHD6Wg0zhmVT7dvLEoyP2V0yAnn2OBqLZ+rcn+r6nF6av/nvGgI4pIEz0k6nf8P3xa2FG7i6wnHAOqPhaU+twLZCr8GtfXGHWIXSOexxlV+PTLgQs8eq1i3LS0eEqGiToma90Rs3LINecXV97i1sVFyeWc9HsI3k9cOjOkHcQS9dlEjB01W4hbWeynA08jP8ViiQnyE/Vom8Z+35mLjn0sXSmxjoO8bQvrFEuqLhnsIkEIw/ZK+3J/GTMiJV8aTfQmPBOj4BpkA5E0x0p/7ym/z01gH2a8CZ1fNG7nlo7kTxb4TWpmKO7mzbuSx7M4KWSz5YerCI+wit4i4ZNKkSqVj6CNH0rQhVw6vz0RQYDdxRw2EbdK9eCEGWL5tRYa5LlXfuT4TSXPts/TRtgcK+9sDVq2cksWcYZb8xNxwkMKkiL6bitpY6MUlDW7jU4tt/VcP/x3pRuDN+ho8QXqR7UOjCoVTdH+YBZYBAEf9WAfUH3pmlnKZM+dYliK9uZCctSoCsF8HMTn//zf/8Fh2IzqL/pRgQQGyW46p8fyrVjm176aUDr/e/QYw==" -> null      - tags            = {
          - "Name" = "technova-key-pair"
        } -> null
      - tags_all        = {
          - "Environment" = "development"
          - "ManagedBy"   = "Terraform"
          - "Name"        = "technova-key-pair"
          - "Owner"       = "6325128"
          - "Project"     = "TechNova"
        } -> null
        # (1 unchanged attribute hidden)
    }

  # aws_route_table.public will be destroyed
  - resource "aws_route_table" "public" {
      - arn              = "arn:aws:ec2:us-east-1:370367331593:route-table/rtb-0a02d88f9f590046c" -> null
      - id               = "rtb-0a02d88f9f590046c" -> null
      - owner_id         = "370367331593" -> null
      - propagating_vgws = [] -> null
      - route            = [
          - {
              - cidr_block                 = "0.0.0.0/0"
              - gateway_id                 = "igw-0ee83b2a184a51c39"
                # (11 unchanged attributes hidden)
            },
        ] -> null
      - tags             = {
          - "Name" = "technova-rt-public"
        } -> null
      - tags_all         = {
          - "Environment" = "development"
          - "ManagedBy"   = "Terraform"
          - "Name"        = "technova-rt-public"
          - "Owner"       = "6325128"
          - "Project"     = "TechNova"
        } -> null
      - vpc_id           = "vpc-0024c5f6d6e1ef0bb" -> null
    }

  # aws_route_table_association.public[0] will be destroyed
  - resource "aws_route_table_association" "public" {
      - id             = "rtbassoc-0061886c1bd5c6332" -> null
      - route_table_id = "rtb-0a02d88f9f590046c" -> null
      - subnet_id      = "subnet-0ad220c50e34a51b8" -> null
        # (1 unchanged attribute hidden)
    }

  # aws_route_table_association.public[1] will be destroyed
  - resource "aws_route_table_association" "public" {
      - id             = "rtbassoc-0e6c577d1afee08bd" -> null
      - route_table_id = "rtb-0a02d88f9f590046c" -> null
      - subnet_id      = "subnet-05f3fd55e98607f26" -> null
        # (1 unchanged attribute hidden)
    }

  # aws_security_group.api will be destroyed
  - resource "aws_security_group" "api" {
      - arn                    = "arn:aws:ec2:us-east-1:370367331593:security-group/sg-0919ef3be038cb5c2" -> null
      - description            = "Security Group para a API TechNova (portas 22 e 3000)" -> null
      - egress                 = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = "Egress all"
              - from_port        = 0
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "-1"
              - security_groups  = []
              - self             = false
              - to_port          = 0
            },
        ] -> null
      - id                     = "sg-0919ef3be038cb5c2" -> null
      - ingress                = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = "API Node.js"
              - from_port        = 3000
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 3000
            },
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = "SSH"
              - from_port        = 22
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 22
            },
        ] -> null
      - name                   = "technova-sg-api" -> null
      - owner_id               = "370367331593" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {
          - "Name" = "technova-sg-api"
        } -> null
      - tags_all               = {
          - "Environment" = "development"
          - "ManagedBy"   = "Terraform"
          - "Name"        = "technova-sg-api"
          - "Owner"       = "6325128"
          - "Project"     = "TechNova"
        } -> null
      - vpc_id                 = "vpc-0024c5f6d6e1ef0bb" -> null
        # (1 unchanged attribute hidden)
    }

  # aws_security_group.db will be destroyed
  - resource "aws_security_group" "db" {
      - arn                    = "arn:aws:ec2:us-east-1:370367331593:security-group/sg-09ce89c013df82a8a" -> null
      - description            = "Security Group para o banco de dados PostgreSQL (acesso interno a VPC)" -> null
      - egress                 = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - description      = "Egress all"
              - from_port        = 0
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "-1"
              - security_groups  = []
              - self             = false
              - to_port          = 0
            },
        ] -> null
      - id                     = "sg-09ce89c013df82a8a" -> null
      - ingress                = [
          - {
              - cidr_blocks      = [
                  - "10.0.0.0/16",
                ]
              - description      = "PostgreSQL interno"
              - from_port        = 5432
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 5432
            },
        ] -> null
      - name                   = "technova-sg-db" -> null
      - owner_id               = "370367331593" -> null
      - revoke_rules_on_delete = false -> null
      - tags                   = {
          - "Name" = "technova-sg-db"
        } -> null
      - tags_all               = {
          - "Environment" = "development"
          - "ManagedBy"   = "Terraform"
          - "Name"        = "technova-sg-db"
          - "Owner"       = "6325128"
          - "Project"     = "TechNova"
        } -> null
      - vpc_id                 = "vpc-0024c5f6d6e1ef0bb" -> null
        # (1 unchanged attribute hidden)
    }

  # aws_subnet.private[0] will be destroyed
  - resource "aws_subnet" "private" {
      - arn                                            = "arn:aws:ec2:us-east-1:370367331593:subnet/subnet-05f29338aef9b157c" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "us-east-1a" -> null
      - availability_zone_id                           = "use1-az4" -> null
      - cidr_block                                     = "10.0.2.0/24" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-05f29338aef9b157c" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = false -> null
      - owner_id                                       = "370367331593" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - tags                                           = {
          - "Name" = "technova-subnet-private-1"
          - "Tier" = "private"
        } -> null
      - tags_all                                       = {
          - "Environment" = "development"
          - "ManagedBy"   = "Terraform"
          - "Name"        = "technova-subnet-private-1"
          - "Owner"       = "6325128"
          - "Project"     = "TechNova"
          - "Tier"        = "private"
        } -> null
      - vpc_id                                         = "vpc-0024c5f6d6e1ef0bb" -> null
        # (4 unchanged attributes hidden)
    }

  # aws_subnet.private[1] will be destroyed
  - resource "aws_subnet" "private" {
      - arn                                            = "arn:aws:ec2:us-east-1:370367331593:subnet/subnet-0d417bbd1c7730525" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "us-east-1b" -> null
      - availability_zone_id                           = "use1-az6" -> null
      - cidr_block                                     = "10.0.4.0/24" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-0d417bbd1c7730525" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = false -> null
      - owner_id                                       = "370367331593" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - tags                                           = {
          - "Name" = "technova-subnet-private-2"
          - "Tier" = "private"
        } -> null
      - tags_all                                       = {
          - "Environment" = "development"
          - "ManagedBy"   = "Terraform"
          - "Name"        = "technova-subnet-private-2"
          - "Owner"       = "6325128"
          - "Project"     = "TechNova"
          - "Tier"        = "private"
        } -> null
      - vpc_id                                         = "vpc-0024c5f6d6e1ef0bb" -> null
        # (4 unchanged attributes hidden)
    }

  # aws_subnet.public[0] will be destroyed
  - resource "aws_subnet" "public" {
      - arn                                            = "arn:aws:ec2:us-east-1:370367331593:subnet/subnet-0ad220c50e34a51b8" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "us-east-1a" -> null
      - availability_zone_id                           = "use1-az4" -> null
      - cidr_block                                     = "10.0.1.0/24" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-0ad220c50e34a51b8" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = true -> null
      - owner_id                                       = "370367331593" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - tags                                           = {
          - "Name" = "technova-subnet-public-1"
          - "Tier" = "public"
        } -> null
      - tags_all                                       = {
          - "Environment" = "development"
          - "ManagedBy"   = "Terraform"
          - "Name"        = "technova-subnet-public-1"
          - "Owner"       = "6325128"
          - "Project"     = "TechNova"
          - "Tier"        = "public"
        } -> null
      - vpc_id                                         = "vpc-0024c5f6d6e1ef0bb" -> null
        # (4 unchanged attributes hidden)
    }

  # aws_subnet.public[1] will be destroyed
  - resource "aws_subnet" "public" {
      - arn                                            = "arn:aws:ec2:us-east-1:370367331593:subnet/subnet-05f3fd55e98607f26" -> null
      - assign_ipv6_address_on_creation                = false -> null
      - availability_zone                              = "us-east-1b" -> null
      - availability_zone_id                           = "use1-az6" -> null
      - cidr_block                                     = "10.0.3.0/24" -> null
      - enable_dns64                                   = false -> null
      - enable_lni_at_device_index                     = 0 -> null
      - enable_resource_name_dns_a_record_on_launch    = false -> null
      - enable_resource_name_dns_aaaa_record_on_launch = false -> null
      - id                                             = "subnet-05f3fd55e98607f26" -> null
      - ipv6_native                                    = false -> null
      - map_customer_owned_ip_on_launch                = false -> null
      - map_public_ip_on_launch                        = true -> null
      - owner_id                                       = "370367331593" -> null
      - private_dns_hostname_type_on_launch            = "ip-name" -> null
      - tags                                           = {
          - "Name" = "technova-subnet-public-2"
          - "Tier" = "public"
        } -> null
      - tags_all                                       = {
          - "Environment" = "development"
          - "ManagedBy"   = "Terraform"
          - "Name"        = "technova-subnet-public-2"
          - "Owner"       = "6325128"
          - "Project"     = "TechNova"
          - "Tier"        = "public"
        } -> null
      - vpc_id                                         = "vpc-0024c5f6d6e1ef0bb" -> null
        # (4 unchanged attributes hidden)
    }

  # aws_vpc.main will be destroyed
  - resource "aws_vpc" "main" {
      - arn                                  = "arn:aws:ec2:us-east-1:370367331593:vpc/vpc-0024c5f6d6e1ef0bb" -> null
      - assign_generated_ipv6_cidr_block     = false -> null
      - cidr_block                           = "10.0.0.0/16" -> null
      - default_network_acl_id               = "acl-07e95cc205cf1a6e8" -> null
      - default_route_table_id               = "rtb-0a574ecc6651d77d9" -> null
      - default_security_group_id            = "sg-0e1160c0f5f6d14b6" -> null
      - dhcp_options_id                      = "dopt-00bab4ac9ca5e0584" -> null
      - enable_dns_hostnames                 = true -> null
      - enable_dns_support                   = true -> null
      - enable_network_address_usage_metrics = false -> null
      - id                                   = "vpc-0024c5f6d6e1ef0bb" -> null
      - instance_tenancy                     = "default" -> null
      - ipv6_netmask_length                  = 0 -> null
      - main_route_table_id                  = "rtb-0a574ecc6651d77d9" -> null
      - owner_id                             = "370367331593" -> null
      - tags                                 = {
          - "Name" = "technova-vpc"
        } -> null
      - tags_all                             = {
          - "Environment" = "development"
          - "ManagedBy"   = "Terraform"
          - "Name"        = "technova-vpc"
          - "Owner"       = "6325128"
          - "Project"     = "TechNova"
        } -> null
        # (4 unchanged attributes hidden)
    }

  # local_sensitive_file.private_key will be destroyed
  - resource "local_sensitive_file" "private_key" {
      - content              = (sensitive value) -> null
      - content_base64sha256 = "bCanfg8Xtug76qgHyRXZzSvf/4jgcHWeeHHMB3OR8L4=" -> null
      - content_base64sha512 = "lF0mZSWpBSzDqFgAN9ASkA8TX8m+aFVDnkmTTM/5C8J40U/MZOUcjPSFm0mh4XXOWSwGIcEdWg/wMz+/IaEIlg==" -> null
      - content_md5          = "8f4c7c04f7f31acd76f24a442f114b7a" -> null
      - content_sha1         = "fd3d63720a5c8d6a00017455e694831e393e8c0a" -> null
      - content_sha256       = "6c26a77e0f17b6e83beaa807c915d9cd2bdfff88e070759e7871cc077391f0be" -> null
      - content_sha512       = "945d266525a9052cc3a8580037d012900f135fc9be6855439e49934ccff90bc278d14fcc64e51c8cf4859b49a1e175ce592c0621c11d5a0ff0333fbf21a10896" -> null
      - directory_permission = "0700" -> null
      - file_permission      = "0600" -> null
      - filename             = "/home/felip/.ssh/technova-key.pem" -> null
      - id                   = "fd3d63720a5c8d6a00017455e694831e393e8c0a" -> null
    }

  # tls_private_key.technova will be destroyed
  - resource "tls_private_key" "technova" {
      - algorithm                     = "RSA" -> null
      - ecdsa_curve                   = "P224" -> null
      - id                            = "9c2a05884f63141e95e6b126ad910398d6e200e2" -> null
      - private_key_openssh           = (sensitive value) -> null
      - private_key_pem               = (sensitive value) -> null
      - private_key_pem_pkcs8         = (sensitive value) -> null
      - public_key_fingerprint_md5    = "36:27:81:f9:d7:e1:28:98:2e:b3:1f:d6:6f:8b:99:8b" -> null
      - public_key_fingerprint_sha256 = "SHA256:0ajg2b8TLMYxYYQAlVm6CK8Ci1qAFoYCrGi+iBXnUO4" -> null
      - public_key_openssh            = <<-EOT
            ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDsrbHJM2jdBp+sYKdd9F0Yx1f8ZqZvGCnDtDULF2xzoIaVuUkrcKE+BYPX9mWZTNqGjjBfSawZ+H4XU875AGI1ONZjTsy7DL9xKrBTjnpAb9HtxC+s9yLaHD6Wg0zhmVT7dvLEoyP2V0yAnn2OBqLZ+rcn+r6nF6av/nvGgI4pIEz0k6nf8P3xa2FG7i6wnHAOqPhaU+twLZCr8GtfXGHWIXSOexxlV+PTLgQs8eq1i3LS0eEqGiToma90Rs3LINecXV97i1sVFyeWc9HsI3k9cOjOkHcQS9dlEjB01W4hbWeynA08jP8ViiQnyE/Vom8Z+35mLjn0sXSmxjoO8bQvrFEuqLhnsIkEIw/ZK+3J/GTMiJV8aTfQmPBOj4BpkA5E0x0p/7ym/z01gH2a8CZ1fNG7nlo7kTxb4TWpmKO7mzbuSx7M4KWSz5YerCI+wit4i4ZNKkSqVj6CNH0rQhVw6vz0RQYDdxRw2EbdK9eCEGWL5tRYa5LlXfuT4TSXPts/TRtgcK+9sDVq2cksWcYZb8xNxwkMKkiL6bitpY6MUlDW7jU4tt/VcP/x3pRuDN+ho8QXqR7UOjCoVTdH+YBZYBAEf9WAfUH3pmlnKZM+dYliK9uZCctSoCsF8HMTn//zf/8Fh2IzqL/pRgQQGyW46p8fyrVjm176aUDr/e/QYw==
        EOT -> null
      - public_key_pem                = <<-EOT
            -----BEGIN PUBLIC KEY-----
            MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA7K2xyTNo3QafrGCnXfRd
            GMdX/Gambxgpw7Q1Cxdsc6CGlblJK3ChPgWD1/ZlmUzaho4wX0msGfh+F1PO+QBi
            NTjWY07Muwy/cSqwU456QG/R7cQvrPci2hw+loNM4ZlU+3byxKMj9ldMgJ59jgai
            2fq3J/q+pxemr/57xoCOKSBM9JOp3/D98WthRu4usJxwDqj4WlPrcC2Qq/BrX1xh
            1iF0jnscZVfj0y4ELPHqtYty0tHhKhok6JmvdEbNyyDXnF1fe4tbFRcnlnPR7CN5
            PXDozpB3EEvXZRIwdNVuIW1nspwNPIz/FYokJ8hP1aJvGft+Zi459LF0psY6DvG0
            L6xRLqi4Z7CJBCMP2SvtyfxkzIiVfGk30JjwTo+AaZAORNMdKf+8pv89NYB9mvAm
            dXzRu55aO5E8W+E1qZiju5s27ksezOClks+WHqwiPsIreIuGTSpEqlY+gjR9K0IV
            cOr89EUGA3cUcNhG3SvXghBli+bUWGuS5V37k+E0lz7bP00bYHCvvbA1atnJLFnG
            GW/MTccJDCpIi+m4raWOjFJQ1u41OLbf1XD/8d6UbgzfoaPEF6ke1DowqFU3R/mA
            WWAQBH/VgH1B96ZpZymTPnWJYivbmQnLUqArBfBzE5//83//BYdiM6i/6UYEEBsl
            uOqfH8q1Y5te+mlA6/3v0GMCAwEAAQ==
            -----END PUBLIC KEY-----
        EOT -> null
      - rsa_bits                      = 4096 -> null
    }

Plan: 0 to add, 0 to change, 15 to destroy.

Changes to Outputs:
  - ami_id                = "ami-0ac62d2d72afdce51" -> null
  - api_security_group_id = "sg-0919ef3be038cb5c2" -> null
  - api_url               = "http://13.220.53.134:3000" -> null
  - db_security_group_id  = "sg-09ce89c013df82a8a" -> null
  - ec2_public_ip         = "13.220.53.134" -> null
  - instance_id           = "i-00ca3244a3cba00d7" -> null
  - private_subnet_ids    = [
      - "subnet-05f29338aef9b157c",
      - "subnet-0d417bbd1c7730525",
    ] -> null
  - public_subnet_ids     = [
      - "subnet-0ad220c50e34a51b8",
      - "subnet-05f3fd55e98607f26",
    ] -> null
  - ssh_command           = "ssh -i ~/.ssh/technova-key.pem ec2-user@13.220.53.134" -> null
  - vpc_id                = "vpc-0024c5f6d6e1ef0bb" -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

local_sensitive_file.private_key: Destroying... [id=fd3d63720a5c8d6a00017455e694831e393e8c0a]
local_sensitive_file.private_key: Destruction complete after 0s
aws_route_table_association.public[0]: Destroying... [id=rtbassoc-0061886c1bd5c6332]
aws_route_table_association.public[1]: Destroying... [id=rtbassoc-0e6c577d1afee08bd]
aws_subnet.private[0]: Destroying... [id=subnet-05f29338aef9b157c]
aws_subnet.private[1]: Destroying... [id=subnet-0d417bbd1c7730525]
aws_security_group.db: Destroying... [id=sg-09ce89c013df82a8a]
aws_instance.api: Destroying... [id=i-00ca3244a3cba00d7]
aws_route_table_association.public[0]: Destruction complete after 1s
aws_route_table_association.public[1]: Destruction complete after 1s
aws_route_table.public: Destroying... [id=rtb-0a02d88f9f590046c]
aws_subnet.private[0]: Destruction complete after 2s
aws_subnet.private[1]: Destruction complete after 2s
aws_security_group.db: Destruction complete after 2s
aws_route_table.public: Destruction complete after 1s
aws_internet_gateway.main: Destroying... [id=igw-0ee83b2a184a51c39]
aws_instance.api: Still destroying... [id=i-00ca3244a3cba00d7, 00m10s elapsed]
aws_internet_gateway.main: Still destroying... [id=igw-0ee83b2a184a51c39, 00m10s elapsed]
aws_instance.api: Still destroying... [id=i-00ca3244a3cba00d7, 00m20s elapsed]
aws_internet_gateway.main: Still destroying... [id=igw-0ee83b2a184a51c39, 00m20s elapsed]
aws_instance.api: Still destroying... [id=i-00ca3244a3cba00d7, 00m33s elapsed]
aws_internet_gateway.main: Destruction complete after 32s
aws_instance.api: Destruction complete after 35s
aws_key_pair.technova: Destroying... [id=technova-key]
aws_subnet.public[0]: Destroying... [id=subnet-0ad220c50e34a51b8]
aws_subnet.public[1]: Destroying... [id=subnet-05f3fd55e98607f26]
aws_security_group.api: Destroying... [id=sg-0919ef3be038cb5c2]
aws_key_pair.technova: Destruction complete after 1s
tls_private_key.technova: Destroying... [id=9c2a05884f63141e95e6b126ad910398d6e200e2]
tls_private_key.technova: Destruction complete after 0s
aws_subnet.public[0]: Destruction complete after 1s
aws_subnet.public[1]: Destruction complete after 1s
aws_security_group.api: Destruction complete after 2s
aws_vpc.main: Destroying... [id=vpc-0024c5f6d6e1ef0bb]
aws_vpc.main: Destruction complete after 0s

Destroy complete! Resources: 15 destroyed.
