# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Caroline Lejne Geli  
**RA:** 6325016  
**Data:** 27/08/2026

## Repositório

- URL: https://github.com/LejneGeli/unifaat-devops-portfolio

## Evidências

- [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [x] Volume nomeado configurado para PostgreSQL
- [x] Rede customizada conectando todos os serviços
- [x] Healthchecks configurados
- [x] Variáveis de ambiente via `.env` (não hardcoded)
- [x] `ia-analise.md` preenchido com reflexão crítica

## Evidência do Ambiente Rodando

Comando executado:

```bash
docker compose ps
```

Resultado:

```text
NAME                       IMAGE                SERVICE    STATUS           PORTS
technova-aula02-api        aula-02-api          api        Up (healthy)     0.0.0.0:3001->3000/tcp
technova-aula02-postgres   postgres:15-alpine   postgres   Up (healthy)     5432/tcp
technova-aula02-redis      redis:7-alpine       redis      Up (healthy)     6379/tcp
```

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