# Entrega — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** Carina Gonçalves dos Santos Dalpino
**RA:** 6325109
**Data:** 13/10/2026

## Repositório

- URL: https://github.com/CarinaDalpino/unifaat-devops-portfolio

## Evidências

- [x] Workflow CI multi-stage funcional (lint -> test -> build)
- [x] ESLint configurado e passando
- [x] Mínimo 3 testes Jest passando com coverage (9 testes)
- [x] Docker build no CI sem erros
- [x] Secret referenciado no workflow (AWS_REGION)
- [x] Badge de status no README
- [x] Screenshots do pipeline verde

## Evidência do Pipeline Rodando

Workflow: `.github/workflows/ci-aula08.yml`
Aba Actions: https://github.com/CarinaDalpino/unifaat-devops-portfolio/actions

Screenshots na pasta `aula-08/screenshots/`:
- screenshot-pipeline-passing.png
- screenshot-pipeline-failing.png
- screenshot-secrets-configured.png

### Bônus implementados
- B1 Matrix Strategy: testes em Node 18 e 20
- B2 Cache de dependências (setup-node com cache npm)
- B4 Concurrency control
- B5 Smoke test no Docker (sobe container e checa /health)