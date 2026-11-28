# Trabalho em Aula — Aula 12: Rollback Strategies e AIOps

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 2026-11-06

## Parte 1 — Análise de Cenário de Incidente

1. **Severidade: P1.** O fluxo principal de receita está parando. `OrdersCreated` caiu de 42 para 2 por minuto (−95%) em 8 minutos. Desde 14:06 a API rejeita pedidos novos (`Queue overflow - rejecting new orders`). Os erros 5xx sobem sem parar (0 → 30) e a latência está em 1200 ms, quase 5 vezes o teto da banda esperada (250 ms). Isso não é só lentidão: clientes não conseguem comprar.

2. **Causa raiz provável:** a dependência externa `payment-gateway` está degradada ou fora do ar. A API fica presa esperando o timeout de 5000 ms do gateway, e as requisições se acumulam. Isso faz a latência e a CPU subirem. O circuit breaker abriu e passou os pedidos para uma fila de retry em memória, que encheu. A partir daí a API rejeita pedidos e devolve 5xx. O problema não está no código da TechNova. É uma falha em cascata a partir de uma dependência.

3. **Evidências:**
   - **Logs:** os primeiros erros são `Timeout waiting for response from payment-gateway (5000ms)` às 14:02 e 14:03. Depois vêm `Circuit breaker OPEN for payment-gateway after 5 failures` às 14:04 e `Queue overflow` às 14:06. É exatamente a sequência de uma dependência que cai.
   - **Linha do tempo das métricas:** `ResponseTime` sobe forte a partir do 3º ponto (350 ms), junto com o primeiro `Error5xx`. Isso bate com o horário dos primeiros timeouts. `OrdersCreated` cai na mesma proporção.
   - **Memória estável (60% → 63%):** descarta vazamento de memória, que seria o sintoma típico de um bug introduzido por deploy. A CPU (35% → 88%) sobe por causa das conexões presas e dos retries, não por um processamento novo.
   - Ponto a confirmar: se não houve deploy perto de 14:00, a hipótese de dependência externa fica praticamente fechada.

4. **Ação imediata:**
   1. Abrir o incidente P1 e avisar o plantão e o time de pagamentos.
   2. Confirmar em `/version` (`deployedAt`) e no histórico do workflow de CD que **não** houve deploy recente.
   3. Confirmar que o gateway está fora: `curl` com timeout no endpoint de saúde do provedor e consulta à status page.
   4. Mitigar sem mexer na versão da API:
      - trocar para o gateway alternativo via feature flag (ver item 6);
      - se não houver alternativa, aceitar o pedido com status "pagamento pendente" e cobrar depois, em vez de rejeitar.
   5. Baixar o timeout do gateway de 5000 ms para ~2000 ms para liberar as conexões presas.
   6. Acionar o suporte do provedor de pagamento.
   - **Não** reiniciar o container. O restart não resolve, porque o gateway continua fora. Ele ainda descartaria os 45 pedidos que estão na fila em memória.

5. **Rollback necessário? Não.** O rollback serve para desfazer uma mudança nossa que quebrou produção. Aqui a falha está fora (`payment-gateway`), e a versão anterior da API chamaria o mesmo gateway e falharia igual. Fazer rollback só adicionaria risco e tempo, sem efeito. A única exceção: se um deploy perto de 14:00 tiver mudado a integração de pagamento (endpoint, credencial, timeout), aí o rollback passa a ser a ação certa.

6. **Feature flag `FF_PAYMENT_GATEWAY_V2=true`:** a flag funciona como um "kill switch" que troca a integração de pagamento em segundos, sem build e sem deploy.
   - Se o que está falhando é o **gateway V2** (integração nova, ligada por essa flag), basta colocar `FF_PAYMENT_GATEWAY_V2=false` para voltar ao V1 estável.
   - Se o que está falhando é o V1 e o V2 é outro provedor, ligar a flag desvia o tráfego para o provedor saudável.
   - Nos dois casos, só o fluxo de pagamento muda, e o resto da API continua na mesma versão. É bem mais rápido e seguro que um rollback.

7. **Prevenção:**
   - Fazer timeout curto (1–2 s) com retry e backoff exponencial com jitter, para não prender conexões por 5 s.
   - Fazer o fallback do circuit breaker gravar numa **fila durável** (SQS + DLQ), não em memória. Assim a fila não estoura e não perde pedidos em um restart.
   - Usar bulkhead: um pool de conexões separado para o gateway, para que a lentidão dele não tome a CPU e as threads do resto da API.
   - Manter um segundo provedor de pagamento atrás de feature flag, com troca testada com antecedência.
   - Criar alarmes para a dependência e para o negócio, e não só para a API:
     - latência e erro das chamadas ao `payment-gateway`;
     - estado do circuit breaker;
     - tamanho da fila;
     - anomalia em `OrdersCreated`.
   - Fazer um health check sintético do gateway.
   - Exercitar o cenário com chaos engineering (injetar timeout no gateway em staging) e ter este runbook pronto.

