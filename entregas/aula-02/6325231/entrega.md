# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Andreyh Rodrigues de Souza
**RA:** 6325231
**Data:** 24/09/2026

## Repositório

- URL: https://github.com/Andreyh117/unifaat-devops-portfolio
- Projeto: https://github.com/Andreyh117/unifaat-devops-portfolio/tree/main/aula-02

## Evidências

- [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [x] Volume nomeado configurado para PostgreSQL
- [x] Rede bridge customizada conectando todos os serviços
- [x] Healthchecks em PostgreSQL e Redis; API aguarda `service_healthy`
- [x] Variáveis de ambiente via `.env`, ignorado pelo Git, com `.env.example`
- [x] Restart policy `unless-stopped` e comentários por seção
- [x] Dockerfile Node.js 20 funcional e `.dockerignore`
- [x] `ia-analise.md` com registro anterior do Kiro e revisão técnica identificada

## Evidência do Ambiente Rodando

Revisão executada em 24/09/2026, em projeto Compose isolado `andreyh-tf02-review`.
Usado `PORT=13002` no `.env` para testar a configuração da porta sem interferir
nos containers existentes. O mapeamento `${PORT}:${PORT}` acompanha a porta
em que o processo Node escuta.

`docker compose -p andreyh-tf02-review config --quiet` e
`docker compose -p andreyh-tf02-review up -d --build --wait`: código de saída 0.

`docker compose -p andreyh-tf02-review ps`:

```text
NAME                             IMAGE                     COMMAND                  SERVICE    CREATED              STATUS                        PORTS
andreyh-tf02-review-api-1        andreyh-tf02-review-api   "docker-entrypoint.s…"   api        About a minute ago   Up About a minute             3000/tcp, 0.0.0.0:13002->13002/tcp, [::]:13002->13002/tcp
andreyh-tf02-review-postgres-1   postgres:15-alpine        "docker-entrypoint.s…"   postgres   About a minute ago   Up About a minute (healthy)   5432/tcp
andreyh-tf02-review-redis-1      redis:7-alpine            "docker-entrypoint.s…"   redis      About a minute ago   Up About a minute (healthy)   6379/tcp
```

`curl http://localhost:13002`:

```text
{"servico":"TechNova API - Aula 02 TF","aluno":"Andreyh Rodrigues de Souza","ra":"6325231","status":"online","banco":"postgres:5432/technova","cache":"redis:6379","timestamp":"2026-09-24T15:31:05.323Z"}
```

`curl http://localhost:13002/health`:

```text
{"status":"healthy","uptime":100.794745496,"servicos":{"api":"online","banco":"postgres:5432","cache":"redis:6379"}}
```

`docker compose -p andreyh-tf02-review exec -T postgres psql -U technova -d technova -c "SELECT 1;"`:

```text
?column?
----------
        1
(1 row)
```

`docker compose -p andreyh-tf02-review exec -T redis redis-cli ping`:

```text
PONG
```

## Rede e persistência

Resumo de `docker network inspect andreyh-tf02-review_technova-network`:

```json
{
  "Name": "andreyh-tf02-review_technova-network",
  "Driver": "bridge",
  "Containers": [
    "andreyh-tf02-review-api-1",
    "andreyh-tf02-review-postgres-1",
    "andreyh-tf02-review-redis-1"
  ]
}
```

Para verificar o volume, foi criada uma tabela de teste com o RA 6325231.
Após `docker compose down` e `docker compose up -d --wait`, a consulta em uma
nova conexão retornou o mesmo registro:

```text
id
---------
 6325231
(1 row)
```

A tabela de teste foi removida após a verificação. `docker compose down` encerrou
os três containers de revisão e removeu a rede; o volume nomeado foi preservado,
conforme o comando de limpeza do enunciado. Nenhum container anterior foi alterado.
