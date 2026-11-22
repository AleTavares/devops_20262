# Entrega — Aula 10: Terraform Automatizado e CD Pipelines

**Aluno:** Leonardo Rafael Contini Costa
**RA:** 6325054
**Data:** 29 de outubro

## Repositório

- URL: https://github.com/leonardocontini/unifaat-devops-portfolio

## Evidências

- [x] Workflow `terraform-plan.yml` postando o plan como comentário no PR
- [x] Workflow `terraform-apply.yml` aplicando no merge para main
- [x] Autenticação na AWS via credenciais temporárias de sessão do Lab (secrets)
- [x] Pipeline CD completo: lint → test → build → push (ECR) → deploy
- [x] Deploy Recreate via SSH na EC2 (login ECR antes do pull)
- [x] Health check pós-deploy funcionando
- [x] `gitops-cd-analise.md` preenchido
- [x] Screenshots (plan no PR, apply após merge, pipeline CD verde, health check)

## Evidência do Pipeline Rodando

![evidência](Imagem%20colada.png)