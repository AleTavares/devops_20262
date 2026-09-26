# Entrega — Aula 06: Terraform Modules

**Aluno:** Maximus Ponciano  
**RA:** 6325066  
**Data:** 26/09/2026  

---

## Repositório

- **URL:** https://github.com/MaximusPonciano/unifaat-devops-portfolio/tree/main/aula-06

---

## Checklist de Validação

### Módulos Reutilizáveis (`aula-06/modules/`)
- [x] **`modules/vpc/`** — VPC modularizada com `for_each` para subnets públicas/privadas, IGW e Route Table
- [x] **`modules/security-group/`** — Security Group genérico aceitando regras de ingress via lista de objetos dinâmicos
- [x] **`modules/ec2/`** — Módulo EC2 reutilizável com suporte a AMI, subnet, SG, key_name e user_data
- [x] **`modules/rds/`** — Módulo RDS PostgreSQL com DB Subnet Group automatizado

### Ambientes e Composição (`aula-06/environments/`)
- [x] **Composição entre módulos** — Output da VPC alimenta inputs de SG, EC2 e RDS; Output de SG alimenta EC2 e RDS
- [x] **`environments/dev/`** — VPC `10.0.0.0/16`, DB `technova_dev`, `terraform validate` ✅, `terraform plan` ✅
- [x] **`environments/staging/`** — VPC `10.1.0.0/16`, DB `technova_staging`, `terraform validate` ✅, `terraform plan` ✅

### Documentação e Boas Práticas
- [x] **README.md** com visão geral, diagrama de arquitetura, tabelas de inputs/outputs e exemplos de uso
- [x] **`.gitignore`** configurado e sem arquivos `.tfstate` ou `.terraform/` commitados
- [x] **Tags padronizadas** (`Name`, `Environment`, `Project`, `ManagedBy`) em todos os recursos

---

## Evidência do `terraform plan` (Ambiente Dev)

```hcl
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.api_server.aws_instance.this will be created
  + resource "aws_instance" "this" {
      + ami                          = "ami-0c7217cdde317cfec"
      + instance_type                = "t2.micro"
      + associate_public_ip_address  = true
      + tags                         = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Name"        = "technova-dev-api-server"
          + "Project"     = "technova"
        }
    }

  # module.api_sg.aws_security_group.this will be created
  + resource "aws_security_group" "this" {
      + description = "Security group for TechNova Dev API Server"
      + name        = "technova-dev-api-sg"
    }

  # module.rds_sg.aws_security_group.this will be created
  + resource "aws_security_group" "this" {
      + description = "Security group for TechNova Dev RDS PostgreSQL"
      + name        = "technova-dev-rds-sg"
    }

  # module.database.aws_db_instance.this will be created
  + resource "aws_db_instance" "this" {
      + allocated_storage    = 20
      + db_name              = "technova_dev"
      + engine               = "postgres"
      + engine_version       = "15.7"
      + instance_class       = "db.t3.micro"
      + skip_final_snapshot  = true
    }

  # module.vpc.aws_vpc.this will be created
  + resource "aws_vpc" "this" {
      + cidr_block           = "10.0.0.0/16"
      + enable_dns_hostnames = true
      + enable_dns_support   = true
      + tags                 = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Name"        = "technova-dev-vpc"
          + "Project"     = "technova"
        }
    }

Plan: 14 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + api_server_instance_id = (known after apply)
  + api_server_public_ip   = (known after apply)
  + api_sg_id              = (known after apply)
  + database_endpoint      = (known after apply)
  + database_name          = "technova_dev"
  + private_subnet_ids     = [
      + (known after apply),
      + (known after apply),
    ]
  + public_subnet_ids      = [
      + (known after apply),
      + (known after apply),
    ]
  + rds_sg_id              = (known after apply)
  + vpc_id                 = (known after apply)
```

---

## Evidência do `terraform plan` (Ambiente Staging)

```hcl
Terraform will perform the following actions:

  # module.api_server.aws_instance.this will be created
  + resource "aws_instance" "this" {
      + ami                          = "ami-0c7217cdde317cfec"
      + instance_type                = "t2.micro"
      + tags                         = {
          + "Environment" = "staging"
          + "Name"        = "technova-staging-api-server"
        }
    }

  # module.database.aws_db_instance.this will be created
  + resource "aws_db_instance" "this" {
      + db_name              = "technova_staging"
      + engine               = "postgres"
      + instance_class       = "db.t3.micro"
    }

  # module.vpc.aws_vpc.this will be created
  + resource "aws_vpc" "this" {
      + cidr_block           = "10.1.0.0/16"
      + tags                 = {
          + "Environment" = "staging"
          + "Name"        = "technova-staging-vpc"
        }
    }

Plan: 14 to add, 0 to change, 0 to destroy.
```
