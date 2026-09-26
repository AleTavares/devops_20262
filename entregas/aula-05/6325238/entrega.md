# Entrega — Aula 05: RDS e Remote State

**Aluno:** [Yuri Sanches]  
**RA:** [6325238]  
**Data:** [24/09/26]

## Repositório

- URL: https://github.com/Dooooc/unifaat-devops-portfolio

## Evidências

- [X] VPC com subnets públicas e privadas em 2 AZs
- [X] RDS PostgreSQL (db.t3.micro) nas subnets privadas
- [X] EC2 t2.micro na subnet pública, conectando ao RDS
- [X] Security Groups corretos (porta 5432 apenas da VPC)
- [X] Remote State configurado (S3 + DynamoDB)
- [X] State armazenado no S3 (evidência abaixo)
- [X] Conexão EC2 → RDS via psql (evidência abaixo)
- [X] `terraform destroy` executado após evidências

## Evidência do State no S3

[2026-09-24 11:06:06      76353 aula-05/terraform.tfstate]

## Evidência da Conexão EC2 → RDS

[aws s3 ls s3://technova-tfstate-6325238/aula-05/ --recursive
2026-09-24 11:06:06      76353 aula-05/terraform.tfstate

 PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC) 12.
4.0, 64-bit
(1 row)

 id | customer  |  product  | amount 
----+-----------+-----------+--------
  1 | Cliente 1 | Produto A | 150.00
  2 | Cliente 2 | Produto B | 250.00
  3 | Cliente 3 | Produto C |  99.90
(3 rows)

No changes. Your infrastructure matches the configuration.

]