# Design Document — Reserva de Salas de Reunião

## Overview

A API de Reserva de Salas de Reunião é uma aplicação Node.js + Express implementada em um **único arquivo `src/server.js`**. O estado é mantido inteiramente em memória, em arrays declarados no topo do arquivo. Não há banco de dados, nem divisão em módulos ou camadas.

A regra de negócio central é a detecção de conflito de horário: uma mesma sala não pode ter duas reservas com intervalos sobrepostos; reservas "encostadas" (fim de uma igual ao início da outra) são permitidas.

---

## Architecture

A aplicação roda como um único processo Node.js. Todo o código — configuração do Express, declaração dos arrays em memória, lógica de negócio e definição das rotas — está concentrado em `src/server.js`.

```
src/
└── server.js   ← ponto de entrada + todos os endpoints + arrays em memória
```

**Estado em memória (topo do arquivo):**

```js
let nextSalaId    = 1;
const salas       = [];   // Sala[]

let nextReservaId = 1;
const reservas    = [];   // Reserva[]
```

Não existe divisão em routes, services ou data stores. Cada endpoint lê e escreve diretamente nos arrays acima.

---

## Components and Interfaces

Todos os endpoints são registrados diretamente no objeto `app` do Express:

| Método | Rota | Descrição |
|---|---|---|
| `POST` | `/salas` | Cadastrar sala |
| `GET` | `/salas` | Listar todas as salas |
| `GET` | `/salas?inicio=&fim=` | Listar salas disponíveis em um período |
| `POST` | `/reservas` | Criar reserva |
| `DELETE` | `/reservas/:id` | Cancelar reserva |
| `GET` | `/reservas?funcionario=` | Listar reservas de um funcionário |

---

## Data Models

### Sala

| Campo | Tipo | Restrições |
|---|---|---|
| `id` | `number` (inteiro) | Sequencial, começa em 1, nunca reutilizado |
| `nome` | `string` | 1–100 caracteres; não pode ser somente espaços brancos |

**Exemplo:**
```json
{ "id": 1, "nome": "Sala de Reunião A" }
```

### Reserva

| Campo | Tipo | Restrições |
|---|---|---|
| `id` | `number` (inteiro) | Sequencial, começa em 1, nunca reutilizado |
| `salaId` | `number` | Deve referenciar um `id` de Sala existente |
| `funcionario` | `string` | 1–100 caracteres; não pode ser somente espaços brancos |
| `inicio` | `string` | ISO 8601 UTC com sufixo `Z`; estritamente anterior a `fim` |
| `fim` | `string` | ISO 8601 UTC com sufixo `Z`; estritamente posterior a `inicio` |

**Exemplo:**
```json
{
  "id": 1,
  "salaId": 2,
  "funcionario": "Ana Lima",
  "inicio": "2025-06-10T14:00:00.000Z",
  "fim": "2025-06-10T15:00:00.000Z"
}
```

### Algoritmo de Detecção de Conflito

Dois intervalos `[A, B)` e `[C, D)` se **sobrepõem** se e somente se:

```
A < D  AND  C < B
```

Essa condição cobre todos os casos de sobreposição (total, parcial, contenção) e **exclui** o caso de reservas encostadas (`B == C` ou `D == A`), que são permitidas.

**Implementação em `server.js`:**

```js
const conflito = reservas.find(
  (r) => r.salaId === sala.id && ini < new Date(r.fim) && new Date(r.inicio) < end
);
if (conflito) {
  return res.status(409).json({
    error: 'Conflito de horário: a sala já está reservada nesse período',
    reservaConflitante: conflito,
  });
}
```

---

## API Contracts

### POST /salas

**Request:**
```json
{ "nome": "Sala A" }
```

**Response 201:**
```json
{ "id": 1, "nome": "Sala A" }
```

**Response 400** — `nome` ausente, vazio, somente espaços brancos ou > 100 caracteres:
```json
{ "error": "Campo obrigatório: nome deve ter entre 1 e 100 caracteres não brancos" }
```

---

### GET /salas

**Response 200:**
```json
[
  { "id": 1, "nome": "Sala A" },
  { "id": 2, "nome": "Sala B" }
]
```

---

### GET /salas?inicio=&fim=

**Response 200** — salas sem conflito com o período:
```json
[{ "id": 2, "nome": "Sala B" }]
```

**Response 400** — apenas um dos parâmetros presente, valores inválidos ou `inicio >= fim`:
```json
{ "error": "Informe inicio e fim válidos (ISO 8601), com inicio < fim" }
```

---

### POST /reservas

