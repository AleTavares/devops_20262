# Entrega — Aula 07: Decompondo um Problema Complexo com Spec-Driven

**Aluno:** Sirlande Martins  
**RA:** 6325269  
**Data:** 02/10/2026

## Arquivos da entrega

Todos nesta pasta (`entregas/aula-07/6325269/`):

- [`processo-spec.md`](processo-spec.md) — documento do processo
- [`server.js`](server.js) e [`package.json`](package.json) — código da API
- [`README.md`](README.md) — como rodar e testar
- [`.kiro/specs/reserva-salas/`](.kiro/specs/reserva-salas/) — requisitos, design e tarefas

## Evidências

- [x] `processo-spec.md` com as 7 seções do modelo (divisão do problema, requisitos, design, tarefas, implementação e validação, erros da IA, reflexão)
- [x] Spec em três etapas em `.kiro/specs/reserva-salas/`: `requirements.md`, `design.md` e `tasks.md` (10 tarefas)
- [x] Código em Node.js + Express com dados em memória (`server.js`, `package.json`) e `.gitignore` com `node_modules/`
- [x] Rotas mínimas: `POST /salas`, `GET /salas`, `POST /reservas`, `DELETE /reservas/:id` e `GET /reservas?funcionario=NOME`
- [x] Bloqueio de conflito de horário tratado como tarefa isolada (tarefa 8), com 11 casos testados e resposta 409
- [x] Validação por etapas: cada tarefa testada com `curl` antes da seguinte (exemplos na seção 5 do `processo-spec.md`)
- [x] `README.md` com os comandos para rodar o projeto e um roteiro de teste com `curl`
