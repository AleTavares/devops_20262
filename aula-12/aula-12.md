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

# Aula 12 — Rollback Strategies e AIOps

**DevOps — Centro Universitário UniFAAT**
Prof. Alexandre Tavares | Semestre 2026-2

---

# O Incidente da TechNova

Sexta, 17h45: deploy da v2.8 do sistema de pedidos. Pipeline verde. "Bom fim de semana."

Às 18h02 o Slack explode:

> "Os pedidos estão retornando erro 500! Clientes não conseguem comprar!"

Carlos (CTO) para Marina:

> "Perdemos 15 min até alguém notar. Mais 20 min para o rollback manual. 35 minutos de downtime numa sexta à noite."

**Dois desafios desta aula:**
1. Reverter sozinho e rápido quando um deploy quebra
2. Detectar a anomalia **antes** do cliente reclamar (AIOps)

---

# Objetivos de Aprendizagem

### Rollback Strategies
- Otimizar o **MTTR** (TTD + TTR) em cenários de falha
- Rollback por estratégia: Recreate, Blue-Green, Canary
- Migrações reversíveis (**expand-contract**) e **feature flags**
- Rollback automático por health check + **runbooks**

### AIOps
- Detecção de anomalias no **CloudWatch** (thresholds dinâmicos)
- **Lambda + Bedrock** para análise inteligente de incidentes
- Monitoramento preditivo e níveis de auto-remediação
- Limites: AIOps complementa, não substitui o engenheiro

---

# MTTR: a métrica que importa no incidente

```
Deploy ──► Detecção ──► Rollback ──► Recuperação
      │◄─ TTD ─►│◄──── TTR ────►│
      │◄──────── MTTR ──────────►│
```

| | TechNova (sexta) | Meta com automação |
|--|:---:|:---:|
| TTD | 15 min (sem monitor) | 30 seg (health check) |
| TTR | 20 min (manual) | 60 seg (automático) |
| **MTTR** | **35 min** | **~2 min** |

> **Regra de ouro:** todo deploy deve ser reversível em menos tempo do que levou para deployar.

---

# Rollback por Estratégia de Deploy

| Estratégia | Mecanismo | Downtime |
|-----------|-----------|:--------:|
| **Recreate** | STOP novo → START anterior | durante o processo |
| **Blue-Green** | redireciona ALB p/ ambiente antigo | **zero** |
| **Canary** | remove canary, 100% volta ao stable | **zero** |

- Blue-Green e Canary dependem do **ambiente anterior ainda rodando**
- Todos dependem de **imagens versionadas no Amazon ECR** (rollback = pull da tag anterior)

> O registry (Aula 09) é o que torna o rollback trivial: `docker pull <ECR>/technova-api:sha-anterior`.

---

# O Problema do Banco: Migrações Reversíveis

Código é stateless (troca de container). **Dados são stateful.** Uma migração incompatível trava o rollback.

**Padrão Expand-Contract (3 fases):**

- **EXPAND:** adiciona colunas novas, mantém as antigas; app escreve em ambas
- **TRANSIÇÃO:** app lê das novas, ainda escreve nas antigas → rollback seguro ✅
- **CONTRACT:** remove colunas antigas só quando a versão anterior foi aposentada

> Nunca remova colunas no mesmo deploy que muda o código. Entre EXPAND e CONTRACT: dias ou semanas.

---

# Migração: up / down / verify

```javascript
module.exports = {
  version: '001',
  up:   async (db) => db.query('ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_email VARCHAR(255);'),
  down: async (db) => db.query('ALTER TABLE orders DROP COLUMN IF EXISTS customer_email;'),
  verify: async (db) => (await db.query(
    "SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='customer_email'"
  )).rows.length === 1
};
```

- Runner grava em `schema_migrations` dentro de uma transação (`BEGIN/COMMIT/ROLLBACK`)
- CLI: `node cli.js up | down <ver> | status`

---

# Feature Flags: Rollback Sem Redeploy

```
Sem flag:  bug → commit → CI/CD → deploy  → 10-15 min
Com flag:  bug → desliga a flag           → < 1 segundo
```

```javascript
if (featureFlags.isEnabled('new_shipping_calc')) {
  shipping = calculateShippingV2(items);  // nova
} else {
  shipping = calculateShippingV1(items);  // legada
}
```

| Tipo | Uso |
|------|-----|
| Release flag | feature em desenvolvimento |
| **Ops flag** | kill switch para emergências |

> Rollback de feature = mudar variável de ambiente + restart (ou AppConfig em tempo real).

---

# Rollback Automático no Pipeline

```
Deploy v2.8 ──► Janela de observação ──► health checks
   health falha além do limite?
        │ sim
        ▼
   ROLLBACK AUTOMÁTICO → pull da tag anterior (ECR) → notifica → marca FAILED
```

- Workflow CD faz deploy, roda N health checks e, se falhar, reverte sozinho
- Login no ECR (`aws ecr get-login-password`) **antes** do `docker pull`
- Label `previous.version` no container guarda a tag para onde voltar

---

# Runbooks: o Manual de Emergência

Documento **prescritivo** para responder a um incidente — "faça isso, depois aquilo".

**Componentes:** Trigger · Severidade (P1-P4) · Diagnóstico · Ação · Verificação · Escalação · Post-mortem

| Nível | Impacto | Resposta |
|-------|---------|:--------:|
| P1 | sistema fora do ar | imediato (< 5 min) |
| P2 | funcionalidade crítica degradada | < 30 min |
| P3 | funcionalidade secundária | < 4 horas |
| P4 | bug menor, com workaround | próximo dia útil |

