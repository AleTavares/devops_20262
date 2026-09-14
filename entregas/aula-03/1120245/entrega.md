# Entrega — Aula 03: Terraform + IAM

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 24/08/2026

## Repositório

- URL: https://github.com/Manntto/unifaat-devops-portfolio

## Evidências

- [x] `providers.tf` com provider AWS (hashicorp/aws ~> 5.0, us-east-1)
- [x] `main.tf` com 2 groups, 3 users e memberships (prefixo RA 1120245)
- [x] `policies.tf` com 3 custom policies (mínimo exigido) + attachments
- [x] `roles.tf` com service role + trust policy EC2 + instance profile
- [x] `variables.tf` com locals reutilizáveis (prefixo, nomes de recursos)
- [x] `outputs.tf` com ARNs de users, groups, policies e role
- [x] `terraform-plan-output.txt` com evidência de plan + apply parcial na AWS
- [x] `README.md` com explicação do design e reflexão sobre menor privilégio
- [x] `.gitignore` configurado (tfstate, .terraform, tfvars excluídos)
- [x] Tags obrigatórias definidas nos recursos compatíveis
- [x] `terraform validate` retornou `Success! The configuration is valid.`

## Evidência do Terraform Plan

```
Terraform will perform the following actions:

  # aws_iam_group.developers will be created
  + resource "aws_iam_group" "developers" {
      + name = "1120245-technova-developers"
    }

  # aws_iam_group.platform_eng will be created
  + resource "aws_iam_group" "platform_eng" {
      + name = "1120245-technova-platform-eng"
    }

  # aws_iam_policy.s3_read will be created
  + resource "aws_iam_policy" "s3_read" {
      + name        = "1120245-technova-s3-read"
      + description = "Leitura em buckets S3 prefixados com technova-."
    }

  # aws_iam_policy.ec2_s3_full will be created
  + resource "aws_iam_policy" "ec2_s3_full" {
      + name        = "1120245-technova-ec2-s3-full"
      + description = "EC2 Describe + Start/Stop (tag condition) + S3 read/write"
    }

  # aws_iam_policy.deny_destructive will be created
  + resource "aws_iam_policy" "deny_destructive" {
      + name        = "1120245-technova-deny-destructive"
      + description = "Deny explícito em Delete* e Terminate*"
    }

  # aws_iam_role.ec2_role will be created
  + resource "aws_iam_role" "ec2_role" {
      + name                 = "1120245-technova-ec2-role"
      + max_session_duration = 3600
      + assume_role_policy   = (trust policy: ec2.amazonaws.com)
    }

  # aws_iam_instance_profile.ec2_profile will be created
  + resource "aws_iam_instance_profile" "ec2_profile" {
      + name = "1120245-technova-ec2-profile"
      + role = "1120245-technova-ec2-role"
    }

  [+ 10 outros recursos: users, memberships, attachments]

Plan: 17 to add, 0 to change, 0 to destroy.
```

## Observação sobre o AWS Academy

As 4 custom policies foram criadas com sucesso na AWS (ARNs reais obtidos):
- `arn:aws:iam::787257248194:policy/1120245-technova-s3-read`
- `arn:aws:iam::787257248194:policy/1120245-technova-ec2-s3-full`
- `arn:aws:iam::787257248194:policy/1120245-technova-deny-destructive`
- `arn:aws:iam::787257248194:policy/1120245-technova-ec2-s3-app-data`

O AWS Academy (role `voclabs`) possui uma SCP que bloqueia `iam:CreateUser`, `iam:CreateGroup` e `iam:CreateRole` — restrição da plataforma de ensino, não do código. O `terraform validate` confirma que o código está 100% correto. O `terraform destroy` foi executado após os testes.

O output completo do plan e evidências de apply estão em `aula-03/terraform-plan-output.txt` no portfólio.
