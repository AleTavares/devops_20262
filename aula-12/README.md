# Aula 12 — Rollback Strategies e AIOps

## Objetivos de Aprendizagem

Ao final desta aula, o aluno será capaz de:

1. Implementar estratégias de rollback para deploys Recreate, Blue-Green e Canary
2. Calcular e otimizar o MTTR (Mean Time To Recovery) em cenários de falha
3. Aplicar migrações de banco de dados reversíveis com estratégias expand-contract
4. Utilizar feature flags para ativar/desativar funcionalidades sem redeploy
5. Configurar políticas de rollback automatizado baseadas em health checks e métricas
6. Criar runbooks operacionais para resposta a incidentes
7. Implementar detecção de anomalias em métricas do CloudWatch usando conceitos de AIOps
8. Integrar AWS Bedrock com Lambda para alertas inteligentes e análise preditiva de incidentes

---

## Contexto Narrativo

> **O Resgate da TechNova — Episódio 12: "A Última Linha de Defesa + O Monitoramento Inteligente"**

Era sexta-feira, 17h45. O deploy da v2.8 do sistema de pedidos da TechNova tinha acabado de ir para produção. Rafael conferiu o pipeline — tudo verde. "Bom fim de semana, pessoal", disse ele fechando o laptop.

Às 18h02, o Slack explodiu.

> "Os pedidos estão retornando erro 500! Clientes não conseguem finalizar compras!"

Carlos Mendes, o CTO, ligou para Marina imediatamente:

> "Marina, perdemos 15 minutos até alguém notar o problema. Mais 20 minutos para o Rafael voltar online e fazer rollback manual. São 35 minutos de downtime numa sexta à noite. Se tivéssemos rollback automático, seriam segundos."

Marina respondeu com calma:

> "Esse é exatamente o problema que vamos resolver. Precisamos de três coisas: **rollback automático** que detecte a falha e reverta sozinho, **feature flags** para desligar funcionalidades sem redeploy, e **migrações reversíveis** para nunca ficar preso num estado de banco incompatível."

Na segunda-feira, Marina trouxe uma proposta adicional:

> "Além do rollback, quero mostrar algo que está transformando o mercado: **AIOps**. Imaginem se o sistema tivesse detectado que as métricas estavam anômalas ANTES dos clientes reclamarem. Com IA analisando padrões de erro, latência e throughput, podemos prever incidentes e agir proativamente. Vamos usar o **Amazon Bedrock** integrado ao CloudWatch para criar alertas inteligentes."

Rafael ficou empolgado:

> "Tipo... a IA avisa que algo vai dar errado antes de dar errado?"

> "Exatamente. E melhor: ela pode sugerir a causa raiz e a ação corretiva. Isso é AIOps — Artificial Intelligence for IT Operations."

---

## Cronograma da Aula

| Bloco | Atividade |
|:-----:|-----------|
| 1 | Revisão TA + Discussão |
| 2 | Conteúdo Teórico — Rollback Strategies + AIOps |
| 3 | Laboratório Parte 1 — Rollback (Feature Flags, DB Migrations, Auto-Rollback) |
| 4 | Laboratório Parte 2 — AIOps (CloudWatch + Bedrock, Alertas Inteligentes) |
| 5 | Encerramento + Orientação TF |

---

## Pré-requisitos

- **Acesso ao AWS Academy Learner Lab** com a sessão iniciada (credenciais temporárias ativas, região `us-east-1`, `LabRole`)
- **Conta GitHub** com repositório `technova-api` e pipeline CD funcional (Aula 10/11)
- **Docker** instalado e funcionando
- **Node.js** instalado (≥ 18)
- **Infraestrutura da TechNova** provisionada (EC2 com app rodando, da Aula 10/11)
- **Conhecimentos das Aulas 01-11:** Git, Docker, Terraform, CI/CD, deploy strategies (Blue-Green/Canary), monitoramento básico
- **Acesso ao Amazon Bedrock** (opcional — alternativas com Kiro AI serão fornecidas)

