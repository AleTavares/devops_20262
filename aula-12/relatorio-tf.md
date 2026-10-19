# Relatório de Produção de TF
**Análise e Desenvolvimento de Sistemas**  
**2026.2**

* **Professor:** Alexandre da Costa Tavares Jr
* **Disciplina:** DevOps
* **Aula:** 1☐ 2☐ 3☐ 4☐ 5☐ 6☐ 7☐ 8☐ 9☐ 10☐ 11☐ 12☒ 13☐ 14☐ 15☐
* **Data da aula:** [Data da aula]
* **Título da aula:** Rollback Strategies e AIOps (ECR / Learner Lab)

---

## Resumo da Atividade Aplicada

### Objetivo
Demonstrar domínio de estratégias de rollback (feature flags, migrações reversíveis expand-contract, rollback automático no pipeline e runbooks) e de **AIOps** (detecção de anomalias no CloudWatch + Lambda inteligente com Amazon Bedrock), operando no **AWS Academy Learner Lab** (`us-east-1`, `LabRole`) e reaproveitando as imagens versionadas no **Amazon ECR**.

### Tarefa
Construir o conjunto de defesas operacionais para o `technova-api`: módulo de **feature flags** por variáveis de ambiente integrado a uma rota; **migrações expand-contract** com up/down/verify e CLI; workflow de **CD com rollback automático** que reverte para a versão anterior (imagem no ECR) quando o health check falha; **runbook** operacional de incidente; métricas customizadas e alarmes no **CloudWatch** (threshold fixo + anomaly band); e uma **Lambda de AIOps** (usando a role pré-existente `LabRole`, pois o Lab não cria roles IAM) que analisa o alarme via **Bedrock** — ou, sem acesso ao Bedrock, via simulador local + Kiro AI. Comprovar com screenshots (feature flag ligando/desligando, migração up/down, rollback automático, alarme CloudWatch e a análise da Lambda/simulador).

---

*Obs: Este é um documento para registro das atividades praticadas em sala de aula junto da turma de Análise e Desenvolvimento de Sistemas, sejam dinâmicas, trabalhos, seminários ou atividades práticas.*
