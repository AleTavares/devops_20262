# Entrega — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 22/09/2026

## Repositório

- Projeto: [unifaat-devops-portfolio](https://github.com/Manntto/unifaat-devops-portfolio)
- Workflow CI: [ci-aula08.yml](https://github.com/Manntto/unifaat-devops-portfolio/blob/main/.github/workflows/ci-aula08.yml)

## Checklist de Requisitos

- [x] Workflow CI multi-stage funcional (lint → test → build)
- [x] ESLint configurado e passando (semi, quotes, no-unused-vars, eqeqeq)
- [x] 6 testes Jest passando com coverage (88%)
- [x] Docker build no CI sem erros + smoke test do container
- [x] Secret `APP_ENV` configurado e referenciado no workflow
- [x] Badge de status no README
- [x] Screenshots do pipeline verde, falhando e secrets
- [x] Cache npm com `actions/setup-node`
- [x] Concurrency control (`cancel-in-progress: true`)
- [x] Smoke test do container após Docker build

## Evidência do Pipeline

```
Lint ✅ (11s) → Test ✅ (12s) → Build + Push ECR ✅ (15s) → Deploy EC2 ✅ (14s)
Total: 1m0s | Status: Success
```

- Pipeline verde: https://github.com/Manntto/unifaat-devops-portfolio/actions
- Execução com falha intencional (lint): lint ❌ → test skipped → build skipped
