# Entrega — Aula 01: Fundamentos de Git e Docker

**Aluno:** Sirlande Martins  
**RA:** 6325269  
**Data:** 13/08/2026

## Repositório

- URL: https://github.com/Sir-Jr/unifaat-devops-portfolio

## Evidências

- [x] Repositório público com estrutura completa
- [x] Mínimo de 5 commits demonstrando workflow Git (6 commits)
- [x] Dockerfile funcional
- [x] Container rodando (evidência abaixo)

## Workflow Git

Branch de feature `feature/aula-01-app` integrada à `main` com merge sem fast-forward,
preservando a ramificação no histórico:

```
*   df9b61c merge: integra aplicação e containerização da aula 01
|\
| * 6e851ee docs: adiciona evidência de container rodando
| * 72ab541 docs: adiciona README com aprendizados da aula 01
| * 7c922c4 feat: adiciona Dockerfile e .dockerignore para containerização
| * a921280 feat: cria aplicação Express para aula 01
|/
* bfc1f98 docs: estrutura inicial do portfólio DevOps
```

## Evidência de Container Rodando

```
Portfolio API rodando na porta 3000
---
Container running:
CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS          PORTS                                         NAMES
56bb302d7cd8   portfolio-aula01:1.0   "docker-entrypoint.s…"   19 seconds ago   Up 19 seconds   0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp   portfolio-test
---
API Response:
{"servico":"DevOps Portfolio API","aluno":"Sirlande Martins","ra":"6325269","aula":"01 - Fundamentos de Git e Docker","status":"online","timestamp":"2026-08-14T00:05:50.868Z"}
```

O arquivo completo está versionado em
[`aula-01/docker-logs.txt`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-01/docker-logs.txt).
