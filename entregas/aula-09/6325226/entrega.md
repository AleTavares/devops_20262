# Entrega — Aula 09: Docker Registry e IA no CI/CD

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 2026-10-23

## Repositório

- URL: https://github.com/lucaskenway/unifaat-devops-portfolio
- Código: [`aula-09/`](https://github.com/lucaskenway/unifaat-devops-portfolio/tree/main/aula-09)
- Workflows: [`ci-aula09.yml`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/.github/workflows/ci-aula09.yml) · [`ai-review-aula09.yml`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/.github/workflows/ai-review-aula09.yml) · [`security-scan-aula09.yml`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/.github/workflows/security-scan-aula09.yml)
- Push no ECR: [`ecr-push.sh`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-09/technova-api/ecr-push.sh) · rollback: [`ecr-rollback.sh`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-09/technova-api/ecr-rollback.sh) · [`ecr-lifecycle-policy.json`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-09/technova-api/ecr-lifecycle-policy.json)
- Script de análise: [`.github/scripts/ai-review.js`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/.github/scripts/ai-review.js)
- Análise: [`aula-09/ia-cicd-analise.md`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-09/ia-cicd-analise.md)
- Relatório do TF: [`aula-09/relatorio-tf.md`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-09/relatorio-tf.md)
- Imagem: `<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/technova-api` (Amazon ECR, AWS Academy Learner Lab)

[![CI Pipeline — Aula 09](https://github.com/lucaskenway/unifaat-devops-portfolio/actions/workflows/ci-aula09.yml/badge.svg)](https://github.com/lucaskenway/unifaat-devops-portfolio/actions/workflows/ci-aula09.yml)

## Evidências

- [x] Script `ecr-push.sh` publicando no **Amazon ECR** com tags (sha, latest, semver)
- [x] Repositório ECR `technova-api` criado no Learner Lab (`us-east-1`)
- [x] Pull da imagem a partir do ECR funcionando (rollback por tag)
- [x] Workflow de AI Review disparando em PRs
- [x] Quality gate (CRITICAL bloqueia o PR)
- [x] `ia-cicd-analise.md` preenchido
- [x] Screenshots (tags no ECR, AI review, pipeline verde, gate bloqueando)

### Bônus

- [x] Lifecycle policy no ECR (`ecr-lifecycle-policy.json`: expira untagged em 1 dia, mantém os 15 builds `sha-` mais recentes)
- [x] Scan de vulnerabilidades do ECR habilitado (`scan on push`): release `1.0.0` com scan `COMPLETE` e 0 achados
- [x] Comentário atualizado (não duplicado) em novos pushes ao PR
- [x] Security scan separado (`security-scan-aula09.yml`: npm audit + Trivy config + Trivy image)
- [x] Badge de status no README
- [x] Mais de 8 padrões detectados pelo AI review (20 regras)
- [x] Camada opcional de LLM no **Amazon Bedrock** (Converse API) com fallback para as regras. No Learner Lab, nenhum modelo pode ser chamado: os liberados estão descontinuados e os atuais dão `AccessDenied` (teste documentado)
- [x] Dockerfile sem achados no Trivy (0 CRITICAL / 0 HIGH / 0 MEDIUM na imagem; 0 misconfig)

## Evidência do Pipeline Rodando

### Execução no Learner Lab (2026-10-15, conta `844303000847`, `us-east-1`)

| Imagem (digest) | Tags no ECR | Scan on push |
|-----------------|-------------|--------------|
| `sha256:488caadc3122…` | `1.0.0`, `1.0`, `1`, `latest`, `sha-7317d71` (git tag `v1.0.0`) | `COMPLETE`, 0 achados |
| `sha256:d2f0f0b561ce…` | `sha-7131e31` (build anterior) | — |

- `./ecr-push.sh`: criou o repositório (scan on push + lifecycle policy), fez login e publicou `sha-7131e31` + `latest`
- `./ecr-push.sh` com a git tag `v1.0.0`: publicou `1.0.0`, `1.0`, `1`, `sha-7317d71` e `latest` com o mesmo digest
- `./ecr-rollback.sh`: `1.0.0` → `sha-7131e31` → `1.0.0`, sempre com pull do ECR e `/health` OK
- Logs completos (TXT + PNG renderizado, com SHA-256): [`evidencias/2026-10-15_211523_aula-09-ecr-push-semver-rollback/`](https://github.com/lucaskenway/unifaat-devops-portfolio/tree/main/evidencias/2026-10-15_211523_aula-09-ecr-push-semver-rollback)

### Pipelines no GitHub Actions (2026-10-23)

O Learner Lab trocou de conta entre as sessões (agora `721003528272`); o pipeline publica na conta da sessão atual sem mudança de código.

- CI verde na `main` (lint → test → build → push no ECR): https://github.com/lucaskenway/unifaat-devops-portfolio/actions/runs/39971991882
- AI review com achados e quality gate bloqueando (PR de demonstração, fechado sem merge): https://github.com/lucaskenway/unifaat-devops-portfolio/pull/10 · run do gate: https://github.com/lucaskenway/unifaat-devops-portfolio/actions/runs/39976721102
- AI review em PR real (7 WARNING, gate aprovado): https://github.com/lucaskenway/unifaat-devops-portfolio/pull/5
- `ecr-push.sh` publicando `sha-`, `latest` e `1.0.0`/`1.0`/`1`: ver screenshots abaixo

### Screenshots

| Evidência | Arquivo |
|-----------|---------|
| Repositório ECR com as tags (`aws ecr describe-images`, imagem renderizada — o console exige login no AWS Academy) | [`ecr-tags.png`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-09/screenshots/ecr-tags.png) |
| `ecr-push.sh` concluído | [`ecr-push-ok.png`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-09/screenshots/ecr-push-ok.png) |
| Comentário do AI review | [`ai-review-comment.png`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-09/screenshots/ai-review-comment.png) |
| Quality gate bloqueando | [`quality-gate-block.png`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-09/screenshots/quality-gate-block.png) |

![Tags no ECR](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-09/screenshots/ecr-tags.png)
![ecr-push.sh concluído](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-09/screenshots/ecr-push-ok.png)
![Comentário do AI review](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-09/screenshots/ai-review-comment.png)
![Quality gate bloqueando](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-09/screenshots/quality-gate-block.png)

## Trabalho em Aula e Trabalho Anterior

- [`trabalho-em-aula.md`](trabalho-em-aula.md)
- [`trabalho-anterior.md`](trabalho-anterior.md)
