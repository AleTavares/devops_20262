# Entrega — Aula 10: Terraform Automatizado e CD Pipelines

**Aluno:** Hector Marcelo Pedroso dos Santos
**RA:** 6125136
**Data:** 2026-11-14

## Repositório

- URL: https://github.com/hectorbackfront/unifaat-devops-portfolio
- Projeto: pasta `aula-10/` (workflows em `.github/workflows/` na raiz do repositório, pois o GitHub Actions só lê dali)

## Evidências

- [x] Workflow `terraform-plan.yml` postando o plan como comentário no PR — PR #3, comentário com `Plan: 3 to add, 0 to change, 0 to destroy`
- [x] Workflow `terraform-apply.yml` aplicando no merge para main — `Apply complete! Resources: 3 added`
- [x] Autenticação na AWS via credenciais temporárias de sessão do Lab (secrets) — `configure-aws-credentials@v4` com as 3 credenciais
- [x] Pipeline CD completo: lint → test → build → push (ECR) → deploy — verde, 52s
- [x] Deploy Recreate via SSH na EC2 (login ECR antes do pull) — `appleboy/ssh-action`
- [x] Health check pós-deploy funcionando — com retry: falhou na tentativa 1 e passou na 2
- [x] `gitops-cd-analise.md` preenchido — `aula-10/gitops-cd-analise.md`
- [x] Screenshots (plan no PR, apply após merge, pipeline CD verde, health check) — `aula-10/screenshots/`

Também entregues: `docs/runbook-rollback.md` (rollback **testado** na EC2: `sha-01aee39` → `sha-8a0d4fd` → `sha-01aee39`) e `README.md` com o passo a passo.

Bônus implementados: `terraform fmt -check` no plan; comentário do plan atualizado em vez de duplicado (marcador no comentário); detecção de destroy com aviso no comentário; imagem rastreável por SHA (`sha-<commit>`) e `GIT_SHA` no container.

Não feito / limitações: o aviso de destroy não exige aprovação extra, e o comentário atualizado e a detecção de destroy não foram exercitados (o plan só teve criações); sem GitHub Environment com aprovação, notificação de deploy, Infracost nem workflow de destroy. No Lab não há OIDC, por isso o `oidc.tf` não existe (explicado no `gitops-cd-analise.md`).

## Evidência do Pipeline Rodando

- PR do fluxo GitOps (plan comentado e merge): https://github.com/hectorbackfront/unifaat-devops-portfolio/pull/3
- Terraform Plan (verde): https://github.com/hectorbackfront/unifaat-devops-portfolio/actions/runs/43651167039
- Terraform Apply no merge (verde): https://github.com/hectorbackfront/unifaat-devops-portfolio/actions/runs/43652771284
- CD Pipeline completo (verde, por push na master): https://github.com/hectorbackfront/unifaat-devops-portfolio/actions/runs/43654674886

Histórico honesto: o primeiro plan falhou (bucket de state da aula 05 apagado pelo reset do Lab; recriado), e o primeiro CD falhou no deploy por falta do secret `EC2_HOST` e pela opção `script_stop`, que não existe mais no ssh-action. Ambos foram corrigidos e os runs acima são os verdes.

Screenshots (em `aula-10/screenshots/` do portfólio): `plan-pr-comment.png`, `apply-success.png`, `cd-pipeline-green.png`, `health-check-pass.png`.
