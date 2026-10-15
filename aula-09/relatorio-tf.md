# Relatório de Produção de TF
**Análise e Desenvolvimento de Sistemas**  
**2026.2**

* **Professor:** Alexandre da Costa Tavares Jr
* **Disciplina:** DevOps
* **Aula:** 1☐ 2☐ 3☐ 4☐ 5☐ 6☐ 7☐ 8☐ 9☒ 10☐ 11☐ 12☐ 13☐ 14☐ 15☐
* **Data da aula:** [Data da aula]
* **Título da aula:** Docker Registry (Amazon ECR) e IA no CI/CD

---

## Resumo da Atividade Aplicada

### Objetivo
Demonstrar domínio de publicação de imagens Docker no **Amazon ECR** (usando o AWS Academy Learner Lab) e de integração de IA ao fluxo de code review, construindo um pipeline completo que builda, publica e revisa código automaticamente, com quality gate.

### Tarefa
Construir um pipeline completo para o repositório `technova-api` com: criação do repositório **Amazon ECR** e um script `ecr-push.sh` que autentica (`aws ecr get-login-password`) e publica a imagem no ECR com estratégia de tagging (SHA, latest e semver via git tags), operando no Learner Lab (`us-east-1`, credenciais temporárias, sem IAM); workflow de **AI Review** que dispara em Pull Requests, analisa o diff e posta um comentário categorizado por severidade; **quality gate** que bloqueia o PR em achados CRITICAL; e o documento `ia-cicd-analise.md` com a análise crítica sobre o uso de IA no review. Comprovar com screenshots (repositório no console do ECR com as tags, comentário do AI review, execução do push concluída e gate bloqueando).

---

*Obs: Este é um documento para registro das atividades praticadas em sala de aula junto da turma de Análise e Desenvolvimento de Sistemas, sejam dinâmicas, trabalhos, seminários ou atividades práticas.*
