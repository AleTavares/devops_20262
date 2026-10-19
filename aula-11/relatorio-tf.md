# Relatório de Produção de TF
**Análise e Desenvolvimento de Sistemas**  
**2026.2**

* **Professor:** Alexandre da Costa Tavares Jr
* **Disciplina:** DevOps
* **Aula:** 1☐ 2☐ 3☐ 4☐ 5☐ 6☐ 7☐ 8☐ 9☐ 10☐ 11☒ 12☐ 13☐ 14☐ 15☐
* **Data da aula:** [Data da aula]
* **Título da aula:** Blue/Green e Canary Deployments (ECR / Learner Lab)

---

## Resumo da Atividade Aplicada

### Objetivo
Demonstrar domínio das estratégias de deploy com **zero downtime** — Blue/Green e Canary — usando Application Load Balancer (ALB), Terraform e GitHub Actions, com as imagens publicadas no **Amazon ECR** e operando no **AWS Academy Learner Lab** (`us-east-1`, credenciais temporárias, `LabRole`/`LabInstanceProfile`).

### Tarefa
Implementar **uma das duas estratégias** para a TechNova API: **Blue/Green** (ALB + 2 Target Groups, traffic switch instantâneo, rollback em < 1 segundo) **ou** **Canary** (weighted routing no ALB, rollout gradual 5%→25%→50%→100% com monitoramento e rollback automático por taxa de erro). A infraestrutura é provisionada via Terraform; o workflow do GitHub Actions faz build e push para o ECR, deploya nas instâncias (login ECR antes do `docker pull`) e controla o tráfego pelo ALB. Entregar o `EXPLICACAO.md` com a análise das decisões e comprovar com screenshots (ALB respondendo, traffic switch/rollout e rollback acionado).

---

*Obs: Este é um documento para registro das atividades praticadas em sala de aula junto da turma de Análise e Desenvolvimento de Sistemas, sejam dinâmicas, trabalhos, seminários ou atividades práticas.*
