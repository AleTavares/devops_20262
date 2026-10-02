# API de Reserva de Salas — TechNova

Node.js + Express, dados em memória (reiniciar o servidor apaga tudo).

## Como rodar

```bash
npm install
npm start          # porta 4000 (ou PORT=4100 npm start)
```

## Rotas

| Método | Rota | Descrição |
|--------|------|-----------|
| POST | `/salas` | Cadastra sala. Body: `{"nome":"Sala A"}` (nome obrigatório → 400) |
| GET | `/salas` | Lista salas |
| GET | `/salas?inicio=...&fim=...` | Lista só as salas **livres** no período |
| POST | `/reservas` | Cria reserva. Body: `{"salaId":1,"funcionario":"Ana","inicio":"2026-10-01T10:00:00Z","fim":"2026-10-01T11:00:00Z"}` |
| DELETE | `/reservas/:id` | Cancela reserva (404 se não existe) |
| GET | `/reservas?funcionario=Ana` | Lista reservas do funcionário |

Códigos: `201` criado, `400` validação, `404` sala/reserva inexistente,
`409` conflito de horário (mesma sala, períodos sobrepostos).
Reservas encostadas (fim de uma = início da outra) **não** conflitam.

## Exemplo

```bash
curl -XPOST localhost:4000/salas -H 'Content-Type: application/json' -d '{"nome":"Sala A"}'
curl -XPOST localhost:4000/reservas -H 'Content-Type: application/json' \
  -d '{"salaId":1,"funcionario":"Ana","inicio":"2026-10-01T10:00:00Z","fim":"2026-10-01T11:00:00Z"}'
```
