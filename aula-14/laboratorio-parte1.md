# Laboratório Parte 1 — Disaster Simulation + Code Review e Governance

## Aula 14 — Disaster Simulation, Code Review e Agente Bedrock

### Objetivo

Executar experimentos de Chaos Engineering para validar a resiliência dos serviços TechNova, conduzir um Game Day completo com métricas de RTO, e estabelecer processos de governance (branch protection, CODEOWNERS, PR templates, conventional commits).

---

### Contexto

O CTO da TechNova desafia a equipe: *"Temos automação, temos pipelines, temos containers. Mas nunca testamos o que acontece quando as coisas quebram. Hoje vamos quebrar intencionalmente — e provar que nosso sistema se recupera. Depois, vamos colocar ordem no processo de contribuição."*

---

### Pré-requisitos

- Docker e docker-compose instalados
- Serviços `technova-api` e `technova-notifications` funcionando (Aula 13)
- Repositório no GitHub com acesso de administrador
- Conhecimento de health checks e restart policies

---

## Etapa 1 — Chaos Engineering: Fundamentos e Setup

### 1.1 Entender os Princípios

Chaos Engineering não é "quebrar coisas aleatoriamente". É um método científico:

1. **Hipótese**: "Se o container do notifications morrer, o restart policy deve restaurá-lo em menos de 30 segundos"
2. **Experimento**: Matar o container intencionalmente
3. **Observação**: Medir tempo de recuperação
4. **Conclusão**: Validar ou refutar a hipótese

### 1.2 Preparar ambiente de experimentos

Criar `chaos-experiments/docker-compose.chaos.yml`:

```yaml
version: '3.8'

services:
  technova-api:
    build:
      context: ../app-technova
    ports:
      - "3000:3000"
    environment:
      - PORT=3000
      - NODE_ENV=production
      - NOTIFICATIONS_URL=http://technova-notifications:3001
    depends_on:
      technova-notifications:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--spider", "http://localhost:3000/health"]
      interval: 5s
      timeout: 3s
      start_period: 10s
      retries: 3
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
    networks:
      - chaos-net

  technova-notifications:
    build:
      context: ../technova-notifications
    ports:
      - "3001:3001"
    environment:
      - PORT=3001
      - NODE_ENV=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--spider", "http://localhost:3001/health"]
      interval: 5s
      timeout: 3s
      start_period: 10s
      retries: 3
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
    networks:
      - chaos-net

networks:
  chaos-net:
    driver: bridge
```

### 1.3 Subir o ambiente

```bash
mkdir -p chaos-experiments
cd chaos-experiments
docker-compose -f docker-compose.chaos.yml up -d --build

# Verificar que ambos estão saudáveis
docker-compose -f docker-compose.chaos.yml ps
curl http://localhost:3000/health | jq .
curl http://localhost:3001/health | jq .
```

**Checkpoint:** Ambiente de chaos pronto com ambos os serviços saudáveis.

---

## Etapa 2 — Chaos Experiments

### Experimento 1: Container Crash Recovery

**Hipótese:** Se o container `technova-notifications` for morto abruptamente, o Docker restart policy deve restaurá-lo em menos de 30 segundos.

#### 2.1 Criar script de monitoramento

Criar `chaos-experiments/monitor.sh`:

