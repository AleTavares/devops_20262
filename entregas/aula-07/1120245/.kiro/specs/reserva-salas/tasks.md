# Plano de Implementação: API de Reserva de Salas de Reunião

## Visão Geral

Implementação incremental de uma API REST com Node.js + Express e dados em memória. Cada tarefa produz código funcional e testável. A ordem garante que nenhuma etapa depende de código ainda não escrito.

Linguagem: **JavaScript (Node.js)**

---

## Tarefas

- [x] 1. Configurar projeto e estrutura base
  - Criar `package.json` com `npm init -y` e adicionar dependências: `express` (produção), `jest`, `supertest`, `fast-check` (dev)
  - Criar `.gitignore` com `node_modules/`
  - Criar `server.js` com a configuração mínima do Express: instância do app, `express.json()` como middleware, e exportação do app (sem `app.listen` no módulo para facilitar testes)
  - Criar `server.js` com um bloco de inicialização no final que chama `app.listen(3000)` apenas quando o arquivo é executado diretamente (`if (require.main === module)`)
  - Configurar script `"test": "jest"` e `"start": "node server.js"` no `package.json`
  - _Requisitos: todos_

- [x] 2. Implementar Repositório em Memória e utilitários
  - [x] 2.1 Implementar estruturas de dados e funções utilitárias
    - Declarar arrays `salas` e `reservas` e contadores `proximoIdSala` e `proximoIdReserva` no topo de `server.js`
    - Implementar função `ehStringNaoVazia(valor)`: retorna `true` se o valor não é nulo, undefined, e contém ao menos um caractere não-espaço (usar `typeof valor === 'string' && valor.trim().length > 0`)
    - Implementar função `ehHorarioValido(horario)`: retorna `true` se a string corresponde ao regex `/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/`
    - Implementar função `existeConflito(salaId, horario)`: retorna `true` se `reservas` contém algum item com `salaId === salaId` e `horario === horario` (comparação por valor com `==`)
    - _Requisitos: 1.3, 3.6, 6.1, 6.4_

  - [ ]* 2.2 Escrever testes de propriedade para Validador e Verificador de Conflito
    - Criar arquivo `__tests__/utils.test.js`
    - **Propriedade 2: Nomes de sala em branco são rejeitados**
    - **Valida: Requisitos 1.2** — Para qualquer string composta apenas de whitespace, `ehStringNaoVazia` deve retornar `false`
    - **Propriedade 10: Formato de horário inválido é rejeitado**
    - **Valida: Requisitos 3.5** — Para qualquer string que não corresponda ao padrão YYYY-MM-DD HH:MM, `ehHorarioValido` deve retornar `false`
    - **Propriedade 6: Detecção de conflito de horário**
    - **Valida: Requisitos 3.4, 6.1, 6.2** — Após inserir uma reserva no array, `existeConflito` com mesmo par (salaId, horario) deve retornar `true`
    - Usar fast-check com mínimo 100 iterações por propriedade
    - _Requisitos: 1.2, 3.4, 3.5, 6.1, 6.4_