> **☁️ AWS Academy Learner Lab:** as credenciais da sessão incluem `aws_session_token` e **expiram quando o Lab encerra** — recarregue-as ao reabrir. Trabalhe sempre em `us-east-1`. O Lab **permite criar CloudWatch, Lambda, EventBridge e SNS** (cobertos pelos créditos do Lab), mas **não permite criar usuários/grupos/roles IAM**. Por isso, a Lambda de AIOps usa a role **pré-existente `LabRole`** (via `LabInstanceProfile`), nunca uma role nova.

> **⚠️ Amazon Bedrock:** O lab de AIOps requer acesso ao Bedrock (Claude/Titan). Se não disponível, usaremos simulações locais + Kiro AI como alternativa para os conceitos.

---

## Conteúdo Teórico — Parte 1: Rollback Strategies

### 1. O Custo do Downtime e MTTR

MTTR (Mean Time To Recovery) é a métrica mais crítica quando algo dá errado em produção:

```
┌─── Anatomia de um Incidente ─────────────────────────────────────────┐
│                                                                        │
│  Deploy v2.8          Detecção          Rollback         Recuperação  │
│     │                    │                  │                 │        │
│     ▼                    ▼                  ▼                 ▼        │
│  ───●────────────────────●──────────────────●─────────────────●───►   │
│     │◄── TTD (Time to ──►│◄── TTR (Time ──►│◄── Validação ──►│       │
│     │     Detect)         │    to Recover)  │                 │       │
│     │                                                         │       │
│     │◄──────────── MTTR (Mean Time to Recovery) ─────────────►│       │
│                                                                        │
│  TechNova sexta-feira:                                                │
│  • TTD = 15 min (ninguém monitorando)                                 │
│  • TTR = 20 min (rollback manual)                                     │
│  • MTTR = 35 minutos                                                  │
│                                                                        │
│  Meta com automação:                                                  │
│  • TTD = 30 seg (health check falha)                                  │
│  • TTR = 60 seg (rollback automático)                                 │
│  • MTTR = ~2 minutos                                                  │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 2. Rollback por Estratégia de Deploy

Cada estratégia de deploy tem seu mecanismo de rollback:

```
┌─── Recreate Rollback ────────────────────────────────────────────────┐
│                                                                        │
│  v2.8 falhou → STOP v2.8 → PULL v2.7 → START v2.7                   │
│                                                                        │
│  • Downtime: durante todo o processo (minutos)                        │
│  • Complexidade: baixa                                                │
│  • Requisito: imagens versionadas no registry                         │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘

┌─── Blue-Green Rollback ──────────────────────────────────────────────┐
│                                                                        │
│  Blue (v2.7) ─── Load Balancer ───► Green (v2.8) ← FALHANDO         │
│       │               │                                               │
│       │               │ ROLLBACK: redireciona tráfego de volta        │
│       │               ▼                                               │
│  Blue (v2.7) ◄── Load Balancer      Green (v2.8) ← isolado          │
│                                                                        │
│  • Downtime: ZERO (apenas muda o target group)                        │
│  • Complexidade: média (requer 2 ambientes)                           │
│  • Velocidade: segundos (DNS/ALB switch)                              │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘

┌─── Canary Rollback ──────────────────────────────────────────────────┐
│                                                                        │
│  95% tráfego → v2.7 (stable)                                         │
│   5% tráfego → v2.8 (canary) ← métricas degradadas                  │
│                                                                        │
│  ROLLBACK: remove canary, 100% volta para v2.7                       │
│                                                                        │
│  • Downtime: ZERO (apenas 5% dos users foram afetados)                │
│  • Complexidade: alta (requer weighted routing)                       │
│  • Impacto: mínimo (blast radius controlado)                          │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 3. Migrações de Banco de Dados Reversíveis

O maior desafio do rollback é o banco de dados. Se a v2.8 alterou o schema, voltar para v2.7 pode quebrar:

