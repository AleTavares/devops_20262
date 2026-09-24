# Entrega — Aula 03: Terraform + IAM

**Aluno:** José Henrique Teixeira Luiz
**RA:** 3225002
**Data:** 20/08/2026

## Repositório

- URL: https://github.com/zzin742/unifaat-devops-portfolio
- Pasta da aula: https://github.com/zzin742/unifaat-devops-portfolio/tree/main/aula-03

## Evidências

- [x] `providers.tf` com provider AWS configurado (`hashicorp/aws ~> 5.0`, `us-east-1`)
- [x] `main.tf` com users, groups e memberships
- [x] `policies.tf` com mínimo 3 custom policies
- [x] `roles.tf` com service role + instance profile
- [x] `variables.tf` e `outputs.tf` configurados
- [x] `terraform-plan-output.txt` com evidência do plano
- [x] `README.md` com explicação do design e reflexão sobre menor privilégio
- [x] Tags obrigatórias em todos os recursos
- [x] `.gitignore` configurado (sem `.tfstate` no repositório)

## Estrutura entregue

| Recurso | Qtd | Nomes |
|---|---|---|
| Groups | 2 | `3225002-technova-developers`, `3225002-technova-platform-eng` |
| Users | 3 | `juliana-dev`, `rafael-platform` (nos 2 grupos), `lucas-intern` |
| Custom policies | 4 | `s3-read`, `ec2-s3-full`, `deny-destructive`, `ec2-app-data` |
| Service role | 1 | `3225002-technova-ec2-role` + instance profile |

**Total: 19 recursos.**

Sobre o critério 6 (Conditions ou Deny), implementei os dois:

- **Condition por tag** — `ec2-s3-full` só permite `StartInstances`/`StopInstances`
  em instâncias com `aws:ResourceTag/Project = TechNova`
- **Deny explícito** — `deny-destructive` bloqueia `Delete*` e `Terminate*`, e
  prevalece sobre qualquer Allow, inclusive de policy gerenciada anexada por engano
- **Policy inline no estagiário** — em vez de duplicar o grupo, um `Deny` inline
  restringe o `lucas-intern` dentro do próprio grupo de developers

## Evidência do Terraform Plan

```
Plan: 19 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ec2_instance_profile_name = "3225002-technova-ec2-profile"
  + ec2_role_arn              = (known after apply)
  + iam_groups                = {
      + developers   = (known after apply)
      + platform_eng = (known after apply)
    }
  + resumo                    = {
      + custom_policies  = 4
      + grupos           = 2
      + instance_profile = 1
      + service_roles    = 1
      + usuarios         = 3
    }
```

Output completo (588 linhas):
https://github.com/zzin742/unifaat-devops-portfolio/blob/main/aula-03/terraform-plan-output.txt

## Evidência adicional — apply real e destroy

Como IAM não tem custo, apliquei de fato na conta AWS para comprovar que a
configuração funciona, e destruí em seguida conforme a regra do enunciado.

```
Apply complete!   Resources: 19 added, 0 changed, 0 destroyed.
Destroy complete! Resources: 19 destroyed.
```

ARNs retornados pela AWS, memberships e tags estão em
[`aula-03/evidencia-aws.txt`](https://github.com/zzin742/unifaat-devops-portfolio/blob/main/aula-03/evidencia-aws.txt).

Conta verificada limpa após o destroy — nenhum recurso ativo.
