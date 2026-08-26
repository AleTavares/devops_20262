# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Felipe Damasceno
**RA:** 6325128
**Data:** 20/08/2026

## Repositório

- URL: https://github.com/FelipeDesda/unifaat-devops-portfolio

## Evidências

- [ ] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [ ] Volume nomeado configurado para PostgreSQL
- [ ] Rede customizada conectando todos os serviços
- [ ] Healthchecks configurados
- [ ] Variáveis de ambiente via `.env` (não hardcoded)
- [ ] `ia-analise.md` preenchido com reflexão crítica

## Evidência do Ambiente Rodando

lipeco@SHASHUMGAJR:~/DEVOPS/unifaat-devops-portfolio/aula-02$ docker compose ps
NAME                IMAGE                COMMAND                  SERVICE    CREATED          STATUS                    PORTS
technova_api        aula-02-api          "docker-entrypoint.s…"   api        14 seconds ago   Up 7 seconds              0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
technova_postgres   postgres:15-alpine   "docker-entrypoint.s…"   postgres   15 seconds ago   Up 14 seconds (healthy)   5432/tcp
technova_redis      redis:7-alpine       "docker-entrypoint.s…"   redis      15 seconds ago   Up 14 seconds (healthy)   6379/tcp