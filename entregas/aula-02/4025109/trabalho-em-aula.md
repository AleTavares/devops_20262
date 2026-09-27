# Trabalho em Aula — Aula 02: Docker Compose e IA como Copiloto

**Aluno:** [Seu nome completo]  
**RA:** 4025109  
**Data:** 02/09/2026

## Parte 1 — Análise do Problema Multi-Container

### Problemas do Rafael (com classificação)

| # | Problema | Classificação |
|---|---|---|
| 1 | O ambiente exigia 4 comandos complexos para subir os serviços manualmente | 🔴 |
| 2 | A ordem correta de inicialização dos containers não era clara e era fácil esquecer | 🔴 |
| 3 | Senhas e configurações eram distribuídas em vários lugares, aumentando o risco de erro | 🟡 |
| 4 | Dados do banco e demais serviços podiam ser perdidos ao recriar o ambiente | 🔴 |
| 5 | Novos desenvolvedores tinham dificuldade para configurar tudo do zero e aprender o setup manual | 🟡 |

### Design da Solução

| Problema do Rafael | Recurso do Docker Compose que resolve |
|---|---|
| 4 comandos complexos | Um único arquivo `docker-compose.yml` com todos os serviços declarados e comando `docker compose up` para subir o ambiente inteiro |
| Ninguém lembra a ordem | `depends_on` para controlar a ordem de inicialização dos containers |
| Senhas espalhadas | `environment` e `env_file`/arquivo `.env` para centralizar variáveis e segredos |
| Dados se perdem | `volumes` para persistência dos dados entre reinicializações |
| Novos devs sofrem | Padronização do ambiente com configuração versionada e reproduzível |

## Parte 2 — Observações sobre a Demonstração do Kiro

### O que o Kiro gerou corretamente?
- Estrutura básica correta do arquivo YAML
- Declaração dos serviços da aplicação e do banco de dados
- Inicialização dos containers em uma rede customizada
- Definição de volume nomeado para persistência do PostgreSQL
- Mapeamento correto da porta da API em `3000:3000`
- Uso de `depends_on` para criar a dependência entre a API e o banco

### O que precisou de ajuste?
- Ajustar versões de imagem conforme necessidade do projeto
- Adicionar todas as variáveis de ambiente necessárias ao serviço
- Corrigir host e nomes de conexão entre a aplicação e o banco
- Remover senhas hardcoded do arquivo para seguir boas práticas
- Validar se `depends_on` é suficiente ou se precisa de `healthcheck` e controle de readiness

### O que a IA não fez mas deveria?
- Criar um arquivo `.env` separado para dados sensíveis
- Incluir um `.env.example` para orientar outros integrantes da equipe
- Adicionar `healthcheck` para garantir que o PostgreSQL esteja pronto antes da API consumir o banco
- Definir política de reinício como `restart: unless-stopped` ou equivalente
- Documentar passos de uso e variáveis esperadas pelo projeto

### Discussão — respostas

1. **Velocidade vs Qualidade:** O Kiro gerou o arquivo muito mais rápido do que escrever manualmente, o que acelera o início do trabalho. A qualidade inicial foi boa na estrutura, mas ainda exige revisão humana para ajustar segurança, dependências e confiabilidade.

2. **Quando confiar:** Eu confiaria imediatamente na estrutura geral do arquivo, nos nomes dos serviços, na rede e nas portas. Eu faria verificação extra em variáveis sensíveis, ordem de inicialização, healthchecks, nomenclatura dos hosts e compatibilidade entre versões.

3. **Cenário real (workflow ideal):** O fluxo ideal é: gerar → revisar → ajustar → testar. A IA é útil para criar a primeira versão, mas a validação é essencial para evitar falhas em ambiente real.

4. **Limitações:** Se o prompt for vago, a IA pode gerar uma solução genérica e incompleta, sem credenciais, sem volume, sem rede adequada ou sem healthcheck, o que gera retrabalho e risco de erro.

## Para Anotar

- [ ] Quais são os elementos obrigatórios de um `docker-compose.yml` para o cenário da TechNova?
- [ ] Qual é o fluxo ideal ao usar IA para gerar configurações?
- [ ] Quais pontos de validação são indispensáveis antes de aceitar output de IA?

---

> A IA ajuda a acelerar a geração da base da infraestrutura, mas a revisão humana continua sendo indispensável para segurança, estabilidade e funcionamento correto do ambiente.
