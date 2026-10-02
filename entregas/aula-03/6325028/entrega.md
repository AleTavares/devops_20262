# Entrega — Aula 03: Terraform + IAM

**Aluno:** Denise Macedo
**RA:** 6325028
**Data:** 2026-09-21

## Repositório

- URL: https://github.com/Denisemayder/unifaat-devops-portfolio

## Evidências

- [x] `providers.tf` com provider AWS configurado
- [x] `main.tf` com estrutura de users, groups e memberships documentada
- [x] `policies.tf` com 3 custom policies (menor privilegio)
- [x] `roles.tf` com service role documentada (bloqueada pelo AWS Academy)
- [x] `variables.tf` e `outputs.tf` configurados
- [x] `terraform-plan-output.txt` com evidencia do plano
- [x] `terraform-apply-output.txt` com evidencia da aplicacao
- [x] `README.md` com explicacao do design e reflexao sobre menor privilegio
- [x] `.gitignore` configurado (sem .tfstate no repositorio)

## Evidência do Terraform Apply

```
aws_iam_policy.deny_destructive: Creation complete [id=arn:aws:iam::626137440679:policy/6325028-technova-deny-destructive]
aws_iam_policy.ec2_s3_full: Creation complete [id=arn:aws:iam::626137440679:policy/6325028-technova-ec2-s3-full]
aws_iam_policy.s3_read: Creation complete [id=arn:aws:iam::626137440679:policy/6325028-technova-s3-read]

Outputs:
policy_deny_destructive_arn = "arn:aws:iam::626137440679:policy/6325028-technova-deny-destructive"
policy_ec2_s3_full_arn      = "arn:aws:iam::626137440679:policy/6325028-technova-ec2-s3-full"
policy_s3_read_arn          = "arn:aws:iam::626137440679:policy/6325028-technova-s3-read"
```

## Observacao

O AWS Academy Learner Lab bloqueia iam:CreateGroup, iam:CreateUser e iam:CreateRole
pela role voclabs. As 3 custom policies foram criadas com sucesso na AWS.
A estrutura completa de grupos, usuarios e role esta documentada no codigo.
