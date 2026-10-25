    # Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Matheus Maciel de Paula  
**RA:** 6325065  
**Data:** 01/10/2026  
**Ferramenta de IA utilizada:** Claude

## Repositório do Projeto

- URL: https://github.com/mtmaciel1/prova-primeiro-bimestre-devops

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

Todas as evidências completas estão na pasta [`evidencias/`](https://github.com/mtmaciel1/prova-primeiro-bimestre-devops/tree/main/evidencias) do repositório. Trechos principais:

### docker compose ps (ambiente local)

```text
NAME                                        IMAGE                                SERVICE    STATUS                   PORTS
prova-primeiro-bimestre-devops-api-1        prova-primeiro-bimestre-devops-api   api        Up 5 minutes             0.0.0.0:3000->3000/tcp
prova-primeiro-bimestre-devops-postgres-1   postgres:15-alpine                   postgres   Up 6 minutes (healthy)   0.0.0.0:5432->5432/tcp
```

### terraform validate / plan

```text
Success! The configuration is valid.

Plan: 17 to add, 0 to change, 0 to destroy.
```

### API rodando na AWS (EC2 + RDS)

```text
POST   /reservas         -> HTTP/1.1 201 Created
GET    /reservas         -> HTTP/1.1 200 OK
GET    /reservas/1       -> HTTP/1.1 200 OK
PUT    /reservas/1       -> HTTP/1.1 200 OK
POST   /reservas (status inválido) -> HTTP/1.1 400 Bad Request
GET    /reservas/999     -> HTTP/1.1 404 Not Found
DELETE /reservas/1       -> HTTP/1.1 204 No Content
```

### Segurança do RDS (AWS CLI)

```text
|  Classe        |  db.t3.micro                        |
|  Criptografado |  True                               |
|  Engine        |  15.17                              |
|  Publico       |  False                              |
|  SubnetGroup   |  technova-reservas-db-subnet-group  |
```

SG do RDS: porta 5432 liberada apenas para o Security Group da EC2 (`UserIdGroupPairs`), sem nenhum `IpRanges`.

### Remote State no S3

```text
2026-10-01 21:06:30      41710 terraform.tfstate
```

### terraform destroy

```text
Destroy complete! Resources: 17 destroyed.
```
