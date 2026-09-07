Entrega — Aula 03: Terraform + IAM

Aluno: João Pedro Paulino Ferreira

RA: 6325175

Data: 03/09/2026

Repositório
URL: https://github.com/Joaoz007/unifaat-devops-portfolio
Pasta do projeto: aula-03/
Evidências

providers.tf com provider AWS configurado (hashicorp/aws ~> 5.0, us-east-1)

main.tf com users, groups e memberships (2 groups, 3 users, memberships configuradas)

policies.tf com mínimo 3 custom policies

roles.tf com service role + instance profile (trust policy ec2.amazonaws.com)

variables.tf e outputs.tf configurados

terraform-plan-output.txt com evidência do plano

README.md com explicação do design e reflexão sobre menor privilégio

Tags obrigatórias nos recursos que as suportam (Project, ManagedBy, Aluno, RA, Disciplina, Aula)

.gitignore configurado (sem .tfstate no repositório)