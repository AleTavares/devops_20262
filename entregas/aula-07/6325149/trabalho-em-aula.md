# Trabalho em Aula — Aula 07: Decomposição de Problemas (Dividir para Conquistar)

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 12/10/2026

## Parte 1 — Sentindo o problema grande

1. **Primeira sensação ao ler o pedido:** não dá para imaginar a solução inteira de uma vez. O pedido mistura várias funcionalidades (tarefas, pessoas, prazos, comentários, notificações e painel), e é difícil saber por onde começar.
2. **Se pedíssemos tudo de uma vez para uma IA:** ela provavelmente geraria muito código de uma vez, com suposições próprias nos pontos que não foram especificados (como são as notificações? quem é gestor?), partes incompletas ou inconsistentes entre si e algo difícil de revisar e de corrigir. Pedir em partes pequenas dá controle e evita alucinação.

## Parte 2 — Dividir para conquistar

### Atividade A — Lista de partes

1. Criar uma tarefa (com título)
2. Listar as tarefas existentes
3. Cadastrar pessoas/usuários da equipe
4. Atribuir uma tarefa a uma pessoa
5. Definir prazo da tarefa
6. Definir prioridade da tarefa (baixa, média, alta)
7. Marcar a tarefa como concluída
8. Comentar em uma tarefa
9. Notificar a pessoa quando uma tarefa é atribuída a ela
10. Definir o papel de gestor (quem pode ver o painel)
11. Painel do gestor com o andamento (quantas tarefas por status, por pessoa e atrasadas)

### Atividade B — Ordem (e por quê)

| Ordem | Parte | Depende de |
|:-----:|-------|-----------|
| 1 | Criar uma tarefa | — (é a base de tudo) |
| 2 | Listar as tarefas | 1 |
| 3 | Cadastrar pessoas | — (necessário antes de atribuir) |
| 4 | Atribuir a uma pessoa | 1, 3 |
| 5 | Definir prazo | 1 |
| 6 | Definir prioridade | 1 |
| 7 | Marcar como concluída | 1 |
| 8 | Comentar na tarefa | 1, 3 (autor do comentário) |
| 9 | Notificar ao atribuir | 4 (precisa de atribuição e de pessoa) |
| 10 | Papel de gestor | 3 |
| 11 | Painel do gestor | 5, 6, 7 e 10 (usa prazo, prioridade, status e papel) |

A ordem segue as dependências: primeiro o que existe sozinho (tarefa e pessoa), depois o que complementa a tarefa (atribuição, prazo, prioridade, conclusão, comentário) e por último o que consome tudo (notificação e painel).

### Atividade C — Parte mais difícil

- **Parte mais difícil:** nº 9, *notificar a pessoa quando uma tarefa é atribuída a ela*, porque depende de outra parte (atribuição), envolve um evento que dispara uma ação em outro lugar e exige decisões (por qual canal? e se a pessoa for atribuída duas vezes?).
- **Prompt pequeno e específico para a IA:**

  > "No app de tarefas que já tem tarefas e usuários, quando uma tarefa for atribuída a uma pessoa, registre uma notificação 'Você recebeu a tarefa X' para ela (guardada no sistema, sem e-mail), e crie uma função para listar as notificações não lidas de um usuário."

## Parte 3 — Discussão em Classe

1. **Quantas partes encontramos:** 11 partes. Outros grupos podem ter números diferentes (por exemplo, juntando prazo e prioridade em uma só), e tudo bem: o importante é que cada parte caiba em uma frase e seja fácil de imaginar.
2. **Ordem escolhida e por quê:** começamos pelo que não depende de nada (criar tarefa e cadastrar pessoas), seguimos para o que complementa a tarefa e deixamos para o final o que depende de várias partes (notificação e painel). Se a ordem fosse invertida, ficaríamos sem base para testar cada passo.
3. **Avaliação do prompt da parte mais difícil:** ele é pequeno (uma frase), delimita um único escopo (notificação interna ao atribuir, sem e-mail) e diz o que já existe e o que se espera ao final, de modo que a IA entenda sem inventar o resto.

**Conexão com o Kiro:** o que fizemos no papel é o que o modo Spec faz: a lista de partes vira as **Tarefas**, a ordem vira o **Design** e cada prompt pequeno vira uma tarefa implementada por vez.
