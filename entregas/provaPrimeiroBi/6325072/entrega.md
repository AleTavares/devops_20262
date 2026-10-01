# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Leandro Duarte
**RA:** 6325072
**Data:** 2026-10-01
**Ferramenta de IA utilizada:** Kiro (Spec-Driven Development)

## Repositório do Projeto

- URL: https://github.com/leandrotadeu210-cmyk/prova-primeiro-bimestre-devops

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

### docker compose ps
```
NAME           IMAGE                                SERVICE   STATUS                  PORTS
reservas_api   prova-primeiro-bimestre-devops-api   api       Up (healthy)            0.0.0.0:3000->3000/tcp
reservas_db    postgres:15-alpine                   db        Up (healthy)            5432/tcp
```

### GET /health
```
status  timestamp
------  ---------
ok      2026-09-29T00:11:08.548Z
```

### POST /reservas (criar reserva)
```
id        : 1
cliente   : Leandro Duarte
data      : 2026-10-01T14:00:00.000Z
status    : confirmada
criado_em : 2026-09-29T00:11:15.326Z
```

### GET /reservas (listar)
```
id        : 1
cliente   : Leandro Duarte
data      : 2026-10-01T14:00:00.000Z
status    : confirmada
criado_em : 2026-09-29T00:11:15.326Z
```

### PUT /reservas/1 (atualizar)
```
id        : 1
cliente   : Leandro Duarte
data      : 2026-10-01T14:00:00.000Z
status    : concluida
criado_em : 2026-09-29T00:11:15.326Z
```

### DELETE /reservas/1 (remover)
```
mensagem                      reserva
--------                      -------
Reserva removida com sucesso. @{id=1; cliente=Leandro Duarte; ...}
```
