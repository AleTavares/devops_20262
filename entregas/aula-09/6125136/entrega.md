# Entrega — Aula 09: Docker Registry e IA no CI/CD

**Aluno:** Hector Marcelo Pedroso dos Santos
**RA:** 6125136
**Data:** 2026-10-23

## Repositório

- URL: https://github.com/hectorbackfront/unifaat-devops-portfolio

## Evidências

- [x] Script `ecr-push.sh` publicando no **Amazon ECR** com tags (sha, latest, semver) — `aula-09/ecr-push.sh`
- [x] Repositório ECR `technova-api` criado no Learner Lab (`us-east-1`)
- [x] Pull da imagem a partir do ECR funcionando (rollback por tag `1.0.0`)
- [x] Workflow de AI Review disparando em PRs — `.github/workflows/ai-review-aula09.yml` (`aula-09/.github/scripts/ai-review.js`)
- [x] Quality gate (CRITICAL bloqueia o PR): o check falhou no PR #2
- [x] `ia-cicd-analise.md` preenchido — `aula-09/ia-cicd-analise.md`
- [x] Screenshots (console ECR com as tags, AI review, pipeline verde, gate bloqueando) — `aula-09/screenshots/`

Bônus: lifecycle policy no ECR, comentário do AI review atualizado (não duplicado), 13 padrões de detecção.

Não feito: `ci.yml` com push automático ao ECR, badge, workflow de segurança separado, Dockerfile com score A. O scan on push está ligado no repositório, mas o ECR não retornou resultado de scan para a imagem, então não há evidência.

## Evidência do Pipeline Rodando

- PR de demonstração do quality gate: https://github.com/hectorbackfront/unifaat-devops-portfolio/pull/2
- Execução do AI Review que **bloqueou** o PR (CRITICAL): https://github.com/hectorbackfront/unifaat-devops-portfolio/actions/runs/39880155109
- Execução do AI Review que **liberou** o PR após a correção (check verde): https://github.com/hectorbackfront/unifaat-devops-portfolio/actions/runs/39962673044
- Aba Actions: https://github.com/hectorbackfront/unifaat-devops-portfolio/actions

Ciclo no PR #2:
1. PR aberto com um arquivo inseguro de propósito (`demo-gate.js`): **3 CRITICAL** (secret hardcoded, `eval()`, SQL injection) e 3 WARNING; check vermelho, PR bloqueado.
2. Remoção do arquivo: check **verde** (0 CRITICAL, 1 WARNING), pois WARNING não bloqueia.
3. Nos dois casos o comentário do bot foi **atualizado**, não duplicado.

Tags publicadas na mesma imagem: `sha-d7ed469`, `latest`, `1.0.0`, `1.0`, `1`.

Screenshots: `ecr-console.png`, `ecr-push-ok.png`, `ecr-rollback-pull.png`, `ai-review-comment.png`, `quality-gate-block.png`, `actions-runs.png`, `codex-review-lifecycle.png`.
