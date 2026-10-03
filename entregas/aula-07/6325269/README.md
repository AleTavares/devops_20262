# API de Reserva de Salas — TechNova

API REST para cadastrar salas de reunião, reservar horários, cancelar reservas e listar as
reservas de um funcionário, **sem permitir duas reservas ao mesmo tempo na mesma sala**.

Feita em **Node.js + Express**, com os dados **em memória** (sem banco de dados). Ao reiniciar o
servidor, todas as salas e reservas são apagadas.

A especificação (requisitos, design e tarefas) está em
[`.kiro/specs/reserva-salas/`](.kiro/specs/reserva-salas/), e o processo de construção está em
[`processo-spec.md`](processo-spec.md).

## Requisitos

- Node.js 18 ou mais recente (testado com Node 24)
- npm

## Como rodar

```bash
cd entregas/aula-07/6325269
npm install
npm start
```

O servidor sobe em `http://localhost:3000`. Para conferir:

```bash
curl http://localhost:3000/
# {"mensagem":"API de Reserva de Salas TechNova funcionando!"}
```

Para parar o servidor, use `Ctrl+C` no terminal onde ele está rodando.

## Rotas

| Método | Rota | Corpo / parâmetro | Sucesso | Erros |
|---|---|---|---|---|
| GET | `/` | — | 200 mensagem de teste | — |
| POST | `/salas` | `{ "nome" }` | 201 sala criada | 400 nome ausente · 409 nome repetido |
| GET | `/salas` | — | 200 lista de salas | — |
| POST | `/reservas` | `{ "salaId", "funcionario", "inicio", "fim" }` | 201 reserva criada | 400 dados inválidos · 404 sala · 409 conflito |
| DELETE | `/reservas/:id` | — | 200 `{ mensagem, reserva }` | 400 id inválido · 404 reserva |
| GET | `/reservas?funcionario=NOME` | query `funcionario` | 200 reservas em ordem cronológica | 400 funcionário não informado |

## Regras principais

- **Data e hora:** `inicio` e `fim` usam o formato `AAAA-MM-DDTHH:mm` (ex.: `2027-03-10T10:00`),
  no horário local do servidor. Datas que não existem (ex.: `2027-02-30T10:00`) são recusadas.
- **Intervalo:** o `fim` precisa ser depois do `inicio`, e o `inicio` não pode estar no passado.
- **Conflito:** uma reserva é recusada (409) se o intervalo se sobrepõe, total ou parcialmente, a
  outra reserva **da mesma sala**. Reservas que apenas encostam (10:00–11:00 e 11:00–12:00) são
  aceitas.
- **Cancelamento:** apaga a reserva e libera o horário para uma nova reserva.
- **Nomes:** salas e funcionários são comparados sem diferenciar maiúsculas de minúsculas
  ("Ana" = "ana"), e os espaços nas pontas são ignorados.
- **Erros:** toda resposta de erro vem no formato `{ "erro": "..." }`, com uma mensagem que
  explica o problema e, quando possível, mostra o valor recebido e um exemplo correto.

## Roteiro de teste com `curl`

Com o servidor rodando, em outro terminal:

```bash
# 1. Cadastrar salas
curl -X POST http://localhost:3000/salas -H "Content-Type: application/json" \
  -d '{"nome":"Sala Aurora"}'
curl -X POST http://localhost:3000/salas -H "Content-Type: application/json" \
  -d '{"nome":"Sala Boreal"}'

# 2. Listar salas
curl http://localhost:3000/salas

# 3. Reservar a Sala Aurora (id 1) das 10:00 às 11:00 → 201
curl -X POST http://localhost:3000/reservas -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Ana","inicio":"2027-03-10T10:00","fim":"2027-03-10T11:00"}'

# 4. Tentar reservar a mesma sala das 10:30 às 11:30 → 409 (conflito)
curl -X POST http://localhost:3000/reservas -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Bruno","inicio":"2027-03-10T10:30","fim":"2027-03-10T11:30"}'

# 5. Reservar logo em seguida, das 11:00 às 12:00 → 201 (apenas encosta)
curl -X POST http://localhost:3000/reservas -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Bruno","inicio":"2027-03-10T11:00","fim":"2027-03-10T12:00"}'

# 6. Listar as reservas da Ana
curl "http://localhost:3000/reservas?funcionario=Ana"

# 7. Cancelar a reserva 1 → 200 (o horário das 10:00 fica livre)
curl -X DELETE http://localhost:3000/reservas/1
```

Exemplo de resposta de conflito:

```json
{
  "erro": "Conflito: a sala Sala Aurora já está reservada de 2027-03-10T10:00 até 2027-03-10T11:00 (reserva 1). Escolha outro horário ou outra sala"
}
```

## Estrutura

```
entregas/aula-07/6325269/
├── .kiro/specs/reserva-salas/   # requirements.md, design.md, tasks.md
├── processo-spec.md             # documento do processo
├── package.json
├── server.js                    # toda a API (configuração, dados, auxiliares, rotas)
└── README.md
```
