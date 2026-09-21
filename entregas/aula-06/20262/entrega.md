# Entrega — Aula 06: Terraform Modules

**Aluno:** Matheus Mantovani  
**RA:** 20262  
**Data:** 18/09/2026

## Repositório

- Projeto: [unifaat-devops-portfolio](https://github.com/matheus-mantovani/unifaat-devops-portfolio)
- Código da Aula 06: [aula-06 no branch main](https://github.com/matheus-mantovani/unifaat-devops-portfolio/tree/main/aula-06)

## Evidências

- [x] Módulo VPC com `for_each` para subnets dinâmicas (mapa de objetos `{cidr, az, type}`)
- [x] Módulo Security Group genérico (regras como lista de objetos, suporta `cidr_blocks` e `source_sg_id`)
- [x] Módulo EC2 reutilizável (AMI, subnet, SGs e user_data configuráveis)
- [x] Módulo RDS reutilizável (DB Subnet Group + PostgreSQL 15, db.t3.micro)
- [x] Composição entre módulos: `module.vpc.vpc_id` → SGs; `module.vpc.public_subnet_ids` → EC2; `module.vpc.private_subnet_ids` + `module.rds_sg.sg_id` → RDS
- [x] Dois ambientes (dev `10.0.0.0/16` + staging `10.1.0.0/16`) usando os mesmos módulos
- [x] `terraform validate` e `terraform plan` sem erros nos dois ambientes
- [x] README documentando cada módulo (inputs, outputs, exemplo de uso)

## Evidência do terraform plan

```
# Ambiente dev — terraform plan
module.vpc.aws_vpc.main: Plan to create
module.vpc.aws_internet_gateway.main: Plan to create
module.vpc.aws_subnet.this["public-1"]: Plan to create
module.vpc.aws_subnet.this["public-2"]: Plan to create
module.vpc.aws_subnet.this["private-1"]: Plan to create
module.vpc.aws_subnet.this["private-2"]: Plan to create
module.vpc.aws_route_table.public: Plan to create
module.vpc.aws_route_table_association.public["public-1"]: Plan to create
module.vpc.aws_route_table_association.public["public-2"]: Plan to create
module.api_sg.aws_security_group.this: Plan to create
module.api_sg.aws_security_group_rule.ingress["SSH-22"]: Plan to create
module.api_sg.aws_security_group_rule.ingress["API-NodeJS-3000"]: Plan to create
module.api_sg.aws_security_group_rule.egress_all: Plan to create
module.rds_sg.aws_security_group.this: Plan to create
module.rds_sg.aws_security_group_rule.ingress["PostgreSQL-from-API-5432"]: Plan to create
module.rds_sg.aws_security_group_rule.egress_all: Plan to create
module.api_server.aws_instance.this: Plan to create
module.database.aws_db_subnet_group.this: Plan to create
module.database.aws_db_instance.this: Plan to create
aws_key_pair.dev: Plan to create

Plan: 20 to add, 0 to change, 0 to destroy.
```

## Composição de Módulos — Fluxo de Dependências

```
modules/vpc
  └─ vpc_id          ──► modules/security-group (api_sg)
  └─ vpc_id          ──► modules/security-group (rds_sg)
  └─ public_subnet_ids[0] ──► modules/ec2 (subnet_id)
  └─ private_subnet_ids   ──► modules/rds  (subnet_ids)

modules/security-group (api_sg)
  └─ sg_id ──► modules/ec2 (security_group_ids)
  └─ sg_id ──► modules/security-group rds_sg (source_sg_id na regra 5432)

modules/security-group (rds_sg)
  └─ sg_id ──► modules/rds (security_group_ids)
```
