# Relatório de Produção de TF
**Análise e Desenvolvimento de Sistemas**  
**2026.2**

* **Professor:** Alexandre da Costa Tavares Jr
* **Disciplina:** DevOps
* **Aula:** 1☐ 2☐ 3☐ 4☐ 5☐ 6☐ 7☐ 8☐ 9☐ 10☐ 11☐ 12☐ 13☐ 14☒ 15☐
* **Data da aula:** [Data da aula]
* **Título da aula:** Disaster Simulation, Code Review e Agente Bedrock

---

## Resumo da Atividade Aplicada

### Objetivo
Demonstrar domínio de três pilares que fecham o conteúdo do curso: **Chaos Engineering** (provar resiliência quebrando intencionalmente e medindo RTO), **Code Review e Governance** (branch protection, CODEOWNERS, PR template, conventional commits) e **AI-Powered DevOps** (projetar e implementar um agente DevOps com AWS Bedrock), tudo operando no **AWS Academy Learner Lab**.

### Tarefa
Conduzir um **Game Day** sobre os serviços `technova-api` e `technova-notifications` em Docker: executar três experimentos de chaos (container kill, degradação graceful, full system recovery), medir o RTO de cada hipótese com `monitor.sh`/`run-game-day.sh` e consolidar um Game Day Report. Estabelecer **governance** no repositório (branch protection, `CODEOWNERS`, `pull_request_template.md`, workflow de conventional commits, `CONTRIBUTING.md`). Projetar o agente **DevOps Guardian** no **AWS Bedrock**: schema OpenAPI dos action groups, instruction prompt, três Lambdas Python (`analyze_pr`, `detect_drift`, `generate_runbook`) com teste local, Terraform usando a role pré-existente `LabRole`/`LabInstanceProfile` (sem criar IAM) no Learner Lab (`us-east-1`), e workflows GitHub Actions que invocam o agente em PRs e issues. Comprovar com screenshots (experimentos de chaos com RTO medido, Game Day executando, branch protection, `python test_local.py` passando, governance configurada).

---

*Obs: Este é um documento para registro das atividades praticadas em sala de aula junto da turma de Análise e Desenvolvimento de Sistemas, sejam dinâmicas, trabalhos, seminários ou atividades práticas.*
