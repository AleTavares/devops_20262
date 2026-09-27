# API de Reservas — TechNova

**Aluno:** Daniel de Oliveira Tavares Junior
**RA:** 6325032
**Disciplina:** DevOps — UNIFAAT (2026-2)
**Prova:** Primeiro Bimestre (Aulas 01 a 07)

## Descrição

API REST de reservas (Node.js/Express + PostgreSQL) com CRUD completo,
containerizada com Docker, orquestrada localmente com Docker Compose, e
provisionada na AWS (Learner Lab) com Terraform modularizado: VPC em 2 AZs,
Security Groups de menor privilégio, EC2 (API) e RDS PostgreSQL em sub-rede
privada, com estado remoto em S3 + DynamoDB.

## Rotas

| Método | Rota            | Ação                         |
|--------|-----------------|------------------------------|
| POST   | `/reservas`     | Cria uma reserva              |
| GET    | `/reservas`     | Lista todas as reservas       |
| GET    | `/reservas/:id` | Busca uma reserva por id      |
| PUT    | `/reservas/:id` | Atualiza uma reserva          |
| DELETE | `/reservas/:id` | Remove uma reserva            |
| GET    | `/health`       | Healthcheck (API + banco)     |

## Rodando localmente

```bash
cp .env.example .env
docker compose up --build
curl http://localhost:3000/health
```

## Infraestrutura na AWS

Veja `infra/README.md` (ou a seção correspondente deste documento) para o
passo a passo de provisionamento no AWS Academy Learner Lab.

## Relatório

O processo completo (jornada pelas aulas, uso de IA como copiloto,
arquitetura/segurança e validação) está documentado em `relatorio.md`.
