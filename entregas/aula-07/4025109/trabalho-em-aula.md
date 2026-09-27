# Trabalho em Aula — Aula 07: Decomposição de Problemas

**Aluno:** Fernanda Tavares  
**RA:** 4025109  
**Data:** 26/09/2026

---

## Parte 1 — Sentindo o problema grande

**Pedido analisado:** um aplicativo de controle de tarefas para equipes, com criação e atribuição de tarefas, prazos, prioridades, conclusão, comentários, notificações e um painel de acompanhamento para o gestor.

**1. Qual foi a primeira sensação ao ler o pedido?**

A sensação foi de sobrecarga — o pedido mistura muitas funcionalidades diferentes em uma frase só (cadastro, atribuição, prazos, comentários, notificações e dashboard). Não deu para imaginar a solução inteira de uma vez; a cabeça foi pulando de um recurso para outro sem conseguir fixar um ponto de partida. Ficou claro que existem várias "mini-aplicações" escondidas dentro do pedido.

**2. Se pedíssemos isso tudo de uma vez para uma IA, o que aconteceria?**

Provavelmente a IA geraria um código extenso e superficial, tentando cobrir tudo ao mesmo tempo. O resultado tende a ter:
- Funcionalidades incompletas ou apenas esboçadas ("stubs")
- Partes que não se conectam bem entre si (ex: notificação que não sabe de qual atribuição veio)
- Dificuldade nossa de revisar, testar e corrigir, porque tudo vem junto
- Retrabalho grande a cada ajuste, já que mexer em uma parte quebra outra

A lição: quanto maior e mais vago o pedido, pior e menos controlável o resultado.

---

## Parte 2 — Dividir para conquistar

### Atividade A — Listar as partes

Quebrei o aplicativo em 12 partes pequenas, cada uma cabendo em uma frase:

```
1.  Criar uma tarefa (com título)
2.  Listar as tarefas existentes
3.  Ver os detalhes de uma tarefa
4.  Editar uma tarefa (título e descrição)
5.  Excluir uma tarefa
6.  Cadastrar/gerenciar as pessoas da equipe (usuários)
7.  Atribuir uma tarefa a uma pessoa
8.  Definir prazo (data de entrega) de uma tarefa
9.  Definir prioridade (baixa, média, alta) de uma tarefa
10. Marcar uma tarefa como concluída
11. Comentar em uma tarefa
12. Notificar a pessoa quando uma tarefa é atribuída a ela
13. Painel do gestor com o andamento de todas as tarefas
```

### Atividade B — Ordenar as partes

Numerei pensando em **o que precisa existir primeiro** para as demais funcionarem:

| Ordem | Parte | Por que nesta posição |
|-------|-------|------------------------|
| 1 | Cadastrar pessoas/usuários (6) | Sem pessoas, não há a quem atribuir tarefas |
| 2 | Criar uma tarefa (1) | É a entidade central de todo o app |
| 3 | Listar tarefas (2) | Precisa existir tarefa para poder listar |
| 4 | Ver detalhes de uma tarefa (3) | Depende de existir e conseguir listar |
| 5 | Editar tarefa (4) | Depende de existir a tarefa |
| 6 | Excluir tarefa (5) | Depende de existir a tarefa |
| 7 | Atribuir tarefa a uma pessoa (7) | Depende de existir tarefa **e** pessoas |
| 8 | Definir prazo (8) | Campo adicional na tarefa já existente |
| 9 | Definir prioridade (9) | Campo adicional na tarefa já existente |
| 10 | Marcar como concluída (10) | Depende da tarefa existir |
| 11 | Comentar em uma tarefa (11) | Depende de tarefa e de usuários |
| 12 | Notificar ao atribuir (12) | Depende da atribuição já funcionar |
| 13 | Painel do gestor (13) | Depende de quase tudo pronto para ter o que mostrar |

**Raciocínio central:** primeiro as **entidades base** (usuários e tarefas), depois as **operações sobre elas** (listar, editar, atribuir), depois os **campos extras** (prazo, prioridade, status), e por último os recursos que **dependem de outros** (notificação depende de atribuição; painel depende de tudo).

### Atividade C — Escolher a parte mais difícil

**Parte mais difícil:** a **notificação quando uma tarefa é atribuída (parte 12)**.

Por que é a mais difícil: ela não é uma funcionalidade isolada — depende de a atribuição já funcionar, precisa "escutar" o momento em que a atribuição acontece (um evento), e envolve entregar a notificação a uma pessoa específica (por e-mail, dentro do app, etc.). Tem mais peças móveis e integrações do que as outras partes.

**Prompt pequeno e específico para pedir só essa parte à IA:**

> "Considere que já existe uma tarefa com um campo `responsavel_id` e uma tabela de usuários. Implemente **apenas** a lógica que, quando uma tarefa recebe (ou tem alterado) o `responsavel_id`, cria uma notificação no app para esse usuário com o texto 'Você recebeu a tarefa: [título]'. Não implemente o restante do sistema, só essa função de notificação e onde ela deve ser chamada."

O prompt é pequeno porque foca em uma única parte, e é específico porque diz o que já existe (pré-condições), o que fazer (criar a notificação) e o que **não** fazer (não construir o resto).

---

## Parte 3 — Discussão em Classe

**1. Quantas partes encontramos?**

Encontramos **13 partes**. É esperado que outros grupos cheguem a números diferentes (10, 15, 20) — o número exato não importa; o que importa é que cada parte seja pequena e fácil de imaginar. Um grupo mais detalhista pode, por exemplo, separar "listar tarefas" de "filtrar tarefas por status".

**2. Qual ordem escolhemos e por quê?**

Escolhemos ir das **entidades base para as dependências**: usuários → tarefas → operações sobre tarefas → campos extras → recursos dependentes (notificação e painel). O critério foi sempre "o que precisa existir antes para esta parte fazer sentido". Isso evita construir uma funcionalidade que não tem em que se apoiar (ex: notificar sem ter atribuição).

**3. Avaliação do prompt da parte mais difícil**

O prompt da notificação ficou pequeno e específico: ele define as pré-condições (tarefa com `responsavel_id` e tabela de usuários), o objetivo único (criar a notificação no momento da atribuição) e o limite (não implementar o resto). Uma IA entenderia bem porque não há ambiguidade sobre o escopo — o pedido está "recortado" em uma única responsabilidade.

---

## Conexão com o Spec do Kiro

| No papel (hoje) | No Kiro (laboratório) |
|-----------------|------------------------|
| Listamos as 13 partes | O Kiro gera as **Tarefas** |
| Ordenamos por dependência | O Kiro organiza a ordem no **Design** |
| Escrevemos um prompt pequeno da parte difícil | Implementamos **uma tarefa por vez** |

**A grande sacada:** decompor um problema grande em uma lista ordenada de partes pequenas é exatamente o que o modo **Spec** do Kiro faz automaticamente. A habilidade é o raciocínio de "dividir para conquistar"; o Kiro é a ferramenta que ajuda a aplicá-la de forma organizada.