```bash
#!/bin/bash
# Monitor de disponibilidade durante experimentos de chaos

SERVICE_URL=${1:-"http://localhost:3001/health"}
SERVICE_NAME=${2:-"technova-notifications"}
INTERVAL=${3:-2}

echo "╔══════════════════════════════════════════════╗"
echo "║  Monitor de Disponibilidade — $SERVICE_NAME"
echo "║  URL: $SERVICE_URL"
echo "║  Intervalo: ${INTERVAL}s"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Timestamp | Status | Latência | Observação"
echo "----------|--------|----------|----------"

DOWN_START=""
TOTAL_DOWNTIME=0

while true; do
  TIMESTAMP=$(date '+%H:%M:%S')
  START_TIME=$(date +%s%N)

  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$SERVICE_URL" 2>/dev/null || echo "000")

  END_TIME=$(date +%s%N)
  LATENCY=$(( (END_TIME - START_TIME) / 1000000 ))

  if [ "$HTTP_CODE" = "200" ]; then
    if [ -n "$DOWN_START" ]; then
      DOWN_END=$(date +%s)
      RECOVERY_TIME=$((DOWN_END - DOWN_START))
      echo "$TIMESTAMP | ✅ UP   | ${LATENCY}ms | RECUPERADO em ${RECOVERY_TIME}s (RTO medido)"
      TOTAL_DOWNTIME=$((TOTAL_DOWNTIME + RECOVERY_TIME))
      DOWN_START=""
    else
      echo "$TIMESTAMP | ✅ UP   | ${LATENCY}ms |"
    fi
  else
    if [ -z "$DOWN_START" ]; then
      DOWN_START=$(date +%s)
      echo "$TIMESTAMP | ❌ DOWN | ---     | FALHA DETECTADA (HTTP $HTTP_CODE)"
    else
      ELAPSED=$(($(date +%s) - DOWN_START))
      echo "$TIMESTAMP | ❌ DOWN | ---     | Indisponível há ${ELAPSED}s"
    fi
  fi

  sleep $INTERVAL
done
```

```bash
chmod +x chaos-experiments/monitor.sh
```

#### 2.2 Executar Experimento 1

**Terminal 1 — Monitor:**

```bash
./chaos-experiments/monitor.sh http://localhost:3001/health technova-notifications 2
```

**Terminal 2 — Introduzir falha:**

```bash
echo "=== EXPERIMENTO 1: Container Kill ==="
echo "Matando container technova-notifications..."
echo "Timestamp: $(date '+%H:%M:%S')"

# Kill abrupto (simula crash)
docker kill chaos-experiments-technova-notifications-1

echo "Container morto. Observando recuperação..."
```

**Registro de resultados:**

```markdown
## Resultado — Experimento 1: Container Crash

| Métrica | Valor |
|---------|-------|
| Falha introduzida em | HH:MM:SS |
| Serviço detectado DOWN | HH:MM:SS |
| Serviço recuperado em | HH:MM:SS |
| **RTO medido** | ____ segundos |
| RTO esperado | < 30 segundos |
| **Hipótese validada?** | ✅ Sim / ❌ Não |

**Observações:**
- O restart policy `unless-stopped` restaurou o container em ~X segundos
- O health check detectou a falha após ~Y segundos
- ...
```

### Experimento 2: Endpoint Unhealthy (Degradação)

**Hipótese:** Se o endpoint /health retornar erro, o Docker healthcheck deve marcar o container como unhealthy, e o serviço dependente (technova-api) deve tratar a indisponibilidade com resiliência.

#### 2.3 Criar endpoint de simulação de falha

Adicionar ao `technova-notifications/src/server.js` (temporariamente para o experimento):

```javascript
// === CHAOS ENGINEERING — REMOVER APÓS GAME DAY ===
let simulateUnhealthy = false;

app.post('/chaos/unhealthy', (req, res) => {
  simulateUnhealthy = true;
  console.log('[CHAOS] Simulando endpoint unhealthy');
  res.json({ chaos: 'unhealthy mode activated' });
});

app.post('/chaos/recover', (req, res) => {
  simulateUnhealthy = false;
  console.log('[CHAOS] Recuperando para estado saudável');
  res.json({ chaos: 'recovered to healthy' });
});

// Modificar o health check existente:
app.get('/health', (req, res) => {
  if (simulateUnhealthy) {
    return res.status(503).json({
      status: 'unhealthy',
      service: 'technova-notifications',
      reason: 'chaos-experiment',
      timestamp: new Date().toISOString()
    });
  }
  res.json({
    status: 'healthy',
    service: 'technova-notifications',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});
// === FIM CHAOS ENGINEERING ===
```

