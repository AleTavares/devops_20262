# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Carina Gonçalves dos Santos Dalpino
**RA:** 6325109
**Data:** 18/08/2026

## Repositório

- URL: https://github.com/CarinaDalpino/unifaat-devops-portfolio

## Evidências

- [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [x] Volume nomeado configurado para PostgreSQL
- [x] Rede customizada conectando todos os serviços
- [x] Healthchecks configurados
- [x] Variáveis de ambiente via `.env` (não hardcoded)
- [x] `ia-analise.md` preenchido com reflexão crítica

## Evidência do Ambiente Rodando

```
NAME             IMAGE                COMMAND                  SERVICE    CREATED              STATUS                        PORTS
technova-api     aula-02-api          "docker-entrypoint.s…"   api        3 seconds ago        Up Less than a second         0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
technova-cache   redis:7-alpine       "docker-entrypoint.s…"   redis      About a minute ago   Up About a minute (healthy)   6379/tcp
technova-db      postgres:15-alpine   "docker-entrypoint.s…"   postgres   About a minute ago   Up About a minute (healthy)   5432/tcp
```
