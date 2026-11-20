# Trabalho em Aula — Aula 11: Blue/Green e Canary

**Aluno:** Nicolas de Jesus Silva  
**RA:** 6325171  
**Data:** 19/11/2026

## Parte 1 — Escolhendo a Estratégia Certa

| Cenário | Estratégia | Argumento Principal |
|---------|:----------:|-------------------|
| A - API de Pedidos | Canary | O risco alto exige validação gradual com tráfego real. Uma refatoração crítica no pagamento pode afetar pedidos enterprise, mas o Canary limita o impacto inicial e permite rollback imediato com 100% do tráfego voltando para a versão estável. |
| B - Dashboard Administrativo | Recreate | Como o acesso é interno, o tráfego é baixo e não há janela formal de SLA, o Recreate é suficiente e tem menor complexidade e custo. Fora do horário comercial, o pequeno downtime é aceitável. |
| C - Hotfix crítico | Blue/Green | O ambiente Blue pode continuar intacto, o fix é implantado no Green e validado antes do switch. Como o hotfix já foi identificado e é simples, o switch imediato reduz o MTTR sem expor gradualmente um bug que pode causar perda de dados. |

## Parte 2 — Planejando o Rollout Canary

| Etapa | % Canary | Duração de monitoramento | Métricas observadas | Threshold de rollback |
|:-----:|:--------:|:------------------------:|--------------------:|:--------------------:|
| 1 | 5% | 10 minutos | Error 5xx, latência p99, health dos targets, pedidos criados | 5xx > 2%, p99 > 1,5x o baseline ou target unhealthy |
| 2 | 25% | 15 minutos | 5xx, p99, CPU/memória, erro no cálculo de frete e cupons | 5xx > 3%, p99 > 1,5x o baseline, CPU/memória > 85% |
| 3 | 50% | 20 minutos | 5xx, p99, throughput, taxa de conclusão de pedidos, compatibilidade Node.js | 5xx > 5% ou 2x o baseline, queda de pedidos > 10%, timeout em 1% |
| 4 | 100% | 30 minutos | Todas as métricas anteriores, erros, latência, pedidos criados e saúde do gateway | Qualquer degradação crítica persistente por 5 minutos |

### Discussão

- **Stickiness:** habilitar com duração de 5 a 10 minutos. Isso evita que o mesmo usuário alternasse entre versões diferentes durante uma sessão, mantendo consistência no carrinho, no cálculo de frete e na interface.
- **Horário do rollout:** iniciar em horário de menor pico, mas com equipe de plantão disponível. Como a API atende clientes enterprise 24/7, não é seguro esperar uma janela de manutenção; o melhor é um período com volume representativo e baixa probabilidade de pico, com monitoramento ativo.
- **Monitoramento:** combinar aprovação humana na promoção das etapas com health checks e thresholds automáticos. O pipeline decide rollback em caso objetivo de falha; um humano aprova a promoção entre as primeiras etapas e intervém em métricas ambíguas.
- **Rollback com requests em andamento:** mudar os pesos para 100% estável não encerra requests já em curso. Requests no Canary continuam até terminar ou atingir timeout, mas novos requests passam a ir para a versão estável. Se houver efeitos persistentes no banco ou em gateways externos, a rota afetada deve ser bloqueada por feature flag.
- **Canary com 1%:** é útil quando o volume é muito alto ou a mudança é extremamente arriscada. Mesmo 1% representa usuários reais suficientes para revelar falhas grosseiras, sem quase nenhum impacto econômico.
- **Stickiness e mascaramento:** a stickiness pode impedir que usuários fixados em versões diferentes exercitem cenários distintos. Por isso ela deve ser usada com duração limitada e complementada por testes sintéticos distribuídos.
- **Quando não automatizar o rollback:** não automatizaria totalmente rollback de alterações que afetam migrações de banco, dados financeiros, integrações externas ou ações irreversíveis. Nessas situações, o sistema pode pausar o rollout e exigir aprovação humana.
