# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** [Nicolas de Jesus Silva]  
**RA:** [6325171]  
**Data:** [26/08/2026]

## Repositório

- URL: https://github.com/NxcolasDev/unifaat-devops-portfolio

## Evidências

- [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [x] Volume nomeado configurado para PostgreSQL
- [x] Rede customizada conectando todos os serviços
- [x] Healthchecks configurados
- [x] Variáveis de ambiente via `.env` (não hardcoded)
- [x] `ia-analise.md` preenchido com reflexão crítica

## Evidência do Ambiente Rodando

```bash
docker compose ps
```

```text
nicolas@Nicolas:/mnt/c/Users/nicol/unifaat-devops-portfolio/aula-02$ docker compose ps
WARN[0000] /mnt/c/Users/nicol/unifaat-devops-portfolio/aula-02/docker-compose.yml: the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion
NAME             IMAGE                COMMAND                  SERVICE    CREATED         STATUS                   PORTS
technova-api     aula-02-api          "docker-entrypoint.s…"   api        4 minutes ago   Up 4 minutes             0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
technova-cache   redis:7-alpine       "docker-entrypoint.s…"   redis      5 minutes ago   Up 5 minutes (healthy)   0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp
technova-db      postgres:15-alpine   "docker-entrypoint.s…"   postgres   5 minutes ago   Up 4 minutes (healthy)   5432/tcp

## Testes Executados

```text
curl http://localhost:3001/
{"servico":"TechNova API","status":"online","banco":"PostgreSQL conectado","cache":"Redis conectado"}

docker compose exec postgres psql -U technova -d technova -c "SELECT 1;"
 ?column?
----------
        1
(1 row)

docker compose exec redis redis-cli ping
PONG