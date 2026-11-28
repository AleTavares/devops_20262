# Trabalho em Aula — Aula 11: Blue/Green e Canary

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 06/11/2026

## Parte 1 — Escolhendo a Estratégia Certa

| Cenário | Estratégia | Argumento Principal |
|---------|:----------:|-------------------|
| A - API Pedidos | **Canary** | Mudança de alto risco no pagamento com tráfego suficiente para medir: o erro aparece em 5% dos pedidos em vez de 100%, e o rollback é imediato |
| B - Dashboard | **Recreate** | 5 usuários internos, sem SLA e com janela fora do horário comercial: zero downtime não compensa o custo de um ALB e de infra dobrada |
| C - Hotfix | **Blue/Green** | O bug atual já custa 2% dos pedidos por minuto: o fix precisa ir a 100% do tráfego de uma vez, sem perder o rollback instantâneo |

### Cenário A — API de Pedidos: Canary

1. **O risco está no módulo de pagamento, e o raio de impacto importa mais que a velocidade.** No Blue/Green, um bug que escapou dos testes atinge **100%** dos pedidos no momento do switch. No Canary com 5%, atinge cerca de 25 req/min dos 500. O rollback acontece antes de a maioria dos clientes perceber.
2. **Há tráfego suficiente para uma amostra estatística.** Com 500 req/min, 5% são cerca de 250 pedidos em 10 minutos, o que basta para comparar a taxa de erro e a latência do canary com as da versão estável. Com pouco tráfego, o Canary não teria o que medir.
3. **O SLA de 99,9% permite 43,8 min de indisponibilidade por mês.** Um erro de 5 minutos em 100% do tráfego gasta 11% desse orçamento. O mesmo erro em 5% do tráfego gasta cerca de 0,6%.
4. **Não há janela de manutenção**, então o Recreate está fora. Entre as estratégias com zero downtime, o Canary é a única que **testa a versão nova com tráfego real** antes do compromisso total.
5. **Cuidado necessário:** as duas versões processam pagamentos ao mesmo tempo. O formato dos dados e as migrações do banco têm de ser compatíveis com as duas (expand/contract), e a idempotência dos pagamentos precisa estar garantida.

### Cenário B — Dashboard Administrativo: Recreate

- **Custo-benefício:** com 10 req/min e 5 funcionários, alguns segundos fora do ar fora do horário comercial não atingem ninguém. Blue/Green exige ALB e o dobro de instâncias. Canary exige ALB, pesos e métricas, e com 10 req/min 5% seria **meia requisição por minuto**, uma amostra inútil.
- **Risco baixo:** um erro não atinge clientes, e o rollback do Recreate (subir a imagem anterior pela tag imutável) leva menos de 1 minuto. Isso é aceitável para uma ferramenta interna.
- **Simplicidade:** nunca há duas versões rodando ao mesmo tempo, então nenhuma migração precisa ser retrocompatível.
- O deploy fica automatizado na janela noturna, com health check e rollback documentado, como no pipeline da aula 10.

### Cenário C — Hotfix crítico: Blue/Green

- **O custo de esperar é maior que o risco do fix.** A cada minuto, cerca de 10 pedidos perdem dados (2% de 500). Um canary 5%→25%→50%→100% com 10 min por etapa deixaria o bug em produção por mais 30–40 min, o que daria **300–400 pedidos corrompidos** a mais.
- **A confiança no fix é alta:** são 3 linhas e o bug está identificado. O risco que sobra é o do deploy (imagem, configuração, dependência), e o Blue/Green cobre isso: o Green só recebe tráfego depois de passar no health check.
- **O rollback continua instantâneo:** o Blue continua rodando. Se o fix piorar algo, o tráfego volta para ele em segundos, com o mesmo `modify-listener`.
- **Tempos:** cerca de 2 min para o Green ficar healthy e passar no smoke test (incluindo o cenário do bug), depois switch para 100%. Observar 10–15 min com o Blue de prontidão, acompanhando a taxa de erro e a **contagem de pedidos com dados perdidos, que tem de ir a zero**. Só então liberar o Blue.
- **Alternativa aceitável:** um canary relâmpago, com 10% por 2–3 min e depois 100%. Ele só se justifica se o ALB já estiver configurado com pesos. Montar um canary durante o incidente é perder tempo.

## Parte 2 — Planejando o Rollout Canary

Release v2.0: endpoint de cupons, refatoração do frete e Node.js 18→20. A troca de runtime afeta **todas** as rotas, não só as novas, então a primeira etapa é pequena e as métricas são de processo além de HTTP.

| Etapa | % Canary | Duração de monitoramento | Métricas observadas | Threshold de rollback |
|:-----:|:--------:|:------------------------:|--------------------:|:--------------------:|
| 1 | 5% | 15 min (~375 req no canary) | Taxa de 5xx, latência p95/p99, health check dos targets, erros de processo (memória/CPU, crash do container com o Node 20) | 5xx > 1% **ou** p95 > 1,5× o estável **ou** 1 restart do container |
| 2 | 25% | 30 min | As anteriores + pedidos criados/min, erros e uso do endpoint de cupons, divergência do valor de frete em relação ao estável (amostragem) | 5xx > 0,5% **ou** p99 > 2× o estável **ou** divergência de frete > 0,1% dos pedidos **ou** queda de pedidos/min > 5% |
| 3 | 50% | 1 h (inclui um horário de pico) | As anteriores + taxa de conversão do checkout, erros no pagamento, CPU/memória sob carga | Qualquer métrica de negócio > 2% pior que o estável **ou** 5xx > 0,5% |
| 4 | 100% | 24 h com a versão antiga de prontidão (não destruir) | Todas as anteriores + alarmes do CloudWatch e tickets do suporte | 5xx > 0,5% sustentado por 5 min → volta para 100% estável |

