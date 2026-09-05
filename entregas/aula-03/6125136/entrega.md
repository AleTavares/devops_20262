# Entrega — Aula 03: Terraform + IAM

**Aluno:** Hector Marcelo Pedroso dos Santos  
**RA:** 6125136  
**Data:** 01/09/2026

## Repositório

- URL: https://github.com/hectorbackfront/unifaat-devops-portfolio
- Pasta da entrega: [`aula-03/`](https://github.com/hectorbackfront/unifaat-devops-portfolio/tree/master/aula-03)

## Evidências

- [x] `providers.tf` com provider AWS configurado (hashicorp/aws ~> 5.0, us-east-1)
- [x] `main.tf` com users, groups e memberships
- [x] `policies.tf` com 4 custom policies + attachments
- [x] `roles.tf` com service role + instance profile
- [x] `variables.tf` e `outputs.tf` configurados
- [x] `terraform-plan-output.txt` com evidência do plano (20 recursos)
- [x] `README.md` com explicação do design e reflexão sobre menor privilégio
- [x] Tags obrigatórias em todos os recursos que suportam tagging
- [x] `.gitignore` configurado (sem `.tfstate` no repositório)

### Estrutura criada

| Tipo | Quantidade | Nomes |
|---|---|---|
| Groups | 2 | `6125136-technova-developers`, `6125136-technova-platform-eng` |
| Users | 3 | `6125136-juliana-dev`, `6125136-rafael-platform`, `6125136-lucas-intern` |
| Custom policies | 5 | `s3-read`, `ec2-s3-full`, `deny-destructive`, `intern-readonly`, `ec2-app-data` |
| Service role | 1 | `6125136-technova-ec2-role` + `6125136-technova-ec2-profile` |

Uso de **Condition** (`ec2:ResourceTag/Project = TechNova` no Start/Stop) e de **Deny explícito** (duas policies) conforme o critério 7.

**Observação sobre tags:** o recurso `aws_iam_group` não aceita o argumento `tags` — é uma limitação da API do IAM da AWS, não do Terraform. Todos os demais recursos (users, policies, role e instance profile) estão tagueados com `Project`, `ManagedBy`, `Aluno`, `RA`, `Disciplina` e `Aula`.

## Evidência do Terraform Plan

Arquivo completo: [`aula-03/terraform-plan-output.txt`](https://github.com/hectorbackfront/unifaat-devops-portfolio/blob/master/aula-03/terraform-plan-output.txt)

```
Plan: 20 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + resumo_entrega = {
      + aluno         = "Hector Marcelo Pedroso dos Santos"
      + groups        = 2
      + instance_prof = 1
      + policies      = 5
      + ra            = "6125136"
      + roles         = 1
      + users         = 3
    }
```

## Observação sobre a execução no AWS Academy

O `terraform plan` executa com sucesso e planeja os 20 recursos. O `terraform apply`, porém, falha no AWS Academy Learner Lab: a role `voclabs`, atribuída ao aluno pelo ambiente, não possui permissões de escrita em IAM.

```
AccessDenied: User: arn:aws:sts::210645360611:assumed-role/voclabs/user5372812=...
is not authorized to perform: iam:CreateGroup
is not authorized to perform: iam:CreateUser
is not authorized to perform: iam:CreateRole
is not authorized to perform: iam:TagPolicy
```

Log completo em [`aula-03/evidencia-apply-accessdenied.txt`](https://github.com/hectorbackfront/unifaat-devops-portfolio/blob/master/aula-03/evidencia-apply-accessdenied.txt).

Como nenhum recurso chegou a ser criado, não houve necessidade de `terraform destroy` — o `terraform state list` retorna apenas os `data sources`, sem recursos gerenciados. Fico à disposição para rodar o `apply` caso haja outro ambiente com `IAMFullAccess` disponível.
