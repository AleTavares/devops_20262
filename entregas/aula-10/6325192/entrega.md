# Entrega — Aula 10: Terraform Automatizado e CD Pipelines

**Aluno:** Emar Cristian Silva Teruo Ito
**RA:** 6325192
**Data:** 22/10/2026

## Repositório

- URL: https://github.com/iHawlKz7/unifaat-devops-portfolio
- Aula 10: https://github.com/iHawlKz7/unifaat-devops-portfolio/tree/main/aula-10

## Evidências

- [x] Workflow Terraform Plan executando em Pull Request e publicando o plan como comentário
- [x] Workflow Terraform Apply executando após merge para `main`
- [x] Autenticação AWS com credenciais temporárias do AWS Academy Learner Lab via GitHub Secrets
- [x] Pipeline CD completo: lint → test → build → push no Amazon ECR → deploy
- [x] Deploy Recreate via SSH na EC2 com login no ECR antes do pull
- [x] Health check pós-deploy funcionando
- [x] `gitops-cd-analise.md` preenchido
- [x] Runbook de rollback documentado
- [x] Quatro screenshots obrigatórios versionados

## Execuções

### Terraform Plan no PR

- PR do portfólio: https://github.com/iHawlKz7/unifaat-devops-portfolio/pull/4
- Comentário automático do plan: https://github.com/iHawlKz7/unifaat-devops-portfolio/pull/4#issuecomment-6354180104
- Screenshot: https://github.com/iHawlKz7/unifaat-devops-portfolio/blob/main/aula-10/screenshots/plan-pr-comment.png

### Terraform Apply após merge

- Workflow: https://github.com/iHawlKz7/unifaat-devops-portfolio/actions/runs/39877278194
- Screenshot: https://github.com/iHawlKz7/unifaat-devops-portfolio/blob/main/aula-10/screenshots/apply-success.png

### CD Pipeline

- Workflow completo: https://github.com/iHawlKz7/unifaat-devops-portfolio/actions/runs/39877278239
- Screenshot: https://github.com/iHawlKz7/unifaat-devops-portfolio/blob/main/aula-10/screenshots/cd-pipeline-green.png

### Health Check

- Job Deploy Recreate / Health Check: https://github.com/iHawlKz7/unifaat-devops-portfolio/actions/runs/39877278239/job/120166157790
- Screenshot: https://github.com/iHawlKz7/unifaat-devops-portfolio/blob/main/aula-10/screenshots/health-check-pass.png

## Arquivos principais

- Análise GitOps/CD: https://github.com/iHawlKz7/unifaat-devops-portfolio/blob/main/aula-10/gitops-cd-analise.md
- Runbook de rollback: https://github.com/iHawlKz7/unifaat-devops-portfolio/blob/main/aula-10/docs/runbook-rollback.md
- Terraform: https://github.com/iHawlKz7/unifaat-devops-portfolio/tree/main/aula-10/terraform
- TechNova API: https://github.com/iHawlKz7/unifaat-devops-portfolio/tree/main/aula-10/technova-api

## Observação sobre autenticação

No AWS Academy Learner Lab foram utilizadas credenciais temporárias de sessão (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` e `AWS_SESSION_TOKEN`) armazenadas como GitHub Secrets.

Em ambiente de produção, a abordagem recomendada seria autenticação via OIDC com IAM Role, evitando chaves armazenadas. O Learner Lab não permite criar os recursos IAM/OIDC necessários.
