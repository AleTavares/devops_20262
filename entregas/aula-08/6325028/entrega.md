# Entrega — Aula 08: GitHub Actions e CI Pipelines

**Aluna:** Denise Maider Batista de Macedo
**RA:** 6325028
**Data:** 18/10/2026

## Repositório

- [Portfólio DevOps](https://github.com/Denisemayder/unifaat-devops-portfolio)
- [Projeto da Aula 08](https://github.com/Denisemayder/unifaat-devops-portfolio/tree/main/aula-08)
- [Workflow GitHub Actions](https://github.com/Denisemayder/unifaat-devops-portfolio/blob/main/.github/workflows/ci-aula08.yml)
- [RESPOSTAS.md](https://github.com/Denisemayder/unifaat-devops-portfolio/blob/main/aula-08/RESPOSTAS.md)

## Evidências

- [x] Workflow CI multi-stage funcional (lint → test → build)
- [x] ESLint configurado e passando
- [x] Quatro testes Jest passando com coverage
- [x] Docker build no CI sem erros
- [x] Secrets referenciados no workflow
- [x] Badge de status no README
- [x] Screenshots do pipeline verde, falha intencional e secrets

## Screenshots

- [Pipeline aprovado](https://github.com/Denisemayder/unifaat-devops-portfolio/blob/main/aula-08/screenshots/screenshot-pipeline-passing.png)
- [Pipeline com falha intencional](https://github.com/Denisemayder/unifaat-devops-portfolio/blob/main/aula-08/screenshots/screenshot-pipeline-failing.png)
- [Secrets configurados](https://github.com/Denisemayder/unifaat-devops-portfolio/blob/main/aula-08/screenshots/screenshot-secrets-configured.png)

## Evidência do Pipeline Rodando

- [GitHub Actions — Execuções do CI](https://github.com/Denisemayder/unifaat-devops-portfolio/actions/workflows/ci-aula08.yml)
- [Pull Request #3 — Falha intencional e correção](https://github.com/Denisemayder/unifaat-devops-portfolio/pull/3)

## Conclusão

O pipeline CI foi implementado com GitHub Actions, utilizando três jobs dependentes: lint, test e build.

Foi demonstrada uma falha intencional no ESLint, seguida de sua correção. Após a correção, os três jobs foram aprovados.
