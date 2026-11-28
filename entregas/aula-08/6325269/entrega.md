# Entrega — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** Sirlande Martins
**RA:** 6325269
**Data:** 14/10/2026

## Repositório

- URL: https://github.com/Sir-Jr/unifaat-devops-portfolio

## Evidências

- [x] Workflow CI multi-stage funcional (lint → test → build) — [`.github/workflows/ci-aula08.yml`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/.github/workflows/ci-aula08.yml), com `test` em `needs: lint` e `build` em `needs: [lint, test]`
- [x] ESLint configurado e passando — [`aula-08/technova-api/.eslintrc.json`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-08/technova-api/.eslintrc.json) (`semi`, `quotes`, `no-unused-vars`, `indent` e outras), script `lint` no `package.json`
- [x] Mínimo 3 testes Jest passando com coverage — 9 testes em `GET /health`, `GET /api/orders`, `GET /api/orders/:id` e `POST /api/orders`, script `test` com `--coverage`
- [x] Docker build no CI sem erros — imagem `technova-api:${{ github.sha }}` a partir do [`Dockerfile`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-08/technova-api/Dockerfile) multi-stage
- [x] Secret referenciado no workflow — `${{ secrets.AWS_REGION }}` no job `build` (valor fictício; aparece como `***` no log)
- [x] Badge de status no README — no [README da raiz](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/README.md) e no [README da aula-08](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-08/README.md)
- [x] Screenshots do pipeline verde — pasta [`aula-08/screenshots/`](https://github.com/Sir-Jr/unifaat-devops-portfolio/tree/main/aula-08/screenshots)

Bônus implementados: matrix Node 18 e 20 (B1), cache npm no `setup-node` (B2), comentário automático no PR (B3),
`concurrency` com `cancel-in-progress` (B4) e smoke test do container com `curl /health` (B5).
Respostas das questões do TA em [`aula-08/RESPOSTAS.md`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-08/RESPOSTAS.md).

## Evidência do Pipeline Rodando

- Pipeline verde na `main` (lint → tests Node 18/20 → build): https://github.com/Sir-Jr/unifaat-devops-portfolio/actions/runs/38650539834
- Pipeline falhando por erro de lint intencional (PR de teste #1): https://github.com/Sir-Jr/unifaat-devops-portfolio/actions/runs/38650682358
- Comentário automático do CI no PR: https://github.com/Sir-Jr/unifaat-devops-portfolio/pull/1

| Screenshot | Conteúdo |
|------------|----------|
| [screenshot-pipeline-passing.png](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-08/screenshots/screenshot-pipeline-passing.png) | pipeline completo verde |
| [screenshot-pipeline-failing.png](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-08/screenshots/screenshot-pipeline-failing.png) | pipeline falhando (`Strings must use singlequote`) |
| [screenshot-secrets-configured.png](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-08/screenshots/screenshot-secrets-configured.png) | secret `AWS_REGION` configurado (valor oculto) |
| [screenshot-pr-comment.png](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-08/screenshots/screenshot-pr-comment.png) | comentário automático do CI no PR (B3) |
