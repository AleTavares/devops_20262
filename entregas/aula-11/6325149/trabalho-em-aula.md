# Trabalho em Aula — Aula 11: Blue/Green e Canary

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 12/11/2026

## Parte 1 — Escolhendo a Estratégia Certa

| Cenário | Estratégia | Argumento Principal |
|---------|:----------:|-------------------|
| A - API Pedidos | Canary | Mudança de alto risco no módulo de pagamento, sem janela de manutenção: o Canary limita o raio de impacto a uma fração pequena dos pedidos e permite decidir com métricas reais de produção. |
| B - Dashboard | Recreate | 5 usuários internos, sem SLA e com janela fora do horário comercial: o downtime de segundos é aceitável e o Recreate é a opção mais simples e barata, sem infraestrutura extra. |
| C - Hotfix | Blue/Green | Cada minuto com a versão defeituosa perde dados de pedidos. O Blue/Green troca 100% do tráfego de uma vez e o rollback também é imediato (basta voltar o listener para o Blue). |

### Detalhamento dos argumentos

**Cenário A — API de Pedidos: Canary (3 argumentos)**
1. **Raio de impacto controlado.** Num erro de pagamento "qualquer erro = pedido perdido". Com 1% do tráfego (~5 req/min) o dano potencial é pequeno. No Blue/Green, 100% dos clientes enterprise são expostos de uma só vez.
2. **Validação com tráfego real.** A refatoração do pagamento depende de dados reais (cartões, gateways, casos de borda) que o ambiente de teste e o smoke test do Green não reproduzem. O Canary compara canary × estável nas mesmas condições.
3. **SLA de 99,9% e sem janela.** O orçamento de erro é ~43 min/mês. Um bug que atinja 1% durante 10 min consome muito menos orçamento do que um que atinja 100% durante o tempo de detecção e rollback.
4. **Trade-off assumido:** o rollout é mais lento e exige métricas, alarmes e roteamento ponderado (ALB com Target Groups ponderados). A TechNova tem de ter observabilidade de pagamento antes de fazer isso; o Blue/Green com o Green validado por smoke test é o plano B se não houver métricas confiáveis.

**Cenário B — Dashboard: Recreate**
- Zero downtime não tem valor aqui: não há SLA, o tráfego é de 10 req/min e a janela é fora do horário comercial.
- Blue/Green dobraria o custo de computação e o Canary exigiria métricas e roteamento por percentual, ambos desproporcionais para uma ferramenta interna de baixo risco.
- O Recreate também evita ter duas versões da aplicação (e do schema) rodando juntas.

**Cenário C — Hotfix: Blue/Green**
- O bug está identificado e o fix é de 3 linhas, com alta confiança. Não precisamos "descobrir" se a versão funciona; precisamos corrigir **já**.
- Num Canary de 1% → 10% → 50% → 100% (30–60 min), 98–99% dos pedidos continuariam sendo corrompidos durante o rollout. A urgência pesa mais que a cautela.
- **Tempo em cada etapa:** subir o Green e rodar os testes em ~2–3 min (health check em `/health`, smoke test do fluxo de pedido). Trocar 100% do tráfego e observar ~5–10 min (5xx, criação de pedidos e o erro de perda de dados). Manter o Blue ligado por ~30 min para rollback instantâneo e desligar depois.
- Se a equipe ainda assim preferir cautela, seria um Canary comprimido (10% por 2 min → 100%), mas o Blue/Green é mais simples e rápido.

## Parte 2 — Planejando o Rollout Canary (API de Pedidos v2.0)

A release tem 3 mudanças (endpoint de cupons, refatoração do cálculo de frete, Node 18 → 20), então o plano observa tanto erros funcionais quanto regressão de runtime.

