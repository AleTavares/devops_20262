# Trabalho de Fixação (TF) — Aula 14: Disaster Simulation, Code Review e Agente Bedrock

## Desafio

Consolidar o aprendizado da aula capstone de IA entregando **dois artefatos principais**: (1) um **Game Day Report** documentando experimentos de Chaos Engineering com métricas reais de RTO, e (2) um **Agent Design Document** com a arquitetura completa do agente Bedrock DevOps e a implementação funcional dos action groups. Publique via Pull Request no repositório da disciplina.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | 1 semana a partir da data da aula |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork** | `entregas/aula-14/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com link do repositório + evidências |
| **Arquivos do projeto** | No repositório `unifaat-devops-portfolio`, pasta `aula-14/` |

### Como Entregar via Pull Request

1. Faça um **fork** do repositório da disciplina (se ainda não fez)
2. Clone o seu fork localmente
3. Crie a pasta `entregas/aula-14/SEU-RA/`
4. Adicione **apenas** o arquivo `entrega.md` (modelo abaixo) — os arquivos do projeto ficam no `unifaat-devops-portfolio`
5. Faça commit e push para o seu fork
6. Abra um **Pull Request** para o repositório original

**Modelo do arquivo `entrega.md`:**

```markdown
# Entrega — Aula 14: Disaster Simulation, Code Review e Agente Bedrock

**Aluno:** [Seu nome completo]
**RA:** [Seu RA]
**Data:** [Data da entrega]

## Repositório

- URL: https://github.com/SEU-USUARIO/unifaat-devops-portfolio

## Evidências

### Entregável 1 — Game Day Report
- [ ] 3 chaos experiments executados com RTO medido
- [ ] Game Day report completo (hipóteses, métricas, melhorias, lições)
- [ ] Governance configurada (branch protection, CODEOWNERS, PR template)
- [ ] Screenshots dos experimentos e do Game Day executando

### Entregável 2 — Agent Design Document
- [ ] DESIGN.md com arquitetura do agente (DevOps Guardian)
- [ ] Agent instruction prompt + schema OpenAPI dos 3 action groups
- [ ] Lambdas analyze_pr / detect_drift / generate_runbook implementadas
- [ ] `python test_local.py` passando (screenshot)
- [ ] Terraform usando `LabRole`/`LabInstanceProfile` (Learner Lab, us-east-1)
- [ ] Workflows GitHub Actions (PR review + runbook generation)

## Evidência da Execução

[Cole aqui os links/screenshots das execuções]
```

---

## Exercício: Game Day + Agente DevOps Bedrock

### Contexto

O CTO da TechNova quer provar a resiliência do sistema sob pressão e, em seguida, colocar um "engenheiro DevOps virtual" operando 24/7. Entregue os dois pilares usando o **AWS Academy Learner Lab**.

> **☁️ Learner Lab:** você vai usar as credenciais temporárias da sessão do Lab (com `aws_session_token`), sempre na região `us-east-1`. O Lab **não permite criar usuários/grupos/roles IAM** — por isso o agente e as Lambdas usam a role pré-existente `LabRole` (`arn:aws:iam::<ACCOUNT_ID>:role/LabRole`) e `LabInstanceProfile`. O padrão de produção com **OIDC** fica apenas como referência, pois está **indisponível** no Lab (exigiria criar role IAM). Rode `terraform destroy` ao final de cada sessão.

### Requisitos

#### Entregável 1 — Game Day Report (50%)

##### Nível 1 — Mínimo (nota C)
- [ ] Pelo menos 2 chaos experiments executados
- [ ] RTO medido para cada experimento
- [ ] Hipóteses definidas com resultado (validada/falhou)
- [ ] `docker-compose.chaos.yml` funcional

##### Nível 2 — Completo (nota B)
- [ ] 3 chaos experiments executados e documentados
- [ ] Script de monitoramento (`monitor.sh`)
- [ ] Script de Game Day automatizado (`run-game-day.sh`)
- [ ] Game Day report com todos os campos preenchidos
- [ ] Melhorias identificadas (mínimo 3)

##### Nível 3 — Excelência (nota A)
- [ ] Tudo do Nível 2
- [ ] Branch protection configurada (com screenshot)
- [ ] CODEOWNERS + PR template + CONTRIBUTING.md
- [ ] Conventional commits workflow
- [ ] Lições aprendidas detalhadas

#### Entregável 2 — Agent Design Document (50%)

##### Nível 1 — Design (nota C)
- [ ] `DESIGN.md` com arquitetura do agente
- [ ] Agent instruction prompt escrito
- [ ] Schema OpenAPI com pelo menos 2 action groups definidos
- [ ] Diagrama de arquitetura (texto ou imagem)

##### Nível 2 — Implementação (nota B)
- [ ] Tudo do Nível 1
- [ ] Lambda `analyze_pr` implementada e testável
- [ ] Lambda `detect_drift` implementada e testável
- [ ] Lambda `generate_runbook` implementada e testável
- [ ] `test_local.py` executando sem erros

##### Nível 3 — Integração (nota A)
- [ ] Tudo do Nível 2
- [ ] Terraform para a infraestrutura do agente usando `LabRole`/`LabInstanceProfile`
- [ ] GitHub Actions workflow para PR review automático
- [ ] Knowledge base documents criados (mínimo 3)
- [ ] Workflow de geração de runbooks via issue label

---

## Estrutura de Entrega

```
entregas/aula-14/RA/   (apenas o entrega.md; o projeto fica no portfólio)

