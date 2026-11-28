# Trabalho em Aula — Aula 11: Blue/Green e Canary

**Aluno:** Emilly Santos de Oliveira
**RA:** 4023575
**Data:** 19/11/2026

---

## Parte 1 — Escolhendo a Estratégia Certa

| Cenário | Estratégia | Argumento Principal |
|---------|:----------:|-------------------|
| A - API Pedidos | **Blue/Green** | Permite rollback instantâneo (troca de roteamento no ALB) sem nenhum downtime, o que é essencial para o SLA de 99,9% com clientes enterprise pagando por pedidos em tempo real |
| B - Dashboard | **Recreate** | Ferramenta interna com apenas 5 usuários, sem SLA formal e com janela de manutenção disponível fora do horário comercial — o custo de manter dois ambientes paralelos não se justifica |
| C - Hotfix | **Blue/Green** | Alta confiança no fix e urgência máxima exigem switch imediato: sobe o ambiente Green com o fix, valida em segundos e troca o tráfego de uma vez, eliminando a janela de exposição que um Canary gradual exigiria |

### Justificativas detalhadas

**Cenário A — API de Pedidos (Blue/Green):**
1. O risco de qualquer erro resultar em pedido perdido exige que o rollback seja instantâneo — com Blue/Green basta redirecionar o ALB de volta ao ambiente Blue sem precisar fazer rollout reverso de containers.
2. Sem janela de manutenção e com pico de 2000 req/min, um Canary exporia uma parcela real de clientes ao risco da refatoração de pagamento durante horas; Blue/Green isola 100% do tráfego no ambiente testado antes de qualquer usuário ser afetado.
3. O ambiente Blue permanece ativo como hot-standby durante todo o switch, garantindo que o SLA de 99,9% não seja violado mesmo que o Green apresente problema logo após a troca.

**Cenário B — Dashboard Administrativo (Recreate):**
1. Cinco usuários internos em horário comercial não justificam o custo operacional de manter dois ambientes simultâneos.
2. O risco é baixo — um erro não afeta clientes externos, e a equipe pode ser avisada com antecedência sobre a indisponibilidade.
3. A janela de manutenção fora do horário comercial é suficiente para fazer o deploy simples, testar e corrigir se necessário.

**Cenário C — Hotfix crítico (Blue/Green):**
1. Com confiança alta no fix (3 linhas, bug identificado), não faz sentido expor o problema a mais usuários durante uma progressão Canary lenta — cada minuto a mais representa 2% de pedidos com perda de dados.
2. Blue/Green permite validar o Green com testes de smoke em 1-2 minutos e trocar 100% do tráfego imediatamente.
3. O ambiente Blue continua disponível para rollback imediato caso o fix introduza regressão inesperada.

**Tempo de espera no Blue/Green para o hotfix:**
- Subida do ambiente Green + testes de smoke: **~2 minutos**
- Switch de tráfego no ALB: **imediato (< 30 segundos)**
- Monitoramento pós-switch com Blue de prontidão: **10-15 minutos**
- Depois dos 15 minutos estável → Blue pode ser descomissionado

---

## Parte 2 — Planejando o Rollout Canary

Contexto: release v2.0 da API de Pedidos (novo endpoint de cupons, refatoração de frete, Node.js 18→20).

| Etapa | % Canary | Duração de monitoramento | Métricas observadas | Threshold de rollback |
|:-----:|:--------:|:------------------------:|:-------------------:|:--------------------:|
| 1 | 5% | 15 min | Error rate, latência p99, logs de erro | Error rate > 0,5% ou latência p99 > 2× baseline |
| 2 | 20% | 20 min | Error rate, latência p99, taxa de sucesso de cupons, cálculo de frete | Error rate > 0,5% ou qualquer anomalia no cálculo de frete |
| 3 | 50% | 30 min | Todas as anteriores + uso de memória/CPU (Node 20), taxa de conversão de pedidos | Error rate > 0,3% ou degradação de CPU/memória > 20% acima do baseline |
| 4 | 100% | 30 min | Todas as anteriores + métricas de negócio (pedidos/min, ticket médio) | Qualquer desvio > 2σ das métricas de negócio |

### Raciocínio das etapas

