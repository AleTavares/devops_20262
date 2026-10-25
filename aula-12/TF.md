# Trabalho de Fixação (TF) — Aula 12: Rollback Strategies e AIOps

## Desafio

Consolidar o aprendizado sobre **Rollback Strategies** e **AIOps** construindo um conjunto de defesas operacionais para a TechNova API: feature flags, migrações reversíveis (expand-contract), rollback automático no pipeline, runbooks e um alerta inteligente com CloudWatch Anomaly Detection + Bedrock (ou alternativa local). Publique via Pull Request no repositório da disciplina.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | 1 semana a partir da data da aula |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork** | `entregas/aula-12/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com link do repositório + evidências |
| **Arquivos do projeto** | No repositório `unifaat-devops-portfolio`, pasta `aula-12/` |

### Como Entregar via Pull Request

1. Faça um **fork** do repositório da disciplina (se ainda não fez)
2. Clone o seu fork localmente
3. Crie a pasta `entregas/aula-12/SEU-RA/`
4. Adicione **apenas** o arquivo `entrega.md` (modelo abaixo) — os arquivos do projeto ficam no `unifaat-devops-portfolio`
5. Faça commit e push para o seu fork
6. Abra um **Pull Request** para o repositório original

**Modelo do arquivo `entrega.md`:**

```markdown
# Entrega — Aula 12: Rollback Strategies e AIOps

**Aluno:** [Seu nome completo]
**RA:** [Seu RA]
**Data:** [Data da entrega]

## Repositório

- URL: https://github.com/SEU-USUARIO/unifaat-devops-portfolio

## Evidências

- [ ] Feature flags implementadas (`src/feature-flags.js`) e integradas em pelo menos uma rota
- [ ] Migrações expand-contract com up/down testadas (`migrations/`)
- [ ] Workflow CD com rollback automático baseado em health check
- [ ] Runbook operacional documentado (`docs/runbooks/`)
- [ ] Alarme CloudWatch + Anomaly Detection configurado (`us-east-1`)
- [ ] Lambda de AIOps com `LabRole` (ou simulador local + análise com Kiro AI)
- [ ] `aiops-analise.md` preenchido
- [ ] Screenshots (feature flag ligando/desligando, migração up/down, rollback automático, alarme CloudWatch, análise da Lambda/simulador)
```

---

## Exercício: Defesas Operacionais Completas

### Contexto

Depois do incidente de sexta-feira, o CTO da TechNova quer garantir que um deploy problemático nunca mais custe 35 minutos de downtime. Você vai implementar as camadas de defesa: **desligar features sem redeploy** (feature flags), **migrar o banco sem travar o rollback** (expand-contract), **reverter sozinho quando o health check falha** (rollback automático), **responder incidentes com um roteiro** (runbook) e **detectar anomalias antes dos clientes** (AIOps).

> **☁️ Learner Lab:** use as credenciais temporárias da sessão (com `aws_session_token`), sempre na região `us-east-1`. O Lab **permite criar CloudWatch, Lambda, EventBridge e SNS**, mas **não permite criar roles IAM** — a Lambda de AIOps usa a role pré-existente **`LabRole`**. O **Bedrock** é opcional: se não tiver acesso, use o simulador local + Kiro AI (os conceitos são os mesmos).

### Requisitos

#### 1. Feature Flags + Rollback Sem Redeploy (25%)

- Módulo `src/feature-flags.js` lendo flags de variáveis de ambiente (prefixo `FF_`)
- Integração em pelo menos uma rota (ex.: cálculo de frete em `orders`)
- Endpoint `/flags` para inspeção (desabilitado em produção)
- Demonstrar "rollback" de uma feature desligando a flag + restart (sem novo deploy)

#### 2. Migrações Reversíveis Expand-Contract (20%)

- Pelo menos 2 migrações seguindo o padrão expand-contract, cada uma com `up`, `down` e `verify`
- Runner com tabela `schema_migrations` e CLI (`up`/`down`/`status`)
- Demonstrar aplicar e reverter uma migração sem perda de dados

#### 3. Rollback Automático no Pipeline (20%)

- Workflow CD que faz deploy e, numa janela de observação, roda health checks
- Se o health check falhar além do limite → **rollback automático** para a versão anterior (imagem no ECR)
- Notificação do rollback (log/Slack/SNS) e workflow marcado como falho

#### 4. Runbook Operacional (10%)

- Runbook `docs/runbooks/deploy-failed.md` com Trigger, Severidade, Diagnóstico, Ação, Verificação e Escalação
- Pelo menos uma ação de mitigação via feature flag

#### 5. AIOps: Anomaly Detection + Lambda Inteligente (25%)

- Métricas customizadas emitidas ao CloudWatch (`TechNova/API`: ResponseTime, Error5xx, OrdersCreated)
- Pelo menos 1 alarme com **threshold fixo** e 1 com **Anomaly Detection** (`ANOMALY_DETECTION_BAND`)
- Lambda que recebe o alarme (via EventBridge) e produz uma análise (severidade, causa raiz provável, ação, rollback necessário)
  - A Lambda roda com a role pré-existente **`LabRole`** — o Lab não permite criar roles novas
  - Se tiver acesso ao Bedrock, invoque o Claude Haiku; senão, use o **simulador local** + análise com **Kiro AI**
- Documento `aiops-analise.md` com análise crítica (quando confiar na IA, limitações, falsos positivos)

**Screenshots obrigatórios:**
- Feature flag ligando/desligando o comportamento de uma rota
- Migração aplicada e revertida (CLI `up`/`down`/`status`)
- Rollback automático disparado por health check falho
- Alarme CloudWatch (threshold fixo + anomaly band) no console
- Saída da análise da Lambda (ou do simulador/Kiro AI)

---

## Estrutura de Entrega

```
entregas/aula-12/RA/   (apenas o entrega.md; o projeto fica no portfólio)

