# Entrega — Aula 01: Fundamentos de Git e Docker

**Aluno:** José Henrique Teixeira Luiz
**RA:** 3225002
**Data:** 14/08/2026

## Repositório

- URL: https://github.com/zzin742/unifaat-devops-portfolio

## Evidências

- [x] Repositório público com estrutura completa
- [x] Mínimo de 5 commits demonstrando workflow Git (6 commits contando o merge)
- [x] Dockerfile funcional
- [x] Container rodando (evidência abaixo)
- [x] Uso de feature branch (`feature/aula-01-app`) com merge `--no-ff` na `main`
- [x] Conventional Commits em todas as mensagens (`docs:`, `feat:`, `merge:`)

## Histórico Git

```
*   fb731e3 (main) merge: integra aplicação da aula 01 (feature/aula-01-app)
|\
| * 57c8ed7 (feature/aula-01-app) docs: adiciona evidência de container rodando
| * 115cf46 docs: adiciona README com aprendizados da aula 01
| * 6099a27 feat: adiciona Dockerfile e .dockerignore para containerização
| * 7c8e365 feat: cria aplicação Express para aula 01
|/
* 505b771 docs: estrutura inicial do portfólio DevOps
```

## Evidência de Container Rodando

Arquivo completo: [`aula-01/docker-logs.txt`](https://github.com/zzin742/unifaat-devops-portfolio/blob/main/aula-01/docker-logs.txt)

```
=== docker logs portfolio-test ===
Portfolio API rodando na porta 3000

===================================
Container running (docker ps):
===================================
CONTAINER ID   IMAGE                  COMMAND                  STATUS         PORTS                                         NAMES
1511d3080a3b   portfolio-aula01:1.0   "docker-entrypoint.s…"   Up 4 minutes   0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp   portfolio-test

===================================
API Response (GET /):
===================================
{
    "servico":  "DevOps Portfolio API",
    "aluno":  "José Henrique Teixeira Luiz",
    "ra":  "3225002",
    "aula":  "01 - Fundamentos de Git e Docker",
    "status":  "online",
    "timestamp":  "2026-08-14T00:26:13.328Z"
}

===================================
API Response (GET /health):
===================================
{
    "status":  "healthy",
    "uptime":  302.194148943,
    "version":  "1.0.0"
}
```

## Como executar

```bash
git clone https://github.com/zzin742/unifaat-devops-portfolio.git
cd unifaat-devops-portfolio/aula-01/app
docker build -t portfolio-aula01:1.0 .
docker run -d -p 3000:3000 portfolio-aula01:1.0
curl http://localhost:3000
curl http://localhost:3000/health
```
