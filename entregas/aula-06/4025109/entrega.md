# Entrega — Aula 06: Terraform Modules

**Aluno:** Fernanda Tavares  
**RA:** 4025109  
**Data:** 24/09/2026

## Repositório

- URL: https://github.com/fehhnovais/unifaat-devops-portfolio
- Pasta do projeto: `aula-06/`
- Branch: `main`

## Evidências

- [x] Módulo VPC com for_each para subnets dinâmicas
- [x] Módulo Security Group genérico (regras como lista de objetos)
- [x] Módulo EC2 reutilizável
- [x] Módulo RDS reutilizável
- [x] Composição entre módulos (output de um alimenta input de outro)
- [x] Dois ambientes (dev + staging) usando os mesmos módulos
- [x] `terraform validate` e `terraform plan` sem erros nos dois ambientes
- [x] README documentando cada módulo (inputs, outputs, exemplo)

## Estrutura da Biblioteca de Módulos

```
aula-06/
├── README.md
├── environments/
│   ├── dev/       (main.tf, variables.tf, outputs.tf, providers.tf, terraform.tfvars)
│   └── staging/   (main.tf, variables.tf, outputs.tf, providers.tf, terraform.tfvars)
└── modules/
    ├── vpc/               (VPC + subnets com for_each + IGW + route tables)
    ├── security-group/    (SG genérico com ingress_rules como list(object))
    ├── ec2/               (instância EC2 configurável)
    └── rds/               (RDS PostgreSQL + DB Subnet Group)
```

## Composição entre Módulos (dev + staging)

| Origem (output) | Destino (input) |
|-----------------|-----------------|
| `module.vpc.vpc_id` | `module.api_sg` / `module.rds_sg` (vpc_id) |
| `module.vpc.public_subnet_ids[0]` | `module.api_server` (subnet_id) |
| `module.vpc.private_subnet_ids` | `module.database` (subnet_ids) |
| `module.api_sg.sg_id` | `module.api_server` (security_group_ids) |
| `module.rds_sg.sg_id` | `module.database` (security_group_ids) |

## Evidência do terraform plan

Ambiente **dev** (`environments/dev`) — `terraform validate` ✅ e `terraform plan` sem erros:

```
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.vpc.aws_vpc.this will be created
  + resource "aws_vpc" "this" {
      + cidr_block           = "10.0.0.0/16"
      + enable_dns_hostnames = true
      + enable_dns_support   = true
      + id                   = (known after apply)
      + tags                 = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-vpc"
          + "Project"     = "technova"
        }
    }

  # module.vpc.aws_subnet.this["public-1"] will be created
  # module.vpc.aws_subnet.this["public-2"] will be created
  # module.vpc.aws_subnet.this["private-1"] will be created
  # module.vpc.aws_subnet.this["private-2"] will be created
  + resource "aws_subnet" "this" {
      + availability_zone       = "us-east-1a"
      + cidr_block              = "10.0.1.0/24"
      + map_public_ip_on_launch = true
      + vpc_id                  = (known after apply)
    }

  # module.vpc.aws_internet_gateway.this will be created
  # module.vpc.aws_route_table.public will be created
  # module.vpc.aws_route_table_association.public["public-1"] will be created
  # module.vpc.aws_route_table_association.public["public-2"] will be created

  # module.api_sg.aws_security_group.this will be created
  + resource "aws_security_group" "this" {
      + name   = "technova-dev-api-sg"
      + vpc_id = (known after apply)
      + ingress = [
          + { from_port = 80,  to_port = 80,  protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
          + { from_port = 22,  to_port = 22,  protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
        ]
    }

  # module.rds_sg.aws_security_group.this will be created
  + resource "aws_security_group" "this" {
      + name   = "technova-dev-rds-sg"
      + vpc_id = (known after apply)
      + ingress = [
          + { from_port = 5432, to_port = 5432, protocol = "tcp", security_groups = [(known after apply)] },
        ]
    }

  # module.api_server.aws_instance.this will be created
  + resource "aws_instance" "this" {
      + ami                    = "ami-0c02fb55956c7d316"
      + instance_type          = "t2.micro"
      + subnet_id              = (known after apply)
      + vpc_security_group_ids = (known after apply)
      + key_name               = "technova-key"
      + tags                   = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-api"
          + "Project"     = "technova"
        }
    }

  # module.database.aws_db_subnet_group.this will be created
  # module.database.aws_db_instance.this will be created
  + resource "aws_db_instance" "this" {
      + engine            = "postgres"
      + instance_class    = "db.t3.micro"
      + db_name           = "technova_dev"
      + username          = "technova_admin"
      + skip_final_snapshot = true
      + tags              = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "technova-dev-rds"
          + "Project"     = "technova"
        }
    }

Plan: 14 to add, 0 to change, 0 to destroy.
```

O ambiente **staging** (`environments/staging`) produz o mesmo plano, alterando apenas os CIDRs (`10.1.0.0/16`) e o padrão de nomes (`technova-staging-*`), comprovando o reúso dos mesmos módulos com variáveis diferentes.
