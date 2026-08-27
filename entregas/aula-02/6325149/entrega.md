# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 20/08/2026

## Repositório

- URL: https://github.com/gabrielreis354/unifaat-devops-portfolio
- Branch: `main` (feature `feature/aula-02-compose` mergeada)
- Pasta da atividade: `aula-02/`

## Evidências

- [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [x] Volume nomeado configurado para PostgreSQL
- [x] Rede customizada conectando todos os serviços
- [x] Healthchecks configurados
- [x] Variáveis de ambiente via `.env` (não hardcoded)
- [x] `ia-analise.md` preenchido com reflexão crítica

## Evidência do Ambiente Rodando

### `docker compose ps` (3 serviços saudáveis)

```
NAME                IMAGE                STATUS                    PORTS
technova_api        aula-02-api          Up 6 seconds (healthy)    0.0.0.0:3000->3000/tcp
technova_postgres   postgres:15-alpine   Up 13 seconds (healthy)   0.0.0.0:5432->5432/tcp
technova_redis      redis:7-alpine       Up 13 seconds (healthy)   0.0.0.0:6379->6379/tcp
```

### Resposta da API — `GET http://localhost:3000/health`

```json
{"status":"healthy","uptime":6.68,"servicos":{"api":"online","banco":"postgres:5432","cache":"redis:6379"}}
```

> Os valores `postgres:5432` e `redis:6379` foram resolvidos a partir do `.env`,
> comprovando a interpolação de variáveis (nada hardcoded no compose).

### Volume nomeado (persistência do PostgreSQL)

```
local     aula-02_postgres_data
```

Persistência validada: criação de tabela + inserção sobreviveram no volume
(dados só são removidos com `docker compose down -v`).

### Rede bridge customizada

```
rede=aula-02_app-network  driver=bridge  containers=technova_postgres technova_redis technova_api
```

Os 3 serviços estão conectados na mesma rede bridge customizada.

## Mapeamento dos requisitos → docker-compose.yml

| Requisito | Como foi atendido |
|-----------|-------------------|
| API Node.js 20 / Express na porta 3000 | serviço `api` com `build: .` (Dockerfile local) |
| PostgreSQL 15 com volume nomeado | `postgres:15-alpine` + volume `postgres_data` |
| Redis 7 como cache | `redis:7-alpine` |
| Rede bridge customizada | `app-network` (driver bridge) nos 3 serviços |
| Interpolação de `.env` (não hardcoded) | `${PORT}`, `${POSTGRES_USER}`, `${DB_HOST}`, etc. |
| `depends_on` com condição | `condition: service_healthy` (API só sobe após Postgres/Redis healthy) |
| Healthchecks | `pg_isready` (Postgres), `redis-cli ping` (Redis), `wget /health` (API) |
| `restart: unless-stopped` | aplicado nos 3 serviços |
| Comentários explicativos | presentes em cada seção do arquivo |

## Uso de IA (copiloto)

Análise crítica completa em `aula-02/ia-analise.md`, incluindo o prompt utilizado,
o output original da IA (preservado como baseline no commit `7709c20`), as correções
manuais aplicadas (interpolação de variáveis do `.env`) e a avaliação do resultado.

### Histórico git da atividade

```
a44381b  feat(aula-02): adiciona ambiente Docker Compose com 3 serviços
82ae514  refactor(aula-02): interpola variaveis do .env no docker-compose
7709c20  feat(aula-02): adiciona stack docker-compose Node.js + PostgreSQL + Redis (baseline da IA)
```