- [x] 3. Implementar endpoints de Salas
  - [x] 3.1 Implementar `POST /salas` — criar sala
    - Extrair `nome` do `req.body`
    - Rejeitar com 400 se `!ehStringNaoVazia(nome)` com mensagem `"O campo 'nome' é obrigatório e não pode ser vazio."`
    - Verificar duplicidade (case-insensitive): se já existe sala com `s.nome.toLowerCase() === nome.trim().toLowerCase()`, retornar 409 com mensagem `"Já existe uma sala com esse nome."`
    - Criar objeto sala `{ id: proximoIdSala++, nome: nome.trim() }`, fazer push em `salas`, retornar 201 com a sala criada
    - _Requisitos: 1.1, 1.2, 1.4_

  - [x] 3.2 Implementar `GET /salas` — listar salas
    - Retornar `res.json(salas)` com status 200 implícito
    - _Requisitos: 2.1, 2.2, 2.3_

  - [ ]* 3.3 Escrever testes de propriedade para endpoints de Salas
    - Criar arquivo `__tests__/salas.test.js`
    - **Propriedade 1: Criação de sala preserva o nome**
    - **Valida: Requisitos 1.1, 2.1, 2.3** — Para qualquer nome não vazio, a sala criada deve aparecer em GET /salas com o nome correto e um ID válido
    - **Propriedade 3: Nomes de sala são únicos (case-insensitive)**
    - **Valida: Requisitos 1.4** — Para qualquer nome válido, a segunda criação com o mesmo nome deve retornar 409
    - **Propriedade 4: Listagem reflete exatamente as salas criadas**
    - **Valida: Requisitos 2.1, 2.2, 2.3** — Para N salas criadas com nomes distintos, GET /salas retorna exatamente N itens
    - Usar fast-check com mínimo 100 iterações; reiniciar estado antes de cada teste com função auxiliar `resetarEstado()`
    - _Requisitos: 1.1, 1.2, 1.4, 2.1, 2.2, 2.3_

- [x] 4. Checkpoint — Salas funcionando
  - Garantir que todos os testes passam, verificar manualmente com `curl`:
    - `curl -X POST http://localhost:3000/salas -H "Content-Type: application/json" -d '{"nome":"Sala Alfa"}'`
    - `curl http://localhost:3000/salas`
  - Resolver qualquer falha antes de avançar para reservas.

- [x] 5. Implementar endpoints de Reservas
  - [x] 5.1 Implementar `POST /reservas` — criar reserva
    - Extrair `salaId`, `funcionario`, `horario` do `req.body`
    - Validar campos obrigatórios: rejeitar 400 se `salaId` ausente, `!ehStringNaoVazia(funcionario)` ou `!ehStringNaoVazia(horario)`, com mensagem específica por campo
    - Validar formato do horário: rejeitar 400 se `!ehHorarioValido(horario)` com mensagem `"O campo 'horario' deve estar no formato 'YYYY-MM-DD HH:MM'."`
    - Verificar existência da sala: buscar `salas.find(s => s.id === Number(salaId))`; se não encontrar, retornar 404 com mensagem `"Sala não encontrada."`
    - Verificar conflito: chamar `existeConflito(Number(salaId), horario)`; se conflito, retornar 409 com mensagem `"Já existe uma reserva para essa sala nesse horário."`
    - Criar objeto `{ id: proximoIdReserva++, salaId: Number(salaId), funcionario: funcionario.trim(), horario }`, fazer push em `reservas`, retornar 201
    - _Requisitos: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 6.1, 6.2_

  - [x] 5.2 Implementar `DELETE /reservas/:id` — cancelar reserva
    - Extrair `id` de `req.params.id` e converter para número
    - Buscar índice: `reservas.findIndex(r => r.id === id)`
    - Se índice `-1`, retornar 404 com mensagem `"Reserva não encontrada."`
    - Remover com `reservas.splice(index, 1)`, retornar 200 com `{ mensagem: "Reserva cancelada com sucesso." }`
    - _Requisitos: 4.1, 4.2, 4.3, 6.3_

  - [x] 5.3 Implementar `GET /reservas` — listar (com filtro opcional por funcionário)
    - Extrair `funcionario` de `req.query.funcionario`
    - Se `funcionario` presente e não vazio: filtrar `reservas.filter(r => r.funcionario === funcionario)`
    - Caso contrário: retornar `reservas` completo
    - Retornar o array resultante com status 200
    - _Requisitos: 5.1, 5.2, 5.3, 5.4_

  - [ ]* 5.4 Escrever testes de propriedade para endpoints de Reservas
    - Criar arquivo `__tests__/reservas.test.js`
    - **Propriedade 5: Criação de reserva válida é persistida**
    - **Valida: Requisitos 3.1, 3.6, 5.3, 5.4** — Para qualquer combinação válida sem conflito, a reserva criada deve aparecer em GET /reservas com todos os campos corretos
    - **Propriedade 6: Detecção de conflito de horário**
    - **Valida: Requisitos 3.4, 6.1, 6.2** — Para qualquer reserva existente, nova tentativa com mesmo (salaId, horario) deve retornar 409
    - **Propriedade 7: Horários distintos não geram conflito**
    - **Valida: Requisitos 6.4** — Dois horários distintos na mesma sala devem permitir duas reservas (ambos retornam 201)
    - **Propriedade 8: Cancelamento libera horário para nova reserva (round-trip)**
    - **Valida: Requisitos 4.1, 4.3, 6.3** — Criar → cancelar → recriar com mesmo (salaId, horario) deve retornar 201
    - **Propriedade 9: Filtragem por funcionário retorna apenas as reservas corretas**
    - **Valida: Requisitos 5.1, 5.2** — GET /reservas?funcionario=X deve retornar exatamente as reservas de X
    - Usar fast-check com mínimo 100 iterações; reiniciar estado antes de cada propriedade
    - _Requisitos: 3.1, 3.4, 3.5, 4.1, 4.2, 4.3, 5.1, 5.2, 5.3, 5.4, 6.1, 6.2, 6.3, 6.4_

