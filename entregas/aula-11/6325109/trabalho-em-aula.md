# Trabalho em Aula — Aula 11: Blue/Green e Canary

**Aluno:** Carina Gonçalves dos Santos Dalpino
**RA:** 6325109
**Data:** 12/11/2026

## Parte 1 — Escolhendo a Estratégia Certa

| Cenário | Estratégia | Argumento Principal |
|---------|:----------:|-------------------|
| A - API Pedidos | Canary | Mudança de alto risco no módulo de pagamento, sem janela de manutenção e com SLA de 99,9%. O canary limita o impacto de um erro a poucos usuários e mede erro real em produção antes de expandir. |
| B - Dashboard | Recreate | Baixo risco, 5 usuários internos, sem SLA e com janela fora do horário comercial. Um downtime curto é aceitável e o Recreate é o mais simples e barato, sem ALB nem ambiente duplicado. |
| C - Hotfix | Blue/Green | Urgência máxima e confiança alta no fix de 3 linhas. O Blue/Green troca 100% do tráfego de uma vez, encerra a perda de dados em segundos e mantém o Blue intacto para rollback imediato. |

### Justificativas

**Cenário A: API de Pedidos (Canary)**
1. O risco está na lógica de negócio (pagamento). Testes antes da produção não cobrem todos os casos reais, e um erro significa pedido perdido. Expor 5% do tráfego primeiro reduz o raio de impacto.
2. Sem janela de manutenção e com SLA de 99,9% (cerca de 8,76 h de downtime por ano), o orçamento de erro é pequeno. Um erro em 100% do tráfego, como pode ocorrer no Blue/Green, gasta esse orçamento muito mais rápido.
3. Com 500 req/min, 5% dá cerca de 25 req/min, volume suficiente para medir taxa de erro e latência em poucos minutos.

**Cenário B: Dashboard (Recreate)**
1. Com 10 req/min e 5 usuários, um rollout gradual não gera amostra útil.
2. Sem SLA e com janela fora do horário comercial, alguns segundos de downtime não têm custo real.
3. Blue/Green e Canary exigem infraestrutura duplicada, o que não se justifica para um sistema interno de baixo risco.

**Cenário C: Hotfix (Blue/Green)**
1. O bug perde dados em 2% dos pedidos, então cada minuto tem custo. O tempo de correção pesa mais do que a cautela gradual.
2. A confiança no fix é alta e a mudança é pequena. Um canary lento com várias etapas manteria o bug em parte do tráfego por mais tempo.
3. O rollback continua instantâneo: basta apontar o listener de volta para o Blue.
4. Tempo de espera: deploy no Green, health check (cerca de 30 s), troca de tráfego e 5 minutos observando a taxa de erro. Se fosse canary, 1 a 2 minutos por etapa (10% → 50% → 100%).

## Parte 2 — Planejando o Rollout Canary

Release v2.0 da API de Pedidos: endpoint de cupons, refatoração do cálculo de frete e Node.js 18 → 20.

| Etapa | % Canary | Duração de monitoramento | Métricas observadas | Threshold de rollback |
|:-----:|:--------:|:------------------------:|--------------------:|:--------------------:|
| 1 | 5% | 15 min | Health check, taxa de 5xx, erros de startup (Node 20) | 5xx > 1% ou target unhealthy |
| 2 | 25% | 30 min | 5xx, latência p95/p99, erros no frete e nos cupons | 5xx > 1% ou p95 > 1,5x o baseline |
| 3 | 50% | 30 min | Mesmas métricas, CPU/memória e taxa de pedidos concluídos | 5xx > 0,5%, p95 > 1,5x o baseline ou queda de pedidos concluídos > 5% |
| 4 | 100% | 60 min (após a promoção) | Todas as anteriores e alarmes de negócio | Qualquer threshold anterior. Rollback para a versão estável mantida no ar |

### Perguntas adicionais

1. **Stickiness:** habilitar, com 300 s. O usuário não alterna entre v1 e v2 no meio de um fluxo de pedido ou pagamento, o que evita comportamento inconsistente, como frete calculado de um jeito e cobrado de outro.
2. **Horário do rollout:** de terça a quinta, de manhã ou no início da tarde, com o time disponível e tráfego moderado. Evitar sexta, madrugada e picos de 2000 req/min. Há volume suficiente para medir e gente para agir se der problema.
3. **Quem monitora:** o pipeline coleta as métricas e faz o rollback por threshold. A promoção para 50% e 100% exige aprovação humana, porque envolve pagamento e o impacto de um erro é alto.
4. **Rollback com 50% e requests em andamento:** ao voltar os pesos para 100/0, o ALB para de enviar novos requests ao Target Group canary. Os requests em andamento terminam normalmente (deregistration delay), então não são cortados. Com stickiness, os usuários presos ao canary voltam ao stable na próxima requisição. Transações de pagamento incompletas precisam ser idempotentes.

### Discussão

- **Stickiness (habilitar? por quê):** sim, para manter a consistência da sessão e dos fluxos de pedido e pagamento. O custo é que a distribuição por usuário fica enviesada e os pesos do ALB deixam de refletir a proporção exata de usuários.
- **Monitoramento humano vs automático:** o automático cobre sinais objetivos e rápidos (5xx, health check, latência) e reage em segundos. O humano decide a promoção quando há risco de negócio ou sinais ambíguos.
- **Cenário em que eu NÃO automatizaria o rollback:** mudanças com migração de banco ou efeito irreversível nos dados, porque reverter o código não desfaz o dado gravado. Também quando o sinal vem de uma métrica de negócio ambígua ou quando a queda pode ter causa externa, como um provedor de pagamento fora do ar.
- **"Canary com 1% é útil?":** sim, quando o volume é alto o bastante para gerar amostra e a mudança é arriscada. Com 500 req/min, 1% são só 5 req/min, quase sem sinal. Serve como teste de fumaça (a versão sobe e atende?), não como validação estatística.
- **"Stickiness pode mascarar problemas?":** pode. Se os usuários presos ao canary não usam o fluxo com defeito, a métrica agregada parece saudável. Convém olhar as métricas por Target Group e garantir que os fluxos críticos sejam exercitados.