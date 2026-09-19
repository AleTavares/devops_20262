# Entrega — Aula 03: Terraform + IAM

**Aluno:** Emilly Santos de Oliveira
**RA:** 4023575
**Data:** 08/09/2026

## Repositório

- URL: https://github.com/leonidas-alt/unifaat-devops-portfolio.git

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

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_group.developers will be created
  + resource "aws_iam_group" "developers" {
      + arn       = (known after apply)
      + id        = (known after apply)
      + name      = "4023575-technova-developers"
      + path      = "/technova/"
      + unique_id = (known after apply)
    }

  # aws_iam_group.platform_eng will be created
  + resource "aws_iam_group" "platform_eng" {
      + arn       = (known after apply)
      + id        = (known after apply)
      + name      = "4023575-technova-platform-eng"
      + path      = "/technova/"
      + unique_id = (known after apply)
    }

  # aws_iam_group_membership.developers_membership will be created
  + resource "aws_iam_group_membership" "developers_membership" {
      + group = "4023575-technova-developers"
      + id    = (known after apply)
      + name  = "4023575-technova-developers-membership"
      + users = [
          + "4023575-juliana-dev",
          + "4023575-rafael-platform",
          + "4023575-lucas-intern",
        ]
    }

  # aws_iam_group_membership.platform_eng_membership will be created
  + resource "aws_iam_group_membership" "platform_eng_membership" {
      + group = "4023575-technova-platform-eng"
      + id    = (known after apply)
      + name  = "4023575-technova-platform-eng-membership"
      + users = [
          + "4023575-rafael-platform",
        ]
    }

  # aws_iam_group_policy_attachment.developers_deny_destructive will be created
  + resource "aws_iam_group_policy_attachment" "developers_deny_destructive" {
      + group      = "4023575-technova-developers"
      + id         = (known after apply)
      + policy_arn = (known after apply)
    }

  # aws_iam_group_policy_attachment.developers_s3_read will be created
  + resource "aws_iam_group_policy_attachment" "developers_s3_read" {
      + group      = "4023575-technova-developers"
      + id         = (known after apply)
      + policy_arn = (known after apply)
    }

  # aws_iam_group_policy_attachment.platform_eng_ec2_s3_full will be created
  + resource "aws_iam_group_policy_attachment" "platform_eng_ec2_s3_full" {
      + group      = "4023575-technova-platform-eng"
      + id         = (known after apply)
      + policy_arn = (known after apply)
    }

  # aws_iam_instance_profile.ec2_profile will be created
  + resource "aws_iam_instance_profile" "ec2_profile" {
      + arn         = (known after apply)
      + create_date = (known after apply)
      + id          = (known after apply)
      + name        = "4023575-technova-ec2-profile"
      + path        = "/technova/"
      + role        = "4023575-technova-ec2-role"
      + tags = {
          + "Aluno"      = "Emilly Santos de Oliveira"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Name"       = "4023575-technova-ec2-profile"
          + "Project"    = "TechNova"
          + "RA"         = "4023575"
        }
      + unique_id   = (known after apply)
    }

  # aws_iam_policy.deny_destructive will be created
  + resource "aws_iam_policy" "deny_destructive" {
      + arn         = (known after apply)
      + id          = (known after apply)
      + name        = "4023575-technova-deny-destructive"
      + path        = "/technova/"
      + policy      = jsonencode(...)
      + policy_id   = (known after apply)
      + tags = {
          + "Aluno"      = "Emilly Santos de Oliveira"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Name"       = "4023575-technova-deny-destructive"
          + "Project"    = "TechNova"
          + "RA"         = "4023575"
        }
    }

  # aws_iam_policy.ec2_s3_app_data will be created
  + resource "aws_iam_policy" "ec2_s3_app_data" {
      + arn  = (known after apply)
      + name = "4023575-technova-ec2-s3-app-data"
      + path = "/technova/"
    }

  # aws_iam_policy.ec2_s3_full will be created
  + resource "aws_iam_policy" "ec2_s3_full" {
      + arn  = (known after apply)
      + name = "4023575-technova-ec2-s3-full"
      + path = "/technova/"
    }

  # aws_iam_policy.s3_read will be created
  + resource "aws_iam_policy" "s3_read" {
      + arn  = (known after apply)
      + name = "4023575-technova-s3-read"
      + path = "/technova/"
    }

  # aws_iam_role.ec2_role will be created
  + resource "aws_iam_role" "ec2_role" {
      + arn              = (known after apply)
      + assume_role_policy = jsonencode({...ec2.amazonaws.com...})
      + name             = "4023575-technova-ec2-role"
      + path             = "/technova/"
    }

  # aws_iam_role_policy_attachment.ec2_role_app_data will be created
  + resource "aws_iam_role_policy_attachment" "ec2_role_app_data" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "4023575-technova-ec2-role"
    }

  # aws_iam_user.juliana_dev will be created
  + resource "aws_iam_user" "juliana_dev" {
      + arn       = (known after apply)
      + name      = "4023575-juliana-dev"
      + path      = "/technova/"
    }

  # aws_iam_user.lucas_intern will be created
  + resource "aws_iam_user" "lucas_intern" {
      + arn  = (known after apply)
      + name = "4023575-lucas-intern"
      + path = "/technova/"
    }

  # aws_iam_user.rafael_platform will be created
  + resource "aws_iam_user" "rafael_platform" {
      + arn  = (known after apply)
      + name = "4023575-rafael-platform"
      + path = "/technova/"
    }

Plan: 17 to add, 0 to change, 0 to destroy.