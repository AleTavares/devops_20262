# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Sirlande Martins  
**RA:** 6325269  
**Data:** 01/10/2026  
**Ferramenta de IA utilizada:** Claude (Opus 5.5), descrita no `relatorio.md`

## Repositório do Projeto

- URL: https://github.com/Sir-Jr/prova-primeiro-bimestre-devops

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

Todas as saídas completas, a spec, o registro de prompts e as capturas de tela estão em
[`evidencias/`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/tree/main/evidencias)
(índice em [`evidencias/README.md`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/README.md)).
Abaixo, onde está cada item do checklist e trechos das saídas principais.

### Onde está cada item

| Item do checklist | Evidência no repositório |
|---|---|
| Repositório público com README e `.gitignore` | [`README.md`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/README.md) (nome e RA nas linhas 3–4), [`.gitignore`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/.gitignore) |
| 6+ commits com Conventional Commits + feature branch | `main` com 39 commits e 9 merges `--no-ff`; branches `feat/api`, `feat/docker`, `feat/compose`, `feat/infra`, `docs/relatorio`, `docs/revisao-final`, `docs/registro-prompts` ([commits](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/commits/main)) |
| CRUD completo + `/health` | [`app/src/routes/reservas.js`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/app/src/routes/reservas.js), [`app/src/app.js`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/app/src/app.js); testes em [`curl-local.txt`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/curl-local.txt) e [`curl-aws.txt`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/curl-aws.txt) |
| CRUD gravando no PostgreSQL | [`app/src/db.js`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/app/src/db.js) (driver `pg`); persistência após `docker compose down`/`up` em [`compose-ps.txt`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/compose-ps.txt); reserva gravada no RDS em [`curl-aws.txt`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/curl-aws.txt) e na imagem 11 |
| Dockerfile funcional | [`app/Dockerfile`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/app/Dockerfile); build, usuário não-root e healthcheck em [`docker-build.txt`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/docker-build.txt) |
| `docker-compose.yml` subindo com um comando | [`docker-compose.yml`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/docker-compose.yml); [`compose-ps.txt`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/compose-ps.txt) |
| Terraform modularizado | [`infra/modules/`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/tree/main/infra/modules) (`vpc`, `security-group`, `ec2`, `rds`), composição em [`infra/main.tf`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/infra/main.tf) |
| RDS PostgreSQL nas subnets privadas | [`rds-describe.txt`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/rds-describe.txt); imagens 02, 03, 04 e 06 |
| Remote state (S3 + DynamoDB) | [`infra/backend/`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/tree/main/infra/backend), [`infra/providers.tf`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/infra/providers.tf); [`terraform-backend.txt`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/terraform-backend.txt); imagens 08–10 |
| LabRole/LabInstanceProfile, sem IAM próprio | nenhum recurso `aws_iam_*` no código; EC2 recebe o instance profile pela variável `iam_instance_profile`, com default `"LabInstanceProfile"` ([`infra/variables.tf`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/infra/variables.tf)) |
| `terraform validate` e `plan` sem erros | [`terraform-plan.txt`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/terraform-plan.txt) |
| `relatorio.md` completo | [`relatorio.md`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/relatorio.md) (4 questões) |
| `terraform destroy` após as evidências | [`terraform-destroy.txt`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/terraform-destroy.txt) |

### docker compose ps (ambiente local)

Trecho de [`compose-ps.txt`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/compose-ps.txt):

```
$ docker compose ps
NAME                    IMAGE                   COMMAND                  SERVICE   CREATED          STATUS                    PORTS
technova-reservas-api   technova-reservas:1.0   "docker-entrypoint.s…"   api       25 seconds ago   Up 20 seconds (healthy)   0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
technova-reservas-db    postgres:16-alpine      "docker-entrypoint.s…"   db        26 seconds ago   Up 25 seconds (healthy)   5432/tcp
```

### terraform validate e terraform plan

Trecho de [`terraform-plan.txt`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/terraform-plan.txt):

```
$ terraform init
Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

$ terraform fmt -check -recursive && terraform validate
Success! The configuration is valid.

$ terraform plan -out=infra.tfplan
(...)
Plan: 19 to add, 0 to change, 0 to destroy.
```

### Smoke test da API na EC2 (gravando no RDS)

Trecho de [`curl-aws.txt`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/curl-aws.txt):

```
OK    GET /health                                           200
OK    POST /reservas (válida, sem status)                   201
OK    POST /reservas (sem campos obrigatórios)              400
OK    POST /reservas (data inexistente 2026-02-30)          400
OK    POST /reservas (status inválido)                      400
OK    POST /reservas (sem Content-Type JSON)                400
OK    GET /reservas (lista)                                 200
OK    GET /reservas/1                                       200
OK    GET /reservas/abc (id inválido)                       404
OK    GET /reservas/2147483647 (inexistente)                404
OK    PUT /reservas/1 (sem status: mantém o atual)          200
OK    PUT /reservas/1 (status confirmada)                   200
OK    PUT /reservas/1 (sem data)                            400
OK    PUT /reservas/2147483647 (inexistente)                404
OK    DELETE /reservas/1                                    204
OK    GET /reservas/1 (após DELETE)                         404
OK    DELETE /reservas/1 (de novo)                          404

Resultado: 17/17 casos OK
```

### RDS privado e encriptado

Trecho de [`rds-describe.txt`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/rds-describe.txt):

```
(...)
    "Engine": "postgres",
    "Version": "16.13",
    "Class": "db.t3.micro",
    "PubliclyAccessible": false,
    "StorageEncrypted": true,
    "MultiAZ": false,
    "Endpoint": "technova-reservas-prova-db.c36miak0ksqa.us-east-1.rds.amazonaws.com",
    "Port": 5432,
    "SubnetGroup": "technova-reservas-prova-db-subnet-group",
(...)
```

### terraform destroy

Trecho de [`terraform-destroy.txt`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/terraform-destroy.txt):

```
Apply complete! Resources: 0 added, 0 changed, 19 destroyed.
```

### Capturas de tela

Console AWS e navegador durante a execução de 30/09/2026, em
[`evidencias/imagens/`](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/tree/main/evidencias/imagens)
(descrição de cada uma no [índice das evidências](https://github.com/Sir-Jr/prova-primeiro-bimestre-devops/blob/main/evidencias/README.md#imagens--imagens)).
