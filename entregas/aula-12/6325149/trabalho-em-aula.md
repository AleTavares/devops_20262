# Trabalho em Aula — Aula 12: Rollback Strategies e AIOps

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 19/11/2026

## Parte 1 — Análise de Cenário de Incidente

1. **Severidade: P1.** O fluxo mais crítico do negócio, a criação de pedidos, está quase parado (`OrdersCreated` caiu de 42 para 2, cerca de 95%), os erros 5xx sobem de 0 para 30 e o sistema já rejeita novos pedidos (`Queue overflow - rejecting new orders`). O impacto é direto no cliente e na receita, em horário comercial, e o quadro piora a cada minuto (8 minutos e crescendo). Isso fere o SLA de 99,9% contratado pelos clientes enterprise.

2. **Causa raiz provável:** degradação ou indisponibilidade de uma **dependência externa, o `payment-gateway`**. As chamadas passam a estourar o timeout de 5 s, as requisições ficam presas esperando, a latência da API sobe, os erros 5xx aparecem, o circuit breaker abre e a fila de reenvio transborda. O problema não nasce na API em si, ele chega até ela pela dependência.

3. **Evidências:**
   - **Logs:** os primeiros erros são `Timeout waiting for response from payment-gateway (5000ms)` às 14:02:15 e 14:03:01, antes de qualquer outro sintoma. Depois vêm `Circuit breaker OPEN ... after 5 failures` (14:04:22), `orders queued for retry (queue size: 45)` e `Queue overflow` (14:06:30). É a cadeia completa de uma dependência que falha.
   - **Métricas correlacionadas:** `ResponseTime` (150 → 1200 ms), `Error5xx` (0 → 30) e a queda de `OrdersCreated` (42 → 2) crescem juntos e na mesma ordem dos logs; cada chamada ao gateway segura a requisição por até 5 s.
   - **O que descarta outras causas:** `MemoryUsage` fica estável (60% → 63%), o que afasta vazamento de memória; e o aumento de CPU (35% → 88%) é consequência (threads/conexões presas, reenvios e fila), não origem.

4. **Ação imediata (agora):**
   1. Declarar o incidente P1 e avisar o time/escalação.
   2. Verificar **o que mudou** nos últimos 30 minutos (deploy, mudança de configuração, feature flag) e consultar a página de status e a conectividade do `payment-gateway`.
   3. Se a mudança recente for a integração de pagamento, desligar a flag. Se for o provedor, **manter o circuit breaker aberto** (falhar rápido, sem segurar threads), ativar o gateway reserva ou o modo "pedido pendente de pagamento" e conter a tempestade de reenvios (backoff).
   4. Acionar o suporte do provedor, comunicar o status aos clientes e acompanhar `OrdersCreated` e `Error5xx` até normalizar.

5. **Rollback necessário? Não, a princípio.** As evidências apontam para uma falha externa; reverter a versão da API não corrige o gateway e só adiciona risco (um rollback desnecessário). O rollback só se justifica se a verificação do passo 4.2 mostrar que o início do incidente coincide com um deploy que alterou a integração de pagamento. Nesse caso, o caminho mais rápido é desligar a flag (item 6) ou reverter essa versão.

6. **Feature flag:** com a `FF_PAYMENT_GATEWAY_V2=true`, se o V2 for a integração nova e o problema começou junto com a sua ativação, basta definir `FF_PAYMENT_GATEWAY_V2=false` para voltar ao fluxo anterior **em segundos, sem novo deploy e sem reiniciar**, e o resto da release continua no ar. A flag também permite liberar o V2 gradualmente (por porcentagem de usuários) para limitar o impacto de uma falha, e serve de interruptor de emergência (*kill switch*) para alternar entre gateways.

7. **Prevenção:**
   - **Timeouts mais curtos** (1 a 2 s) com *retry* limitado, backoff exponencial e jitter, para a API não segurar requisições por 5 s.
   - **Circuit breaker bem calibrado** (estado *half-open*) e **bulkhead**: pool de threads separado para o pagamento, assim uma dependência lenta não derruba o resto.
   - **Fila durável** (ex.: SQS com DLQ) com alarme de profundidade e capacidade para absorver picos, no lugar de uma fila de memória que transborda; **chaves de idempotência** para reenviar pedidos sem cobrar duas vezes.
   - **Gateway reserva** (failover) e modo degradado ("pagar depois").
   - **Observabilidade (AIOps):** alarmes de detecção de anomalia no CloudWatch para `ResponseTime`, `Error5xx`, profundidade da fila e `OrdersCreated`, com alarme composto e verificações sintéticas da dependência.
   - **Entrega segura:** mudanças de integração via feature flag + canary, e *game days* (Chaos Engineering) simulando a queda do gateway.

