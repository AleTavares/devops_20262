# Entrega — Aula 05: RDS e Remote State

**Aluno:** rafael nogueira maruca
**RA:** 6322006
**Data da entrega:** 14/09/2026

## Repositório

- URL: https://github.com/rafadical/unifaat-devops-portfolio

## Evidências

- [x] VPC e subnets em duas AZs verificadas na AWS.
- [x] RDS PostgreSQL db.t3.micro em subnets privadas.
- [x] EC2 t2.micro com conexão psql ao RDS.
- [x] Porta 5432 permitida somente pelo SG da EC2.
- [x] Backend S3 com versionamento, criptografia e bloqueio de acesso público.
- [x] Locking DynamoDB configurado e funcional.
- [x] State armazenado no S3.
- [x] Tabela orders criada e consultada.
- [x] Terraform plan sem alterações.
- [x] Infraestrutura principal e backend destruídos após as evidências.

## Evidência do State no S3

```
$ aws s3 ls s3://6322006-technova-tfstate-533129404111-us-east-1/aula-05/6322006/
2026-09-14 22:58:09      39471 terraform.tfstate
```

## Evidência da Conexão EC2 → RDS

```
$ psql "host=technova-6322006-aula05-db.cpgishv9reyu.us-east-1.rds.amazonaws.com port=5432 dbname=technova user=technova_admin sslmode=require" -c "SELECT version();"

                                              version
---------------------------------------------------------------------------------------------------
 PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC) 12.4.0, 64-bit
(1 row)
```

## Evidência de Dados Persistentes

```
$ psql "host=technova-6322006-aula05-db.cpgishv9reyu.us-east-1.rds.amazonaws.com port=5432 dbname=technova user=technova_admin sslmode=require" -f orders.sql

BEGIN
CREATE TABLE
INSERT 0 5
COMMIT
 id |     customer_name      | product | quantity |          created_at
----+------------------------+---------+----------+------------------------------
  1 | Rafael Nogueira Maruca | Teclado |        1 | 2026-09-15 02:07:12.46199+00
  2 | Rafael Nogueira Maruca | Mouse   |        2 | 2026-09-15 02:07:12.46199+00
  3 | Rafael Nogueira Maruca | Monitor |        1 | 2026-09-15 02:07:12.46199+00
  4 | Rafael Nogueira Maruca | Headset |        1 | 2026-09-15 02:07:12.46199+00
  5 | Rafael Nogueira Maruca | Webcam  |        1 | 2026-09-15 02:07:12.46199+00
(5 rows)
```

## Evidência do Terraform Plan

```
$ terraform plan

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.
```

## Evidência da Limpeza

```
$ terraform destroy (infraestrutura principal)
Destroy complete! Resources: 16 destroyed.

$ terraform destroy (backend)
Destroy complete! Resources: 5 destroyed.

$ aws s3api head-bucket --bucket 6322006-technova-tfstate-533129404111-us-east-1
An error occurred (404) when calling the HeadBucket operation: Not Found
```

O bucket S3 do backend foi criado fora do Terraform (via AWS CLI, contornando o bloqueio de leitura de Object Lock imposto pelo SCP do AWS Academy Learner Lab) e removido manualmente (esvaziamento de todas as versões + `delete-bucket`) após o destroy do backend.
