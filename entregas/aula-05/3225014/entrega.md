# Entrega — Aula 05: RDS e Remote State

**Aluno:** Felipe Gomes Mariano 
**RA:** 3225014
**Data:** 13/09/2026

## Repositório

- URL: https://github.com/felipem004/unifaat-devops-portfolio

## Evidências

- [x] VPC com subnets públicas e privadas em 2 AZs
- [x] RDS PostgreSQL (db.t3.micro) nas subnets privadas
- [x] EC2 t2.micro na subnet pública, conectando ao RDS
- [x] Security Groups corretos (porta 5432 apenas da VPC)
- [ ] Remote State configurado (S3 + DynamoDB)
- [ ] State armazenado no S3 (evidência abaixo)
- [x] Conexão EC2 → RDS via psql (evidência abaixo)
- [x] `terraform destroy` executado após evidências

## Evidência do State no S3

xxx

## Evidência da Conexão EC2 → RDS

![alt text](<Imagem colada.png>)