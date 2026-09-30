# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Denise Macedo
**RA:** 6325028
**Data:** 2026-09-21

## Repositório

- URL: https://github.com/Denisemayder/unifaat-devops-portfolio

## Evidências

- [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [x] Volume nomeado configurado para PostgreSQL
- [x] Rede customizada conectando todos os serviços
- [x] Healthchecks configurados
- [x] Variáveis de ambiente via `.env` (não hardcoded)
- [x] `ia-analise.md` preenchido com reflexão crítica

## Evidência do Ambiente Rodando

```
NAME                IMAGE                COMMAND                  SERVICE    CREATED              STATUS                        PORTS
technova-api        aula-02-api          "docker-entrypoint.s…"   api        About a minute ago   Up About a minute             0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
technova-postgres   postgres:15-alpine   "docker-entrypoint.s…"   postgres   About a minute ago   Up About a minute (healthy)   5432/tcp
technova-redis      redis:7-alpine       "docker-entrypoint.s…"   redis      About a minute ago   Up About a minute (healthy)   6379/tcp

API Response:
{"servico":"TechNova API - Aula 02 TF","aluno":"Denise Macedo","ra":"6325028","status":"online","banco":"postgres:5432/technova","cache":"redis:6379","timestamp":"2026-09-21T22:56:57.848Z"}

Health:
{"status":"healthy","uptime":88.87,"servicos":{"api":"online","banco":"postgres:5432","cache":"redis:6379"}}
```