- **Etapa 1 (5%):** expõe o mínimo de tráfego real para validar que a mudança de runtime (Node 18→20) não quebra nada catastroficamente. Com 500 req/min, 5% = 25 req/min — suficiente para detectar erros sistemáticos rapidamente.
- **Etapa 2 (20%):** aumenta a amostragem para validar os novos endpoints (cupons e frete) com volume representativo. 100 req/min já permite identificar edge cases de lógica de negócio.
- **Etapa 3 (50%):** split igual entre versões. Neste ponto a confiança já é alta; o monitoramento foca em comportamento de longo prazo e estabilidade de memória do Node 20.
- **Etapa 4 (100%):** conclusão do rollout com monitoramento estendido para garantir que não há degradação de métricas de negócio após a migração total.

---

### Discussão

**Stickiness (habilitar? por quê):**
Sim, deve-se habilitar stickiness por sessão para os endpoints de pedidos e cupons. Um usuário que inicia um fluxo de checkout na versão Stable e é redirecionado para o Canary no meio da transação pode ter inconsistências de estado (especialmente após a refatoração do cálculo de frete). A stickiness garante que o usuário permaneça na mesma versão durante toda a sessão, evitando erros de estado inconsistente e facilitando a rastreabilidade de bugs — se um erro ocorrer, é possível confirmar que o usuário estava no Canary. A contrapartida é que a distribuição de tráfego não é perfeitamente proporcional, mas para a TechNova a consistência de experiência pesa mais que a uniformidade estatística exata.

**Horário do rollout:**
O melhor horário para iniciar o Canary é durante o **horário de menor tráfego**, tipicamente entre 02h e 06h, quando a API opera abaixo de 10% do pico. Isso reduz o impacto absoluto de qualquer problema (ex.: 5% de 100 req/min = 5 req/min afetados, vs. 5% de 2000 req/min = 100 req/min no pico). Além disso, a equipe precisa estar disponível para monitorar e eventualmente acionar rollback — portanto, iniciar às 02h permite que as etapas 1 e 2 completem antes do horário comercial, quando há mais engenheiros disponíveis para decidir sobre a continuidade.

**Monitoramento humano vs automático:**
Para as etapas 1 e 2 (5% e 20%), o rollback automático deve ser ativado — os thresholds são claros (error rate, latência) e a velocidade de reação é mais importante que julgamento humano. Para a etapa 3 (50%) e especialmente a etapa 4 (100%), uma aprovação humana antes de avançar é recomendada, porque nessas etapas as métricas de negócio (conversão, ticket médio) exigem interpretação contextual que um threshold fixo pode não capturar adequadamente.

**Cenário em que eu NÃO automatizaria o rollback:**
Não automatizaria o rollback quando a mudança envolve **migrações de schema de banco de dados** que já foram executadas. Se o Canary está em 50% e o rollback automático é acionado, a aplicação Stable pode ser incompatível com o schema novo, gerando erros piores do que o problema original. Nesse caso, o rollback requer análise humana para decidir entre: reverter o schema (caro e arriscado), manter o Canary e corrigir o bug, ou aceitar incompatibilidade temporária com tratamento manual. Outro cenário: quando o "problema" detectado pelo threshold é na verdade um **falso positivo** gerado por spike de tráfego externo — rollback automático causaria interrupção desnecessária.

**Discussão — perguntas da turma:**

**"Canary com 1% é útil?"**
Sim, especialmente quando: (a) a base de usuários é muito grande e 1% ainda representa volume estatisticamente significativo; (b) a mudança envolve risco extremo como modificações em autenticação ou dados sensíveis; (c) o objetivo é detectar erros de infraestrutura (memory leaks, conexões de banco) que se manifestam com qualquer carga. Para a TechNova com 500 req/min, 1% = 5 req/min, o que pode ser pouco para validar a lógica de cupons — mas é suficiente para detectar crash na inicialização do Node 20.

**"Stickiness pode mascarar problemas?"**
Sim. Se um bug afeta apenas usuários que fazem pedidos com endereços de um estado específico (edge case geográfico no cálculo de frete), e esses usuários estão todos fixos no ambiente Stable por stickiness, o Canary jamais exercitará esse caminho de código. A mitigação é combinar stickiness com testes sintéticos automatizados que exercitem casos específicos de negócio no Canary, independente de quais usuários reais estão sendo roteados.

**"Monitoramento humano vs automático — quando NÃO automatizar o rollback?"**
Além do caso de migrações de schema, também não automatizaria em situações onde a decisão de rollback tem impacto contratual ou regulatório — por exemplo, se o deploy é uma atualização de conformidade com LGPD que precisa estar em produção até uma data-limite. Nesse caso, reverter automaticamente por um erro de performance marginal seria trocar um problema técnico por um problema legal.
