# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Maximus Ponciano  
**RA:** 6325066  
**Data:** 25/08/2026  

## Repositório

- URL: https://github.com/MaximusPonciano/unifaat-devops-portfolio

## Evidências

- [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [x] Volume nomeado configurado para PostgreSQL
- [x] Rede customizada conectando todos os serviços
- [x] Healthchecks configurados
- [x] Variáveis de ambiente via `.env` (não hardcoded)
- [x] `ia-analise.md` preenchido com reflexão crítica

## Evidência do Ambiente Rodando

```text
NAME           IMAGE                COMMAND                  SERVICE    CREATED          STATUS                    PORTS
app_api        aula-02-api          "docker-entrypoint.s…"   api        30 seconds ago   Up 15 seconds (healthy)   0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
app_postgres   postgres:15-alpine   "docker-entrypoint.s…"   postgres   30 seconds ago   Up 28 seconds (healthy)   5432/tcp
app_redis      redis:7-alpine       "docker-entrypoint.s…"   redis      30 seconds ago   Up 29 seconds (healthy)   6379/tcp
```
