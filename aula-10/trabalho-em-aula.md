# Aula 10 — Trabalho em Aula

## Objetivo

Discutir os benefícios e riscos do GitOps para infraestrutura e debater estratégias de deploy para diferentes cenários, aplicando ao contexto da TechNova.

**Formato:** Discussão em grupo + apresentação

---

## Parte 1 — GitOps: Confiança no Pipeline

### Contexto

A TechNova vai adotar GitOps para Terraform. O CTO Carlos Mendes está animado, mas tem preocupações:

> "Se o pipeline roda apply automaticamente no merge, e alguém mergeia algo errado, a infraestrutura quebra. Como nos protegemos?"

### Atividade

Em grupos de 3-4 pessoas, debatam e respondam:

**1. Quais proteções devem existir ANTES do merge?**

Listem pelo menos 5 proteções que evitam que um PR problemático seja mergeado:

| # | Proteção | Como implementar |
|:-:|----------|-----------------|
| 1 | Exemplo: Branch protection | Settings → Branches → Require PR + approvals |
| 2 | | |
| 3 | | |
| 4 | | |
| 5 | | |

**2. E se o apply falhar DEPOIS do merge? O que acontece?**

Discutam:
- O state do Terraform fica inconsistente?
- Como fazer rollback de infraestrutura?
- O git revert resolve? Por quê ou por quê não?

**3. Cenário: Alguém fez merge acidentalmente e o apply destruiu o banco de dados RDS. Como prevenir?**

Proponham pelo menos 2 soluções técnicas.

### Apresentação

Cada grupo apresenta suas proteções em 2 minutos. Turma debate: qual proteção é a mais importante?

---

## Parte 2 — Escolhendo a Estratégia de Deploy

### Contexto

A TechNova tem três aplicações com requisitos diferentes. O time precisa escolher a estratégia de deploy adequada para cada uma.

### Atividade — Análise de Cenários

Para cada aplicação abaixo, escolham a estratégia de deploy mais adequada e justifiquem:

**Estratégias disponíveis:**
- **Recreate:** para tudo, sobe novo (downtime)
- **Blue-Green:** mantém duas versões, redireciona tráfego
- **Canary:** deploy gradual para % dos usuários
- **Rolling:** atualiza instâncias uma por vez

| Aplicação | Descrição | Estratégia escolhida | Justificativa |
|-----------|-----------|:--------------------:|---------------|
| **Admin Dashboard** | Painel interno usado por 5 funcionários, horário comercial | ? | ? |
| **API de Pedidos** | API pública com 500 req/min, SLA 99.9% | ? | ? |
| **Job de Relatórios** | Roda 1x por dia às 3h da manhã, processa dados | ? | ? |

**Perguntas adicionais para discussão:**

1. **Qual é o custo de cada estratégia?** (infraestrutura extra necessária)
2. **A TechNova hoje (startup, 1 servidor) pode usar Blue-Green?** O que precisaria mudar?
3. **Quando Recreate é MELHOR que Blue-Green?** (sim, há cenários!)

### Discussão Guiada

Após o debate em grupos, discutam como turma:

1. **"Downtime de 5 segundos é aceitável?"** — Depende para quem?
2. **"Zero downtime custa quanto a mais?"** — Infraestrutura dobrada (Blue-Green) ou load balancer
3. **"O que a TechNova deve fazer AGORA vs o que deve planejar para 6 meses?"**

---

## Critérios de Avaliação

| Critério | Peso |
|----------|:----:|
| Lista de proteções GitOps com implementação técnica | 25% |
| Análise do cenário de falha pós-merge | 25% |
| Escolha justificada de estratégia para cada aplicação | 30% |
| Participação na discussão sobre custos e trade-offs | 20% |

---

## Entrega

### Onde entregar

No fork do repositório da disciplina, na pasta de entrega da aula:

```
entregas/aula-10/SEU-RA/trabalho-em-aula.md
```

### O que entregar

Um arquivo `trabalho-em-aula.md` com as respostas das atividades realizadas em sala:

```markdown
# Trabalho em Aula — Aula 10: GitOps e Estratégias de Deploy

**Aluno:** [Seu nome completo]
**RA:** [Seu RA]
**Data:** [Data da aula]

## Parte 1 — Proteções GitOps

| # | Proteção | Como implementar |
|:-:|----------|-----------------|
| 1 | | |
| ... | | |
| 5 | | |

- O que acontece se o apply falhar depois do merge: ...
- Como prevenir destroy acidental do RDS (2 soluções): ...

## Parte 2 — Estratégia de Deploy por Aplicação

| Aplicação | Estratégia escolhida | Justificativa |
|-----------|:--------------------:|---------------|
| Admin Dashboard | | |
| API de Pedidos | | |
| Job de Relatórios | | |

### Discussão
- Downtime aceitável (para quem?): ...
- Custo de zero downtime: ...
- O que a TechNova deve fazer agora vs planejar para 6 meses: ...
```

### Como entregar

- O arquivo pode ser adicionado no **mesmo PR** do TF ou em PR separado
- A entrega é **individual** — mesmo que a atividade tenha sido em grupo
- O trabalho em aula vale **1 ponto na nota final** do semestre (contabilizado apenas ao final, com **todos** os trabalhos entregues)
