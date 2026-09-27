# Entrega — Aula 03: Terraform + IAM

**Aluno:** [Yuri Batista Sanches]  
**RA:** [6325238]  
**Data:** [23/09/2026]

## Repositório

- URL: https://github.com/Dooooc/unifaat-devops-portfolio

## Evidências

- [X] `providers.tf` com provider AWS configurado
- [X] `main.tf` com users, groups e memberships
- [X] `policies.tf` com mínimo 3 custom policies
- [X] `roles.tf` com service role + instance profile
- [X] `variables.tf` e `outputs.tf` configurados
- [X] `terraform-plan-output.txt` com evidência do plano
- [X] `README.md` com explicação do design e reflexão sobre menor privilégio
- [X] Tags obrigatórias em todos os recursos
- [X] `.gitignore` configurado (sem `.tfstate` no repositório)

## Evidência do Terraform Plan

[terraform plan
aws_iam_policy.developer: Refreshing state... [id=arn:aws:iam::172424055362:policy/TechNovaDeveloperPolicy]
aws_iam_policy.operations: Refreshing state... [id=arn:aws:iam::172424055362:policy/TechNovaOperationsPolicy]
aws_iam_policy.readonly: Refreshing state... [id=arn:aws:iam::172424055362:policy/TechNovaReadOnlyPolicy]
aws_iam_policy.application: Refreshing state... [id=arn:aws:iam::172424055362:policy/TechNovaApplicationPolicy]

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_group.developers will be created
  + resource "aws_iam_group" "developers" {
      + arn       = (known after apply)
      + id        = (known after apply)
      + name      = "technova-developers"
      + path      = "/"
      + unique_id = (known after apply)
    }

  # aws_iam_group.operations will be created
  + resource "aws_iam_group" "operations" {
      + arn       = (known after apply)
      + id        = (known after apply)
      + name      = "technova-ops"
      + path      = "/"
      + unique_id = (known after apply)
    }

  # aws_iam_group.readonly will be created
  + resource "aws_iam_group" "readonly" {
      + arn       = (known after apply)
      + id        = (known after apply)
      + name      = "technova-readonly"
      + path      = "/"
      + unique_id = (known after apply)
    }

  # aws_iam_group_policy_attachment.developer will be created
  + resource "aws_iam_group_policy_attachment" "developer" {
      + group      = "technova-developers"
      + id         = (known after apply)
      + policy_arn = "arn:aws:iam::172424055362:policy/TechNovaDeveloperPolicy"
    }

  # aws_iam_group_policy_attachment.operations will be created
  + resource "aws_iam_group_policy_attachment" "operations" {
      + group      = "technova-ops"
      + id         = (known after apply)
      + policy_arn = "arn:aws:iam::172424055362:policy/TechNovaOperationsPolicy"
    }

  # aws_iam_group_policy_attachment.readonly will be created
  + resource "aws_iam_group_policy_attachment" "readonly" {
      + group      = "technova-readonly"
      + id         = (known after apply)
      + policy_arn = "arn:aws:iam::172424055362:policy/TechNovaReadOnlyPolicy"
    }

  # aws_iam_role.application will be created
  + resource "aws_iam_role" "application" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "ec2.amazonaws.com"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "TechNovaApplicationRole"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "Aluno"      = "Yuri"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "RA"         = "6325238"
        }
      + tags_all              = {
          + "Aluno"      = "Yuri"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "RA"         = "6325238"
        }
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # aws_iam_role_policy_attachment.application will be created
  + resource "aws_iam_role_policy_attachment" "application" {
      + id         = (known after apply)
      + policy_arn = "arn:aws:iam::172424055362:policy/TechNovaApplicationPolicy"
      + role       = "TechNovaApplicationRole"
    }

  # aws_iam_user.auditor will be created
  + resource "aws_iam_user" "auditor" {
      + arn           = (known after apply)
      + force_destroy = false
      + id            = (known after apply)
      + name          = "technova-auditor-carol"
      + path          = "/"
      + tags          = {
          + "Aluno"      = "Yuri"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "RA"         = "6325238"
        }
      + tags_all      = {
          + "Aluno"      = "Yuri"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "RA"         = "6325238"
        }
      + unique_id     = (known after apply)
    }

  # aws_iam_user.developer will be created
  + resource "aws_iam_user" "developer" {
      + arn           = (known after apply)
      + force_destroy = false
      + id            = (known after apply)
      + name          = "technova-dev-alice"
      + path          = "/"
      + tags          = {
          + "Aluno"      = "Yuri"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "RA"         = "6325238"
        }
      + tags_all      = {
          + "Aluno"      = "Yuri"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "RA"         = "6325238"
        }
      + unique_id     = (known after apply)
    }

  # aws_iam_user.operations will be created
  + resource "aws_iam_user" "operations" {
      + arn           = (known after apply)
      + force_destroy = false
      + id            = (known after apply)
      + name          = "technova-ops-bob"
      + path          = "/"
      + tags          = {
          + "Aluno"      = "Yuri"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "RA"         = "6325238"
        }
      + tags_all      = {
          + "Aluno"      = "Yuri"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "RA"         = "6325238"
        }
      + unique_id     = (known after apply)
    }

  # aws_iam_user_group_membership.auditor will be created
  + resource "aws_iam_user_group_membership" "auditor" {
      + groups = [
          + "technova-readonly",
        ]
      + id     = (known after apply)
      + user   = "technova-auditor-carol"
    }

  # aws_iam_user_group_membership.developer will be created
  + resource "aws_iam_user_group_membership" "developer" {
      + groups = [
          + "technova-developers",
        ]
      + id     = (known after apply)
      + user   = "technova-dev-alice"
    }

  # aws_iam_user_group_membership.operations will be created
  + resource "aws_iam_user_group_membership" "operations" {
      + groups = [
          + "technova-ops",
        ]
      + id     = (known after apply)
      + user   = "technova-ops-bob"
    }

Plan: 14 to add, 0 to change, 0 to destroy.
]