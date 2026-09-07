# Entrega - Aula 03: Terraform + IAM

**Aluno:** Gabriel Carneiro da Silva
**RA:** 6325300
**Data:** 02/09/2026

## Repositorio

- URL: https://github.com/gcdsofc/unifaat-devops-portfolio
- Pasta da aula: `aula-03/`
- Branch da aula: https://github.com/gcdsofc/unifaat-devops-portfolio/tree/feature/aula-03-terraform-iam/aula-03

## Evidencias

- [x] `providers.tf` com provider AWS configurado
- [x] `main.tf` com users, groups e memberships
- [x] `policies.tf` com minimo 3 custom policies
- [x] `roles.tf` com service role + instance profile
- [x] `variables.tf` e `outputs.tf` configurados
- [x] `terraform-plan-output.txt` com evidencia do plano
- [x] `README.md` com explicacao do design e reflexao sobre menor privilegio
- [x] Tags obrigatorias nos recursos suportados pelo provider
- [x] `.gitignore` configurado sem `.tfstate`, `.terraform`, `.tfvars` e lockfile no repositorio

## Validacoes Executadas

```bash
terraform fmt
terraform init
terraform validate
terraform plan
```

Resultado do validate:

```text
Success! The configuration is valid.
```

## Evidencia do Terraform Plan

Trecho do arquivo `terraform-plan-output.txt`:

```text
Terraform will perform the following actions:

  # aws_iam_group.developers will be created
  + resource "aws_iam_group" "developers" {
      + name = "6325300-technova-developers"
      + path = "/technova/"
    }

  # aws_iam_group.platform_eng will be created
  + resource "aws_iam_group" "platform_eng" {
      + name = "6325300-technova-platform-eng"
      + path = "/technova/"
    }

  # aws_iam_role.ec2_role will be created
  + resource "aws_iam_role" "ec2_role" {
      + name = "6325300-technova-ec2-role"
      + path = "/technova/"
    }

Plan: 17 to add, 0 to change, 0 to destroy.
```

## Observacao sobre Tags

As tags obrigatorias foram aplicadas aos recursos que aceitam tags no provider AWS:

- `aws_iam_user`
- `aws_iam_policy`
- `aws_iam_role`
- `aws_iam_instance_profile`

Recursos de relacionamento, como `aws_iam_group_membership`, `aws_iam_group_policy_attachment` e `aws_iam_role_policy_attachment`, nao possuem atributo `tags` no schema do provider.

## Observacao sobre Apply

Foi executado `terraform plan` para gerar a evidencia solicitada.
Nao executei `terraform apply`, porque o objetivo da entrega e demonstrar o plano antes da criacao dos recursos.
