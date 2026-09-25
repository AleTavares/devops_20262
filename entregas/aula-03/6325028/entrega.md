# Entrega — Aula 03: Terraform + IAM

**Aluno:** Denise Macedo
**RA:** 6325028
**Data:** 2026-09-21

## Repositório

- URL: https://github.com/Denisemayder/unifaat-devops-portfolio

## Evidências

- [x] `providers.tf` com provider AWS configurado
- [x] `main.tf` com 2 grupos, 3 usuários e memberships no código ativo
- [x] `policies.tf` com 3 custom policies com tags e attachments
- [x] `roles.tf` com service role + instance profile no código ativo
- [x] `variables.tf` e `outputs.tf` configurados
- [x] `terraform-plan-output.txt` com Plan: 13 recursos
- [x] `terraform-apply-output.txt` com 3 policies criadas na AWS
- [x] `README.md` com explicação do design e reflexão sobre menor privilégio
- [x] `.gitignore` configurado (sem .tfstate no repositório)

## Evidência do Terraform Plan (código ativo)

```
Plan: 13 to add, 0 to change, 0 to destroy.

Recursos declarados:
- aws_iam_group.developers
- aws_iam_group.platform_eng
- aws_iam_user.juliana / rafael / lucas
- aws_iam_group_membership.developers / platform_eng
- aws_iam_policy.s3_read / ec2_s3_full / deny_destructive
- aws_iam_group_policy_attachment (3x)
- aws_iam_role.ec2_role
- aws_iam_role_policy.ec2_s3_policy
- aws_iam_instance_profile.ec2_profile
```

## Evidência do Terraform Apply (policies criadas na AWS)

```
aws_iam_policy.deny_destructive: Creation complete
  [id=arn:aws:iam::626137440679:policy/6325028-technova-deny-destructive]
aws_iam_policy.ec2_s3_full: Creation complete
  [id=arn:aws:iam::626137440679:policy/6325028-technova-ec2-s3-full]
aws_iam_policy.s3_read: Creation complete
  [id=arn:aws:iam::626137440679:policy/6325028-technova-s3-read]
```

## Observação

O AWS Academy bloqueia iam:CreateGroup, iam:CreateUser e iam:CreateRole
via SCP da organização (role voclabs). O código está completo e funcional —
o terraform plan mostra todos os 13 recursos. As 3 custom policies foram
aplicadas com sucesso na AWS comprovando a sintaxe correta.
