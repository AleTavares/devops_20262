# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Matheus de Paula
**RA:** 6325065
**Data:** 25/09/2026

## Repositório

- URL: https://github.com/mtmaciel1/unifaat-devops-portfolio

## Evidências

- [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [x] Volume nomeado configurado para PostgreSQL
- [x] Rede customizada conectando todos os serviços
- [x] Healthchecks configurados
- [x] Variáveis de ambiente via `.env` (não hardcoded)
- [x] `ia-analise.md` preenchido com reflexão crítica

## Evidência do Ambiente Rodando

```text
$ docker compose ps
WARN[0000] C:\Users\psyym\unifaat-devops-portfolio\aula-02\docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion
NAME             IMAGE                COMMAND                  SERVICE    CREATED          STATUS                    PORTS
technova-api     aula-02-api          "docker-entrypoint.s…"   api        15 seconds ago   Up 3 seconds              0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
technova-cache   redis:7-alpine       "docker-entrypoint.s…"   redis      16 seconds ago   Up 14 seconds (healthy)   0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp
technova-db      postgres:15-alpine   "docker-entrypoint.s…"   postgres   16 seconds ago   Up 14 seconds (healthy)   0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp

