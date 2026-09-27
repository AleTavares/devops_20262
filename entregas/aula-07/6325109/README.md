# API de Reserva de Salas de Reuniao - TechNova

API REST simples para reservar salas de reuniao. Dados em memoria (sem banco de dados).
Projeto da Aula 07 (Spec-Driven Development).

## Pre-requisitos

- Node.js 18+
- npm

## Como rodar

```bash
npm install
npm start
```

O servidor sobe em `http://localhost:3000`.

## Rotas

| Metodo | Rota | Descricao |
|--------|------|-----------|
| POST | /salas | Cadastrar uma sala (nome obrigatorio) |
| GET | /salas | Listar salas cadastradas |
| POST | /reservas | Criar reserva (salaId, funcionario, horario) |
| DELETE | /reservas/:id | Cancelar uma reserva |
| GET | /reservas?funcionario=NOME | Listar reservas de um funcionario |

## Exemplos (curl)

```bash
# Cadastrar sala
curl -X POST http://localhost:3000/salas \
  -H "Content-Type: application/json" \
  -d '{"nome":"Sala Azul"}'

# Listar salas
curl http://localhost:3000/salas

# Criar reserva
curl -X POST http://localhost:3000/reservas \
  -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Ana","horario":"2026-10-01 14:00"}'

# Conflito de horario (retorna 409)
curl -X POST http://localhost:3000/reservas \
  -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Bruno","horario":"2026-10-01 14:00"}'

# Cancelar reserva
curl -X DELETE http://localhost:3000/reservas/1

# Listar reservas de um funcionario
curl "http://localhost:3000/reservas?funcionario=Ana"
```

## Regras de negocio

- Nome da sala e obrigatorio no cadastro.
- Reserva exige salaId, funcionario e horario.
- A sala precisa existir para criar a reserva.
- Nao e permitido duas reservas na mesma sala e mesmo horario (retorna erro 409).
- Ao cancelar uma reserva, o horario fica livre novamente.