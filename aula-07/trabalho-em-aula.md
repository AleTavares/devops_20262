# Aula 07 — Trabalho em Aula

## Objetivo

Praticar, **no papel** (sem computador), a habilidade central desta aula: pegar um problema complexo e **quebrá-lo em partes menores**. Você vai treinar a "dividir para conquistar" antes de levar isso para o Kiro no laboratório.

**Tempo total:** ~30 minutos
**Formato:** Grupos de 3-4 alunos

> **Por que no papel?** Porque decompor é uma habilidade de **raciocínio**, não de ferramenta. Se você aprende a dividir o problema na cabeça, consegue guiar qualquer IA depois.

---

## Parte 1 — Sentindo o problema grande

Leia em grupo o pedido abaixo (é grande de propósito):

> *"Quero um aplicativo de controle de tarefas para equipes: cada pessoa cria tarefas, atribui a colegas, define prazo e prioridade, marca como concluída, comenta nas tarefas, recebe notificação quando algo é atribuído a ela, e o gestor vê um painel com o andamento de tudo."*

**Discutam rapidamente (e anotem):**
1. Qual foi a primeira sensação ao ler o pedido? (Deu para imaginar a solução inteira?)
2. Se vocês pedissem isso **tudo de uma vez** para uma IA, o que provavelmente aconteceria?

---

## Parte 2 — Dividir para conquistar

Agora o trabalho principal: **quebrem esse problema grande em partes menores.**

### Atividade A — Listar as partes

Escrevam uma lista de **partes pequenas** desse aplicativo. Cada parte deve ser algo pequeno o suficiente para caber em uma frase e ser fácil de imaginar. 

> **Dica:** comece pelo mais simples (ex: "criar uma tarefa") e vá crescendo. Pensem em uma parte por funcionalidade.

Exemplo de como começar (continuem a lista):

```
1. Criar uma tarefa (com título)
2. Listar as tarefas existentes
3. Atribuir uma tarefa a uma pessoa
4. ...
5. ...
```

### Atividade B — Ordenar as partes

Numerem as partes na **ordem em que fariam** cada uma. Pensem:
- O que precisa existir **primeiro** para as outras partes funcionarem?
- Qual parte depende de outra?

### Atividade C — Escolher a parte mais difícil

Marquem qual parte vocês acham a **mais difícil** e escrevam em uma frase **como vocês pediriam essa parte específica para uma IA** (um prompt pequeno e claro, só daquela parte).

---

## Parte 3 — Discussão em Classe

Cada grupo compartilha:

1. **Quantas partes** vocês encontraram? (Vamos comparar entre os grupos — provavelmente números diferentes, e tudo bem!)
2. Qual foi a **ordem** escolhida e por quê?
3. Leiam o **prompt da parte mais difícil**. A turma avalia: está pequeno e específico o suficiente? A IA entenderia bem?

**O professor conduz o fechamento conectando com o TA:**

| No papel (hoje) | No Kiro (laboratório) |
|-----------------|------------------------|
| Vocês listaram as partes | O Kiro gera as **Tarefas** |
| Vocês ordenaram | O Kiro organiza a ordem no **Design** |
| Vocês escreveram um prompt pequeno | Vocês implementam **uma tarefa por vez** |

> **A grande sacada:** vocês acabaram de fazer, no papel, o que o modo **Spec** do Kiro faz automaticamente. Decompor é a habilidade; o Kiro é a ferramenta que ajuda a aplicá-la.

---

## Entrega

Não há entrega formal — a participação e a qualidade da decomposição contam para a nota de participação.

**O que levar para o laboratório:**
- A sensação de que **todo problema grande vira uma lista de partes pequenas**
- A noção de que **a ordem importa** (algumas partes vêm antes de outras)
- A prática de escrever um **pedido pequeno e específico** para a IA
