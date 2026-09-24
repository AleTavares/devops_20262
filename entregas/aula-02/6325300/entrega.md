# Entrega - Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Gabriel Carneiro da Silva  
**RA:** 6325300  
**Data:** 27/08/2026

## Repositorio

- URL: https://github.com/gcdsofc/unifaat-devops-portfolio
- Pasta da aula: `aula-02/`
- Branch de desenvolvimento: `feature/aula-02-compose`

## Evidencias

- [x] `docker-compose.yml` com 3 servicos (API + PostgreSQL + Redis)
- [x] Volume nomeado configurado para PostgreSQL
- [x] Rede customizada conectando todos os servicos
- [x] Healthchecks configurados
- [x] Variaveis de ambiente via `.env` (nao hardcoded)
- [x] `.env.example` versionado como template
- [x] `.env` fora do Git
- [x] `ia-analise.md` preenchido com reflexao critica

## Evidencia do Ambiente Rodando

Comando executado na pasta `aula-02/` do repositorio pessoal:

```bash
docker compose ps
```

Output:

```text
NAME                       IMAGE                COMMAND                  SERVICE    CREATED              STATUS                        PORTS
technova-aula02-api        aula-02-api          "docker-entrypoint.s..."   api        19 seconds ago       Up 16 seconds (healthy)       0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
technova-aula02-postgres   postgres:15-alpine   "docker-entrypoint.s..."   postgres   About a minute ago   Up About a minute (healthy)   0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp
technova-aula02-redis      redis:7-alpine       "docker-entrypoint.s..."   redis      About a minute ago   Up About a minute (healthy)   0.0.0.0:6379->6379/tcp, [::]:6379->6379/tcp
```

## Teste da API

```bash
curl http://localhost:3000
```

```json
{"servico":"TechNova API - Aula 02 TF","aluno":"Gabriel Carneiro da Silva","ra":"6325300","status":"online","banco":"postgres:5432/technova","cache":"redis:6379","timestamp":"2026-08-28T02:14:40.310Z"}
```

```bash
curl http://localhost:3000/health
```

```json
{"status":"healthy","uptime":13.934444209,"servicos":{"api":"online","banco":"postgres:5432","cache":"redis:6379"}}
```

## Teste do PostgreSQL

```bash
docker compose exec -T postgres psql -U technova -d technova -c "SELECT 1;"
```

```text
 ?column?
----------
        1
(1 row)
```

## Teste do Redis

```bash
docker compose exec -T redis redis-cli ping
```

```text
PONG
```