---

# AIOps: Evolução do Monitoramento

```
Tradicional   →      AIOps       →    Auto-Remediation
 (reativo)        (preditivo)           (autônomo)
```

- **Nível 1 — Tradicional:** thresholds fixos, humano analisa
- **Nível 2 — AIOps:** anomalias, thresholds dinâmicos, correlação, previsão
- **Nível 3 — Auto-remediação:** IA detecta, decide e age

> TechNova hoje: Nível 1-2. Meta da aula: implementar Nível 1, conceitos de Nível 2.

---

# CloudWatch Anomaly Detection

Threshold fixo não vê **degradação gradual** nem distingue **picos normais**.

```
Latência
 400ms ┤    ╭────●────╮  ← anomalia (fora da banda)
       │╭───│─banda──│──╮
 200ms ┤│   ╰────────╯  │  ← banda esperada (ML por hora/dia)
       │╰───────────────╯
       └──────────────────── tempo
```

- ML aprende o baseline por hora/dia da semana
- `ANOMALY_DETECTION_BAND(m1, 2)` → alerta ao sair da banda
- Segunda 10h a 400ms = normal ✅; quarta 15h a 400ms = anomalia ⚠️

---

# Arquitetura AIOps com Bedrock

```
CloudWatch ──(EventBridge)──► Lambda ──► Bedrock
 (anomalia)                  (LabRole)   (análise IA)
                                │
                                ├─► coleta métricas + logs (15 min)
                                └─► SNS / Slack / rollback
```

- A anomalia dispara um evento; a Lambda **coleta contexto** antes de chamar o LLM
- Bedrock devolve: causa raiz provável, severidade, ação, `rollback_necessario`

> **☁️ Learner Lab:** a Lambda usa a role pré-existente **`LabRole`** (o Lab não cria roles IAM). Sem Bedrock, use o simulador local + Kiro AI.

---

# Lambda + Bedrock: análise estruturada

```javascript
const input = {
  modelId: 'anthropic.claude-3-haiku-20240307-v1:0',
  body: JSON.stringify({
    anthropic_version: 'bedrock-2023-05-31',
    max_tokens: 1024,
    messages: [{ role: 'user', content: prompt }]
  })
};
const res = await bedrock.send(new InvokeModelCommand(input));
// → { severidade, causa_raiz_provavel, confianca, acao_recomendada, rollback_necessario }
```

- Prompt inclui métricas + logs recentes → análise **específica**, não genérica
- Fallback por **regras** se o Bedrock não estiver disponível (TypeError → rollback; timeout → infra)

---

# Monitoramento Preditivo

AIOps não só detecta — **prevê** antes de acontecer:

| Sinal | Previsão | Ação |
|-------|----------|------|
| Logs +2GB/dia | disco cheio em 3 dias | log rotation |
| Memória +50MB/h | OOM iminente | restart preventivo |
| p99 +10ms/h | breach de SLA | alerta de tendência |
| Erros 0.1→0.3→0.8% | escalada exponencial | alerta precoce |

> Lambda agendada analisa tendências; Bedrock correlaciona múltiplas métricas.

---

# Limites do AIOps

| ✅ Funciona hoje | ❌ Ainda não confiável |
|------------------|------------------------|
| Anomaly detection em métricas | Auto-remediação de problemas complexos |
| Redução de ruído de alertas | Substituir o engenheiro de plantão |
| Causa raiz sugerida por LLM | Rollback autônomo sem supervisão |

> **Recomendação:** combine AIOps com monitoramento tradicional. Mantenha thresholds fixos como safety net. Use IA para reduzir TTD e sugerir ações — não para agir sozinha.

---

# Resumo dos Conceitos

| Conceito | Descrição |
|----------|-----------|
| MTTR | tempo de detecção + recuperação |
| Expand-Contract | migração em fases (add → migrate → drop) |
| Feature Flags | ligar/desligar features sem redeploy |
| Rollback Automático | reverte por health check (pull da tag anterior no ECR) |
| Runbook | roteiro prescritivo de incidente (P1-P4) |
| Anomaly Detection | ML aprende baseline e alerta desvios |
| Lambda + Bedrock | análise inteligente (Lambda com `LabRole`) |
| Auto-Remediação | níveis 0-4 de autonomia |

---

# Referências e Próximos Passos

**Referências:**
- AWS CodeDeploy — Rollbacks: [docs.aws.amazon.com/codedeploy](https://docs.aws.amazon.com/codedeploy/latest/userguide/deployments-rollback-and-redeploy.html)
- Expand-Contract (Prisma): [prisma.io/dataguide](https://www.prisma.io/dataguide/types/relational/expand-and-contract-pattern)
- Feature Toggles (Fowler): [martinfowler.com](https://martinfowler.com/articles/feature-toggles.html)
- CloudWatch Anomaly Detection: [docs.aws.amazon.com/AmazonCloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Anomaly_Detection.html)
- Amazon Bedrock: [docs.aws.amazon.com/bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html)

**Para o TF:**
- Feature flags + migrações + rollback automático + runbook + AIOps (CloudWatch/Lambda `LabRole`/Bedrock)
- Rode a limpeza dos recursos ao final (créditos do Lab)

> **Fechamento do bimestre:** você consolidou o ciclo operacional — build, deploy, observar e reverter com confiança.
