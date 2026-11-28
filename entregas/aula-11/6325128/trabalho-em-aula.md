# Trabalho em Aula — Aula 11: Blue/Green e Canary

**Aluno:** Felipe Damasceno
**RA:** 6325128
**Data:** 12/11/2026

## Parte 1 — Escolhendo a Estratégia Certa

### Análise dos Cenários

#### Cenário A — API de Pedidos (produção, clientes enterprise)

**Estratégia Recomendada:** Canary Deploy

**Justificativas:**

1. **Risco Alto e SLA Rigoroso:** Com 99.9% de SLA contratual e refatoração do módulo de pagamento, qualquer erro pode gerar perda financeira e quebra de contrato. O Canary permite validação gradual com exposição controlada de risco.

2. **Sem Janela de Manutenção:** Clientes 24/7 exigem zero downtime. O Canary permite rollout progressivo sem interrupção, diferente do Blue/Green que ainda requer um "switch" momentâneo que pode afetar sessões ativas.

3. **Validação em Produção Real:** Com pico de 2000 req/min, o comportamento sob carga real é crítico. Canary permite observar o comportamento em 1-5% do tráfego antes de expor todos os clientes, detectando problemas de performance ou edge cases que testes não capturam.

4. **Rollback Granular:** Em caso de problema, apenas uma pequena parcela dos usuários é afetada, minimizando o impacto financeiro e reputacional.

#### Cenário B — Dashboard Administrativo (interno)

**Estratégia Recomendada:** Blue/Green ou até Recreate

**Justificativas:**

1. **Baixo Impacto:** Com apenas 10 req/min e 5 usuários internos, não há necessidade de estratégia complexa. Um downtime de 30-60 segundos é aceitável.

2. **Custo-Benefício:** Canary exige infraestrutura adicional (balanceamento, monitoramento granular) que não se justifica para uma aplicação de baixo tráfego sem SLA formal.

3. **Janela de Manutenção Disponível:** Fora do horário comercial, é possível fazer deploy tradicional sem pressão. Blue/Green oferece rollback rápido se necessário, mas até Recreate seria aceitável.

4. **Simplicidade Operacional:** Menos complexidade significa menos chance de erro no processo de deploy e manutenção mais simples.

#### Cenário C — Hotfix crítico em produção

**Estratégia Recomendada:** Blue/Green com Canary Acelerado

**Justificativas:**

1. **Urgência Máxima:** Bug causando perda de dados exige ação rápida. Blue/Green permite switch instantâneo se o fix estiver correto, enquanto Canary puro seria lento demais.

2. **Alta Confiança no Fix:** Fix simples de 3 linhas com causa raiz identificada reduz o risco. Canary acelerado (ex: 5% por 5 min → 25% por 10 min → 100%) valida rapidamente sem exposição prolongada.

3. **Rollback Instantâneo:** Blue/Green mantém versão anterior rodando, permitindo rollback em segundos se o fix criar um problema pior.

4. **Abordagem Híbrida:** Ideal seria Blue/Green com smoke test no ambiente Green + Canary de 5-10min em 10% antes do switch completo. Balanceia velocidade com segurança.

**Tempo Sugerido:**
- 5 min em 10% do tráfego (validação inicial)
- Se métricas OK: switch Blue/Green completo
- Monitoramento intensivo por 30 min pós-deploy

### Tabela Resumo

| Cenário | Estratégia | Argumento Principal |
|---------|:----------:|-------------------|
| A - API Pedidos | **Canary** | Alto risco + SLA rigoroso + sem janela de manutenção exigem validação gradual com exposição controlada |
| B - Dashboard | **Blue/Green ou Recreate** | Baixo tráfego e impacto interno não justificam complexidade do Canary; janela de manutenção disponível |
| C - Hotfix | **Blue/Green + Canary Acelerado** | Urgência alta + confiança no fix + necessidade de rollback rápido; validação breve antes do switch completo |

## Parte 2 — Planejando o Rollout Canary

### Plano de Rollout para API de Pedidos v2.0

