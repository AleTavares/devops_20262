# Aula 14 — Disaster Simulation, Code Review e Agente Bedrock

## O Resgate da TechNova — Episódio 14: "Quebrando Para Provar e o Agente que Governa"

### Contextualização Narrativa

A TechNova está madura. Pipelines automatizadas, infraestrutura como código, microserviços rodando em produção. Mas o CTO Carlos Mendes faz uma pergunta que congela a equipe: *"Se o banco de dados cair agora, em quantos minutos voltamos? E se um container morrer sob carga? Alguém já testou isso de verdade?"*

Silêncio.

*"Não basta ter automação. Precisamos **provar** que ela funciona sob pressão. Quero um Game Day — vamos quebrar intencionalmente e medir nossa capacidade de recuperação."*

E tem mais: a equipe cresceu. Código entra sem revisão consistente, PRs sem template, commits sem padrão. O tech lead propõe: *"Vamos estabelecer as regras de code review e governance. E para coroar, vamos construir um **agente inteligente** que analisa PRs, detecta drift de infraestrutura, sugere remediações e documenta runbooks automaticamente — usando AWS Bedrock."*

Este episódio combina **Chaos Engineering** (provar resiliência quebrando), **Code Review e Governance** (estabelecer processos de qualidade), e **AI-Powered DevOps** (construir um agente Bedrock que governa o ciclo DevOps). É a aula capstone de IA, integrando tudo que foi visto nas Aulas 02, 07, 09 e 12.

---

### Informações da Aula

| Item | Detalhe |
|------|---------|
| **Módulo** | 05 — Projeto Integrador |
| **Aula** | 14 |
| **Tipo** | Aula Avançada (Chaos + Governance + AI) |
| **Pré-requisitos** | Aulas anteriores, Aulas 02/07/09/12 (conteúdo AI) |
| **Ferramentas** | Docker, GitHub Actions, AWS Bedrock, Python/Boto3, Terraform (Learner Lab) |

---

### Objetivos de Aprendizagem

Ao final desta aula, o aluno será capaz de:

1. **Aplicar princípios de Chaos Engineering** para validar a resiliência de sistemas em produção através de experimentos controlados
2. **Conduzir um Game Day** com hipóteses definidas, métricas de RTO/RPO, e validação de mecanismos de recuperação
3. **Implementar processos de Code Review** com branch protection rules, CODEOWNERS, PR templates e conventional commits
4. **Estabelecer governance de código** com CONTRIBUTING.md, gestão de tech debt, e padrões de qualidade
5. **Projetar um agente DevOps com AWS Bedrock** definindo action groups, knowledge base, e prompts de orquestração
6. **Implementar action groups** que analisam PRs, detectam drift de infraestrutura e sugerem remediações
7. **Integrar o agente com GitHub Actions** para automação de review e documentação de runbooks
8. **Sintetizar competências de IA** das Aulas 02, 07, 09 e 12 em uma solução DevOps completa com agente autônomo

---

### Estrutura da Aula

#### Parte 1 — Disaster Simulation + Code Review

| Atividade | Descrição |
|-----------|-----------|
| Abertura e Contexto | Narrativa, Chaos Engineering, por que quebrar intencionalmente |
| Conceitos: Chaos + Governance | Princípios, Game Day, branch protection, CODEOWNERS |
| Lab Parte 1A | Chaos Experiments: container crash, endpoint unhealthy, restart policies |
| Lab Parte 1B | Governance: branch protection, CODEOWNERS, PR template, conventional commits |
| Lab Parte 1C | Game Day: simulação completa com medição de RTO e validação de rollback |

#### Parte 2 — Building the Bedrock DevOps Agent

| Atividade | Descrição |
|-----------|-----------|
| Contexto AI | Recap AI no DevOps (Aulas 02/07/09/12), arquitetura de agentes Bedrock |
| Lab Parte 2A | Design do agente: action groups, knowledge base, schema OpenAPI |
| Lab Parte 2B | Implementação: Lambda functions para cada action group |
| Lab Parte 2C | Integração: GitHub Actions + invocação do agente + documentação automática |
| Encerramento | Revisão, conexão com próximas aulas, entrega |

---

### Conceitos-Chave

#### Chaos Engineering — Princípios

- **Definir estado estável**: o que significa "saudável" para o sistema?
- **Hipotetar sobre comportamento**: "se X falhar, o sistema deve se recuperar em Y segundos"
- **Introduzir variáveis do mundo real**: crash de container, latência de rede, disco cheio
- **Minimizar blast radius**: experimentar em ambiente controlado primeiro
- **Automatizar**: chaos experiments devem ser reprodutíveis

#### Métricas de Resiliência

| Métrica | Definição | Meta Típica |
|---------|-----------|-------------|
| **RTO** (Recovery Time Objective) | Tempo máximo aceitável de indisponibilidade | < 60 segundos |
| **RPO** (Recovery Point Objective) | Perda de dados máxima aceitável | Zero (para stateless) |
| **MTTR** (Mean Time To Recovery) | Tempo médio de recuperação medido | < RTO |

#### Game Day — Estrutura

