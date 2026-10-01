# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Pablo Augusto  
**RA:** 6325076  
**Data:** 01/10/2026  
**Ferramenta de IA utilizada:** ChatGPT

## Repositório do Projeto

- URL: https://github.com/Pablao02/prova-primeiro-bimestre-devops

## Checklist de Evidências

- [x] Repositório público com README (nome + RA) e .gitignore
- [x] Mínimo de 6 commits com Conventional Commits + feature branch
- [x] API com CRUD completo de reservas (POST, GET, GET/:id, PUT, DELETE) + /health
- [x] Rotas de CRUD gravando no banco PostgreSQL (não em memória)
- [x] Dockerfile funcional
- [x] docker-compose.yml (API + PostgreSQL) subindo com um comando
- [x] Terraform modularizado (vpc, security-group, ec2, rds)
- [x] RDS PostgreSQL provisionado nas subnets privadas
- [x] Remote State (S3 + DynamoDB)
- [x] Uso de LabRole/LabInstanceProfile
- [x] terraform validate e terraform plan sem erros
- [x] relatorio.md completo (4 questões)
- [x] terraform destroy executado após evidências

## Evidências

### Docker Compose

- evidencias/compose-config.txt
- evidencias/compose-ps.txt
- evidencias/docker-build.txt

### API no AWS

- evidencias/aws-health.txt
- evidencias/aws-post.txt
- evidencias/aws-get.txt
- evidencias/aws-get-id.txt
- evidencias/aws-put.txt
- evidencias/aws-get-after-delete.txt

### Terraform

- evidencias/terraform-validate.txt
- evidencias/terraform-plan.txt

### Relatório

- elatorio.md

## Observações

A infraestrutura AWS foi utilizada durante a realização das evidências e posteriormente destruída com 	erraform destroy, conforme solicitado na prova.

O projeto completo, incluindo código da API, Docker, Docker Compose, Terraform, evidências e relatório, está disponível no repositório informado acima.
