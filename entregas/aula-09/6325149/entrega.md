# Entrega — Aula 09: Docker Registry e IA no CI/CD

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 23/10/2026

## Repositório

- URL: https://github.com/gabrielreis354/unifaat-devops-portfolio
- Projeto da aula: [`aula-09/`](https://github.com/gabrielreis354/unifaat-devops-portfolio/tree/main/aula-09) (`ecr-push.sh`, `technova-api/` com Dockerfile multi-stage, `ia-cicd-analise.md`, `screenshots/`, `README.md`)
- Workflows e script do AI review: [`.github/workflows/ai-review.yml`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/.github/workflows/ai-review.yml), [`security-scan.yml`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/.github/workflows/security-scan.yml) e [`.github/scripts/ai-review.js`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/.github/scripts/ai-review.js). Ficam na **raiz** do repositório porque o GitHub só executa workflows de lá (combinado com o professor).

## Evidências

- [x] Script `ecr-push.sh` publicando no **Amazon ECR** com tags (sha, latest, semver)
- [x] Repositório ECR `technova-api` criado no Learner Lab (`us-east-1`)
- [x] Pull da imagem a partir do ECR funcionando (rollback por tag)
- [x] Workflow de AI Review disparando em PRs
- [x] Quality gate (CRITICAL bloqueia o PR)
- [x] `ia-cicd-analise.md` preenchido
- [x] Screenshots (console ECR com as tags, AI review, pipeline verde, gate bloqueando)

## Evidência do Pipeline Rodando

Execução em 23/10/2026, Learner Lab, identidade `assumed-role/voclabs` (não root), região `us-east-1`.

### 1. ECR: repositório, tags e scan

[`ecr-push.sh`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/aula-09/ecr-push.sh): garante o repositório (idempotente, `scanOnPush=true`), aplica a lifecycle policy, faz `aws ecr get-login-password | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com`, builda (multi-stage) e publica. As tags semver saem da git tag `vX.Y.Z` do `HEAD`.

| Release | Commit | Tags no ECR |
|---------|--------|-------------|
| `v1.0.0` | `499d3ff` | `sha-499d3ff`, `latest`, `1.0.0`, `1.0`, `1` |
| `v1.0.1` | `4a7900e` | `sha-4a7900e`, `latest`, `1.0.1`, `1.0`, `1` (as tags móveis passam para o novo digest `a16a6eb6…`; `1.0.0` e `sha-499d3ff` ficam no digest `2c2f7a15…`) |

- Repositório: `technova-api`, `scanOnPush=True`. Lifecycle policy: expira imagens sem tag após 1 dia e mantém só as 10 mais recentes com tag.
- **Pull e rollback:** `docker pull <ECR>/technova-api:1.0.1` + `docker run` + `curl /health` → **HTTP 200** (usuário `technova`); rollback `docker pull …:1.0.0` → **HTTP 200**.
- **Scan do ECR** (`describe-image-scan-findings`, `1.0.1`): status `COMPLETE`, **0 achados**. Também escaneei a imagem com o **Trivy**: o Dockerfile inicial tinha 27 vulnerabilidades HIGH/CRITICAL (4 no Alpine e 23 no npm embutido na imagem base); após `apk upgrade` e a remoção do npm/npx do runtime, ficou **0** (e 0 secrets).
- **Problema encontrado e corrigido:** a `1.0.0` foi publicada como índice OCI (Docker 29 inclui um manifesto de attestation) e o ECR recusou o scan (`UnsupportedImageTypeException`). O [PR #8](https://github.com/gabrielreis354/unifaat-devops-portfolio/pull/8) passou o build para `--provenance=false --sbom=false`; a `1.0.1` é escaneável. A `1.0.0` segue disponível para pull e rollback.
- **Custos:** terminadas as evidências, o repositório foi apagado (`aws ecr delete-repository --force`) e `aws ecr describe-repositories` retornou `[]`.

### 2. AI Review e Quality Gate (PRs no portfólio)

- [PR #7](https://github.com/gabrielreis354/unifaat-devops-portfolio/pull/7) (feature): AI Code Review e Security Scan verdes; comentário com 1 WARNING (`console.log` do `server.js` copiado), sem CRITICAL → gate passa. Runs: [AI Review 40045196416](https://github.com/gabrielreis354/unifaat-devops-portfolio/actions/runs/40045196416), [Security Scan 40045196589](https://github.com/gabrielreis354/unifaat-devops-portfolio/actions/runs/40045196589).
- [PR #9](https://github.com/gabrielreis354/unifaat-devops-portfolio/pull/9) (demonstração, fechado sem merge): 1º push só com WARNING/INFO (3 achados, check verde, run [40046542342](https://github.com/gabrielreis354/unifaat-devops-portfolio/actions/runs/40046542342)); 2º push com secrets, SQL injection e `eval()` → **7 achados (4 CRITICAL)**, o **mesmo comentário foi atualizado** (um só) e os checks **falharam** (`exit 1`): runs [AI Review 40046592014](https://github.com/gabrielreis354/unifaat-devops-portfolio/actions/runs/40046592014) e [Security Scan 40046592146](https://github.com/gabrielreis354/unifaat-devops-portfolio/actions/runs/40046592146).
- Script: 11 padrões (6 CRITICAL, 4 WARNING, 1 INFO) com 28 testes (`node --test`, 28/28). Lógica do gate, prompt, limitações e a justificativa do ECR no [`ia-cicd-analise.md`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/aula-09/ia-cicd-analise.md).
- O Bedrock não é usado: o Learner Lab não o disponibiliza (confirmado pelo professor; testei antes: `AccessDenied` para `ListFoundationModels` e `InvokeModel`). A análise é por regras (Opção A).

### 3. Screenshots

| Evidência | Arquivo |
|-----------|---------|
| Console do ECR com as tags (sha, latest, semver) | [`ecr-console.png`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/aula-09/screenshots/ecr-console.png) |
| Execução do `ecr-push.sh` concluída | [`ecr-push-ok.png`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/aula-09/screenshots/ecr-push-ok.png) |
| Comentário do AI review no PR | [`ai-review-comment.png`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/aula-09/screenshots/ai-review-comment.png) |
| Quality gate bloqueando o PR (CRITICAL) | [`quality-gate-block.png`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/aula-09/screenshots/quality-gate-block.png) |

### Bônus

Lifecycle policy no ECR; scan on push com resultado; comentário atualizado (não duplicado); security scan separado ([`security-scan.yml`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/.github/workflows/security-scan.yml)); badges no [README da aula](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/aula-09/README.md); 11 padrões no AI review (> 8); Dockerfile com 0 vulnerabilidades no Trivy.
