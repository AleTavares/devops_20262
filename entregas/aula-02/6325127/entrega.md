# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Marcos Eduardo dos Santos Sousa
**RA:** 6325127
**Data:** 2026-09-17

## Repositório

- URL: https://github.com/MarcosSantt/unifaat-devops-portfolio
- Pasta da aula: [`aula-02/`](https://github.com/MarcosSantt/unifaat-devops-portfolio/tree/main/aula-02)
- Branch de desenvolvimento (evidência do workflow): [`feature/aula-02-compose`](https://github.com/MarcosSantt/unifaat-devops-portfolio/tree/feature/aula-02-compose)

## Evidências

- [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [x] Volume nomeado configurado para PostgreSQL (`pgdata`)
- [x] Rede customizada conectando todos os serviços (`technova-net`)
- [x] Healthchecks configurados (PostgreSQL via `pg_isready`, Redis via `redis-cli ping`)
- [x] Variáveis de ambiente via `.env` (não hardcoded) — `.env.example` versionado como template
- [x] `ia-analise.md` preenchido com reflexão crítica sobre o uso da IA (Claude, usado no lugar do Kiro, indisponível no meu ambiente)

## Evidência do Ambiente Rodando

```
=== docker compose ps ===
NAME                IMAGE                COMMAND                  SERVICE    CREATED          STATUS                    PORTS
technova-api        aula-02-api          "docker-entrypoint.s…"   api        21 seconds ago   Up 9 seconds              0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
technova-postgres   postgres:15-alpine   "docker-entrypoint.s…"   postgres   21 seconds ago   Up 20 seconds (healthy)   5432/tcp
technova-redis      redis:7-alpine       "docker-entrypoint.s…"   redis      21 seconds ago   Up 20 seconds (healthy)   6379/tcp

=== curl http://localhost:3000 ===
{"servico":"TechNova API - Aula 02 TF","aluno":"Marcos Eduardo dos Santos Sousa","ra":"6325127","status":"online","banco":"postgres:5432/technova","cache":"redis:6379","timestamp":"2026-09-17T23:43:54.598Z"}

=== curl http://localhost:3000/health ===
{"status":"healthy","uptime":9.471768342,"servicos":{"api":"online","banco":"postgres:5432","cache":"redis:6379"}}

=== docker compose exec postgres psql -U technova -d technova -c "SELECT 1;" ===
 ?column?
----------
        1
(1 row)

=== docker compose exec redis redis-cli ping ===
PONG
```

Log completo também disponível em [`aula-02/evidencia-ambiente.txt`](https://github.com/MarcosSantt/unifaat-devops-portfolio/blob/main/aula-02/evidencia-ambiente.txt) no repositório do portfólio.