- [x] 6. Checkpoint final — Todos os requisitos funcionando
  - Garantir que todos os testes passam (`npm test`)
  - Verificar manualmente os endpoints de reservas com `curl`:
    - `curl -X POST http://localhost:3000/reservas -H "Content-Type: application/json" -d '{"salaId":1,"funcionario":"Ana Lima","horario":"2026-10-15 14:00"}'`
    - `curl -X POST http://localhost:3000/reservas -H "Content-Type: application/json" -d '{"salaId":1,"funcionario":"Carlos Souza","horario":"2026-10-15 14:00"}'` (deve retornar 409)
    - `curl -X DELETE http://localhost:3000/reservas/1`
    - `curl "http://localhost:3000/reservas?funcionario=Ana%20Lima"`
  - Resolver qualquer falha antes de prosseguir.

- [x] 7. Criar documentação e arquivos de entrega
  - [x] 7.1 Criar `README.md` com instruções de instalação e execução
    - Documentar: pré-requisitos (Node.js), `npm install`, `npm start`, `npm test`
    - Listar todos os endpoints com exemplos de `curl` para cada um
    - Incluir exemplo do erro de conflito de horário (409)
    - _Requisitos: todos_

  - [ ]* 7.2 Criar `processo-spec.md` com documentação do processo Spec-Driven
    - Preencher as 7 seções do modelo conforme o `TF.md`
    - Incluir evidência de testes por etapa (saída de `curl` ou `npm test`)
    - _Requisitos: todos_

---

## Notas

- Tarefas marcadas com `*` são opcionais e podem ser puladas para uma entrega MVP mais rápida, mas são fortemente recomendadas para demonstrar o domínio de testes.
- Cada tarefa referencia os requisitos correspondentes do `requirements.md` para rastreabilidade.
- Os checkpoints garantem validação incremental — não avance sem passar no checkpoint anterior.
- A função `resetarEstado()` nos testes deve restaurar `salas = []`, `reservas = []`, `proximoIdSala = 1`, `proximoIdReserva = 1` antes de cada caso de teste para garantir isolamento.
- O `server.js` deve exportar `app` (sem chamar `listen`) para que os testes com supertest funcionem corretamente.

---

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1"] },
    { "id": 1, "tasks": ["2.1"] },
    { "id": 2, "tasks": ["2.2", "3.1", "3.2"] },
    { "id": 3, "tasks": ["3.3"] },
    { "id": 4, "tasks": ["5.1", "5.2", "5.3"] },
    { "id": 5, "tasks": ["5.4"] },
    { "id": 6, "tasks": ["7.1", "7.2"] }
  ]
}
```
