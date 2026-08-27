# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Sirlande Martins
**RA:** 6325269
**Data:** 23/08/2026

## Repositório

- URL: https://github.com/Sir-Jr/unifaat-devops-portfolio

## Evidências

- [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [x] Volume nomeado configurado para PostgreSQL
- [x] Rede customizada conectando todos os serviços
- [x] Healthchecks configurados
- [x] Variáveis de ambiente via `.env` (não hardcoded)
- [x] `ia-analise.md` preenchido com reflexão crítica

## Evidência do Ambiente Rodando

```
$ docker compose up -d --build
 Network aula-02_technova-network  Created
 Container technova-db             Started
 Container technova-cache          Started
 Container technova-db             Healthy
 Container technova-cache          Healthy
 Container technova-api            Started

$ docker compose ps
NAME             IMAGE                COMMAND                  SERVICE    STATUS                    PORTS
technova-api     aula-02-api          "docker-entrypoint.s…"   api        Up 7 seconds              0.0.0.0:3000->3000/tcp
technova-cache   redis:7-alpine       "docker-entrypoint.s…"   redis      Up 18 seconds (healthy)   0.0.0.0:6379->6379/tcp
technova-db      postgres:15-alpine   "docker-entrypoint.s…"   postgres   Up 18 seconds (healthy)   0.0.0.0:5432->5432/tcp

$ curl http://localhost:3000/health
{"status":"healthy","uptime":7.25,"servicos":{"api":"online","banco":"online","cache":"online"}}
```

O arquivo completo do ambiente (`docker-compose.yml`, `app/`, `ia-analise.md`) está versionado em
[`aula-02/`](https://github.com/Sir-Jr/unifaat-devops-portfolio/tree/main/aula-02).
