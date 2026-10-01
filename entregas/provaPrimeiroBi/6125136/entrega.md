# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Hector Marcelo Pedroso dos Santos
**RA:** 6125136
**Data:** 01/10/2026
**Ferramenta de IA utilizada:** Claude (via Claude Code)

---

## Repositório do Projeto

- **URL:** https://github.com/hectorbackfront/prova-primeiro-bimestre-devops

---

## Checklist de Evidências

- [x] Repositório público no GitHub (`prova-primeiro-bimestre-devops`)
- [x] README.md com nome, RA e descrição do projeto
- [x] .gitignore adequado (node_modules, .env, .terraform, *.tfstate, *.pem)
- [x] Mínimo 6 commits com Conventional Commits (`feat:`, `docs:`, `fix:`, `chore:`)
- [x] Feature branch + merge (evidência de workflow Git)
- [x] API Node.js/Express com **CRUD completo** de reservas
  - [x] POST /reservas (Create)
  - [x] GET /reservas (Read List)
  - [x] GET /reservas/:id (Read One)
  - [x] PUT /reservas/:id (Update)
  - [x] DELETE /reservas/:id (Delete)
  - [x] GET /health (Health Check)
- [x] Rotas de CRUD gravando no **banco PostgreSQL** (não em memória)
- [x] Dockerfile funcional (multi-stage, usuário não-root)
- [x] .dockerignore configurado
- [x] docker-compose.yml (API + PostgreSQL) subindo com um comando
- [x] Volume nomeado para persistência do banco
- [x] Rede bridge customizada no Compose
- [x] Healthcheck no PostgreSQL
- [x] .env.example versionado (sem senhas reais)
- [x] .env no .gitignore
- [x] Terraform modularizado
  - [x] Módulo VPC (2 subnets públicas + 2 privadas, 2 AZs)
  - [x] Módulo Security Groups (EC2 e RDS com menor privilégio)
  - [x] Módulo EC2 (t2.micro, subnet pública, instance profile LabInstanceProfile)
  - [x] Módulo RDS (PostgreSQL db.t3.micro, subnets privadas, storage_encrypted=true, publicly_accessible=false)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] main.tf com composição dos modules
- [x] variables.tf, outputs.tf, providers.tf configurados
- [x] terraform validate sem erros
- [x] terraform plan executado com sucesso
- [x] terraform apply executado no AWS Academy Learner Lab
- [x] Uso de LabRole/LabInstanceProfile (sem criar IAM próprio)
- [x] Evidências capturadas (outputs/screenshots)
  - [x] docker compose ps
  - [x] terraform plan output
  - [x] EC2 rodando com API
  - [x] RDS endpoint funcional
- [x] relatorio.md completo (4 questões, 10+ linhas cada)
- [x] terraform destroy executado (limpeza)
- [x] Todos os commits com histórico Git limpo

---

## Evidências

### Docker Build + Run (container standalone)

```
docker build -t reservas-api . → build multi-stage concluído sem erro
docker exec reservas-api-test whoami → appuser (não-root)
docker inspect reservas-api-test → Health: healthy
curl /health → {"status":"ok"} [HTTP 200]
curl POST /reservas → {"id":2,...} [HTTP 201]
```
(output completo em `evidencias/docker-build.txt`)

### Docker Compose

```
docker compose ps
NAME                IMAGE                STATUS                    PORTS
reservas-api        reservas-api         Up 19 seconds (healthy)   0.0.0.0:3000->3000/tcp
reservas-postgres   postgres:15-alpine   Up 25 seconds (healthy)   0.0.0.0:5433->5432/tcp

curl /health → {"status":"ok"} [HTTP 200]
curl POST /reservas → {"id":2,"cliente":"Compose Evidencia",...} [HTTP 201]
curl GET /reservas → [{"id":1,...},{"id":2,...}] [HTTP 200]
```
(output completo em `evidencias/compose-ps.txt`)

### Terraform Plan

```
Plan: 17 to add, 0 to change, 0 to destroy.
Changes to Outputs:
  + api_url       = (known after apply)
  + ec2_public_ip = (known after apply)
  + rds_endpoint  = (known after apply)
```
(output completo em `evidencias/terraform-plan.txt`)

### Terraform Apply + API rodando na AWS

```
Apply complete! Resources: 17 added, 0 changed, 0 destroyed.

Outputs:
api_url       = "http://13.220.223.155:3000"
ec2_public_ip = "13.220.223.155"
rds_endpoint  = "reservas-db.c0nku9luxy40.us-east-1.rds.amazonaws.com:5432"

curl /health → {"status":"ok"} [HTTP 200]
curl POST /reservas → {"id":2,"cliente":"Evidencia Final",...} [HTTP 201]
curl GET /reservas → dado persistido de fato no RDS [HTTP 200]
```
(output completo em `evidencias/aws-api-crud.txt`; `terraform destroy` executado
depois de capturar as evidências, nada ficou rodando na AWS)

---

## Links Úteis

- Repositório do projeto: https://github.com/hectorbackfront/prova-primeiro-bimestre-devops
- Commits: https://github.com/hectorbackfront/prova-primeiro-bimestre-devops/commits/main
- Relatório completo: https://github.com/hectorbackfront/prova-primeiro-bimestre-devops/blob/main/relatorio.md

---

## Notas

- Prova entregue via Pull Request no repositório da disciplina
- Pasta: `entregas/provaPrimeiroBi/6125136/`
- Arquivo: `entrega.md` (este)
- Data de abertura do PR: dia da prova (presencialmente)
