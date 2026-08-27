# Trabalho em Aula — Aula 02: Docker Compose e IA como Copiloto

**Aluno:** Renan Dias  
**RA:** 6325033  
**Data:** 23/08/2026

## Parte 1 — Análise do Problema Multi-Container

### Problemas do Rafael (com classificação)

| #   | Problema                                                                         | Classificação |
| --- | -------------------------------------------------------------------------------- | ------------- |
| 1   | É necessário executar 4 comandos complexos para iniciar os serviços manualmente. | 🟡 Moderado   |
| 2   | Ninguém lembra a ordem correta para iniciar os serviços e suas dependências.     | 🟡 Moderado   |
| 3   | As senhas e configurações ficam espalhadas entre diferentes comandos e arquivos. | 🔴 Crítico    |
| 4   | Os dados podem ser perdidos quando os containers são removidos ou recriados.     | 🔴 Crítico    |
| 5   | Novos desenvolvedores têm dificuldade para configurar o ambiente corretamente.   | 🟡 Moderado   |

### Design da Solução

| Problema do Rafael     | Recurso do Docker Compose que resolve                                                             |
| ---------------------- | ------------------------------------------------------------------------------------------------- |
| 4 comandos complexos   | Um único arquivo `docker-compose.yml` permite iniciar os serviços com `docker compose up`.        |
| Ninguém lembra a ordem | `depends_on` permite declarar as dependências entre os serviços.                                  |
| Senhas espalhadas      | Variáveis de ambiente e arquivo `.env` centralizam as configurações sensíveis.                    |
| Dados se perdem        | Volumes nomeados permitem persistir os dados do PostgreSQL mesmo quando o container é recriado.   |
| Novos devs sofrem      | O `docker-compose.yml` padroniza o ambiente e facilita a configuração para novos desenvolvedores. |

### Arquitetura proposta

A solução utiliza três containers principais:

- **API Node.js + Express:** executa a aplicação na porta 3000.
- **PostgreSQL 15:** armazena os dados da aplicação.
- **Redis 7:** fornece o serviço de cache.

Os serviços são conectados por uma rede bridge customizada chamada `app-network`.

O PostgreSQL utiliza um volume nomeado para garantir a persistência dos dados.

A API depende do PostgreSQL e do Redis para funcionar corretamente.

---

## Parte 2 — Observações sobre a Demonstração do Kiro

### O que o Kiro gerou corretamente?

- Estrutura básica do `docker-compose.yml`.
- Definição dos serviços.
- Configuração da API Node.js.
- Configuração do PostgreSQL.
- Exposição da porta da API.
- Rede customizada.
- Volume nomeado para persistência do PostgreSQL.
- Relacionamento entre os serviços utilizando `depends_on`.

### O que precisou de ajuste?

- Conferência das versões das imagens utilizadas.
- Ajuste das variáveis de ambiente necessárias para a aplicação.
- Configuração correta das variáveis do PostgreSQL e Redis.
- Separação das configurações sensíveis utilizando `.env`.
- Inclusão de `.env.example` para documentar as variáveis necessárias sem expor a senha real.
- Inclusão de healthchecks para verificar a disponibilidade dos serviços.
- Configuração de restart policies para aumentar a resiliência dos containers.

### O que a IA não fez mas deveria?

A IA poderia ter incluído desde o início:

- Um arquivo `.env` separado para as configurações do ambiente.
- Um `.env.example` sem informações sensíveis.
- Healthchecks para os serviços.
- Restart policies.
- Validação das dependências entre os serviços.
- Boas práticas para evitar senhas diretamente no `docker-compose.yml`.

---

## Discussão — respostas

### 1. Velocidade vs Qualidade

O Kiro consegue gerar uma configuração inicial muito mais rapidamente do que escrever todo o arquivo manualmente. Porém, a velocidade não garante que a configuração esteja correta ou adequada ao projeto. Por isso, o resultado gerado pela IA precisa ser revisado, ajustado e testado antes de ser utilizado.

### 2. Quando confiar

Eu confiaria inicialmente na estrutura básica gerada, como a declaração dos serviços, redes e volumes, mas faria uma verificação extra nas variáveis de ambiente, portas, versões das imagens, dependências, persistência dos dados e configurações de segurança.

### 3. Cenário real — workflow ideal

O fluxo ideal seria:

**Gerar → Revisar → Ajustar → Testar → Validar**

A IA pode acelerar a criação da configuração, mas a responsabilidade pela configuração final continua sendo do desenvolvedor. Depois de gerar o arquivo, é necessário revisar o conteúdo, adaptar ao projeto, executar os containers e verificar se os serviços estão funcionando corretamente.

### 4. Limitações

Se o prompt for muito vago, como apenas "cria docker compose", a IA pode gerar uma configuração genérica que não atende às necessidades do projeto. Quanto mais informações forem fornecidas no prompt, como serviços, versões, portas, volumes, redes, variáveis de ambiente e dependências, maior será a chance de obter um resultado adequado.
