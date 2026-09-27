# Entrega - Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Rafael Nogueira Maruca  
**RA:** 6322006  
**Data:** 24/09/2026

## Repositorio

- URL: https://github.com/rafadical/unifaat-devops-portfolio
- Pasta da aula: https://github.com/rafadical/unifaat-devops-portfolio/tree/main/aula-02
- Branch de desenvolvimento: https://github.com/rafadical/unifaat-devops-portfolio/tree/feature/aula-02-compose

## Evidencias

- [x] `docker-compose.yml` com API, PostgreSQL e Redis
- [x] Volume nomeado `technova-postgres-data` para PostgreSQL
- [x] Rede customizada `technova-net`
- [x] Healthchecks na API, PostgreSQL e Redis
- [x] `depends_on` com `condition: service_healthy`
- [x] Variaveis interpoladas do `.env`, sem credenciais no Compose
- [x] `.env.example` versionado e `.env` ignorado
- [x] `ia-analise.md` com prompt, rascunho, alteracoes e avaliacao critica
- [x] Dockerfile funcional para a API
- [ ] Ambiente Docker Compose executado e evidenciado em `compose-evidence.txt`

## Validacao local

A API foi executada com Node.js usando os hosts de servico `postgres` e `redis` e as rotas `/` e `/health` responderam corretamente. A validacao de `docker compose config`, `docker compose up` e `docker compose ps` depende do Docker Desktop ativo e sera registrada no arquivo de evidencia apos essa execucao.

## Arquivos principais

- `aula-02/docker-compose.yml`
- `aula-02/app.js`
- `aula-02/Dockerfile`
- `aula-02/.env.example`
- `aula-02/ia-analise.md`
- `aula-02/README.md`
