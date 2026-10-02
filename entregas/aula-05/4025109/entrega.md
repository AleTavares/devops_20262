# Entrega — Aula 05: RDS e Remote State

**Aluno:** [FERNANDA TAVARES]  
**RA:** [4025109]  
**Data:** [17/09/2026]

## Repositório

- URL: https://github.com/fehhnovais/unifaat-devops-portfolio

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

[Cole aqui o output do `aws s3 ls` ou screenshot]

## Evidência da Conexão EC2 → RDS

[Cole aqui o output do psql ou screenshot]