# Trabalho em Aula — Aula 07: Decompondo um Problema Complexo

**Aluno:** Sirlande Martins  
**RA:** 6325269  
**Data:** 30/09/2026

## Parte 1 — Sentindo o problema grande

1. **Primeira sensação ao ler o pedido:** a primeira sensação foi de dúvida. Em um primeiro momento
   parecia um problema muito grande, sendo necessário colocar em prática a metodologia de quebrar o
   problema em etapas menores, criar uma tabela de decisão, aprovar, executar e depois verificar. Não
   foi possível imaginar a solução inteira com o meu conhecimento atual; foi preciso fatiar a solução
   em partes para ser compreendida.

2. **Se pedisse tudo de uma vez para uma IA:** pedir para a IA fazer tudo de uma vez seria vago e
   genérico, muitos erros iriam passar sem a minha revisão, a entrega perderia qualidade e seria ruim
   para o meu aprendizado.

## Parte 2 — Dividir para conquistar

### Atividade A — Listar as partes

O pedido tem sete funcionalidades (criar, atribuir, prazo e prioridade, concluir, comentar,
notificar e painel), mas várias delas escondem uma parte que precisa existir antes: não dá para
atribuir uma tarefa sem saber **quem são as pessoas**, nem mostrar um painel "de gestor" sem saber
**quem é o gestor**. Cada parte abaixo cabe em uma frase:

- Cadastrar uma pessoa da equipe (nome e papel: membro ou gestor)
- Listar as pessoas da equipe
- Criar uma tarefa (com título)
- Listar as tarefas existentes
- Ver os detalhes de uma tarefa
- Definir a prioridade de uma tarefa (baixa, média ou alta)
- Definir o prazo de uma tarefa (data válida, que não esteja no passado)
- Atribuir uma tarefa a uma pessoa
- Listar as tarefas atribuídas a uma pessoa ("minhas tarefas")
- Marcar uma tarefa como concluída
- Comentar em uma tarefa
- Listar os comentários de uma tarefa
- Gerar uma notificação quando uma tarefa for atribuída a alguém
- Listar as notificações de uma pessoa e marcá-las como lidas
- Montar o painel com o andamento (tarefas por status, por pessoa e atrasadas)
- Restringir o painel ao gestor

São **16 partes**.

### Atividade B — Ordenar as partes

| Ordem | Parte | Depende de | Por que nesta posição |
|:---:|---|---|---|
| 1 | Cadastrar pessoa | — | Atribuição, comentário, notificação e painel precisam de pessoas |
| 2 | Listar pessoas | 1 | Permite conferir o cadastro antes de seguir |
| 3 | Criar tarefa | — | É o centro do sistema; quase tudo depois mexe em uma tarefa |
| 4 | Listar tarefas | 3 | Conferência do que foi criado |
| 5 | Ver detalhes da tarefa | 3 | Lugar onde prazo, prioridade, responsável e comentários aparecem |
| 6 | Definir prioridade | 3 | Campo simples, com valores fixos |
| 7 | Definir prazo | 3 | Tem validação de data; separado da prioridade para testar cada regra sozinha |
| 8 | Atribuir a uma pessoa | 1 e 3 | Liga a tarefa a uma pessoa que precisa existir |
| 9 | Minhas tarefas | 8 | Só faz sentido depois que há atribuição |
| 10 | Marcar como concluída | 3 | Cria o status que o painel vai contar |
| 11 | Comentar | 1 e 3 | Comentário tem autor (pessoa) e pertence a uma tarefa |
| 12 | Listar comentários | 11 | Conferência dos comentários |
| 13 | Gerar notificação de atribuição | 8 | É disparada pela atribuição |
| 14 | Listar e marcar notificações como lidas | 13 | Precisa de notificações geradas para testar |
| 15 | Painel do gestor | 7, 8 e 10 | Conta status (10), responsáveis (8) e atrasadas (prazo, 7) |
| 16 | Restringir o painel ao gestor | 1 e 15 | Usa o papel cadastrado na parte 1 sobre um painel que já funciona |

Duas decisões guiaram a ordem:

- **O painel vem por último** porque ele só **lê** o que as outras partes gravam. Se fosse feito
  antes, não haveria status, responsável nem prazo para contar.
- **A notificação vem depois da atribuição**, e não junto, porque é ela que dispara a notificação.
  Com a atribuição já testada, um erro na notificação aponta direto para a parte 13.

### Atividade C — A parte mais difícil

**Parte escolhida: 13 — gerar a notificação quando uma tarefa é atribuída.**

É a única parte que não é chamada diretamente pela pessoa: ela acontece **como efeito** de outra
ação (a atribuição), e tem casos que o pedido não responde: o que acontece ao reatribuir a tarefa
para outra pessoa, ao atribuir a si mesmo ou ao repetir a mesma atribuição. Por isso, antes de pedir
à IA, eu decidiria esses casos e colocaria no prompt, para ela não inventar a regra:

> Implemente só a notificação de atribuição. Quando uma tarefa for atribuída ou reatribuída a uma
> pessoa, grave para ela uma notificação com o id da tarefa, o título, quem atribuiu, a data e hora e
> `lida = false`. Não envie e-mail nem push. Não gere notificação quando a pessoa atribuir a tarefa a
> si mesma nem quando o responsável não mudar. Não altere as outras partes. No final, mostre como
> testar esses três casos.

## Parte 3 — Discussão em Classe

1. **Quantas partes:** 16. O número sobe em relação às sete funcionalidades do pedido porque
   apareceram partes "escondidas" (cadastro de pessoas, listagens de conferência e a restrição do
   painel ao gestor).
2. **Ordem escolhida e por quê:** primeiro o que não depende de nada (pessoas e tarefas), depois o
   que liga uma coisa à outra (atribuição, comentário), depois o que é disparado por outra ação
   (notificação) e, por último, o que só lê o resto (painel).
3. **O prompt da parte mais difícil está pequeno e específico?** Sim: trata de uma parte só, diz o
   que gravar, define os três casos que o pedido deixava em aberto, proíbe mexer nas outras partes e
   pede um jeito de testar.

| No papel (hoje) | Com o Claude (laboratório) |
|---|---|
| Listei 16 partes | O Claude gera as **Tarefas** |
| Ordenei pelas dependências | O Claude organiza a ordem no **Design** |
| Escrevi um prompt pequeno para a parte mais difícil | Implementa-se **uma tarefa por vez** |
