# Entrega — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** Carina Gonçalves dos Santos Dalpino
**RA:** 6325109
**Data:** 13/10/2026

## Repositório

- **Portfólio (código do projeto):** https://github.com/CarinaDalpino/unifaat-devops-portfolio
- **Pasta do projeto:** [`aula-08/`](https://github.com/CarinaDalpino/unifaat-devops-portfolio/tree/main/aula-08)
- **Aba Actions (execuções do CI):** https://github.com/CarinaDalpino/unifaat-devops-portfolio/actions/workflows/ci-aula08.yml

## Mapa dos Requisitos → Arquivo (links diretos)

| Req | Evidência | Link direto |
|-----|-----------|-------------|
| **R1** — Pipeline multi-stage (lint → test → build, push + PR, `needs`) | Workflow YAML | [.github/workflows/ci-aula08.yml](https://github.com/CarinaDalpino/unifaat-devops-portfolio/blob/main/.github/workflows/ci-aula08.yml) |
| **R2** — ESLint (`semi`, `quotes`, `no-unused-vars` + script) | `.eslintrc.json` | [aula-08/.eslintrc.json](https://github.com/CarinaDalpino/unifaat-devops-portfolio/blob/main/aula-08/.eslintrc.json) |
| **R3** — Jest 9 testes + coverage (4 endpoints) | `__tests__/server.test.js` | [aula-08/__tests__/server.test.js](https://github.com/CarinaDalpino/unifaat-devops-portfolio/blob/main/aula-08/__tests__/server.test.js) |
| **R4** — Docker build no CI | `Dockerfile` | [aula-08/Dockerfile](https://github.com/CarinaDalpino/unifaat-devops-portfolio/blob/main/aula-08/Dockerfile) |
| **R5** — Secret `AWS_REGION` referenciado | Workflow (job build) | [ci-aula08.yml (job build)](https://github.com/CarinaDalpino/unifaat-devops-portfolio/blob/main/.github/workflows/ci-aula08.yml) |
| **R6** — Badge CI + README | `README.md` | [aula-08/README.md](https://github.com/CarinaDalpino/unifaat-devops-portfolio/blob/main/aula-08/README.md) |
| **R7** — Screenshots (passing/failing/secrets) | `screenshots/` | [aula-08/screenshots/](https://github.com/CarinaDalpino/unifaat-devops-portfolio/tree/main/aula-08/screenshots) |
| **RESPOSTAS.md** — respostas conceituais (10%) | `RESPOSTAS.md` | [aula-08/RESPOSTAS.md](https://github.com/CarinaDalpino/unifaat-devops-portfolio/blob/main/aula-08/RESPOSTAS.md) |

> O arquivo `RESPOSTAS.md` também segue em cópia nesta pasta de entrega.

## Evidências (checklist)

- [x] Workflow CI multi-stage funcional (lint → test → build)
- [x] ESLint configurado e passando (`npm run lint` sem erros)
- [x] Mínimo 3 testes Jest passando com coverage — **9 testes, coverage ~89%**
- [x] Docker build no CI sem erros (multi-stage)
- [x] Secret referenciado no workflow (`${{ secrets.AWS_REGION }}`)
- [x] Badge de status no README
- [x] 3 screenshots (pipeline verde, pipeline falhando, secrets configurados)
- [x] RESPOSTAS.md com respostas demonstrando compreensão

## Validação local (executada)

| Estágio | Comando | Resultado |
|---------|---------|-----------|
| Lint | `npm run lint` | exit 0, zero erros |
| Testes | `npm test` | 9 passed / 9 total, coverage 89,28% |
| Build | `docker build` | imagem criada com sucesso |
| Smoke test | `curl /health` no container | `{"status":"ok",...}` (200) |

## Screenshots

Na pasta [`aula-08/screenshots/`](https://github.com/CarinaDalpino/unifaat-devops-portfolio/tree/main/aula-08/screenshots):
- `screenshot-pipeline-passing.png` — pipeline completo verde
- `screenshot-pipeline-failing.png` — pipeline falhando (erro intencional)
- `screenshot-secrets-configured.png` — tela de secrets (nomes visíveis, valores ocultos)

## Bônus implementados

- **B1 — Matrix Strategy:** testes em Node 18 e 20
- **B2 — Cache de dependências:** `setup-node` com `cache: npm`
- **B4 — Concurrency control:** cancela runs antigos (`cancel-in-progress`)
- **B5 — Smoke test no Docker:** sobe o container e checa o `/health`
