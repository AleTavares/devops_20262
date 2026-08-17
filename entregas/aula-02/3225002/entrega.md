# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** José Henrique Teixeira Luiz
**RA:** 3225002
**Data:** 17/08/2026

## Repositório

- URL: https://github.com/zzin742/unifaat-devops-portfolio
- Pasta desta entrega: https://github.com/zzin742/unifaat-devops-portfolio/tree/main/aula-02

## Evidências

- [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [x] Volume nomeado configurado para PostgreSQL (`technova-postgres-data`)
- [x] Rede customizada conectando todos os serviços (`technova-net`, bridge)
- [x] Healthchecks configurados (Postgres via `pg_isready`, Redis via `redis-cli ping`)
- [x] `depends_on` com `condition: service_healthy` nos dois serviços
- [x] Variáveis de ambiente via `.env` (não hardcoded) + `.env.example` versionado como template
- [x] `restart: unless-stopped` em todos os serviços
- [x] `ia-analise.md` preenchido com reflexão crítica sobre o output do Kiro
- [x] Feature branch `feature/aula-02-compose` com merge `--no-ff` na `main` (workflow Git)

## Evidência do Ambiente Rodando

Arquivo completo em [`aula-02/docker-compose-logs.txt`](https://github.com/zzin742/unifaat-devops-portfolio/blob/main/aula-02/docker-compose-logs.txt).

```
=== docker compose ps ===
NAME                IMAGE                COMMAND                  SERVICE    STATUS                        PORTS
technova-api        aula-02-api          "docker-entrypoint.s…"   api        Up About a minute             0.0.0.0:3000->3000/tcp
technova-postgres   postgres:15-alpine   "docker-entrypoint.s…"   postgres   Up About a minute (healthy)   0.0.0.0:5433->5432/tcp
technova-redis      redis:7-alpine       "docker-entrypoint.s…"   redis      Up About a minute (healthy)   0.0.0.0:6380->6379/tcp

=== API GET / ===
{
  "servico": "TechNova API - Aula 02 TF",
  "aluno": "José Henrique Teixeira Luiz",
  "ra": "3225002",
  "status": "online",
  "banco": "postgres:5432/technova",
  "cache": "redis:6379"
}

=== PostgreSQL - SELECT version() ===
PostgreSQL 15.19 on x86_64-pc-linux-musl, compiled by gcc (Alpine 15.2.0) 15.2.0, 64-bit

=== Redis - PING ===
PONG

=== Rede customizada ===
technova-net - driver: bridge - containers: 3
```

## Observações adicionais

- Usei portas do host `5433` (Postgres) e `6380` (Redis) pra não colidir com serviços locais já em uso no meu PC.
- Todas as senhas ficam apenas no `.env` local (fora do git). O `.env.example` versionado documenta os nomes das variáveis com placeholder `ALTERE_ESTA_SENHA`.
- No `ia-analise.md` documentei 11 alterações que fiz em cima do rascunho do Kiro — a mais crítica foi a substituição de senhas hardcoded pelas variáveis do `.env`, que o próprio prompt tinha pedido mas o Kiro ignorou.
