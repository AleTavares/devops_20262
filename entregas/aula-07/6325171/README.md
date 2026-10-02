# Aula 07 — API de Reserva de Salas

## Objetivo

Construir uma API simples em Node.js com Express para gerenciar salas e reservas, seguindo a abordagem de decomposição em problemas menores e documentação de processo Spec-Driven.

## Tecnologias

- Node.js
- Express
- JavaScript

## Estrutura

- `server.js` — API principal com rotas e regras de negócio
- `processo-spec.md` — documentação do processo de decomposição e validação
- `package.json` — dependências e scripts

## Como rodar

```bash
cd aula-07
npm install
npm start
```

A API fica disponível em:

- `http://localhost:3000/health`
- `http://localhost:3000/salas`
- `http://localhost:3000/reservas`

## Endpoints

### Criar sala

```bash
curl -X POST http://localhost:3000/salas \
  -H "Content-Type: application/json" \
  -d '{"nome":"Sala Verde","capacidade":8}'
```

### Listar salas

```bash
curl http://localhost:3000/salas
```

### Criar reserva

```bash
curl -X POST http://localhost:3000/reservas \
  -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Ana","data":"2026-10-01","horario":"09:00"}'
```

### Listar reservas do funcionário

```bash
curl "http://localhost:3000/reservas?funcionario=Ana"
```

### Cancelar reserva

```bash
curl -X DELETE http://localhost:3000/reservas/1
```

## Regras de negócio

- Nome da sala obrigatório
- Não permitir duas reservas na mesma sala no mesmo dia e horário
- Validar existência da sala antes da reserva
- Listar reservas por funcionário

## Observação

Este projeto foi montado seguindo o método de decomposição e validação por etapas, em linha com a aula 07 de DevOps.