## Parte 2 — Runbook

```markdown
# Runbook: Timeout no payment-gateway (falha em cascata de dependência externa)

## Trigger
- Alarme `TechNova-ResponseTime-Anomaly` em ALARM (latência fora da banda esperada)
  junto com `TechNova-HighError5xx` ou `TechNova-Incident-LatencyAndErrors`.
- Logs da API com `Timeout waiting for response from payment-gateway`,
  `Circuit breaker OPEN for payment-gateway` ou `Queue overflow`.
- Queda brusca de `OrdersCreated` (namespace `TechNova/API`).

## Severidade: P1
Pedidos sendo rejeitados = impacto direto em receita. Agir em até 5 min.
(Se o circuit breaker abriu mas a fila ainda absorve e nenhum pedido é rejeitado: P2.)

## Diagnóstico (< 2 min)
1. Confirmar sintomas e estado dos alarmes:
   aws cloudwatch describe-alarms --alarm-name-prefix TechNova- \
     --query 'MetricAlarms[].[AlarmName,StateValue]' --output table

2. Confirmar que a causa é o gateway (e não código nosso):
   aws logs tail /technova/api --since 15m --filter-pattern '"payment-gateway"'
   aws logs tail /technova/api --since 15m --filter-pattern '"Queue overflow"'

3. Descartar deploy recente (se houve deploy perto do início, ir para o runbook deploy-failed):
   HOST=$(cd aula-12/terraform && terraform output -raw api_public_ip)
   curl -s http://$HOST:3000/version | jq '{imageTag, commit, deployedAt, flags}'
   gh run list --workflow cd-with-rollback.yml --limit 3

4. Testar o gateway direto, de dentro da EC2:
   ssh -i ~/.ssh/technova-aula10-deploy.pem ec2-user@$HOST \
     'curl -s -m 3 -o /dev/null -w "%{http_code} %{time_total}s\n" "$PAYMENT_GATEWAY_URL/health"'
   (timeout ou 5xx = gateway fora → causa confirmada; consultar também a status page do provedor)

5. Memória estável + CPU subindo + timeouts do gateway = falha de dependência, NÃO bug nosso.

## Ação Imediata
1. Declarar incidente P1 no canal de incidentes e avisar o time de pagamentos.
2. NÃO fazer rollback (a versão anterior usa o mesmo gateway) e NÃO reiniciar o
   container (perde os pedidos da fila em memória sem resolver nada).
3. Aplicar a mitigação via feature flag (abaixo).
4. Sem flag disponível: reduzir o timeout do gateway e ativar o modo
   "pagamento pendente" (aceitar pedido, cobrar depois), recriando o container
   com a MESMA imagem e as novas variáveis de ambiente.
5. Abrir chamado com o provedor do gateway, anexando horários e mensagens de erro.

## Ação via Feature Flag (se aplicável)
Trocar a integração de pagamento sem deploy (o script recria o container com a mesma imagem):
   scp -i ~/.ssh/technova-aula10-deploy.pem aula-12/scripts/toggle-flag.sh ec2-user@$HOST:/tmp/
   # Se o V2 é o que falha, volta para o V1:
   ssh -i ~/.ssh/technova-aula10-deploy.pem ec2-user@$HOST 'bash /tmp/toggle-flag.sh FF_PAYMENT_GATEWAY_V2 false'
   # (se o V1 é o que falha e o V2 é o provedor alternativo, use `true`)
   curl -s http://$HOST:3000/version | jq .flags   # confirmar o valor da flag

## Verificação
- [ ] `curl http://$HOST:3000/health` responde HTTP 200 três vezes seguidas, a cada 10 s.
- [ ] `aws logs tail /technova/api --since 5m --filter-pattern '"payment-gateway"'` sem novos timeouts.
- [ ] Sem `Queue overflow` nos logs, e a fila de retry esvaziando.
- [ ] `POST /api/orders` volta a responder 201.
- [ ] `OrdersCreated` volta ao patamar normal (~40/min) e `Error5xx` volta a 0.
- [ ] `TechNova-ResponseTime-Anomaly` e `TechNova-HighError5xx` voltam para OK (2–3 min).
- [ ] Os pedidos que ficaram em "pagamento pendente" foram reprocessados depois que o gateway voltou.

## Escalação
- 0–5 min: plantão DevOps executa este runbook.
- 15 min sem melhora: escalar o time de Pagamentos/Backend e o suporte
  do provedor do gateway (chamado prioritário).
- 30 min sem melhora: Tech Lead / CTO (Carlos Mendes) decide sobre comunicação aos
  clientes e sobre desligar o checkout com uma mensagem de manutenção.
- Depois do incidente: post-mortem sem culpados em até 48 h, com as ações de prevenção.
```