unifaat-devops-portfolio/aula-14/
├── chaos-experiments/
│   ├── docker-compose.chaos.yml
│   ├── monitor.sh
│   ├── run-game-day.sh
│   └── game-day-report.md          ← ENTREGÁVEL PRINCIPAL 1
├── governance/
│   ├── CODEOWNERS
│   ├── pull_request_template.md
│   ├── CONTRIBUTING.md
│   └── commit-lint.yml
├── bedrock-agent/
│   ├── DESIGN.md                    ← ENTREGÁVEL PRINCIPAL 2
│   ├── agent-instruction.md
│   ├── schemas/
│   │   └── api-schema.yaml
│   ├── lambdas/
│   │   ├── analyze_pr/handler.py
│   │   ├── detect_drift/handler.py
│   │   └── generate_runbook/handler.py
│   ├── terraform/
│   │   ├── main.tf                  ← usa LabRole/LabInstanceProfile
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── knowledge-base/
│   │   ├── architecture-patterns.md
│   │   ├── incident-history.md
│   │   └── deploy-policies.md
│   └── test_local.py
├── .github/
│   └── workflows/
│       ├── devops-agent-review.yml
│       ├── generate-runbook.yml
│       └── commit-lint.yml
└── screenshots/
    ├── chaos-experiment-1.png
    ├── game-day-results.png
    ├── branch-protection.png
    ├── test-local-output.png
    └── governance-setup.png
```

> **📁 Na pasta de entrega do fork (`entregas/aula-14/RA/`) vai _somente_ o `entrega.md`.** Todo o projeto (chaos experiments, governance, agente Bedrock, workflows) e os screenshots/evidências ficam no seu repositório de portfólio (`unifaat-devops-portfolio/aula-14/`). PRs que alterem arquivos fora da sua pasta de entrega são bloqueados automaticamente.

---

## Critérios de Avaliação

| Critério | Peso | O que é avaliado |
|----------|:----:|------------------|
| Game Day — Experimentos | 20% | Execução documentada com métricas reais de RTO |
| Game Day — Report | 15% | Completude, hipóteses, lições aprendidas |
| Governance | 15% | Branch protection, CODEOWNERS, templates, conventional commits |
| Agent — Design | 20% | Clareza arquitetural, schema OpenAPI, instruction prompt |
| Agent — Implementação | 20% | Lambdas funcionais, `test_local.py` passando |
| Agent — Integração | 10% | GitHub Actions, knowledge base, Terraform com `LabRole` |

> Os pesos acima somam 100%. Entregas parciais são aceitas — faça o máximo que conseguir.

---

## Critérios de Excelência (Bônus)

Para nota acima da média, implemente adicionalmente:

- [ ] Chaos experiment adicional (latência de rede ou disco cheio)
- [ ] Agent com fallback local funcional (análise por regex sem AWS)
- [ ] Runbook gerado por invocação real do Bedrock no Learner Lab
- [ ] Tech debt tracker automatizado (issue criada automaticamente)
- [ ] Comentário do agente atualizado (não duplicado) a cada push no PR

---

## Entrega

### 1 — Publicar no portfólio

Os arquivos do projeto ficam no seu `unifaat-devops-portfolio`, pasta `aula-14/`:

```bash
cd unifaat-devops-portfolio
git checkout -b feature/aula-14-gameday-bedrock
mkdir -p aula-14/{chaos-experiments,governance,bedrock-agent}
# copie os artefatos do seu projeto para aula-14/
git add aula-14/
git commit -m "feat(aula-14): game day report + agente bedrock devops"
git checkout main
git merge feature/aula-14-gameday-bedrock
git push origin main
git push origin feature/aula-14-gameday-bedrock
```

### 2 — Registrar entrega no fork da disciplina

```bash
cd /caminho/para/seu-fork-da-disciplina
git checkout -b entregas/aula-14/SEU-RA
mkdir -p entregas/aula-14/SEU-RA
# Crie o arquivo entrega.md (modelo na seção Informações de Entrega)
git add entregas/aula-14/SEU-RA/entrega.md
git commit -m "feat(aula-14): entrega TF - SEU NOME (RA: SEU-RA)"
git push -u origin entregas/aula-14/SEU-RA
```

Abra o Pull Request no GitHub com:
- **Título:** `[Aula 14] RA: SEU-RA - SEU NOME`
- **Base:** `main`
- **Compare:** `entregas/aula-14/SEU-RA`

---

## Dicas

- **Comece pelo Game Day** — é mais rápido e vale 35% da nota (experimentos + report)
- **Execute os experimentos de verdade** — valores reais de RTO valem mais que teoria
- **Documente tudo** — screenshots, timestamps, observações
- **Agent design antes de code** — um `DESIGN.md` bem feito já vale a nota C do entregável 2
- `test_local.py` é obrigatório — prove que as Lambdas funcionam sem precisar de conta AWS
- Confirme sempre a região `us-east-1` e o uso de `LabRole`/`LabInstanceProfile` no Terraform
- Se o Bedrock recusar a chamada por credencial expirada, reabra o Learner Lab e recarregue as credenciais da sessão

---

## Conexão com Próximas Aulas

Esta é a aula capstone de IA e consolida o **AI Track** do curso (Aulas 02/07/09/12). Na **Aula 15** o curso é encerrado com a entrega final integradora, onde você reúne o pipeline, a infraestrutura, a resiliência e a governança construídos ao longo do semestre.

> **💡 Guarde seu agente e seu Game Day Report** — eles compõem o portfólio que demonstra, na entrega final, que você domina o ciclo DevOps completo.
