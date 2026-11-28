# Implementation Plan: Reserva de Salas de Reunião — Correções de Validação

## Overview

O `src/server.js` já possui a estrutura base da API. As tarefas abaixo cobrem apenas as validações ausentes em relação aos requisitos: rejeição de strings whitespace-only, limite de 100 caracteres, parâmetros de query parciais e `id` não numérico/não positivo. Todas as alterações ocorrem no único arquivo `src/server.js`.

## Tasks

- [x] 1. Corrigir validação do `POST /salas`
  - [x] 1.1 Rejeitar `nome` whitespace-only e `nome` com mais de 100 caracteres
    - Localizar o handler `app.post('/salas', ...)` em `src/server.js`
    - Substituir a verificação `if (!nome)` por uma que também rejeite `nome.trim() === ''` e `nome.trim().length > 100`
    - Retornar HTTP 400 com mensagem: `"Campo obrigatório: nome deve ter entre 1 e 100 caracteres não brancos"`
    - A sala NÃO deve ser persistida em nenhum desses casos
    - _Requirements: 1.2_

- [x] 2. Corrigir validação do `GET /salas?inicio=&fim=`
  - [x] 2.1 Rejeitar quando apenas `inicio` OU apenas `fim` está presente na query
    - Já implementado: o handler `app.get('/salas', ...)` contém `if (!inicio || !fim || isNaN(ini) || isNaN(end) || ini >= end)` que retorna HTTP 400 quando apenas um dos parâmetros está presente
    - _Requirements: 3.2_

- [x] 3. Corrigir validação do `POST /reservas`
  - [x] 3.1 Rejeitar `funcionario` whitespace-only e `funcionario` com mais de 100 caracteres
    - Localizar o handler `app.post('/reservas', ...)` em `src/server.js`
    - Após a verificação de campos obrigatórios ausentes, adicionar validação: `funcionario.trim() === ''` → HTTP 400, `funcionario.trim().length > 100` → HTTP 400
    - Retornar mensagem descritiva indicando a restrição do campo `funcionario`
    - A reserva NÃO deve ser persistida em nenhum desses casos
    - _Requirements: 4.3_

- [x] 4. Corrigir validação do `DELETE /reservas/:id`
  - [x] 4.1 Rejeitar `id` não numérico ou não inteiro positivo com HTTP 400
    - Localizar o handler `app.delete('/reservas/:id', ...)` em `src/server.js`
    - No início do handler, antes de buscar no array, verificar se `req.params.id` é um inteiro positivo: `Number.isInteger(Number(req.params.id)) && Number(req.params.id) > 0`
    - Se não for, retornar HTTP 400 com `{ "error": "O id deve ser um inteiro positivo" }`
    - _Requirements: 5.3_

- [x] 5. Corrigir validação do `GET /reservas?funcionario=`
  - [x] 5.1 Rejeitar `funcionario` somente espaços brancos com HTTP 400
    - Localizar o handler `app.get('/reservas', ...)` em `src/server.js`
    - Substituir a verificação `if (!funcionario)` por `if (!funcionario || funcionario.trim() === '')`
    - Retornar HTTP 400 com mensagem: `"Parâmetro obrigatório: funcionario não pode ser vazio"`
    - _Requirements: 6.2_

- [x] 6. Validar bloqueio de conflito de horário
  - Executar os comandos curl abaixo em sequência para verificar o algoritmo de conflito
  - **Setup**: cadastrar uma sala e criar uma reserva base (14h–15h) antes de cada grupo de testes

  ```bash
  # Setup — cadastrar sala
  curl -s -X POST http://localhost:4000/salas \
    -H "Content-Type: application/json" \
    -d '{"nome": "Sala Alpha"}' | jq

  # Setup — criar reserva base 14h–15h (salaId=1)
  curl -s -X POST http://localhost:4000/reservas \
    -H "Content-Type: application/json" \
    -d '{"salaId": 1, "funcionario": "Ana", "inicio": "2025-06-10T14:00:00.000Z", "fim": "2025-06-10T15:00:00.000Z"}' | jq
  ```

  **Caso 1 — Horário idêntico → deve retornar 409**
  ```bash
  curl -s -X POST http://localhost:4000/reservas \
    -H "Content-Type: application/json" \
    -d '{"salaId": 1, "funcionario": "Bruno", "inicio": "2025-06-10T14:00:00.000Z", "fim": "2025-06-10T15:00:00.000Z"}' | jq
  ```

  **Caso 2 — Sobreposição parcial → deve retornar 409**
  ```bash
  curl -s -X POST http://localhost:4000/reservas \
    -H "Content-Type: application/json" \
    -d '{"salaId": 1, "funcionario": "Bruno", "inicio": "2025-06-10T14:30:00.000Z", "fim": "2025-06-10T15:30:00.000Z"}' | jq
  ```

  **Caso 3 — Contido dentro → deve retornar 409**
  ```bash
  curl -s -X POST http://localhost:4000/reservas \
    -H "Content-Type: application/json" \
    -d '{"salaId": 1, "funcionario": "Bruno", "inicio": "2025-06-10T14:15:00.000Z", "fim": "2025-06-10T14:45:00.000Z"}' | jq
  ```

  **Caso 4 — Encostado no fim → deve retornar 201 (permitido)**
  ```bash
  curl -s -X POST http://localhost:4000/reservas \
    -H "Content-Type: application/json" \
    -d '{"salaId": 1, "funcionario": "Bruno", "inicio": "2025-06-10T15:00:00.000Z", "fim": "2025-06-10T16:00:00.000Z"}' | jq
  ```

  **Caso 5 — Outra sala → deve retornar 201 (permitido)**
  ```bash
  # Primeiro cadastrar uma segunda sala
  curl -s -X POST http://localhost:4000/salas \
    -H "Content-Type: application/json" \
    -d '{"nome": "Sala Beta"}' | jq

  # Reservar mesma janela 14h–15h na sala 2
  curl -s -X POST http://localhost:4000/reservas \
    -H "Content-Type: application/json" \
    -d '{"salaId": 2, "funcionario": "Bruno", "inicio": "2025-06-10T14:00:00.000Z", "fim": "2025-06-10T15:00:00.000Z"}' | jq
  ```

  _Requirements: 4.7, 4.8_

- [x] 7. Checkpoint final — Garantir que todas as validações estão corretas
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Todas as alterações ocorrem exclusivamente em `src/server.js`
- As validações de whitespace-only devem usar `.trim() === ''` para cobrir qualquer combinação de espaços, tabs e newlines
- O projeto usa apenas `node` + `express`
- Cada tarefa referencia os requisitos correspondentes para rastreabilidade

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "3.1", "4.1", "5.1"] },
    { "id": 1, "tasks": ["6"] },
    { "id": 2, "tasks": ["7"] }
  ]
}
```
