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

<!-- Cole aqui o output do `docker compose ps` após rodar o ambiente localmente -->
<!-- Exemplo do output esperado:

NAME               IMAGE                    COMMAND                  SERVICE    CREATED         STATUS                   PORTS
technova-api       6325109-aula-02-api      "docker-entrypoint.s…"   api        2 minutes ago   Up 2 minutes             0.0.0.0:3000->3000/tcp
technova-cache     redis:7-alpine           "docker-entrypoint.s…"   redis      2 minutes ago   Up 2 minutes (healthy)   6379/tcp
technova-db        postgres:15-alpine       "docker-entrypoint.s…"   postgres   2 minutes ago   Up 2 minutes (healthy)   5432/tcp

-->
