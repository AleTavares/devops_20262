# Entrega — Aula 09: Docker Registry e IA no CI/CD

**Aluno:** Sirlande Martins
**RA:** 6325269
**Data:** 24/10/2026

## Repositório

- URL: https://github.com/Sir-Jr/unifaat-devops-portfolio

## Evidências

- [x] Script `ecr-push.sh` publicando no **Amazon ECR** com tags (sha, latest, semver) — [`aula-09/ecr-push.sh`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-09/ecr-push.sh): garante o repositório, faz login (`aws ecr get-login-password | docker login`), builda a imagem multi-stage e publica `sha-XXXXXXX`, `latest` e, com a git tag `v1.0.0`, também `1.0.0`, `1.0` e `1` ([saída](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-09/evidencias/ecr-push-v1.0.0.txt))
- [x] Repositório ECR `technova-api` criado no Learner Lab (`us-east-1`) — criado pelo próprio script (idempotente), com scan on push e lifecycle policy
- [x] Pull da imagem a partir do ECR funcionando (rollback por tag) — [`aula-09/ecr-rollback.sh`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-09/ecr-rollback.sh): `1.0.0` → `sha-2b3c81b` → `1.0.0`, com `/health` OK em cada troca ([saída](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-09/evidencias/ecr-rollback.txt))
- [x] Workflow de AI Review disparando em PRs — [`.github/workflows/ai-review.yml`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/.github/workflows/ai-review.yml) + [`.github/scripts/ai-review.js`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/.github/scripts/ai-review.js) (18 padrões, comentário em tabela por severidade, atualizado a cada push)
- [x] Quality gate (CRITICAL bloqueia o PR) — step *Quality gate* com `exit 1` e check `ai-review` obrigatório na proteção da `main`; WARNING/INFO não bloqueiam
- [x] `ia-cicd-analise.md` preenchido — [`aula-09/ia-cicd-analise.md`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-09/ia-cicd-analise.md)
- [x] Screenshots (console ECR com as tags, AI review, pipeline verde, gate bloqueando) — pasta [`aula-09/screenshots/`](https://github.com/Sir-Jr/unifaat-devops-portfolio/tree/main/aula-09/screenshots)

Também implementado: workflow opcional [`.github/workflows/ci.yml`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/.github/workflows/ci.yml)
(lint → test → build-and-push com `configure-aws-credentials@v4` + `amazon-ecr-login@v2`, push só fora de PR).
Bônus: lifecycle policy no ECR, scan on push (26 vulnerabilidades do Alpine → 0, [resultado](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-09/evidencias/ecr-scan.txt)),
comentário atualizado sem duplicar, security scan separado ([`security-scan.yml`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/.github/workflows/security-scan.yml)),
badges no [README da aula](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-09/README.md) e 18 padrões detectados.

## Evidência do Pipeline Rodando

- CI verde publicando no ECR pela git tag `v1.0.0`: https://github.com/Sir-Jr/unifaat-devops-portfolio/actions/runs/40152172054
- Quality gate bloqueando (run do AI review que falhou com 4 CRITICAL): https://github.com/Sir-Jr/unifaat-devops-portfolio/actions/runs/40150242656
- PR de teste do AI review (hoje mostra o estado final: arquivo removido → comentário atualizado para ✅): https://github.com/Sir-Jr/unifaat-devops-portfolio/pull/2
- PR liberado pelo gate (sem CRITICAL): https://github.com/Sir-Jr/unifaat-devops-portfolio/pull/3

| Screenshot | Conteúdo |
|------------|----------|
| [ecr-console.png](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-09/screenshots/ecr-console.png) | repositório `technova-api` no console do ECR com as tags |
| [ai-review-comment.png](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-09/screenshots/ai-review-comment.png) | comentário do AI review no PR com os achados |
| [ecr-push-ok.png](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-09/screenshots/ecr-push-ok.png) | `ecr-push.sh` concluído publicando a release 1.0.0 |
| [quality-gate-block.png](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-09/screenshots/quality-gate-block.png) | PR bloqueado pelo check `ai-review` (CRITICAL) |
