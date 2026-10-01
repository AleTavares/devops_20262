# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Guilherme Alvisi  
**RA:** 6325197  
**Data:** 01/10/2026  
**Ferramenta de IA utilizada:** ChatGPT

## Repositório do Projeto

- URL: https://github.com/guialvisi/prova-primeiro-bimestre-devops

## Checklist de Evidências

- [x] Repositório público com README (nome + RA) e .gitignore
- [x] Mínimo de 6 commits com Conventional Commits + feature branch
- [x] API com CRUD completo de reservas (POST, GET, GET/:id, PUT, DELETE) + /health
- [x] Rotas de CRUD gravando no banco PostgreSQL
- [x] Dockerfile funcional da API de Reservas
- [x] docker-compose.yml (API + PostgreSQL)
- [x] Terraform modularizado (vpc, security-group, ec2, rds)
- [x] RDS PostgreSQL configurado nas subnets privadas
- [x] Remote State configurado (S3 + DynamoDB)
- [x] Uso de LabRole/LabInstanceProfile
- [x] terraform validate e terraform plan validados
- [x] relatorio.md completo com as 4 questões
- [x] Evidências registradas no repositório
- [x] terraform destroy executado após a captura das evidências

## Evidências

As evidências da execução do projeto estão disponíveis no diretório `evidencias/` do repositório principal:

- Build da imagem Docker
- Execução do Docker Compose
- Healthcheck da API e PostgreSQL
- Terraform Plan
- Evidências da infraestrutura AWS

O relatório completo do processo está disponível no arquivo `relatorio.md` do repositório principal.