| Etapa | % Canary | Duração de monitoramento | Métricas observadas | Threshold de rollback |
|:-----:|:--------:|:------------------------:|--------------------:|:--------------------:|
| 1 | 1% | 10 min (mínimo de ~50 requisições para ter amostra) | 5xx, health check do Target Group (`UnHealthyHostCount`), logs de boot/erros do Node 20 | qualquer host unhealthy ou taxa de 5xx > 1% |
| 2 | 10% | 20 min | taxa de 5xx, latência p95/p99, pedidos criados/min, erros do cálculo de frete e do endpoint de cupons | 5xx > 0,5%, p95 > 1,5× o baseline ou queda de pedidos criados > 10% vs. estável |
| 3 | 50% | 30 min (incluindo parte do pico) | as mesmas, mais CPU/memória (Node 20), conexões com o banco, pagamentos aprovados × rejeitados | 5xx > 0,1% acima do estável, p95 > 1,3× o baseline ou CPU > 80% sustentada |
| 4 | 100% | 60 min de observação, mantendo o ambiente antigo ligado por 24h | SLO completo: disponibilidade, latência, taxa de pedido concluído, reclamações/suporte | disponibilidade < 99,9% na janela ou qualquer regressão de negócio (pedido perdido) |

**Perguntas adicionais**

1. **Stickiness:** sim, ativar (cookie de sessão do ALB, duração curta de ~1 h). Sem ela, o mesmo cliente alterna entre v1 e v2 no meio do carrinho/checkout, com cálculo de frete e cupons diferentes entre requisições, o que gera erros que não seriam do bug e sim da mistura de versões. Em contrapartida, ela torna a distribuição menos precisa e pode concentrar clientes grandes no canary.
2. **Horário do rollout:** terça a quinta de manhã (~10h), com a equipe presente e fora do pico (e longe de sexta-feira, fim de semana e fechamento de campanhas). Há tráfego suficiente para dar significância estatística ao canary, mas se algo der errado há gente para agir e o impacto é menor que no pico de 2000 req/min.
3. **Quem monitora:** híbrido. O pipeline mede e **faz o rollback automático** se um threshold for ultrapassado, pois é mais rápido que um humano. A **promoção** entre etapas (principalmente 10% → 50% → 100%) exige aprovação humana (GitHub Environment com *required reviewers*), porque a API de Pedidos mexe com pagamento e há métricas de negócio que o pipeline não enxerga.
4. **Rollback com o canary em 50%:** colocamos o peso do Target Group canary em 0% e o estável em 100%. As requisições em andamento não são cortadas: o ALB usa o *deregistration delay* (connection draining) e elas terminam no alvo em que começaram, enquanto novas requisições vão só para o estável. Com stickiness, os clientes presos ao canary passam a ser redirecionados ao estável. O risco real é de estado: pedidos criados pela v2 precisam continuar legíveis pela v1 (daí migrações compatíveis, expand/contract).

### Discussão

- **Stickiness (habilitar? por quê):** sim, para uma experiência consistente em fluxos com estado (carrinho, checkout, cupons); o cuidado é saber que ela distorce a amostra e deve ser desligada ou ter duração curta em fases em que se quer exposição ampla.
- **"Canary com 1% é útil?":** sim, como *smoke test em produção*. Ele pega erros grosseiros (a app não sobe com Node 20, variável faltando, 500 em toda requisição, migração quebrada) com dano mínimo. Não serve para detectar regressões pequenas ou raras, porque 1% de 500 req/min são ~5 req/min e não dá significância estatística. Faz sentido quando o risco é alto e o custo de uma etapa extra é baixo, como no pagamento. Num serviço de tráfego baixo, 1% pode nem receber requisição, então vale começar com 5–10%.
- **"Stickiness pode mascarar problemas?":** pode. Se os usuários fixos no canary forem de um perfil específico (por exemplo, quem passou por um clique antigo ou um dispositivo específico), o bug que só aparece em outros perfis não será visto até uma etapa maior. A mitigação é medir também por segmentos (região, tipo de cliente, endpoint), olhar logs além de médias e não depender só de taxa agregada.
- **Monitoramento humano vs. automático:** o automático é melhor para sinais objetivos e rápidos (5xx, latência, health check). O humano é necessário na promoção e em decisões de negócio.
- **Cenário em que eu NÃO automatizaria o rollback:** quando o rollback pode piorar a situação ou perder dados, por exemplo depois de uma migração de banco não reversível (um `DROP COLUMN`, ou escritas no novo formato que a v1 não lê), ou quando o alarme pode ser um falso positivo causado por dependência externa (o gateway de pagamento fora do ar derrubaria o canary e o estável da mesma forma e o rollback não ajudaria). Nesses casos o rollback automático vira um alerta com decisão humana, guiada por runbook.