#### 2.4 Executar Experimento 2

```bash
# Rebuild com endpoint de chaos
docker-compose -f docker-compose.chaos.yml up -d --build

# Verificar que está saudável
curl http://localhost:3001/health | jq .

# Ativar modo unhealthy
curl -X POST http://localhost:3001/chaos/unhealthy | jq .

# Observar o Docker marcando como unhealthy
watch docker inspect --format='{{.State.Health.Status}}' chaos-experiments-technova-notifications-1

# Tentar criar pedido (deve funcionar por resiliência)
curl -X POST http://localhost:3000/orders \
  -H "Content-Type: application/json" \
  -d '{"product":"Teste Chaos","quantity":1}' | jq .

# Recuperar
curl -X POST http://localhost:3001/chaos/recover | jq .
```

### Experimento 3: Resource Exhaustion (Memória)

**Hipótese:** Se o container atingir o limite de memória (256MB), o Docker deve reiniciá-lo e o serviço deve se recuperar.

#### 2.5 Simular pressão de memória

Criar `chaos-experiments/memory-stress.js`:

```javascript
// Script que aloca memória progressivamente
const http = require('http');

const TARGET_URL = process.env.TARGET_URL || 'http://localhost:3001';
const buffers = [];

console.log('=== Memory Stress Test ===');
console.log(`Alvo: ${TARGET_URL}`);
console.log('Alocando memória progressivamente...\n');

const interval = setInterval(() => {
  try {
    // Alocar 10MB por iteração
    const buf = Buffer.alloc(10 * 1024 * 1024, 'x');
    buffers.push(buf);
    const totalMB = (buffers.length * 10);
    console.log(`Alocado: ${totalMB}MB total`);
  } catch (e) {
    console.log(`OOM! Memória esgotada após ${buffers.length * 10}MB`);
    clearInterval(interval);
  }
}, 1000);

// Monitorar health enquanto stressa
setInterval(async () => {
  try {
    const res = await fetch(`${TARGET_URL}/health`);
    const data = await res.json();
    console.log(`  Health: ${res.status} — ${data.status}`);
  } catch (e) {
    console.log(`  Health: UNREACHABLE — ${e.message}`);
  }
}, 2000);
```

```bash
# Executar stress dentro do container de notifications
docker exec chaos-experiments-technova-notifications-1 \
  node -e "const b=[]; setInterval(()=>{b.push(Buffer.alloc(10*1024*1024));console.log(b.length*10+'MB')},500)" &

# Monitorar
./chaos-experiments/monitor.sh http://localhost:3001/health notifications 2
```

**Checkpoint:** Três experimentos de chaos executados e documentados.

---

## Etapa 3 — Code Review e Governance

### 3.1 Configurar Branch Protection Rules

No GitHub, acessar **Settings → Branches → Add rule**:

**Configurações para branch `main`:**

| Regra | Valor | Motivo |
|-------|-------|--------|
| Require pull request reviews | 1 reviewer mínimo | Garantir revisão humana |
| Dismiss stale reviews | Ativado | Forçar re-review após mudanças |
| Require status checks | CI passando | Não mergear código quebrado |
| Require conversation resolution | Ativado | Resolver todos os comentários |
| Restrict who can push | Apenas via PR | Impedir push direto |
| Require linear history | Ativado | Histórico limpo |

**Documentar a configuração:**

```markdown
## Branch Protection — main

- ✅ Require pull request before merging (1 approval)
- ✅ Dismiss stale pull request approvals
- ✅ Require status checks to pass (CI workflow)
- ✅ Require conversation resolution
- ✅ Do not allow bypassing the above settings
- ✅ Restrict pushes (only via PR)
```

### 3.2 Criar CODEOWNERS

