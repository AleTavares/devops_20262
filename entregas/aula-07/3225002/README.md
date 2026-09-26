# API de Reserva de Salas de Reunião — TechNova

**Aluno:** José Henrique Teixeira Luiz — **RA:** 3225002
**Disciplina:** DevOps — Aula 07 — Prof. Alexandre da Costa Tavares Jr

API em Node.js + Express com os dados **em memória** (sem banco), construída com
o método Spec-Driven: o problema foi quebrado em 8 tarefas pequenas e cada uma
foi validada antes da seguinte. O relato do processo está em
[`processo-spec.md`](processo-spec.md).

## Como rodar

```bash
npm install
npm start          # sobe em http://localhost:3000
```

Porta configurável: `PORT=4000 npm start`.

## Rotas

| Método | Rota | Descrição |
|--------|------|-----------|
| `GET` | `/health` | Verifica se a API está no ar |
| `POST` | `/salas` | Cadastra uma sala (`nome` obrigatório) |
| `GET` | `/salas` | Lista as salas cadastradas |
| `POST` | `/reservas` | Cria uma reserva — **recusa conflito de horário** |
| `GET` | `/reservas?funcionario=NOME` | Lista as reservas de um funcionário |
| `GET` | `/reservas` | Lista todas as reservas |
| `DELETE` | `/reservas/:id` | Cancela uma reserva |

## Exemplos

```bash
# cadastrar uma sala
curl -X POST localhost:3000/salas \
  -H 'Content-Type: application/json' \
  -d '{"nome":"Sala Azul","capacidade":8}'

# listar salas
curl -s localhost:3000/salas

# criar uma reserva
curl -X POST localhost:3000/reservas \
  -H 'Content-Type: application/json' \
  -d '{"sala_id":1,"funcionario":"Jose","inicio":"2026-10-01T14:00","fim":"2026-10-01T15:00"}'

# tentar um horário sobreposto na mesma sala -> 409
curl -X POST localhost:3000/reservas \
  -H 'Content-Type: application/json' \
  -d '{"sala_id":1,"funcionario":"Maria","inicio":"2026-10-01T14:30","fim":"2026-10-01T15:30"}'

# reservas de um funcionário
curl -s "localhost:3000/reservas?funcionario=Jose"

# cancelar
curl -X DELETE localhost:3000/reservas/1
```

## Códigos de resposta

| Código | Quando |
|--------|--------|
| `201` | Sala ou reserva criada |
| `204` | Reserva cancelada |
| `400` | Dados inválidos (nome vazio, horário inválido, `fim` antes do `inicio`) |
| `404` | Sala ou reserva inexistente |
| **`409`** | **Conflito de horário — a sala já está ocupada no intervalo** |

## Estrutura

```
src/
├── server.js               # sobe o servidor
├── app.js                  # monta o Express e as rotas
├── data/memoria.js         # armazenamento em memória
├── routes/salas.js         # POST e GET /salas
├── routes/reservas.js      # POST, GET e DELETE /reservas
└── services/conflito.js    # a regra de sobreposição de horários
```

A regra de conflito ficou num módulo próprio de propósito: é a parte mais
difícil do problema e foi testada isoladamente, com 8 casos, antes de ser
ligada à rota.
