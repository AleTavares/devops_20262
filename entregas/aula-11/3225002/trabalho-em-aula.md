# Trabalho em Aula — Aula 11: Blue/Green e Canary

**Aluno:** José Henrique Teixeira Luiz
**RA:** 3225002
**Data:** 13/11/2026

## Parte 1 — Escolhendo a Estratégia Certa

| Cenário | Estratégia | Argumento Principal |
|---------|:----------:|-------------------|
| A - API Pedidos | Canary | Refatoração de pagamento é mudança de alto risco com efeito que só aparece sob tráfego real; o canary limita o estrago a uma fração dos pedidos em vez de expor 100% de uma vez |
| B - Dashboard | Recreate | 10 req/min com janela de manutenção disponível e sem SLA: o downtime de segundos cai fora do horário comercial e não custa nada, enquanto Blue/Green dobraria a infraestrutura para resolver um problema que não existe |
| C - Hotfix | Blue/Green | A confiança no fix é alta e o dano está acontecendo agora: 2% dos pedidos perdendo dados a 500 req/min são 10 pedidos corrompidos por minuto, e cada etapa de canary prolongaria o sangramento |

### Cenário A — três argumentos

1. **O risco é do tipo que só aparece com tráfego real.** A refatoração é do
   módulo de pagamento. Bug de cálculo ou de integração com adquirente não
   aparece em teste sintético — aparece no cartão de bandeira incomum, no
   pedido parcelado, no caso de borda que o ambiente de homologação não tem.
   O canary expõe a versão nova a esse tráfego com uma fração dos usuários.
2. **Sem janela de manutenção, o deploy acontece sob carga.** Os clientes são
   24/7. Tanto Blue/Green quanto canary dão zero downtime, mas o Blue/Green
   troca 100% do tráfego de uma vez: se o bug existir, todos os 500 req/min o
   encontram no mesmo instante.
3. **O SLA de 99.9% é de disponibilidade, e o risco aqui não é indisponibilidade
   — é pedido errado.** Um erro de pagamento devolve HTTP 200 com o valor
   errado; o monitoramento de uptime não acusa nada. Por isso a decisão precisa
   de métrica de negócio (taxa de pagamento recusado, ticket médio) observada
   por etapa, e isso é exatamente o que o rollout gradual permite.

**Ressalva honesta:** canary exige que exista métrica confiável por versão. Se
o time não consegue separar erro da v1 do erro da v2 no dashboard, o canary
vira Blue/Green lento — com o risco de ninguém perceber o problema a tempo.
Nesse caso, o passo anterior ao deploy é instrumentar, não escolher estratégia.

### Cenário B — por que Recreate, e não Blue/Green

Blue/Green e canary resolvem downtime e risco de exposição. Aqui não há
nenhum dos dois: existe janela de manutenção, não há SLA, e o erro não chega
ao cliente. Manter dois ambientes idênticos no ar custa o dobro de infra
permanentemente para evitar segundos de indisponibilidade de cinco
funcionários fora do horário comercial.

A escolha mudaria se o dashboard virasse ferramenta de plantão — alguém
precisando dele às 3h da manhã durante um incidente. Aí o downtime deixa de
ser inofensivo.

### Cenário C — Blue/Green, com tempos

| Momento | Ação | Tempo |
|---|---|---|
| T+0 | Sobe o Green com o fix de 3 linhas | — |
| T+0 a T+3min | Smoke test no Green pelo DNS interno, sem tráfego de produção | ~3 min |
| T+3min | Traffic switch de 100% para o Green | instantâneo |
| T+3 a T+15min | Blue fica de pé, em standby, pronto para rollback | 12 min |
| T+15min | Se as métricas estão estáveis, encerra o Blue | — |

Por que não canary: a cada minuto de rollout gradual, 2% dos pedidos continuam
perdendo dados na versão que **ainda** está servindo a maioria. Um canary de
4 etapas com 10 minutos cada deixaria o bug ativo por 40 minutos — cerca de
400 pedidos corrompidos. O canary protege contra fix duvidoso; aqui o fix é
conhecido e pequeno, e o inimigo é o relógio.

**O que eu não abriria mão mesmo com urgência:** os 3 minutos de smoke test no
Green antes do switch. Fix de 3 linhas aplicado às pressas no arquivo errado é
um clássico, e trocar um bug de perda de dados por uma indisponibilidade total
é piorar.

## Parte 2 — Planejando o Rollout Canary

Release v2.0 da API de Pedidos: novo endpoint de cupons, refatoração do cálculo
de frete e upgrade do Node.js 18 → 20.