## Parte 2 — Runbook

# Runbook: Lentidão e erros 5xx por falha do payment-gateway

## Trigger
Alerta `TechNova-ResponseTime-Anomaly` (`ResponseTime` fora da banda esperada por mais de 5 minutos) **combinado com** `Error5xx` subindo e/ou `OrdersCreated` caindo, ou o log `Circuit breaker OPEN for payment-gateway`.

## Severidade: P1
Criação de pedidos degradada/indisponível, com impacto direto em clientes e receita.

## Diagnóstico (< 2 min)
1. Confirmar o sintoma nas métricas (últimos 15 min):
   ```bash
   aws cloudwatch get-metric-statistics --namespace AWS/ApplicationELB \
     --metric-name HTTPCode_Target_5XX_Count --dimensions Name=LoadBalancer,Value=<ALB_ID> \
     --start-time "$(date -u -d '-15 min' +%FT%TZ)" --end-time "$(date -u +%FT%TZ)" \
     --period 60 --statistics Sum
   ```
2. Procurar a assinatura da dependência nos logs da aplicação:
   ```bash
   docker logs --since 15m technova-api 2>&1 | grep -E "payment-gateway|Circuit breaker|Queue overflow" | tail -20
   ```
3. Confirmar a causa raiz: medir o gateway direto e comparar com a saúde da própria API.
   ```bash
   curl -o /dev/null -s -w "gateway: %{http_code} em %{time_total}s\n" --max-time 6 https://<payment-gateway>/health
   curl -s -o /dev/null -w "api: %{http_code} em %{time_total}s\n" http://localhost:3000/health
   ```
   Gateway lento ou com erro e API saudável = causa na dependência.
4. Verificar **o que mudou** (decide entre rollback e mitigação):
   ```bash
   aws ecr describe-images --repository-name technova-api \
     --query 'sort_by(imageDetails,&imagePushedAt)[-3:].[imageTags[0],imagePushedAt]' --output table
   git log --since="2 hours ago" --oneline
   ```
   Conferir também se `FF_PAYMENT_GATEWAY_V2` foi alterada recentemente.

## Ação Imediata
1. Abrir o canal do incidente, declarar P1 e notificar a escalação.
2. **Sem mudança recente na integração de pagamento** (causa no provedor): manter o circuit breaker aberto para falhar rápido, ativar o gateway reserva ou o modo "pedido pendente de pagamento", conter reenvios (backoff) e acionar o suporte do provedor.
3. **Com deploy recente que alterou a integração:** reverter para a imagem anterior (a última tag saudável do ECR):
   ```bash
   docker pull <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/technova-api:<TAG_ANTERIOR>
   docker stop technova-api && docker run -d --name technova-api -p 3000:3000 \
     <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/technova-api:<TAG_ANTERIOR>
   ```
   (em um ambiente Blue/Green, apontar o listener do ALB de volta para o target group estável).

## Ação via Feature Flag (se aplicável)
Se o início do incidente coincide com a ativação do novo gateway, desligar a flag, sem deploy e sem reiniciar:
```bash
# exemplo com parâmetro no SSM Parameter Store lido pela aplicação
aws ssm put-parameter --name /technova/FF_PAYMENT_GATEWAY_V2 --value false --type String --overwrite
```
Confirmar nos logs que as chamadas voltaram ao gateway anterior e que os timeouts cessaram.

## Verificação
- [ ] `ResponseTime` voltou à banda esperada (100–250 ms) por pelo menos 10 minutos.
- [ ] `Error5xx` em zero e `OrdersCreated` voltou ao patamar normal (~40/min).
- [ ] Fila de reenvio drenou e circuit breaker voltou a `CLOSED`.
- [ ] Pedidos que ficaram pendentes foram reprocessados sem cobrança duplicada (idempotência).
- [ ] Incidente comunicado como resolvido e post-mortem agendado.

## Escalação
- **Sem melhora em 10 minutos**: acionar o engenheiro de plantão sênior e o responsável pela integração de pagamentos.
- **Sem melhora em 20 minutos**, ou se o provedor confirmar indisponibilidade: acionar o gerente de engenharia/CTO e o contato do provedor; comunicar os clientes enterprise.
- Registrar linha do tempo, métricas e decisões para o post-mortem (sem culpados, com ações de prevenção).
