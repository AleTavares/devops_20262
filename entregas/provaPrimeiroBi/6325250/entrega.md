# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Fábio Panosian
**RA:** 6325250
**Data:** 01/10/2026
**Ferramenta de IA utilizada:** ChatGPT

## Repositório do Projeto

* URL: https://github.com/fabiopanosian-droid/prova-primeiro-bimestre-devops

## Checklist de Evidências

* [x] Repositório público com README (nome + RA) e .gitignore
* [x] Mínimo de 6 commits com Conventional Commits + feature branch
* [x] API com **CRUD completo** de reservas (POST, GET, GET/:id, PUT, DELETE) + /health
* [x] Rotas de CRUD gravando no **banco PostgreSQL** (não em memória)
* [x] Dockerfile funcional da API de Reservas
* [x] docker-compose.yml (API + PostgreSQL) subindo com um comando
* [x] Terraform modularizado (vpc, security-group, ec2, rds)
* [x] **RDS PostgreSQL provisionado** nas subnets privadas (banco da API na nuvem)
* [x] Remote State configurado (S3 + DynamoDB)
* [x] Uso de LabRole/LabInstanceProfile (sem criar IAM próprio)
* [x] terraform validate e terraform plan sem erros
* [x] relatorio.md completo (4 questões)
* [x] terraform destroy executado após evidências

## Evidências

As evidências estão disponíveis no repositório do projeto, no diretório `evidencias/`.

* Evidência do build e execução do Docker
* Evidência do Docker Compose
* Evidência dos testes da API na AWS
* Evidência do Terraform Plan
* Evidência do Remote State
* Evidência do CRUD completo da API
