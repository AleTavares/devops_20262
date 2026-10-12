# Aula 07 — API de reservas de salas

API REST da TechNova em Node.js e Express. Os dados ficam em memória e são
apagados quando o processo é reiniciado, como pede o TF.

## Requisitos

- Node.js 18 ou superior
- npm

## Executar

```bash
npm ci
npm start
```

A API fica em `http://localhost:3000`. Para escolher outra porta, defina a
variável de ambiente `PORT`.

## Rotas

| Método | Rota | Comportamento |
|---|---|---|
| `GET` | `/health` | Confirma que a API está ativa |
| `POST` | `/salas` | Cadastra sala; exige `nome` |
| `GET` | `/salas` | Lista salas |
| `POST` | `/reservas` | Reserva sala com `salaId`, `funcionario` e `horario` |
| `GET` | `/reservas?funcionario=NOME` | Lista reservas do funcionário |
| `DELETE` | `/reservas/:id` | Cancela reserva |

O horário deve usar o formato `YYYY-MM-DDTHH:mm:ss` com fuso explícito (`Z` ou
offset válido). A API valida o formato e a data, normaliza para UTC e rejeita
reservas duplicadas para a mesma sala e instante. O conflito retorna HTTP 409.

## Exemplos com curl

```bash
curl -i -X POST http://localhost:3000/salas \
  -H 'Content-Type: application/json' \
  -d '{"nome":"Sala Ipê"}'

curl -i http://localhost:3000/salas

# Substitua ID_DA_SALA pelo id retornado no cadastro.
curl -i -X POST http://localhost:3000/reservas \
  -H 'Content-Type: application/json' \
  -d '{"salaId":"ID_DA_SALA","funcionario":"Eloísa","horario":"2026-10-12T14:00:00-03:00"}'

curl -i 'http://localhost:3000/reservas?funcionario=Elo%C3%ADsa'
```

## Testes automatizados

```bash
npm test
```

Os testes cobrem cadastro/listagem de salas, criação e cancelamento de reserva,
consulta por funcionário, validações de entrada, normalização de horários e
conflito entre horários equivalentes em fusos diferentes.

## Escopo do trabalho

O processo de requisitos, design, tarefas e validação está registrado em
[`processo-spec.md`](./processo-spec.md).