```
┌─── Problema: Migração Irreversível ──────────────────────────────────┐
│                                                                        │
│  v2.7: tabela `users` com coluna `name` (VARCHAR 100)                │
│                                                                        │
│  Migração v2.8: ALTER TABLE users DROP COLUMN name;                   │
│                  ALTER TABLE users ADD COLUMN first_name VARCHAR(50);  │
│                  ALTER TABLE users ADD COLUMN last_name VARCHAR(50);   │
│                                                                        │
│  Se fizer rollback para v2.7:                                         │
│  ❌ v2.7 espera coluna `name` que não existe mais!                    │
│  ❌ Dados de `first_name` e `last_name` seriam perdidos               │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

**Solução: Expand-Contract Pattern**

```
┌─── Expand-Contract (Migração Segura) ────────────────────────────────┐
│                                                                        │
│  FASE 1 — EXPAND (deploy v2.8a):                                      │
│  • ADD first_name, last_name (novas colunas)                          │
│  • MANTER name (coluna antiga)                                        │
│  • App escreve em AMBOS (name + first/last)                           │
│  • Migrar dados existentes: name → first_name + last_name             │
│                                                                        │
│  FASE 2 — TRANSIÇÃO (deploy v2.8b):                                   │
│  • App lê de first_name/last_name (novas)                             │
│  • App ainda escreve em name (compatibilidade)                        │
│  • Se rollback: v2.7 usa `name` que ainda existe ✅                   │
│                                                                        │
│  FASE 3 — CONTRACT (deploy v2.9, semanas depois):                     │
│  • DROP COLUMN name (só quando v2.7 não é mais necessário)            │
│  • Agora é irreversível, mas seguro (v2.7 já foi aposentado)          │
│                                                                        │
│  ⏰ Entre EXPAND e CONTRACT: dias ou semanas de convivência            │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 4. Feature Flags: Rollback Sem Redeploy

Feature flags permitem ativar/desativar funcionalidades em runtime, sem novo deploy:

```
┌─── Feature Flags ────────────────────────────────────────────────────┐
│                                                                        │
│  Sem Feature Flag:                                                    │
│  ─────────────────                                                    │
│  Bug na feature → Novo commit → CI/CD → Deploy → 10-15 min          │
│                                                                        │
│  Com Feature Flag:                                                    │
│  ────────────────                                                     │
│  Bug na feature → Desliga flag → Instantâneo (< 1 segundo)           │
│                                                                        │
│  Implementação (Node.js):                                             │
│  ┌────────────────────────────────────────────────────┐               │
│  │  // feature-flags.js                               │               │
│  │  const flags = {                                   │               │
│  │    NEW_CHECKOUT: process.env.FF_NEW_CHECKOUT,      │               │
│  │    AI_RECOMMENDATIONS: process.env.FF_AI_RECS,    │               │
│  │    BULK_ORDERS: process.env.FF_BULK_ORDERS        │               │
│  │  };                                                │               │
│  │                                                    │               │
│  │  // No código:                                     │               │
│  │  if (flags.NEW_CHECKOUT === 'true') {             │               │
│  │    return newCheckoutFlow(order);                  │               │
│  │  }                                                 │               │
│  │  return legacyCheckoutFlow(order);                │               │
│  └────────────────────────────────────────────────────┘               │
│                                                                        │
│  Rollback = mudar variável de ambiente + restart container            │
│  (ou usar serviço como LaunchDarkly/AWS AppConfig para tempo real)    │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 5. Políticas de Rollback Automático

Rollback automático monitora métricas pós-deploy e reverte se os thresholds forem violados:

```
┌─── Automated Rollback Policy ────────────────────────────────────────┐
│                                                                        │
│  Deploy v2.8                                                          │
│     │                                                                 │
│     ▼                                                                 │
│  Janela de observação (5 minutos)                                     │
│     │                                                                 │
│     ├── Health check endpoint: /health retorna 200?                   │
│     ├── Taxa de erro 5xx < 5%?                                        │
│     ├── Latência p99 < 2000ms?                                        │
│     ├── CPU < 80%?                                                    │
│     └── Throughput > 50% do baseline?                                 │
│                                                                        │
│     Se QUALQUER threshold violado:                                    │
│     │                                                                 │
│     ▼                                                                 │
│  ROLLBACK AUTOMÁTICO                                                  │
│     │                                                                 │
│     ├── Notifica equipe (Slack/PagerDuty)                             │
│     ├── Reverte para versão anterior                                  │
│     ├── Registra incidente no log                                     │
│     └── Marca deploy como FAILED                                      │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 6. Runbooks: Documentação Operacional

