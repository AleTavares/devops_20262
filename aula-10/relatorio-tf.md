# Relatório de Produção de TF
**Análise e Desenvolvimento de Sistemas**  
**2026.2**

* **Professor:** Alexandre da Costa Tavares Jr
* **Disciplina:** DevOps
* **Aula:** 1☐ 2☐ 3☐ 4☐ 5☐ 6☐ 7☐ 8☐ 9☐ 10☒ 11☐ 12☐ 13☐ 14☐ 15☐
* **Data da aula:** [Data da aula]
* **Título da aula:** Terraform Automatizado e CD Pipelines (ECR / Learner Lab)

---

## Resumo da Atividade Aplicada

### Objetivo
Demonstrar domínio de GitOps para Terraform (plan automático em PRs e apply automático no merge) e de Continuous Deployment, construindo um pipeline unificado CI → Build → Push (**Amazon ECR**) → Deploy que atualiza automaticamente a aplicação na EC2, usando o AWS Academy Learner Lab.

### Tarefa
Implementar, para o repositório `technova-api`, dois fluxos automatizados: (1) **Terraform GitOps** — workflow `terraform-plan.yml` que posta o plan como comentário no PR e workflow `terraform-apply.yml` que aplica no merge para `main`, autenticando na AWS com as credenciais temporárias de sessão do Learner Lab como GitHub Secrets (`us-east-1`); e (2) **Pipeline CD** — `cd.yml` com lint → test → build → push no **Amazon ECR** → deploy via SSH na EC2 pela estratégia Recreate (login no ECR antes do `docker pull`), com health check pós-deploy e rollback manual documentado. Em produção fora do Lab, a autenticação seria substituída por OIDC + role IAM (padrão ideal, indisponível no Lab). Comprovar com screenshots (plan no PR, apply após merge, pipeline CD verde e health check passando).

---

*Obs: Este é um documento para registro das atividades praticadas em sala de aula junto da turma de Análise e Desenvolvimento de Sistemas, sejam dinâmicas, trabalhos, seminários ou atividades práticas.*
