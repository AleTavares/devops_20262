# Trabalho de Fixação (TF) — Aula 07: Decompondo um Problema Complexo com Spec-Driven

## Desafio

Você vai provar que aprendeu a **domar um problema complexo** — quebrando-o em partes menores e usando o Kiro (modo **Spec**) para resolvê-lo passo a passo, sem cair em alucinação. O problema deste TF é **diferente** do laboratório (não é o sistema de fidelidade), mas usa **o mesmo método**: decompor, guiar a IA e validar cada parte.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | 1 semana a partir da data da aula |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork** | `entregas/aula-07/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | O código do projeto + o documento do processo (`processo-spec.md`) |
| **Valor** | Avaliação individual |

### Como Entregar via Pull Request

1. Faça um **fork** do repositório da disciplina (se ainda não fez)
2. Clone o seu fork localmente
3. Crie a pasta `entregas/aula-07/SEU-RA/`
4. Coloque ali o **código do projeto** que você construiu com o Kiro + o arquivo **`processo-spec.md`** (modelo abaixo)
5. Faça commit e push para o seu fork
6. Abra um **Pull Request** para o repositório original com o título:
   ```
   [Aula 07] RA: SEU-RA - Nome Completo
   ```

---

## O Problema (diferente do laboratório)

> A TechNova quer uma **API de Reserva de Salas de Reunião**. Os funcionários precisam poder: cadastrar salas, ver as salas disponíveis, fazer uma reserva de sala para um horário, cancelar uma reserva e listar as reservas de um funcionário. O sistema não pode deixar duas reservas no mesmo horário para a mesma sala. Os dados podem ficar em memória (sem banco de dados).

Assim como no laboratório, esse é um problema **grande** — mas você já sabe o segredo: **não resolva de uma vez**. Divida em partes, guie a IA por cada parte e valide cada uma.

> **Tecnologia:** Node.js + Express, dados em memória (igual ao laboratório). **Não usa AWS.**

---

## O que você precisa fazer

### Etapa 1 — Usar o modo Spec do Kiro

Descreva o problema para o Kiro em uma **sessão Spec** e conduza as três etapas:

1. **Requisitos** — revise o que o Kiro entendeu. Corrija o que estiver faltando ou errado.
2. **Design** — revise como ele pretende construir. Simplifique se estiver complexo demais.
3. **Tarefas** — confira se o problema virou uma **lista de passos pequenos**.

### Etapa 2 — Implementar tarefa por tarefa

Implemente **uma tarefa de cada vez**, validando cada uma (rode e teste com `curl` ou navegador) antes de ir para a próxima. Nada de mandar a IA "fazer tudo de uma vez".

### Etapa 3 — Documentar o processo

Este é o coração do TF. Preencha o arquivo **`processo-spec.md`** mostrando **como você decompôs o problema e guiou a IA**. (Modelo abaixo.)

---

## Estrutura da Entrega

```
entregas/aula-07/SEU-RA/
├── processo-spec.md        # Documento do processo (OBRIGATÓRIO — é o que mais vale)
├── package.json
├── server.js               # (ou vários arquivos, se o seu design separou)
└── README.md               # Como rodar o projeto (comandos)
```

> **Não inclua** a pasta `node_modules/`. Adicione um `.gitignore` com `node_modules/` se precisar.

---

## Modelo do `processo-spec.md`

```markdown
# Processo Spec-Driven — Reserva de Salas | SEU NOME (RA)

## 1. Como eu dividi o problema
[Liste as partes menores em que você quebrou o problema. Ex: cadastrar sala,
listar salas, criar reserva, evitar conflito de horário, cancelar, listar reservas.]

## 2. Requisitos (o quê)
[Resuma os requisitos que o Kiro gerou. O que você precisou corrigir ou adicionar? Por quê?]

## 3. Design (como)
[Resuma o design proposto. Você simplificou algo? Mudou alguma decisão? Por quê?]

## 4. Tarefas (os passos pequenos)
[Cole a lista de tarefas em que o problema foi dividido.]

## 5. Implementação e validação
[Para pelo menos 3 tarefas, mostre: qual era a tarefa, como você testou (comando
curl ou print) e como confirmou que funcionou.]

## 6. A IA errou em algum momento?
[Descreva se a IA alucinou ou errou algo, como você percebeu e como corrigiu.
Se não errou, explique por que você acha que o método Spec ajudou a evitar isso.]

## 7. Reflexão
[Compare com o "jeito errado" (pedir tudo de uma vez). O que teria acontecido?
O que você aprendeu sobre dividir problemas e usar IA como copiloto?]
```

---

## Requisitos Funcionais Mínimos do Projeto

O código entregue precisa ter, no mínimo, estas rotas funcionando:

- [ ] `POST /salas` — cadastrar uma sala (com validação: nome obrigatório)
- [ ] `GET /salas` — listar as salas cadastradas
- [ ] `POST /reservas` — criar uma reserva (sala, funcionário, horário)
- [ ] **Impedir conflito:** não permitir duas reservas na mesma sala e horário (retornar erro claro)
- [ ] `DELETE /reservas/:id` — cancelar uma reserva
- [ ] `GET /reservas?funcionario=NOME` — listar reservas de um funcionário

---

## Critérios de Avaliação

| Critério | Peso | O que avaliamos |
|----------|:----:|-----------------|
| `processo-spec.md` completo e honesto | 40% | Como você decompôs o problema, guiou a IA e validou cada parte |
| Decomposição em tarefas pequenas | 15% | O problema foi realmente quebrado em partes menores |
| Código funcional | 25% | As rotas mínimas funcionam (incluindo o bloqueio de conflito de horário) |
| Validação por etapas | 10% | Evidência de que você testou tarefa por tarefa |
| Reflexão crítica | 10% | Comparação com o "jeito errado" e aprendizado sobre IA |

> **Atenção:** o `processo-spec.md` vale **mais** que o código. O objetivo do TF **não** é entregar um sistema perfeito — é provar que você sabe **decompor um problema complexo e pilotar a IA** por ele. Um `processo-spec.md` genérico ou copiado reduz muito a nota.

---

## Dicas

- **Releia o TA** antes de começar — os conceitos de decomposição, Harness e Spec-Driven são o que está sendo avaliado.
- **Não peça tudo de uma vez.** Se você fizer isso, vai sentir na pele a alucinação — e o `processo-spec.md` vai ficar pobre.
- **Teste cada tarefa** antes de seguir. É mais rápido do que descobrir tudo quebrado no final.
- O "bloqueio de conflito de horário" é a parte mais difícil — trate-a como **uma tarefa isolada** e valide bem.
- Seja **honesto** no relato: se a IA errou, conte. Mostrar que você percebeu e corrigiu vale nota.

---

*Este TF fecha o Módulo 2 com a habilidade mais valiosa que você leva para a carreira: transformar qualquer problema complexo em partes pequenas e resolvê-las com a IA como copiloto — no controle, sem sustos.*