Runbook é um documento que descreve os passos exatos para responder a um incidente:

```
┌─── Runbook: Deploy Falhou ───────────────────────────────────────────┐
│                                                                        │
│  TRIGGER: Health check falhou após deploy                             │
│  SEVERIDADE: P1 (impacto em produção)                                 │
│  RESPONSÁVEL: Engenheiro de plantão                                   │
│                                                                        │
│  PASSOS:                                                              │
│  1. Verificar qual versão foi deployada                               │
│     $ docker ps --format "{{.Image}}"                                 │
│                                                                        │
│  2. Verificar logs da aplicação                                       │
│     $ docker logs technova-api --tail 50                              │
│                                                                        │
│  3. Se erro óbvio (crash, OOM) → rollback imediato                   │
│     $ docker stop technova-api                                        │
│     $ docker run -d --name technova-api IMAGE_ANTERIOR                │
│                                                                        │
│  4. Se erro não-óbvio → ativar feature flags defensivos               │
│     $ aws ssm put-parameter --name /technova/ff/new-checkout false    │
│                                                                        │
│  5. Notificar equipe com timeline do incidente                        │
│                                                                        │
│  ESCALAÇÃO: Se não resolver em 15 min → chamar Tech Lead              │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Conteúdo Teórico — Parte 2: AIOps (Artificial Intelligence for IT Operations)

### 1. O Que é AIOps?

AIOps aplica Inteligência Artificial e Machine Learning para automatizar e aprimorar operações de TI:

```
┌─── AIOps: Evolução do Monitoramento ────────────────────────────────┐
│                                                                        │
│  Nível 1 — Monitoramento Tradicional (Aulas 08-11):                  │
│  • Métricas coletadas (CPU, memória, requests)                        │
│  • Alertas com thresholds FIXOS (CPU > 80% → alerta)                 │
│  • Humano analisa e responde                                          │
│                                                                        │
│  Nível 2 — Monitoramento Inteligente (AIOps):                        │
│  • IA detecta ANOMALIAS (padrões fora do normal)                      │
│  • Thresholds DINÂMICOS (aprende o baseline)                          │
│  • Correlação automática de eventos                                   │
│  • Previsão de incidentes ANTES que ocorram                           │
│  • Sugestão de causa raiz e remediação                                │
│                                                                        │
│  Nível 3 — Auto-Remediação:                                          │
│  • IA detecta problema                                                │
│  • IA identifica causa raiz                                           │
│  • IA executa correção automaticamente                                │
│  • Humano é apenas notificado                                         │
│                                                                        │
│  ┌─────────────────────────────────────────────────────┐              │
│  │ Tradicional    →    AIOps    →    Auto-Remediation  │              │
│  │ (reativo)         (preditivo)      (autônomo)       │              │
│  └─────────────────────────────────────────────────────┘              │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 2. Detecção de Anomalias com CloudWatch

CloudWatch Anomaly Detection usa ML para aprender o comportamento normal das métricas:

