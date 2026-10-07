# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Denise Maider Batista de Macedo  
**RA:** 6325028  
**Data:** 01/10/2026  
**Ferramenta de IA utilizada:** Kiro e ChatGPT

## Repositório do Projeto

- URL: https://github.com/Denisemayder/prova-primeiro-bimestre-devops

## Checklist de Evidências

- [x] Repositório público com README (nome + RA) e .gitignore
- [x] Mínimo de 6 commits com Conventional Commits + feature branch
- [x] API com CRUD completo de reservas (POST, GET, GET/:id, PUT, DELETE) + /health
- [x] Rotas de CRUD gravando no banco PostgreSQL (não em memória)
- [x] Dockerfile funcional da API de Reservas
- [x] docker-compose.yml (API + PostgreSQL) subindo com um comando
- [x] Terraform modularizado (vpc, security-group, ec2, rds)
- [x] RDS PostgreSQL provisionado nas subnets privadas (banco da API na nuvem)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] Uso de LabRole/LabInstanceProfile (sem criar IAM próprio)
- [x] terraform validate e terraform plan sem erros
- [x] relatorio.md completo
- [x] terraform destroy executado após evidências

## Evidências

As evidências completas estão disponíveis no repositório do projeto, no diretório `evidencias/`.

Foram registradas evidências de:

- build e execução com Docker e Docker Compose;
- execução e funcionamento da API;
- operações CRUD de reservas;
- terraform validate e terraform plan;
- recursos EC2 e RDS provisionados;
- Security Groups;
- backend remoto S3 com versionamento e criptografia;
- DynamoDB utilizado para locking do state;
- execução do terraform destroy;
- utilização do Kiro com Spec-Driven Development.

O processo completo de desenvolvimento, desafios encontrados e utilização de Inteligência Artificial está documentado no arquivo `relatorio.md` do repositório do projeto.
