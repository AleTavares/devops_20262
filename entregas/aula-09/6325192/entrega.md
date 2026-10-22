# Entrega — Aula 09: Docker Registry e IA no CI/CD

**Aluno:** Emar Cristian Silva Teruo Ito
**RA:** 6325192
**Data:** 14/10/2026

## Repositório

- URL: https://github.com/iHawlKz7/unifaat-devops-portfolio

## Evidências

- [x] Pipeline CI (lint → test → build+push) funcional
- [x] Imagem publicada no ghcr.io com tags (sha, latest, semver)
- [x] Push condicional (só em push para main/tags, não em PRs)
- [x] Workflow de AI Review disparando em PRs
- [x] Quality gate (CRITICAL bloqueia o PR)
- [x] `ia-cicd-analise.md` preenchido
- [x] Screenshots (Packages, AI review, pipeline verde, gate bloqueando)

## Evidência do Pipeline Rodando

- PR de validação: https://github.com/iHawlKz7/unifaat-devops-portfolio/pull/2
- Pipeline verde: https://github.com/iHawlKz7/unifaat-devops-portfolio/blob/main/aula-09/screenshots/pipeline-passing.png
- AI Review: https://github.com/iHawlKz7/unifaat-devops-portfolio/blob/main/aula-09/screenshots/ai-review-comment.png
- Quality Gate bloqueando CRITICAL: https://github.com/iHawlKz7/unifaat-devops-portfolio/blob/main/aula-09/screenshots/quality-gate-block.png
- GitHub Packages / SemVer: https://github.com/iHawlKz7/unifaat-devops-portfolio/blob/main/aula-09/screenshots/packages-tab.png
- Package: https://github.com/iHawlKz7/unifaat-devops-portfolio/pkgs/container/technova-api
