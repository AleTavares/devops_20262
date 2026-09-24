# Entrega — Aula 06: Terraform Modules

**Aluno:** Sirlande Martins
**RA:** 6325269
**Data:** 24/09/2026

## Repositório

- URL: https://github.com/Sir-Jr/unifaat-devops-portfolio

## Evidências

- [x] Módulo VPC com for_each para subnets dinâmicas (mapa `subnets` com cidr, az e type, validação de `type`)
- [x] Módulo Security Group genérico (regras como lista de objetos; origem por `cidr_blocks` ou por `source_security_group_id`)
- [x] Módulo EC2 reutilizável (AMI, tipo, subnet, SGs, key pair e user_data opcional configuráveis)
- [x] Módulo RDS reutilizável (DB Subnet Group + PostgreSQL 15 db.t3.micro, `db_password` sensitive)
- [x] Composição entre módulos (VPC → SGs, EC2 e RDS; SG da API → EC2 e regra 5432 do SG do RDS; SG do RDS → RDS)
- [x] Dois ambientes (dev + staging) usando os mesmos módulos, com `main.tf` idêntico e só o `terraform.tfvars` diferente
- [x] `terraform validate` e `terraform plan` sem erros nos dois ambientes
- [x] README documentando cada módulo (inputs, outputs, exemplo)

## Evidência do terraform plan

Resumo do `terraform plan` do ambiente **dev** (o staging gera os mesmos 19 recursos com
`technova-staging-*` e `10.1.0.0/16`):

```
$ cd aula-06/environments/dev
$ terraform validate
Success! The configuration is valid.

$ terraform plan
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

A saída completa dos dois ambientes está versionada em
[`terraform-plan-dev.txt`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-06/terraform-plan-dev.txt)
e
[`terraform-plan-staging.txt`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-06/terraform-plan-staging.txt).

Os arquivos do projeto (`modules/vpc`, `modules/security-group`, `modules/ec2`, `modules/rds`,
`environments/dev`, `environments/staging` e o `README.md` com a documentação da biblioteca) estão
em [`aula-06/`](https://github.com/Sir-Jr/unifaat-devops-portfolio/tree/main/aula-06).

**Nota sobre o ambiente:** o `plan` foi executado com credenciais do AWS Academy Learner Lab. A
key pair usada é a `vockey`, que já existe no Learner Lab, e a senha do banco é passada via
`TF_VAR_db_password` (não fica em nenhum `.tfvars` versionado). O TF não exige `apply`, então
nenhum recurso desta entrega foi criado na AWS. Os laboratórios Parte 1 e Parte 2 foram executados
no Learner Lab e destruídos ao final.
