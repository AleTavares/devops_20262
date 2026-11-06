# Entrega — Aula 11: Blue/Green e Canary Deployments

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 2026-11-06

## Repositório

- URL: https://github.com/lucaskenway/unifaat-devops-portfolio
- Pasta: [`aula-11/`](https://github.com/lucaskenway/unifaat-devops-portfolio/tree/main/aula-11)
- Workflow (raiz, onde o GitHub o executa): [`deploy-blue-green.yml`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/.github/workflows/deploy-blue-green.yml)
- Documentos: [`EXPLICACAO.md`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-11/EXPLICACAO.md) · [`ROLLBACK.md`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-11/ROLLBACK.md)

## Estratégia escolhida

- [x] Opção A — Blue/Green
- [ ] Opção B — Canary

## Trabalho em Aula

- [`trabalho-em-aula.md`](trabalho-em-aula.md): escolha de estratégia (Canary, Recreate, Blue/Green) por cenário e plano de rollout do canary

## Evidências

- [x] Terraform do ALB + 2 Target Groups aplicável (`terraform validate`/`plan` → 23 recursos criados no Learner Lab)
- [x] Workflow de deploy com validação e rollback (`deploy-blue-green.yml` + `aula-11/scripts/bluegreen.sh`)
- [x] Imagem puxada do **Amazon ECR** no deploy das instâncias (login ECR via SSH antes do `docker pull`)
- [x] `EXPLICACAO.md` preenchido (com os tempos medidos)
- [x] Screenshots (ALB respondendo, traffic switch, rollback acionado)

Bônus:
- Workflow testado com evidência: run com sucesso e run com `simulate_failure`.
- Health check customizado: `/health/ready` confere a camada de dados e a memória.
- Notificação de rollback: comentário no commit, mais Discord se o webhook estiver configurado.
- Lifecycle policy no ECR.

## Evidência do Deploy Rodando

| O quê | Link |
|-------|------|
| Deploy Blue/Green com sucesso (green → blue, switch em 2,6 s, 20/20 requisições OK) | https://github.com/lucaskenway/unifaat-devops-portfolio/actions/runs/42309886648 |
| Rollback automático (`simulate_failure=true`: 20/20 HTTP 500 → volta para blue em 2,9 s) | https://github.com/lucaskenway/unifaat-devops-portfolio/actions/runs/42310187138 |
| Correções encontradas no lab real (TG ocioso sem health check; propagação do switch) | https://github.com/lucaskenway/unifaat-devops-portfolio/pull/13 · https://github.com/lucaskenway/unifaat-devops-portfolio/pull/15 |

**Deploy Blue/Green verde**

![Deploy Blue/Green](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-11/screenshots/02-deploy-blue-green-sucesso.png)

**ALB respondendo (`/version` com a cor ativa)**

![ALB respondendo](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-11/screenshots/03-alb-respondendo-version.png)

**Rollback automático acionado**

![Rollback automático](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-11/screenshots/04-rollback-automatico-run.png)
