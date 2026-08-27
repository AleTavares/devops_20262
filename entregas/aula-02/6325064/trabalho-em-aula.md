# Trabalho em Aula — Aula 02: Docker Compose e IA como Copiloto

**Aluno:** Henri da Silva Despezzi 
**RA:** 6325064
**Data:** 20/08/2026

## Parte 1 — Análise do Problema Multi-Container

### Problemas do Rafael (com classificação)

| # | Problema | Classificação |
|---|---|---|
| 1 | São necessários 4 comandos complexos para iniciar a aplicação | 🟡 |
| 2 | Ninguém lembra a ordem correta dos comandos | 🟡 |
| 3 | As senhas ficam espalhadas nos arquivos e configurações | 🔴 |
| 4 | Os dados do banco se perdem quando o container é removido | 🔴 |
| 5 | Novos desenvolvedores têm dificuldade para configurar o ambiente | 🟡 |

### Design da Solução

| Problema do Rafael | Recurso do Docker Compose que resolve |
|---|---|
| 4 comandos complexos | Um único `docker compose up` para iniciar todos os serviços |
| Ninguém lembra a ordem | `depends_on` para definir a dependência entre os serviços |
| Senhas espalhadas | Variáveis de ambiente e arquivo `.env` para centralizar as configurações |
| Dados se perdem | Volume nomeado para persistir os dados do PostgreSQL |
| Novos devs sofrem | `docker-compose.yml` padronizado, facilitando a configuração do ambiente |

## Parte 2 — Observações sobre a Demonstração do Kiro

### O que o Kiro gerou corretamente?
- Estrutura básica do `docker-compose.yml`.
- Os serviços da API Node.js e do PostgreSQL 15.
- A porta 3000 para a API.
- As variáveis de ambiente para conexão com o banco.
- Volume nomeado para persistência dos dados do PostgreSQL.
- Rede customizada do tipo bridge.
- `depends_on` para indicar a dependência da API em relação ao banco.

### O que precisou de ajuste?
- Verificar se as versões das imagens estavam corretas.
- Conferir se todas as variáveis de ambiente necessárias estavam presentes.
- Evitar deixar senhas diretamente no `docker-compose.yml`.
- Ajustar configurações de acordo com as necessidades reais da aplicação.

### O que a IA não fez mas deveria?
- Criar ou utilizar um arquivo `.env` para as informações sensíveis.
- Criar um `.env.example` sem as senhas reais.
- Adicionar `healthcheck` para verificar se o PostgreSQL está realmente pronto.
- Considerar políticas de `restart` para melhorar a disponibilidade dos containers.
- Testar e validar se a configuração gerada funciona corretamente.

### Discussão — respostas

1. **Velocidade vs Qualidade:** O Kiro consegue gerar a configuração mais rapidamente do que escrever tudo manualmente. Porém, a qualidade precisa ser revisada e testada, pois a IA pode cometer erros ou deixar configurações importantes de fora.

2. **Quando confiar:** Eu confiaria inicialmente na estrutura geral, como serviços, portas, redes e volumes. Porém, faria uma verificação extra nas senhas, variáveis de ambiente, versões das imagens, dependências e configurações de segurança.

3. **Cenário real (workflow ideal):** O workflow ideal seria **Gerar → Revisar → Ajustar → Testar**. A IA pode acelerar bastante o desenvolvimento, mas o desenvolvedor deve revisar e validar o resultado antes de utilizá-lo.

4. **Limitações:** Se o prompt for muito vago, como "cria docker compose", a IA pode gerar uma configuração genérica que não atende às necessidades da aplicação. Quanto mais específico for o prompt, maior a chance de obter um resultado adequado.
