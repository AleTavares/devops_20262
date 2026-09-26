# Trabalho em Aula — Aula 02: Docker Compose e IA como Copiloto

**Aluno:** Maximus Ponciano  
**RA:** 6325066  
**Data:** 25/08/2026  

## Parte 1 — Análise do Problema Multi-Container

### Problemas do Rafael (com classificação)

| # | Problema | Classificação |
|---|---|---|
| 1 | Processo manual com múltiplos comandos complexos para subir o ambiente local | 🟡 Moderado |
| 2 | Dependência de ordem rígida de inicialização (subir banco antes da API) sem controle automático | 🔴 Crítico |
| 3 | Credenciais e senhas sensíveis hardcoded ou expostas no terminal | 🔴 Crítico |
| 4 | Dados do banco de dados perdidos toda vez que o container é removido | 🔴 Crítico |
| 5 | Dificuldade e demora na integração de novos desenvolvedores à equipe | 🟡 Moderado |

### Design da Solução

| Problema do Rafael | Recurso do Docker Compose que resolve |
|---|---|
| Múltiplos comandos manuais | Arquivo `docker-compose.yml` orquestrado via `docker compose up` |
| Ordem de inicialização e dependências | Diretiva `depends_on` com condição `service_healthy` aliada a `healthcheck` |
| Senhas expostas | Interpolação de variáveis de ambiente através de `.env` e `.env.example` |
| Perda de dados | Volumes nomeados (`volumes:`) persistidos no host |
| Integração lenta de novos membros | Padronização declarativa da infraestrutura local versionada no Git |

---

## Parte 2 — Observações sobre a Demonstração da IA Copiloto

### O que a IA gerou corretamente?
- Estrutura sintática do YAML em conformidade com o padrão Docker Compose.
- Declaração dos três serviços solicitados (`api`, `postgres`, `redis`).
- Definição de rede customizada tipo `bridge` conectando os 3 containers.
- Mapeamento de volume nomeado para a persistência de dados do PostgreSQL.

### O que precisou de ajuste?
- Inclusão de senhas e credenciais diretamente no YAML, exigindo refatoração para carregar via `.env`.
- Falta de retentativas e intervalos adequados nos healthchecks do Redis e PostgreSQL.
- Ausência de mapeamento adequado de portas de conexão da API.

### O que a IA não fez mas deveria?
- Não criou o arquivo de modelo `.env.example` necessário para versionamento seguro.
- Omitiu políticas de reinício automático (`restart: unless-stopped`).
- Não configurou a verificação de prontidão (*readiness*) completa antes da subida da API.

### Discussão — respostas

1. **Velocidade vs Qualidade:** A IA agiliza bastante a criação da estrutura básica (boilerplate), reduzindo tempo de digitação. Porém, a qualidade exige revisão humana minuciosa para garantir segurança e resiliência.
2. **Quando confiar:** Pode-se confiar na sintaxe do YAML e estrutura inicial de serviços, mas deve-se revisar rigorosamente credenciais, imagens/tags e healthchecks.
3. **Cenário real (workflow ideal):** Prompt bem especificado → Geração pela IA → Code Review e Refatoração manual → Teste local (`docker compose up`).
4. **Limitações:** Prompts vagos resultam em configurações incompletas, senhas hardcoded e ausência de mecanismos de proteção, não sendo adequados para ambientes profissionais sem validação.
