# Aula 02 — Docker Compose e IA como Copiloto DevOps

## Objetivos de Aprendizagem

Ao final desta aula, o aluno será capaz de:

1. Compreender o papel do Docker Compose na orquestração de aplicações multi-container
2. Escrever um arquivo `docker-compose.yml` declarando serviços, redes, volumes e variáveis de ambiente
3. Configurar um ambiente de desenvolvimento local completo com API + banco de dados PostgreSQL
4. Utilizar volumes para persistência de dados e redes para comunicação entre containers
5. Compreender o papel da IA generativa como copiloto no fluxo de trabalho DevOps
6. Utilizar Kiro como IDE inteligente para gerar e validar configurações de infraestrutura
7. Aplicar boas práticas de prompting para obter resultados eficientes de assistentes de IA
8. Identificar casos de uso de IA ao longo do ciclo DevOps (desenvolvimento, CI/CD, monitoramento)

---

## Contexto Narrativo

> **O Resgate da TechNova — Episódio 2: "Um Container Não é Suficiente... Mas a IA Pode Ajudar"**

A containerização da API (Aula 01) foi um sucesso — agora qualquer desenvolvedor pode rodar a aplicação com `docker build` e `docker run`. O código está no Git e o ambiente está padronizado no Dockerfile. Mas um novo problema surgiu.

O backend da TechNova precisa de um **banco de dados PostgreSQL** para substituir o armazenamento em memória. Além disso, a equipe quer adicionar um **Redis** para cache no futuro. Rodar múltiplos containers manualmente ficou insustentável — são dezenas de flags, redes criadas na mão, e toda segunda-feira alguém esquece um parâmetro e tudo quebra.

Na reunião de quarta-feira, o CTO perdeu a paciência:

> "Toda vez que alguém novo entra no time, leva meio dia para subir o ambiente. Preciso de **um comando** para subir tudo. E outra coisa — ouvi falar de ferramentas de IA que aceleram a configuração de infraestrutura. Quero que a equipe explore isso também."

A líder da equipe de Platform Engineering sorriu:

> "Já temos a solução para os containers: **Docker Compose**. Um arquivo YAML que declara todos os serviços, redes e volumes. E sobre a IA — conheço o **Kiro**, um ambiente de desenvolvimento inteligente que pode nos ajudar a gerar e validar configurações. Vamos atacar os dois problemas hoje."

O desafio desta aula: transformar a orquestração manual em um `docker-compose.yml` declarativo **e** explorar como a IA pode ser nossa aliada no dia a dia de DevOps.

---

## Cronograma da Aula

| Bloco | Atividade |
|:---:|---|
| 1 | Revisão TA + Discussão |
| 2 | Conteúdo Teórico — Docker Compose |
| 3 | Laboratório Parte 1 — Docker Compose |
| 4 | Conteúdo Teórico — IA no DevOps + Kiro |
| 5 | Laboratório Parte 2 — IA como Copiloto (Spec-Driven) |
| 6 | Encerramento + Orientação TF |

---

## Pré-requisitos

Antes da aula, o aluno deve ter:

