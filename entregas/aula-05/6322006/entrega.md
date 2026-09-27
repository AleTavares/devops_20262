# Entrega — Aula 05: RDS e Remote State

**Aluno:** Rafael Nogueira Maruca  
**RA:** 6322006  
**Data:** 25/09/2026

## Repositório

- URL: https://github.com/rafadical/unifaat-devops-portfolio

## Evidências

- [x] VPC com subnets públicas e privadas em 2 AZs
- [x] RDS PostgreSQL (db.t3.micro) nas subnets privadas
- [x] EC2 t2.micro na subnet pública, conectando ao RDS
- [x] Security Groups corretos (porta 5432 apenas da VPC)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] State armazenado no S3 (evidência em `aula-05/evidencias/state-s3.txt`)
- [x] Conexão EC2 → RDS via psql (evidência em `aula-05/evidencias/rds-connection.txt`)
- [x] Dados persistentes na tabela `orders` (evidência em `aula-05/evidencias/orders-data.txt`)
- [x] `terraform plan` limpo após apply (evidência em `aula-05/evidencias/plan-clean.txt`)
- [x] `terraform destroy` executado após evidências

## Evidência do State no S3

```text
aws s3 ls s3://<bucket>/aula-05/6322006/
```

## Evidência da Conexão EC2 → RDS

```text
psql "host=<ENDPOINT> port=5432 dbname=technova user=technova_admin sslmode=require" -c "SELECT version();"
```

## Evidência dos dados persistentes

```text
psql "host=<ENDPOINT> port=5432 dbname=technova user=technova_admin sslmode=require" -c "SELECT * FROM orders ORDER BY id;"
```

> A validação real da infraestrutura foi registrada no portfólio em `aula-05/VALIDACAO.md`, incluindo a execução do backend S3/DynamoDB, a conexão EC2→RDS, a persistência da tabela `orders` e a limpeza final dos recursos.
