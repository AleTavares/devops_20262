# Entrega — Aula 09: Docker Registry e IA no CI/CD

**Aluno:** Matheus Mantovani
**RA:** 1120245
**Data:** 2026-10-24

## Repositório

- URL: https://github.com/Manntto/unifaat-devops-portfolio
- Pasta: `aula-09/`
- Script ECR: `aula-09/ecr-push.sh`
- AI Review workflow: `.github/workflows/ai-review.yml`
- AI Review script: `.github/scripts/ai-review.js`

## Evidências

- [x] Script `ecr-push.sh` publicando no Amazon ECR com 5 tags (sha-cf16541, latest, 1.0.0, 1.0, 1)
- [x] Repositório ECR `technova-api` criado em `us-east-1` (Account: 864636683316)
- [x] Pull da imagem por tag funcional (rollback por sha ou semver)
- [x] Workflow AI Review disparando em PRs (`opened`, `synchronize`, `reopened`)
- [x] Quality gate CRITICAL bloqueando PR (eval() detectado → exit 1)
- [x] `ia-cicd-analise.md` preenchido com análise crítica
- [x] 4 screenshots (console ECR com tags, CloudShell com output, AI review comentando PR, quality gate bloqueando)

## Requisitos cobertos

| Requisito | Status |
|-----------|--------|
| Build e push no ECR com `ecr-push.sh` | ✅ |
| Tagging: sha + latest + semver (X.Y.Z, X.Y, X) | ✅ |
| Repositório ECR criado em us-east-1 com scan on push | ✅ |
| AI Review workflow em PRs | ✅ |
| Comentário formatado como tabela no PR | ✅ |
| Quality gate CRITICAL → exit 1 → PR bloqueado | ✅ |
| 8 padrões detectados (4 CRITICAL, 3 WARNING, 1 INFO) | ✅ |
| Documentação `ia-cicd-analise.md` | ✅ |
| 4 screenshots obrigatórios | ✅ |

## Evidência do Pipeline Rodando

- Repositório ECR: `864636683316.dkr.ecr.us-east-1.amazonaws.com/technova-api`
- Tags publicadas: `sha-cf16541`, `latest`, `1.0.0`, `1.0`, `1`
- AI Review: https://github.com/Manntto/unifaat-devops-portfolio/actions
- PR com quality gate falhando: `eval()` detectado como CRITICAL → merge bloqueado

## Screenshots

| Arquivo | Conteúdo |
|---------|----------|
| `ecr-console.png` | Console ECR com repositório `technova-api` e as 5 tags |
| `ecr-push-ok.png` | CloudShell mostrando as 5 tags publicadas |
| `ai-review-comment.png` | Comentário do AI Review no PR com achados formatados |
| `quality-gate-block.png` | PR bloqueado por CRITICAL (eval() detectado) |
