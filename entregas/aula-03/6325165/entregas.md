# Entrega — Aula 03: Terraform + IAM

**Aluno:** Grazielli Monteiro
**RA:** 6325165
**Data:** 16/09/2026

## Repositório

- URL: https://github.com/grazykkj/unifaat-devops-portfolio

## Evidências

- [x] `providers.tf` com provider AWS configurado
- [x] `main.tf` com users, groups e memberships
- [x] `policies.tf` com mínimo 3 custom policies
- [x] `roles.tf` com service role + instance profile
- [x] `variables.tf` e `outputs.tf` configurados
- [x] `terraform-plan-output.txt` com evidência do plano
- [x] `README.md` com explicação do design e reflexão sobre menor privilégio
- [x] Tags obrigatórias em todos os recursos
- [x] `.gitignore` configurado (sem `.tfstate` no repositório)

## Evidência do Terraform Plan

Plan: 18 to add, 0 to change, 0 to destroy.

with aws_iam_policy.ec2_app_data,
│   on roles.tf line 30, in resource "aws_iam_policy" "ec2_app_data":
│   30: resource "aws_iam_policy" "ec2_app_data"