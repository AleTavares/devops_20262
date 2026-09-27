# Entrega — Aula 07: Decompondo um Problema Complexo com Spec-Driven

**Aluno:** Fernanda Tavares  
**RA:** 4025109  
**Data:** 26/09/2026

## Projeto

- **Tema:** API de Reserva de Salas de Reunião da TechNova
- **Tecnologia:** Node.js + Express, dados em memória (sem banco de dados, sem AWS)
- **Método:** Spec-Driven com o Kiro (Requisitos → Design → Tarefas), implementado tarefa por tarefa

## Estrutura da Entrega

```
entregas/aula-07/4025109/
├── processo-spec.md        # Documento do processo Spec-Driven (principal — 40%)
├── package.json
├── server.js               # API Express com as rotas de salas e reservas
├── README.md               # Como rodar o projeto e exemplos de teste
└── .gitignore              # node_modules/
```

## Evidências — Requisitos Funcionais Mínimos

- [x] `POST /salas` — cadastrar uma sala (validação: nome obrigatório)
- [x] `GET /salas` — listar as salas cadastradas
- [x] `POST /reservas` — criar uma reserva (sala, funcionário, horário)
- [x] **Impedir conflito:** não permite duas reservas na mesma sala e horário (erro claro)
- [x] `DELETE /reservas/:id` — cancelar uma reserva
- [x] `GET /reservas?funcionario=NOME` — listar reservas de um funcionário

## Evidências — Processo Spec-Driven

- [x] `processo-spec.md` completo e honesto (como decompus, guiei a IA e validei)
- [x] Decomposição do problema em tarefas pequenas
- [x] Requisitos revisados no Kiro (o que corrigi/adicionei)
- [x] Design revisado e simplificado
- [x] Lista de tarefas gerada pelo Spec
- [x] Validação por etapas: pelo menos 3 tarefas testadas com `curl` (evidências)
- [x] Relato de erro/alucinação da IA (ou por que o método Spec evitou)
- [x] Reflexão crítica comparando com o "jeito errado" (pedir tudo de uma vez)

## Como o Problema Foi Decomposto

O problema grande (API de reserva de salas) foi quebrado em 6 tarefas pequenas, na ordem de dependência:

1. Setup do servidor Express + armazenamento em memória (arrays de salas e reservas)
2. `POST /salas` + `GET /salas` (cadastrar e listar salas)
3. `POST /reservas` básico (criar reserva sem validação de conflito)
4. **Bloqueio de conflito de horário** (tarefa isolada — a mais difícil)
5. `DELETE /reservas/:id` (cancelar reserva)
6. `GET /reservas?funcionario=NOME` (listar reservas por funcionário)

## Evidência de Validação (exemplos de teste)

```bash
# Cadastrar sala
curl -X POST http://localhost:3000/salas \
  -H "Content-Type: application/json" \
  -d '{"nome": "Sala Azul"}'

# Criar reserva
curl -X POST http://localhost:3000/reservas \
  -H "Content-Type: application/json" \
  -d '{"salaId": 1, "funcionario": "Fernanda", "horario": "2026-09-26T14:00"}'

# Tentar conflito no mesmo horário/sala → retorna erro 409
curl -X POST http://localhost:3000/reservas \
  -H "Content-Type: application/json" \
  -d '{"salaId": 1, "funcionario": "Rafael", "horario": "2026-09-26T14:00"}'
# Resposta esperada: { "erro": "Já existe uma reserva para esta sala neste horário" }
```

> O relato completo do processo, com os prints/saídas de cada validação e a reflexão crítica, está em `processo-spec.md` (arquivo obrigatório e de maior peso na avaliação).
