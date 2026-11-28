# Entrega — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** José Henrique Teixeira Luiz
**RA:** 3225002
**Data:** 16/10/2026

## Repositório

- URL: https://github.com/zzin742/unifaat-devops-portfolio
- Pasta da aula: [`aula-08/`](https://github.com/zzin742/unifaat-devops-portfolio/tree/main/aula-08)
- Workflow: [`.github/workflows/ci-aula08.yml`](https://github.com/zzin742/unifaat-devops-portfolio/blob/main/.github/workflows/ci-aula08.yml)
- Respostas: [`aula-08/RESPOSTAS.md`](https://github.com/zzin742/unifaat-devops-portfolio/blob/main/aula-08/RESPOSTAS.md)

## Evidências

- [x] Workflow CI multi-stage funcional (lint → test → build)
- [x] ESLint configurado e passando
- [x] Mínimo 3 testes Jest passando com coverage — **9 testes, 89,28% de cobertura**
- [x] Docker build no CI sem erros
- [x] Secret referenciado no workflow (`AWS_REGION`)
- [x] Badge de status no README
- [x] Screenshots do pipeline verde

## Evidência do Pipeline Rodando

**Pipeline verde (main):**
https://github.com/zzin742/unifaat-devops-portfolio/actions/runs/38830448802

```
✓ Lint (ESLint)                  success
✓ Testes (Jest · Node 18)        success
✓ Testes (Jest · Node 20)        success
✓ Build Docker + Smoke Test      success
  Comentar resultado no PR       skipped   (só roda em pull_request)
```

**Pipeline falhando (erro proposital, evidência do R7):**
https://github.com/zzin742/unifaat-devops-portfolio/actions/runs/38830607192

```
✗ Lint (ESLint)                  failure
  Testes (Jest · Node 18 e 20)   skipped   ← needs funcionando
  Build Docker + Smoke Test      skipped   ← needs funcionando
✓ Comentar resultado no PR       success
```

O `needs` é o que faz os estágios seguintes serem **pulados** quando o lint
falha — o pipeline não gasta runner com testes e build de um código que já não
passou na análise estática.

**PR de demonstração (não mergeado):**
https://github.com/zzin742/unifaat-devops-portfolio/pull/1

Comentário publicado automaticamente pelo job `comentar-no-pr`:

| Etapa | Status |
|---|---|
| Lint (ESLint) | ❌ failure |
| Testes (Node 18 e 20) | ⏭️ skipped |
| Build Docker + smoke | ⏭️ skipped |

## Requisitos obrigatórios

| # | Requisito | Onde |
|---|---|---|
| R1 | Workflow multi-stage com `needs` | 3 jobs encadeados, cada um com nome descritivo |
| R2 | ESLint (`semi`, `quotes`, `no-unused-vars`) | `aula-08/.eslintrc.json` + script `lint` |
| R3 | Testes Jest com coverage | 9 testes sobre 4 rotas, script `test:ci` |
| R4 | Docker build taggeado | `technova-api:${{ github.sha }}` e `:latest` |
| R5 | Secret referenciado | `${{ secrets.AWS_REGION }}` no job `build` |
| R6 | Badge de status | topo do `aula-08/README.md` |
| R7 | Screenshots | `aula-08/screenshots/` |

## Bônus implementados (5 de 5)

| # | Bônus | Implementação |
|---|---|---|
| B1 | Matrix strategy | testes em **Node 18 e 20**, com `fail-fast: false` |
| B2 | Cache de dependências | `setup-node` com `cache: npm` e `cache-dependency-path` |
| B3 | PR comment | job `comentar-no-pr` com `actions/github-script@v7` |
| B4 | Concurrency control | `cancel-in-progress` por `github.ref` |
| B5 | Smoke test no Docker | sobe o container, faz health check no `/health`, remove |

## Observação sobre a estrutura

O enunciado sugere criar `aula-08/.github/workflows/`. Mantive uma cópia ali
para seguir a estrutura pedida, mas **o workflow que efetivamente executa está
na raiz do repositório**, porque o GitHub Actions só reconhece workflows em
`.github/workflows/` da raiz — dentro de uma subpasta ele nunca seria disparado.
Os jobs usam `working-directory: aula-08` para operar sobre o código da aula, e
há filtro por `paths:` para o CI só rodar quando algo desta aula mudar.
