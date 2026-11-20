# Entrega — Aula 07: Spec-Driven Development com IA

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 15/09/2026

## Repositório

- Projeto: [unifaat-devops-portfolio](https://github.com/Manntto/unifaat-devops-portfolio)
- Código da Aula 07: [aula-07 no branch main](https://github.com/Manntto/unifaat-devops-portfolio/tree/main/aula-07)

## O que foi feito

Utilizei o Kiro em modo Spec-Driven Development para construir a API de Reserva de Salas de Reunião da TechNova. O fluxo seguido foi Requisitos → Design → Tarefas → Implementação, com aprovação manual em cada etapa antes de avançar.

## Checklist de Requisitos

- [x] Problema decomposto em partes menores (cadastro de salas, reservas, conflito de horário)
- [x] Requisitos gerados no formato EARS/INCOSE pelo Kiro
- [x] Design revisado e aprovado antes da implementação
- [x] Tarefas divididas em passos pequenos (7 tarefas top-level)
- [x] Implementação tarefa por tarefa com validação por curl
- [x] API com CRUD completo de reservas
- [x] Validação de conflito de horário funcionando (HTTP 409)
- [x] Testes Jest passando (mínimo 3 test cases)
- [x] `processo-spec.md` documentando o processo com as 7 seções obrigatórias

## Evidência — Endpoints funcionando

```bash
POST /salas {"nome":"Sala Alfa"} → 201 {"id":1,"nome":"Sala Alfa"}
GET  /salas → 200 [{"id":1,"nome":"Sala Alfa"}]
POST /reservas {"salaId":1,"funcionario":"Ana","horario":"2026-10-15 14:00"} → 201
POST /reservas (conflito) → 409 {"erro":"Já existe uma reserva para essa sala nesse horário."}
DELETE /reservas/1 → 200 {"mensagem":"Reserva cancelada com sucesso."}
GET  /reservas?funcionario=Ana → 200 []
```