| Etapa | % Canary | Duração de monitoramento | Métricas observadas | Threshold de rollback |
|:-----:|:--------:|:------------------------:|--------------------:|:--------------------:|
| 1 | **1%** | **30 minutos** | • Error rate (HTTP 5xx)<br>• Latência P95/P99<br>• Taxa de sucesso de pagamentos<br>• Logs de exceção (Node.js) | • Error rate > 0.5%<br>• Latência P99 > 2x baseline<br>• Falha em pagamento > 0.1% |
| 2 | **10%** | **1 hora** | • Todas anteriores +<br>• Uso de CPU/memória<br>• Taxa de cálculo de frete correto<br>• Uso do endpoint de cupons | • Error rate > 0.3%<br>• Latência P95 > 1.5x baseline<br>• CPU > 80% sustentado<br>• Erro em cupons > 1% |
| 3 | **50%** | **2 horas** | • Todas anteriores +<br>• Comportamento sob carga (500-2000 req/min)<br>• Impacto no banco de dados<br>• Testes A/B de conversão | • Error rate > 0.2%<br>• Queries lentas (> 500ms) aumentam > 20%<br>• Queda na taxa de conversão > 5% |
| 4 | **100%** | **24 horas (monitoramento estendido)** | • Todas anteriores +<br>• Métricas de negócio (receita, pedidos)<br>• Feedback de clientes<br>• Estabilidade de longo prazo | • Qualquer anomalia crítica:<br>• Error rate > baseline + 0.1%<br>• Alertas de clientes enterprise<br>• Degradação de performance |

### Respostas às Perguntas Adicionais

#### 1. Stickiness: Devem habilitar?

**Resposta: Sim, com ressalvas**

**Por quê habilitar:**
- **Consistência de experiência:** Clientes enterprise não devem ver comportamento alternado entre requisições (ex: cupom funciona em uma requisição, falha na próxima)
- **Sessões e carrinho:** Evita problemas com sessões distribuídas entre versões diferentes, especialmente na refatoração do cálculo de frete
- **Debugging facilitado:** Se um cliente reportar problema, saber que ele está consistentemente no canary ou no stable facilita investigação

**Ressalvas importantes:**
- **Pode mascarar problemas específicos de usuário/dispositivo:** Se apenas clientes mobile tiverem problemas e eles caírem no stable, o bug passa despercebido
- **Solução:** Combinar stickiness com amostragem estratificada (garantir que cada grupo - mobile/desktop, B2B/B2C - tenha representação no canary)

#### 2. Horário do rollout: Qual o melhor horário?

**Resposta: Terça ou Quarta-feira, às 10h (horário comercial, meio da semana)**

**Justificativa:**
- **Evitar Segunda-feira:** Time pode estar resolvendo problemas do fim de semana; acúmulo de demandas
- **Evitar Sexta-feira:** Se houver problema, pode comprometer o fim de semana do time ou ficar sem resolução até segunda
- **Meio da semana:** Terça/Quarta oferece buffer de dias para resolver problemas antes do fim de semana
- **Horário comercial (10h):** Time completo disponível, já passou o pico de check-in da manhã, ainda há dia inteiro para monitorar e reagir
- **Evitar picos de tráfego:** Não fazer durante horário de almoço (12-14h) ou final do dia (18-20h) quando tráfego está em 2000 req/min

#### 3. Quem monitora: Pipeline automático ou aprovação humana?

**Resposta: Híbrido - Automação com gates de aprovação humana**

**Modelo Proposto:**

| Etapa | Monitoramento | Aprovação | Justificativa |
|:-----:|:-------------:|:---------:|---------------|
| 1% → 10% | Automático | Humana obrigatória | Primeira validação real; SRE deve confirmar que métricas estão saudáveis e Node.js 20 está estável |
| 10% → 50% | Automático | Humana obrigatória | Salto grande (5x o tráfego); Product Owner deve validar que endpoint de cupons está funcionando como esperado |
| 50% → 100% | Automático | Automática com opt-out | Se passou 2h sem issues, probabilidade de sucesso é alta; mas humano pode pausar se necessário |

**Rollback:**
- **Automático sempre:** Se qualquer threshold crítico for atingido, rollback imediato sem esperar aprovação
- **Humano pode forçar:** SRE/DevOps pode fazer rollback manual a qualquer momento via dashboard

#### 4. Rollback em 50%: O que acontece com requests em andamento?

**Resposta: Depende da estratégia de drenagem (graceful shutdown)**

**Cenário Ideal (implementação recomendada):**

1. **Pipeline sinaliza rollback:** Instrução enviada ao load balancer/ingress
2. **Drenagem do canary:**
   - Load balancer para de enviar NOVOS requests para pods canary
   - Requests EM ANDAMENTO no canary continuam até conclusão (timeout: 30 segundos para API de pedidos)
   - Durante a drenagem, 100% do tráfego novo vai para stable
3. **Após drenagem completa:** Pods canary são terminados
4. **Tempo total do rollback:** ~30-60 segundos

**O que acontece na prática com os requests:**