Os critérios de promoção são o inverso dos de rollback. Só avança se a etapa inteira passou **dentro** dos limites e com o mínimo de requisições atingido. Sem amostra suficiente, a etapa é estendida, não promovida.

### Perguntas adicionais

1. **Stickiness: sim, por 300 s, com cuidado.** Sem stickiness, o mesmo usuário alterna entre v1 e v2 a cada requisição. Por exemplo, aplica um cupom (endpoint que só existe na v2) e o checkout cai na v1, que não conhece o cupom. Isso gera erros que não são bugs de nenhuma das versões. O preço é que o percentual real por **usuário** deixa de ser exatamente o configurado, porque um cliente pesado pode ficar preso no canary. Por isso a análise compara taxas, não contagens absolutas.
2. **Horário: terça a quinta, por volta das 10h.** É dia útil, com tráfego moderado e o time inteiro disponível para reagir. A etapa 3 deve cruzar um pico de propósito, porque o problema de carga do Node 20 só aparece com volume. Nunca sexta à tarde nem de madrugada: tráfego baixo demais para a amostra e ninguém acordado se der errado.
3. **Quem monitora: os dois.** O **rollback** é automático. O pipeline compara as métricas com os thresholds e volta o peso para 100/0 sem esperar ninguém, porque reverter é barato e seguro. A **promoção** das etapas 1→2 é automática. As etapas 2→3 e 3→4 pedem aprovação humana (environment com reviewer no GitHub Actions), porque envolvem métricas de negócio (frete, conversão) que exigem julgamento.
4. **Rollback com o canary em 50%:** o `modify-listener` vale para **conexões novas**. As requisições que já estão em andamento no canary **terminam nele**, porque o ALB não corta a conexão no meio. Com o *deregistration delay* (30 s no meu Terraform), o ALB espera essas conexões fecharem antes de tirar o target. O risco real está na **lógica de negócio**: um pedido que começou na v2 (com cupom) pode ter o passo seguinte atendido pela v1. Por isso as duas versões precisam ler os dados uma da outra, e o pagamento precisa ser idempotente para um retry não cobrar duas vezes. Os usuários fixados pela stickiness também perdem o cookie de afinidade com o canary e voltam ao estável na próxima requisição.

### Discussão com a Turma

- **"Canary com 1% é útil?"** Sim, quando o tráfego é grande o bastante para 1% ser uma amostra, por exemplo 10 mil req/min dão 100 req/min. Também é útil quando a mudança é de **infraestrutura ou runtime**, como o Node 18→20, que pode derrubar o processo na inicialização ou vazar memória: o objetivo da primeira etapa não é medir negócio, é provar que a versão **sobe e aguenta tráfego real** sem expor quase ninguém. Com 500 req/min, 1% são 5 req/min, e 15 min dão só 75 requisições, o que é pouco para ver 1% de erro com confiança. Por isso escolhi 5%.
- **"Stickiness pode mascarar problemas?"** Pode. Com stickiness, o canary atende sempre os **mesmos** usuários durante a sessão. Se o bug está em um cenário específico (um tipo de cupom, uma região de frete, um navegador), a amostra pode simplesmente não conter esse cenário, e a etapa "passa" sem ter testado nada. Mitigações:
  - durações por etapa longas o bastante para renovar os usuários (TTL de 300 s, etapas de 15–60 min);
  - métricas **segmentadas** por versão e por tipo de operação, não só a média;
  - testes sintéticos que exercitam os cenários críticos diretamente no Target Group do canary.
- **Monitoramento humano vs automático:** o automático é melhor para o que é **objetivo e urgente** (5xx, latência, crash), porque reage em segundos, de madrugada e sem cansaço. O humano é melhor para o que é **contextual**: uma queda de conversão pode ser bug ou pode ser fim de promoção, e só alguém com contexto decide.

### Discussão
- **Stickiness (habilitar? por quê):** sim, por 300 s, para que o mesmo usuário não alterne entre v1 e v2 no meio de um fluxo (cupom aplicado na v2, checkout na v1). O preço é medir com taxas por versão e testes sintéticos, porque a amostra deixa de ser aleatória por requisição.
- **Monitoramento humano vs automático:** o rollback é automático por thresholds objetivos (5xx, latência, crash), porque reverter é barato. A promoção para 50% e para 100% pede aprovação humana, porque depende de métricas de negócio que exigem contexto.
- **Cenário em que eu NÃO automatizaria o rollback:** quando a versão nova executou uma **migração de banco não reversível** ou já gravou dados no formato novo. Voltar o tráfego para a v1 faria ela ler dados que não entende e transformaria um incidente pequeno em corrupção de dados. Também não automatizaria quando o sinal de erro vem de uma **dependência externa** (gateway de pagamento fora do ar, por exemplo): as duas versões falhariam igual, e o rollback automático só esconderia a causa e geraria uma troca de tráfego inútil. Nesses casos o pipeline **para a promoção e alerta**, e uma pessoa decide.
