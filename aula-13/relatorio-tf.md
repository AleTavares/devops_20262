# Relatório de Produção de TF
**Análise e Desenvolvimento de Sistemas**  
**2026.2**

* **Professor:** Alexandre da Costa Tavares Jr
* **Disciplina:** DevOps
* **Aula:** 1☐ 2☐ 3☐ 4☐ 5☐ 6☐ 7☐ 8☐ 9☐ 10☐ 11☐ 12☐ 13☒ 14☐ 15☐
* **Data da aula:** [Data da aula]
* **Título da aula:** Novo Microserviço com Pipeline End-to-End

---

## Resumo da Atividade Aplicada

### Objetivo
Demonstrar domínio do ciclo DevOps completo criando um microserviço novo do zero — o `technova-notifications` — com um pipeline **end-to-end** que vai do commit até a validação em produção: código com testes, container, CI publicando no **Amazon ECR**, infraestrutura como código no **AWS Academy Learner Lab**, deploy automatizado com health check e integração inter-serviço validada por testes E2E.

### Tarefa
Construir o microserviço `technova-notifications` (Express.js, porta 3001) com rotas (`POST /notifications/send`, `GET /notifications`, `GET /notifications/:orderId`, `GET /health`), testes unitários (Jest + Supertest) e ESLint; containerizar com Dockerfile multi-stage (non-root + HEALTHCHECK); implementar pipeline CI (lint → test → build → push) publicando a imagem no **Amazon ECR** (`us-east-1`, credenciais temporárias do Lab com `aws_session_token`); provisionar a infraestrutura com Terraform (EC2 + Security Group + `LabInstanceProfile` para o `docker pull` do ECR); automatizar o deploy (CD) com health check pós-deploy; integrar o `technova-api` ao `technova-notifications` via HTTP com resiliência; e validar o fluxo completo (criar pedido → disparar notificação → confirmar entrega) com testes E2E. Comprovar com screenshots (pipeline CI verde, imagem no console do Amazon ECR, health check respondendo, testes E2E passando).

---

*Obs: Este é um documento para registro das atividades praticadas em sala de aula junto da turma de Análise e Desenvolvimento de Sistemas, sejam dinâmicas, trabalhos, seminários ou atividades práticas.*
