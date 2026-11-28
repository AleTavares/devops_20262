# Trabalho em Aula — Aula 12: Rollback Strategies e AIOps

**Aluno:** Carina Gonçalves dos Santos Dalpino
**RA:** 6325109
**Data:** 19/11/2026

## Parte 1 — Análise de Cenário de Incidente

1. **Severidade: P1.** Os clientes já são afetados e há perda de receita. Os pedidos criados caíram de 42 para 2 por intervalo, o Error5xx subiu de 0 para 30 e a fila estourou: "Queue overflow - rejecting new orders". O sistema está recusando pedidos agora, e o problema segue piorando há 8 minutos.

2. **Causa raiz provável:** degradação ou indisponibilidade do **payment-gateway** (dependência externa). A API espera 5000 ms por resposta, estoura o timeout, o circuit breaker abre e a fila de reprocessamento enche. O problema não parece estar na aplicação em si.

3. **Evidências:**
   - Os logs mostram a sequência causal: timeouts de 5000 ms no payment-gateway (14:02 e 14:03), circuit breaker OPEN após 5 falhas (14:04), fila com 45 pedidos (14:05) e overflow (14:06).
   - A memória ficou estável (60% → 63%), o que descarta vazamento de memória na aplicação. A CPU subiu de forma gradual (35% → 88%), compatível com threads e retries presos esperando o gateway, e não com um bug de processamento.
   - A queda de OrdersCreated (42 → 2) acompanha o crescimento do Error5xx (0 → 30) e do ResponseTime (150 → 1200 ms). O ResponseTime sobe junto com os timeouts, o que aponta o gargalo na chamada ao gateway.

4. **Ação imediata (agora):**
   - Confirmar a causa em menos de 2 minutos: testar o gateway (`curl` com tempo) e olhar a página de status do provedor.
   - Verificar se houve deploy ou mudança de configuração nos últimos 30 minutos.
   - Mitigar: desligar a integração nova pela feature flag (se foi a mudança recente) ou ativar o fallback de pagamento alternativo.
   - Proteger a fila: aumentar o limite e parar de rejeitar pedidos, e drenar com retry controlado.
   - Comunicar no canal de incidente e abrir a página de status.

5. **Rollback necessário? Depende, mas por ora não.** As métricas apontam para uma dependência externa. Um rollback de código só resolve se a degradação começou depois de um deploy, o que ainda não foi verificado. Fazer rollback sem essa evidência desperdiça tempo e acrescenta risco. A decisão se confirma na linha do tempo: se o início das falhas coincidir com um deploy, faz-se rollback. Se não coincidir, trata-se como incidente de dependência externa.

6. **Feature flag `FF_PAYMENT_GATEWAY_V2=true`:** se a falha vem da versão nova da integração, basta mudar a flag para `false`. Assim o tráfego volta ao gateway anterior em segundos, sem build, sem deploy e sem rollback da aplicação. Também permite liberar a V2 gradualmente (por percentual de usuários) e desligá-la só para a parte afetada. Se o problema for do provedor externo, a flag só ajuda quando existir outro caminho de pagamento para onde alternar.

7. **Prevenção:**
   - Reduzir o timeout do gateway (5000 ms é muito alto) e usar circuit breaker com estado half-open, para testar a recuperação de forma automática.
   - Trocar a fila em memória por uma fila durável (por exemplo SQS com DLQ), para não perder pedidos em caso de overflow.
   - Alarmes de anomalia (CloudWatch Anomaly Detection) sobre ResponseTime, Error5xx e OrdersCreated, para disparar antes dos 8 minutos.
   - Monitor sintético do gateway e alerta de latência da dependência.
   - Um segundo provedor de pagamento como fallback e deploy gradual (canary) de qualquer troca de integração.
   - Runbook testado, com responsáveis definidos.

## Parte 2 — Runbook

# Runbook: Timeout no payment-gateway com circuit breaker aberto

## Trigger
Alarme `TechNova-ResponseTime-Anomaly` (ResponseTime fora da banda esperada) combinado com Error5xx crescente e logs de "Timeout waiting for response from payment-gateway" ou "Circuit breaker OPEN for payment-gateway".

## Severidade: P1
Pedidos sendo rejeitados (OrdersCreated em queda) e erros 5xx para o cliente.

## Diagnóstico (< 2 min)
1. Confirmar o padrão nos logs da aplicação:
   ```bash
   docker logs --since 15m technova-api 2>&1 | grep -E "payment-gateway|Circuit breaker|Queue overflow" | tail -20
   ```
2. Ver as métricas de tendência (ResponseTime e Error5xx dos últimos 15 min):
   ```bash
   aws cloudwatch get-metric-statistics --namespace TechNova --metric-name ResponseTime \
     --statistics Average --period 60 \
     --start-time $(date -u -d '-15 min' +%FT%TZ) --end-time $(date -u +%FT%TZ)
   ```
3. Testar o gateway direto, a partir da própria EC2, para separar problema externo de problema interno:
   ```bash
   curl -s -o /dev/null -w "HTTP %{http_code} em %{time_total}s\n" --max-time 6 https://<URL-DO-GATEWAY>/health
   ```
4. Verificar a mudança recente (deploy ou flag) para decidir sobre rollback:
   ```bash
   docker inspect technova-api --format '{{.Created}} {{.Config.Image}}'
   ```
   - Se o início das falhas coincide com um deploy ou mudança de flag, a causa provável é a mudança. Siga para rollback ou flag.
   - Se não coincide e o `curl` do passo 3 também falha ou demora, a causa é o gateway externo.

## Ação Imediata
1. Abrir o canal de incidente e avisar o time. Registrar o horário de início.
2. Se o gateway é o problema: ativar o fallback de pagamento alternativo (ou o modo de fila durável) e ampliar o limite da fila para parar de rejeitar pedidos.
3. Se a causa é um deploy recente: fazer rollback para a imagem anterior.
   ```bash
   docker compose pull technova-api   # imagem anterior fixada por tag
   docker compose up -d technova-api
   ```
4. Não reiniciar o serviço sem necessidade, porque a fila em memória seria perdida.
5. Reprocessar a fila acumulada com retry controlado, assim que o gateway responder.

## Ação via Feature Flag (se aplicável)
Se a integração nova (`FF_PAYMENT_GATEWAY_V2`) foi liberada recentemente, desligar a flag para voltar ao gateway anterior, sem novo deploy:
```bash
# exemplo: flag lida por variável de ambiente do container
sed -i 's/^FF_PAYMENT_GATEWAY_V2=.*/FF_PAYMENT_GATEWAY_V2=false/' .env
docker compose up -d technova-api
```
Confirmar nos logs que as chamadas voltaram ao caminho anterior.

## Verificação
- [ ] ResponseTime voltou para a banda esperada (100-250 ms) e permanece por pelo menos 10 minutos.
- [ ] Error5xx voltou a 0.
- [ ] OrdersCreated voltou ao patamar normal.
- [ ] Circuit breaker em estado CLOSED e fila esvaziada, sem pedidos perdidos.
- [ ] Comunicação de encerramento enviada e postmortem agendado.

## Escalação
- Sem melhora em **10 minutos**: acionar o responsável de plantão da plataforma.
- Sem melhora em **20 minutos**, ou se há perda de pedidos confirmada: acionar o gerente de engenharia e o contato do provedor do gateway.
- Após o incidente, registrar um postmortem sem culpa, com a linha do tempo e as ações de prevenção da Parte 1.