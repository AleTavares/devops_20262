# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Emilly Santos de Oliveira 
**RA:** 4023575
**Data:** 31/08/2026

## Repositório

- URL: https://github.com/leonidas-alt/unifaat-devops-portfolio.git

## Evidências

- [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [x] Volume nomeado configurado para PostgreSQL
- [x] Rede customizada conectando todos os serviços
- [x] Healthchecks configurados
- [x] Variáveis de ambiente via `.env` (não hardcoded)
- [x] `ia-analise.md` preenchido com reflexão crítica

## Evidência do Ambiente Rodando

CONTAINER ID   IMAGE                COMMAND                  CREATED          STATUS                         PORTS                                         NAMES
832e5b81d1f1   aula-02-api          "docker-entrypoint.s…"   19 seconds ago   Restarting (1) 2 seconds ago                                                 technova-api
c80f3880f66a   postgres:15-alpine   "docker-entrypoint.s…"   19 seconds ago   Up 18 seconds (healthy)        0.0.0.0:5433->5432/tcp, [::]:5433->5432/tcp   technova-postgres
97993037b965   redis:7-alpine       "docker-entrypoint.s…"   19 seconds ago   Up 18 seconds (healthy)        0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp   technova-redis