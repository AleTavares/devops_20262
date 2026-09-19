# Entrega - Aula 06: Terraform Modules

**Aluno:** Carina Goncalves dos Santos Dalpino
**RA:** 6325109
**Data:** 19/09/2026

## Repositorio

- URL: https://github.com/CarinaDalpino/unifaat-devops-portfolio
- Pasta do projeto: `aula-06/`

## Evidencias

- [x] Modulo VPC com for_each para subnets dinamicas
- [x] Modulo Security Group generico (regras como lista de objetos)
- [x] Modulo EC2 reutilizavel
- [x] Modulo RDS reutilizavel
- [x] Composicao entre modulos (output de um alimenta input de outro)
- [x] Dois ambientes (dev + staging) usando os mesmos modulos
- [x] `terraform validate` e `terraform plan` sem erros nos dois ambientes
- [x] README documentando cada modulo (inputs, outputs, exemplo)

## Estrutura entregue

```
aula-06/
├── README.md
├── environments/
│   ├── dev/       (main.tf, variables.tf, outputs.tf, providers.tf, terraform.tfvars)
│   └── staging/   (main.tf, variables.tf, outputs.tf, providers.tf, terraform.tfvars)
└── modules/
    ├── vpc/               (VPC + subnets com for_each + IGW + route table)
    ├── security-group/    (SG generico com regras dinamicas)
    ├── ec2/               (instancia EC2 reutilizavel)
    └── rds/               (RDS PostgreSQL + DB Subnet Group)
```

## Composicao implementada

- `module.vpc.vpc_id` -> Security Groups (API e RDS)
- `module.vpc.public_subnet_ids[0]` -> modulo EC2
- `module.vpc.private_subnet_ids` -> modulo RDS
- `module.api_sg.sg_id` -> modulo EC2
- `module.rds_sg.sg_id` -> modulo RDS

## Dois ambientes com os mesmos modulos

| Aspecto | Dev | Staging |
|---------|-----|---------|
| VPC CIDR | 10.0.0.0/16 | 10.1.0.0/16 |
| Subnets Publicas | 10.0.1.0/24, 10.0.2.0/24 | 10.1.1.0/24, 10.1.2.0/24 |
| Subnets Privadas | 10.0.3.0/24, 10.0.4.0/24 | 10.1.3.0/24, 10.1.4.0/24 |
| DB Name | technova_dev | technova_staging |
| Naming | technova-dev-* | technova-staging-* |

## Evidencia do terraform validate

```
# environments/dev
Success! The configuration is valid.

# environments/staging
Success! The configuration is valid.
```

## Evidencia do terraform plan - DEV

Executado na conta AWS Academy Learner Lab (775148702826):

```
  # module.api_server.aws_instance.this will be created
  # module.api_sg.aws_security_group.this will be created
  # module.api_sg.aws_security_group_rule.egress[0] will be created
  # module.api_sg.aws_security_group_rule.ingress[0] will be created
  # module.api_sg.aws_security_group_rule.ingress[1] will be created
  # module.database.aws_db_instance.this will be created
  # module.database.aws_db_subnet_group.this will be created
  # module.rds_sg.aws_security_group.this will be created
  # module.rds_sg.aws_security_group_rule.egress[0] will be created
  # module.rds_sg.aws_security_group_rule.ingress[0] will be created
  # module.vpc.aws_internet_gateway.main will be created
  # module.vpc.aws_route_table.public will be created
  # module.vpc.aws_route_table_association.public["public-1"] will be created
  # module.vpc.aws_route_table_association.public["public-2"] will be created
  # module.vpc.aws_subnet.this["private-1"] will be created
  # module.vpc.aws_subnet.this["private-2"] will be created
  # module.vpc.aws_subnet.this["public-1"] will be created
  # module.vpc.aws_subnet.this["public-2"] will be created
  # module.vpc.aws_vpc.main will be created

Plan: 19 to add, 0 to change, 0 to destroy.
```

## Evidencia do terraform plan - STAGING

Mesmos modulos, CIDR 10.1.0.0/16, nomes technova-staging-*:

```
Plan: 19 to add, 0 to change, 0 to destroy.
```

As subnets do staging usam CIDRs 10.1.1.0/24, 10.1.2.0/24, 10.1.3.0/24, 10.1.4.0/24 - provando que os mesmos modulos geram ambientes distintos apenas variando as variaveis.

> Observacao: Foi executado apenas `terraform plan` (nao `apply`), conforme permitido pelo TF ("nao e obrigatorio executar terraform apply"). Nenhum recurso foi criado na AWS, portanto nao ha custo nem necessidade de destroy.