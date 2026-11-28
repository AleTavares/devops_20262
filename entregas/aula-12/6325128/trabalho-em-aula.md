# Trabalho em Aula — Aula 12: Rollback Strategies e AIOps

**Aluno:** Felipe Damasceno
**RA:** 6325128
**Data:** 19/11/2026

## Parte 1 — Análise de Cenário de Incidente

### 1. Severidade: **P1 (Crítico)**

**Justificativa:**
- **Impacto no negócio:** OrdersCreated caiu de 42 para 2 pedidos (queda de ~95%), impactando diretamente a receita
- **Disponibilidade:** Error5xx crescendo exponencialmente (0 → 30 erros em 10 minutos)
- **Usuários afetados:** Sistema rejeitando novos pedidos (queue overflow), afetando todos os clientes
- **Duração:** 8 minutos e crescendo, sem sinais de recuperação automática
- **Urgência:** Cada minuto parado significa perda de receita e reputação da marca

### 2. Causa raiz provável: **Falha/Degradação no serviço externo payment-gateway**

O payment-gateway está com timeout ou indisponível, causando um efeito cascata no sistema principal da TechNova.

### 3. Evidências:

1. **Logs de timeout específicos do payment-gateway:**
   - `ERROR [14:02:15] Timeout waiting for response from payment-gateway (5000ms)`
   - `ERROR [14:03:01] Timeout waiting for response from payment-gateway (5000ms)`
   - Múltiplos timeouts consecutivos apontam claramente para o gateway como ponto de falha

2. **Circuit breaker ativado:**
   - `ERROR [14:04:22] Circuit breaker OPEN for payment-gateway after 5 failures`
   - O padrão de circuit breaker detectou a falha e isolou o serviço problemático

3. **Correlação temporal e progressão dos sintomas:**
   - ResponseTime aumentou de 150ms → 1200ms (8x)
   - CPU subiu de 35% → 88% (threads bloqueadas aguardando timeout)
   - OrdersCreated despencou quando o sistema começou a rejeitar pedidos
   - MemoryUsage estável (~60%), descartando memory leak como causa

### 4. Ação imediata: **Ativar fallback/degradação graciosa — NÃO fazer rollback**

**Sequência de ações:**

1. **Isolar o problema (já feito automaticamente):**
   - Circuit breaker já está OPEN, isolando o payment-gateway

2. **Ativar modo de degradação graciosa:**
   - Redirecionar pagamentos para gateway secundário (se disponível)
   - OU aceitar pedidos sem pagamento imediato e processar de forma assíncrona
   - OU exibir mensagem informativa aos usuários e permitir "pedido pendente"

3. **Comunicação:**
   - Notificar time de negócio sobre impacto
   - Abrir ticket urgente com fornecedor do payment-gateway

4. **Monitoramento:**
   - Verificar se queue está processando quando gateway voltar
   - Monitorar health do gateway externo

### 5. Rollback necessário? **NÃO**

**Por quê:**
- O problema **não é causado por uma mudança recente no código da TechNova**
- É uma falha de **dependência externa** (payment-gateway)
- Rollback do código não resolveria o problema do gateway externo
- Os logs não mostram erros de aplicação, apenas timeouts de serviço externo
- O sistema está se comportando corretamente (circuit breaker funcionou, queue ativada, fallback tentado)

**Rollback seria apropriado apenas se:**
- Houvesse um deploy recente que mudou a integração com o gateway
- Os logs mostrassem erros de lógica de negócio
- O problema tivesse começado imediatamente após uma mudança de código

### 6. Feature flag: **Como FF_PAYMENT_GATEWAY_V2 ajudaria?**

Se a TechNova tivesse `FF_PAYMENT_GATEWAY_V2=true`, isso permitiria:

**Mitigação imediata:**
```bash
# Desabilitar gateway problemático instantaneamente
kubectl set env deployment/order-service FF_PAYMENT_GATEWAY_V2=false
# OU via ferramenta de feature flags (LaunchDarkly, etc)
```

**Benefícios:**
1. **Rollback instantâneo sem redeploy** (segundos vs minutos)
2. **Granularidade:** Desabilitar só o gateway V2, mantendo resto do sistema
3. **Rollback parcial:** Desabilitar para 100% dos usuários ou apenas alguns segmentos
4. **Teste gradual:** Reabilitar para 5% → 20% → 50% → 100% quando gateway voltar
5. **Sem downtime:** Mudança em runtime, sem restart de pods

