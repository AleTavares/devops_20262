# API de Reserva de Salas de Reunião

API REST para gerenciar reservas de salas na TechNova. Permite cadastrar salas, listar disponibilidade, criar e cancelar reservas, e consultar a agenda de um funcionário. Todos os dados ficam em memória — sem banco de dados externo.

Construída com **Node.js + Express**.

---

## Pré-requisitos

- Node.js 18 ou superior
- npm

---

## Instalação

```bash
npm install
```

---

## Execução

```bash
npm start
```

O servidor sobe na porta **3000** por padrão.

---

## Testes

```bash
npm test
```

Roda a suíte completa com Jest e Supertest.

---

## Endpoints

| Método   | Rota                  | Descrição                                      |
|----------|-----------------------|------------------------------------------------|
| `POST`   | `/salas`              | Cadastra uma nova sala                         |
| `GET`    | `/salas`              | Lista todas as salas cadastradas               |
| `POST`   | `/reservas`           | Cria uma reserva para uma sala                 |
| `DELETE` | `/reservas/:id`       | Cancela uma reserva pelo ID                    |
| `GET`    | `/reservas`           | Lista reservas (opcionalmente filtra por funcionário) |

---

## Exemplos de uso com curl

### POST /salas — Cadastrar sala

**Sucesso (201):**
```bash
curl -s -X POST http://localhost:3000/salas \
  -H "Content-Type: application/json" \
  -d '{"nome":"Sala Alfa"}'
```
```json
{"id":1,"nome":"Sala Alfa"}
```

**Nome vazio → 400:**
```bash
curl -s -X POST http://localhost:3000/salas \
  -H "Content-Type: application/json" \
  -d '{"nome":""}'
```
```json
{"erro":"O campo 'nome' é obrigatório e não pode ser vazio."}
```

**Nome duplicado → 409:**
```bash
curl -s -X POST http://localhost:3000/salas \
  -H "Content-Type: application/json" \
  -d '{"nome":"Sala Alfa"}'
```
```json
{"erro":"Já existe uma sala com esse nome."}
```

---

### GET /salas — Listar salas

```bash
curl -s http://localhost:3000/salas
```
```json
[{"id":1,"nome":"Sala Alfa"}]
```

---

### POST /reservas — Criar reserva

**Sucesso (201):**
```bash
curl -s -X POST http://localhost:3000/reservas \
  -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Ana Lima","horario":"2026-10-15 14:00"}'
```
```json
{"id":1,"salaId":1,"funcionario":"Ana Lima","horario":"2026-10-15 14:00"}
```

**Conflito de horário → 409:**
```bash
curl -s -X POST http://localhost:3000/reservas \
  -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Carlos Souza","horario":"2026-10-15 14:00"}'
```
```json
{"erro":"Já existe uma reserva para essa sala nesse horário."}
```

**Sala não encontrada → 404:**
```bash
curl -s -X POST http://localhost:3000/reservas \
  -H "Content-Type: application/json" \
  -d '{"salaId":99,"funcionario":"Ana Lima","horario":"2026-10-15 15:00"}'
```
```json
{"erro":"Sala não encontrada."}
```

**Horário em formato inválido → 400:**
```bash
curl -s -X POST http://localhost:3000/reservas \
  -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Ana Lima","horario":"15/10/2026 14h00"}'
```
```json
{"erro":"O campo 'horario' deve estar no formato 'YYYY-MM-DD HH:MM'."}
```

---

### GET /reservas — Listar reservas

**Todas as reservas:**
```bash
curl -s http://localhost:3000/reservas
```
```json
[{"id":1,"salaId":1,"funcionario":"Ana Lima","horario":"2026-10-15 14:00"}]
```

**Filtrar por funcionário:**
```bash
curl -s "http://localhost:3000/reservas?funcionario=Ana%20Lima"
```
```json
[{"id":1,"salaId":1,"funcionario":"Ana Lima","horario":"2026-10-15 14:00"}]
```

> Atenção: espaços no nome do funcionário devem ser codificados como `%20` na URL.

---

### DELETE /reservas/:id — Cancelar reserva

**Sucesso (200):**
```bash
curl -s -X DELETE http://localhost:3000/reservas/1
```
```json
{"mensagem":"Reserva cancelada com sucesso."}
```

**Reserva não encontrada → 404:**
```bash
curl -s -X DELETE http://localhost:3000/reservas/999
```
```json
{"erro":"Reserva não encontrada."}
```

---

## Formato de horário

Todos os horários devem seguir o padrão `YYYY-MM-DD HH:MM`.

Exemplo válido: `"2026-10-15 14:00"`

---

## Estrutura do projeto

```
.
├── server.js          # Aplicação Express (rotas, validação, lógica de negócio)
├── package.json
├── .gitignore
├── README.md
└── processo-spec.md   # Documentação do processo Spec-Driven
```
