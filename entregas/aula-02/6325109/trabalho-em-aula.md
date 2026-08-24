# Trabalho em Aula — Aula 02: Docker Compose e IA como Copiloto

**Aluno:** Carina Gonçalves dos Santos Dalpino  
**RA:** 6325109  
**Data:** 18/08/2026

---

## Parte 1 — Análise do Problema Multi-Container

### Problemas do Rafael (com classificação)

| # | Problema | Classificação |
|---|---|---|
| 1 | São necessários 4 comandos complexos para subir o ambiente — qualquer flag errada e nada funciona | 🔴 Crítico |
| 2 | Ninguém lembra a ordem de inicialização — o banco precisa subir antes da API, mas isso não está documentado em nenhum lugar | 🔴 Crítico |
| 3 | Senhas espalhadas — cada desenvolvedor coloca uma senha diferente, quebrando a integração entre os serviços | 🟡 Moderado |
| 4 | Dados se perdem — se o container for removido acidentalmente com `docker rm`, todos os dados do banco somem | 🔴 Crítico |
| 5 | Novos desenvolvedores sofrem para configurar o ambiente — o Marcos levou 2 horas só para subir o projeto | 🟡 Moderado |

### Design da Solução

| Problema do Rafael | Recurso do Docker Compose que resolve |
|---|---|
| 4 comandos complexos | Um único `docker compose up` substitui todos os comandos manuais — toda a configuração fica declarada no `docker-compose.yml` |
| Ninguém lembra a ordem | `depends_on` com `condition: service_healthy` garante que a API só sobe depois que o PostgreSQL estiver pronto |
| Senhas espalhadas | Variáveis de ambiente centralizadas no arquivo `.env`, referenciadas pelo `docker-compose.yml` via interpolação — todos usam as mesmas configurações |
| Dados se perdem | Volume nomeado (`pgdata`) persiste os dados do PostgreSQL independentemente do ciclo de vida do container |
| Novos devs sofrem | O `docker-compose.yml` versionado no Git documenta toda a infraestrutura — qualquer pessoa clona o repositório e sobe o ambiente com um único comando |

### Arquitetura da Solução

```
┌─────────────────────────────────────────────┐
│               technova-net (bridge)          │
│                                              │
│  ┌──────────────┐      ┌──────────────────┐  │
│  │  technova-api│─────▶│  technova-db     │  │
│  │  (Node.js)   │      │  (PostgreSQL 15) │  │
│  │  porta 3000  │      │  volume: pgdata  │  │
│  └──────────────┘      └──────────────────┘  │
│          │                                   │
│          ▼                                   │
│  ┌──────────────┐                            │
│  │technova-cache│                            │
│  │  (Redis 7)   │                            │
│  └──────────────┘                            │
└─────────────────────────────────────────────┘
```

---

## Parte 2 — Observações sobre a Demonstração do Kiro

### O que o Kiro gerou corretamente

- Estrutura geral do `docker-compose.yml` bem organizada e com sintaxe válida
- Declaração correta dos três serviços: `api`, `postgres` e `redis`
- Uso de `depends_on` com `condition: service_healthy` — boa prática aplicada corretamente
- Imagens corretas e atualizadas: `postgres:15-alpine` e `redis:7-alpine`
- Interpolação de variáveis de ambiente a partir do arquivo `.env`
- Volume nomeado para persistência dos dados do PostgreSQL
- Rede bridge customizada conectando todos os serviços
- Restart policy `unless-stopped` em todos os serviços

### O que precisou de ajuste

- O healthcheck do PostgreSQL não incluía o parâmetro `-d` para validar o banco específico — apenas verificava a conectividade geral do servidor
- Ausência de `start_period` nos healthchecks — sem esse parâmetro o PostgreSQL pode ser marcado como `unhealthy` durante a inicialização, que é naturalmente mais lenta
- Ausência de `container_name` nos serviços — dificulta a identificação dos containers no `docker ps` e nos logs

### O que a IA não fez mas deveria

- Não gerou o arquivo `.env.example` como template para outros desenvolvedores
- Não adicionou comentários explicativos nas seções do arquivo — importante para onboarding de novos membros
- Não sugeriu o `.dockerignore` para otimizar o contexto de build
- Não alertou sobre a necessidade de adicionar `.env` ao `.gitignore` antes do primeiro commit

### Discussão — respostas

**1. Velocidade vs Qualidade:**  
O Kiro gerou o rascunho inicial em segundos, o que seria inviável manualmente no mesmo tempo. A qualidade foi boa para uma base de trabalho, mas não estava pronta para uso sem revisão — faltavam detalhes importantes nos healthchecks e boas práticas de documentação. O melhor uso é gerar rápido e revisar com cuidado.

**2. Quando confiar:**  
Confio imediatamente na estrutura geral do YAML, nos nomes das imagens e na lógica do `depends_on`. Faço verificação extra em healthchecks (parâmetros específicos de cada ferramenta), variáveis de ambiente (garantir que nenhuma senha está hardcoded) e versões de imagens (confirmar que existem no Docker Hub).

**3. Cenário real (workflow ideal):**  
O fluxo ideal é: **Gerar → Revisar → Ajustar → Testar localmente → Commitar**. Usar a IA para eliminar o trabalho repetitivo de escrever a estrutura base, mas sempre passar pelo ciclo de revisão antes de considerar o arquivo pronto. Nunca aceitar o output diretamente sem `docker compose up` local para validar.

**4. Limitações:**  
Com um prompt vago como "cria docker compose", o resultado seria genérico e provavelmente inutilizável — sem versões de imagens, sem rede customizada, sem healthchecks, com senhas hardcoded. A qualidade do output da IA é diretamente proporcional à qualidade do prompt. Quanto mais contexto e requisitos específicos fornecemos, mais preciso e útil é o resultado.
