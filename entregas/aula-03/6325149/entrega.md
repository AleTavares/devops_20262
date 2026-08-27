# Entrega — Aula 03: Terraform + IAM

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 27/08/2026

## Repositório

- URL: https://github.com/gabrielreis354/unifaat-devops-portfolio
- Pasta do projeto: [`aula-03/`](https://github.com/gabrielreis354/unifaat-devops-portfolio/tree/main/aula-03)

## Evidências

- [x] `providers.tf` com provider AWS configurado (hashicorp/aws ~> 5.0, us-east-1)
- [x] `main.tf` com users, groups e memberships (2 groups, 3 users, 2 memberships)
- [x] `policies.tf` com mínimo 3 custom policies (4 policies: s3-read, ec2-s3-full, deny-destructive, ec2-app-data)
- [x] `roles.tf` com service role + instance profile (trust policy `ec2.amazonaws.com`)
- [x] `variables.tf` e `outputs.tf` configurados
- [x] `terraform-plan-output.txt` com evidência do plano (`Plan: 17 to add`)
- [x] `README.md` com explicação do design e reflexão sobre menor privilégio
- [x] Tags obrigatórias em todos os recursos que as suportam (Project, ManagedBy, Aluno, RA, Disciplina, Aula)
- [x] `.gitignore` configurado (sem `.tfstate` no repositório)

## Evidência do Terraform Plan

Autenticação feita com identidade **IAM (não-root)** — perfil de laboratório, não o usuário root.

```
Terraform will perform the following actions:

  # aws_iam_group.developers will be created
  + resource "aws_iam_group" "developers" {
      + name      = "6325149-technova-developers"
      + path      = "/technova/"
    }

  # aws_iam_group.platform_eng will be created
  + resource "aws_iam_group" "platform_eng" {
      + name      = "6325149-technova-platform-eng"
      + path      = "/technova/"
    }

  # ... (users, memberships, 4 custom policies, attachments, service role e instance profile)

Plan: 17 to add, 0 to change, 0 to destroy.
```

Recursos que o plano cria (17):

| Tipo | Recursos |
|------|----------|
| Groups (2) | `6325149-technova-developers`, `6325149-technova-platform-eng` |
| Users (3) | `6325149-juliana-dev`, `6325149-rafael-platform`, `6325149-lucas-intern` |
| Memberships (2) | developers, platform-eng |
| Custom policies (4) | `s3-read`, `ec2-s3-full` (com Condition por tag), `deny-destructive` (Deny explícito), `ec2-app-data` |
| Attachments (4) | 3 em groups + 1 na role |
| Service role (1) | `6325149-technova-ec2-role` (trust `ec2.amazonaws.com`) |
| Instance profile (1) | `6325149-technova-ec2-profile` |

> Apenas `terraform plan` foi executado (evidência exigida pelo critério de avaliação). Nenhum recurso foi aplicado na AWS — portanto não há custo nem recurso ativo a destruir.
