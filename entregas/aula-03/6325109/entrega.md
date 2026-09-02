# Entrega — Aula 03: Terraform + IAM

**Aluno:** Carina Gonçalves dos Santos Dalpino  
**RA:** 6325109  
**Data:** 18/08/2026

## Repositório

- URL: https://github.com/CarinaDalpino/unifaat-devops-portfolio

## Evidências

- [x] `providers.tf` com provider AWS configurado
- [x] `main.tf` com users, groups e memberships
- [x] `policies.tf` com 3 custom policies
- [x] `roles.tf` com service role + instance profile
- [x] `variables.tf` e `outputs.tf` configurados
- [x] `terraform-plan-output.txt` com evidência do plano
- [x] `README.md` com explicação do design e reflexão sobre menor privilégio
- [x] Tags obrigatórias em todos os recursos
- [x] `.gitignore` configurado (sem `.tfstate` no repositório)

## Evidência do Terraform Apply

```
Apply complete! Resources: 22 added, 0 changed, 0 destroyed.

Outputs:

ec2_instance_profile_arn = "arn:aws:iam::619459868117:instance-profile/technova-ec2-instance-profile"
ec2_role_arn             = "arn:aws:iam::619459868117:role/technova-ec2-s3-role"
group_developers_arn     = "arn:aws:iam::619459868117:group/technova-developers"
group_devops_arn         = "arn:aws:iam::619459868117:group/technova-devops"
group_readonly_arn       = "arn:aws:iam::619459868117:group/technova-readonly"
iam_user_names           = ["technova-dev-joao", "technova-dev-maria", "technova-devops-ana", "technova-devops-carlos", "technova-readonly-marcos"]
policy_developer_s3_arn  = "arn:aws:iam::619459868117:policy/technova-developer-s3-policy"
policy_devops_arn        = "arn:aws:iam::619459868117:policy/technova-devops-policy"
```
