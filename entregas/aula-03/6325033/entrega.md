# Entrega — Aula 03: Terraform + IAM Completo

**Aluno:** Renan Dias  
**RA:** 6325033  
**Data:** 02/09/2026

## Repositório do projeto

- **GitHub:** https://github.com/diazrenan/unifaat-devops-portfolio
- **Pasta:** `aula-03/`

## Evidências

- [x] `providers.tf` com provider AWS configurado
- [x] `main.tf` com usuários, grupos e memberships
- [x] `policies.tf` com as políticas IAM customizadas
- [x] `roles.tf` com Service Role e Instance Profile para EC2
- [x] `variables.tf` e `outputs.tf` configurados
- [x] `terraform-plan-output.txt` contendo a evidência do `terraform plan`
- [x] `README.md` com a documentação do projeto
- [x] `.gitignore` configurado para impedir o versionamento do Terraform State

## Estrutura IAM implementada

A configuração Terraform implementa a estrutura solicitada na atividade:

- `6325033-technova-developers`
- `6325033-technova-platform-eng`
- `6325033-juliana-dev`
- `6325033-rafael-platform`
- `6325033-lucas-intern`
- `6325033-technova-s3-read`
- `6325033-technova-ec2-s3-full`
- `6325033-technova-deny-destructive`
- `6325033-technova-ec2-role`
- `6325033-technova-ec2-profile`

## Evidência do Terraform Plan

O comando `terraform plan` foi executado com sucesso.

Resultado:

```text
Plan: 16 to add, 0 to change, 0 to destroy.