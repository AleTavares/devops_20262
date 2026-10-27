# Entrega — Aula 10: Terraform Automatizado e CD Pipelines

**Aluno:** Carina Dal Pino
**RA:** 6325109
**Data:** 22/10/2026

## Repositório

- URL: https://github.com/CarinaDalpino/unifaat-devops-portfolio (pasta `aula-10/`)

## Evidências

- [x] Workflow `terraform-plan.yml` postando o plan como comentário no PR
- [x] Workflow `terraform-apply.yml` aplicando no merge para main
- [x] Autenticação na AWS via credenciais temporárias de sessão do Lab (secrets)
- [x] Pipeline CD completo: lint → test → build → push (ECR) → deploy
- [x] Deploy Recreate via SSH na EC2 (login ECR antes do pull)
- [x] Health check pós-deploy funcionando
- [x] `gitops-cd-analise.md` preenchido
- [x] Screenshots (plan no PR, apply após merge, pipeline CD verde, health check)

## Estrutura entregue no portfólio

```
unifaat-devops-portfolio/
├── .github/workflows/
│   ├── terraform-plan.yml    # plan on PR (comenta no PR)
│   ├── terraform-apply.yml   # apply on merge
│   └── cd.yml                # lint→test→build→push(ECR)→deploy(EC2)
└── aula-10/
    ├── terraform/            # provider(backend S3), variables, main(VPC/SG/EC2/ECR), outputs
    ├── technova-api/         # app + Dockerfile multi-stage
    ├── docs/runbook-rollback.md
    ├── gitops-cd-analise.md
    ├── screenshots/
    └── README.md
```

## Validação local realizada

- `terraform fmt -check` → OK
- `terraform validate` → "Success! The configuration is valid."
- Aplicação (`technova-api`): lint, testes e docker build validados na Aula 09 (mesma base)

## Observação (AWS Academy Learner Lab)

A autenticação do GitHub Actions usa as 3 credenciais temporárias de sessão do Lab
(`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`) como secrets.
O Lab não permite criar OIDC provider nem roles IAM — o padrão OIDC + role (ideal
em produção) fica documentado como referência no `gitops-cd-analise.md`.

## Evidência do Pipeline Rodando

Executado de verdade no AWS Academy Learner Lab (Account 688770970340, região us-east-1):

- **CD Pipeline** (lint → test → build-push ECR → deploy EC2 → health check): **sucesso** — https://github.com/CarinaDalpino/unifaat-devops-portfolio/actions/workflows/cd.yml
- **Terraform Apply** (via merge/dispatch): **sucesso** — https://github.com/CarinaDalpino/unifaat-devops-portfolio/actions/workflows/terraform-apply.yml
- **Terraform Plan no PR** (comentário automático): PR #4 — https://github.com/CarinaDalpino/unifaat-devops-portfolio/pull/4
- **Imagem no ECR:** `688770970340.dkr.ecr.us-east-1.amazonaws.com/technova-api` (tags `latest` + `sha-...`)
- **Aplicação no ar na EC2:** `http://34.224.39.161:3000/health` → `{"status":"ok"}`

Screenshots em `aula-10/screenshots/` do portfólio:
`plan-pr-comment.png`, `cd-pipeline-green.png`, `health-check-pass.png`, `apply-success.png`.

> Observação: o IP da EC2 e as credenciais do Lab são temporários (expiram ao
> encerrar a sessão). As evidências/screenshots foram capturadas com o Lab ativo.
