# Trabalho em Aula — Aula 11: Blue/Green e Canary

**Aluno:** Sirlande Martins  
**RA:** 6325269  
**Data:** 12/11/2026

## Parte 1 — Escolhendo a Estratégia Certa

| Cenário | Estratégia | Argumento Principal |
|---------|:----------:|-------------------|
| A - API Pedidos | Canary | Refatoração de pagamento é a mudança de maior risco que existe nessa API, e o canary limita o estrago a uma fração dos pedidos enquanto a versão nova prova que funciona com tráfego real |
| B - Dashboard | Recreate | Sem SLA, 5 usuários internos e janela fora do horário comercial: o downtime de alguns segundos não atinge ninguém e não justifica manter dois ambientes |
| C - Hotfix | Blue/Green | Cada minuto com o bug é pedido perdido, então o fix precisa chegar em 100% de uma vez, mas com o ambiente antigo de pé para voltar em segundos se o fix piorar algo |

No cenário A, o primeiro argumento é que o Blue/Green troca 100% do tráfego de uma vez: se o novo módulo de pagamento tiver um erro que só aparece com dados reais (um cartão de outra bandeira, um cupom antigo), todos os pedidos falham ao mesmo tempo até alguém perceber e voltar. No canary, com 5% do tráfego, o mesmo erro afeta 25 dos 500 pedidos por minuto e o alarme dispara antes de chegar nos outros. O segundo é o SLA de 99.9%, que dá uns 43 minutos de margem por mês; um incidente com 100% do tráfego queima essa margem muito mais rápido que um com 5%. O terceiro é que não existe janela de manutenção, então não dá para fazer a troca num horário sem clientes, e o rollout gradual é o jeito de testar em produção sem expor todo mundo. O canary é mais demorado, mas aqui a velocidade importa menos que a segurança.

No cenário B, o Recreate é suficiente. O Blue/Green ou Canary resolveriam um problema que não existe ali, e custariam infraestrutura extra e um pipeline mais complicado. Se a feature nova de relatórios der problema, o pior caso é o gestor esperar até o dia seguinte ou o time voltar a imagem anterior.

No cenário C, a lógica do canary se inverte. Ele existe para proteger contra uma versão nova pior que a atual, mas aqui a versão atual é que está quebrada, perdendo 2% dos pedidos (cerca de 10 por minuto), e manter 95% do tráfego nela durante as etapas do canary é escolher continuar perdendo pedido. Como o fix tem 3 linhas e a causa já é conhecida, a confiança é alta. Então eu subiria o ambiente green com o fix, rodaria o health check e um smoke test de criação de pedido (1 a 2 minutos), trocaria 100% do tráfego e ficaria observando por uns 10 a 15 minutos, mantendo o blue de pé para voltar em segundos se a taxa de erro subir. Se o time quisesse um meio-termo, seria um canary rápido de 2 ou 3 minutos em 10% só para confirmar que o fix não quebra nada, seguido de 100%, mas não um rollout de horas.

## Parte 2 — Planejando o Rollout Canary

| Etapa | % Canary | Duração de monitoramento | Métricas observadas | Threshold de rollback |
|:-----:|:--------:|:------------------------:|--------------------:|:--------------------:|
| 1 | 1% | 30 min | Erros 5xx, crashes e restarts do container, erros de inicialização do Node 20, logs de exceção | Qualquer crash/restart ou 5xx acima de 1% |
| 2 | 10% | 1 h | 5xx, latência p95 e p99, taxa de sucesso do checkout, uso de cupom | 5xx > 1% ou p95 > 20% acima da versão estável |
| 3 | 50% | 2 h (incluindo um horário de pico) | Tudo acima + valor médio do frete, pedidos concluídos por minuto, CPU e memória | 5xx > 0,5%, frete médio fora de ±5% do estável ou queda de pedidos concluídos |
| 4 | 100% | 24 h (versão antiga parada, mas disponível) | Mesmas métricas comparadas com o dia anterior, mais reclamações no suporte | Qualquer regressão confirmada nas métricas de negócio |

A etapa de 1% existe por causa da atualização do Node.js 18 para 20, que é a mudança que pode quebrar algo independentemente do código (uma dependência nativa que não compila, um comportamento diferente de alguma API). Com 1% isso aparece em minutos e afeta 5 requisições por minuto. A etapa de 10% já dá volume para comparar latência e ver o endpoint de cupons sendo usado de verdade. A de 50% precisa passar por um pico (2000 req/min) e é onde o cálculo de frete fica visível na média: um erro de arredondamento ou de regra muda o valor médio do frete, coisa que nenhum 5xx mostraria. A métrica de negócio é tão importante quanto a técnica nessa release, porque o frete calculado errado devolve 200 OK.

### Discussão
- **Stickiness (habilitar? por quê):** sim, habilitaria. A API de pedidos tem fluxo com várias chamadas (montar o carrinho, aplicar cupom, calcular frete, finalizar), e se o usuário cair no canary numa chamada e na estável na seguinte ele pode ver um frete numa tela e outro no pagamento, ou ter o cupom aceito e depois recusado. Fixar o usuário numa versão por algumas horas evita essa mistura e deixa a comparação entre as versões mais limpa. A preocupação de que a stickiness pode esconder problemas é real, porque os mesmos usuários ficam no canary, e se o bug só aparece para um perfil que caiu todo na versão estável ele passa despercebido. Por isso usaria duração limitada para a stickiness e as etapas de 10% e 50%, em que a amostra de usuários é grande o bastante. Quanto ao horário, começaria num dia útil no meio da manhã, com tráfego moderado e o time inteiro disponível para acompanhar, nunca numa sexta à tarde, e deixaria a etapa de 50% atravessar o horário de pico de propósito.
- **Monitoramento humano vs automático:** o pipeline decide sozinho o rollback, porque reverter é seguro e rápido e um alarme do CloudWatch reage antes de uma pessoa abrir o dashboard. Para avançar, as etapas 1 e 2 podem ser automáticas se as métricas ficarem dentro do limite, mas a passagem para 50% e para 100% eu deixaria com aprovação de alguém do time (um environment com revisor no GitHub Actions), porque é quando as métricas de negócio aparecem e elas precisam de interpretação. Sobre um rollback com 50% do tráfego: o ALB para de mandar requisições novas para o target group do canary, e as que já estão em andamento terminam dentro do *deregistration delay* (connection draining). Um pedido que estava no meio do processamento conclui na versão nova, desde que as duas versões gravem dados compatíveis no banco, que é a maior preocupação ali.
- **Cenário em que eu NÃO automatizaria o rollback:** quando a release tem migração de banco que não é compatível com a versão anterior, como uma coluna removida ou renomeada. Nesse caso voltar o código automaticamente pode deixar a versão antiga rodando sobre um schema que ela não entende, o que transforma um problema em dois. Também não automatizaria quando a métrica é ambígua, como uma queda de pedidos que pode ser o canary ou pode ser só o horário, porque um rollback automático disparado por falso positivo em cada release faz o time perder a confiança no processo. Nesses casos o pipeline deve parar o avanço e chamar uma pessoa, não reverter sozinho.
