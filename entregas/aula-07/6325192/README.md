# Aula 07 — API de Reserva de Salas

**Aluno:** Emar Cristian Silva Teruo Ito  
**RA:** 6325192  
**Disciplina:** DevOps

## Sobre

API REST desenvolvida em Node.js com Express para o Trabalho de Fixação da Aula 07.

Os dados são armazenados em memória, conforme solicitado no enunciado.

## Funcionalidades

- Cadastrar salas
- Listar salas
- Criar reservas
- Impedir duas reservas para a mesma sala no mesmo horário
- Cancelar reservas
- Listar reservas de um funcionário

## Como executar

Instale as dependências:

    npm install

Inicie a aplicação:

    npm start

A API ficará disponível em:

    http://localhost:3000

## Rotas

### Cadastrar sala

POST /salas

Exemplo de body:

    {
      "nome": "Sala Azul"
    }

### Listar salas

GET /salas

### Criar reserva

POST /reservas

Exemplo:

    {
      "salaId": 1,
      "funcionario": "Emar",
      "horario": "2026-09-28T10:00"
    }

### Listar reservas

GET /reservas

### Filtrar por funcionário

GET /reservas?funcionario=Emar

### Cancelar reserva

DELETE /reservas/:id

## Regra de conflito

A API não permite criar duas reservas com o mesmo `salaId` e o mesmo `horario`.

Quando existe conflito, retorna HTTP 409 com uma mensagem clara.