| Etapa | % Canary | Duração de monitoramento | Métricas observadas | Threshold de rollback |
|:-----:|:--------:|:------------------------:|--------------------:|:--------------------:|
| 1 | 5% | 30 min | Taxa de erro 5xx, latência p95, erros de boot/módulo nativo do Node 20 | 5xx > 1% ou p95 > 2× a linha de base |
| 2 | 25% | 1 h | As acima + valor médio de frete calculado, taxa de uso do endpoint de cupons | 5xx > 1%, p95 > 1,5× base, ou desvio > 5% no frete médio |
| 3 | 50% | 2 h | As acima + taxa de conversão do checkout e volume de pedidos/min | 5xx > 0,5%, ou queda > 3% na conversão |
| 4 | 100% | 24 h (Blue em standby) | Todas, mais reclamações no suporte | Qualquer uma das acima mantém o Blue de pé para rollback |

**Por que as etapas encurtam o threshold conforme sobem.** Com 5% do tráfego, a
amostra é pequena e o ruído é grande — um threshold apertado dispararia
rollback por acaso estatístico. Com 50%, a amostra é grande e qualquer desvio
já é sinal real, então o threshold fecha.

**Por que a etapa 2 ganha métrica de negócio.** O upgrade do Node 20 e o erro
de módulo nativo aparecem na etapa 1, em 5xx. Mas o bug do cálculo de frete
não gera erro nenhum: ele devolve 200 com o valor errado. A única forma de
vê-lo é comparar o frete médio da v2 com o da v1 no mesmo recorte — e isso
exige volume, que só existe a partir de 25%.

### Discussão

- **Stickiness (habilitar? por quê):** Sim, habilitar. Sem stickiness, o mesmo
  usuário alterna entre v1 e v2 durante um fluxo de checkout de várias
  requisições: calcula o frete na v2, aplica o cupom na v1 e fecha o pedido na
  v2, com estados que não conversam. O sintoma seria um erro intermitente que
  nenhuma das duas versões reproduz sozinha. O preço do stickiness é o que a
  própria pergunta da discussão aponta: se o bug afeta só um perfil de usuário
  e esse perfil ficou fixo na v1, ele passa invisível pelo rollout inteiro e
  estoura em 100%. É um trade-off real — eu habilito e compenso garantindo que
  a seleção do canary seja aleatória por usuário, não por região ou por
  qualquer atributo correlacionado com o comportamento.

- **Horário do rollout:** Começar no início da manhã de um dia útil, com
  tráfego subindo mas ainda longe do pico. Nunca na sexta à tarde nem de
  madrugada. O motivo não é o tráfego em si: é que quem escreveu o código
  precisa estar acordado e disponível quando o canary estiver em 25%.
  Madrugada tem tráfego baixo demais para a métrica significar alguma coisa.

- **Monitoramento humano vs automático:** Rollback automático nas etapas 1 a 3,
  para as métricas técnicas (5xx e latência) — são objetivas, rápidas e o
  tempo de reação humano é pior que o do pipeline. A **promoção** de uma etapa
  para a seguinte, porém, exige aprovação humana. Automatizar os dois lados
  significa que o pipeline pode levar a release a 100% às 2h da manhã sem
  ninguém olhando as métricas de negócio.

- **Cenário em que eu NÃO automatizaria o rollback:** Quando a release envolve
  **migração de schema que já escreveu dados no formato novo**. O rollback
  automático devolve o tráfego para a v1, que não sabe ler o que a v2 gravou —
  e o resultado é pior que o bug original, porque agora há dados órfãos. Nesse
  caso o pipeline deve alertar e parar o rollout, e a decisão de voltar é
  humana, acompanhada do plano de reversão dos dados. O mesmo vale quando a
  métrica de erro é ruidosa por natureza, como taxa de recusa de cartão, que
  oscila sozinha por motivo do adquirente.

- **"Canary com 1% é útil?":** Sim, em dois casos. Quando o volume é grande o
  bastante para 1% ainda dar significância estatística (uma API com 100 mil
  req/min tem mil requisições por minuto no canary — amostra de sobra). E
  quando o custo de um único erro é altíssimo — pagamento, saúde, dado
  regulado. Com 500 req/min, porém, 1% são 5 requisições por minuto: não dá
  para concluir nada, e a etapa só atrasa o rollout dando falsa sensação de
  segurança.

- **Rollback com o canary em 50% — o que acontece com os requests em
  andamento:** O ALB para de **encaminhar novas** requisições ao target group
  da v2, mas as que já estão em voo continuam sendo processadas por ela até
  responder. Se o target da v2 for terminado na hora, essas conexões são
  cortadas e o usuário recebe erro de rede. É o que o *deregistration delay*
  do target group resolve: ele mantém o alvo drenando por um tempo (padrão
  300s) antes de removê-lo. O valor precisa ser maior que a requisição mais
  longa da API — e requisição que escreve no banco merece atenção redobrada,
  porque cortar no meio é o caminho para transação pela metade.