**Request:**
```json
{
  "salaId": 1,
  "funcionario": "João Silva",
  "inicio": "2025-06-10T14:00:00.000Z",
  "fim": "2025-06-10T15:00:00.000Z"
}
```

**Response 201:**
```json
{
  "id": 1,
  "salaId": 1,
  "funcionario": "João Silva",
  "inicio": "2025-06-10T14:00:00.000Z",
  "fim": "2025-06-10T15:00:00.000Z"
}
```

**Response 400** — campo ausente, `funcionario` inválido, data inválida ou `inicio >= fim`:
```json
{ "error": "Campos obrigatórios: salaId, funcionario, inicio, fim" }
```

**Response 404** — sala não encontrada:
```json
{ "error": "Sala não encontrada" }
```

**Response 409** — conflito de horário:
```json
{
  "error": "Conflito de horário: a sala já está reservada nesse período",
  "reservaConflitante": {
    "id": 1, "salaId": 1, "funcionario": "Maria",
    "inicio": "2025-06-10T13:30:00.000Z",
    "fim": "2025-06-10T14:30:00.000Z"
  }
}
```

---

### DELETE /reservas/:id

**Response 200:**
```json
{
  "mensagem": "Reserva cancelada",
  "reserva": { "id": 1, "salaId": 1, "funcionario": "João Silva", "inicio": "...", "fim": "..." }
}
```

**Response 400** — `id` não é um inteiro positivo:
```json
{ "error": "O id deve ser um inteiro positivo" }
```

**Response 404** — reserva não encontrada:
```json
{ "error": "Reserva não encontrada" }
```

---

### GET /reservas?funcionario=

**Response 200:**
```json
[
  { "id": 2, "salaId": 1, "funcionario": "Ana Lima", "inicio": "...", "fim": "..." }
]
```

**Response 400** — parâmetro ausente, vazio ou somente espaços brancos:
```json
{ "error": "Parâmetro obrigatório: funcionario não pode ser vazio" }
```

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do.*

### Property 1: IDs sequenciais de salas

*Para qualquer* sequência de requisições `POST /salas` bem-sucedidas, o campo `id` retornado na primeira criação é sempre `1`, e cada criação subsequente retorna um `id` exatamente `1` maior que o anterior — independentemente de quais salas existam ou quantas requisições inválidas tenham sido feitas entre elas.

**Validates: Requirements 1.1, 1.3**

### Property 2: IDs sequenciais de reservas

*Para qualquer* sequência de requisições `POST /reservas` bem-sucedidas, o campo `id` retornado na primeira criação é sempre `1`, e cada criação subsequente retorna um `id` exatamente `1` maior que o anterior — independentemente de cancelamentos ou requisições inválidas intercaladas.

**Validates: Requirements 4.1, 4.9**

### Property 3: Nome obrigatório na criação de sala

*Para qualquer* requisição `POST /salas` cujo corpo não contenha o campo `nome`, ou cujo `nome` seja uma string vazia, composta inteiramente por espaços brancos, ou com mais de 100 caracteres, a API retorna status HTTP 400 e nenhuma sala nova é persistida — o número total de salas retornado pelo `GET /salas` subsequente permanece inalterado.

**Validates: Requirements 1.2**

### Property 4: Detecção de conflito de horário

*Para quaisquer* dois intervalos `[A, B)` e `[C, D)` associados à mesma sala, se `A < D AND C < B` (os intervalos se sobrepõem), então a segunda requisição `POST /reservas` sempre retorna status HTTP 409 com o campo `reservaConflitante` contendo os dados da reserva já existente — e nenhuma nova reserva é criada.

**Validates: Requirements 4.7**

### Property 5: Reservas encostadas são permitidas

*Para qualquer* reserva existente com `fim = T` em uma determinada sala, uma nova requisição `POST /reservas` para a mesma sala com `inicio = T` (e qualquer `fim > T` válido) sempre retorna status HTTP 201 — pois intervalos encostados não configuram sobreposição pela condição `A < D AND C < B`.

**Validates: Requirements 4.8**

### Property 6: Cancelamento libera o horário

*Para qualquer* reserva existente com `id = X`, após uma requisição `DELETE /reservas/X` retornar status HTTP 200, uma nova requisição `POST /reservas` para a mesma `salaId` e com um intervalo igual ou contido no intervalo liberado sempre retorna status HTTP 201 — desde que não haja outra reserva conflitante remanescente para essa sala nesse período.

**Validates: Requirements 5.1, 5.4**

### Property 7: Filtro de funcionário é case-insensitive

