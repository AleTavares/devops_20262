# Entrega — Aula 05: RDS e Remote State

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 09/09/2026

## Repositório

- URL: https://github.com/lucaskenway/unifaat-devops-portfolio

A pasta `aula-05/` do portfólio contém o código Terraform organizado por responsabilidade em `aula-05-backend/` e `aula-05-rds/`, além de uma cópia consolidada (`main.tf`, `providers.tf`, `variables.tf`, `outputs.tf`, `.gitignore`) na raiz de `aula-05/`.

## Evidências

- [x] VPC com subnets públicas e privadas em 2 AZs
- [x] RDS PostgreSQL (db.t3.micro) nas subnets privadas
- [x] EC2 t2.micro na subnet pública, conectando ao RDS
- [x] Security Groups corretos (porta 5432 apenas da VPC)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] State armazenado no S3 (evidência abaixo)
- [x] Conexão EC2 → RDS via psql (evidência abaixo)
- [x] `terraform destroy` executado após evidências

> Detalhes completos da execução (incluindo um bloqueio de permissão real do AWS Academy Learner Lab e como foi contornado) estão em [`relatorio-execucao.md`](./relatorio-execucao.md).

## Evidência do State no S3

```
$ aws s3 ls s3://technova-terraform-state-de3dd3e7/aula-05/
2026-09-10 21:30:14      34846 terraform.tfstate

$ terraform plan
No changes. Your infrastructure matches the configuration.
```

## Evidência da Conexão EC2 → RDS

```
$ psql -h technova-db.cm3yu4zllmdf.us-east-1.rds.amazonaws.com -U technova_admin -d technova -p 5432 -c "SELECT version();"
                                              version
---------------------------------------------------------------------------------------------------
 PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC) 12.4.0, 64-bit
(1 row)

$ psql ... -f seed.sql
CREATE TABLE
INSERT 0 3
 id | customer_name |       product       | quantity |  total  |         created_at
----+---------------+---------------------+----------+---------+----------------------------
  1 | Maria Silva   | Laptop TechNova Pro |        1 | 4599.90 | 2026-09-11 00:12:21.748275
  2 | João Santos   | Monitor 27"         |        2 | 2398.00 | 2026-09-11 00:12:21.748275
  3 | Ana Costa     | Teclado Mecânico    |        3 |  897.00 | 2026-09-11 00:12:21.748275
(3 rows)
```
