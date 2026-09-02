# Entrega — Aula 03: Terraform + IAM

**Aluno:** Felipe Damasceno  
**RA:** 6325128  
**Data:** 28/08/2026

## Repositório

- URL: https://github.com/FelipeDesda/unifaat-devops-portfolio

## Evidências

- [ ] `providers.tf` com provider AWS configurado
- [ ] `main.tf` com users, groups e memberships
- [ ] `policies.tf` com mínimo 3 custom policies
- [ ] `roles.tf` com service role + instance profile
- [ ] `variables.tf` e `outputs.tf` configurados
- [ ] `terraform-plan-output.txt` com evidência do plano
- [ ] `README.md` com explicação do design e reflexão sobre menor privilégio
- [ ] Tags obrigatórias em todos os recursos
- [ ] `.gitignore` configurado (sem `.tfstate` no repositório)

## Evidência do Terraform Plan

data.aws_iam_policy_document.ec2_trust_policy: Reading...
data.aws_iam_policy_document.ec2_trust_policy: Read complete after 0s [id=595599228]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_group.developers will be created
  + resource "aws_iam_group" "developers" {
      + arn       = (known after apply)
      + id        = (known after apply)
      + name      = "SEURA-technova-developers"
      + path      = "/technova/"
      + unique_id = (known after apply)
    }

  # aws_iam_group.platform_eng will be created
  + resource "aws_iam_group" "platform_eng" {
      + arn       = (known after apply)
      + id        = (known after apply)
      + name      = "SEURA-technova-platform-eng"
      + path      = "/technova/"
      + unique_id = (known after apply)
    }

  # aws_iam_group_policy_attachment.developers_deny_destructive will be created
  + resource "aws_iam_group_policy_attachment" "developers_deny_destructive" {
      + group      = "SEURA-technova-developers"
      + id         = (known after apply)
      + policy_arn = (known after apply)
    }

  # aws_iam_group_policy_attachment.developers_s3_read will be created
  + resource "aws_iam_group_policy_attachment" "developers_s3_read" {
      + group      = "SEURA-technova-developers"
      + id         = (known after apply)
      + policy_arn = (known after apply)
    }

  # aws_iam_group_policy_attachment.platform_eng_ec2_s3_full will be created
  + resource "aws_iam_group_policy_attachment" "platform_eng_ec2_s3_full" {
      + group      = "SEURA-technova-platform-eng"
      + id         = (known after apply)
      + policy_arn = (known after apply)
    }

  # aws_iam_instance_profile.ec2_profile will be created
  + resource "aws_iam_instance_profile" "ec2_profile" {
      + arn         = (known after apply)
      + create_date = (known after apply)
      + id          = (known after apply)
      + name        = "SEURA-technova-ec2-profile"
      + name_prefix = (known after apply)
      + path        = "/technova/"
      + role        = "SEURA-technova-ec2-role"
      + tags        = {
          + "Purpose" = "Instance profile for EC2 S3 app data role"
        }
      + tags_all    = {
          + "Aluno"      = "Felipe Damasceno"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "Purpose"    = "Instance profile for EC2 S3 app data role"
          + "RA"         = "6325128"
        }
      + unique_id   = (known after apply)
    }

  # aws_iam_policy.deny_destructive will be created
  + resource "aws_iam_policy" "deny_destructive" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Deny explícito para Delete* e Terminate* — proteção extra sobre o grupo developers"
      + id               = (known after apply)
      + name             = "SEURA-technova-deny-destructive"
      + name_prefix      = (known after apply)
      + path             = "/technova/"
      + policy           = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "s3:DeleteObject",
                          + "s3:DeleteObjectVersion",
                          + "s3:DeleteBucket",
                          + "s3:DeleteBucketPolicy",
                          + "s3:DeleteBucketWebsite",
                        ]
                      + Effect   = "Deny"
                      + Resource = "*"
                      + Sid      = "DenyDestructiveS3"
                    },
                  + {
                      + Action   = [
                          + "ec2:TerminateInstances",
                          + "ec2:DeleteVolume",
                          + "ec2:DeleteSnapshot",
                          + "ec2:DeleteSecurityGroup",
                          + "ec2:DeleteKeyPair",
                        ]
                      + Effect   = "Deny"
                      + Resource = "*"
                      + Sid      = "DenyDestructiveEC2"
                    },
                  + {
                      + Action   = [
                          + "iam:DeleteUser",
                          + "iam:DeleteGroup",
                          + "iam:DeleteRole",
                          + "iam:DeletePolicy",
                          + "iam:DeleteAccessKey",
                        ]
                      + Effect   = "Deny"
                      + Resource = "*"
                      + Sid      = "DenyDestructiveIAM"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id        = (known after apply)
      + tags             = {
          + "Purpose" = "Guardrail: prevent destructive actions by developers"
        }
      + tags_all         = {
          + "Aluno"      = "Felipe Damasceno"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "Purpose"    = "Guardrail: prevent destructive actions by developers"
          + "RA"         = "6325128"
        }
    }

  # aws_iam_policy.ec2_role_s3_app_data will be created
  + resource "aws_iam_policy" "ec2_role_s3_app_data" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Permite que instâncias EC2 façam read/write em buckets technova-app-data-*"
      + id               = (known after apply)
      + name             = "SEURA-technova-ec2-role-s3-app-data"
      + name_prefix      = (known after apply)
      + path             = "/technova/"
      + policy           = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "s3:ListBucket",
                          + "s3:GetBucketLocation",
                        ]
                      + Effect   = "Allow"
                      + Resource = "arn:aws:s3:::technova-app-data-*"
                      + Sid      = "ListAppDataBuckets"
                    },
                  + {
                      + Action   = [
                          + "s3:GetObject",
                          + "s3:GetObjectVersion",
                          + "s3:PutObject",
                          + "s3:PutObjectTagging",
                          + "s3:DeleteObject",
                          + "s3:AbortMultipartUpload",
                          + "s3:ListMultipartUploadParts",
                        ]
                      + Effect   = "Allow"
                      + Resource = "arn:aws:s3:::technova-app-data-*/*"
                      + Sid      = "ReadWriteAppDataObjects"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id        = (known after apply)
      + tags             = {
          + "Purpose" = "S3 read/write for EC2 instances (app data buckets)"
        }
      + tags_all         = {
          + "Aluno"      = "Felipe Damasceno"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "Purpose"    = "S3 read/write for EC2 instances (app data buckets)"
          + "RA"         = "6325128"
        }
    }

  # aws_iam_policy.ec2_s3_full will be created
  + resource "aws_iam_policy" "ec2_s3_full" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "EC2 Describe/Start/Stop (tag condition) + S3 read/write em technova-*"
      + id               = (known after apply)
      + name             = "SEURA-technova-ec2-s3-full"
      + name_prefix      = (known after apply)
      + path             = "/technova/"
      + policy           = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "ec2:DescribeInstances",
                          + "ec2:DescribeInstanceStatus",
                          + "ec2:DescribeRegions",
                          + "ec2:DescribeAvailabilityZones",
                          + "ec2:DescribeTags",
                          + "ec2:DescribeVolumes",
                          + "ec2:DescribeSecurityGroups",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                      + Sid      = "EC2DescribeAll"
                    },
                  + {
                      + Action    = [
                          + "ec2:StartInstances",
                          + "ec2:StopInstances",
                          + "ec2:RebootInstances",
                        ]
                      + Condition = {
                          + StringEquals = {
                              + "ec2:ResourceTag/Project" = "TechNova"
                            }
                        }
                      + Effect    = "Allow"
                      + Resource  = "arn:aws:ec2:*:*:instance/*"
                      + Sid       = "EC2StartStopTagged"
                    },
                  + {
                      + Action   = [
                          + "s3:ListBucket",
                          + "s3:GetBucketLocation",
                          + "s3:ListBucketMultipartUploads",
                        ]
                      + Effect   = "Allow"
                      + Resource = "arn:aws:s3:::technova-*"
                      + Sid      = "S3ListTechnovaBuckets"
                    },
                  + {
                      + Action   = [
                          + "s3:GetObject",
                          + "s3:GetObjectVersion",
                          + "s3:GetObjectTagging",
                          + "s3:PutObject",
                          + "s3:PutObjectTagging",
                          + "s3:AbortMultipartUpload",
                          + "s3:ListMultipartUploadParts",
                        ]
                      + Effect   = "Allow"
                      + Resource = "arn:aws:s3:::technova-*/*"
                      + Sid      = "S3ReadWriteTechnovaObjects"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id        = (known after apply)
      + tags             = {
          + "Purpose" = "EC2 and S3 full access for platform engineers"
        }
      + tags_all         = {
          + "Aluno"      = "Felipe Damasceno"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "Purpose"    = "EC2 and S3 full access for platform engineers"
          + "RA"         = "6325128"
        }
    }

  # aws_iam_policy.s3_read will be created
  + resource "aws_iam_policy" "s3_read" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Permite s3:GetObject e s3:ListBucket em buckets technova-* (menor privilégio)"
      + id               = (known after apply)
      + name             = "SEURA-technova-s3-read"
      + name_prefix      = (known after apply)
      + path             = "/technova/"
      + policy           = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "s3:ListBucket",
                          + "s3:GetBucketLocation",
                        ]
                      + Effect   = "Allow"
                      + Resource = "arn:aws:s3:::technova-*"
                      + Sid      = "ListTechnovaBuckets"
                    },
                  + {
                      + Action   = [
                          + "s3:GetObject",
                          + "s3:GetObjectVersion",
                          + "s3:GetObjectTagging",
                        ]
                      + Effect   = "Allow"
                      + Resource = "arn:aws:s3:::technova-*/*"
                      + Sid      = "ReadTechnovaObjects"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id        = (known after apply)
      + tags             = {
          + "Purpose" = "S3 read-only access for developers"
        }
      + tags_all         = {
          + "Aluno"      = "Felipe Damasceno"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "Purpose"    = "S3 read-only access for developers"
          + "RA"         = "6325128"
        }
    }

  # aws_iam_role.ec2_role will be created
  + resource "aws_iam_role" "ec2_role" {
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
                      + Sid       = "AllowEC2AssumeRole"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + description           = "Role assumida por instâncias EC2 para acesso ao S3 de dados da aplicação"
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "SEURA-technova-ec2-role"
      + name_prefix           = (known after apply)
      + path                  = "/technova/"
      + tags                  = {
          + "Purpose" = "EC2 service role for S3 app data access"
        }
      + tags_all              = {
          + "Aluno"      = "Felipe Damasceno"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "Purpose"    = "EC2 service role for S3 app data access"
          + "RA"         = "6325128"
        }
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # aws_iam_role_policy_attachment.ec2_role_s3_app_data will be created
  + resource "aws_iam_role_policy_attachment" "ec2_role_s3_app_data" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "SEURA-technova-ec2-role"
    }

  # aws_iam_user.juliana_dev will be created
  + resource "aws_iam_user" "juliana_dev" {
      + arn           = (known after apply)
      + force_destroy = false
      + id            = (known after apply)
      + name          = "SEURA-juliana-dev"
      + path          = "/technova/"
      + tags          = {
          + "Role" = "Developer"
        }
      + tags_all      = {
          + "Aluno"      = "Felipe Damasceno"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "RA"         = "6325128"
          + "Role"       = "Developer"
        }
      + unique_id     = (known after apply)
    }

  # aws_iam_user.lucas_intern will be created
  + resource "aws_iam_user" "lucas_intern" {
      + arn           = (known after apply)
      + force_destroy = false
      + id            = (known after apply)
      + name          = "SEURA-lucas-intern"
      + path          = "/technova/"
      + tags          = {
          + "Role" = "Intern"
        }
      + tags_all      = {
          + "Aluno"      = "Felipe Damasceno"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "RA"         = "6325128"
          + "Role"       = "Intern"
        }
      + unique_id     = (known after apply)
    }

  # aws_iam_user.rafael_platform will be created
  + resource "aws_iam_user" "rafael_platform" {
      + arn           = (known after apply)
      + force_destroy = false
      + id            = (known after apply)
      + name          = "SEURA-rafael-platform"
      + path          = "/technova/"
      + tags          = {
          + "Role" = "Platform Engineer"
        }
      + tags_all      = {
          + "Aluno"      = "Felipe Damasceno"
          + "Aula"       = "03"
          + "Disciplina" = "DevOps - UniFAAT 2026-2"
          + "ManagedBy"  = "Terraform"
          + "Project"    = "TechNova"
          + "RA"         = "6325128"
          + "Role"       = "Platform Engineer"
        }
      + unique_id     = (known after apply)
    }

  # aws_iam_user_group_membership.juliana_membership will be created
  + resource "aws_iam_user_group_membership" "juliana_membership" {
      + groups = [
          + "SEURA-technova-developers",
        ]
      + id     = (known after apply)
      + user   = "SEURA-juliana-dev"
    }

  # aws_iam_user_group_membership.lucas_membership will be created
  + resource "aws_iam_user_group_membership" "lucas_membership" {
      + groups = [
          + "SEURA-technova-developers",
        ]
      + id     = (known after apply)
      + user   = "SEURA-lucas-intern"
    }

  # aws_iam_user_group_membership.rafael_membership will be created
  + resource "aws_iam_user_group_membership" "rafael_membership" {
      + groups = [
          + "SEURA-technova-developers",
          + "SEURA-technova-platform-eng",
        ]
      + id     = (known after apply)
      + user   = "SEURA-rafael-platform"
    }

  # aws_iam_user_policy.lucas_intern_restricted will be created
  + resource "aws_iam_user_policy" "lucas_intern_restricted" {
      + id          = (known after apply)
      + name        = "SEURA-technova-lucas-intern-restricted"
      + name_prefix = (known after apply)
      + policy      = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "s3:ListBucket",
                          + "s3:GetObject",
                        ]
                      + Effect   = "Allow"
                      + Resource = [
                          + "arn:aws:s3:::technova-*",
                          + "arn:aws:s3:::technova-*/*",
                        ]
                      + Sid      = "InternS3ReadOnlyRestricted"
                    },
                  + {
                      + Action   = [
                          + "s3:PutObject",
                          + "s3:DeleteObject",
                          + "s3:PutBucketPolicy",
                          + "ec2:*",
                          + "iam:*",
                        ]
                      + Effect   = "Deny"
                      + Resource = "*"
                      + Sid      = "InternDenyWrite"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + user        = "SEURA-lucas-intern"
    }