*Para qualquer* valor de `funcionario` `X` (em qualquer combinação de maiúsculas e minúsculas), a requisição `GET /reservas?funcionario=X` retorna exatamente o conjunto de reservas cujo campo `funcionario` é igual a `X` ignorando capitalização — nem mais, nem menos. Reservas de outros funcionários nunca aparecem no resultado, e todas as reservas do funcionário consultado sempre aparecem.

**Validates: Requirements 6.1**

---

## Error Handling

| Condição | Status | Corpo |
|---|---|---|
| Campo obrigatório ausente | 400 | `{ "error": "..." }` descrevendo o campo |
| `nome` ou `funcionario` vazio, whitespace-only ou > 100 chars | 400 | `{ "error": "..." }` descrevendo a restrição |
| Data inválida ou `inicio >= fim` | 400 | `{ "error": "..." }` identificando o parâmetro |
| `id` não numérico ou não positivo em `:id` | 400 | `{ "error": "O id deve ser um inteiro positivo" }` |
| Apenas um de `inicio`/`fim` presente na query | 400 | `{ "error": "..." }` |
| Sala não encontrada | 404 | `{ "error": "Sala não encontrada" }` |
| Reserva não encontrada | 404 | `{ "error": "Reserva não encontrada" }` |
| Conflito de horário | 409 | `{ "error": "...", "reservaConflitante": {...} }` |

---

## Testing Strategy

A validação será feita **manualmente via curl**. Inicie o servidor antes de executar os comandos:

```bash
node src/server.js
# API rodando em http://localhost:4000
```

### Cadastrar sala válida
```bash
curl -s -X POST http://localhost:4000/salas \
  -H "Content-Type: application/json" \
  -d '{"nome": "Sala A"}' | jq
# Esperado: 201 { "id": 1, "nome": "Sala A" }
```

### Rejeitar nome vazio / somente espaços
```bash
curl -s -X POST http://localhost:4000/salas \
  -H "Content-Type: application/json" \
  -d '{"nome": "   "}' | jq
# Esperado: 400 { "error": "..." }
```

### Listar todas as salas
```bash
curl -s http://localhost:4000/salas | jq
# Esperado: 200 [ { "id": 1, "nome": "Sala A" } ]
```

### Listar salas disponíveis em um período
```bash
curl -s "http://localhost:4000/salas?inicio=2025-06-10T14:00:00.000Z&fim=2025-06-10T15:00:00.000Z" | jq
# Esperado: 200 com salas que não têm conflito no período
```

### Rejeitar query com apenas um parâmetro de período
```bash
curl -s "http://localhost:4000/salas?inicio=2025-06-10T14:00:00.000Z" | jq
# Esperado: 400 { "error": "..." }
```

### Criar reserva válida
```bash
curl -s -X POST http://localhost:4000/reservas \
  -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"João Silva","inicio":"2025-06-10T14:00:00.000Z","fim":"2025-06-10T15:00:00.000Z"}' | jq
# Esperado: 201 com id, salaId, funcionario, inicio, fim
```

### Rejeitar conflito de horário
```bash
curl -s -X POST http://localhost:4000/reservas \
  -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Maria","inicio":"2025-06-10T14:30:00.000Z","fim":"2025-06-10T15:30:00.000Z"}' | jq
# Esperado: 409 { "error": "Conflito...", "reservaConflitante": {...} }
```

### Aceitar reservas encostadas (fim == início da próxima)
```bash
curl -s -X POST http://localhost:4000/reservas \
  -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Carlos","inicio":"2025-06-10T15:00:00.000Z","fim":"2025-06-10T16:00:00.000Z"}' | jq
# Esperado: 201 (não é conflito com a reserva anterior que termina às 15:00)
```

### Cancelar reserva
```bash
curl -s -X DELETE http://localhost:4000/reservas/1 | jq
# Esperado: 200 { "mensagem": "Reserva cancelada", "reserva": {...} }
```

### Rejeitar id não numérico no cancelamento
```bash
curl -s -X DELETE http://localhost:4000/reservas/abc | jq
# Esperado: 400 { "error": "O id deve ser um inteiro positivo" }
```

### Listar reservas por funcionário (case-insensitive)
```bash
curl -s "http://localhost:4000/reservas?funcionario=joão%20silva" | jq
# Esperado: 200 com reservas de "João Silva" (busca case-insensitive)
```

### Rejeitar funcionário vazio / somente espaços
```bash
curl -s "http://localhost:4000/reservas?funcionario=%20%20" | jq
# Esperado: 400 { "error": "..." }
```
