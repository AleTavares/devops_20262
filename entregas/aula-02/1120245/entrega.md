# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 24/08/2026

## Repositório

- URL: https://github.com/Manntto/unifaat-devops-portfolio

## Evidências

- [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [x] Volume nomeado `pgdata` configurado para PostgreSQL
- [x] Rede customizada `technova-net` conectando todos os serviços
- [x] Healthchecks configurados (PostgreSQL com `pg_isready`, Redis com `redis-cli ping`)
- [x] Variáveis de ambiente via `.env` (não hardcoded, não versionado)
- [x] `.env.example` presente como template
- [x] `ia-analise.md` preenchido com reflexão crítica
- [x] Branch `feature/aula-02-compose` publicada (evidência do workflow)

## Evidência do Ambiente Rodando

```
=== docker compose ps ===
NAME                IMAGE                COMMAND                  SERVICE    STATUS
technova-api        aula-02-api          "docker-entrypoint.s…"   api        Up 5 seconds   0.0.0.0:3001->3000/tcp
technova-postgres   postgres:15-alpine   "docker-entrypoint.s…"   postgres   Up (healthy)   0.0.0.0:5433->5432/tcp
technova-redis      redis:7-alpine       "docker-entrypoint.s…"   redis      Up (healthy)   0.0.0.0:6379->6379/tcp

=== GET / ===
{
    "servico": "TechNova API - Aula 02 TF",
    "aluno": "Matheus Mantovani",
    "ra": "1120245",
    "status": "online",
    "banco": "postgres:5432/technova",
    "cache": "redis:6379",
    "timestamp": "2026-08-24T22:59:37.223Z"
}

=== Redis PING ===
PONG

=== PostgreSQL ===
PostgreSQL 15.18 on x86_64-pc-linux-musl — respondeu SELECT version()

=== Rede technova-net ===
technova-postgres — 172.20.0.2/16
technova-redis    — 172.20.0.3/16
technova-api      — 172.20.0.4/16
```

## Estrutura da Aula 02 no Portfólio

```
aula-02/
├── app.js               — API Node.js com Express
├── package.json         — dependências
├── Dockerfile           — build da imagem
├── .dockerignore
├── .gitignore
├── docker-compose.yml   — orquestração dos 3 serviços
├── .env.example         — template de variáveis (sem senhas)
├── ia-analise.md        — análise crítica do uso do Kiro
└── docker-compose-evidence.txt — evidência do ambiente rodando
```
