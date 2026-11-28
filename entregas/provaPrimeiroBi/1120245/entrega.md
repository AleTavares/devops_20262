# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 2026-10-01  
**Ferramenta de IA utilizada:** Kiro (Spec-Driven Development)

## Repositório do Projeto

- URL: https://github.com/Manntto/prova-primeiro-bimestre-devops

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

As evidências estão organizadas em `evidencias/screenshots/` no repositório do projeto.

| Print | Arquivo | O que mostra |
|-------|---------|-------------|
| Git | `GIT HISTORICO.png` | 13 commits, Conventional Commits, feature branches com merge |
| Docker Build | `DOCKER_IMAGEM.png` | Imagem `api-reservas:1.0` multi-stage, usuário não-root |
| Docker Compose | `DOCKER_PS.png` | `reservas-api` Up + `reservas-db` **(healthy)** |
| API /health | `API_HEALTH.png` | `{"status":"ok"}` na porta 3000 |
| API CRUD | `API_CRUD.png` | POST, GET, PUT, DELETE + 404 após delete |
| API AWS | `API_AWS.png` | CRUD completo rodando na EC2 contra RDS |
| Terraform módulos | `TERRAFORM_MODULOS.png` | Pastas `vpc`, `security-group`, `ec2`, `rds` |
| Terraform validate | `TERRAFORM_VALIDADE.png` | `Success! The configuration is valid.` |
| Terraform plan | `TERRAFORM_PLAN.png` | `Plan: 14 to add, 0 to change, 0 to destroy` |
| Terraform outputs | `TERRAFORM_OUTPUTS.png` | IP da EC2, endpoint do RDS, URL da API |
| Terraform destroy | `TERRAFORM_DESTROY.png` | `Destroy complete! Resources: 14 destroyed.` |

### Terraform Outputs — AWS

```
api_url        = "http://54.234.242.166:3000"
ec2_public_ip  = "54.234.242.166"
ec2_public_dns = "ec2-54-234-242-166.compute-1.amazonaws.com"
rds_endpoint   = "reservas-rds.cpmnqfiwmifd.us-east-1.rds.amazonaws.com:5432"
rds_host       = "reservas-rds.cpmnqfiwmifd.us-east-1.rds.amazonaws.com"
```

### API CRUD — Ambiente Local (Docker Compose + PostgreSQL)

```
GET  /health  → {"status":"ok","timestamp":"2026-10-01T16:53:46.433Z"}
POST /reservas → {"id":5,"cliente":"Matheus Mantovani","data":"2026-10-01T00:00:00.000Z","status":"confirmada"}
GET  /reservas → [{"id":4,...},{"id":5,...},{"id":6,...}]
GET  /reservas/5 → {"id":5,"cliente":"Matheus Mantovani",...}
PUT  /reservas/6 → {"id":6,...,"status":"confirmada"}
DELETE /reservas/5 → {"mensagem":"Reserva removida com sucesso.",...}
GET  /reservas/5 (após delete) → {"erro":"Reserva não encontrada."} HTTP 404
```

### API CRUD — AWS (EC2 + RDS PostgreSQL)

```
GET  /health  → {"status":"ok"}
POST /reservas → {"id":1,"cliente":"Matheus Mantovani","data":"2026-10-01","status":"confirmada"}
GET  /reservas → [{"id":1,...},{"id":2,...}]
GET  /reservas/1 → {"id":1,"cliente":"Matheus Mantovani",...}
PUT  /reservas/2 → {"id":2,...,"status":"confirmada"}
DELETE /reservas/1 → {"mensagem":"Reserva removida com sucesso.",...}
GET  /reservas/1 (após delete) → {"erro":"Reserva não encontrada."} HTTP 404
```
