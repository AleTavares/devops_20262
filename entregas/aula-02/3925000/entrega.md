# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** CAROLLINI GODOY  
**RA:** 3925000 
**Data:** 26/08/2026

## Repositório

- URL: https://github.com/caroll143/unifaat-devops-portfolio.git

## Evidências

- [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [x] Volume nomeado configurado para PostgreSQL
- [x] Rede customizada conectando todos os serviços
- [x] Healthchecks configurados
- [x] Variáveis de ambiente via `.env` (não hardcoded)
- [x] `ia-analise.md` preenchido com reflexão crítica

## Evidência do Ambiente Rodando

O ambiente foi executado com sucesso utilizando Docker Compose.

Resultado do comando `docker compose ps`:

```text
NAME                 IMAGE                COMMAND                  SERVICE    CREATED              STATUS                        PORTS
aula-02-api-1        aula-02-api          "docker-entrypoint.s…"   api        About a minute ago   Up 46 seconds (healthy)       0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
aula-02-postgres-1   postgres:15-alpine   "docker-entrypoint.s…"   postgres   About a minute ago   Up About a minute (healthy)   5432/tcp
aula-02-redis-1      redis:7-alpine       "docker-entrypoint.s…"   redis      About a minute ago   Up About a minute (healthy)   6379/tcp
```
