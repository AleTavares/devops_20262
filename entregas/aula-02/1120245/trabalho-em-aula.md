# Trabalho em Aula — Aula 02: Docker Compose e IA como Copiloto

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 24/08/2026

---

## Parte 1 — Análise do Problema Multi-Container

### Problemas do Rafael (com classificação)

| # | Problema | Classificação |
|---|---|---|
| 1 | São 4 comandos complexos para subir o ambiente — qualquer flag errada e nada funciona | 🟡 Moderado |
| 2 | Ninguém lembra a ordem de inicialização — o banco precisa estar pronto antes da API | 🔴 Crítico |
| 3 | Senhas espalhadas em variáveis manuais — cada dev usa uma senha diferente, causando inconsistências | 🔴 Crítico |
| 4 | Dados se perdem — um `docker rm` acidental no container do banco apaga todos os dados | 🔴 Crítico |
| 5 | Novos devs sofrem — setup de 2h para cada pessoa nova na equipe, onboarding impossível de escalar | 🟡 Moderado |

### Design da Solução

| Problema do Rafael | Recurso do Docker Compose que resolve |
|---|---|
| 4 comandos complexos | Um único `docker compose up` substitui todos os comandos manuais — a configuração inteira fica declarada no `docker-compose.yml` |
| Ninguém lembra a ordem | `depends_on` com `condition: service_healthy` garante que o PostgreSQL esteja saudável antes da API iniciar |
| Senhas espalhadas | Arquivo `.env` compartilhado via `.env.example` — todos os devs usam as mesmas variáveis, sem hardcode no YAML |
| Dados se perdem | Volume nomeado `pgdata` persiste os dados do PostgreSQL — `docker compose down` não apaga os dados, somente `down -v` |
| Novos devs sofrem | Com o `docker-compose.yml` no Git, qualquer dev clona o repo e roda `docker compose up` — setup em minutos, não horas |

**Arquitetura desenhada:**

```
┌─────────────────────────────────────────────────────┐
│                   rede: technova-net                 │
│                                                     │
│  ┌──────────┐    ┌──────────────┐    ┌───────────┐  │
│  │   API    │───▶│  PostgreSQL  │    │   Redis   │  │
│  │ :3000    │    │  :5432       │    │  :6379    │  │
│  └──────────┘    └──────┬───────┘    └───────────┘  │
│                         │                           │
│                    volume: pgdata                   │
└─────────────────────────────────────────────────────┘
```

---

## Parte 2 — Observações sobre a Demonstração do Kiro

### O que o Kiro gerou corretamente?

- Estrutura base do YAML com `services`, `networks` e `volumes` bem organizada
- Uso de `depends_on` com `condition: service_healthy` — a forma correta de controlar ordem de inicialização
- Volume nomeado configurado no path correto do PostgreSQL (`/var/lib/postgresql/data`)
- Rede bridge customizada conectando todos os serviços
- `restart: unless-stopped` aplicado a todos os serviços — boa prática padrão

### O que precisou de ajuste?

- **Senhas hardcoded** (`secret123` diretamente no YAML) — principal problema de segurança; precisou substituir por variáveis `${POSTGRES_PASSWORD}`
- **`version: '3.8'`** obsoleto — a propriedade foi removida do Compose v2+ e gera warnings
- **`pg_isready` sem `-d`** — o healthcheck do Postgres não especificava o banco a ser verificado, tornando a checagem menos precisa
- **Sem `start_period`** no healthcheck do Postgres — na primeira inicialização o banco demora mais e os retries falhavam prematuramente

### O que a IA não fez mas deveria?

- **Sem healthcheck no Redis** — o `depends_on` com `condition: service_healthy` para o Redis não funcionaria sem essa checagem; a API iniciaria antes do Redis estar pronto
- **Sem `.env.example`** — não criou o arquivo template para documentar quais variáveis são necessárias
- **Sem `.gitignore`** para garantir que o `.env` real (com senhas) não seja versionado acidentalmente

### Discussão — respostas

**1. Velocidade vs Qualidade:**
O Kiro gerou o rascunho em cerca de 30 segundos — o que levaria ~5 minutos de digitação manual. A qualidade foi suficiente como ponto de partida, mas não estava pronta para uso: os problemas de segurança (senha hardcoded) e o healthcheck faltando no Redis exigiriam tempo extra de debug se não fossem identificados na revisão.

**2. Quando confiar:**
Confiaria imediatamente na estrutura do YAML, na lógica de `depends_on` e nas instruções de volume. Faria verificação extra em: senhas e variáveis de ambiente (sempre checar se estão hardcoded), versões de imagens (verificar no Docker Hub se existem), e healthchecks (testar de verdade com `docker compose up`).

**3. Cenário real (workflow ideal):**
Gerar com IA → revisar com checklist de segurança (senhas, portas, imagens) → validar sintaxe com `docker compose config` → testar localmente com `docker compose up` → ajustar até funcionar → commitar. A IA entra como acelerador do rascunho, não como substituta da revisão técnica.

**4. Limitações:**
Com um prompt vago como "cria docker compose", o output seria genérico demais — provavelmente sem healthchecks, sem volumes, sem rede customizada e com senhas hardcoded. A qualidade do output é proporcional à qualidade do prompt: quanto mais contexto e requisitos específicos, mais útil o resultado.
