# Entrega — Aula 10: Terraform Automatizado e CD Pipelines

**Aluno:** Sirlande Martins
**RA:** 6325269
**Data:** 25/10/2026

## Repositório

- URL: https://github.com/Sir-Jr/unifaat-devops-portfolio

## Evidências

- [x] Workflow `terraform-plan.yml` postando o plan como comentário no PR — [`.github/workflows/terraform-plan.yml`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/.github/workflows/terraform-plan.yml): `fmt -check`, `init`, `validate` e `plan` em PRs que alteram `aula-10/terraform/`; comentário atualizado a cada push; falha se o plan falhar ([PR #4](https://github.com/Sir-Jr/unifaat-devops-portfolio/pull/4))
- [x] Workflow `terraform-apply.yml` aplicando no merge para main — [`.github/workflows/terraform-apply.yml`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/.github/workflows/terraform-apply.yml): a EC2 de produção foi criada pelo apply após o merge do PR #4 ([run](https://github.com/Sir-Jr/unifaat-devops-portfolio/actions/runs/40155338659))
- [x] Autenticação na AWS via credenciais temporárias de sessão do Lab (secrets) — `aws-actions/configure-aws-credentials@v4` com `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` e `AWS_SESSION_TOKEN`; OIDC + role IAM documentado como padrão de produção (indisponível no Lab)
- [x] Pipeline CD completo: lint → test → build → push (ECR) → deploy — [`.github/workflows/cd.yml`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/.github/workflows/cd.yml), push com tags `sha-XXXXXXX` e `latest` via `aws-actions/amazon-ecr-login@v2`
- [x] Deploy Recreate via SSH na EC2 (login ECR antes do pull) — `appleboy/ssh-action`: `aws ecr get-login-password | docker login` → stop → rm → pull → run
- [x] Health check pós-deploy funcionando — 20 tentativas em `/health` com falha do pipeline se não responder; confere também se o `/version` no ar mostra o commit do pipeline
- [x] `gitops-cd-analise.md` preenchido — [`aula-10/gitops-cd-analise.md`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-10/gitops-cd-analise.md); rollback em [`aula-10/docs/runbook-rollback.md`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-10/docs/runbook-rollback.md), testado ([saída](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-10/evidencias/rollback-teste.txt))
- [x] Screenshots (plan no PR, apply após merge, pipeline CD verde, health check) — pasta [`aula-10/screenshots/`](https://github.com/Sir-Jr/unifaat-devops-portfolio/tree/main/aula-10/screenshots)

Bônus: plan com destroy exige o rótulo `aprovado-destroy` (testado no [PR #5](https://github.com/Sir-Jr/unifaat-devops-portfolio/pull/5)), comentário do plan
atualizado sem duplicar, deploy com `GITHUB_SHA` (rota `/version`), notificação de deploy como comentário no
commit, `terraform fmt -check` no plan, [`terraform-destroy.yml`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/.github/workflows/terraform-destroy.yml)
separado com aprovação manual (environment `destroy` com revisor obrigatório; executado em 25/10 depois da
aprovação, destruindo os 6 recursos: [run](https://github.com/Sir-Jr/unifaat-devops-portfolio/actions/runs/40158253920)). O environment `production` restringe o deploy à `main`, mas não exige aprovação:
o fluxo é Continuous Deployment.

## Resumo da análise ([`gitops-cd-analise.md`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-10/gitops-cd-analise.md))

O Git virou a fonte da verdade da infraestrutura: a EC2 foi criada pelo PR #4, com o plan comentado no PR e o apply rodando sozinho depois do merge; o plan no PR mostra o efeito real antes de acontecer e o merge é a aprovação humana, por isso o `-auto-approve`, com a ressalva de que o apply recalcula o plan no merge. No Lab a autenticação usa as três credenciais temporárias da sessão como secrets, que expiram a cada sessão; em produção o certo seria OIDC com role IAM, sem chave guardada, mas a role `voclabs` nega a criação do provedor OIDC e da role, e a EC2 usa o `LabInstanceProfile` para o login no ECR. O deploy é Recreate (login no ECR, stop, rm, pull, run e health check): simples e sem duas versões juntas, mas com a API fora do ar na troca, medido em ~1–2 s com a imagem em cache ([log](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-10/evidencias/downtime-recreate.txt)); serve para dev, homologação e janelas de manutenção, e para produção sem downtime ficam Blue-Green e Canary. O fluxo é Continuous Deployment (a rota `/version` chegou sozinha à produção); para ser Continuous Delivery bastaria exigir revisor no environment `production`. O rollback ([runbook](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-10/docs/runbook-rollback.md)) volta para uma tag `sha-` do ECR fazendo o login antes do pull, e foi testado indo de `sha-11f1f32` para `sha-bbeaec3` e voltando. As limitações principais são as credenciais que expiram, o SSH aberto para os runners, o downtime do Recreate, uma única EC2 e a falta de rollback automático quando o health check falha.

## Evidência do Pipeline Rodando

- Plan como comentário no PR: https://github.com/Sir-Jr/unifaat-devops-portfolio/pull/4
- Apply após o merge: https://github.com/Sir-Jr/unifaat-devops-portfolio/actions/runs/40155338659
- Pipeline CD verde disparado por push na `main` (lint → test → build-push → deploy + health check): https://github.com/Sir-Jr/unifaat-devops-portfolio/actions/runs/40155820969
- Mesmo commit disparado manualmente (run dos screenshots, usada na medição de downtime): https://github.com/Sir-Jr/unifaat-devops-portfolio/actions/runs/40156320739
- Deploy automático de uma mudança de código (rota `/version`): https://github.com/Sir-Jr/unifaat-devops-portfolio/actions/runs/40155711755

| Screenshot | Conteúdo |
|------------|----------|
| [plan-pr-comment.png](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-10/screenshots/plan-pr-comment.png) | plan comentado no PR #4 |
| [apply-success.png](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-10/screenshots/apply-success.png) | apply com sucesso após o merge |
| [cd-pipeline-green.png](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-10/screenshots/cd-pipeline-green.png) | pipeline CD completo verde |
| [health-check-pass.png](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-10/screenshots/health-check-pass.png) | health check passando no log do workflow |
