# Trabalho em Aula — Aula 02: Docker Compose e IA como Copiloto

**Aluno:** Sirlande Martins
**RA:** 6325269
**Data:** 23/08/2026

## Parte 1 — Análise do Problema Multi-Container

### Problemas do Rafael (com classificação)

| # | Problema | Classificação |
|---|---|---|
| 1 | 4 comandos complexos — qualquer flag errada e nada funciona | 🟡 Moderado |
| 2 | Ninguém lembra a ordem (o banco precisa subir antes da API) | 🔴 Crítico |
| 3 | Senhas espalhadas — cada dev usa uma diferente | 🔴 Crítico |
| 4 | Dados se perdem se alguém usar `docker rm` sem querer | 🔴 Crítico |
| 5 | Novos devs sofrem (Marcos levou 2 horas pra configurar) | 🟡 Moderado |

### Design da Solução

| Problema do Rafael | Recurso do Docker Compose que resolve |
|---|---|
| 4 comandos complexos | Um único `docker-compose.yml` + `docker compose up` |
| Ninguém lembra a ordem | `depends_on` com `condition: service_healthy` + healthchecks |
| Senhas espalhadas | Variáveis de ambiente centralizadas via `.env` (interpolação), com `.env.example` versionado |
| Dados se perdem | Volume nomeado (`pgdata:/var/lib/postgresql/data`) persiste independente do container |
| Novos devs sofrem | Configuração declarativa versionada no Git — `git clone` + `docker compose up` = ambiente pronto em segundos |

## Parte 2 — Observações sobre a Demonstração do Kiro

### O que o Kiro gerou corretamente?
- A lógica da aplicação (integração Node.js/Express com PostgreSQL) veio coerente
- Depois de um prompt específico cobrando a parte de Docker, a estrutura básica do `docker-compose.yml` (services, variáveis mapeadas) veio correta

### O que precisou de ajuste?
- Foi necessário um novo prompt só pra cobrir a parte de Docker, que não veio na spec inicial
- Mesmo depois de gerada, apareceram os problemas típicos: sem healthcheck, sem restart policy, `depends_on` sem `condition`, senha hardcoded

### O que a IA não fez mas deveria?
- A não especificação de que a API deveria ser criada em um ambiente com containers Docker Compose fez com que o Kiro criasse somente o backend, sem infraestrutura definida (sem Dockerfile, docker-compose, healthchecks, restart policy)

### Discussão — respostas

1. **Velocidade vs Qualidade:** Sim, foi mais rápido do que realizado manualmente, porém exigiu mais atenção e compreensão dos conceitos trabalhados no projeto para obter qualidade equivalente.

2. **Quando confiar:** Dá pra confiar na sintaxe e na estrutura básica; não dá pra confiar que o escopo foi coberto por completo. Foi recomendado sempre conferir se algo ficou de fora antes de aceitar, questionar, realizar o teste, e seguir.

3. **Cenário real (workflow ideal):** Workflow ideal é gerar, revisar se o escopo completo foi atendido, ajustar, e testar. Essa demo mostrou bem por que é necessário ter um conhecimento planejado sobre os requisitos, e a necessidade de especificação para obter o melhor resultado.

4. **Limitações:** Um prompt vago pode fazer a IA ignorar partes inteiras que são fulcrais para o desenvolvimento do projeto, fazendo ela criar uma arquitetura completa com base em um erro.
