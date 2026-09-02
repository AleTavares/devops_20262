# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Henri da Silva Despezzi  
**RA:** 6325064 
**Data:** 20-08-2026

## Repositório

- URL: https://github.com/HenriSD/unifaat-devops-portfolio

## Evidências

- [X] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [X] Volume nomeado configurado para PostgreSQL
- [X] Rede customizada conectando todos os serviços
- [X] Healthchecks configurados
- [X] Variáveis de ambiente via `.env` (não hardcoded)
- [X] `ia-analise.md` preenchido com reflexão crítica

## Evidência do Ambiente Rodando

faat@D04-001:~/unifaat-devops-portfolio/aula-02$ docker compose ps
WARN[0000] /home/faat/unifaat-devops-portfolio/aula-02/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion
NAME           IMAGE                COMMAND                  SERVICE    CREATED          STATUS                    PORTS
app_api        aula-02-api          "docker-entrypoint.s…"   api        27 seconds ago   Up 14 seconds (healthy)   0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
app_postgres   postgres:15-alpine   "docker-entrypoint.s…"   postgres   27 seconds ago   Up 26 seconds (healthy)   5432/tcp
app_redis      redis:7-alpine       "docker-entrypoint.s…"   redis      27 seconds ago   Up 26 seconds (healthy)   6379/tcp