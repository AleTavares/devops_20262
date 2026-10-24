# Entrega — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** Matheus Mantovani
**RA:** 1120245
**Data:** 2026-10-02

## Repositório

- URL: https://github.com/Manntto/unifaat-devops-portfolio
- Pasta: `aula-08/`
- Workflow: `.github/workflows/ci-aula08.yml`

## Evidências

- [x] Workflow CI multi-stage funcional (lint → test → build)
- [x] ESLint configurado e passando
- [x] 6 testes Jest passando com coverage (88%)
- [x] Docker build no CI sem erros + smoke test do container
- [x] Secret `APP_ENV` configurado e referenciado no workflow
- [x] Badge de status no README
- [x] Screenshots do pipeline verde, falhando e secrets

## Requisitos cobertos

| Requisito | Status |
|-----------|--------|
| R1 — Workflow CI multi-stage (lint → test → build, `needs`) | ✅ |
| R2 — ESLint configurado (semi, quotes, no-unused-vars, eqeqeq) | ✅ |
| R3 — 6 testes Jest com `--coverage` | ✅ |
| R4 — Docker build + smoke test no CI | ✅ |
| R5 — Secret `APP_ENV` referenciado com `${{ secrets.APP_ENV }}` | ✅ |
| R6 — Badge de status no README | ✅ |
| R7 — 3 screenshots obrigatórios | ✅ |
| B2 — Cache npm com `actions/setup-node` | ✅ |
| B4 — Concurrency control (`cancel-in-progress: true`) | ✅ |
| B5 — Smoke test do container após docker build | ✅ |

## Evidência do Pipeline Rodando

- Pipeline verde: https://github.com/Manntto/unifaat-devops-portfolio/actions
- Execução #1: `Merge branch 'feature/aula-08-ci-pipeline'` — 3 jobs passando em 1m5s
- Pipeline falhando: PR `feature/aula-08-lint-fail` — lint ❌ (Missing semicolon), test e build skipped pela cadeia `needs`

## Screenshots

| Arquivo | Conteúdo |
|---------|----------|
| `screenshot-pipeline-passing.png` | Pipeline verde com lint ✅ test ✅ build ✅ |
| `screenshot-pipeline-failing.png` | Lint ❌ falhando, test e build skipped pelo `needs` |
| `screenshot-secrets-configured.png` | Secret `APP_ENV` listado em Repository secrets |
