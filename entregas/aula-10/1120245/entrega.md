# Entrega — Aula 10: Terraform Automatizado e CD Pipelines

**Aluno:** Matheus Mantovani
**RA:** 1120245
**Data:** 2026-10-24

## Repositório

- URL: https://github.com/Manntto/unifaat-devops-portfolio
- Pasta: `aula-10/`
- Workflows: `.github/workflows/terraform-plan.yml`, `terraform-apply.yml`, `cd.yml`

## Evidências

- [x] Workflow `terraform-plan.yml` postando o plan como comentário no PR
- [x] Workflow `terraform-apply.yml` aplicando no merge para main (26s, Success)
- [x] Autenticação na AWS via credenciais temporárias de sessão do Lab (secrets)
- [x] Pipeline CD completo: lint → test → build → push (ECR) → deploy (1m0s)
- [x] Deploy Recreate via SSH na EC2 (login ECR → stop → rm → run)
- [x] Health check pós-deploy funcionando (`{"status":"ok"}`)
- [x] `gitops-cd-analise.md` preenchido
- [x] Screenshots: plan no PR, apply após merge, pipeline CD verde, health check

## Evidência do Pipeline Rodando

- **Terraform Plan no PR:** comentário automático com `Resultado: ✅ success`
- **Terraform Apply:** `Apply complete! Resources: 1 changed` — tag Pipeline=gitops adicionada
- **CD Pipeline:** Lint ✅ → Test ✅ → Build+Push ECR ✅ → Deploy EC2 ✅ (1m0s)
- **Health check:** `http://34.200.220.13:3000/health` → `{"status":"ok","version":"...","uptime":...}`
- **Actions:** https://github.com/Manntto/unifaat-devops-portfolio/actions

## Secrets configurados

| Secret | Descrição |
|--------|-----------|
| `AWS_ACCESS_KEY_ID` | Credencial temporária do Learner Lab |
| `AWS_SECRET_ACCESS_KEY` | Credencial temporária do Learner Lab |
| `AWS_SESSION_TOKEN` | Token de sessão do Learner Lab (~4h) |
| `AWS_ACCOUNT_ID` | 864636683316 |
| `EC2_HOST` | 34.200.220.13 |
| `EC2_SSH_KEY` | Chave RSA PEM para SSH na EC2 |

## Screenshots

| Arquivo | Conteúdo |
|---------|----------|
| `plan-pr-comment.png` | PR com comentário do Terraform Plan (success) + merge |
| `apply-success.png` | Terraform Apply verde em 22s após merge |
| `cd-pipeline-green.png` | CD Pipeline com 4 jobs verdes (Lint, Test, Build+Push, Deploy) |
| `health-check-pass.png` | Health check respondendo `{"status":"ok"}` na EC2 |
