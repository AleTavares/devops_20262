# Trabalho em Aula — Aula 10: GitOps e Estratégias de Deploy

**Aluno:** Carina Dal Pino
**RA:** 6325109
**Data:** 22/10/2026

## Parte 1 — Proteções GitOps

| # | Proteção | Como implementar |
|:-:|----------|-----------------|
| 1 | Branch protection na `main` | Settings → Branches → Require PR + approvals (1) antes do merge |
| 2 | Status check obrigatório (plan verde) | Require status checks to pass → selecionar "Terraform Plan"; PR sem plan válido não mergeia |
| 3 | CODEOWNERS para `.tf` | `.github/CODEOWNERS` com `*.tf @devops` — mudança de infra exige aprovação do time de DevOps |
| 4 | `prevent_destroy` em recursos críticos | `lifecycle { prevent_destroy = true }` no RDS/estado — impede destroy acidental via apply |
| 5 | State remoto com lock | Backend S3 + DynamoDB lock — evita applies concorrentes corrompendo o state |

- **O que acontece se o apply falhar depois do merge:** o state pode ficar parcialmente aplicado (alguns recursos criados, outros não). O Terraform registra o que conseguiu aplicar; o próximo apply tenta convergir para o estado desejado. Um `git revert` do PR **não desfaz** automaticamente a infra já criada — é preciso um novo apply (com o código revertido) para o Terraform destruir/ajustar o que mudou. Por isso o plan revisado no PR é a principal defesa.

- **Como prevenir destroy acidental do RDS (2 soluções):**
  1. `lifecycle { prevent_destroy = true }` no recurso do banco — o apply falha se tentar destruí-lo.
  2. Plan que detecta `destroy` e exige aprovação extra (ex.: gate manual via GitHub Environment) + `deletion_protection = true` no próprio RDS.

## Parte 2 — Estratégia de Deploy por Aplicação

| Aplicação | Estratégia escolhida | Justificativa |
|-----------|:--------------------:|---------------|
| Admin Dashboard | Recreate | Uso interno por poucos funcionários em horário comercial; downtime de segundos é aceitável e a simplicidade compensa. Não justifica infra extra. |
| API de Pedidos | Blue-Green | API pública com SLA 99.9% e 500 req/min não tolera downtime. Blue-Green mantém a versão antiga no ar enquanto a nova sobe, com troca de tráfego e rollback instantâneo. |
| Job de Relatórios | Recreate | Roda 1x/dia de madrugada, sem usuários online no momento. Basta parar e subir a nova versão antes da próxima execução; zero necessidade de alta disponibilidade. |

### Discussão

- **Downtime aceitável (para quem?):** depende do usuário e do horário. Para um painel interno usado por 5 pessoas em horário comercial, alguns segundos à noite não impactam ninguém. Para uma API pública com SLA, qualquer downtime vira violação de contrato e perda de receita.

- **Custo de zero downtime:** Blue-Green exige **dobrar** a infraestrutura durante a transição (duas versões simultâneas) ou um **load balancer** para redirecionar tráfego. Isso aumenta custo de servidores e complexidade operacional.

- **O que a TechNova deve fazer agora vs planejar para 6 meses:** **Agora** (startup, 1 servidor) → Recreate, simples e barato, aceitando segundos de downtime. **Em 6 meses** (mais tráfego, SLA) → migrar a API pública para Blue-Green com load balancer, e depois Canary para deploys graduais com observabilidade.
