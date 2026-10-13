# Entrega — Aula 06: Terraform Modules

**Aluno:** Emar Cristian Silva Teruo Ito  
**RA:** 6325192  
**Data:** 27/09/2026

## Repositório

- URL: https://github.com/iHawlKz7/unifaat-devops-portfolio
- Projeto: `aula-06/`

## Evidências

- [x] Módulo VPC criado
- [x] Módulo Security Group criado
- [x] Módulo EC2 criado
- [x] Módulo RDS criado
- [x] Cada módulo possui `main.tf`, `variables.tf` e `outputs.tf`
- [x] Subnets criadas de forma reutilizável com `for_each`
- [x] Security Group implementado como módulo reutilizável
- [x] Composição entre módulos utilizando outputs como inputs
- [x] Ambiente `dev` criado
- [x] Ambiente `staging` criado
- [x] `terraform init` executado com sucesso em DEV e STAGING
- [x] `terraform validate` executado com sucesso em DEV e STAGING
- [x] `terraform plan` executado com sucesso em DEV e STAGING
- [x] README da Aula 06 com documentação dos módulos, inputs, outputs, arquitetura e ambientes

## Observação

A infraestrutura foi organizada em módulos Terraform reutilizáveis e utilizada por dois ambientes independentes: DEV e STAGING.

Não foi necessário executar `terraform apply` para a validação desta atividade.
