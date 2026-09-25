# Entrega — Aula 03: Terraform + IAM

**Aluno:** Rafael Nogueira Maruca  
**RA:** 6322006  
**Data:** 24/09/2026

## Repositório

- URL: https://github.com/rafadical/unifaat-devops-portfolio

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

```text
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.100.0...
- Installed hashicorp/aws v5.100.0 (signed by HashiCorp)

Success! The configuration is valid.
```

> Observação: a execução real do `terraform plan` no ambiente local falhou por ausência de credenciais AWS válidas, mas a estrutura e a validação sintática do Terraform foram confirmadas no ambiente atual. A aplicação real do laboratório deve ocorrer no AWS Academy Learner Lab.
