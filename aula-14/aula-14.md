---
marp: true
paginate: true
backgroundColor: '#F5F7FA'
footer: 'DevOps — UniFAAT 2026-2 | Prof. Alexandre Tavares'
style: |
  section {
    font-family: 'Segoe UI', Arial, sans-serif;
    font-size: 17px;
    padding: 35px 48px 28px 48px;
    color: #333333;
  }
  h1 {
    color: #0D2B45;
    border-bottom: 3px solid #F58220;
    padding-bottom: 5px;
    font-size: 1.45em;
    margin-bottom: 8px;
    margin-top: 0;
  }
  h2 { color: #1B3A5C; font-size: 1.2em; margin: 4px 0; }
  h3 { color: #2E86C1; font-size: 0.98em; margin: 4px 0; }
  p, li { margin: 2px 0; line-height: 1.35; }
  ul, ol { margin: 3px 0; padding-left: 18px; }
  strong { color: #F58220; }
  pre { margin: 4px 0; font-size: 0.72em; line-height: 1.25; }
  code { background-color: #e8eef4; color: #1B3A5C; font-size: 0.82em; padding: 1px 4px; }
  pre code { font-size: 1em; padding: 0; }
  table { font-size: 0.82em; width: 100%; margin: 4px 0; border-collapse: collapse; }
  table th { background-color: #1B3A5C; color: white; padding: 3px 7px; }
  table td { padding: 2px 7px; border-bottom: 1px solid #ddd; }
  blockquote { font-size: 0.88em; border-left: 4px solid #F58220; padding-left: 10px; margin: 4px 0; color: #555; }
  section.title {
    background-color: #1B3A5C;
    color: white !important;
    text-align: center;
    justify-content: center;
    padding: 60px;
  }
  section.title h1 { color: #F58220 !important; border-bottom: 3px solid #F58220; font-size: 2.2em; }
  section.title h2 { color: #F58220 !important; font-size: 1.3em; }
  section.title h3 { color: #ccc !important; }
  section.title p { color: #ccc !important; }
  section.title strong { color: #F58220 !important; }
  footer { color: #888; font-size: 0.62em; }
  img { max-height: 340px; display: block; margin: 6px auto; }
---

<!-- _class: title -->

# Aula 14 — Disaster Simulation, Code Review e Agente Bedrock

**DevOps — Centro Universitário UniFAAT**
Prof. Alexandre Tavares | Semestre 2026-2

---

# O Desafio da TechNova

Episódio 14: a plataforma está madura — pipelines, IaC, microserviços em produção.

O CTO Carlos Mendes faz a pergunta que ninguém sabe responder:

> "Se o banco cair agora, em quantos minutos voltamos? Alguém já testou isso **de verdade**?"

**Três pilares nesta aula capstone de IA:**

- **Chaos Engineering** — provar resiliência quebrando
- **Code Review e Governance** — estabelecer qualidade
- **AI-Powered DevOps** — um agente Bedrock que governa o ciclo

> Nuvem: **AWS Academy Learner Lab** (`us-east-1`, sem IAM — usar `LabRole`)

---

# Objetivos de Aprendizagem

- **Aplicar Chaos Engineering** com método científico (hipótese → experimento → observação)
- **Conduzir um Game Day** medindo RTO/RPO/MTTR
- **Implementar Code Review** com branch protection, CODEOWNERS, PR template
- **Estabelecer governance** com conventional commits e CONTRIBUTING.md
- **Projetar um agente DevOps** no AWS Bedrock (action groups + knowledge base)
- **Implementar action groups** como Lambdas (analyze_pr, detect_drift, generate_runbook)
- **Integrar o agente** com GitHub Actions (PR review + runbooks)
- **Sintetizar o AI Track** (Aulas 02/07/09/12) em uma solução completa

---

# Chaos Engineering — Princípios

Não é "quebrar coisas aleatoriamente". É **método científico**:

1. **Hipótese** — "se X falhar, o sistema recupera em Y segundos"
2. **Experimento** — introduzir a falha controlada
3. **Observação** — medir o tempo de recuperação
4. **Conclusão** — validar ou refutar

Regras de ouro:

- **Definir estado estável** antes de quebrar
- **Minimizar o blast radius** (comece em ambiente controlado)
- **Automatizar** — experimentos reprodutíveis

---

# Métricas de Resiliência

| Métrica | O que mede | Meta típica |
|---------|------------|-------------|
| **RTO** | Tempo máximo aceitável fora do ar | < 60 s |
| **RPO** | Perda de dados aceitável | Zero (stateless) |
| **MTTR** | Tempo médio de recuperação **medido** | < RTO |
| **MTBF** | Tempo médio entre falhas | o maior possível |

> **RTO é meta; MTTR é resultado medido.** O Game Day existe para comparar os dois.

---

# Game Day — Estrutura

1. **Planejamento** — hipóteses, métricas, blast radius
2. **Preparação** — monitor de disponibilidade, alertas, rollback plan
3. **Execução** — introduzir falha (`docker kill`)
4. **Observação** — medir RTO, analisar dependências
5. **Retrospectiva** — achados, melhorias, lições

**Degradação graceful:** quando notifications cai, o `technova-api` deve continuar criando pedidos com `notification.sent: false` — nunca erro 500.

---

# Experimentos de Chaos (os 3)

| # | Hipótese | Como validar |
|---|----------|--------------|
| H1 | Container recupera em < 30 s via restart policy | `docker kill` + monitor |
| H2 | API degrada graceful quando notifications cai | parar notifications e criar pedido |
| H3 | Sistema completo recupera em < 60 s | `docker-compose kill` + medir |

```bash
docker kill $(docker-compose -f docker-compose.chaos.yml ps -q technova-notifications)
# monitor até retornar HTTP 200 → RTO medido
```

---

# Monitor de Disponibilidade

Script que mede o RTO automaticamente durante o experimento:

```bash
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$URL")
if [ "$HTTP_CODE" = "200" ] && [ -n "$DOWN_START" ]; then
  RTO=$(( $(date +%s) - DOWN_START ))
  echo "RECUPERADO em ${RTO}s (RTO medido)"
fi
```

O `run-game-day.sh` orquestra os 3 experimentos e grava um `game-day-results.md` com o resumo executivo.

---

# Code Review e Governance

Quando a equipe cresce, código entra sem controle. Governance resolve:

| Mecanismo | O que faz |
|-----------|-----------|
| **Branch Protection** | Exige PR + review + CI verde para `main` |
| **CODEOWNERS** | Define revisores automáticos por área |
| **PR Template** | Padroniza tipo, checklist, como testar |
| **Conventional Commits** | Mensagens semânticas verificáveis |
| **CONTRIBUTING.md** | Guia para novos contribuidores |

---

# Conventional Commits

Formato `tipo(escopo): descrição` — legível e automatizável:

```
feat(notifications): adicionar suporte a SMS
fix(api): corrigir timeout na criação de pedidos
docs(readme): adicionar diagrama de arquitetura
ci(agent): workflow de review automático com Bedrock
```

Um workflow de CI valida o formato de cada commit do PR e bloqueia os que não seguem o padrão.

---

# De Assistente a Agente (AI Track)

| Aula | Modo de IA |
|------|------------|
| 02 — Kiro | Interativo (dev pergunta, IA responde) |
| 07 — IaC | Semi-automático (IA gera, humano valida) |
| 09 — CI/CD | Automático (IA revisa cada PR) |
| **14 — Agente** | **Autônomo (recebe objetivo, decide, orquestra)** |

Um **agente Bedrock** recebe um objetivo, **decide quais ações executar** e orquestra ferramentas para alcançá-lo.

---

# Agente DevOps Guardian — Arquitetura

```
GitHub Event → GitHub Actions → Bedrock Agent → Action Groups (Lambda) → Response
                                      ↕
                              Knowledge Base (S3 + Embeddings)
```

Três peças centrais:

- **Foundation Model** — orquestra e decide (Claude 3 Haiku)
- **Action Groups** — ações concretas (Lambdas + schema OpenAPI)
- **Knowledge Base** — contexto histórico via RAG (runbooks, incidentes, padrões)

---

# Os Três Action Groups

| Action Group | Lambda | O que faz |
|--------------|--------|-----------|
| PR Analyzer | `analyze_pr` | Segurança, Docker, Terraform, conventional commits |
| Drift Detector | `detect_drift` | Estado real vs declarado da infra |
| Runbook Generator | `generate_runbook` | Runbook estruturado a partir do cenário |

Cada action group é descrito por um **schema OpenAPI** e implementado por uma **Lambda Python** no formato de evento do Bedrock Agent.

---

# Lambda analyze_pr (resumo)

```python
security_patterns = [
    (r'password\s*=\s*["\'].+["\']', 'Possível senha hardcoded'),
    (r'0\.0\.0\.0/0', 'CIDR aberto — acesso irrestrito'),
]
# + checks de Dockerfile (USER, HEALTHCHECK, :latest)
# + conventional commits no título do PR

risk_level = 'high' if any(f['severity'] == 'error' for f in findings) else 'low'
recommendation = 'request_changes' if risk_level == 'high' else 'approve'
```

Retorna `summary`, `riskLevel`, `findings[]` e `recommendation`.

---

# Terraform no Learner Lab — LabRole

Em produção, o Terraform criaria uma role IAM para o agente e as Lambdas.
No Learner Lab isso é **indisponível** — reutilize a `LabRole`:

```hcl
data "aws_caller_identity" "current" {}

locals {
  lab_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
}

resource "aws_lambda_function" "analyze_pr" {
  role = local.lab_role_arn   # sem criar role/policy IAM
  # ...
}
```

> Sem criar role nem policy IAM: o Lab não permite criar IAM.

---

# Integração GitHub Actions

Workflow dispara o agente a cada PR e comenta o resultado:

```yaml
- uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
    aws-region: us-east-1
```

- As **3 credenciais temporárias** da sessão viram GitHub Secrets
- Expiram ao encerrar o Lab — atualize a cada sessão
- Há **fallback local** (regex) se o Bedrock estiver indisponível

---

# OIDC: só como referência de produção

O padrão **ideal em produção** seria o GitHub Actions assumir uma role via **OIDC** — sem credenciais estáticas permanentes.

| | Produção | Learner Lab |
|---|----------|-------------|
| Autenticação | OIDC + role IAM (produção) | 3 credenciais temporárias da sessão |
| Criar role IAM | Sim | **Indisponível** |
| Resource role do agente | role dedicada | **`LabRole`** |

> No Lab, o OIDC (padrão de produção) fica apenas como conceito — o fluxo real usa os secrets da sessão.

---

# Teste Local — sem AWS

As Lambdas são testáveis localmente, sem conta Bedrock ativa:

```python
event = make_event('pr-analyzer', '/analyze-pr', {
    'diff': 'password = "admin123"\nFROM node:latest',
    'prTitle': 'update stuff'
})
result = handler.lambda_handler(event, None)
# → findings de security + Docker + conventional commits
```

```bash
cd bedrock-agent && python test_local.py   # ✅ Testes locais OK!
```

---

# Knowledge Base (RAG)

Documentos que dão contexto histórico ao agente:

- `architecture-patterns.md` — padrões de Docker, Terraform, microserviços
- `incident-history.md` — incidentes passados (OOM, drift de SG)
- `deploy-policies.md` — regras de pipeline e deploy

Indexados via **Titan Text Embeddings** em **OpenSearch Serverless**, consultados pelo agente para fundamentar findings e runbooks.

---

# Learner Lab — Regras da Aula

> **☁️ AWS Academy Learner Lab**

- **Região fixa** `us-east-1`
- **Credenciais temporárias** da sessão (com `aws_session_token`) — expiram ao encerrar
- **Sem IAM** — nada de criar usuários/grupos/roles → usar `LabRole` / `LabInstanceProfile`
- **Permite** Bedrock, Lambda, S3, OpenSearch Serverless
- Rode **`terraform destroy`** ao final de cada sessão

---

# Entregáveis e Avaliação

Dois entregáveis principais (50% cada no TF):

- **Game Day Report** — 3 experimentos com RTO medido + governance
- **Agent Design Document** — arquitetura, Lambdas, teste local, Terraform com `LabRole`

| Critério | Peso |
|----------|:----:|
| Chaos (experimentos + report) | 35% |
| Governance | 15% |
| Agente (design + implementação + integração) | 50% |

---

# Síntese da Aula

- **Chaos Engineering** prova resiliência com método científico e métricas (RTO)
- **Game Day** mede a recuperação; **degradação graceful** evita cascata de falhas
- **Governance** mantém qualidade: branch protection, CODEOWNERS, conventional commits
- **Agente Bedrock** orquestra action groups (Lambdas) com knowledge base
- No **Learner Lab**, use **`LabRole`** e credenciais temporárias — OIDC só como referência de produção

> Esta é a aula capstone de IA. Na **Aula 15**, o curso é encerrado com a entrega final integradora.

---

<!-- _class: title -->

# Obrigado!

**Dúvidas?**
Prof. Alexandre Tavares | DevOps — UniFAAT 2026-2