**Cenário ideal com feature flag:**
```yaml
FF_PAYMENT_GATEWAY_V2=true  → usa gateway novo (atual com problema)
FF_PAYMENT_GATEWAY_V2=false → usa gateway antigo/alternativo (estável)
```

Tempo de mitigação: **30 segundos** (vs 5-10 min de rollback tradicional)

### 7. Prevenção: **Implementações para evitar este cenário**

**Arquitetura:**
1. **Gateway secundário (failover automático):**
   - Configurar 2+ provedores de payment gateway
   - Fallback automático quando um falha

2. **Timeout e circuit breaker otimizados:**
   - Timeout de 5000ms é muito alto → reduzir para 2000ms
   - Circuit breaker deve abrir mais cedo (3 falhas em vez de 5)

3. **Processamento assíncrono:**
   - Pedidos devem ser aceitos e enfileirados ANTES de chamar pagamento
   - Pagamento processado em background com retry

**Observabilidade:**
4. **Health check do gateway externo:**
   - Monitor independente verificando saúde do gateway a cada 30s
   - Alerta ANTES que usuários sejam impactados

5. **Alertas proativos:**
   - Alerta quando ResponseTime > 300ms (não esperar 1200ms)
   - Alerta quando Error5xx > 5 (não esperar 30)
   - Alerta quando circuit breaker abre

**Automação:**
6. **Feature flags para dependências críticas:**
   - `FF_PAYMENT_GATEWAY_PROVIDER` → escolher provedor via flag
   - Permite troca instantânea sem deploy

7. **Runbook automatizado:**
   - Script que detecta "circuit breaker open" e já ativa gateway alternativo
   - Reduz MTTR (Mean Time To Recovery)

**Teste:**
8. **Chaos Engineering:**
   - Teste mensal simulando falha do payment-gateway
   - Validar se fallbacks funcionam em produção

---

## Parte 2 — Runbook

# Runbook: Payment Gateway Timeout / Degradação

## Trigger
- **Alerta:** `TechNova-ResponseTime-Anomaly` com ResponseTime > 500ms por mais de 5 minutos
- **OU** Log: `Circuit breaker OPEN for payment-gateway`
- **OU** Error5xx crescendo + OrdersCreated caindo simultaneamente
- **OU** Múltiplos logs de timeout para payment-gateway

## Severidade: **P1 (Crítico)**
- Impacta criação de pedidos (receita direta)
- Afeta 100% dos usuários tentando comprar

---

## Diagnóstico (< 2 min)

### 1. Confirmar sintomas no dashboard
```bash
# Abrir dashboard Grafana
open https://grafana.technova.com/d/orders-overview

# Verificar métricas:
# - ResponseTime > 500ms? ✓
# - Error5xx crescendo? ✓
# - OrdersCreated caindo? ✓
```

### 2. Verificar logs do order-service
```bash
kubectl logs -n production deployment/order-service --tail=50 | grep -E "ERROR|timeout|payment-gateway"

# Procurar por:
# - "Timeout waiting for response from payment-gateway"
# - "Circuit breaker OPEN for payment-gateway"
```

### 3. Confirmar que NÃO foi deploy recente
```bash
# Verificar últimos deploys
kubectl rollout history deployment/order-service -n production

# Se último deploy foi há > 2 horas → NÃO é problema de código
# Se foi há < 30 min → considerar rollback
```

### 4. Testar health do payment-gateway diretamente
```bash
# Testar endpoint de saúde do gateway
curl -i https://api.payment-gateway.com/health

# Timeout ou 5xx? → problema confirmado no gateway externo
# 200 OK? → investigar configuração/rede
```

**✅ Confirmação da causa raiz:**
- [ ] Logs mostram timeout específico do payment-gateway
- [ ] Circuit breaker abriu para payment-gateway
- [ ] Health check do gateway falha ou timeout
- [ ] Não houve deploy recente (> 2h)

---

## Ação Imediata

