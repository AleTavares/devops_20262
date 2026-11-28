# Trabalho em Aula — Aula 07: Decompondo um Problema Complexo

**Aluno:** Nicolas de Jesus Silva  
**RA:** 6325171

---

## Parte 1 — Sentindo o problema grande

1. **Primeira sensação ao ler o pedido:**  
   O problema parece grande e envolve muitos detalhes ao mesmo tempo. Quando a exigência é ampla, é fácil perder o foco e não saber por onde começar.

2. **O que aconteceria se pedíssemos tudo de uma vez para uma IA?**  
   Ela tentaria resolver tudo em um único bloco, o que costuma gerar funções incompletas, regras de negócio inconsistentes e validações esquecidas. O resultado seria mais difícil de testar e corrigir.

---

## Parte 2 — Dividir para conquistar

### Atividade A — Listar e Ordenar as Partes

1. Criar a estrutura básica da API em Express.
2. Implementar o cadastro de salas.
3. Implementar a listagem de salas.
4. Implementar a criação de reservas.
5. Verificar a regra de conflito para a mesma sala e mesmo horário.
6. Listar reservas por funcionário.
7. Permitir cancelamento de reserva.
8. Validar com testes e comandos cURL.

### Atividade B — Priorizar os requisitos

A prioridade foi:

- validar o funcionamento mínimo da API
- confirmar a regra de conflito de sala/horário
- testar a consulta por funcionário
- depois implementar o cancelamento e a organização final

### Atividade C — Parte mais difícil

A parte mais difícil foi garantir que a regra de negócios fosse aplicada corretamente sem permitir conflitos de agendamento. Isso exige validar a sala informada, comparar o mesmo horário e a mesma data, e bloquear a duplicação sem quebrar o restante da API.

**Prompt específico para a IA:**

> "Atue como desenvolvedor Node.js. Crie uma API com Express para reserva de salas, com endpoints para criar salas, listar salas, criar reservas e consultar reservas por funcionário. Valide se a sala existe antes de criar a reserva e bloqueie reservas duplicadas na mesma sala e mesmo dia/horário. Retorne status 409 quando houver conflito."

---

## Parte 3 — Reflexão sobre o método Spec-Driven

O método Spec-Driven foi importante porque reduziu a carga cognitiva e aumentou a confiabilidade da entrega. Em vez de escrever tudo de uma vez, o problema foi quebrado em requisitos, design e tarefas pequenas, com validação após cada etapa.

Esse processo ajuda a evitar que a IA "adivinhe" parte da solução. A documentação deixa claro o que precisa ser feito, como deve funcionar e como validar cada funcionalidade.

O aprendizado principal foi: problemas complexos são mais fáceis de resolver quando são divididos em blocos pequenos, testáveis e verificáveis.
