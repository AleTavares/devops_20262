# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Matheus Gabriel Correa Braga Viana
**RA:** 6325053
**Data:** 20/08/2026

## Repositório

* URL: https://github.com/Matiasdocs/unifaat-devops-portfolio-aula-02

## Evidências

* [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
* [x] Volume nomeado configurado para PostgreSQL
* [x] Rede customizada conectando todos os serviços
* [x] Healthchecks configurados
* [x] Variáveis de ambiente via `.env` (não hardcoded)
* [x] `ia-analise.md` preenchido com reflexão crítica

## Evidência do Ambiente Rodando

```text
NAME                IMAGE                SERVICE    STATUS
technova-api        aula-02-api          api        Up (healthy)
technova-postgres   postgres:15-alpine   postgres   Up (healthy)
technova-redis      redis:7-alpine       redis      Up (healthy)
```