# Entrega — Aula 03: Terraform + IAM

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 2026-08-28

## Repositório

- URL: https://github.com/lucaskenway/unifaat-devops-portfolio/tree/main/aula-03

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

```
Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_group.developers will be created
  # aws_iam_group.platform_eng will be created
  # aws_iam_group_membership.developers will be created
  # aws_iam_group_membership.platform_eng will be created
  # aws_iam_group_policy_attachment.developers_deny_destructive will be created
  # aws_iam_group_policy_attachment.developers_s3_read will be created
  # aws_iam_group_policy_attachment.platform_eng_ec2_s3_full will be created
  # aws_iam_instance_profile.technova_ec2_profile will be created
  # aws_iam_policy.deny_destructive will be created
  # aws_iam_policy.ec2_s3_full will be created
  # aws_iam_policy.s3_read will be created
  # aws_iam_role.technova_ec2_role will be created
  # aws_iam_role_policy.technova_ec2_role_permissions will be created
  # aws_iam_user.juliana_dev will be created
  # aws_iam_user.lucas_intern will be created
  # aws_iam_user.rafael_platform will be created

Plan: 16 to add, 0 to change, 0 to destroy.
```

Output completo em [`aula-03/terraform-plan-output.txt`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-03/terraform-plan-output.txt) no repositório do portfólio.