unifaat-devops-portfolio/aula-12/
├── src/
│   ├── feature-flags.js        # Sistema de feature flags
│   └── metrics.js              # Emissão de métricas ao CloudWatch
├── migrations/
│   ├── 001_expand_*.js         # Migração expand-contract
│   ├── 002_expand_*.js
│   ├── runner.js               # Runner de migrações (up/down)
│   └── cli.js                  # CLI: up | down | status
├── scripts/
│   ├── health-check.sh         # Health check com retry
│   └── rollback.sh             # Rollback para versão anterior (ECR)
├── .github/workflows/
│   └── cd-with-rollback.yml    # CD com rollback automático
├── lambda-aiops/
│   ├── index.js                # Lambda (LabRole) + Bedrock
│   ├── local-simulator.js      # Alternativa sem Bedrock
│   └── package.json
├── docs/runbooks/
│   └── deploy-failed.md        # Runbook operacional
├── aiops-analise.md            # Análise crítica de AIOps
├── screenshots/
│   ├── feature-flag.png
│   ├── migration-up-down.png
│   ├── auto-rollback.png
│   ├── cloudwatch-alarm.png
│   └── aiops-analysis.png
└── README.md                   # Como executar/testar
```

> **📁 Na pasta de entrega do fork (`entregas/aula-12/RA/`) vai _somente_ o `entrega.md`.** Todo o código, migrações, scripts, Lambda, docs e as evidências ficam no seu repositório de portfólio (`unifaat-devops-portfolio/aula-12/`). PRs que alterem arquivos fora da sua pasta de entrega são bloqueados automaticamente.

---

## Critérios de Avaliação

| Critério | Peso | Descrição |
|----------|:----:|-----------|
| Feature flags | 15% | Módulo lê flags do ambiente e integra em rota; "rollback" por flag demonstrado |
| Endpoint `/flags` | 5% | Inspeção das flags, desabilitado em produção |
| Migrações expand-contract | 15% | 2 migrações com up/down/verify; reversão sem perda de dados |
| CLI de migrações | 5% | `up`/`down`/`status` funcionando com `schema_migrations` |
| Rollback automático | 20% | Workflow reverte para versão anterior quando o health check falha |
| Runbook | 10% | Trigger, diagnóstico, ação, verificação e escalação |
| Métricas + alarmes CloudWatch | 10% | Métricas customizadas + alarme fixo + anomaly band |
| Lambda AIOps (`LabRole`) | 10% | Lambda analisa o alarme (Bedrock ou simulador/Kiro AI) |
| Documentação (`aiops-analise.md`) | 5% | Análise crítica sobre IA em operações |
| Screenshots + organização | 5% | 5 screenshots e estrutura de arquivos limpa |

---

## Critérios de Excelência (Bônus)

Para nota acima da média, implemente adicionalmente:

- [ ] Rollback automático também para a estratégia Blue-Green ou Canary (switch de target group / peso)
- [ ] Feature flags dinâmicas com AWS AppConfig (sem restart)
- [ ] Alarme composto (CloudWatch Composite Alarm) correlacionando latência + erros
- [ ] Lambda emite resumo de post-mortem automático a partir dos logs
- [ ] Simulador de incidentes com 3+ cenários (latência, bug no deploy, memory leak)
- [ ] Dashboard CloudWatch com as métricas de negócio e a anomaly band

---

## Entrega

### 1 — Publicar no portfólio

Os arquivos do projeto ficam no seu `unifaat-devops-portfolio`, pasta `aula-12/`:

```bash
cd unifaat-devops-portfolio
git checkout -b feature/aula-12-rollback-aiops
mkdir -p aula-12/src aula-12/migrations aula-12/scripts
mkdir -p aula-12/.github/workflows aula-12/lambda-aiops aula-12/docs/runbooks aula-12/screenshots
# copie os arquivos do seu projeto para aula-12/
git add aula-12/
git commit -m "feat(aula-12): rollback strategies e AIOps"
git checkout main
git merge feature/aula-12-rollback-aiops
git push origin main
git push origin feature/aula-12-rollback-aiops
```

### 2 — Registrar entrega no fork da disciplina

```bash
cd /caminho/para/seu-fork-da-disciplina
git checkout -b entregas/aula-12/SEU-RA
mkdir -p entregas/aula-12/SEU-RA
# Crie o arquivo entrega.md (modelo na seção Informações de Entrega)
git add entregas/aula-12/SEU-RA/entrega.md
git commit -m "feat(aula-12): entrega TF - SEU NOME (RA: SEU-RA)"
git push -u origin entregas/aula-12/SEU-RA
```

Abra o Pull Request no GitHub com:
- **Título:** `[Aula 12] RA: SEU-RA - SEU NOME`
- **Base:** `main`
- **Compare:** `entregas/aula-12/SEU-RA`

---

## Dicas

- Comece pelas feature flags — são a base para desligar comportamento sem redeploy
- Teste as migrações `up`/`down` localmente com Docker Compose antes de automatizar
- No rollback automático, guarde a tag da versão anterior (label do container) para reverter
- Para o AIOps, se o Bedrock não estiver habilitado, use o simulador local e peça a análise ao Kiro AI
- Confirme sempre a região `us-east-1` e que a Lambda aponta para a `LabRole` (o Lab não cria roles)
- Se o `aws` falhar com `ExpiredToken`, reabra o Learner Lab e recarregue as credenciais da sessão

---

## Conexão com Próximas Aulas

As defesas que você constrói aqui fecham o ciclo operacional do curso:
- O rollback automático reaproveita as imagens versionadas no **Amazon ECR** (Aula 09) e as estratégias de deploy (Aulas 10/11)
- O AIOps (anomaly detection + Lambda inteligente) é a base de observabilidade para operar em produção com confiança
- A análise crítica de IA em operações prepara o fechamento do segundo bimestre

> **💡 Guarde este conjunto de defesas funcionando** — ele demonstra a maturidade operacional esperada ao final do curso.
