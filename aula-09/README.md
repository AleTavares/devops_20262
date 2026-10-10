# Aula 09 — Docker Registry e IA no CI/CD

## Objetivos de Aprendizagem

Ao final desta aula, o aluno será capaz de:

1. Explicar o papel de um Docker Registry no ciclo CI/CD
2. Configurar docker build e push para ghcr.io em GitHub Actions
3. Aplicar estratégias de tagging de imagens (latest, semver, SHA)
4. Autenticar no GitHub Container Registry usando GITHUB_TOKEN
5. Compreender como IA pode ser integrada em pipelines CI/CD para code review automatizado
6. Configurar um workflow que usa Bedrock/IA para analisar PRs automaticamente
7. Implementar quality gates inteligentes com feedback de IA em Pull Requests
8. Avaliar resultados de análise de IA e definir quando confiar vs revisar manualmente

---

## Contexto Narrativo

> **O Resgate da TechNova — Episódio 9: "Da Imagem Local ao Registry + O Revisor que Nunca Dorme"**

O pipeline CI da TechNova estava funcionando perfeitamente — lint, testes e build passavam em cada push. Mas na reunião de sprint, Rafael levantou um problema:

> "Pessoal, o build roda, mas a imagem Docker fica presa no runner do GitHub Actions. Quando vou fazer deploy, preciso buildar de novo no servidor. Ontem o build deu diferente em produção porque alguém atualizou uma dependência entre o CI e o deploy."

Marina, a consultora, concordou:

> "Isso é um problema clássico. Vocês precisam de um **Docker Registry** — um repositório centralizado de imagens. O CI builda, tageia e pusha a imagem. O deploy só faz pull. Mesma imagem, sempre. E o GitHub tem um registry integrado: o ghcr.io."

Mas o CTO Carlos Mendes tinha outra preocupação:

> "Ótimo, resolvemos o delivery das imagens. Mas tenho outro problema: nosso time está crescendo, e os code reviews estão levando dias. PRs ficam abertas esperando alguém revisar. Algumas passam com bugs óbvios porque o reviewer estava cansado. Preciso de um revisor que nunca cansa, nunca esquece, e funciona 24/7."

Marina sorriu:

> "Isso é a terceira aplicação de IA que vamos implementar. Na Aula 02 vocês conheceram o Kiro para desenvolvimento interativo. Na Aula 07, usaram IA para gerar infraestrutura. Agora vamos colocar IA **dentro do pipeline** — um revisor automatizado que analisa cada PR antes de qualquer humano olhar. Ele não substitui o review humano, mas pega os problemas óbvios antes."

Esse é o duplo desafio desta aula: publicar imagens Docker automaticamente no registry E implementar um revisor de código por IA que funciona 24 horas por dia, 7 dias por semana.

---

## Cronograma da Aula (~5 horas)

| Bloco | Atividade | Duração |
|:-----:|-----------|:-------:|
| 1 | Revisão TA + Discussão | 30 min |
| 2 | Conteúdo Teórico — Docker Registry + CI/CD | 50 min |
| 3 | Laboratório Parte 1 — Build e Push para ghcr.io | 120 min |
| 4 | Conteúdo Teórico — IA no CI/CD | 50 min |
| 5 | Laboratório Parte 2 — PR Review Automatizado com IA | 120 min |
| 6 | Encerramento + Orientação TF | 15 min |

---

## Conteúdo Original Consolidado

Esta aula consolida o conteúdo de:

- **Aula 16 original:** Docker Registry e Artifacts (ghcr.io, Docker Hub, ECR, tagging strategies, build+push em GitHub Actions, GITHUB_TOKEN auth, multi-stage para CI, GitHub Packages)
- **Conteúdo NOVO:** IA no CI/CD (automated PR review com Bedrock, análise de código por IA em pipelines, security scanning com IA, quality gates com feedback inteligente)

---

## Pré-requisitos

