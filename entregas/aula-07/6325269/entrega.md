# Entrega — Aula 07: Decompondo um Problema Complexo com Spec-Driven

**Aluno:** Sirlande Martins  
**RA:** 6325269  
**Data:** 30/09/2026

## Repositório

- URL: https://github.com/Sir-Jr/unifaat-devops-portfolio
- Pasta do TF: [`aula-07/`](https://github.com/Sir-Jr/unifaat-devops-portfolio/tree/main/aula-07)

## Evidências

- [x] `processo-spec.md` com as 7 seções do modelo (divisão do problema, requisitos, design, tarefas, implementação e validação, erros da IA, reflexão)
- [x] Spec em três etapas em `aula-07/.kiro/specs/reserva-salas/`: `requirements.md`, `design.md` e `tasks.md` (10 tarefas)
- [x] Código em Node.js + Express com dados em memória (`server.js`, `package.json`) e `.gitignore` com `node_modules/`
- [x] Rotas mínimas: `POST /salas`, `GET /salas`, `POST /reservas`, `DELETE /reservas/:id` e `GET /reservas?funcionario=NOME`
- [x] Bloqueio de conflito de horário tratado como tarefa isolada (tarefa 8), com 11 casos testados e resposta 409
- [x] Validação por etapas: cada tarefa testada com `curl` antes da seguinte (exemplos na seção 5 do `processo-spec.md`)
- [x] `README.md` com os comandos para rodar o projeto e um roteiro de teste com `curl`