```
┌─── Anomaly Detection ────────────────────────────────────────────────┐
│                                                                        │
│  Métrica: Request Latency (p99)                                       │
│                                                                        │
│  Normal (aprendido):                                                  │
│  • Dias úteis 9h-18h: 150-300ms                                       │
│  • Noites e fins de semana: 80-150ms                                  │
│  • Segundas-feiras: pico até 400ms (normal)                           │
│                                                                        │
│  Alerta Tradicional (threshold fixo):                                 │
│  • Latência > 500ms → alerta                                          │
│  • Problema: não detecta degradação gradual (300ms → 450ms)           │
│  • Problema: alerta falso em picos normais de segunda                 │
│                                                                        │
│  Alerta AIOps (anomaly band):                                         │
│  • ML calcula banda esperada por hora/dia da semana                   │
│  • Alerta quando métrica SAI da banda (mesmo que < 500ms)             │
│  • Segunda às 10h: 400ms é normal ✅                                   │
│  • Quarta às 15h: 400ms é anomalia ⚠️ (esperado: 150-250ms)          │
│                                                                        │
│       Latência                                                        │
│     500ms ┤                                                           │
│           │         ╭─ Anomalia detectada                             │
│     400ms ┤    ╭────●────╮                                            │
│           │╭───│─banda──│───╮                                         │
│     300ms ┤│   │ esperada│   │                                        │
│           ││   │         │   │                                        │
│     200ms ┤│   ╰─────────╯   │                                        │
│           │╰─────────────────╯                                        │
│     100ms ┤                                                           │
│           └─────────────────────────────── tempo                      │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 3. Amazon Bedrock para Análise Inteligente

Amazon Bedrock fornece acesso a LLMs (Claude, Titan) via API para análise de logs e métricas:

```
┌─── Arquitetura AIOps com Bedrock ────────────────────────────────────┐
│                                                                        │
│  CloudWatch                    Lambda                   Bedrock        │
│  (métricas/logs)               (orquestrador)          (análise IA)   │
│       │                            │                       │          │
│       │ 1. Anomalia detectada      │                       │          │
│       │──────────────────────────► │                       │          │
│       │   (EventBridge trigger)    │                       │          │
│       │                            │ 2. Coleta contexto    │          │
│       │◄───────────────────────────│    (logs, métricas)   │          │
│       │   (GetMetricData,          │                       │          │
│       │    FilterLogEvents)        │ 3. Envia para análise │          │
│       │                            │──────────────────────►│          │
│       │                            │                       │          │
│       │                            │ 4. Resposta:          │          │
│       │                            │◄──────────────────────│          │
│       │                            │  • Causa raiz provável│          │
│       │                            │  • Severidade         │          │
│       │                            │  • Ação recomendada   │          │
│       │                            │                       │          │
│       │                            │ 5. Notifica + age     │          │
│       │                            │──► Slack/SNS/rollback │          │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

> **☁️ No Learner Lab:** a Lambda orquestradora roda com a role pré-existente **`LabRole`** (o Lab não permite criar roles IAM). O Bedrock exige habilitação (Request Access); sem ele, use a análise simulada local + Kiro AI, como no Laboratório Parte 2.

### 4. Monitoramento Preditivo

AIOps não apenas detecta problemas — prevê antes que aconteçam:

```
┌─── Monitoramento Preditivo ──────────────────────────────────────────┐
│                                                                        │
│  Cenários de Previsão:                                                │
│                                                                        │
│  1. Crescimento de Disco:                                             │
│     • Logs crescendo 2GB/dia → disco cheio em 3 dias                  │
│     • Ação: alerta preventivo + sugestão de log rotation              │
│                                                                        │
│  2. Memory Leak:                                                      │
│     • Memória subindo 50MB/hora constantemente                        │
│     • Ação: alerta antes do OOM Kill + sugestão de restart            │
│                                                                        │
│  3. Degradação de Latência:                                           │
│     • Latência p99 subindo 10ms/hora (imperceptível no curto prazo)   │
│     • Ação: alerta quando tendência indica breach do SLA              │
│                                                                        │
│  4. Padrão de Erros:                                                  │
│     • Taxa de erro 0.1% → 0.3% → 0.8% (curva exponencial)            │
│     • Ação: alerta quando padrão indica escalada iminente             │
│                                                                        │
│  Implementação:                                                       │
│  • CloudWatch Anomaly Detection (built-in ML)                         │
│  • Lambda scheduled (a cada 5 min) analisa tendências                 │
│  • Bedrock para correlação de múltiplas métricas                      │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 5. Auto-Remediação: O Futuro

```
┌─── Níveis de Auto-Remediação ────────────────────────────────────────┐
│                                                                        │
│  Nível 0: Alerta apenas (humano decide e age)                         │
│  Nível 1: Alerta + sugestão de ação (humano confirma)                 │
│  Nível 2: Ação automática para problemas conhecidos                   │
│           (restart, scale up, rollback)                                │
│  Nível 3: IA decide a ação para problemas novos                       │
│           (com aprovação humana)                                       │
│  Nível 4: IA decide e age autonomamente                               │
│           (humano apenas revisa post-mortem)                           │
│                                                                        │
│  TechNova hoje: Nível 1-2                                             │
│  Meta desta aula: implementar Nível 1, conceitos de Nível 2           │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 6. Limitações e Considerações sobre AIOps

