# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Yuri batista sanches
**RA:** 6325238
**Data:** 20/08/2026

## Repositório

* URL: https://github.com/Dooooc/unifaat-devops-portfolio

## Evidências

* [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
* [x] Volume nomeado configurado para PostgreSQL
* [x] Rede customizada conectando todos os serviços
* [x] Healthchecks configurados
* [x] Variáveis de ambiente via `.env` (não hardcoded)
* [x] `ia-analise.md` preenchido com reflexão crítica

## Evidência do Ambiente Rodando

CONTAINER ID   IMAGE                COMMAND                  CREATED          STATUS                    PORTS                    NAMES
562186bbe384   aula-02-api          "docker-entrypoint.s…"   10 seconds ago   Up 4 seconds              0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp   app_api
ebc943caa1b4   postgres:15-alpine   "docker-entrypoint.s…"   11 seconds ago   Up 10 seconds (healthy)   5432/tcp                    app_postgres
f87dd7a698fd   redis:7-alpine       "docker-entrypoint.s…"   11 seconds ago   Up 10 seconds (healthy)   6379/tcp                    app_redis