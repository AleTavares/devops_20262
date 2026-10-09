# Entrega — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 2026-10-08

## Repositório

- URL: https://github.com/lucaskenway/unifaat-devops-portfolio
- Código: [`aula-08/technova-api/`](https://github.com/lucaskenway/unifaat-devops-portfolio/tree/main/aula-08/technova-api)
- Workflow: [`.github/workflows/ci-aula08.yml`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/.github/workflows/ci-aula08.yml)

[![CI Pipeline — Aula 08](https://github.com/lucaskenway/unifaat-devops-portfolio/actions/workflows/ci-aula08.yml/badge.svg)](https://github.com/lucaskenway/unifaat-devops-portfolio/actions/workflows/ci-aula08.yml)

## Evidências

- [x] Workflow CI multi-stage funcional (lint → test → build)
- [x] ESLint configurado e passando
- [x] Mínimo 3 testes Jest passando com coverage (9 testes, ~89% de statements)
- [x] Docker build no CI sem erros (imagem `technova-api:${{ github.sha }}`)
- [ ] Secret referenciado no workflow (`AWS_REGION` e `AWS_ACCESS_KEY_ID`)
- [ ] Badge de status no README
- [ ] Screenshots do pipeline verde

### Bônus

- [x] B1 — Matrix Strategy: testes em Node 18 e Node 20
- [x] B2 — Cache de dependências (`setup-node` com `cache: npm`)
- [x] B3 — PR Comment via `GITHUB_TOKEN` (`actions/github-script`)
- [x] B4 — Concurrency Control (`cancel-in-progress: true`)
- [x] B5 — Smoke test do container (`/health`) com remoção ao final

## Evidência do Pipeline Rodando

- Execução verde: <!-- TODO: link da run na aba Actions -->
- Execução falhando (erro intencional): <!-- TODO: link da run -->
- Comentário automático no PR: <!-- TODO: link do PR -->

### Screenshots

| Evidência | Arquivo |
|-----------|---------|
| Pipeline verde | [`screenshot-pipeline-passing.png`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-08/screenshots/screenshot-pipeline-passing.png) |
| Pipeline falhando | [`screenshot-pipeline-failing.png`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-08/screenshots/screenshot-pipeline-failing.png) |
| Secrets configurados | [`screenshot-secrets-configured.png`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-08/screenshots/screenshot-secrets-configured.png) |
