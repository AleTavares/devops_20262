# Trabalho em Aula — Aula 07: Decompondo um Problema Complexo

**Aluno:** Nicolas de Jesus Silva  
**RA:** 6325171  
 URL: https://github.com/NxcolasDev/unifaat-devops-portfolio

---

## Parte 1 — Sentindo o problema grande

1. **Primeira sensação ao ler o pedido:**  
   A primeira sensação é de sobrecarga cognitiva. O pedido abrange múltiplos domínios (autenticação, CRUD de tarefas, atribuição, datas/prazos, comentários, serviço de notificações e um dashboard para gestores). Tentar imaginar a arquitetura completa de uma só vez gera confusão sobre por onde começar.

2. **O que aconteceria se pedíssemos tudo de uma vez para uma IA?**  
   A IA tentaria gerar todo o sistema em um único bloco de código gigantesco. Isso resultaria em alucinações de sintaxe, funções incompletas (placeholders como `// TODO: implementar`), regras de negócio esquecidas e um código difícil de depurar e testar.

---

## Parte 2 — Dividir para conquistar

### Atividade A — Listar e Ordenar as Partes (Atividade A e B)

1. **Criar uma tarefa:** Permite cadastrar uma tarefa básica apenas com título.
2. **Listar as tarefas existentes:** Exibe a lista de tarefas cadastradas.
3. **Atribuir uma pessoa e prazo:** Adiciona o responsável (`atribuidoA`) e a data limite.
4. **Atualizar status da tarefa:** Permite marcar uma tarefa como "concluída".
5. **Adicionar comentários em uma tarefa:** Permite vincular mensagens a uma tarefa específica.
6. **Regra de notificação:** Gera um alerta fictício/log quando a tarefa troca de responsável.
7. **Painel do gestor (Dashboard):** Filtra e exibe o andamento/métricas de todas as tarefas.

### Atividade C — A Parte Mais Difícil e o Prompt Específico

* **Parte mais difícil:** **Garantir a notificação e atualização de status sem permitir dados inconsistentes ou atribuições inválidas.**
* **Prompt específico para a IA:**
  > *"Atue como desenvolvedor Node.js. Implemente uma rota 'PATCH /tarefas/:id/atribuir' que receba o ID da tarefa e o ID do usuário no corpo da requisição. Valide se a tarefa e o usuário existem. Se válidos, atualize o campo 'atribuidoA' da tarefa e retorne o objeto atualizado junto com uma mensagem de confirmação. Não altere outras rotas."*