# Entrega — Aula 12: Rollback Strategies e AIOps

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 2026-11-06

## Repositório

- URL: https://github.com/lucaskenway/unifaat-devops-portfolio
- Pasta: [`aula-12/`](https://github.com/lucaskenway/unifaat-devops-portfolio/tree/main/aula-12) (ver o [README](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-12/README.md))
- Workflow (raiz, onde o GitHub o executa): [`cd-with-rollback.yml`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/.github/workflows/cd-with-rollback.yml)
- Análise crítica: [`aiops-analise.md`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-12/aiops-analise.md) · Runbook: [`docs/runbooks/deploy-failed.md`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-12/docs/runbooks/deploy-failed.md)

## Evidências

- [x] Feature flags implementadas (`src/feature-flags.js`) e integradas em pelo menos uma rota (frete em `POST /api/orders`; `/flags` responde 403 em produção)
- [x] Migrações expand-contract com up/down testadas (`migrations/`: 001 e 002 com `up`/`down`/`verify`, runner transacional e CLI)
- [x] Workflow CD com rollback automático baseado em health check (janela 6×10 s → `rollback.sh` volta para a imagem anterior no ECR)
- [x] Runbook operacional documentado (`docs/runbooks/deploy-failed.md`)
- [x] Alarme CloudWatch + Anomaly Detection configurado (`us-east-1`): 2 alarmes de limite fixo, 2 com `ANOMALY_DETECTION_BAND`
- [x] Lambda de AIOps com `LabRole`. O Lab não tem Bedrock, então ela usa a análise por regras, mais o simulador local com 3 cenários
- [x] `aiops-analise.md` preenchido
- [x] Screenshots (feature flag ligando/desligando, migração up/down, rollback automático, alarme CloudWatch, análise da Lambda/simulador)

Bônus:
- Alarme composto `TechNova-Incident-LatencyAndErrors` (latência E erros).
- Dashboard CloudWatch `TechNova-Aula12`, com as métricas de negócio e a banda de anomalia.
- A Lambda gera um rascunho de post-mortem a partir do alarme, das métricas e dos logs.
- Simulador com 3 cenários de incidente: latência/pool de banco, bug no deploy, memory leak.
- Notificação SNS no rollback automático.
- Infra inteira em Terraform: EC2, SNS, alarmes, dashboard, Lambda e EventBridge.

## Evidência rodando

| O quê | Link |
|-------|------|
| Deploy com health check aprovado | https://github.com/lucaskenway/unifaat-devops-portfolio/actions/runs/42309893461 |
| Rollback automático (`simulate_failure=true`: 6/6 checks HTTP 503 → volta de `a12-sha-2507a1c-r3` para `r2` em ~4 s, SNS publicado, workflow vermelho) | https://github.com/lucaskenway/unifaat-devops-portfolio/actions/runs/42310191161 |
| Logs reais (migrações na EC2, flags em produção, alarmes → EventBridge → Lambda, simulador) | https://github.com/lucaskenway/unifaat-devops-portfolio/tree/main/evidencias/2026-11-06_194152_aula-12-rollback-e-aiops |

**Feature flag ligando e desligando o frete em produção (mesma imagem, sem pipeline)**

![Feature flag](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-12/screenshots/feature-flag.png)

**Migração aplicada e revertida (`status` / `up` / `down 001` / `down 000` / `up`)**

![Migração up/down](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-12/screenshots/migration-up-down.png)

**Rollback automático disparado por health check falho**

![Rollback automático](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-12/screenshots/auto-rollback.png)

![Log do rollback](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-12/screenshots/auto-rollback-log.png)

**Alarmes CloudWatch (limite fixo + composto em ALARM; banda de anomalia) e análises da Lambda**

![Métricas e banda de anomalia](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-12/screenshots/cloudwatch-metrics-anomaly-band.png)

![Alarmes e Lambda](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-12/screenshots/cloudwatch-alarm.png)

**Análise AIOps (simulador local, 3/3 cenários)**

![Análise AIOps](https://raw.githubusercontent.com/lucaskenway/unifaat-devops-portfolio/main/aula-12/screenshots/aiops-analysis.png)
