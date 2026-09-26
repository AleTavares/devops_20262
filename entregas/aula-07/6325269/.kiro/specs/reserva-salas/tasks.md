# Plano de Implementação — API de Reserva de Salas TechNova

Cada tarefa é pequena, implementada **uma de cada vez** e validada com `curl` antes de seguir
para a próxima. Tudo no arquivo `server.js` (ver `design.md`). Datas dos testes em 2027, para
não esbarrar na regra de "reserva no passado".

- [x] 1. Criar o servidor Express básico
  - Criar `server.js` com Express, `express.json()` e porta 3000
  - Criar as seções comentadas previstas no design
  - Rota de teste `GET /` retornando `{ mensagem }`
  - **Validar:** `npm start` e `curl http://localhost:3000/`
  - _Requisitos: 7_

- [x] 2. Cadastrar sala com validação de nome
  - Dados em memória: `salas` e `proximoIdSala`
  - `POST /salas` recebendo `{ nome }`, salvo sem espaços nas pontas
  - Erro 400 se o nome estiver ausente ou vazio
  - **Validar:** cadastro válido (201), sem nome (400), nome só com espaços (400)
  - _Requisitos: 1.1, 1.2, 7.1_

- [x] 3. Impedir nome de sala duplicado
  - Recusar com 409 se já existir sala com o mesmo nome (comparação em minúsculas)
  - **Validar:** cadastrar "Sala Aurora" e depois "sala aurora" (409); outro nome (201)
  - _Requisitos: 1.3_

- [x] 4. Listar salas
  - `GET /salas` retornando todas as salas cadastradas
  - **Validar:** lista vazia antes de cadastrar (200 `[]`); lista com as salas depois (200)
  - _Requisitos: 2.1, 2.2_

- [x] 5. Criar reserva com validação de funcionário e sala
  - Dados em memória: `reservas` e `proximoIdReserva`
  - `POST /reservas` recebendo `{ salaId, funcionario, inicio, fim }`
  - Erro 400 se o funcionário estiver ausente ou vazio
  - Erro 400 se `inicio` ou `fim` estiverem ausentes (formato validado na tarefa 6)
  - Erro 404 se a sala não existir
  - **Validar:** reserva válida (201), sem funcionário (400), sem início/fim (400), sala
    inexistente (404)
  - **Correção após o teste:** `salaId` ausente ou não numérico → 400 (antes caía no 404);
    mensagens da sala indicam o id recebido e `GET /salas`
  - **Revalidar:** sem `salaId` (400), `salaId: "1"` texto (400), `salaId: 0` (400), sala 99
    (404 com o id na mensagem), reserva válida continua 201
  - _Requisitos: 3.1, 3.2, 3.3, 3.4, 3.8, 7.1_

- [x] 6. Validar formato das datas e fim depois do início
  - Função auxiliar que aceita só `AAAA-MM-DDTHH:mm` e data real
  - Erro 400 para formato inválido ou data inexistente, indicando o campo
  - Erro 400 se o fim não for depois do início
  - **Validar:** `"10/03/2027"` (400), `"2027-02-30T10:00"` (400), fim igual ao início (400), fim
    antes do início (400), reserva válida continua 201
  - _Requisitos: 3.5, 3.6_

- [x] 7. Recusar reserva no passado
  - Erro 400 se o início for anterior ao momento atual
  - **Validar:** início em 2020 (400); início em 2027 continua 201
  - _Requisitos: 3.7_

- [x] 8. Bloquear conflito de horário (sobreposição) — tarefa isolada
  - Função auxiliar de sobreposição: `novo.inicio < existente.fim && novo.fim > existente.inicio`
  - Antes de criar, procurar reserva da mesma sala que se sobreponha → erro 409 com a sala e o
    intervalo já reservado
  - **Validar:** os 8 casos da tabela do design — igual, parcial no fim, parcial no início,
    dentro e envolvendo (409); encostando depois, encostando antes e outra sala (201)
  - _Requisitos: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 9. Cancelar reserva
  - `DELETE /reservas/:id` removendo do array e retornando 200 com a reserva removida
  - Erro 404 se a reserva não existir
  - **Validar:** cancelar existente (200), cancelar de novo (404), id inexistente (404) e, após
    cancelar, reservar o mesmo intervalo na mesma sala (201 — horário liberado)
  - **Ajuste após o teste:** id que não é número inteiro positivo (ex.: `abc`) → 400 com o
    formato esperado e onde consultar os ids (antes caía no 404 "pode já ter sido cancelada")
  - **Revalidar:** `abc` (400), `0` (400), `1.5` (400), id 99 (404), cancelamento válido (200)
  - _Requisitos: 5.1, 5.2, 5.3, 5.4_

- [x] 10. Listar reservas de um funcionário
  - `GET /reservas?funcionario=NOME` filtrando pelo nome em minúsculas, ordenado pelo início
  - Erro 400 se `funcionario` não for informado
  - **Validar:** reservas só do funcionário e em ordem cronológica (200), "ANA" igual a "Ana",
    funcionário sem reservas (200 `[]`), sem o parâmetro (400)
  - _Requisitos: 6.1, 6.2, 6.3, 6.4_
