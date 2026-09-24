# Trabalho em Aula - Aula 02: Docker Compose e IA como Copiloto

**Aluno:** Gabriel Carneiro da Silva  
**RA:** 6325300  
**Data:** 27/08/2026

## Parte 1 - Analise do Problema Multi-Container

### Problemas do Rafael (com classificacao)

| # | Problema | Classificacao |
|---|---|---|
| 1 | Sao 4 comandos complexos, com muitas flags e alto risco de erro manual | Critico |
| 2 | Ninguem lembra a ordem correta de inicializacao dos containers | Critico |
| 3 | Senhas ficam espalhadas em comandos e variam entre desenvolvedores | Critico |
| 4 | Dados podem se perder quando containers sao removidos sem volume adequado | Critico |
| 5 | Novos desenvolvedores demoram muito para configurar o ambiente | Moderado |

### Design da Solucao

| Problema do Rafael | Recurso do Docker Compose que resolve |
|---|---|
| 4 comandos complexos | `docker compose up`, usando um arquivo declarativo unico |
| Ninguem lembra a ordem | `depends_on` com `condition: service_healthy` |
| Senhas espalhadas | Variaveis no `.env` e template em `.env.example` |
| Dados se perdem | Volume nomeado para o PostgreSQL |
| Novos devs sofrem | Configuracao versionada no Git com README de execucao |

### Arquitetura proposta

- `api`: aplicacao Node.js/Express exposta na porta 3000.
- `postgres`: banco PostgreSQL 15 com volume nomeado para persistencia.
- `redis`: cache Redis 7.
- `technova-network`: rede bridge customizada conectando todos os servicos.
- `pgdata`: volume nomeado usado pelo PostgreSQL.

## Parte 2 - Observacoes sobre a Demonstracao do Kiro

### O que o Kiro gerou corretamente?

- Estrutura inicial do `docker-compose.yml`.
- Servicos principais separados em API, banco e cache.
- Uso de rede customizada para comunicacao entre containers.
- Uso de volume para persistir dados do PostgreSQL.

### O que precisou de ajuste?

- Fixar versoes das imagens, evitando `latest`.
- Trocar senhas hardcoded por variaveis de ambiente.
- Adicionar `.env.example` para documentar as configuracoes.
- Adicionar healthchecks no PostgreSQL e no Redis.
- Usar `depends_on` com condicao de servico saudavel.
- Adicionar `restart: unless-stopped`.

### O que a IA nao fez mas deveria?

- Validar se as imagens escolhidas existem e sao adequadas.
- Separar variaveis sensiveis fora do Compose.
- Explicar os riscos de subir servicos sem healthcheck.
- Criar um checklist de validacao antes de aceitar o output.

### Discussao - respostas

1. **Velocidade vs Qualidade:** O Kiro acelera bastante o primeiro rascunho, mas a qualidade final depende da revisao humana. O arquivo gerado nao deve ser aceito direto.

2. **Quando confiar:** Eu confiaria mais na estrutura geral do YAML e na ideia dos servicos. Faria verificacao extra em seguranca, versoes de imagem, healthchecks, volumes, variaveis sensiveis e funcionamento real com `docker compose up`.

3. **Cenario real (workflow ideal):** O melhor fluxo seria gerar um rascunho com IA, revisar linha por linha, ajustar boas praticas, validar com `docker compose config`, subir o ambiente, testar API, banco e cache, e so depois versionar.

4. **Limitacoes:** Se o prompt for vago, a IA pode gerar uma configuracao incompleta, com imagens erradas, senhas expostas, falta de healthchecks ou nomes de servicos pouco claros. Por isso, conhecimento tecnico continua essencial.
