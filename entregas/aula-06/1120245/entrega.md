# Entrega — Aula 06: Terraform Modules

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 08/09/2026

## Repositório

- Projeto: [unifaat-devops-portfolio](https://github.com/Manntto/unifaat-devops-portfolio)
- Código da Aula 06: [aula-06 no branch main](https://github.com/Manntto/unifaat-devops-portfolio/tree/main/aula-06)

## Arquivos entregues

| Arquivo | Descrição |
|---------|-----------|
| [`modules/vpc/main.tf`](https://github.com/Manntto/unifaat-devops-portfolio/tree/main/aula-06/modules/vpc) | Módulo VPC: VPC + subnets públicas/privadas + IGW + Route Table |
| [`modules/security-group/main.tf`](https://github.com/Manntto/unifaat-devops-portfolio/tree/main/aula-06/modules/security-group) | Módulo Security Group genérico com regras dinâmicas |
| [`modules/ec2/main.tf`](https://github.com/Manntto/unifaat-devops-portfolio/tree/main/aula-06/modules/ec2) | Módulo EC2 reutilizável com AMI, subnet, SG e user_data |
| [`modules/rds/main.tf`](https://github.com/Manntto/unifaat-devops-portfolio/tree/main/aula-06/modules/rds) | Módulo RDS PostgreSQL com DB Subnet Group automatizado |
| [`environments/dev/main.tf`](https://github.com/Manntto/unifaat-devops-portfolio/tree/main/aula-06/environments/dev) | Composição dev: VPC 10.0.0.0/16 |
| [`environments/staging/main.tf`](https://github.com/Manntto/unifaat-devops-portfolio/tree/main/aula-06/environments/staging) | Composição staging: VPC 10.1.0.0/16 |

## Checklist de Requisitos

- [x] Módulo `vpc` com subnets públicas e privadas, IGW e Route Table
- [x] Módulo `security-group` genérico com regras de ingress dinâmicas
- [x] Módulo `ec2` reutilizável com suporte a AMI, subnet, SG e user_data
- [x] Módulo `rds` com DB Subnet Group automatizado
- [x] Composição entre módulos: output da VPC alimenta inputs de SG, EC2 e RDS
- [x] Ambiente `dev` com VPC 10.0.0.0/16
- [x] Ambiente `staging` com VPC 10.1.0.0/16
- [x] `terraform validate` passando em ambos os ambientes
- [x] `terraform plan` passando em ambos os ambientes

## Evidência — terraform plan (Ambiente Dev)

```
Plan: 14 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + api_server_public_ip = (known after apply)
  + database_endpoint    = (known after apply)
  + vpc_id               = (known after apply)
```

## Evidência — terraform plan (Ambiente Staging)

```
Plan: 14 to add, 0 to change, 0 to destroy.
```