Criar `.github/CODEOWNERS`:

```
# CODEOWNERS — TechNova
# Cada linha define quem é responsável por revisar mudanças em determinados arquivos

# Infraestrutura — Tech Lead deve aprovar
/terraform/                    @tech-lead
/.github/workflows/            @tech-lead @devops-team
/docker-compose*.yml           @tech-lead

# Serviço de API — Backend team
/app-technova/                 @backend-team
/technova-notifications/       @backend-team

# Configurações sensíveis — Apenas leads
*.env.example                  @tech-lead
/Dockerfile                    @tech-lead @backend-team

# Documentação — Qualquer um pode revisar
/docs/                         @team
*.md                           @team
```

### 3.3 Criar PR Template

Criar `.github/pull_request_template.md`:

```markdown
## Descrição

<!-- Descreva brevemente o que este PR faz -->

## Tipo de Mudança

- [ ] 🐛 Bug fix (correção que não quebra funcionalidades existentes)
- [ ] ✨ Nova feature (funcionalidade que não quebra o que já existe)
- [ ] 💥 Breaking change (correção ou feature que altera comportamento existente)
- [ ] 📚 Documentação (apenas mudanças em docs)
- [ ] 🏗️ Infraestrutura (Terraform, Docker, CI/CD)
- [ ] 🧹 Refactor (sem mudança funcional)

## Checklist

- [ ] Meu código segue os padrões do projeto (ESLint passa)
- [ ] Adicionei testes para as mudanças
- [ ] Todos os testes passam localmente (`npm test`)
- [ ] Atualizei a documentação (se aplicável)
- [ ] O container builda sem erros (`docker build`)
- [ ] Revisei meu próprio código antes de solicitar review

## Como Testar

<!-- Passos para o reviewer testar as mudanças -->

```bash
# Comandos para testar
npm install
npm test
```

## Screenshots / Evidências

<!-- Se aplicável, adicione screenshots ou outputs -->

## Observações para o Reviewer

<!-- Algo que o reviewer deve prestar atenção especial? -->
```

### 3.4 Configurar Conventional Commits

Criar `.github/workflows/commit-lint.yml`:

```yaml
name: Commit Lint

on:
  pull_request:
    branches: [main, develop]

jobs:
  commitlint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Verificar formato dos commits
        run: |
          echo "Verificando conventional commits no PR..."
          COMMITS=$(git log --format="%s" origin/main..HEAD)

          VALID_PREFIXES="feat|fix|docs|style|refactor|test|chore|ci|perf|build|revert"

          ERRORS=0
          while IFS= read -r commit; do
            if [ -z "$commit" ]; then continue; fi
            if ! echo "$commit" | grep -qE "^($VALID_PREFIXES)(\(.+\))?: .+"; then
              echo "❌ Commit inválido: '$commit'"
              echo "   Formato esperado: tipo(escopo): descrição"
              echo "   Tipos válidos: $VALID_PREFIXES"
              ERRORS=$((ERRORS + 1))
            else
              echo "✅ OK: '$commit'"
            fi
          done <<< "$COMMITS"

          if [ $ERRORS -gt 0 ]; then
            echo ""
            echo "═══════════════════════════════════════════"
            echo "  $ERRORS commit(s) não seguem conventional commits"
            echo "  Formato: tipo(escopo): descrição"
            echo "  Exemplos:"
            echo "    feat(notifications): adicionar endpoint de stats"
            echo "    fix(api): corrigir validação de pedidos"
            echo "    docs: atualizar README com instruções de deploy"
            echo "═══════════════════════════════════════════"
            exit 1
          fi

          echo ""
          echo "✅ Todos os commits seguem o padrão conventional commits!"
```

### 3.5 Criar CONTRIBUTING.md

Criar `CONTRIBUTING.md` na raiz do repositório:

