# Entrega — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** Rafael Nogueira Maruca
**RA:** 6322006
**Data:** 16/11/2026

[![CI Pipeline — Aula 08](https://github.com/rafadical/unifaat-devops-portfolio/actions/workflows/ci-aula08.yml/badge.svg)](https://github.com/rafadical/unifaat-devops-portfolio/actions/workflows/ci-aula08.yml)

## Repositório

- URL: https://github.com/rafadical/unifaat-devops-portfolio
- Pasta da aula: [`aula-08/`](https://github.com/rafadical/unifaat-devops-portfolio/tree/main/aula-08) — app em `aula-08/technova-api/`
- Workflow: [`.github/workflows/ci-aula08.yml`](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/.github/workflows/ci-aula08.yml)
- Respostas: [`aula-08/RESPOSTAS.md`](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-08/RESPOSTAS.md)

## Evidências

- [x] Workflow CI multi-stage funcional (lint → test → build) com `needs`
- [x] ESLint configurado e passando (`semi`, `quotes`, `no-unused-vars`, `indent`, `eol-last`)
- [x] 10 testes Jest passando com coverage (5 endpoints, 90% das linhas)
- [x] Docker build no CI sem erros (tag `${{ github.sha }}`)
- [x] Secret `AWS_REGION` referenciado no workflow (aparece como `***` no log)
- [x] Badge de status no README (raiz e `aula-08/`)
- [x] Pipeline verde e pipeline falhando executados (links abaixo)

### Bônus

- [x] B1 — Matrix: testes em Node 18 e Node 20
- [x] B2 — Cache: `setup-node` com `cache: npm` (log mostra `Cache restored from key: node-cache-Linux-x64-npm-...`)
- [x] B3 — PR comment: job `pr-comment` comentou o resultado no [PR #2](https://github.com/rafadical/unifaat-devops-portfolio/pull/2)
- [x] B4 — Concurrency com `cancel-in-progress: true`
- [x] B5 — Smoke test: container iniciado, `/health` respondeu `{"status":"ok"}`, container removido

## Evidência do Pipeline Rodando

| Execução | Resultado | Trecho do log |
|---|---|---|
| [Run 43982958949](https://github.com/rafadical/unifaat-devops-portfolio/actions/runs/43982958949) — push na `main` | ✅ lint, test (Node 18 e 20), build + smoke test | [ci-passando.txt](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-08/evidencias/ci-passando.txt) |
| [Run 43983106146](https://github.com/rafadical/unifaat-devops-portfolio/actions/runs/43983106146) — [PR #2](https://github.com/rafadical/unifaat-devops-portfolio/pull/2) com erro de lint intencional | ❌ lint falhou; test e build pulados pelo `needs`; comentário automático no PR | [ci-falhando.txt](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-08/evidencias/ci-falhando.txt) |

Trechos dos logs:

```
job Lint (ESLint): success
job Testes (Jest) — Node 18: success
job Testes (Jest) — Node 20: success
job Build Docker + Smoke Test: success

Tests:       10 passed, 10 total
Regiao configurada via secret: ***
{"status":"ok","timestamp":"2026-11-16T23:53:02.986Z","version":"1.0.0"}
Smoke test OK na tentativa 2
```

```
job Lint (ESLint): failure
job Testes (Jest) — Node (matrix): skipped
job Build Docker + Smoke Test: skipped
##[error]  4:22  error  Missing semicolon  semi
```
