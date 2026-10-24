# Entrega — Aula 10: Terraform Automatizado e CD Pipelines

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 23/10/2026

## Repositório

- URL: https://github.com/gabrielreis354/unifaat-devops-portfolio
- Projeto da aula: [`aula-10/`](https://github.com/gabrielreis354/unifaat-devops-portfolio/tree/main/aula-10) (`terraform/`, `technova-api/` com Dockerfile multi-stage, `gitops-cd-analise.md`, `docs/runbook-rollback.md`, `screenshots/`, `README.md`)
- Workflows: [`terraform-plan.yml`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/.github/workflows/terraform-plan.yml), [`terraform-apply.yml`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/.github/workflows/terraform-apply.yml), [`cd.yml`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/.github/workflows/cd.yml) (e `terraform-destroy.yml`, `aws-check.yml`). Ficam na **raiz** do repositório porque o GitHub só executa workflows de lá (combinado com o professor); `aula-10/README.md` mapeia onde cada arquivo está.

## Evidências

- [x] Workflow `terraform-plan.yml` postando o plan como comentário no PR — PR [#11](https://github.com/gabrielreis354/unifaat-devops-portfolio/pull/11) (4 to add) e PR [#12](https://github.com/gabrielreis354/unifaat-devops-portfolio/pull/12) (`Plan: 1 to add, 0 to change, 0 to destroy`); comentário atualizado em vez de duplicado, com `fmt -check` e aviso de destroy
- [x] Workflow `terraform-apply.yml` aplicando no merge para main — [run 40049192443](https://github.com/gabrielreis354/unifaat-devops-portfolio/actions/runs/40049192443): `Apply complete! Resources: 1 added, 0 changed, 0 destroyed.` (regra 443 confirmada por `aws ec2 describe-security-group-rules`); o merge do PR #11 aplicou a infra base (4 added)
- [x] Autenticação na AWS via credenciais temporárias de sessão do Lab (secrets) — `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` com `aws-actions/configure-aws-credentials@v4`; OIDC × Lab explicado em `gitops-cd-analise.md`; os secrets foram removidos ao final
- [x] Pipeline CD completo: lint → test → build → push (ECR) → deploy — [run 40049695435](https://github.com/gabrielreis354/unifaat-devops-portfolio/actions/runs/40049695435), imagem `sha-64c147f` + `latest` no ECR
- [x] Deploy Recreate via SSH na EC2 (login ECR antes do pull) — job `deploy` com `appleboy/ssh-action`: `aws ecr get-login-password` → `docker pull` → `stop` → `rm` → `run`; a EC2 usa o `LabInstanceProfile`
- [x] Health check pós-deploy funcionando — `Health check OK (HTTP 200) na tentativa 1` e `/version` com o commit implantado (falha o job após 20 tentativas)
- [x] `gitops-cd-analise.md` preenchido — [`aula-10/gitops-cd-analise.md`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/aula-10/gitops-cd-analise.md) (inclui tags, `.gitignore`/`git ls-files`, rollback real e destroy)
- [x] Screenshots (plan no PR, apply após merge, pipeline CD verde, health check) — [`aula-10/screenshots/`](https://github.com/gabrielreis354/unifaat-devops-portfolio/tree/main/aula-10/screenshots): `plan-pr-comment.png`, `apply-success.png`, `cd-pipeline-green.png`, `health-check-pass.png`

## Evidência do Pipeline Rodando

- Plan no PR: [PR #11](https://github.com/gabrielreis354/unifaat-devops-portfolio/pull/11) e [PR #12](https://github.com/gabrielreis354/unifaat-devops-portfolio/pull/12)
- Apply após merge: https://github.com/gabrielreis354/unifaat-devops-portfolio/actions/runs/40049192443
- CD completo (lint → test → build → push → deploy → health check): https://github.com/gabrielreis354/unifaat-devops-portfolio/actions/runs/40049695435
- Rollback executado (`sha-64c147f` 1.1.0 → `sha-d88b6d4` 1.0.1) conforme [`docs/runbook-rollback.md`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/aula-10/docs/runbook-rollback.md); `/version` voltou a 1.0.1, confirmado por `curl` externo
- Tags `Project/Environment/ManagedBy/Aula/Name` em EC2, SG, key pair, volume e ECR (`describe-tags`), key pair automatizado (`aws_key_pair` com a `.pub` versionada) e `git ls-files` sem state/segredos: ver `gitops-cd-analise.md`
- Destroy: [run 40050125833](https://github.com/gabrielreis354/unifaat-devops-portfolio/actions/runs/40050125833) — `Destroy complete! Resources: 5 destroyed.`; sem EC2/ECR/SG/key pair/volumes (conferido por CLI) e bucket de state removido
- Bônus: comentário do plan atualizado (não duplicado), `terraform fmt -check`, `GITHUB_SHA` no container, aviso de destroy no plan, notificação por comentário no commit, workflow de destroy manual com confirmação e GitHub Environments (`production`, `destroy`)
