# Aula 09 — Trabalho em Aula

## Objetivo

Discutir estratégias de tagging de imagens Docker e explorar o potencial de IA para code review automatizado, aplicando ao contexto da TechNova.

**Duração:** ~30 minutos
**Formato:** Discussão em grupo + apresentação

---

## Parte 1 — Estratégia de Tagging para a TechNova (15 min)

### Contexto

A TechNova precisa definir sua estratégia oficial de tagging de imagens Docker. O CTO Carlos Mendes quer uma política clara que o time todo siga.

### Atividade

Em grupos de 3-4 pessoas, debatam e definam:

**1. Qual estratégia de tagging a TechNova deve adotar?**

Considerem os cenários:
- A equipe faz 5-10 commits por dia na branch `main`
- Releases oficiais acontecem a cada 2 semanas
- Produção precisa de rollback rápido em caso de problema
- Time de QA precisa testar versões específicas antes do release

**2. Para cada tipo de evento, qual tag usar?**

| Evento | Tag sugerida | Justificativa |
|--------|-------------|---------------|
| Push para `main` | ? | ? |
| Push para `develop` | ? | ? |
| Git tag `v1.2.3` | ? | ? |
| Pull Request | ? | ? |

**3. Quais tags NUNCA devem ir para produção? Por quê?**

### Apresentação

Cada grupo apresenta sua estratégia em 2 minutos. Turma debate prós e contras de cada abordagem.

---

## Parte 2 — O que IA Deve Revisar em um PR? (15 min)

### Contexto

O CTO decidiu implementar AI review em todos os PRs da TechNova. Mas antes de configurar, precisa definir: **o que exatamente a IA deve verificar?**

### Atividade — Brainstorm

Em grupos, criem uma lista de **10 itens** que a IA deve verificar em cada PR. Classifiquem cada item:

| # | O que verificar | Severidade | Humano também revisa? |
|:-:|----------------|:----------:|:--------------------:|
| 1 | Exemplo: secrets hardcoded | CRITICAL | Sim |
| 2 | | | |
| 3 | | | |
| ... | | | |
| 10 | | | |

**Categorias para inspiração:**
- Segurança (secrets, injection, permissões)
- Performance (loops infinitos, queries N+1, memória)
- Qualidade (code smells, complexidade, duplicação)
- Padrões (naming conventions, estrutura de arquivos)
- Documentação (comentários, JSDoc, README)

### Discussão Guiada

Após o brainstorm, discutam como turma:

1. **Quais itens a IA é MELHOR que humanos para verificar?**
   (Hint: padrões repetitivos, checklists extensos, busca em texto)

2. **Quais itens APENAS humanos conseguem revisar bem?**
   (Hint: lógica de negócio, decisões de arquitetura, UX)

3. **Em qual cenário vocês NÃO confiariam na IA?**
   (Hint: falsos positivos, código com contexto complexo)

---

## Critérios de Avaliação

| Critério | Peso |
|----------|:----:|
| Participação ativa na discussão de tagging | 30% |
| Justificativa técnica para escolhas de tag | 20% |
| Lista de 10 itens para AI review com classificação | 30% |
| Argumentação sobre limitações da IA | 20% |

---

## Entrega

### Onde entregar

No fork do repositório da disciplina, na pasta de entrega da aula:

```
entregas/aula-09/SEU-RA/trabalho-em-aula.md
```

### O que entregar

Um arquivo `trabalho-em-aula.md` com as respostas das atividades realizadas em sala:

```markdown
# Trabalho em Aula — Aula 09: Tagging e AI Review

**Aluno:** [Seu nome completo]
**RA:** [Seu RA]
**Data:** [Data da aula]

## Parte 1 — Estratégia de Tagging

| Evento | Tag sugerida | Justificativa |
|--------|-------------|---------------|
| Push para `main` | | |
| Push para `develop` | | |
| Git tag `v1.2.3` | | |
| Pull Request | | |

- Tags que NUNCA devem ir para produção (e por quê): ...

## Parte 2 — O que a IA deve revisar em um PR

| # | O que verificar | Severidade | Humano também revisa? |
|:-:|----------------|:----------:|:--------------------:|
| 1 | | | |
| ... | | | |
| 10 | | | |

### Discussão
- Itens em que a IA é melhor que humanos: ...
- Itens que só humanos revisam bem: ...
- Cenário em que eu NÃO confiaria na IA: ...
```

### Como entregar

- O arquivo pode ser adicionado no **mesmo PR** do TF ou em PR separado
- A entrega é **individual** — mesmo que a atividade tenha sido em grupo
- O trabalho em aula vale **1 ponto na nota final** do semestre (contabilizado apenas ao final, com **todos** os trabalhos entregues)
