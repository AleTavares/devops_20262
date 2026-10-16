# Aula 11 — Trabalho em Aula

## Objetivo

Analisar cenários reais de deploy para decidir entre Blue/Green e Canary, compreender os trade-offs de cada estratégia e planejar a implementação no contexto da TechNova.

**Formato:** Discussão em grupo + apresentação

---

## Parte 1 — Escolhendo a Estratégia Certa

### Contexto

A TechNova cresceu. Agora tem 3 aplicações em produção com perfis diferentes. O CTO Carlos Mendes pediu que o time defina qual estratégia de deploy usar para cada uma. Ele quer zero downtime, mas também quer segurança máxima para mudanças críticas.

### Atividade

Em grupos de 3-4 pessoas, analisem os cenários e decidam:

**Cenário A — API de Pedidos (produção, clientes enterprise)**

| Informação | Valor |
|-----------|-------|
| Tráfego | 500 req/min, pico de 2000 req/min |
| SLA contratual | 99.9% (máximo 8.76h downtime/ano) |
| Tipo de mudança | Refatoração do módulo de pagamento |
| Risco | Alto — qualquer erro = pedido perdido |
| Janela de manutenção | Não existe (clientes 24/7) |

**Pergunta:** Blue/Green ou Canary? Justifiquem com pelo menos 3 argumentos.

**Cenário B — Dashboard Administrativo (interno)**

| Informação | Valor |
|-----------|-------|
| Tráfego | 10 req/min (5 funcionários) |
| SLA | Não há SLA formal |
| Tipo de mudança | Nova feature de relatórios |
| Risco | Baixo — erro não afeta clientes |
| Janela de manutenção | Fora do horário comercial |

**Pergunta:** Blue/Green, Canary ou Recreate? Justifiquem.

**Cenário C — Hotfix crítico em produção**

| Informação | Valor |
|-----------|-------|
| Situação | Bug em produção causando perda de dados em 2% dos pedidos |
| Urgência | Máxima — cada minuto conta |
| Confiança no fix | Alta (bug identificado, fix simples de 3 linhas) |
| Tráfego | 500 req/min |

**Pergunta:** Blue/Green ou Canary? Quanto tempo esperar em cada etapa? Justifiquem.

### Formato de Apresentação

Cada grupo tem 3 minutos para apresentar suas decisões. Usem a tabela:

| Cenário | Estratégia | Argumento Principal |
|---------|:----------:|-------------------|
| A - API Pedidos | ? | ? |
| B - Dashboard | ? | ? |
| C - Hotfix | ? | ? |

---

## Parte 2 — Planejando o Rollout Canary

### Contexto

Marina pediu ao time para definir o **plano de rollout canary** para a próxima release da API de Pedidos (v2.0). A release inclui:
- Novo endpoint de cupons de desconto
- Refatoração do cálculo de frete
- Atualização do Node.js de 18 para 20

### Atividade — Defina o Plano de Rollout

Preencham a tabela com as decisões do grupo:

| Etapa | % Canary | Duração de monitoramento | Métricas observadas | Threshold de rollback |
|:-----:|:--------:|:------------------------:|--------------------:|:--------------------:|
| 1 | ? | ? | ? | ? |
| 2 | ? | ? | ? | ? |
| 3 | ? | ? | ? | ? |
| 4 | ? | ? | ? | ? |

**Perguntas adicionais:**

1. **Stickiness:** devem habilitar stickiness? Por quê?
2. **Horário do rollout:** qual o melhor horário para iniciar o canary? Por quê?
3. **Quem monitora:** o pipeline decide sozinho ou alguém humano aprova cada etapa?
4. **Se o canary estiver com 50% e precisar de rollback, o que acontece com os requests em andamento?**

### Discussão com a Turma

Após os grupos apresentarem, debatam:

1. **"Canary com 1% é útil?"** — Quando faz sentido ter uma primeira etapa tão pequena?
2. **"Stickiness pode mascarar problemas?"** — Se um usuário fica fixo no canary e todos os problemas são de um cenário específico, os outros usuários nunca veriam o bug?
3. **"Monitoramento humano vs automático:"** — Em que situações você NÃO automatizaria o rollback?

---

## Critérios de Avaliação

| Critério | Peso |
|----------|:----:|
| Escolha justificada de estratégia para cada cenário | 30% |
| Argumentos técnicos (não apenas opinião) | 25% |
| Plano de rollout canary completo e realista | 25% |
| Participação na discussão sobre trade-offs | 20% |

---

## Entrega

### Onde entregar

No fork do repositório da disciplina, na pasta de entrega da aula:

```
entregas/aula-11/SEU-RA/trabalho-em-aula.md
```

### O que entregar

Um arquivo `trabalho-em-aula.md` com as respostas das atividades realizadas em sala:

```markdown
# Trabalho em Aula — Aula 11: Blue/Green e Canary

**Aluno:** [Seu nome completo]
**RA:** [Seu RA]
**Data:** [Data da aula]

## Parte 1 — Escolhendo a Estratégia Certa

| Cenário | Estratégia | Argumento Principal |
|---------|:----------:|-------------------|
| A - API Pedidos | | |
| B - Dashboard | | |
| C - Hotfix | | |

## Parte 2 — Planejando o Rollout Canary

| Etapa | % Canary | Duração de monitoramento | Métricas observadas | Threshold de rollback |
|:-----:|:--------:|:------------------------:|--------------------:|:--------------------:|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |

### Discussão
- Stickiness (habilitar? por quê): ...
- Monitoramento humano vs automático: ...
- Cenário em que eu NÃO automatizaria o rollback: ...
```

### Como entregar

- O arquivo pode ser adicionado no **mesmo PR** do TF ou em PR separado
- A entrega é **individual** — mesmo que a atividade tenha sido em grupo
- O trabalho em aula vale **1 ponto na nota final** do semestre (contabilizado apenas ao final, com **todos** os trabalhos entregues)
