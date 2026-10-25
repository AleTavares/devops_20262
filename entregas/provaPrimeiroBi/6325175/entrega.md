# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** João Pedro Paulino Ferreira  
**RA:** 6325175  
**Data:** 01/10/2026  
**Ferramenta de IA utilizada:** Kiro e ChatGPT

## Repositório do Projeto

- URL: https://github.com/Joaoz007/prova-primeiro-bimestre-devops

## Checklist de Evidências

- [x] Repositório público com README (nome + RA) e .gitignore
- [x] Mínimo de 6 commits com Conventional Commits + feature branch
- [x] API com **CRUD completo** de reservas (POST, GET, GET/:id, PUT, DELETE) + /health
- [x] Rotas de CRUD gravando no **banco PostgreSQL** (não em memória)
- [x] Dockerfile funcional da API de Reservas
- [x] docker-compose.yml (API + PostgreSQL) subindo com um comando
- [x] Terraform modularizado (vpc, security-group, ec2, rds)
- [x] **RDS PostgreSQL provisionado** nas subnets privadas (banco da API na nuvem)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] Uso de LabRole/LabInstanceProfile (sem criar IAM próprio)
- [x] terraform validate e terraform plan sem erros
- [x] relatorio.md completo (4 questões)
- [x] terraform destroy executado após evidências

## Evidências

As evidências do projeto estão disponíveis no diretório `evidencias/` do repositório.

### Evidências textuais

- `evidencias/docker-build.txt` — build da imagem Docker
- `evidencias/compose-ps.txt` — execução do ambiente Docker Compose
- `evidencias/terraform-plan.txt` — Terraform Plan
- `evidencias/aws-api-crud.txt` — validação da API na AWS
- `evidencias/prompts.txt` — registro dos prompts utilizados durante o desenvolvimento

### Evidências visuais

A pasta `evidencias/prints/` contém registros das principais etapas:

- `01-git-historico.png`
- `02-docker-build.png`
- `04-terraform-plan.png`
- `05-terraform-apply.png`
- `06-aws-recursos.png`
- `07-aws-api-health.png`
- `08-aws-api-crud.png`
- `09-terraform-destroy.png`

### Relatório

O relatório completo da prova está disponível em:

- `relatorio.md`