```
┌─── Realidade sobre AIOps ────────────────────────────────────────────┐
│                                                                        │
│  ✅ O que funciona bem HOJE:                                           │
│  • Anomaly detection em métricas (CloudWatch, Datadog, New Relic)     │
│  • Correlação básica de eventos                                       │
│  • Redução de ruído (agrupar alertas)                                 │
│  • Análise de logs com LLMs (causa raiz sugerida)                     │
│                                                                        │
│  ⚠️ O que está emergindo:                                             │
│  • Auto-remediação para cenários simples (restart, scale)             │
│  • Previsão de incidentes com alta taxa de acerto                     │
│  • Integração LLM + observabilidade (Bedrock, GPT)                    │
│                                                                        │
│  ❌ O que NÃO é confiável ainda:                                      │
│  • Auto-remediação para problemas complexos                           │
│  • Substituir completamente o engenheiro de plantão                   │
│  • Decisões autônomas de rollback sem supervisão                      │
│  • Correlação perfeita em sistemas muito complexos                    │
│                                                                        │
│  Recomendação: COMBINE AIOps com monitoramento tradicional            │
│  • AIOps complementa, não substitui alertas tradicionais              │
│  • Sempre tenha thresholds fixos como safety net                      │
│  • Use AIOps para reduzir TTD e sugerir ações, não para agir sozinho  │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Resumo dos Conceitos

| Conceito | Descrição |
|----------|-----------|
| MTTR | Mean Time To Recovery — tempo total de detecção + recuperação |
| Rollback Recreate | Para container atual, sobe versão anterior |
| Rollback Blue-Green | Redireciona tráfego de volta ao ambiente anterior |
| Rollback Canary | Remove instâncias canary, 100% volta ao stable |
| Expand-Contract | Padrão de migração de banco em fases (add → migrate → drop) |
| Feature Flags | Toggles para ativar/desativar features sem redeploy |
| Rollback Automático | Políticas que revertam deploys baseadas em métricas |
| Runbook | Documentação passo-a-passo para resposta a incidentes |
| AIOps | Uso de IA/ML para automação de operações de TI |
| Anomaly Detection | ML que aprende baseline e alerta desvios |
| Amazon Bedrock | Serviço AWS de LLMs para análise inteligente |
| Monitoramento Preditivo | Prever incidentes antes que ocorram via tendências |
| Auto-Remediação | Sistema que corrige problemas sem intervenção humana |
| Lambda + Bedrock | Padrão serverless para análise inteligente de incidentes (Lambda com `LabRole`) |
| Threshold Dinâmico | Limiar que se adapta ao padrão temporal da métrica |
| Blast Radius | Porcentagem de usuários afetados por um problema |

---

## Custo — AIOps no Learner Lab

| Serviço | Custo |
|---------|:-----:|
| CloudWatch (métricas básicas) | coberto pelos créditos do Lab (10 métricas customizadas incluídas) |
| CloudWatch Anomaly Detection | ~$0.30/métrica/mês (coberto pelos créditos do Lab) |
| Lambda (invocações) | coberto pelos créditos do Lab (1M requests/mês incluídos) |
| EventBridge (eventos) | coberto pelos créditos do Lab |
| Amazon Bedrock (Claude Haiku) | ~$0.25/1M input tokens (pay-per-use) |
| SNS (notificações) | coberto pelos créditos do Lab (1M requests incluídos) |

> **💡 No AWS Academy Learner Lab os custos de CloudWatch, Lambda, EventBridge e SNS são cobertos pelos créditos do Lab.** O Bedrock é pay-per-use; alternativas gratuitas com Kiro AI são fornecidas. Rode a limpeza dos recursos ao final do laboratório.

---

*Próximas etapas: Laboratório Parte 1 (Rollback Strategies) → Laboratório Parte 2 (AIOps) → TF (Trabalho de Fixação)*