```markdown
# Guia de Contribuição — TechNova

## Como Contribuir

1. Crie uma branch a partir de `main`: `git checkout -b tipo/descricao-curta`
2. Faça suas alterações seguindo os padrões abaixo
3. Commit usando conventional commits
4. Abra um Pull Request usando o template

## Padrão de Branches

| Prefixo | Uso | Exemplo |
|---------|-----|---------|
| `feat/` | Nova funcionalidade | `feat/notification-sms` |
| `fix/` | Correção de bug | `fix/order-validation` |
| `docs/` | Documentação | `docs/api-swagger` |
| `infra/` | Infraestrutura | `infra/terraform-rds` |
| `refactor/` | Refatoração | `refactor/notification-service` |

## Conventional Commits

Formato: `tipo(escopo): descrição`

```
feat(notifications): adicionar suporte a SMS
fix(api): corrigir timeout na criação de pedidos
docs(readme): adicionar diagrama de arquitetura
chore(deps): atualizar express para 4.19
ci(actions): adicionar job de security scan
```

## Code Review

- Todo código deve passar por review antes de merge
- Resolva todos os comentários antes de mergear
- CI deve estar verde (lint + tests)
- Seja construtivo nos comentários de review

## Padrões de Código

- ESLint deve passar sem erros
- Cobertura de testes mínima: 80%
- Comentários em português para lógica de negócio
- Nomes de variáveis e funções em inglês

## Tech Debt

Se identificar débito técnico:
1. Crie uma issue com label `tech-debt`
2. Descreva o problema e impacto
3. Sugira uma solução
4. Será priorizado no próximo sprint planning
```

**Checkpoint:** Governance configurada com branch protection, CODEOWNERS, PR template, e conventional commits.

---

## Etapa 4 — Game Day Completo

### 4.1 Planejar o Game Day

Criar `chaos-experiments/game-day-plan.md`:

```markdown
# Game Day Plan — TechNova

## Data: [DATA DA AULA]
## Participantes: [NOMES]

## Objetivo
Validar a resiliência do sistema TechNova multi-serviço sob condições de falha controlada.

## Hipóteses

### H1 — Container Recovery
- **Se** o container de notifications morrer
- **Então** o restart policy deve restaurá-lo em < 30s
- **E** nenhum pedido deve ser perdido durante a indisponibilidade

### H2 — Degradação Graceful
- **Se** o serviço de notifications ficar indisponível
- **Então** o technova-api deve continuar criando pedidos (sem notificação)
- **E** retornar `notification.sent: false` ao invés de erro 500

### H3 — Cascading Failure Prevention
- **Se** ambos os serviços forem derrubados simultaneamente
- **Então** ambos devem se recuperar independentemente
- **E** o sistema deve estar totalmente operacional em < 60s

## Blast Radius
- Ambiente: Docker local (não produção)
- Serviços afetados: technova-api, technova-notifications
- Dados em risco: Nenhum (in-memory, não persistente)
- Impacto externo: Zero

## Rollback Plan
1. `docker-compose -f docker-compose.chaos.yml down`
2. `docker-compose -f docker-compose.chaos.yml up -d`
3. Verificar health checks de ambos os serviços

## Métricas a Coletar
- RTO por serviço
- Número de requisições com erro durante indisponibilidade
- Tempo para detecção de falha (health check interval)
- Comportamento de serviço dependente durante falha
```

### 4.2 Executar o Game Day

Criar `chaos-experiments/run-game-day.sh`:

