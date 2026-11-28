# Entrega — Aula 10: Terraform Automatizado e CD Pipelines

**Aluno:** Rafael Nogueira Maruca
**RA:** 6322006
**Data:** 25/10/2026

## Repositório

- URL: https://github.com/rafadical/unifaat-devops-portfolio
- Pasta da aula: [`aula-10/`](https://github.com/rafadical/unifaat-devops-portfolio/tree/main/aula-10)
- Workflows: [`.github/workflows/`](https://github.com/rafadical/unifaat-devops-portfolio/tree/main/.github/workflows) — `terraform-plan.yml`, `terraform-apply.yml`, `cd.yml`

## Evidências

- [x] Workflow `terraform-plan.yml` postando o plan como comentário no PR — [PR #1](https://github.com/rafadical/unifaat-devops-portfolio/pull/1)
- [x] Workflow `terraform-apply.yml` aplicando no merge para main — [run 40244007318](https://github.com/rafadical/unifaat-devops-portfolio/actions/runs/40244007318)
- [x] Autenticação na AWS via credenciais temporárias de sessão do Lab (secrets `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`)
- [x] Pipeline CD completo: lint → test → build → push (ECR) → deploy — [run 40243739843](https://github.com/rafadical/unifaat-devops-portfolio/actions/runs/40243739843)
- [x] Deploy Recreate via SSH na EC2 (login ECR antes do pull)
- [x] Health check pós-deploy funcionando (`/health` 200 e commit confirmado em `/version`)
- [x] [`gitops-cd-analise.md`](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-10/gitops-cd-analise.md) preenchido
- [x] Evidências dos logs em [`aula-10/evidencias/`](https://github.com/rafadical/unifaat-devops-portfolio/tree/main/aula-10/evidencias)

## Evidência do Pipeline Rodando

| Etapa | Execução no GitHub Actions | Trecho do log |
|---|---|---|
| Apply inicial — 11 recursos (VPC, SG, EC2, EIP, ECR...) | [40243554160](https://github.com/rafadical/unifaat-devops-portfolio/actions/runs/40243554160) | [apply-initial.txt](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-10/evidencias/apply-initial.txt) |
| CD: lint → test → build/push ECR → deploy → health check | [40243739843](https://github.com/rafadical/unifaat-devops-portfolio/actions/runs/40243739843) | [cd-pipeline.txt](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-10/evidencias/cd-pipeline.txt) |
| Plan comentado no PR | [PR #1](https://github.com/rafadical/unifaat-devops-portfolio/pull/1) | [plan-pr-comment.md](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-10/evidencias/plan-pr-comment.md) |
| Apply após merge (regra HTTPS 443) | [40244007318](https://github.com/rafadical/unifaat-devops-portfolio/actions/runs/40244007318) | [apply-after-merge.txt](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-10/evidencias/apply-after-merge.txt) |

Resumo do health check (log do job de deploy):

```
Health check passou (HTTP 200) na tentativa 1
Versao confirmada: f11e74852ce6d2055da554fa0922cb6c1f865337
```

Observação: durante a revisão do PR #1, o plan mostrou um problema real (regra `aws_security_group_rule` separada conflitando com as regras inline do SG). A correção foi feita no próprio PR antes do merge. Detalhes no [README da aula](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-10/README.md#execução-real-na-aws-learner-lab-25102026).
