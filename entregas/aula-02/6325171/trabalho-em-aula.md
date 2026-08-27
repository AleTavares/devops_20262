# Trabalho em Aula — Aula 02: Docker Compose e IA como Copiloto

**Aluno:** [Nicolas De Jesus Silva  ]  
**RA:** [6325171]  
**Data:** [27/08/26]

## Parte 1 — Análise do Problema Multi-Container

### Problemas do Rafael (com classificação)

| # | Problema | Classificação |
|---|---|---|
| 1 | Subir containers com 4 comandos manuais longos | 🟡 Moderado |
| 2 | Ninguém lembra a ordem correta para subir os serviços | 🟡 Moderado |
| 3 | Senhas e credenciais espalhadas por scripts | 🔴 Crítico |
| 4 | Perda de dados do banco ao destruir/reiniciar container | 🔴 Crítico |
| 5 | Dificuldade e demora na integração de novos desenvolvedores | 🟡 Moderado |

### Design da Solução

| Problema do Rafael | Recurso do Docker Compose que resolve |
|---|---|
| 4 comandos complexos | Declaração de `services` centralizada em um único `docker-compose.yml` (`docker compose up`) |
| Ninguém lembra a ordem | `depends_on` com `condition: service_healthy` |
| Senhas espalhadas | Interpolação de variáveis via arquivo `.env` |
| Dados se perdem | Mapeamento de `volumes` nomeados para dados persistentes |
| Novos devs sofrem | Padronização do ambiente em arquivo declarativo versionado |

## Parte 2 — Observações sobre a Demonstração do Kiro

### O que o Kiro gerou corretamente?
- Estrutura base do YAML e sintaxe dos serviços.
- Definição da rede bridge customizada e mapeamento de portas básicas.

### O que precisou de ajuste?
- Remoção/ajuste de porta ocupada (ex: conflito da porta 5432).
- Ajuste e verificação das variáveis de ambiente para a API se conectar corretamente ao banco e cache.

### O que a IA não fez mas deveria?
- Criação automática dos arquivos `.env` e `.env.example`.
- Configuração de healthchecks para Redis/Postgres por padrão.

### Discussão — respostas

1. **Velocidade vs Qualidade:** A IA acelerou a criação da estrutura básica, mas exigiu validação humana para corrigir detalhes de ambiente e portas.
2. **Quando confiar:** Pode-se confiar na sintaxe e no boilerplate inicial, mas nunca em credenciais ou portas padrão sem testar no ambiente local.
3. **Cenário real (workflow ideal):** Gerar o rascunho com a IA → Revisar parâmetros e segurança → Ajustar arquivos locais → Testar com `docker compose up`.
4. **Limitações:** Prompts vagos geram configurações sem suporte a persistência adequada, sem healthchecks e com credenciais hardcoded.