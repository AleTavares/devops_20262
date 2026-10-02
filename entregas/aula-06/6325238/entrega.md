# Entrega — Aula 06: Terraform Modules

**Aluno:** [Yuri Sanches]  
**RA:** [6325238]  
**Data:** [24/09/26]

## Repositório

- URL: https://github.com/Dooooc/unifaat-devops-portfolio

## Evidências

- [X] Módulo VPC com for_each para subnets dinâmicas
- [X] Módulo Security Group genérico (regras como lista de objetos)
- [X] Módulo EC2 reutilizável
- [X] Módulo RDS reutilizável
- [X] Composição entre módulos (output de um alimenta input de outro)
- [X] Dois ambientes (dev + staging) usando os mesmos módulos
- [X] `terraform validate` e `terraform plan` sem erros nos dois ambientes
- [X] README documentando cada módulo (inputs, outputs, exemplo)

## Evidência do terraform plan

[ terraform plan
data.aws_ami.amazon_linux_2023: Reading...
data.aws_ami.amazon_linux_2023: Read complete after 2s [id=ami-0a2601fa32a0e773d]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # module.api_server.aws_instance.this will be created
  + resource "aws_instance" "this" {
      + ami                                  = "ami-0a2601fa32a0e773d"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + force_destroy                        = false
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = "LabInstanceProfile"
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "vockey"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_group_id                   = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + region                               = "us-east-1"
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-api"
          + "Project"     = "technova"
        }
      + tags_all                             = {
          + "Aluno"       = "Yuri Batista Sanches"
          + "Aula"        = "06"
          + "Disciplina"  = "DevOps - UniFAAT 2026-2"
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-api"
          + "Owner"       = "6325238"
          + "Project"     = "technova"
        }
      + tenancy                              = (known after apply)
      + user_data                            = <<-EOT
            #!/bin/bash
            yum update -y
            dnf install -y postgresql15
            curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
            yum install -y nodejs git
            echo "TechNova Dev setup concluido" >> /var/log/setup.log
        EOT
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = true
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + primary_network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device {
          + delete_on_termination = true
          + device_name           = (known after apply)
          + encrypted             = true
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags                  = {
              + "Environment" = "dev"
              + "ManagedBy"   = "Terraform"
              + "Name"        = "technova-dev-api-root-volume"
              + "Project"     = "technova"
            }
          + tags_all              = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = 30
          + volume_type           = "gp3"
        }

      + secondary_network_interface (known after apply)
    }

  # module.api_sg.aws_security_group.this will be created
  + resource "aws_security_group" "this" {
      + arn                    = (known after apply)
      + description            = "SG da API TechNova Dev - SSH e porta 3000"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "Todo o trafego de saida permitido"
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "API Node.js porta 3000"
              + from_port        = 3000
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 3000
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "SSH administrativo"
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
      + name                   = "technova-dev-sg-api"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "us-east-1"
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-sg-api"
          + "Project"     = "technova"
        }
      + tags_all               = {
          + "Aluno"       = "Yuri Batista Sanches"
          + "Aula"        = "06"
          + "Disciplina"  = "DevOps - UniFAAT 2026-2"
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-sg-api"
          + "Owner"       = "6325238"
          + "Project"     = "technova"
        }
      + vpc_id                 = (known after apply)
    }

  # module.database.aws_db_instance.this will be created
  + resource "aws_db_instance" "this" {
      + address                               = (known after apply)
      + allocated_storage                     = 20
      + apply_immediately                     = false
      + arn                                   = (known after apply)
      + auto_minor_version_upgrade            = true
      + availability_zone                     = (known after apply)
      + backup_retention_period               = 0
      + backup_target                         = (known after apply)
      + backup_window                         = (known after apply)
      + ca_cert_identifier                    = (known after apply)
      + character_set_name                    = (known after apply)
      + copy_tags_to_snapshot                 = false
      + database_insights_mode                = (known after apply)
      + db_name                               = "technova_dev"
      + db_subnet_group_name                  = "technova-dev-db-subnet-group"
      + dedicated_log_volume                  = false
      + delete_automated_backups              = true
      + deletion_protection                   = false
      + domain_fqdn                           = (known after apply)
      + endpoint                              = (known after apply)
      + engine                                = "postgres"
      + engine_lifecycle_support              = (known after apply)
      + engine_version                        = "15"
      + engine_version_actual                 = (known after apply)
      + hosted_zone_id                        = (known after apply)
      + id                                    = (known after apply)
      + identifier                            = "technova-dev-postgres"
      + identifier_prefix                     = (known after apply)
      + instance_class                        = "db.t3.micro"
      + iops                                  = (known after apply)
      + kms_key_id                            = (known after apply)
      + latest_restorable_time                = (known after apply)
      + license_model                         = (known after apply)
      + listener_endpoint                     = (known after apply)
      + maintenance_window                    = (known after apply)
      + master_user_secret                    = (known after apply)
      + master_user_secret_kms_key_id         = (known after apply)
      + monitoring_interval                   = 0
      + monitoring_role_arn                   = (known after apply)
      + multi_az                              = false
      + nchar_character_set_name              = (known after apply)
      + network_type                          = (known after apply)
      + option_group_name                     = (known after apply)
      + parameter_group_name                  = (known after apply)
      + password                              = (sensitive value)
      + password_wo                           = (write-only attribute)
      + performance_insights_enabled          = false
      + performance_insights_kms_key_id       = (known after apply)
      + performance_insights_retention_period = (known after apply)
      + port                                  = 5432
      + publicly_accessible                   = false
      + region                                = "us-east-1"
      + replica_mode                          = (known after apply)
      + replicas                              = (known after apply)
      + resource_id                           = (known after apply)
      + skip_final_snapshot                   = true
      + snapshot_identifier                   = (known after apply)
      + status                                = (known after apply)
      + storage_encrypted                     = true
      + storage_throughput                    = (known after apply)
      + storage_type                          = "gp2"
      + tags                                  = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-rds-postgres"
          + "Project"     = "technova"
        }
      + tags_all                              = {
          + "Aluno"       = "Yuri Batista Sanches"
          + "Aula"        = "06"
          + "Disciplina"  = "DevOps - UniFAAT 2026-2"
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-rds-postgres"
          + "Owner"       = "6325238"
          + "Project"     = "technova"
        }
      + timezone                              = (known after apply)
      + upgrade_rollout_order                 = (known after apply)
      + username                              = (sensitive value)
      + vpc_security_group_ids                = (known after apply)
    }

  # module.database.aws_db_subnet_group.this will be created
  + resource "aws_db_subnet_group" "this" {
      + arn                     = (known after apply)
      + description             = "DB Subnet Group technova-dev - subnets privadas"
      + id                      = (known after apply)
      + name                    = "technova-dev-db-subnet-group"
      + name_prefix             = (known after apply)
      + region                  = "us-east-1"
      + subnet_ids              = (known after apply)
      + supported_network_types = (known after apply)
      + tags                    = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-db-subnet-group"
          + "Project"     = "technova"
        }
      + tags_all                = {
          + "Aluno"       = "Yuri Batista Sanches"
          + "Aula"        = "06"
          + "Disciplina"  = "DevOps - UniFAAT 2026-2"
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-db-subnet-group"
          + "Owner"       = "6325238"
          + "Project"     = "technova"
        }
      + vpc_id                  = (known after apply)
    }

  # module.rds_sg.aws_security_group.this will be created
  + resource "aws_security_group" "this" {
      + arn                    = (known after apply)
      + description            = "SG do RDS TechNova Dev - PostgreSQL apenas da EC2"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "Todo o trafego de saida permitido"
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = []
              + description      = "PostgreSQL apenas da EC2"
              + from_port        = 5432
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = (known after apply)
              + self             = false
              + to_port          = 5432
            },
        ]
      + name                   = "technova-dev-sg-rds"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "us-east-1"
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-sg-rds"
          + "Project"     = "technova"
        }
      + tags_all               = {
          + "Aluno"       = "Yuri Batista Sanches"
          + "Aula"        = "06"
          + "Disciplina"  = "DevOps - UniFAAT 2026-2"
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-sg-rds"
          + "Owner"       = "6325238"
          + "Project"     = "technova"
        }
      + vpc_id                 = (known after apply)
    }

  # module.vpc.aws_internet_gateway.this will be created
  + resource "aws_internet_gateway" "this" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + region   = "us-east-1"
      + tags     = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-igw"
          + "Project"     = "technova"
        }
      + tags_all = {
          + "Aluno"       = "Yuri Batista Sanches"
          + "Aula"        = "06"
          + "Disciplina"  = "DevOps - UniFAAT 2026-2"
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-igw"
          + "Owner"       = "6325238"
          + "Project"     = "technova"
        }
      + vpc_id   = (known after apply)
    }

  # module.vpc.aws_route_table.private will be created
  + resource "aws_route_table" "private" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + region           = "us-east-1"
      + route            = (known after apply)
      + tags             = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-rtb-private"
          + "Project"     = "technova"
          + "Type"        = "private"
        }
      + tags_all         = {
          + "Aluno"       = "Yuri Batista Sanches"
          + "Aula"        = "06"
          + "Disciplina"  = "DevOps - UniFAAT 2026-2"
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-rtb-private"
          + "Owner"       = "6325238"
          + "Project"     = "technova"
          + "Type"        = "private"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table.public will be created
  + resource "aws_route_table" "public" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + region           = "us-east-1"
      + route            = [
          + {
              + cidr_block                 = "0.0.0.0/0"
              + gateway_id                 = (known after apply)
                # (12 unchanged attributes hidden)
            },
        ]
      + tags             = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-rtb-public"
          + "Project"     = "technova"
          + "Type"        = "public"
        }
      + tags_all         = {
          + "Aluno"       = "Yuri Batista Sanches"
          + "Aula"        = "06"
          + "Disciplina"  = "DevOps - UniFAAT 2026-2"
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-rtb-public"
          + "Owner"       = "6325238"
          + "Project"     = "technova"
          + "Type"        = "public"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table_association.private["private-1"] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.private["private-2"] will be created
  + resource "aws_route_table_association" "private" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.public["public-1"] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.public["public-2"] will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + region         = "us-east-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_subnet.this["private-1"] will be created
  + resource "aws_subnet" "this" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.3.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block                                = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-subnet-private-1"
          + "Project"     = "technova"
          + "Type"        = "private"
        }
      + tags_all                                       = {
          + "Aluno"       = "Yuri Batista Sanches"
          + "Aula"        = "06"
          + "Disciplina"  = "DevOps - UniFAAT 2026-2"
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-subnet-private-1"
          + "Owner"       = "6325238"
          + "Project"     = "technova"
          + "Type"        = "private"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.this["private-2"] will be created
  + resource "aws_subnet" "this" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.4.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block                                = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-subnet-private-2"
          + "Project"     = "technova"
          + "Type"        = "private"
        }
      + tags_all                                       = {
          + "Aluno"       = "Yuri Batista Sanches"
          + "Aula"        = "06"
          + "Disciplina"  = "DevOps - UniFAAT 2026-2"
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-subnet-private-2"
          + "Owner"       = "6325238"
          + "Project"     = "technova"
          + "Type"        = "private"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.this["public-1"] will be created
  + resource "aws_subnet" "this" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block                                = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-subnet-public-1"
          + "Project"     = "technova"
          + "Type"        = "public"
        }
      + tags_all                                       = {
          + "Aluno"       = "Yuri Batista Sanches"
          + "Aula"        = "06"
          + "Disciplina"  = "DevOps - UniFAAT 2026-2"
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-subnet-public-1"
          + "Owner"       = "6325238"
          + "Project"     = "technova"
          + "Type"        = "public"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.this["public-2"] will be created
  + resource "aws_subnet" "this" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.2.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block                                = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "us-east-1"
      + tags                                           = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-subnet-public-2"
          + "Project"     = "technova"
          + "Type"        = "public"
        }
      + tags_all                                       = {
          + "Aluno"       = "Yuri Batista Sanches"
          + "Aula"        = "06"
          + "Disciplina"  = "DevOps - UniFAAT 2026-2"
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-subnet-public-2"
          + "Owner"       = "6325238"
          + "Project"     = "technova"
          + "Type"        = "public"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_vpc.this will be created
  + resource "aws_vpc" "this" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + region                               = "us-east-1"
      + tags                                 = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-vpc"
          + "Project"     = "technova"
        }
      + tags_all                             = {
          + "Aluno"       = "Yuri Batista Sanches"
          + "Aula"        = "06"
          + "Disciplina"  = "DevOps - UniFAAT 2026-2"
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-vpc"
          + "Owner"       = "6325238"
          + "Project"     = "technova"
        }
    }

Plan: 17 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + api_sg_id          = (known after apply)
  + ec2_instance_id    = (known after apply)
  + ec2_public_ip      = (known after apply)
  + private_subnet_ids = [
      + (known after apply),
      + (known after apply),
    ]
  + psql_command       = (sensitive value)
  + public_subnet_ids  = [
      + (known after apply),
      + (known after apply),
    ]
  + rds_db_name        = "technova_dev"
  + rds_endpoint       = (known after apply)
  + rds_sg_id          = (known after apply)
  + ssh_command        = (known after apply)
  + vpc_id             = (known after apply)

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────]