```bash
#!/bin/bash
set -e

echo "╔══════════════════════════════════════════════════════════╗"
echo "║          GAME DAY — TechNova Resilience Test            ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "Data: $(date)"
echo ""

COMPOSE_FILE="docker-compose.chaos.yml"
API_URL="http://localhost:3000"
NOTIF_URL="http://localhost:3001"
RESULTS_FILE="game-day-results-$(date +%Y%m%d-%H%M%S).md"

# Funções auxiliares
check_health() {
  local url=$1
  local code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$url/health" 2>/dev/null || echo "000")
  echo "$code"
}

measure_rto() {
  local url=$1
  local name=$2
  local start=$(date +%s)
  local max_wait=120

  echo "  Medindo RTO para $name..."
  while true; do
    local elapsed=$(($(date +%s) - start))
    if [ $elapsed -ge $max_wait ]; then
      echo "  ⏰ TIMEOUT: $name não recuperou em ${max_wait}s"
      echo "$max_wait"
      return 1
    fi
    local code=$(check_health "$url")
    if [ "$code" = "200" ]; then
      echo "  ✅ $name recuperou em ${elapsed}s"
      echo "$elapsed"
      return 0
    fi
    sleep 1
  done
}

# Inicializar resultados
cat > "$RESULTS_FILE" << 'EOF'
# Game Day Results — TechNova

## Resumo Executivo

| Hipótese | Resultado | RTO Medido |
|----------|-----------|------------|
EOF

echo "▶ Fase 1: Verificando pré-condições..."
docker-compose -f $COMPOSE_FILE up -d --build
sleep 15

API_STATUS=$(check_health $API_URL)
NOTIF_STATUS=$(check_health $NOTIF_URL)

if [ "$API_STATUS" != "200" ] || [ "$NOTIF_STATUS" != "200" ]; then
  echo "❌ Pré-condições não atendidas: API=$API_STATUS, Notifications=$NOTIF_STATUS"
  exit 1
fi
echo "  ✅ Ambos os serviços saudáveis"
echo ""

# === EXPERIMENTO H1: Container Kill ===
echo "▶ Fase 2: Experimento H1 — Container Kill"
echo "  Matando container notifications..."
docker kill $(docker-compose -f $COMPOSE_FILE ps -q technova-notifications)

RTO_H1=$(measure_rto $NOTIF_URL "notifications")
H1_RESULT="✅ Validada"
[ "$RTO_H1" -gt 30 ] && H1_RESULT="❌ Falhou (RTO > 30s)"

echo "| H1 — Container Recovery | $H1_RESULT | ${RTO_H1}s |" >> "$RESULTS_FILE"
echo ""
sleep 5

# === EXPERIMENTO H2: Degradação Graceful ===
echo "▶ Fase 3: Experimento H2 — Degradação Graceful"
echo "  Parando notifications..."
docker-compose -f $COMPOSE_FILE stop technova-notifications

echo "  Criando pedido durante indisponibilidade..."
RESPONSE=$(curl -s -X POST "$API_URL/orders" \
  -H "Content-Type: application/json" \
  -d '{"product":"Chaos Test","quantity":1,"customerEmail":"chaos@test.com"}')

echo "  Resposta: $RESPONSE"

if echo "$RESPONSE" | grep -q '"status":"created"' || echo "$RESPONSE" | grep -q '"product"'; then
  echo "  ✅ H2 Validada: Pedido criado apesar de notifications indisponível"
  echo "| H2 — Degradação Graceful | ✅ Validada | N/A |" >> "$RESULTS_FILE"
else
  echo "  ❌ H2 Falhou: Pedido não foi criado"
  echo "| H2 — Degradação Graceful | ❌ Falhou | N/A |" >> "$RESULTS_FILE"
fi

# Restaurar
docker-compose -f $COMPOSE_FILE start technova-notifications
sleep 10
echo ""

# === EXPERIMENTO H3: Cascading Failure ===
echo "▶ Fase 4: Experimento H3 — Cascading Failure"
echo "  Derrubando AMBOS os serviços..."
docker-compose -f $COMPOSE_FILE kill

echo "  Reiniciando..."
docker-compose -f $COMPOSE_FILE up -d
START_H3=$(date +%s)

# Aguardar ambos recuperarem
while true; do
  ELAPSED=$(($(date +%s) - START_H3))
  API_OK=$(check_health $API_URL)
  NOTIF_OK=$(check_health $NOTIF_URL)

  if [ "$API_OK" = "200" ] && [ "$NOTIF_OK" = "200" ]; then
    echo "  ✅ H3: Sistema completo recuperado em ${ELAPSED}s"
    H3_RESULT="✅ Validada"
    [ $ELAPSED -gt 60 ] && H3_RESULT="❌ Falhou (> 60s)"
    echo "| H3 — Cascading Recovery | $H3_RESULT | ${ELAPSED}s |" >> "$RESULTS_FILE"
    break
  fi

  if [ $ELAPSED -gt 120 ]; then
    echo "  ❌ H3: Timeout — sistema não recuperou em 120s"
    echo "| H3 — Cascading Recovery | ❌ Timeout | >120s |" >> "$RESULTS_FILE"
    break
  fi
  sleep 2
done

echo ""
echo "▶ Fase 5: Cleanup..."
docker-compose -f $COMPOSE_FILE down

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║          GAME DAY COMPLETO                              ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║  Resultados salvos em: $RESULTS_FILE"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
cat "$RESULTS_FILE"
```

