# Entrega — Aula 03: Terraform + IAM

**Aluno:** Sirlande Martins
**RA:** 6325269
**Data:** 27/08/2026

## Repositório

- URL: https://github.com/Sir-Jr/unifaat-devops-portfolio

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
$ terraform init && terraform validate && terraform plan

Terraform has been successfully initialized!
Success! The configuration is valid.

  # aws_iam_group.developers will be created
  # aws_iam_group.platform_eng will be created
  # aws_iam_user.juliana will be created
  # aws_iam_user.rafael will be created
  # aws_iam_user.lucas will be created
  # aws_iam_group_membership.developers will be created
  # aws_iam_group_membership.platform_eng will be created
  # aws_iam_policy.s3_read will be created
  # aws_iam_policy.ec2_s3_full will be created
  # aws_iam_policy.deny_destructive will be created
  # aws_iam_group_policy_attachment.developers_s3_read will be created
  # aws_iam_group_policy_attachment.developers_deny_destructive will be created
  # aws_iam_group_policy_attachment.platform_eng_ec2_s3_full will be created
  # aws_iam_role.ec2_role will be created
  # aws_iam_policy.ec2_app_data will be created
  # aws_iam_role_policy_attachment.ec2_role_s3 will be created
  # aws_iam_instance_profile.ec2_profile will be created

Plan: 17 to add, 0 to change, 0 to destroy.
```

**Nota sobre o ambiente:** testado com credenciais do AWS Academy Learner Lab. O `terraform
plan` roda limpo (evidência completa em
[`terraform-plan-output.txt`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-03/terraform-plan-output.txt)),
mas o `terraform apply` retorna `AccessDenied` — a role `voclabs` do Learner Lab tem Deny
explícito para ações de escrita em IAM (restrição intencional da sandbox da AWS Academy, não uma
falha no código). Detalhes completos no
[`README.md`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-03/README.md) do
projeto.

O arquivo completo do projeto (`providers.tf`, `main.tf`, `policies.tf`, `roles.tf`,
`variables.tf`, `outputs.tf`, `terraform-plan-output.txt`, `README.md`) está versionado em
[`aula-03/`](https://github.com/Sir-Jr/unifaat-devops-portfolio/tree/main/aula-03).
