# Trabalho em Aula — Aula 02: Docker Compose e IA como Copiloto

**Aluno:** [FERNANDA ROSA NOVAIS TAVARES]  
**RA:** 4025109  
**Data:** 20/08/2026

## Parte 1 — Análise do Problema Multi-Container

### Problemas do Rafael (com classificação)

| # | Problema | Classificação |
|---|---|---|
| 1 | Iniciar o ambiente exige 4 comandos complexos e repetitivos | 🔴 |
| 2 | Ninguém lembra a ordem correta de execução dos serviços | 🔴 |
| 3 | Senhas e configurações ficam espalhadas em arquivos e comandos diferentes | 🟡 |
| 4 | Dados do banco e de outros serviços podem ser perdidos ao recriar os containers | 🔴 |
| 5 | Novos desenvolvedores precisam aprender um setup manual e demorado para rodar o ambiente | 🟡 |

### Design da Solução

| Problema do Rafael | Recurso do Docker Compose que resolve |
|---|---|
| 4 comandos complexos | Definição centralizada de todos os serviços em um único `docker-compose.yml`, com `docker compose up` para subir o ambiente completo | 
| Ninguém lembra a ordem | `depends_on` para controlar a ordem inicial dos serviços e evitar falhas de conexão | 
| Senhas espalhadas | `environment` e `env_file`/`.env` para centralizar variáveis e segredos em um único lugar | 
| Dados se perdem | `volumes` nomeados para persistir dados do PostgreSQL e outros serviços entre reinícios | 
| Novos devs sofrem | Ambiente reproduzível, com configuração declarada no compose, facilitando onboarding e padronização | 

## Parte 2 — Observações sobre a Demonstração do Kiro

### O que o Kiro gerou corretamente?
- Estrutura básica correta do YAML com `services`, `networks` e `volumes`
- Declaração dos serviços da aplicação Node.js e do banco PostgreSQL
- Configuração de rede bridge customizada
- Volume nomeado para persistência do PostgreSQL
- Mapeamento da porta da API em `3000:3000`
- Uso de `depends_on` para iniciar a dependência do banco antes da app

### O que precisou de ajuste?
- Versões de imagem precisam ser revisadas e padronizadas, por exemplo `postgres:15` ou `postgres:15-alpine`
- As variáveis de ambiente do banco não estavam completas; faltou, por exemplo, `POSTGRES_DB`, `POSTGRES_USER` e `POSTGRES_PASSWORD`
- A variável `DB_HOST` depende do nome do serviço no Compose, e isso precisa ser conferido para não apontar para `localhost` errado em container
- Senhas e segredos não devem ficar hardcoded no arquivo YAML
- `depends_on` por si só não garante que o banco está pronto; um `healthcheck` e uma condição de saúde ajudariam muito

### O que a IA não fez mas deveria?
- Separar as configurações sensíveis em um arquivo `.env` e deixar um `.env.example` para referência
- Incluir `healthcheck` no PostgreSQL e, se possível, na aplicação
- Definir `restart: unless-stopped` ou outra política de reinício
- Adicionar documentação mínima de uso, portas, variáveis previstas e instruções de execução
- Validar se a aplicação realmente usa as variáveis esperadas e se o host do banco está correto

### Discussão — respostas

1. **Velocidade vs Qualidade:** O Kiro gera a estrutura muito mais rápido do que escrever manualmente, o que aumenta produtividade. A qualidade inicial é boa para o esqueleto, mas ainda exige revisão humana para corrigir detalhes de ambiente, segurança e confiabilidade.

2. **Quando confiar:** Eu confiaria imediatamente em partes mais padronizadas, como a estrutura do arquivo, nomes dos serviços, portas e rede. Eu faria validação extra em variáveis sensíveis, nomes de host, volumes, healthchecks, ordem de inicialização e compatibilidade entre versões.

3. **Cenário real (workflow ideal):** O fluxo ideal é: gerar → revisar → ajustar → testar. A IA pode acelerar a primeira versão, mas a pessoa responsável precisa validar se a configuração realmente funciona no ambiente real antes de aceitar o arquivo.

4. **Limitações:** Se o prompt for vago, a IA pode gerar algo incompleto ou genérico, como serviço sem `environment`, sem rede adequada, sem volume persistente, sem healthcheck ou com senha fixa em texto puro. Em ambientes de infraestrutura, comandos imprecisos geram mais retrabalho e riscos.

## Para Anotar

- [ ] Quais são os elementos obrigatórios de um `docker-compose.yml` para o cenário da TechNova?
- [ ] Qual é o fluxo ideal ao usar IA para gerar configurações?
- [ ] Quais pontos de validação são indispensáveis antes de aceitar output de IA?

---

> Conclui-se que o Docker Compose resolve o problema de orquestração multi-container ao centralizar configuração, padronizar startup, proteger segredos e preservar dados, enquanto a IA funciona melhor como aceleradora do início do trabalho, não como substituta da revisão humana.
