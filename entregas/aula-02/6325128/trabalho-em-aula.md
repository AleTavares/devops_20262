# Trabalho em Aula — Aula 02: Docker Compose e IA como Copiloto

**Aluno:** Felipe Damasceno
**RA:** 6325128
**Data:** 20/08/2026

## Parte 1 — Análise do Problema Multi-Container

### Problemas do Rafael (com classificação)

| # | Problema | Classificação |
|---|---|---|
| 1 | **4 comandos complexos** — para subir o ambiente é preciso lembrar e executar manualmente `docker run` com flags longas para cada container (API, banco, etc.) | 🟡 Moderado |
| 2 | **Ninguém lembra a ordem** — os containers têm dependências entre si (a API precisa que o banco já esteja up), mas sem orquestração qualquer dev pode subir na ordem errada, causando falha na inicialização | 🔴 Crítico |
| 3 | **Senhas espalhadas** — as credenciais do banco ficam expostas diretamente nos comandos `docker run` ou em arquivos não versionados de forma controlada, criando risco de segurança | 🔴 Crítico |
| 4 | **Dados se perdem** — sem volumes declarados explicitamente, ao remover ou recriar o container do banco todos os dados são apagados | 🔴 Crítico |
| 5 | **Novos devs sofrem** — não há documentação ou automação do setup; cada pessoa nova precisa pedir ajuda ou decifrar anotações informais para conseguir subir o ambiente | 🟡 Moderado |

### Design da Solução

| Problema do Rafael | Recurso do Docker Compose que resolve |
|---|---|
| 4 comandos complexos | Um único `docker compose up` sobe todos os serviços declarados no `docker-compose.yml`, eliminando a necessidade de executar múltiplos `docker run` manualmente |
| Ninguém lembra a ordem | Diretiva `depends_on` garante que o Compose inicie os containers na ordem correta (ex: `api` só sobe após `postgres` estar disponível) |
| Senhas espalhadas | Seção `environment` referenciando variáveis de um arquivo `.env` (ex: `${DB_PASSWORD}`), mantendo credenciais fora do código e do repositório |
| Dados se perdem | Declaração de `volumes` nomeados (ex: `postgres_data`) que persiste os dados do banco independentemente do ciclo de vida do container |
| Novos devs sofrem | O próprio `docker-compose.yml` serve como documentação executável do ambiente; basta clonar o repositório e rodar `docker compose up` para ter tudo funcionando |

### Arquitetura (Desafio Bônus)

```
┌─────────────────────────────────────────────────┐
│              Rede: technova_network (bridge)     │
│                                                 │
│  ┌────────────┐        ┌──────────────────────┐ │
│  │   api      │───────▶│      postgres        │ │
│  │ Node/Express│        │   postgres:15-alpine │ │
│  │  :3000     │        │       :5432          │ │
│  └────────────┘        └──────────┬───────────┘ │
│       ▲                           │             │
└───────┼───────────────────────────┼─────────────┘
        │                           │
   Host :3000               Volume nomeado
   (porta exposta)          postgres_data
                            (dados persistidos)
```

## Parte 2 — Observações sobre a Demonstração do Kiro

### O que o Kiro gerou corretamente?
- Estrutura do YAML válida e bem indentada, seguindo o formato esperado pelo Docker Compose
- Dois serviços declarados (`api` e `postgres`) com as imagens corretas (`node` e `postgres:15`)
- Mapeamento de porta `3000:3000` para o serviço da API
- Volume nomeado para o PostgreSQL (`postgres_data`) e sua referência na seção de topo `volumes:`
- Rede bridge customizada declarada e associada a ambos os serviços
- Diretiva `depends_on` configurada para que a `api` aguarde o `postgres`
- Variáveis de ambiente `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` e `DB_PASSWORD` presentes no serviço da API

### O que precisou de ajuste?
- As senhas e usuários foram gerados **hardcoded** diretamente no `docker-compose.yml` (ex: `DB_PASSWORD: senha123`), em vez de referenciar variáveis de um `.env`
- A tag da imagem Node não foi fixada em uma versão específica (usou `node:latest` em vez de algo como `node:20-alpine`), o que pode causar comportamentos imprevisíveis com o tempo
- O `depends_on` simples não garante que o PostgreSQL esteja *pronto para aceitar conexões*, apenas que o container iniciou — seria necessário um `condition: service_healthy` com healthcheck

### O que a IA não fez mas deveria?
- **Arquivo `.env`**: não criou o arquivo com os valores padrão das variáveis de ambiente
- **Arquivo `.env.example`**: não gerou o template documentado para novos desenvolvedores saberem quais variáveis configurar
- **Healthchecks**: não adicionou a configuração de `healthcheck` no serviço `postgres` para que o `depends_on` funcione de forma confiável
- **Restart policies**: não incluiu `restart: unless-stopped` (ou similar) nos serviços, o que significa que os containers não vão reiniciar automaticamente em caso de falha

### Discussão — respostas

1. **Velocidade vs Qualidade:** O Kiro gerou o `docker-compose.yml` em segundos, o que levaria vários minutos escrevendo manualmente — especialmente para quem ainda está aprendendo a sintaxe. A qualidade do esqueleto foi boa, mas não foi equivalente a um arquivo pronto para produção: faltaram boas práticas como `.env`, healthchecks e restart policies. Ou seja, a IA entrega velocidade na primeira versão, mas exige revisão crítica antes do uso real.

2. **Quando confiar:** Confiaríamos imediatamente na estrutura geral do YAML (serviços, redes, volumes bem declarados) e nos nomes das diretivas. Faríamos verificação extra em tudo relacionado a segurança (senhas, variáveis de ambiente), versões de imagens (preferir tags fixas como `postgres:15-alpine` a `latest`) e na lógica de dependência entre serviços (validar se o `depends_on` usa `condition: service_healthy`).

3. **Cenário real (workflow ideal):** O fluxo ideal seria **Gerar → Revisar → Ajustar → Testar**. O Kiro resolve o trabalho braçal da estrutura inicial; a revisão humana garante segurança e boas práticas; o ajuste incorpora os detalhes do projeto real; e o teste (`docker compose up`) valida tudo. Usar o Kiro apenas para revisar um arquivo já escrito também é válido, mas aproveita menos o ganho de velocidade da ferramenta.

4. **Limitações:** Com um prompt vago como "cria docker compose", o Kiro provavelmente geraria um arquivo genérico com serviços fictícios, portas arbitrárias e sem nenhuma variável de ambiente relevante para o projeto. O resultado exigiria quase tanto trabalho de edição quanto escrever do zero. A qualidade do output depende diretamente da qualidade do prompt — quanto mais contexto (tecnologias, portas, variáveis, requisitos de persistência), melhor e mais aproveitável será o resultado gerado.