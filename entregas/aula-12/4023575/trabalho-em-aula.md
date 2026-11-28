# Trabalho em Aula — Aula 12: Rollback Strategies e AIOps

**Aluno:** Emilly Santos de Oliveira
**RA:** 4023575
**Data:** 24/11/2026

## Parte 1 — Análise de Cenário de Incidente

**1. Severidade: P1**

O incidente é P1 porque impacta diretamente o fluxo de negócio principal da TechNova: pedidos estão sendo rejeitados (`Queue overflow - rejecting new orders`), `OrdersCreated` caiu de 42 para 2 em 8 minutos, e o tempo de resposta está em 1200ms com tendência crescente. Há perda de receita em tempo real.

**2. Causa raiz provável:**

O gateway de pagamento (`payment-gateway`) está indisponível ou com latência extremamente alta, causando timeouts de 5000ms em série. Isso abriu o circuit breaker, sobrecarregou a fila de retry e eventualmente levou ao overflow, bloqueando novos pedidos. O problema não é interno à aplicação — é uma dependência externa degradada.

**3. Evidências:**

- `ERROR [14:02:15] Timeout waiting for response from payment-gateway (5000ms)` — o primeiro timeout aparece antes de qualquer degradação de CPU, indicando que a falha veio de fora.
- `Circuit breaker OPEN for payment-gateway after 5 failures` — confirmação de que o gateway falhou repetidamente, não foi um evento isolado.
- `MemoryUsage` praticamente estável (60% → 63%) enquanto `CPU` dispara (35% → 88%) — a memória não vazou, o CPU subiu por acúmulo de threads esperando timeout do gateway, o que aponta para bloqueio em I/O externo, não leak interno.

**4. Ação imediata:**

Desabilitar o fluxo de pagamento via feature flag para parar o acúmulo de timeouts e aliviar a fila. Em paralelo, verificar o status do gateway de pagamento junto ao provedor (dashboard/status page). Se a flag não estiver disponível, fazer restart do serviço para limpar a fila e o circuit breaker, e redirecionar temporariamente para um gateway alternativo se existir.

**5. Rollback necessário? Não.**

O problema não foi introduzido por um deploy recente — não há nenhum indício nos logs ou métricas de que uma nova versão foi publicada. A causa é externa (gateway de pagamento). Fazer rollback da aplicação não resolveria nada e adicionaria tempo de indisponibilidade desnecessário.

**6. Feature flag `FF_PAYMENT_GATEWAY_V2=true`:**

Se essa flag existisse, bastaria setar `FF_PAYMENT_GATEWAY_V2=false` para redirecionar as chamadas de pagamento para a versão anterior do gateway (v1) ou para uma rota de fallback, sem nenhum redeploy. Isso interromperia imediatamente os timeouts, esvaziaria a fila e restauraria o fluxo de pedidos em segundos. É exatamente o tipo de cenário para o qual feature flags são projetadas: isolamento rápido de uma integração problemática sem risco de deploy.

**7. Prevenção:**

- Implementar **timeout agressivo** nas chamadas ao gateway (ex: 1500ms) em vez de 5000ms, para falhar rápido e não acumular threads bloqueadas.
- Configurar **circuit breaker com half-open** para tentar recuperação automática periódica.
- Adicionar **health check** do gateway como métrica no CloudWatch com alarme em P2 ao primeiro timeout, antes de virar crise.
- Ter um **gateway de pagamento alternativo** configurado como fallback.
- Usar **feature flags** para todos os provedores de pagamento, permitindo troca imediata sem deploy.
- Monitorar `queue size` como métrica e alertar quando ultrapassar um threshold (ex: 20 itens).

---

## Parte 2 — Runbook

```markdown
# Runbook: Degradação por Timeout no Gateway de Pagamento

## Trigger
Alarme `TechNova-ResponseTime-Anomaly` disparado com ResponseTime > 500ms por mais de 5 minutos
OU logs com `Timeout waiting for response from payment-gateway` em frequência > 3/min.

## Severidade: P1

## Diagnóstico (< 2 min)

1. Verificar logs do serviço de pedidos em tempo real:
   ```bash
   aws logs filter-log-events \
     --log-group-name /ecs/technova-orders \
     --filter-pattern "payment-gateway" \
     --start-time $(date -d '10 minutes ago' +%s000)
   ```

2. Verificar estado do circuit breaker e tamanho da fila:
   ```bash
   curl -s https://api.technova.internal/health | jq '.dependencies.paymentGateway'
   curl -s https://api.technova.internal/metrics | grep -E 'queue_size|circuit_breaker'
   ```

3. Confirmar a causa raiz — checar se o gateway externo está fora:
   ```bash
   curl -o /dev/null -s -w "%{http_code} %{time_total}s\n" https://api.payment-gateway.com/health
   # Resposta esperada: 200 em < 0.5s. Qualquer outra coisa confirma o problema externo.
   ```

## Ação Imediata

1. Desabilitar o gateway v2 via feature flag (parar novos timeouts):
   ```bash
   aws ssm put-parameter \
     --name "/technova/feature-flags/FF_PAYMENT_GATEWAY_V2" \
     --value "false" \
     --overwrite
   ```

2. Se não houver feature flag, fazer restart do pod/task para limpar fila e circuit breaker:
   ```bash
   aws ecs update-service \
     --cluster technova-cluster \
     --service technova-orders \
     --force-new-deployment
   ```

3. Notificar o time no canal de incidentes (#incidents) com severidade, horário de início e ação tomada.

4. Abrir chamado no provedor do gateway de pagamento com os logs de timeout.

## Ação via Feature Flag (se aplicável)

```bash
# Redirecionar para gateway v1 (fallback)
aws ssm put-parameter \
  --name "/technova/feature-flags/FF_PAYMENT_GATEWAY_V2" \
  --value "false" \
  --overwrite

# Confirmar que a flag foi aplicada
aws ssm get-parameter \
  --name "/technova/feature-flags/FF_PAYMENT_GATEWAY_V2" \
  --query "Parameter.Value"
```

A aplicação deve reler a flag em até 60 segundos (dependendo do TTL do cache de configuração).

## Verificação

- [ ] `ResponseTime` voltou para a banda esperada (100–250ms)
- [ ] `Error5xx` zerou ou está abaixo de 1/min
- [ ] `OrdersCreated` voltou ao volume normal para o horário
- [ ] Fila de retry esvaziou (`queue size` = 0)
- [ ] Circuit breaker fechado (estado `CLOSED`)
- [ ] CPU voltou abaixo de 50%

## Escalação

- Se não resolver em **10 minutos**: escalar para o engenheiro sênior de backend responsável pelo serviço de pagamentos.
- Se não resolver em **20 minutos**: escalar para o CTO e acionar o provedor do gateway com prioridade máxima.
- Registrar timeline completa no post-mortem após resolução.
```