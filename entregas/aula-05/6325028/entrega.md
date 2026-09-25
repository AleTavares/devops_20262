# Entrega — Aula 05: RDS e Remote State

**Aluno:** Denise Macedo
**RA:** 6325028
**Data:** 2026-09-22

## Repositório

- URL: https://github.com/Denisemayder/unifaat-devops-portfolio

## Evidências

- [x] VPC com subnets públicas e privadas em 2 AZs
- [x] RDS PostgreSQL 15 (db.t3.micro) nas subnets privadas
- [x] EC2 t2.micro na subnet pública, conectando ao RDS
- [x] Security Groups corretos (porta 5432 apenas do SG EC2)
- [x] Remote State configurado (DynamoDB lock + S3 documentado)
- [x] Conexão EC2 → RDS via psql comprovada
- [x] Dados persistentes criados e consultados
- [x] `terraform destroy` executado após evidências

## Evidência da Conexão EC2 → RDS

```
[ec2-user@ip-10-0-1-225 ~]$ psql -h technova-db-6325028.cyxchmww8xse.us-east-1.rds.amazonaws.com \
     -U technovaadmin -d technova -c "SELECT version();"

PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by gcc 12.4.0, 64-bit
(1 row)
```

## Evidência de Dados Persistentes

```
CREATE TABLE
INSERT 0 2

 id |  produto  | quantidade
----+-----------+------------
  1 | Produto A |         10
  2 | Produto B |         25
(2 rows)
```

## Observação sobre Remote State

O AWS Academy bloqueia s3:GetBucketObjectLockConfiguration e operações S3
via SCP da organização. O DynamoDB de lock foi criado com sucesso. O backend
S3 está documentado no providers.tf — funcional em ambiente real.
