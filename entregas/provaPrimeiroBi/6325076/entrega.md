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

As evidências estão documentadas no repositório do projeto, incluindo:

- Configuração e execução do Docker Compose
- Status dos containers
- Build da imagem Docker
- Testes do CRUD local e na AWS
- Teste do endpoint /health
- Terraform validate
- Terraform plan
- Infraestrutura AWS provisionada
- Infraestrutura AWS destruída após as evidências
