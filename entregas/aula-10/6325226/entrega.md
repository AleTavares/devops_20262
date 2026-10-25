# Entrega — Aula 10: Terraform Automatizado e CD Pipelines

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 2026-10-23

## Repositório

- URL: https://github.com/lucaskenway/unifaat-devops-portfolio
- Pasta: [`aula-10/`](https://github.com/lucaskenway/unifaat-devops-portfolio/tree/main/aula-10)
- Workflows (raiz, onde o GitHub os executa): [`terraform-plan.yml`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/.github/workflows/terraform-plan.yml), [`terraform-apply.yml`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/.github/workflows/terraform-apply.yml), [`cd.yml`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/.github/workflows/cd.yml), [`terraform-destroy.yml`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/.github/workflows/terraform-destroy.yml)

## Trabalho em Aula

- [`trabalho-em-aula.md`](trabalho-em-aula.md) — proteções GitOps, falha de apply pós-merge, prevenção de destroy do RDS e estratégia de deploy por aplicação

## Evidências

- [x] Workflow `terraform-plan.yml` postando o plan como comentário no PR
- [x] Workflow `terraform-apply.yml` aplicando no merge para main
- [x] Autenticação na AWS via credenciais temporárias de sessão do Lab (secrets)
- [x] Pipeline CD completo: lint → test → build → push (ECR) → deploy
- [x] Deploy Recreate via SSH na EC2 (login ECR antes do pull)
- [x] Health check pós-deploy funcionando
- [x] `gitops-cd-analise.md` preenchido
- [x] Screenshots (plan no PR, apply após merge, pipeline CD verde, health check)

Bônus: gate de destroy (label `allow-destroy`), comentário do plan atualizado sem duplicar, `terraform fmt -check`, `GITHUB_SHA` no deploy (conferido via `/version`), notificação por comentário no commit, workflow de destroy manual com environment protegido.

## Evidência do Pipeline Rodando

| O quê | Link |
|-------|------|
| Plan comentado no PR (infra inicial, 10 to add) | https://github.com/lucaskenway/unifaat-devops-portfolio/pull/5 |
| Apply após o merge (10 recursos criados) | https://github.com/lucaskenway/unifaat-devops-portfolio/actions/runs/39970717413 |
| Pipeline CD completo (lint → test → build-push ECR → deploy + health check) | https://github.com/lucaskenway/unifaat-devops-portfolio/actions/runs/39971130945 |
| GitOps end-to-end: PR com regra HTTPS (plan 1 to add) → apply → CD via `workflow_run` | https://github.com/lucaskenway/unifaat-devops-portfolio/pull/8 · https://github.com/lucaskenway/unifaat-devops-portfolio/actions/runs/39972897118 · https://github.com/lucaskenway/unifaat-devops-portfolio/actions/runs/39972962601 |
| Rollback testado (runbook) e retorno à main pelo pipeline | https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-10/docs/runbook-rollback.md#teste-do-procedimento |

**Plan como comentário no PR**

![Plan no PR](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-10/screenshots/plan-pr-comment-https.png)

**Apply executado após o merge**

![Apply após merge](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-10/screenshots/apply-success.png)

**Pipeline CD verde**

![Pipeline CD verde](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-10/screenshots/cd-pipeline-green.png)

**Health check no log do workflow**

![Health check](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-10/screenshots/health-check-pass.png)
