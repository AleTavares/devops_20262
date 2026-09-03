# Aula 03 — Terraform + IAM

**Aluno:** Carollini Godoy
**RA:** 3925000
**Disciplina:** DevOps - UniFAAT 2026-2

## Entrega

Implementação da Aula 03 utilizando Terraform e AWS IAM.

A solução está disponível no repositório do portfólio:

**Repositório:**
https://github.com/caroll143/unifaat-devops-portfolio

**Pasta da atividade:**
`aula-03/`

## Recursos implementados

* 2 grupos IAM
* 3 usuários IAM
* 3 policies personalizadas
* Associações entre usuários, grupos e policies
* EC2 Service Role
* EC2 Instance Profile
* Políticas de acesso ao S3
* Controle de ações destrutivas
* Variáveis, outputs e tags padronizadas
* Registro do `terraform plan`

## Observação sobre a execução

O `terraform validate` e o `terraform plan` foram executados com sucesso, com previsão de criação de 17 recursos.

Durante o `terraform apply`, o AWS Academy Learner Lab bloqueou operações IAM necessárias à criação dos recursos, retornando `AccessDenied` para ações como `iam:CreateUser`, `iam:CreateGroup`, `iam:CreateRole` e `iam:TagPolicy`.

A configuração Terraform e o plano foram mantidos no repositório para avaliação.
