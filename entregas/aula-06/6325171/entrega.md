# Entrega — Aula 06: Terraform Modules

**Aluno:** Nicolas de Jesus Silva  
**RA:** 6325171  
**Data:** 26/09/2026

## Repositório

- URL: https://github.com/NxcolasDev/unifaat-devops-portfolio
- Pasta do projeto: `aula-06/`
- Branch de desenvolvimento: `feature/aula-06-modules`

## Evidências

- [x] Módulo VPC com `for_each` para subnets dinâmicas (`modules/vpc/`)
- [x] Módulo Security Group genérico com regras dinâmicas (`modules/security-group/`)
- [x] Módulo EC2 reutilizável (`modules/ec2/`)
- [x] Módulo RDS PostgreSQL reutilizável (`modules/rds/`)
- [x] Composição entre módulos (output da VPC → input do SG/EC2/RDS; output do SG → input do EC2/RDS)
- [x] Dois ambientes isolados (`environments/dev` e `environments/staging`) reutilizando a mesma biblioteca de módulos
- [x] `terraform validate` executado com sucesso nos dois ambientes
- [x] `terraform plan` gerado com sucesso nos dois ambientes (14 recursos para criar em cada)
- [x] README.md documentando a biblioteca de módulos, inputs, outputs e arquitetura
- [x] `trabalho-em-aula.md` preenchido com o code review e diagrama de dependências

## Output do `terraform plan` (Ambiente Dev)

```text
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.api_server.aws_instance.main will be created
  # module.api_sg.aws_security_group.main will be created
  # module.database.aws_db_instance.main will be created
  # module.database.aws_db_subnet_group.main will be created
  # module.rds_sg.aws_security_group.main will be created
  # module.vpc.aws_internet_gateway.main will be created
  # module.vpc.aws_route_table.public will be created
  # module.vpc.aws_route_table_association.public["public-1"] will be created
  # module.vpc.aws_route_table_association.public["public-2"] will be created
  # module.vpc.aws_subnet.subnets["private-1"] will be created
  # module.vpc.aws_subnet.subnets["private-2"] will be created
  # module.vpc.aws_subnet.subnets["public-1"] will be created
  # module.vpc.aws_subnet.subnets["public-2"] will be created
  # module.vpc.aws_vpc.main will be created

Plan: 14 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + api_public_ip = (known after apply)
  + db_endpoint   = (known after apply)
  + vpc_id        = (known after apply)


## Output do `terraform plan` (Ambiente Staging)

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.api_server.aws_instance.main will be created
  # module.api_sg.aws_security_group.main will be created
  # module.database.aws_db_instance.main will be created
  # module.database.aws_db_subnet_group.main will be created
  # module.rds_sg.aws_security_group.main will be created
  # module.vpc.aws_internet_gateway.main will be created
  # module.vpc.aws_route_table.public will be created
  # module.vpc.aws_route_table_association.public["public-1"] will be created
  # module.vpc.aws_route_table_association.public["public-2"] will be created
  # module.vpc.aws_subnet.subnets["private-1"] will be created
  # module.vpc.aws_subnet.subnets["private-2"] will be created
  # module.vpc.aws_subnet.subnets["public-1"] will be created
  # module.vpc.aws_subnet.subnets["public-2"] will be created
  # module.vpc.aws_vpc.main will be created

Plan: 14 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + api_public_ip = (known after apply)
  + db_endpoint   = (known after apply)
  + vpc_id        = (known after apply)