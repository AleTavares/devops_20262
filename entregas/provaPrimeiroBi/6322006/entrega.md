# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Rafael Nogueira Maruca  
**RA:** 6322006  
**Data:** 01/10/2026
**Ferramenta de IA utilizada:** Claude (Claude Code — modelo Claude Opus 5.5, Anthropic)

## Repositório do Projeto

- URL: https://github.com/rafadical/prova-primeiro-bimestre-devops

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

Arquivos completos e prints em [`evidencias/`](https://github.com/rafadical/prova-primeiro-bimestre-devops/tree/main/evidencias). Os blocos abaixo são **linhas copiadas sem edição** desses arquivos (trechos selecionados).

### Git — Conventional Commits, feature branches e merge --no-ff (`git-log.txt`)

```text
## $ git rev-list --count main
43
## $ git log main --format=%s | grep -vcE "^(feat|fix|docs|chore|refactor|test|style|ci|build|perf)(\(.+\))?: "   (commits fora do padrão)
0
## $ git log main --merges --oneline
21cad05 chore: merge da feature/relatorio-formatacao na main
0083dc9 chore: merge da feature/historico-final na main
1c6ac78 chore: merge da feature/ajustes-auditoria na main
6cccba5 chore: merge da feature/documentacao na main
502a457 chore: merge da feature/infra-terraform na main
8520941 chore: merge da feature/api-reservas na main
## $ git log main --graph --oneline
*   8520941 chore: merge da feature/api-reservas na main
|\  
| * 7ecd832 docs: adiciona evidência do docker compose ps
| * b678a7b feat: adiciona Docker Compose com API e PostgreSQL
| * cf6e9cb docs: adiciona evidências de build e execução do container
| * 93a505f feat: adiciona Dockerfile multi-stage com usuário não-root
| * eb7002a feat: implementa CRUD de reservas e health check
| * 24f0dcd feat: adiciona conexão com PostgreSQL e criação da tabela reservas
| * 396e93a chore: inicializa projeto Node da API com express e pg
|/  
* c8d5b07 docs: adiciona README com nome, RA e descrição do projeto
* ec42ede chore: adiciona .gitignore para Node, Terraform e segredos
```

### Docker — build e execução como usuário não-root (`docker-build.txt`, `docker-run.txt`)

```text
# Exit code do docker build: 0
IMAGE              ID             DISK USAGE   CONTENT SIZE   EXTRA
api-reservas:1.0   6c8773053d29        200MB         49.2MB        
$ docker exec api-reservas-teste whoami
node
## curl http://localhost:3001/health
{"status":"healthy","banco":"conectado","uptime":6.827179598}  [HTTP 200]
```

### docker compose — ambiente local, CRUD e persistência após down/up (`compose-ps.txt`)

```text
## $ docker compose ps
NAME           IMAGE                                COMMAND                  SERVICE    CREATED          STATUS                    PORTS
reservas-api   prova-primeiro-bimestre-devops-api   "docker-entrypoint.s…"   api        41 seconds ago   Up 34 seconds (healthy)   0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
reservas-db    postgres:15-alpine                   "docker-entrypoint.s…"   postgres   41 seconds ago   Up 40 seconds (healthy)   5432/tcp
volume: prova-primeiro-bimestre-devops_pgdata (driver local)
rede: prova-primeiro-bimestre-devops_reservas-net (driver bridge)
{"id":4,"cliente":"Evidencia Local","data":"2026-12-10","status":"pendente"}  [HTTP 201]
$ GET /reservas/4  (mesmo registro, após down + up)
{"id":4,"cliente":"Evidencia Local","data":"2026-12-11","status":"confirmada"}  [HTTP 200]
```

### terraform validate e plan (`terraform-validate.txt`, `terraform-plan.txt`)

```text
Success! The configuration is valid.
Success! The configuration is valid.
Plan: 15 to add, 0 to change, 0 to destroy.
```

### API na EC2 gravando no RDS — AWS Academy Learner Lab, us-east-1 (`aws-api-rds.txt`)

```text
api_url = "http://3.84.136.24:3000"
ec2_public_ip = "3.84.136.24"
rds_endpoint = "technova-dev-db.cjgxolbvplbe.us-east-1.rds.amazonaws.com:5432"
{"id":3,"cliente":"Evidencia AWS","data":"2026-11-10","status":"pendente"}  [HTTP 201]
{"erro":"Reserva não encontrada"}  [HTTP 404]
 10.0.3.250      | reservas         | PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC) 12.4.0, 64-bit
|  Classe      |  db.t3.micro                   |
|  Encriptado  |  True                          |
|  Publico     |  False                         |
|  0    |  5432  |  sg-01684f963abcb7052   |
## EC2 (LabInstanceProfile, sem IAM criado)
|  Perfil|  arn:aws:iam::211973601530:instance-profile/LabInstanceProfile   |
2026-10-01 00:13:03      38916 terraform.tfstate
versionamento: Enabled | encriptação: AES256
```

### terraform destroy (`terraform-destroy.txt`)

```text
Apply complete! Resources: 0 added, 0 changed, 15 destroyed.
Apply complete! Resources: 0 added, 0 changed, 5 destroyed.
bucket technova-6322006-tfstate-a6e6b7ad existe: NAO
tabela technova-6322006-terraform-locks existe: NAO
VPCs (tag Owner=6322006): 0
EC2 ativas (tag Owner=6322006): 0
RDS instances: 0
Security Groups technova-dev-*: 0
terraform state list (infra/): vazio — verificado logo após o destroy da infra principal, antes de remover o bucket (o state remoto deixou de existir junto com o bucket)
terraform state list (infra/backend/): 0 recursos
```
