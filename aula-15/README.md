# Aula 15 — Apresentação Final: O Resgate Completo da TechNova

## 📋 Informações Gerais

| Item | Descrição |
|------|-----------|
| **Módulo** | 05 — Projeto Integrador e Encerramento |
| **Aula** | 15 de 15 |
| **Tema** | Apresentação Final do Portfólio DevOps |
| **Professor** | Alexandre Tavares |

---

## 🎬 Narrativa da Aula

> **O Resgate da TechNova — Episódio Final: "Missão Cumprida"**
>
> Chegou o dia. Depois de 15 encontros de trabalho intenso, a TechNova não é mais aquela
> empresa em crise que conhecemos na Aula 01. A plataforma que antes sofria com deploys
> manuais, ausência de automação e infraestrutura frágil agora opera com pipelines de CI/CD
> automatizados, infraestrutura como código na AWS, containers publicados em registry,
> estratégias de deploy com zero downtime e inteligência artificial integrada ao ciclo de
> desenvolvimento. Rafael, Marina e o CTO Carlos Mendes reúnem o time para o momento final:
> cada engenheiro apresenta sua jornada — do caos à excelência operacional. Missão cumprida.

---

## 🎯 Objetivos de Aprendizagem

Ao final desta aula, o aluno será capaz de:

1. **Apresentar** seu portfólio DevOps completo de forma estruturada e profissional
2. **Demonstrar** o pipeline end-to-end funcionando (push → CI → build → push no Amazon ECR → deploy)
3. **Articular** a evolução técnica e conceitual desde a Aula 01 até a Aula 15
4. **Demonstrar** a integração de IA no fluxo DevOps (review de PRs, geração de IaC, agente Bedrock)
5. **Identificar** próximos passos na jornada DevOps (certificações, tecnologias, carreira)
6. **Avaliar** criticamente o trabalho dos colegas com feedback construtivo

---

## 📅 Cronograma da Aula

| Bloco | Atividade |
|:-----:|-----------|
| 1 | Abertura e instruções finais |
| 2 | **Bloco 1 de Apresentações** |
| 3 | Intervalo |
| 4 | **Bloco 2 de Apresentações** |
| 5 | **Retrospectiva e Encerramento do Curso** |

---

## 🏗️ Estrutura da Apresentação

Cada apresentação deve cobrir:

### 1. Visão Geral da Arquitetura
- Diagrama da infraestrutura final (AWS no Learner Lab)
- Tecnologias utilizadas (Git, Docker, Terraform, GitHub Actions, Amazon ECR, Bedrock)
- Decisões arquiteturais tomadas

### 2. Demo do Pipeline
- Push de código → CI dispara → Build → Testes → push da imagem no **Amazon ECR** → Deploy
- Mostrar logs, status checks, artefatos gerados
- Estratégia de deploy (Blue/Green ou Canary) e rollback (se aplicável)

### 3. Demo da Integração com IA
- Review automático de PR com IA
- Geração ou validação de IaC com assistente (Kiro/Bedrock)
- Agente DevOps (Bedrock) ou qualquer outro uso de IA no fluxo

### 4. Lições Aprendidas e Evolução
- O que mudou da Aula 01 para a Aula 15
- Maior desafio enfrentado
- O que faria diferente

### 5. Perguntas
- Perguntas da turma e do professor

---

## 📊 Critérios de Avaliação

| Critério | Peso | Descrição |
|----------|:----:|-----------|
| Pipeline funcional | 25% | Demo ao vivo do CI/CD end-to-end (CI → ECR → deploy) |
| Portfólio completo | 25% | Todas as aulas do curso documentadas no repositório |
| Integração IA | 15% | Demonstração de pelo menos um uso de IA no fluxo |
| Clareza da apresentação | 15% | Comunicação objetiva e estruturada |
| Evolução demonstrada | 10% | Narrativa coerente da jornada |
| Participação como avaliador | 10% | Feedback construtivo aos colegas |

---

## 📁 Pré-requisitos

Para esta aula, o aluno deve ter:

- [ ] Repositório `unifaat-devops-portfolio` completo e público
- [ ] Pipeline CI/CD funcional e demonstrável (com push no Amazon ECR)
- [ ] Apresentação preparada (slides ou demo ao vivo)
- [ ] TA.md desta aula concluído (preparação da apresentação)
- [ ] Ensaio da demo realizado pelo menos uma vez

> **☁️ AWS Academy Learner Lab:** se a demo depende de recursos AWS (ECR, EC2, ALB, RDS,
> Bedrock), inicie a sessão do Lab antes da apresentação e recarregue as credenciais
> temporárias (com `aws_session_token`). Trabalhe sempre em `us-east-1`. Tenha um
> **plano B** (vídeo/screenshots) caso a sessão expire durante a demo.

---

## 🔗 Conexão com Aulas Anteriores

Esta aula é a **síntese de todo o curso**. Cada bloco anterior contribui diretamente para o portfólio apresentado:

| Aula | Tema | Contribuição para a Apresentação |
|------|------|----------------------------------|
| 01 | Git — repositórios, branches, merge, remotes | Base de versionamento do portfólio |
| 02 | Docker — imagens, Dockerfile, layers | Containerização da aplicação |
| 03 | Docker Compose — services, networks, volumes | Orquestração local do ambiente |
| 04 | IA como copiloto DevOps (Kiro, prompting para IaC) | IA aplicada ao desenvolvimento |
| 05-06 | Terraform — HCL, providers, state; IAM/menor privilégio | Infraestrutura como código na AWS |
| 07-09 | VPC e Networking; EC2; RDS PostgreSQL | Infra de rede, computação e dados |
| 10-11 | Remote State (S3/DynamoDB); Módulos Terraform | IaC escalável e reutilizável |
| 12 | Revisão de arquitetura + IA para gerar IaC (Bedrock) | Arquitetura revisada com apoio de IA |
| 13 | GitHub Actions, testes, Secrets, CI | Pipeline de integração contínua |
| 14 | Docker Registry (**Amazon ECR**) + IA no CI/CD | Publicação de imagens e review por IA |
| 15 | GitOps e Pipelines de CD | Entrega contínua automatizada |
| 16 | Blue/Green e Canary Deployment | Deploy com zero downtime |
| 17 | Rollback, Feature Flags e AIOps | Resiliência e operação inteligente |
| 18 | Projeto Integrador (microserviço E2E + agente Bedrock) | Plataforma completa com IA |
| **—** | **Apresentação Final** | **Síntese e demonstração de tudo** |

> Observação: a numeração acima segue os temas do conteúdo programático do curso
> (ver `DISCIPLINA.md`). A orquestração em produção é feita com **EC2/ALB provisionados por
> Terraform** no Learner Lab (o curso não cobre plataformas de orquestração de containers).

---

## 💡 Dica do Professor

> "A apresentação não é sobre ser perfeito. É sobre mostrar o que você aprendeu, o que
> construiu e como evoluiu. Um pipeline que quebrou e foi consertado conta mais do que um
> que nunca foi testado de verdade. Mostrem a jornada real."

---

*Última aula do curso. Parabéns pela jornada!* 🎓