- **Conta GitHub** ativa (repositório público = Actions gratuito com minutos ilimitados)
- **Docker** instalado e funcionando (`docker --version`)
- **Node.js** instalado (≥ 18) — [Download](https://nodejs.org/)
- **Git** configurado com autenticação no GitHub (SSH ou HTTPS token)
- **Repositório `technova-api`** no GitHub com pipeline CI da Aula 08 funcionando
- **Conhecimentos das Aulas 01-08:** Git, Docker, Docker Compose, Kiro, Terraform (modules, remote state), IAM, VPC, EC2, RDS, IA para IaC, GitHub Actions (CI completo com lint/test/build, secrets, environments)

> **💡 GitHub Container Registry (ghcr.io) é GRATUITO para repositórios públicos** — armazenamento ilimitado de imagens. Todos os labs desta aula podem ser feitos sem custo algum.

---

## Conteúdo Teórico — Parte 1: Docker Registry e CI/CD

*Tempo estimado: ~50 minutos*

### 1. O Problema: Imagens que Nascem e Morrem no CI

Hoje na TechNova, o pipeline CI builda a imagem Docker para verificar que o Dockerfile funciona — mas a imagem é descartada após o job terminar:

![Problema Atual](img/rd001.png)

### 2. O que é um Docker Registry?

Um Docker Registry é um **repositório centralizado** para armazenar e distribuir imagens Docker:

![Docker Registry](img/rd002.png)

**Analogia:** O Docker Registry é como o npm para pacotes Node.js, mas para imagens Docker. Você publica (push) e consome (pull) imagens versionadas.

### 3. Opções de Registry

| Registry | Provedor | Custo (público) | Integração |
|----------|----------|:---------------:|-----------|
| **Docker Hub** | Docker Inc. | Gratuito (1 repo privado) | Universal, padrão |
| **ghcr.io** | GitHub | **Gratuito (ilimitado)** | Integrado ao GitHub |
| **Amazon ECR** | AWS | ~$0.10/GB/mês | Integrado à AWS |
| **Azure ACR** | Microsoft | ~$5/mês (Basic) | Integrado ao Azure |
| **Google Artifact Registry** | GCP | Gratuito (500MB) | Integrado ao GCP |

**Por que ghcr.io para a TechNova?**
- Gratuito para repositórios públicos (armazenamento ilimitado)
- Integrado ao GitHub (mesmo lugar do código e CI)
- Autenticação via GITHUB_TOKEN (já disponível nos workflows)
- Imagens vinculadas ao repositório (visíveis na aba Packages)
- Permissões controladas pelo mesmo sistema do repositório

### 4. Estratégias de Tagging

Tags identificam versões de uma imagem. Existem três estratégias principais:

![Estratégia de Tagging](img/rd003.png)

### 5. Multi-Stage Build Otimizado para CI

Multi-stage builds criam imagens menores separando o build do runtime:

```dockerfile
# Estágio 1: Build (instalação de dependências)
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Estágio 2: Runtime (imagem final pequena)
FROM node:20-alpine AS runtime
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && adduser -S technova -u 1001
COPY --from=builder /app/node_modules ./node_modules
COPY . .
USER technova
EXPOSE 3000
CMD ["node", "server.js"]
```

**Benefícios para CI:**
- Imagem final menor (sem devDependencies, sem cache do npm)
- Build mais rápido (layers cacheadas)
- Mais seguro (menos superfície de ataque)

### 6. Build e Push em GitHub Actions

O workflow completo para buildar e publicar no ghcr.io:

```yaml
name: Build and Push

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Login no ghcr.io
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extrair metadata (tags)
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=sha
            type=raw,value=latest,enable={{is_default_branch}}
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}

      - name: Build e Push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

**Actions usadas:**

| Action | Função |
|--------|--------|
| `docker/login-action@v3` | Autentica no registry (ghcr.io) |
| `docker/metadata-action@v5` | Gera tags automaticamente (SHA, semver, latest) |
| `docker/build-push-action@v5` | Builda e pusha a imagem em um step |

### 7. Autenticação com GITHUB_TOKEN

O `GITHUB_TOKEN` é gerado automaticamente em cada workflow e pode autenticar no ghcr.io:

```yaml
permissions:
  contents: read     # Ler código do repositório
  packages: write    # Publicar imagens no ghcr.io
```

**Por que GITHUB_TOKEN e não um Personal Access Token (PAT)?**
- Não precisa criar/gerenciar tokens manualmente
- Escopo limitado ao repositório (princípio de menor privilégio)
- Expira automaticamente após o workflow
- Sem risco de vazamento de token pessoal

### 8. Ciclo de Vida da Imagem
![Ciclo Completo](img/rd004.png)
### 9. Visualizando Imagens no GitHub Packages

Após o push, as imagens aparecem na aba **Packages** do repositório:

- URL: `https://github.com/USER/REPO/pkgs/container/REPO`
- Mostra: todas as tags, tamanho, data de publicação
- Permite: pull direto, ver layers, deletar versões antigas

---

## Conteúdo Teórico — Parte 2: IA no CI/CD

*Tempo estimado: ~50 minutos*

### 1. A Evolução da IA no Curso

Esta é a **terceira aplicação de IA** no curso, com complexidade crescente:

![Jornada da IA](img/rd005.png)

### 2. Por que IA no CI/CD?

**Problemas que IA resolve no code review:**

| Problema Humano | Solução com IA |
|----------------|----------------|
| Reviews demoram dias | IA responde em segundos/minutos |
| Reviewer cansado perde bugs | IA mantém consistência 24/7 |
| Conhecimento desigual no time | IA aplica mesmos padrões para todos |
| PRs grandes intimidam | IA analisa qualquer tamanho sem reclamar |
| Padrões de segurança esquecidos | IA verifica checklist completo sempre |
| Feedback inconsistente | IA segue o mesmo prompt/critérios |

**O que IA NÃO substitui:**
- Decisões de arquitetura
- Contexto de negócio
- Revisão de lógica complexa
- Aprovação final de merge

### 3. Casos de Uso de IA em Pipelines

![IA no CI/CD](img/rd006.png)

### 4. Arquitetura: IA no Pipeline

![AI Review](img/rd007.png)
### 5. AWS Bedrock no CI/CD

Na Aula 07, conhecemos o Bedrock para geração de IaC. No CI/CD, o fluxo é:

![Fluxo de Integração e Análise](img/rd008.png)

**Alternativas para quem não tem acesso a Bedrock:**
- GitHub Actions de terceiros (ex: `ai-pr-reviewer`)
- Script local com Kiro para gerar o workflow
- Abordagem conceitual (entender o fluxo, implementar quando tiver acesso)

### 6. Limitações e Considerações

| Aspecto | Consideração |
|---------|-------------|
| **Custo** | Bedrock cobra por token; PRs grandes = mais tokens |
| **Latência** | IA leva 10-60 segundos para responder |
| **Falsos positivos** | IA pode apontar problemas que não existem |
| **Falsos negativos** | IA pode perder bugs sutis de lógica |
| **Contexto limitado** | IA vê apenas o diff, não o projeto inteiro |
| **Complementar** | Sempre combine com review humano |

### 7. Quando IA Agrega Mais Valor no Review

- PRs grandes (>500 linhas) — humanos perdem atenção
- Código de infraestrutura (Terraform, Docker) — padrões de segurança
- Código de segurança (auth, crypto) — checklist extenso
- PRs de novos contribuidores — padronização
- Horários fora do expediente — feedback imediato

---

## Resumo dos Conceitos

| Conceito | Descrição |
|----------|-----------|
| Docker Registry | Repositório centralizado para imagens Docker |
| ghcr.io | GitHub Container Registry (gratuito para repos públicos) |
| Tag: latest | Aponta para build mais recente (evitar em prod) |
| Tag: semver | Versionamento semântico (v1.2.3) para releases |
| Tag: SHA | Hash do commit (rastreabilidade total) |
| docker/login-action | Action para autenticar no registry |
| docker/metadata-action | Action para gerar tags automaticamente |
| docker/build-push-action | Action para build + push em um step |
| Multi-stage build | Dockerfile otimizado (build separado do runtime) |
| GITHUB_TOKEN + packages:write | Permissão para publicar no ghcr.io |
| GitHub Packages | Aba do repositório que mostra imagens publicadas |
| AI PR Review | IA que analisa PRs automaticamente no pipeline |
| Quality Gate | Regra que bloqueia/permite merge baseado em análise |
| Bedrock no CI/CD | AWS Bedrock invocado via Lambda em workflows |
| Prompt de review | Instruções que dizem à IA o que verificar |
| Severidade (CRITICAL/WARNING/INFO) | Classificação dos achados da IA |

---

## Custo — Docker Registry e IA

| Serviço | Custo (repo público) |
|---------|:-------------------:|
| ghcr.io (armazenamento) | **$0.00** (ilimitado) |
| ghcr.io (transferência) | **$0.00** (ilimitado) |
| GitHub Actions (minutos) | **$0.00** (ilimitado) |
| Bedrock (se usado) | ~$0.003/1K tokens input |
| AI Review Actions (terceiros) | Varia (muitos gratuitos) |

> **💡 Todos os labs desta aula podem ser feitos com custo ZERO usando ghcr.io e actions gratuitas.**

---

*Próximas etapas: Laboratório Parte 1 (Build e Push para ghcr.io) → Laboratório Parte 2 (PR Review com IA) → TF (Trabalho de Fixação)*
