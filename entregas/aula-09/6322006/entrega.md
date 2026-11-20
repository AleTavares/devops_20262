# Entrega — Aula 09: Docker Registry e IA no CI/CD

**Aluno:** Rafael Nogueira Maruca
**RA:** 6322006
**Data:** 19/11/2026

## Repositório

- URL: https://github.com/rafadical/unifaat-devops-portfolio
- Pasta da aula: [`aula-09/`](https://github.com/rafadical/unifaat-devops-portfolio/tree/main/aula-09) (README com a situação de cada parte)
- Workflows: [`ai-review.yml`](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/.github/workflows/ai-review.yml), [`ci-aula09.yml`](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/.github/workflows/ci-aula09.yml), [`security-scan.yml`](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/.github/workflows/security-scan.yml)
- Script de análise: [`.github/scripts/ai-review.js`](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/.github/scripts/ai-review.js) (+ [8 testes](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/.github/scripts/ai-review.test.js))
- Análise: [`aula-09/ia-cicd-analise.md`](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-09/ia-cicd-analise.md)

## Evidências

- [ ] Script `ecr-push.sh` publicando no **Amazon ECR** com tags (sha, latest, semver) — script pronto ([`aula-09/ecr-push.sh`](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-09/ecr-push.sh)), **não executado na AWS** (sessão do Learner Lab expirada na data da entrega)
- [ ] Repositório ECR `technova-api` criado no Learner Lab (`us-east-1`) — criado pelo próprio script (idempotente, `scanOnPush`, lifecycle policy); não executado
- [ ] Pull da imagem a partir do ECR funcionando (rollback por tag) — [`aula-09/ecr-rollback.sh`](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-09/ecr-rollback.sh) e job `rollback` prontos; não executados
- [x] Workflow de AI Review disparando em PRs — [PR #3](https://github.com/rafadical/unifaat-devops-portfolio/pull/3)
- [x] Quality gate (CRITICAL bloqueia o PR) — [execução bloqueada](https://github.com/rafadical/unifaat-devops-portfolio/actions/runs/44637843540) e [execução liberada](https://github.com/rafadical/unifaat-devops-portfolio/actions/runs/44638112212)
- [x] `ia-cicd-analise.md` preenchido
- [ ] Screenshots — substituídos pelos links das execuções e pelos trechos de log em [`aula-09/evidencias/`](https://github.com/rafadical/unifaat-devops-portfolio/tree/main/aula-09/evidencias)

### Bônus

- [x] Lifecycle policy no ECR (no `ecr-push.sh`: expira untagged em 1 dia, mantém as 20 mais recentes) — não executada
- [x] Scan on push habilitado na criação do repositório — não executado
- [x] Comentário atualizado (não duplicado) em novos pushes ao PR — o PR #3 tem **1** comentário do bot, atualizado no 2º push
- [x] Security scan separado — [`security-scan.yml`](https://github.com/rafadical/unifaat-devops-portfolio/actions/runs/44637981706) (npm audit + Trivy), que encontrou e levou à correção de uma vulnerabilidade HIGH real no `body-parser`
- [x] Badges de status no README da aula
- [x] Mais de 8 padrões: **16** (8 CRITICAL, 6 WARNING, 2 INFO)

## Evidência do Pipeline Rodando

| Execução | Resultado | Log |
|---|---|---|
| [AI review — 1º push do PR #3](https://github.com/rafadical/unifaat-devops-portfolio/actions/runs/44637843540) | ❌ gate bloqueou: 4 CRITICAL, 2 WARNING, 1 INFO | [ai-review-bloqueado.txt](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-09/evidencias/ai-review-bloqueado.txt) |
| [AI review — 2º push (CRITICAL corrigidos)](https://github.com/rafadical/unifaat-devops-portfolio/actions/runs/44638112212) | ✅ gate liberou: 0 CRITICAL; comentário atualizado | [ai-review-aprovado.txt](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-09/evidencias/ai-review-aprovado.txt) |
| [Security scan](https://github.com/rafadical/unifaat-devops-portfolio/actions/runs/44637981706) | ✅ npm audit 0 vulnerabilidades; Trivy sem misconfig HIGH/CRITICAL | [security-scan.txt](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-09/evidencias/security-scan.txt) |
| [CI + ECR](https://github.com/rafadical/unifaat-devops-portfolio/actions/runs/44642884284) | ✅ lint e testes; push no ECR pulado (sem sessão do Lab) | — |

Trecho do log do quality gate bloqueando:

```
Achados: 7 (CRITICAL 4, WARNING 2, INFO 1)
  [CRITICAL] aula-09/demo-ai-review/relatorio-pedidos.js:5 hardcoded-secret
  [CRITICAL] aula-09/demo-ai-review/relatorio-pedidos.js:8 eval
  [CRITICAL] aula-09/demo-ai-review/relatorio-pedidos.js:9 sql-injection
  [CRITICAL] aula-09/demo-ai-review/relatorio-pedidos.js:13 command-injection
  [WARNING] aula-09/demo-ai-review/relatorio-pedidos.js:15 console-log
  [WARNING] aula-09/demo-ai-review/relatorio-pedidos.js:16 empty-catch
  [INFO] aula-09/demo-ai-review/relatorio-pedidos.js:17 todo
##[error]Quality gate: 4 achado(s) CRITICAL. Corrija antes do merge.
```

**Sobre o ECR:** a parte de registry não foi executada porque a sessão do AWS Academy Learner Lab estava expirada. O código está pronto para rodar assim que houver sessão válida (`./ecr-push.sh` localmente, ou a variável `ECR_ENABLED=true` no repositório para o GitHub Actions publicar).