- [ ] **Docker Desktop** instalado e funcional ([download](https://www.docker.com/products/docker-desktop/))
- [ ] **Docker Compose** disponível (incluso no Docker Desktop)
- [ ] **Git** instalado e configurado (Aula 01)
- [ ] **Conta no GitHub** ativa (Aula 01)
- [ ] **VS Code** instalado ([download](https://code.visualstudio.com/))
- [ ] **Kiro** instalado ([download](https://kiro.dev/)) — ou acesso configurado conforme orientação do professor
- [ ] **Terminal** funcional (Git Bash no Windows, Terminal no macOS/Linux)
- [ ] Conceitos de Dockerfile e Docker dominados (Aula 01)

> **Verificar Docker Compose:**
> ```bash
> docker compose version
> ```
> Resultado esperado: `Docker Compose version v2.x.x`

---

## Conteúdo Teórico — Parte 1: Docker Compose

### 1. O Problema: Orquestração Manual

Com múltiplos containers (API + banco + cache), gerenciar tudo manualmente se torna insustentável:

| Containers | Comandos manuais | Pontos de falha |
|:---:|:---:|:---:|
| 1 | ~3 | Poucos |
| 2 | ~8 | Moderados |
| 3+ | ~15+ | Muitos |

Cada container adicional **multiplica** a complexidade.

### 2. O que é Docker Compose

**Definição:** Ferramenta para definir e executar aplicações multi-container usando um arquivo YAML declarativo.

**Princípios:**
- **Declarativo** — descreve o estado desejado, não os passos
- **Reproduzível** — mesmo arquivo = mesmo ambiente sempre
- **Versionável** — o arquivo vai no Git junto com o código
- **Um comando** — `docker compose up` sobe tudo

### 3. Anatomia do `docker-compose.yml`

```yaml
services:          # Containers da aplicação
  app:
    build: .
    ports: ["3000:3000"]
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]

networks:
  backend:
    driver: bridge

volumes:
  pgdata:
```

### 4. Conceitos-Chave

| Conceito | Descrição |
|----------|-----------|
| **Services** | Define cada container (build, imagem, portas, variáveis) |
| **Networks** | Comunicação entre containers (pelo nome do serviço) |
| **Volumes** | Persistência de dados entre reinicializações |
| **depends_on** | Ordem de inicialização (com `condition: service_healthy`) |
| **Healthchecks** | Verificação de que o serviço está pronto |
| `.env` | Variáveis sensíveis fora do YAML (no `.gitignore`) |

### 5. Comandos Essenciais

| Comando | Função |
|---------|--------|
| `docker compose up -d` | Cria e inicia todos os serviços |
| `docker compose down` | Para e remove containers e redes |
| `docker compose down -v` | Remove também volumes (dados!) |
| `docker compose ps` | Status dos serviços |
| `docker compose logs -f` | Logs em tempo real |
| `docker compose config` | Valida sintaxe do YAML |

### 6. Boas Práticas

- Usar `.env` para variáveis sensíveis — nunca hardcode
- Definir `restart: unless-stopped` para resiliência
- Especificar versões de imagens — nunca `latest` em produção
- Usar `depends_on` com `condition: service_healthy`
- `.env` no `.gitignore` — fornecer `.env.example`

---

## Conteúdo Teórico — Parte 2: Spec-Driven Development e IA no DevOps

### 1. IA como Copiloto, Não Substituto

| IA faz bem | IA não substitui |
|-----------|-----------------|
| Gerar rascunhos de configuração | Decisões de arquitetura |
| Identificar padrões em logs | Entendimento do contexto |
| Sugerir otimizações | Julgamento sobre trade-offs |
| Acelerar tarefas repetitivas | Validação final de segurança |

### 2. Spec-Driven Development — O Conceito

Um workflow onde a IA **pensa antes de agir** — e você controla cada etapa:

| Etapa | O que acontece | Você faz |
|---|---|---|
| **1. Requisitos** | Kiro documenta o que o sistema deve fazer | Revisa e corrige |
| **2. Design** | Kiro propõe arquitetura e estrutura | Aprova ou ajusta |
| **3. Tarefas** | Kiro gera lista ordenada de implementação | Valida a ordem |
| **4. Código** | Kiro executa as tarefas e gera arquivos | Revisa cada mudança |

### 3. Spec vs. Vibe (chat livre)

| | Chat / Vibe | Spec-Driven |
|---|---|---|
| **Início** | Prompt direto | Descrição do que quer construir |
| **Processo** | IA responde imediatamente | Requisitos → Design → Tarefas → Código |
| **Controle** | Você revisa o resultado final | Você aprova cada etapa |
| **Rastreabilidade** | Conversa descartável | Documentação gerada automaticamente |

### 4. IA Responsável — Limitações

- **Alucinações:** IA pode gerar configurações que parecem corretas mas têm erros
- **Desatualização:** Pode sugerir práticas de versões antigas
- **Contexto limitado:** Não conhece restrições de segurança do seu projeto
- **Segurança:** Nunca compartilhe senhas ou tokens em prompts

**Checklist de validação:**
1. Sintaxe está correta? (`docker compose config`)
2. Imagens referenciadas existem?
3. Senhas hardcoded? (deve usar `.env`)
4. Healthchecks configurados?
5. Funciona quando você executa?

### 5. AWS Bedrock — Visão Conceitual

Serviço gerenciado da AWS para acessar modelos de IA generativa via API. Será explorado em aulas futuras quando integrarmos IA diretamente em pipelines de automação.

---

## Entrega do Trabalho em Aula

O trabalho em aula vale **1 ponto na nota final** do semestre (contabilizado apenas ao final, com todos os trabalhos entregues).

### Onde entregar

Na **mesma pasta** da entrega do TF, no fork da disciplina:

```
entregas/aula-02/SEU-RA/trabalho-em-aula.md
```

### O que entregar

Um arquivo `trabalho-em-aula.md` com as respostas das atividades realizadas em sala (discussões, análises, tabelas preenchidas).

### Observações

- A entrega é **individual** — mesmo que a atividade tenha sido em grupo
- O arquivo pode ser adicionado no **mesmo PR** do TF ou em PR separado
- Entregas parciais (apenas algumas aulas) **não garantem o ponto**

---

## Entrega do Trabalho de Fixação (TF)

O TF desta aula deve ser desenvolvido no **seu repositório pessoal** (`unifaat-devops-portfolio`, pasta `aula-02/`). A entrega neste repositório da disciplina consiste em um **arquivo Markdown (`entrega.md`)** contendo o **link para o seu repositório** e as evidências solicitadas.

### Passo a Passo

1. **Desenvolva o TF** no seu repositório pessoal (`unifaat-devops-portfolio/aula-02/`)
2. Faça **fork** do repositório da disciplina (se ainda não fez)
3. Crie uma **branch**: `SEU-RA/tf-02`
4. Crie a pasta `entregas/aula-02/SEU-RA/`
5. Adicione o arquivo **`entrega.md`** com o link do seu repositório + evidências
6. Faça commits descritivos seguindo [Conventional Commits](https://www.conventionalcommits.org/pt-br/)
7. Abra um **Pull Request** para o repositório original com título: `[Aula 02] RA: XXXXX - Nome Completo`

### Modelo do arquivo `entrega.md`

```markdown
# Entrega — Aula 02: Docker Compose + IA como Copiloto

**Aluno:** [Seu nome completo]  
**RA:** [Seu RA]  
**Data:** [Data da entrega]

## Repositório

- URL: https://github.com/SEU-USUARIO/unifaat-devops-portfolio

## Evidências

- [ ] `docker-compose.yml` com 3 serviços (API + PostgreSQL + Redis)
- [ ] Volume nomeado configurado para PostgreSQL
- [ ] Rede customizada conectando todos os serviços
- [ ] Healthchecks configurados
- [ ] Variáveis de ambiente via `.env` (não hardcoded)
- [ ] `ia-analise.md` preenchido com reflexão crítica

## Evidência do Ambiente Rodando

[Cole aqui o output do `docker compose ps` ou screenshot]
```

> **Importante:** O repositório pessoal do aluno deve estar **público** para que o professor consiga avaliar. PRs que não contenham o link para o repositório ou cujo repositório esteja privado serão considerados **incompletos**.

Para detalhes completos sobre os entregáveis e critérios de avaliação, consulte o arquivo [`TF.md`](TF.md).

---

## Estrutura de Arquivos desta Aula

| Arquivo | Descrição |
|---------|-----------|
| `README.md` | Este arquivo — visão geral da aula |
| `TA.md` | Trabalho Anterior — leitura prévia obrigatória |
| `trabalho-em-aula.md` | Atividade de discussão e demonstração em sala |
| `laboratorio-parte1.md` | Laboratório hands-on de Docker Compose |
| `laboratorio-parte2.md` | Laboratório hands-on de IA como Copiloto |
| `TF.md` | Trabalho de Fixação — entrega semanal via PR |
| `materiais-complementares.md` | Recursos adicionais para aprofundamento |

---

## Conexão com o Módulo

| Aula | Problema Resolvido | Artefato Principal |
|------|-------------------|----------|
| Aula 01 | Código se perdia + "funciona na minha máquina" | `.git/` + `Dockerfile` |
| **Aula 02** | **Orquestração manual + produtividade com IA** | **`docker-compose.yml` + workflow com Kiro** |

Ao final desta aula, a TechNova terá:

- ✅ Código versionado e rastreável (Git)
- ✅ Ambiente isolado e reproduzível (Docker)
- ✅ Infraestrutura local declarativa e automatizada (Docker Compose)
- ✅ Fluxo de trabalho assistido por IA (Kiro)

---

*Próxima etapa: Leitura do TA.md (Trabalho Anterior) como preparação para a aula.*
