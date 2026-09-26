# API de Reserva de Salas — TF Aula 07

**Aluno:** Gabriel Reis Cunha — **RA:** 6325149

API em Node.js + Express para reservar salas de reunião da TechNova. Os dados ficam **em memória** (somem ao reiniciar o servidor). Não usa AWS nem banco de dados.

## Como rodar

```bash
npm install
npm start          # sobe na porta 3000 (use PORT=3100 npm start para trocar)
```

## Rotas

| Método | Rota | Descrição | Respostas |
|--------|------|-----------|-----------|
| POST | `/salas` | Cadastra sala (`nome` obrigatório) | 201, 400 |
| GET | `/salas` | Lista as salas | 200 |
| POST | `/reservas` | Cria reserva (`salaId`, `funcionario`, `inicio`, `fim`) | 201, 400, 404, 409 |
| DELETE | `/reservas/:id` | Cancela a reserva e libera o horário | 200, 404 |
| GET | `/reservas?funcionario=NOME` | Lista reservas do funcionário (sem o parâmetro, lista todas) | 200 |
| GET | `/saude` | Verificação simples de que a API está no ar | 200 |

### Regras

- Cada reserva é um intervalo **`inicio` → `fim`**, e o `fim` deve ser posterior ao `inicio`.
- Não pode haver duas reservas na **mesma sala** com horários que se sobreponham (retorna **409** informando quem já reservou). Horários que apenas se encostam (ex.: 14h–16h e 16h–17h) são permitidos, e salas diferentes não conflitam entre si.
- Envie os horários **com fuso explícito** (ex.: `2026-10-01T14:00:00Z`). Sem fuso, o JavaScript interpreta no fuso do servidor.

## Exemplos com `curl`

```bash
# 1. Cadastrar sala
curl -X POST localhost:3000/salas -H "Content-Type: application/json" \
  -d '{"nome":"Sala Alfa"}'

# 2. Listar salas
curl localhost:3000/salas

# 3. Reservar (sala 1, das 14h às 16h UTC)
curl -X POST localhost:3000/reservas -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Ana","inicio":"2026-10-01T14:00:00Z","fim":"2026-10-01T16:00:00Z"}'

# 4. Mesma sala e horário sobreposto -> 409
curl -X POST localhost:3000/reservas -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Bia","inicio":"2026-10-01T15:00:00Z","fim":"2026-10-01T17:00:00Z"}'

# 5. Reservas de um funcionário
curl "localhost:3000/reservas?funcionario=Ana"

# 6. Cancelar a reserva 1
curl -X DELETE localhost:3000/reservas/1
```

## Processo

O passo a passo de como o problema foi decomposto e como a IA foi guiada está em [`processo-spec.md`](processo-spec.md).
