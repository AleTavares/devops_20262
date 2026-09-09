# Entrega — Aula 03: Terraform + IAM

**Aluno:** Andreyh Rodrigues de Souza
**RA:** 6325231
**Data:** 03/09/2026

## Repositório

- URL: https://github.com/Andreyh117/unifaat-devops-portfolio

## Evidências

- [x] `providers.tf` com provider AWS configurado
- [x] `main.tf` com users, groups e memberships
- [x] `policies.tf` com mínimo 3 custom policies
- [x] `roles.tf` com service role + instance profile
- [x] `variables.tf` e `outputs.tf` configurados
- [x] `terraform-plan-output.txt` com evidência do plano
- [x] `README.md` com explicação do design e reflexão sobre menor privilégio
- [x] Tags obrigatórias nos recursos IAM que suportam tags
- [x] `.gitignore` configurado (sem `.tfstate` no repositório)

## Evidência do Terraform Plan

```text
Success! The configuration is valid.

Plan: 18 to add, 0 to change, 0 to destroy.
```

O plano prevê a criação de dois grupos, três usuários, três memberships,
quatro policies IAM (incluindo a policy da service role), três attachments,
uma role e um instance profile.