Plan: 19 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + all_user_arns                   = {
      + juliana_dev     = (known after apply)
      + lucas_intern    = (known after apply)
      + rafael_platform = (known after apply)
    }
  + ec2_instance_profile_arn        = (known after apply)
  + ec2_instance_profile_name       = "SEURA-technova-ec2-profile"
  + ec2_role_arn                    = (known after apply)
  + ec2_role_name                   = "SEURA-technova-ec2-role"
  + group_developers_arn            = (known after apply)
  + group_platform_eng_arn          = (known after apply)
  + policy_deny_destructive_arn     = (known after apply)
  + policy_ec2_role_s3_app_data_arn = (known after apply)
  + policy_ec2_s3_full_arn          = (known after apply)
  + policy_s3_read_arn              = (known after apply)
  + user_juliana_dev_arn            = (known after apply)
  + user_lucas_intern_arn           = (known after apply)
  + user_rafael_platform_arn        = (known after apply)
╷
│ Warning: Argument is deprecated
│
│   with aws_iam_role.ec2_role,
│   on roles.tf line 72, in resource "aws_iam_role" "ec2_role":
│   72:   managed_policy_arns = []
│
│ managed_policy_arns is deprecated. Use the aws_iam_role_policy_attachment resource instead. If Terraform should
│ exclusively manage all managed policy attachments (the current behavior of this argument), use the
│ aws_iam_role_policy_attachments_exclusive resource as well.
╵

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if
you run "terraform apply" now.