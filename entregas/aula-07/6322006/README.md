# API de Reserva de Salas

API REST em Node.js + Express para cadastrar salas e gerenciar reservas em memória. Horários são enviados em ISO 8601 com fuso (`Z` ou offset); intervalos são tratados como `[início, fim)`, portanto reservas adjacentes são permitidas.

## Requisitos

- Node.js 18 ou superior

## Executar

```powershell
npm install
npm start
```

A API escuta em `http://localhost:3000`. Defina `PORT` para usar outra porta.

## Testar

```powershell
npm test
```

## Rotas

| Método | Rota | Descrição |
|---|---|---|
| `POST` | `/salas` | Cadastra sala com `{ "nome": "Sala Azul" }` |
| `GET` | `/salas` | Lista salas |
| `POST` | `/reservas` | Cria reserva com sala, funcionário e horários |
| `GET` | `/reservas?funcionario=Rafael` | Lista reservas do funcionário (sem query, lista todas) |
| `DELETE` | `/reservas/:id` | Cancela reserva |

Exemplo para criar reserva:

```json
{
  "salaId": 1,
  "funcionario": "Rafael Nogueira",
  "inicio": "2026-09-25T10:00:00-03:00",
  "fim": "2026-09-25T11:00:00-03:00"
}
```

Erros de validação retornam `400`, sala/reserva inexistente retorna `404` e conflito de horário retorna `409`. Uma reserva só conflita quando pertence à mesma sala e os intervalos se sobrepõem.

## Limitações

Os dados existem somente na memória do processo e são perdidos ao reiniciar o servidor. O projeto é didático e não inclui autenticação nem persistência.