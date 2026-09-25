# Entrega — Aula 06: Terraform Modules

**Aluno:** Matheus Mantovani  
**RA:** 20262  
**Data:** 18/09/2026

## Repositório

- Projeto: [unifaat-devops-portfolio](https://github.com/Manntto/unifaat-devops-portfolio)
- Código da Aula 06: [aula-06 no branch main](https://github.com/Manntto/unifaat-devops-portfolio/tree/main/aula-06)

## Evidências

- [x] Módulo VPC com `for_each` para subnets dinâmicas
- [x] Módulo Security Group genérico (regras como lista de objetos)
- [x] Módulo EC2 reutilizável
- [x] Módulo RDS reutilizável (DB Subnet Group + PostgreSQL 15)
- [x] Composição entre módulos: `module.vpc.vpc_id` → SGs; `module.vpc.public_subnet_ids` → EC2; `module.vpc.private_subnet_ids` + SG → RDS
- [x] Dois ambientes dev (`10.0.0.0/16`) + staging (`10.1.0.0/16`) usando os mesmos módulos
- [x] [README documentando cada módulo](https://github.com/Manntto/unifaat-devops-portfolio/blob/main/aula-06/README.md)

## Composição de Módulos

```
modules/vpc
  └─ vpc_id              ──► modules/security-group (api_sg e rds_sg)
  └─ public_subnet_ids   ──► modules/ec2 (subnet_id)
  └─ private_subnet_ids  ──► modules/rds (subnet_ids)

modules/security-group (api_sg)
  └─ sg_id ──► modules/ec2 (security_group_ids)
  └─ sg_id ──► modules/security-group rds_sg (source_sg_id na regra 5432)

modules/security-group (rds_sg)
  └─ sg_id ──► modules/rds (security_group_ids)
```