| Tipo de Request | O que acontece |
|-----------------|----------------|
| **Novo request no momento do rollback** | Roteado para stable (versão anterior) |
| **Request em andamento no canary** | Completa normalmente no canary com timeout de 30s |
| **Request de pagamento (transacional)** | Se estiver em processamento, completa; se falhar, sistema de retry tenta no stable |
| **WebSocket/Long-polling** | Conexões são fechadas gracefully; cliente reconecta e cai no stable |

**Proteções Adicionais:**
- **Idempotência:** Endpoints críticos (pagamento, criação de pedido) devem ser idempotentes para tolerar retry
- **Circuit breaker:** Se canary começar a falhar, circuit breaker abre e força requests para stable antes mesmo do rollback formal
- **Monitoramento de requests em andamento:** Antes de derrubar pods canary, aguardar que contador de requests ativos chegue próximo a zero

### Discussão Complementar

#### "Canary com 1% é útil?"

**Sim, extremamente útil em cenários de alto risco**

**Quando faz sentido:**
- **Mudanças estruturais:** Upgrade de runtime (Node 18→20), refatorações grandes, novos algoritmos críticos
- **Detecção de erros raros:** Com 500 req/min, 1% = ~5 req/min = 300 req em 1h. Suficiente para detectar crashes óbvios ou erros de configuração
- **Smoke test em produção:** Valida que a aplicação sobe, responde requests básicos e não tem erro de deployment
- **Custo baixo de falha:** Se der errado, apenas ~5 usuários/min são afetados

**Quando NÃO faz sentido:**
- **Mudanças pequenas/isoladas:** Feature flag nova que nem está ativa ainda
- **Alta urgência:** Hotfix crítico onde cada minuto conta
- **Aplicações de baixíssimo tráfego:** 1% de 10 req/min = 0.1 req/min = nenhuma validação real

#### "Stickiness pode mascarar problemas?"

**Sim, absolutamente**

**Exemplos reais:**

1. **Bug específico de plataforma:**
   - Canary tem bug que só afeta Safari/iOS
   - Se usuários iOS caem majoritariamente no stable por sorte (ou stickiness baseado em cookie que correlaciona com browser), o bug passa despercebido
   - **Mitigação:** Estratificação intencional - garantir % de cada segmento no canary

2. **Problema de estado:**
   - Bug só aparece após 3ª requisição do mesmo usuário
   - Com stickiness, usuário do canary vai sempre no canary e vê o bug
   - Sem stickiness, usuário alterna e pode não atingir a condição do bug
   - **Conclusão:** Neste caso, stickiness AJUDA a detectar o problema

3. **Impacto acumulativo:**
   - Canary tem memory leak lento
   - Com stickiness, mesmos usuários vão sempre no canary e o leak se acumula
   - Sem stickiness, carga distribuída mascara o leak
   - **Mitigação:** Monitorar métricas de servidor (memória, CPU) além de métricas de request

**Resposta:** Stickiness é uma faca de dois gumes. Use com estratificação consciente e monitore tanto métricas de usuário quanto de infraestrutura.

#### "Monitoramento humano vs automático: quando NÃO automatizar rollback?"

**Cenários onde humano deve decidir:**

1. **Falsos positivos conhecidos:**
   - Metric spike esperado (ex: Black Friday, campanhas de marketing)
   - Mudança intencional que piora métrica secundária para melhorar métrica primária (ex: adicionar validação pode aumentar latência levemente mas reduz erros)

2. **Mudanças de negócio:**
   - Nova feature que INTENCIONALMENTE muda comportamento (ex: novo cálculo de frete pode deixar alguns pedidos mais caros)
   - Métricas de conversão podem cair temporariamente por mudança de UI, mas a longo prazo melhora UX

3. **Problemas em infraestrutura, não em código:**
   - Threshold de CPU atingido, mas é problema de scaling, não do código novo
   - Latência alta, mas é porque banco de dados está lento (não relacionado ao deploy)
   - **Humano pode identificar:** "Esse problema existe também no stable, não é do canary"

4. **Situações ambíguas:**
   - Error rate subiu de 0.05% para 0.08% (acima do threshold de 0.2%? Não. Mas é um aumento de 60%!)
   - Humano avalia contexto: é tendência ou spike temporário? Vale continuar observando?

5. **Mudanças irreversíveis:**
   - Migration de dados que já foi aplicada
   - Integração com sistema externo que não pode voltar atrás
   - **Nestes casos:** Rollback do código pode não resolver; humano precisa orquestrar rollback complexo

**Resumo:** Automate rollback para falhas óbvias e críticas. Mantenha humano no loop para decisões ambíguas, contextuais ou que envolvem trade-offs de negócio.