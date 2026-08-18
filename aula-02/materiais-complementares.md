# Materiais Complementares — Aula 02: Docker Compose e IA no DevOps

---

## Parte 1 — Docker Compose

### Documentação Oficial

- **[Docker Compose Overview](https://docs.docker.com/compose/)** — Documentação oficial e introdução ao Compose
- **[Compose File Reference](https://docs.docker.com/compose/compose-file/)** — Referência completa de todas as opções do `docker-compose.yml`
- **[Docker Compose CLI Reference](https://docs.docker.com/compose/reference/)** — Todos os comandos disponíveis (`up`, `down`, `logs`, etc.)
- **[Networking in Compose](https://docs.docker.com/compose/networking/)** — Como redes funcionam no Docker Compose
- **[Volumes in Compose](https://docs.docker.com/compose/compose-file/07-volumes/)** — Configuração de volumes para persistência
- **[Environment Variables in Compose](https://docs.docker.com/compose/environment-variables/)** — Guia completo sobre variáveis de ambiente
- **[Startup Order / depends_on](https://docs.docker.com/compose/startup-order/)** — Ordem de inicialização e healthchecks

### YAML

- **[Learn YAML in Y Minutes](https://learnxinyminutes.com/docs/yaml/)** — Guia rápido de sintaxe YAML
- **[YAML Lint](http://www.yamllint.com/)** — Validador online de YAML (útil para debugar erros de indentação)
- **[YAML Quick Reference](https://quickref.me/yaml.html)** — Referência rápida de sintaxe

### PostgreSQL com Docker

- **[PostgreSQL no Docker Hub](https://hub.docker.com/_/postgres)** — Imagem oficial com documentação de variáveis de ambiente
- **[Redis no Docker Hub](https://hub.docker.com/_/redis)** — Imagem oficial do Redis

### Vídeos — Docker Compose

#### Em Português

| Vídeo | Canal | Duração | Descrição |
|-------|-------|---------|-----------|
| [Docker Compose Tutorial](https://www.youtube.com/watch?v=HxPz3eLnXZk) | Full Cycle | ~40 min | Tutorial completo de Docker Compose com exemplos práticos |
| [Docker Compose do Zero](https://www.youtube.com/watch?v=yb2udL9GG2U) | Rocketseat | ~25 min | Introdução prática ao Docker Compose |
| [Ambiente de Dev com Docker Compose](https://www.youtube.com/watch?v=4EGWMhSdG8Q) | Código Fonte TV | ~20 min | Configuração de ambiente de desenvolvimento |
| [Docker Compose com Node.js e PostgreSQL](https://www.youtube.com/watch?v=AVNADGzXrrQ) | Programador a Bordo | ~30 min | Exatamente o cenário desta aula |

#### Em Inglês (com legendas)

| Vídeo | Canal | Duração | Descrição |
|-------|-------|---------|-----------|
| [Docker Compose in 12 Minutes](https://www.youtube.com/watch?v=Qw9zlE3t8Ko) | Jake Wright | ~12 min | Explicação concisa e visual do Docker Compose |
| [Docker Compose Tutorial](https://www.youtube.com/watch?v=SXwC9fSwct8) | Programming with Mosh | ~30 min | Tutorial passo a passo com Node.js |
| [Docker Networking](https://www.youtube.com/watch?v=bKFMS5C4CG0) | NetworkChuck | ~20 min | Entendendo redes Docker em detalhes |
| [Docker Volumes Explained](https://www.youtube.com/watch?v=p2PH_YPCsis) | TechWorld with Nana | ~15 min | Volumes e persistência de dados |

### Cheat Sheets

- **[Docker Compose Cheat Sheet](https://devhints.io/docker-compose)** — Referência rápida de sintaxe do docker-compose.yml
- **[Docker Compose Commands](https://dockerlabs.collabnix.com/intermediate/docker-compose/compose-cheatsheet.html)** — Todos os comandos organizados por categoria

### Ferramentas — Docker

- **[VS Code Docker Extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)** — Autocompletar, validação e gerenciamento de Compose
- **[VS Code YAML Extension](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)** — Validação de sintaxe YAML com schemas
- **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** — Interface gráfica para visualizar containers, volumes e redes

### Clientes de Banco de Dados

- **[DBeaver](https://dbeaver.io/)** — Cliente universal de banco de dados (gratuito, conecta no PostgreSQL via Docker)
- **[pgAdmin 4](https://www.pgadmin.org/)** — Cliente oficial do PostgreSQL (também disponível como container Docker)
- **[TablePlus](https://tableplus.com/)** — Cliente moderno para múltiplos bancos (versão gratuita disponível)
- **[Redis Insight](https://redis.com/redis-enterprise/redis-insight/)** — Cliente visual para Redis (gratuito)

---

## Parte 2 — IA no DevOps e Kiro

### Kiro — Documentação e Getting Started

- **[Kiro — Site oficial](https://kiro.dev/)** — Download, documentação e primeiros passos
- **[Kiro — Getting Started Guide](https://kiro.dev/docs/)** — Guia de início rápido

### AWS Bedrock — Visão Conceitual

- **[What is Amazon Bedrock?](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html)** — Documentação oficial — o que é e como funciona
- **[Amazon Bedrock — Foundation Models](https://aws.amazon.com/bedrock/)** — Página do produto com visão geral dos modelos disponíveis
- **[AWS Bedrock Pricing](https://aws.amazon.com/bedrock/pricing/)** — Modelo de precificação (pay-per-use)

> **Nota:** Usaremos AWS Bedrock de forma prática a partir do Módulo 2. Por ora, entenda o conceito.

### Artigos — IA no DevOps

- **[AI in DevOps — A Practical Guide](https://www.atlassian.com/devops/ai-in-devops)** — Visão geral de como IA se integra ao ciclo DevOps
- **[How AI is Transforming DevOps](https://aws.amazon.com/blogs/devops/)** — Blog AWS DevOps com artigos sobre IA
- **[The Role of AI in Modern Software Development](https://github.blog/category/ai/)** — Blog do GitHub sobre IA no desenvolvimento
- **[Responsible AI Practices](https://ai.google/responsibility/responsible-ai-practices/)** — Guia do Google sobre IA responsável

### Vídeos — IA e Desenvolvimento

#### Em Português

| Vídeo | Canal | Duração | Descrição |
|-------|-------|---------|-----------|
| [IA no Desenvolvimento de Software](https://www.youtube.com/results?search_query=ia+desenvolvimento+software+2024) | Diversos | Variada | Busque conteúdos atualizados sobre IA + Dev |
| [O que é IA Generativa?](https://www.youtube.com/results?search_query=ia+generativa+explicada) | Diversos | Variada | Conceitos fundamentais de IA generativa |

#### Em Inglês

| Vídeo | Canal | Duração | Descrição |
|-------|-------|---------|-----------|
| [AI-Assisted Development](https://www.youtube.com/results?search_query=ai+assisted+development+2024) | Diversos | Variada | Como IA acelera o trabalho de desenvolvedores |
| [AWS Bedrock Introduction](https://www.youtube.com/results?search_query=aws+bedrock+introduction) | AWS | Variada | Introdução ao Amazon Bedrock |

### Guias de Prompting

- **[Prompt Engineering Guide](https://www.promptingguide.ai/)** — Guia completo de engenharia de prompts
- **[OpenAI — Best Practices for Prompting](https://platform.openai.com/docs/guides/prompt-engineering)** — Boas práticas oficiais
- **[Anthropic — Prompt Engineering](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering)** — Guia de prompting da Anthropic (criadora do Claude)

### IA Responsável

- **[AWS Responsible AI](https://aws.amazon.com/machine-learning/responsible-ai/)** — Princípios de IA responsável da AWS
- **[NIST AI Risk Management Framework](https://www.nist.gov/artificial-intelligence)** — Framework do NIST para gestão de riscos de IA
- **[EU AI Act — Resumo](https://artificialintelligenceact.eu/)** — Regulamentação europeia de IA (referência global)

---

## Parte 3 — Prática Extra (Combinando Docker Compose + IA)

Se quiser praticar mais antes da próxima aula:

### Exercício 1: Expandir o Compose com pgAdmin

Adicione o pgAdmin como serviço de administração do banco:

```yaml
pgadmin:
  image: dpage/pgadmin4
  environment:
    - PGADMIN_DEFAULT_EMAIL=admin@technova.com
    - PGADMIN_DEFAULT_PASSWORD=admin
  ports:
    - "8080:80"
  depends_on:
    - postgres
  networks:
    - technova-network
```

Use Kiro para gerar a configuração e compare com o exemplo acima.

### Exercício 2: Hot-reload com Bind Mount

Configure um bind mount para que alterações no código reflitam automaticamente:

```yaml
api:
  volumes:
    - ./src:/app/src   # Código local sincronizado com container
```

Peça ao Kiro: "Como configurar hot-reload com nodemon em um container Docker Compose?"

### Exercício 3: Compose Profiles

Explore `profiles` para separar serviços de dev dos essenciais:

```yaml
services:
  pgadmin:
    profiles:
      - debug
    # ... configuração
```

```bash
# Sobe apenas API + banco + redis
docker compose up -d

# Sobe tudo incluindo pgAdmin
docker compose --profile debug up -d
```

### Exercício 4: Desafio de Prompting

Tente gerar com Kiro:
1. Um docker-compose.yml para uma stack completa: API + PostgreSQL + Redis + Nginx (reverse proxy)
2. Um GitHub Actions workflow que faz `docker compose up` para rodar testes
3. Um script de backup do PostgreSQL rodando dentro do container

Para cada um, documente: prompt usado, resultado obtido, correções necessárias.

### Exercício 5: Comparação de IAs

Se tiver acesso a diferentes ferramentas de IA (Kiro, ChatGPT, etc.), peça o mesmo docker-compose.yml para cada uma e compare:
- Qual gerou o resultado mais completo?
- Qual seguiu mais boas práticas?
- Qual precisou de menos correções?

---

## Conexão com Próximas Aulas

| Aula | Tópico | Como esta aula se conecta |
|------|--------|---------------------------|
| Aula 03 | Terraform (IaC) | Mesmo conceito de "declarar infraestrutura em arquivo" — mas na nuvem. Kiro ajudará a gerar HCL. |
| Aula 04 | VPC e Redes AWS | As redes do Docker Compose são análogas às VPCs/subnets da AWS. |
| Aula 05 | EC2 e Compute | Containers que rodamos localmente serão deployados em instâncias EC2. |
| Aula 07+ | AWS Bedrock | Usaremos Bedrock via API para integrar IA em pipelines automatizados. |
| Aula 09 | GitHub Actions | CI pipeline fará `docker compose up` para rodar testes automatizados. |

---

## Referência Rápida: `app-technova/`

O repositório do curso contém a aplicação de referência em `app-technova/`:

```
app-technova/
├── server.js              ← API Express (referência)
├── routes/orders.js       ← CRUD de pedidos
├── package.json           ← Dependências com versões fixas
├── Dockerfile             ← Multi-stage build
├── docker-compose.yml     ← Orquestração básica
└── .env                   ← Configurações de exemplo
```

Use como base para comparar com o seu `docker-compose.yml` e entender as boas práticas aplicadas.

---

*Estes materiais complementam o conteúdo da aula. Na próxima aula, levaremos o conceito de "infraestrutura declarada em arquivo" para a nuvem com Terraform — e Kiro continuará sendo nosso copiloto.*
