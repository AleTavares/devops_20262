# Aula 12 — Trabalho em Aula

## Objetivo

Consolidar os conceitos de **Rollback Strategies** e **AIOps** através de uma atividade prática guiada: analisar um cenário real de incidente e desenhar um runbook operacional para a TechNova.

**Formato:** Trabalho em duplas (realizado durante os laboratórios) + entrega ao final da aula

---

## Parte 1 — Análise de Cenário de Incidente

Você recebeu o seguinte alerta às 14h de uma quarta-feira:

```
🚨 ALERTA: TechNova-ResponseTime-Anomaly
Métrica: ResponseTime (Average)
Valor atual: 1200ms
Banda esperada para quarta 14h: 100-250ms
Duração: 8 minutos e crescendo

Métricas correlacionadas (últimos 10 min):
- ResponseTime: [150, 180, 350, 600, 800, 1000, 1100, 1200]
- Error5xx: [0, 0, 1, 3, 8, 15, 22, 30]
- OrdersCreated: [42, 40, 35, 25, 18, 10, 5, 2]
- CPU: [35%, 38%, 42%, 55%, 68%, 75%, 82%, 88%]
- MemoryUsage: [60%, 60%, 61%, 61%, 62%, 62%, 63%, 63%]

Logs recentes:
ERROR [14:02:15] Timeout waiting for response from payment-gateway (5000ms)
ERROR [14:03:01] Timeout waiting for response from payment-gateway (5000ms)
ERROR [14:04:22] Circuit breaker OPEN for payment-gateway after 5 failures
WARN  [14:05:00] Fallback: orders queued for retry (queue size: 45)
ERROR [14:06:30] Queue overflow - rejecting new orders
```

**Responda (em um documento markdown):**

1. **Severidade:** Classifique este incidente (P1/P2/P3/P4). Justifique.
2. **Causa raiz provável:** Baseado nas métricas e logs, qual é a causa mais provável?
3. **Evidências:** Liste 3 evidências que suportam sua hipótese.
4. **Ação imediata:** O que você faria AGORA? (rollback, restart, feature flag, etc.)
5. **Rollback necessário?** Sim ou não? Por quê?
6. **Feature flag:** Se a TechNova tivesse uma flag `FF_PAYMENT_GATEWAY_V2=true`, como isso ajudaria?
7. **Prevenção:** O que implementar para evitar este cenário no futuro?

---

## Parte 2 — Desenho de Runbook

Baseado no cenário da Parte 1, escreva um runbook completo seguindo o template:

```markdown
# Runbook: [Nome do Cenário]

## Trigger
[O que ativa este runbook]

## Severidade: [P1/P2/P3/P4]

## Diagnóstico (< 2 min)
1. [Comando para verificar X]
2. [Comando para verificar Y]
3. [Como confirmar a causa raiz]

## Ação Imediata
[Passos exatos para resolver]

## Ação via Feature Flag (se aplicável)
[Como usar flags para mitigar]

## Verificação
- [ ] [Check 1]
- [ ] [Check 2]

## Escalação
[Quem chamar se não resolver em X min]
```

---

## Critérios de Avaliação

| Critério | Peso |
|----------|:----:|
| Identificação correta da causa raiz | 30% |
| Ação imediata adequada (não fazer rollback desnecessário) | 25% |
| Runbook completo com comandos reais | 25% |
| Justificativas baseadas em evidências (métricas/logs) | 20% |

---

## Entrega

### Onde entregar

No fork do repositório da disciplina, na pasta de entrega da aula:

```
entregas/aula-12/SEU-RA/trabalho-em-aula.md
```

### O que entregar

Um arquivo `trabalho-em-aula.md` com as respostas das atividades realizadas em sala:

```markdown
# Trabalho em Aula — Aula 12: Rollback Strategies e AIOps

**Aluno:** [Seu nome completo]
**RA:** [Seu RA]
**Data:** [Data da aula]

## Parte 1 — Análise de Cenário de Incidente

1. Severidade: ...
2. Causa raiz provável: ...
3. Evidências: ...
4. Ação imediata: ...
5. Rollback necessário? ...
6. Feature flag: ...
7. Prevenção: ...

## Parte 2 — Runbook

[Cole aqui o runbook completo seguindo o template]
```

### Como entregar

- O arquivo pode ser adicionado no **mesmo PR** do TF ou em PR separado
- A entrega é **individual** — mesmo que a atividade tenha sido em dupla
- O trabalho em aula vale **1 ponto na nota final** do semestre (contabilizado apenas ao final, com **todos** os trabalhos entregues)
