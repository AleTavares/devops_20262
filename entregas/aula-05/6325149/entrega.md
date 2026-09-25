# Entrega — Aula 05: RDS e Remote State

**Aluno:** Gabriel Reis Cunha  
**RA:** 6325149  
**Data:** 24/09/2026

## Repositório

- URL: https://github.com/gabrielreis354/unifaat-devops-portfolio

## Evidências

- [x] VPC com subnets públicas e privadas em 2 AZs
- [x] RDS PostgreSQL (db.t3.micro) nas subnets privadas
- [x] EC2 t2.micro na subnet pública, conectando ao RDS
- [x] Security Groups corretos (porta 5432 apenas da VPC)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] State armazenado no S3 (evidência abaixo)
- [x] Conexão EC2 → RDS via psql (evidência abaixo)
- [x] `terraform destroy` executado após evidências

## Evidência do State no S3

```
$ aws s3 ls s3://technova-terraform-state-54600b3e83155696/aula-05/ --recursive
2026-09-10 22:26:35      34843 aula-05/terraform.tfstate

$ terraform plan
No changes. Your infrastructure matches the configuration.
```

## Evidência da Conexão EC2 → RDS

```
$ psql -h technova-db.cxhwj2zlyovj.us-east-1.rds.amazonaws.com -U technova_admin -d technova -c "SELECT version();"
                                              version
---------------------------------------------------------------------------------------------------
 PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC) 12.4.0, 64-bit
(1 row)

$ psql -h technova-db.cxhwj2zlyovj.us-east-1.rds.amazonaws.com -U technova_admin -d technova -c "SELECT * FROM orders;"
 id | customer_name |       product       | quantity |  total  |         created_at
----+---------------+---------------------+----------+---------+----------------------------
  1 | Maria Silva   | Laptop TechNova Pro |        1 | 4599.90 | 2026-09-11 01:28:18.231431
  2 | Joao Santos   | Monitor 27"         |        2 | 2398.00 | 2026-09-11 01:28:18.231431
  3 | Ana Costa     | Teclado Mecanico    |        3 |  897.00 | 2026-09-11 01:28:18.231431
(3 rows)
```