```bash
chmod +x chaos-experiments/run-game-day.sh
./chaos-experiments/run-game-day.sh
```

### 4.3 Documentar Resultados

Completar o arquivo de resultados com:

```markdown
## Detalhes dos Experimentos

### H1 — Container Recovery
- **Hora de início:** HH:MM:SS
- **Hora da falha:** HH:MM:SS
- **Hora da recuperação:** HH:MM:SS
- **RTO medido:** X segundos
- **Mecanismo de recuperação:** Docker restart policy (unless-stopped)
- **Observações:** ...

### H2 — Degradação Graceful
- **Comportamento do technova-api:** Continuou funcionando / Falhou
- **Resposta HTTP durante falha:** 201 com notification.sent=false
- **Pattern utilizado:** Circuit breaker simplificado (try/catch)
- **Observações:** ...

### H3 — Cascading Failure
- **Tempo total de recuperação:** X segundos
- **Ordem de recuperação:** notifications primeiro, api depois
- **Observações:** ...

## Melhorias Identificadas

1. [ ] Implementar retry com backoff exponencial na comunicação inter-serviço
2. [ ] Adicionar alertas quando RTO > 80% do limite
3. [ ] Considerar circuit breaker com Hystrix/Resilience4j
4. [ ] Adicionar persistent storage para não perder notificações

## Lições Aprendidas

- ...
- ...
- ...
```

**Checkpoint:** Game Day completo executado com resultados documentados.

---

## Validação Final — Parte 1

### Critérios de sucesso

| Critério | Status |
|----------|--------|
| Experimento 1 (Container Kill) executado e documentado | ⬜ |
| Experimento 2 (Endpoint Unhealthy) executado e documentado | ⬜ |
| Experimento 3 (Resource Exhaustion) executado e documentado | ⬜ |
| Game Day completo com medições de RTO | ⬜ |
| Branch protection configurada no GitHub | ⬜ |
| CODEOWNERS criado | ⬜ |
| PR template criado | ⬜ |
| Conventional commits workflow criado | ⬜ |
| CONTRIBUTING.md criado | ⬜ |

---

## Problemas Comuns

| Problema | Solução |
|----------|---------|
| Container não reinicia após kill | Verificar que `restart: unless-stopped` está no compose |
| Health check não detecta falha | Reduzir `interval` para 5s no compose |
| API falha quando notifications está down | Implementar try/catch na chamada HTTP (Aula 13) |
| Script de monitor não funciona | Verificar que `curl` e `jq` estão instalados |
| docker-compose kill não afeta containers | Usar `docker kill` diretamente no container ID |

---

## Próximo Passo

Continue para o **Laboratório Parte 2** onde você vai projetar e implementar o Agente DevOps com AWS Bedrock — a culminação de todo o conteúdo de IA do curso.
