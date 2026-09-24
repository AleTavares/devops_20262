# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Lucas José Campos da Rocha
**RA:** 6325123
**Data:** 26/08/2026

## Repositório

* URL: https://github.com/crocodiles128/unifaat-devops-portfolio
## Evidências

* [x] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
* [x] Volume nomeado configurado para PostgreSQL
* [x] Rede customizada conectando todos os serviços
* [x] Healthchecks configurados
* [x] Variáveis de ambiente via `.env` (não hardcoded)
* [x] `ia-analise.md` preenchido com reflexão crítica

## Evidência do Ambiente Rodando

```bash
 => => naming to docker.io/library/technova-aula02-api:latest                   0.1s
 => => unpacking to docker.io/library/technova-aula02-api:latest                0.5s
 => resolving provenance for metadata file                                      0.0s
[+] up 4/4
 ✔ Image technova-aula02-api:latest   Built                                     14.5s
 ✔ Container technova-aula02-api      Started                                   15.0s
 ✔ Container technova-aula02-redis    Healthy                                    9.0s
 ✔ Container technova-aula02-postgres Healthy                                   10.5s
```