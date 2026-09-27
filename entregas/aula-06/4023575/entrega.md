# Entrega — Aula 06: Terraform Modules

**Aluno:** Emilly Santos de Oliveira  
**RA:** 4023575  
**Data:** 26/09/2026

## Repositório

- URL: https://github.com/leonidas-alt/unifaat-devops-portfolio.git

## Evidências

- [x] Módulo VPC com for_each para subnets dinâmicas
- [x] Módulo Security Group genérico (regras como lista de objetos)
- [x] Módulo EC2 reutilizável
- [x] Módulo RDS reutilizável
- [x] Composição entre módulos (output de um alimenta input de outro)
- [x] Dois ambientes (dev + staging) usando os mesmos módulos
- [x] `terraform validate` e `terraform plan` sem erros nos dois ambientes
- [x] README documentando cada módulo (inputs, outputs, exemplo)

## Evidência do terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.vpc.aws_vpc.main will be created
  + resource "aws_vpc" "main" {
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
      + tags                                 = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Name"        = "technova-dev-vpc"
          + "Project"     = "technova"
        }
      + tags_all                             = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Name"        = "technova-dev-vpc"
          + "Project"     = "technova"
        }
    }

Plan: 19 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + api_instance_id    = (known after apply)
  + api_public_ip      = (known after apply)
  + api_sg_id          = (known after apply)
  + db_endpoint        = (known after apply)
  + db_name            = "technova_dev"
  + private_subnet_ids = [
      + (known after apply),
      + (known after apply),
    ]
  + public_subnet_ids  = [
      + (known after apply),
      + (known after apply),
    ]
  + rds_sg_id          = (known after apply)
  + vpc_id             = (known after apply)

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.