# Entrega — Aula 10: GitOps + CD Pipeline

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 24/10/2026

## Repositório

- Projeto: [unifaat-devops-portfolio](https://github.com/Manntto/unifaat-devops-portfolio)
- Pasta: `aula-10/`
- Workflows: `.github/workflows/terraform-plan.yml`, `terraform-apply.yml`, `cd.yml`

## Checklist de Requisitos

- [x] Workflow `terraform-plan.yml` postando o plan como comentário no PR
- [x] Workflow `terraform-apply.yml` aplicando no merge para main
- [x] Autenticação AWS via credenciais temporárias do Learner Lab
- [x] Pipeline CD: lint → test → build → push ECR → deploy EC2
- [x] Deploy Recreate via SSH (stop → rm → run)
- [x] Health check pós-deploy funcionando
- [x] `gitops-cd-analise.md` preenchido com análise crítica
- [x] 4 screenshots de evidência

## Evidência do Pipeline

```
Lint ✅ → Test ✅ → Build+Push ECR ✅ → Deploy EC2 ✅
Total: 1m0s | Status: Success
EC2: http://34.200.220.13:3000
Health: {"status":"ok","version":"afff4a2...","uptime":294}
```

- Terraform Apply: `Apply complete! Resources: 8 added` (infraestrutura EC2 + VPC)
- Terraform Plan no PR: comentário automático com `Resultado: ✅ success`
