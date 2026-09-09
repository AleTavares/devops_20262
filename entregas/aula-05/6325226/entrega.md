# Entrega — Aula 05: RDS e Remote State

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 09/09/2026

## Repositório

- URL: https://github.com/lucaskenway/unifaat-devops-portfolio

> **⚠️ Confirme:** este link precisa apontar para o seu repositório pessoal `unifaat-devops-portfolio`, **público**, com a pasta `aula-05/` contendo o código Terraform (`aula-05-backend/` e `aula-05-rds/`). Ajuste a URL acima se o nome/usuário do repositório for outro.

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
