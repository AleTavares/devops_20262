# Entrega — Aula 05: RDS e Remote State

**Aluno:** Felipe Damasceno
**RA:** 6325128  
**Data:** 10/09/2026

## Repositório

- URL: https://github.com/FelipeDesda/unifaat-devops-portfolio

## Evidências

- [ ] VPC com subnets públicas e privadas em 2 AZs
- [ ] RDS PostgreSQL (db.t3.micro) nas subnets privadas
- [ ] EC2 t2.micro na subnet pública, conectando ao RDS
- [ ] Security Groups corretos (porta 5432 apenas da VPC)
- [ ] Remote State configurado (S3 + DynamoDB)
- [ ] State armazenado no S3 (evidência abaixo)
- [ ] Conexão EC2 → RDS via psql (evidência abaixo)
- [ ] `terraform destroy` executado após evidências

## Evidência do State no S3

[Cole aqui o output do `aws s3 ls` ou screenshot]

## Evidência da Conexão EC2 → RDS

[Cole aqui o output do psql ou screenshot]