### Opção A: Desabilitar gateway problemático via Feature Flag (PREFERENCIAL - 30s)
```bash
# Se FF_PAYMENT_GATEWAY_V2 existir:
kubectl set env deployment/order-service -n production FF_PAYMENT_GATEWAY_V2=false

# OU via LaunchDarkly/Split.io
curl -X PATCH https://api.launchdarkly.com/flags/payment-gateway-v2 \
  -H "Authorization: Bearer $LD_TOKEN" \
  -d '{"enabled": false}'

# Verificar mudança aplicada (5-10s)
kubectl get pods -n production -w
```

### Opção B: Ativar gateway alternativo (se configurado)
```bash
# Redirecionar para gateway secundário
kubectl set env deployment/order-service -n production \
  PAYMENT_GATEWAY_PROVIDER=stripe-backup

# OU editar ConfigMap
kubectl edit configmap order-service-config -n production
# Alterar: payment_gateway_url: https://backup-gateway.com
```

### Opção C: Modo de degradação graciosa (último recurso)
```bash
# Aceitar pedidos sem pagamento imediato
kubectl set env deployment/order-service -n production \
  PAYMENT_MODE=async

# Pedidos ficam "pending_payment" e processam quando gateway voltar
```

### Comunicação imediata
```bash
# Notificar no Slack #incidents
/incident declare payment-gateway-down p1

# Abrir ticket com fornecedor do gateway
# Template: "Payment API timing out since 14:02 UTC - affecting production"
```

---

## Ação via Feature Flag (se aplicável)

### Se gateway V2 foi recém-habilitado via flag:
```bash
# 1. Desabilitar imediatamente
FF_PAYMENT_GATEWAY_V2=false

# 2. Aguardar 2 minutos e verificar recuperação

# 3. Se recuperar: manter desabilitado e investigar V2

# 4. Reabilitar gradualmente (após correção):
# - 5% dos usuários por 1 hora
# - 25% por 2 horas  
# - 50% por 4 horas
# - 100% se métricas estáveis
```

---

## Verificação

Execute após a ação e aguarde 2-3 minutos:

- [ ] **ResponseTime voltou a < 300ms**
  ```bash
  # Verificar no Grafana ou:
  kubectl top pods -n production | grep order-service
  ```

- [ ] **Error5xx parou de crescer (= 0 novos erros)**
  ```bash
  kubectl logs deployment/order-service -n production --since=2m | grep ERROR | wc -l
  ```

- [ ] **OrdersCreated voltou ao baseline (~40 pedidos/min)**
  ```bash
  # Verificar dashboard de pedidos
  # OU query no banco:
  SELECT COUNT(*) FROM orders WHERE created_at > NOW() - INTERVAL 1 MINUTE;
  ```

- [ ] **Circuit breaker voltou a CLOSED**
  ```bash
  kubectl logs deployment/order-service -n production --tail=20 | grep "circuit breaker"
  # Deve mostrar: "Circuit breaker CLOSED" ou "Circuit breaker HALF_OPEN"
  ```

- [ ] **CPU voltou a < 50%**
  ```bash
  kubectl top pods -n production -l app=order-service
  ```

- [ ] **Queue de retry está processando** (se havia pedidos enfileirados)
  ```bash
  kubectl logs deployment/order-service -n production | grep "Processing queued order"
  ```

---

## Escalação

### Se não resolver em 5 minutos:
1. **Escalar para Tech Lead de Backend**
   - Slack: @tech-lead-backend
   - Telefone: +55 11 9xxxx-xxxx

2. **Envolver DevOps Lead** (para investigar rede/infra)
   - Slack: @devops-lead

### Se não resolver em 15 minutos:
3. **Escalar para CTO**
   - Decisão de negócio: aceitar pedidos sem pagamento vs rejeitar vendas

4. **Comunicação externa:**
   - Time de Customer Support deve notificar clientes
   - Status page: https://status.technova.com
   - Mensagem: "Estamos enfrentando lentidão no processamento de pagamentos. Pedidos estão sendo aceitos e processados assim que possível."

---

## Pós-Incidente (após resolução)

- [ ] Documentar timeline no post-mortem
- [ ] Verificar se gateway externo teve incidente (status page deles)
- [ ] Implementar health check proativo do gateway
- [ ] Considerar adicionar gateway secundário (se não existir)
- [ ] Revisar SLA com fornecedor do payment-gateway
- [ ] Atualizar alertas para detectar mais cedo (threshold menor)