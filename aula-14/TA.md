# Aula 14 — Trabalho Anterior (TA)

## Objetivo

Preparar-se para a Aula 14 — a aula **capstone de IA** do curso — através de leitura prévia sobre **Chaos Engineering**, **Code Review e Governance** e **agentes DevOps com AWS Bedrock**. Nesta aula a TechNova deixa de apenas confiar na automação e passa a **provar** que ela funciona sob pressão: vamos quebrar o sistema de propósito e medir a recuperação (Game Day), estabelecer as regras de contribuição no repositório, e construir um agente inteligente que revisa PRs, detecta drift e gera runbooks. Ao final da leitura você deve entender *por que* resiliência precisa ser testada, *como* medir recuperação com métricas objetivas, e *qual* o papel (e os limites) de um agente de IA no ciclo DevOps.

> **Como estudar este material:** leia as três partes, observe os diagramas (eles resumem o fluxo que você vai aplicar no laboratório) e responda as questões de verificação ao final. Traga suas respostas e dúvidas para a discussão no início da aula.

---

## Parte 1 — Chaos Engineering e Resiliência

### 1.1 Por que quebrar de propósito?

Ter restart policies, health checks e pipelines automatizadas **não garante** que o sistema se recupera de uma falha real. A única forma de ter certeza é **provocar a falha de forma controlada e observar o comportamento**. Isso é Chaos Engineering: um método científico aplicado à resiliência.

O ciclo é sempre o mesmo:

1. **Hipótese** — "se o container de notifications morrer, o restart policy deve restaurá-lo em menos de 30 segundos"
2. **Experimento** — matar o container intencionalmente
3. **Observação** — medir o tempo de recuperação
4. **Conclusão** — validar ou refutar a hipótese e registrar aprendizados

O princípio-chave é **minimizar o blast radius**: comece sempre em ambiente controlado (Docker local), nunca testando primeiro em produção com clientes reais.

### 1.2 Métricas de Resiliência

Resiliência não se mede com "achismo". Existem métricas objetivas:

| Métrica | O que mede | Meta típica |
|---------|------------|-------------|
| **RTO** (Recovery Time Objective) | Tempo máximo aceitável de indisponibilidade | < 60 segundos |
| **RPO** (Recovery Point Objective) | Perda de dados máxima aceitável | Zero (para serviços stateless) |
| **MTTR** (Mean Time To Recovery) | Tempo médio de recuperação **medido** na prática | < RTO |
| **MTBF** (Mean Time Between Failures) | Tempo médio entre falhas | Maior possível |

A diferença crucial: o **RTO** é uma *meta* (quanto você aceita ficar fora do ar), enquanto o **MTTR** é um *resultado medido*. O Game Day existe para comparar os dois.

### 1.3 Game Day

Um **Game Day** é um exercício planejado onde a equipe introduz falhas controladas e mede a resposta do sistema. A estrutura típica:

1. **Planejamento** — definir hipóteses, métricas a coletar e blast radius
2. **Preparação** — instrumentação (monitor de disponibilidade), alertas e plano de rollback
3. **Execução** — introduzir a falha (ex.: `docker kill`)
4. **Observação** — medir o RTO e analisar o comportamento dos serviços dependentes
5. **Retrospectiva** — documentar achados, melhorias e lições aprendidas

Um padrão importante que o Game Day valida é a **degradação graceful**: quando um serviço dependente cai (ex.: notifications), o serviço principal (api) deve **continuar funcionando** com funcionalidade reduzida (ex.: criar o pedido com `notification.sent = false`) em vez de retornar erro 500.

---

## Parte 2 — Code Review e Governance

### 2.1 Governance de Repositório

Quando a equipe cresce, código entra sem revisão, PRs ficam inconsistentes e commits viram caos. Governance é o conjunto de regras que mantém a qualidade:

| Mecanismo | O que faz |
|-----------|-----------|
| **Branch Protection** | Impede push direto para `main`; exige PR com review e CI verde |
| **CODEOWNERS** | Define automaticamente quem revisa cada área do código |
| **PR Template** | Padroniza as informações de todo Pull Request (tipo, checklist, como testar) |
| **Conventional Commits** | Mensagens semânticas (`feat`, `fix`, `docs`, `chore`, `ci`) verificáveis por automação |
| **CONTRIBUTING.md** | Guia que orienta novos contribuidores sobre o fluxo e os padrões |

### 2.2 Conventional Commits

O padrão **Conventional Commits** define o formato `tipo(escopo): descrição`. Exemplos:

```
feat(notifications): adicionar suporte a SMS
fix(api): corrigir timeout na criação de pedidos
docs(readme): adicionar diagrama de arquitetura
ci(actions): adicionar job de security scan
```

Além de deixar o histórico legível, esse padrão permite **automação**: um workflow de CI pode validar o formato de cada commit e até gerar changelog e versões automaticamente.

---

## Parte 3 — Agentes DevOps com AWS Bedrock

### 3.1 De assistente a agente

Nas aulas anteriores a IA foi evoluindo: assistente interativo (Aula 02), geração de IaC supervisionada (Aula 07), review automático no CI/CD (Aula 09). Um **agente Bedrock** é o próximo nível: ele **recebe um objetivo**, **decide quais ações executar** e **orquestra ferramentas** para alcançá-lo.

A arquitetura de um Bedrock Agent tem três peças centrais:

