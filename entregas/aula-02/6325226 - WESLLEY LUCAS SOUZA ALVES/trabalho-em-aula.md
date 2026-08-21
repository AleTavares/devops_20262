# Trabalho em Aula - Aula 02: Docker Compose e IA como Copiloto

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 20/08/2026

## Parte 1 - Análise do Problema Multi-Container

### Problemas do Rafael

| # | Problema | Classificação |
|---|---|---|
| 1 | Era necessário executar vários comandos manuais para iniciar os containers. | Moderado |
| 2 | A ordem de inicialização dos serviços precisava ser lembrada manualmente. | Crítico |
| 3 | As senhas e configurações ficavam espalhadas nos comandos. | Crítico |
| 4 | Os dados do banco poderiam ser perdidos ao remover o container. | Crítico |
| 5 | A configuração de novos desenvolvedores era demorada e sujeita a erros. | Moderado |

### Design da Solução

| Problema do Rafael | Recurso do Docker Compose que resolve |
|---|---|
| 4 comandos complexos | Um arquivo `docker-compose.yml` e o comando `docker compose up`. |
| Ninguém lembra a ordem | `depends_on` e condições baseadas em healthcheck. |
| Senhas espalhadas | Arquivo `.env`, interpolação de variáveis e `.env.example` sem segredos reais. |
| Dados se perdem | Volume nomeado para o PostgreSQL. |
| Novos devs sofrem | Configuração versionada no Git e procedimento reproduzível. |

### Arquitetura proposta

A API, o PostgreSQL e o Redis ficam em uma rede bridge customizada. A API se comunica com o banco pelo hostname `postgres` e com o cache pelo hostname `redis`. O PostgreSQL usa um volume nomeado para manter os dados mesmo quando o container é recriado.

## Parte 2 - Observações sobre a Demonstração do Kiro

### O que o Kiro gerou corretamente?

- A estrutura básica do `docker-compose.yml`.
- A declaração dos serviços da API e do PostgreSQL.
- A rede compartilhada entre os containers.
- O volume nomeado para persistência do banco.
- O uso de `depends_on` para expressar a dependência entre serviços.

### O que precisou de ajuste?

- Inclusão do Redis como terceiro serviço.
- Inclusão de healthchecks no PostgreSQL e no Redis.
- Uso de variáveis interpoladas do `.env` em vez de senhas hardcoded.
- Conferência das versões das imagens e dos nomes dos serviços.
- Validação da configuração com `docker compose config`.

### O que a IA não fez mas deveria?

A IA pode omitir `.env.example`, healthchecks, políticas de reinício, proteção de segredos e instruções de teste. Também pode gerar uma configuração sintaticamente válida, mas que não atende ao comportamento esperado. Por isso, todos os arquivos precisam ser revisados e testados.

### Discussão - respostas

1. **Velocidade vs. qualidade:** O Kiro acelera o rascunho inicial, mas a velocidade não garante qualidade. A configuração gerada precisa ser revisada, corrigida e validada com Docker Compose.

2. **Quando confiar:** É possível confiar inicialmente na estrutura repetitiva, mas é necessário verificar imagens, portas, permissões, variáveis, volumes, healthchecks e dependências antes de executar em um ambiente real.

3. **Cenário real:** O fluxo ideal é requisitos, design, tarefas, geração do código, revisão humana, validação automática, teste do ambiente e documentação das alterações.

4. **Limitações:** Um prompt vago pode produzir serviços faltando, versões inadequadas, senhas expostas, ausência de persistência ou dependências incorretas. Quanto mais específico o prompt, mais fácil é revisar o resultado.

## Checklist de validação

- [x] Serviços, redes e volumes foram definidos no planejamento.
- [x] O fluxo de revisão humana foi considerado.
- [x] A validação com `docker compose config` foi definida.
- [ ] Evidência de um ambiente Aula 02 executado foi anexada.
