# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Fábio Panosian
**RA:** 6325250
**Data:** 24/09/2026

## Repositório

- URL: https://github.com/fabiopanosian-droid/unifaat-devops-portfolio
- Pasta do projeto: `aula-02/`

## Evidências

- [x] `docker-compose.yml` com 3 serviços: API, PostgreSQL e Redis
- [x] Volume nomeado configurado para o PostgreSQL
- [x] Rede customizada conectando todos os serviços
- [x] Healthchecks configurados
- [x] Variáveis de ambiente via `.env`, sem credenciais hardcoded no Compose
- [x] `ia-analise.md` preenchido com a reflexão crítica sobre o uso do Kiro
- [x] Projeto publicado no repositório pessoal

## Padrão do Pull Request

- **Branch:** `entregas/aula-02/6325250`
- **Commit:** `feat(aula-02): entrega TF - Fábio Panosian (RA: 6325250)`
- **Título do PR:** `[Aula 02] RA: 6325250 - Fábio Panosian`
- **Base:** `main`
- **Compare:** `entregas/aula-02/6325250`

## Evidência do Ambiente Rodando

```text
fabio@fabio-Aspire-4736Z:~/unifaat-devops-portfolio/aula-02$ docker compose ps
NAME             IMAGE                COMMAND                  SERVICE   CREATED        STATUS                            PORTS
technova-api     aula-02-api          "docker-entrypoint.s…"   api   23 hours ago   Up Less than a second             0.0.0.0:3001->3000/tcp, [::]:3001->3000/tcp
technova-db      postgres:15-alpine   "docker-entrypoint.s…"   postgres   23 hours ago   Up Less than a second (healthy)   0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp
technova-redis   redis:7-alpine       "docker-entrypoint.s…"   redis   23 hours ago   Up Less than a second (healthy)   0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp
```

fabio@fabio-Aspire-4736Z:~/unifaat-devops-portfolio/aula-02$ curl http://localhost:3001/health
{"status":"healthy","uptime":895.843734268,"servicos":{"api":"online","banco":"postgres:5432","cache":"redis:6379"}}fabio@fabio-Aspire-4736Z:
```