- **Foundation Model (orquestração)** — interpreta o pedido e decide o que fazer
- **Action Groups** — ações concretas que o agente pode executar, implementadas como **Lambda functions** e descritas por um **schema OpenAPI**
- **Knowledge Base** — contexto histórico (runbooks, incidentes, padrões) indexado via embeddings para RAG

### 3.2 O DevOps Guardian

No laboratório você vai projetar o agente **DevOps Guardian**, com três action groups:

| Action Group | Lambda | O que faz |
|--------------|--------|-----------|
| PR Analyzer | `analyze_pr` | Analisa o diff do PR buscando problemas de segurança, Docker e Terraform |
| Drift Detector | `detect_drift` | Compara estado real vs declarado da infraestrutura |
| Runbook Generator | `generate_runbook` | Gera runbooks estruturados a partir de um cenário de incidente |

### 3.3 Execução no Learner Lab

Em produção, o padrão ideal para o GitHub Actions autenticar na AWS seria **OIDC**, mas isso exige criar uma role IAM — algo **indisponível no AWS Academy Learner Lab**. Por isso, no Lab:

- O agente e as Lambdas usam a role pré-existente **`LabRole`** (`arn:aws:iam::<ACCOUNT_ID>:role/LabRole`) e **`LabInstanceProfile`** onde houver instance profile — **sem criar** usuários/grupos/roles IAM
- A autenticação usa as **credenciais temporárias da sessão** (com `aws_session_token`, que expira ao encerrar o Lab), sempre em `us-east-1`
- Para desenvolver sem custo, as Lambdas são testadas localmente (`test_local.py`) sem precisar de uma conta Bedrock ativa

---

## Questões de Verificação

Responda as questões abaixo para verificar sua compreensão. Traga suas respostas para a discussão em aula.

### Questão 1

Qual é a diferença correta entre **RTO** e **MTTR**?

- a) RTO e MTTR são sinônimos — ambos medem o tempo real de recuperação
- b) RTO é a meta máxima aceitável de indisponibilidade; MTTR é o tempo médio de recuperação efetivamente medido
- c) RTO mede perda de dados; MTTR mede tempo de recuperação
- d) RTO só se aplica a bancos de dados; MTTR só a containers

### Questão 2

Durante um Game Day, o serviço de notifications é derrubado e o `technova-api` continua criando pedidos retornando `notification.sent: false` (sem erro 500). Que princípio foi validado?

- a) Blast radius ilimitado
- b) Degradação graceful (resiliência a falha de dependência)
- c) Recovery Point Objective zero
- d) Rollback automático de deploy

### Questão 3

No AWS Academy Learner Lab, como o agente Bedrock e as Lambdas obtêm permissões, já que não é possível criar roles IAM?

- a) Criando um usuário IAM dedicado para o agente
- b) Configurando OIDC entre o GitHub Actions e a AWS (padrão de produção indisponível no Lab)
- c) Usando a role pré-existente `LabRole` (e `LabInstanceProfile` quando há instance profile)
- d) Sem permissões, pois o Bedrock é público

### Questão 4

Qual mensagem de commit segue corretamente o padrão **Conventional Commits**?

- a) `atualizei o dockerfile`
- b) `WIP mudanças`
- c) `fix(api): corrigir timeout na criação de pedidos`
- d) `[API] timeout corrigido`

### Questão 5

Em um Bedrock Agent, qual é o papel de um **action group**?

- a) Armazenar o histórico de incidentes para RAG
- b) Definir uma ação concreta que o agente pode executar, implementada como Lambda e descrita por um schema OpenAPI
- c) Escolher qual foundation model usar
- d) Substituir completamente o review humano

---

> As respostas das questões serão discutidas no início da aula.

---

## Referências

### Chaos Engineering e Resiliência

- **Principles of Chaos Engineering**. Disponível em: [https://principlesofchaos.org/](https://principlesofchaos.org/)
- Netflix. **Chaos Monkey**. Disponível em: [https://netflix.github.io/chaosmonkey/](https://netflix.github.io/chaosmonkey/)
- Google. **Site Reliability Engineering (SRE Book)**. Disponível em: [https://sre.google/sre-book/](https://sre.google/sre-book/)

### Code Review e Governance

- GitHub. **About protected branches**. GitHub Docs. Disponível em: [https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-a-branch-protection-rule](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-a-branch-protection-rule)
- GitHub. **About code owners (CODEOWNERS)**. GitHub Docs. Disponível em: [https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
- **Conventional Commits (PT-BR)**. Disponível em: [https://www.conventionalcommits.org/pt-br/v1.0.0/](https://www.conventionalcommits.org/pt-br/v1.0.0/)

### Agentes AWS Bedrock

- Amazon Web Services. **Agents for Amazon Bedrock**. AWS Documentation. Disponível em: [https://docs.aws.amazon.com/bedrock/latest/userguide/agents.html](https://docs.aws.amazon.com/bedrock/latest/userguide/agents.html)
- Amazon Web Services. **Action groups for Amazon Bedrock agents**. AWS Documentation. Disponível em: [https://docs.aws.amazon.com/bedrock/latest/userguide/agents-action-create.html](https://docs.aws.amazon.com/bedrock/latest/userguide/agents-action-create.html)
- **OpenAPI Specification**. Disponível em: [https://swagger.io/specification/](https://swagger.io/specification/)
