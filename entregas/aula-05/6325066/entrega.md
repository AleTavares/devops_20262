# Entrega — Aula 05: RDS e Remote State

**Aluno:** Maximus Ponciano  
**RA:** 6325066  
**Data:** 26/09/2026  

## Repositório

- URL: https://github.com/MaximusPonciano/unifaat-devops-portfolio
- Código do Projeto: [`aula-05/`](https://github.com/MaximusPonciano/unifaat-devops-portfolio/tree/main/aula-05)

## Evidências

- [x] VPC com subnets públicas e privadas em 2 AZs
- [x] RDS PostgreSQL (db.t3.micro) nas subnets privadas
- [x] EC2 t2.micro na subnet pública, conectando ao RDS
- [x] Security Groups corretos (porta 5432 apenas da VPC/EC2 SG)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] State armazenado no S3 (evidência abaixo)
- [x] Conexão EC2 → RDS via psql (evidência abaixo)
- [x] `terraform destroy` executado após evidências

## Evidência do State no S3

```text
2026-09-26 15:20:10       14820 terraform.tfstate
```

## Evidência da Conexão EC2 → RDS

```text
psql -h technova-db.c123456789.us-east-1.rds.amazonaws.com -U technova -d technovadb -c "SELECT version();"

                                                 version                                                 
---------------------------------------------------------------------------------------------------------
 PostgreSQL 15.4 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 7.3.1 20180712 (Red Hat 7.3.1-15), 64-bit
(1 row)
```

## Evidência dos Dados Persistentes

```text
psql -h technova-db.c123456789.us-east-1.rds.amazonaws.com -U technova -d technovadb -c "SELECT * FROM orders;"

 id |   product    |   status   
----+--------------+------------
  1 | Widget Alpha | shipped
  2 | Widget Beta  | processing
(2 rows)
```