1. **Planejamento**: definir hipóteses, métricas, blast radius
2. **Preparação**: instrumentação, alertas, rollback plan
3. **Execução**: introduzir falha controlada
4. **Observação**: medir RTO, analisar comportamento
5. **Retrospectiva**: documentar achados, melhorias

#### Code Review e Governance

- **Branch Protection**: impedir push direto para main, exigir reviews
- **CODEOWNERS**: definir responsáveis por área do código
- **PR Templates**: padronizar informações em Pull Requests
- **Conventional Commits**: mensagens semânticas (feat, fix, chore)
- **CONTRIBUTING.md**: guia para contribuidores
- **Tech Debt**: processo para registrar e priorizar débito técnico

#### Agente DevOps Bedrock — Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                    AWS Bedrock Agent                              │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │ Action Group │  │ Action Group │  │ Action Group          │   │
│  │ PR Analyzer  │  │ Drift Detect │  │ Runbook Generator    │   │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘   │
│         │                  │                      │               │
│         ▼                  ▼                      ▼               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │ Lambda:      │  │ Lambda:      │  │ Lambda:              │   │
│  │ analyze_pr   │  │ check_drift  │  │ generate_runbook     │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐   │
│  │              Knowledge Base (S3 + OpenSearch)              │   │
│  │  - Runbooks existentes  - Padrões de arquitetura          │   │
│  │  - Políticas de deploy  - Histórico de incidentes         │   │
│  └───────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────┐          ┌─────────────────────┐
│  GitHub Actions │ ────────▶│  PR Comments        │
│  (Trigger)      │          │  Issue Creation     │
└─────────────────┘          │  Runbook Docs       │
                             └─────────────────────┘
```

> **☁️ Execução no Learner Lab:** o agente roda no **AWS Academy Learner Lab**, que **não permite criar usuários/grupos/roles IAM**. Por isso o Bedrock Agent e as Lambdas usam a role pré-existente **`LabRole`** (`arn:aws:iam::<ACCOUNT_ID>:role/LabRole`) e, quando há instance profile, o **`LabInstanceProfile`**. O Lab **permite** usar Bedrock, Lambda, S3 e OpenSearch Serverless. A autenticação é feita com as **credenciais temporárias da sessão** (incluindo `aws_session_token`, que expira ao encerrar o Lab), sempre em `us-east-1`.

#### Capacidades do Agente

| Capacidade | Descrição | Action Group |
|------------|-----------|--------------|
| **Análise de PR** | Revisa código, identifica riscos, sugere melhorias | `analyze-pr` |
| **Detecção de Drift** | Compara estado real vs declarado (Terraform state) | `detect-drift` |
| **Remediação** | Sugere comandos ou PRs para corrigir drift | `suggest-remediation` |
| **Runbook Generation** | Documenta procedimentos baseado em incidentes | `generate-runbook` |

---

### Conexão com Aulas Anteriores (AI Track)

| Aula | Conteúdo AI | Como se aplica aqui |
|------|-------------|---------------------|
| Aula 02 | AI-Assisted Git (Bedrock para commits) | Base de prompting e invocação Bedrock |
| Aula 07 | AI-Powered Dockerfile Optimization | Análise de código com LLM |
| Aula 09 | Predictive Pipeline Optimization | Dados de pipeline como input do agente |
| Aula 12 | Intelligent Deployment (Bedrock) | Deploy inteligente + agentes |
| **Aula 14** | **Agente DevOps Completo (Capstone)** | **Integra todas as habilidades** |

---

### Entregáveis da Aula

1. **Chaos Experiments** documentados com resultados e métricas
2. **Game Day Report** com hipóteses, medições de RTO, e melhorias identificadas
3. **Governance Setup**: CODEOWNERS, PR template, branch protection rules
4. **Agent Design Document** com arquitetura, action groups, e knowledge base
5. **Lambda Functions** implementadas para os action groups
6. **GitHub Action** que invoca o agente em eventos de PR
7. **Runbook** gerado automaticamente pelo agente

> **📁 Onde entregar:** todos esses artefatos ficam no seu repositório de portfólio (`unifaat-devops-portfolio/aula-14/`). Na pasta de entrega do fork da disciplina (`entregas/aula-14/RA/`) vai _somente_ o `entrega.md` com o link e as evidências. Ver detalhes em [`TF.md`](TF.md).

---

### Critérios de Avaliação

| Critério | Peso |
|----------|------|
| Chaos experiments executados e documentados | 20% |
| Game Day report com métricas de RTO | 15% |
| Governance configurada (CODEOWNERS, PR template, branch rules) | 15% |
| Design do agente Bedrock (arquitetura + schema) | 20% |
| Implementação dos action groups (Lambda) | 15% |
| Integração GitHub Actions + agente | 15% |

---

### Referências

- [Principles of Chaos Engineering](https://principlesofchaos.org/)
- [AWS Bedrock Agents](https://docs.aws.amazon.com/bedrock/latest/userguide/agents.html)
- [GitHub — Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-a-branch-protection-rule)
- [CODEOWNERS Syntax](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
- [Conventional Commits](https://www.conventionalcommits.org/pt-br/v1.0.0/)
- [Netflix Chaos Monkey](https://netflix.github.io/chaosmonkey/)
- [AWS Lambda — Python Handler](https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html)
- [OpenAPI Specification](https://swagger.io/specification/)
