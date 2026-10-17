# Aula 09 — Docker Registry e IA no CI/CD

## Objetivos de Aprendizagem

Ao final desta aula, o aluno será capaz de:

1. Explicar o papel de um Docker Registry no ciclo CI/CD
2. Criar um repositório no **Amazon ECR** e publicar imagens usando o **AWS Academy Learner Lab**
3. Aplicar estratégias de tagging de imagens (latest, semver, SHA)
4. Autenticar o Docker no ECR com credenciais temporárias (`aws ecr get-login-password`)
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

> "Isso é um problema clássico. Vocês precisam de um **Docker Registry** — um repositório centralizado de imagens. O CI (ou um script) builda, tageia e pusha a imagem. O deploy só faz pull. Mesma imagem, sempre. E como a infra de vocês roda na AWS, o registry natural é o **Amazon ECR** — vamos usá-lo direto no **AWS Academy Learner Lab**."

Mas o CTO Carlos Mendes tinha outra preocupação:

> "Ótimo, resolvemos o delivery das imagens. Mas tenho outro problema: nosso time está crescendo, e os code reviews estão levando dias. PRs ficam abertas esperando alguém revisar. Algumas passam com bugs óbvios porque o reviewer estava cansado. Preciso de um revisor que nunca cansa, nunca esquece, e funciona 24/7."

Marina sorriu:

> "Isso é a terceira aplicação de IA que vamos implementar. Na Aula 02 vocês conheceram o Kiro para desenvolvimento interativo. Na Aula 07, usaram IA para gerar infraestrutura. Agora vamos colocar IA **dentro do pipeline** — um revisor automatizado que analisa cada PR antes de qualquer humano olhar. Ele não substitui o review humano, mas pega os problemas óbvios antes."

Esse é o duplo desafio desta aula: publicar imagens Docker automaticamente no registry E implementar um revisor de código por IA que funciona 24 horas por dia, 7 dias por semana.

---

## Cronograma da Aula

| Bloco | Atividade |
|:-----:|-----------|
| 1 | Revisão TA + Discussão |
| 2 | Conteúdo Teórico — Docker Registry + CI/CD |
| 3 | Laboratório Parte 1 — Build e Push para o Amazon ECR (Learner Lab) |
| 4 | Conteúdo Teórico — IA no CI/CD |
| 5 | Laboratório Parte 2 — PR Review Automatizado com IA |
| 6 | Encerramento + Orientação TF |

---

## Pré-requisitos

- **Conta GitHub** ativa (repositório público = Actions gratuito com minutos ilimitados)
- **Acesso ao AWS Academy Learner Lab** com a sessão iniciada (credenciais temporárias ativas)
- **AWS CLI v2** instalada e configurada com as credenciais do Lab (`aws sts get-caller-identity` funcionando, região `us-east-1`)
- **Docker** instalado e funcionando (`docker --version`)
- **Node.js** instalado (≥ 18) — [Download](https://nodejs.org/)
- **Git** configurado com autenticação no GitHub (SSH ou HTTPS token)
- **Repositório `technova-api`** no GitHub com pipeline CI da Aula 08 funcionando
- **Conhecimentos das Aulas 01-08:** Git, Docker, Docker Compose, Kiro, Terraform (modules, remote state), IAM, VPC, EC2, RDS, IA para IaC, GitHub Actions (CI completo com lint/test/build, secrets, environments)

> **☁️ AWS Academy Learner Lab:** as credenciais da sessão incluem `aws_session_token` e **expiram quando o Lab encerra** — recarregue-as ao reabrir. Trabalhe sempre em `us-east-1`. O Lab **não permite criar usuários/grupos/roles IAM**, mas **permite criar repositórios ECR**. O armazenamento no ECR tem custo baixo (~$0.10/GB/mês), coberto pelos créditos do Lab para imagens pequenas.

---

## Conteúdo Teórico — Parte 1: Docker Registry e CI/CD

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
| **Amazon ECR** | AWS | ~$0.10/GB/mês | Integrado à AWS (**nosso caso**) |
| **Azure ACR** | Microsoft | ~$5/mês (Basic) | Integrado ao Azure |
| **Google Artifact Registry** | GCP | Gratuito (500MB) | Integrado ao GCP |

**Por que Amazon ECR para a TechNova?**
- Mesmo ecossistema AWS do **Learner Lab** — a imagem fica ao lado de onde vai rodar (EC2/ECS/EKS)
- Registry **privado** por padrão, com controle de acesso pela própria conta AWS
- **Scan de vulnerabilidades** integrado (opcional, no push)
- Prepara o aluno para o cenário real de empresas que rodam na AWS

> **☁️ Regras do Learner Lab (valem para toda a Parte 1):**
> 1. Credenciais **temporárias** (com `aws_session_token`) que expiram por sessão
> 2. Região fixa **`us-east-1`**
> 3. **Sem IAM** (não cria user/group/role) — autenticação usa as credenciais da sessão; **mas pode criar repositórios ECR**

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

### 6. Build e Push para o ECR (fluxo principal: `ecr-push.sh`)

Como o Learner Lab usa credenciais temporárias e não permite OIDC/roles IAM, o fluxo confiável é um **script local** executado com as credenciais da sessão. São três passos:

```bash
# 1. Criar o repositório ECR (uma vez; o Lab permite criar ECR)
aws ecr create-repository --repository-name technova-api --region us-east-1

# 2. Autenticar o Docker no ECR (token temporário, usuário sempre "AWS")
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$REGISTRY"

# 3. Build, tag (sha + latest) e push
docker build -t technova-api aula-09/technova-api
SHA=$(git rev-parse --short HEAD)
docker tag technova-api "$REGISTRY/technova-api:sha-$SHA"
docker tag technova-api "$REGISTRY/technova-api:latest"
docker push "$REGISTRY/technova-api:sha-$SHA"
docker push "$REGISTRY/technova-api:latest"
```

No laboratório, esses passos são empacotados num `ecr-push.sh` reutilizável.

### 7. CI opcional com `amazon-ecr-login`

Dá para publicar no ECR a partir do GitHub Actions usando as actions oficiais da AWS:

```yaml
jobs:
  build-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}   # Learner Lab exige
          aws-region: us-east-1
      - id: ecr
        uses: aws-actions/amazon-ecr-login@v2
      - uses: docker/build-push-action@v5
        with:
          context: aula-09/technova-api
          push: true
          tags: ${{ steps.ecr.outputs.registry }}/technova-api:latest
```

> **⚠️ Limitação do Learner Lab:** as 3 credenciais (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`) são **temporárias** e precisam ser atualizadas como secrets a cada nova sessão do Lab. Por isso o `ecr-push.sh` local é o fluxo recomendado; o CI fica como exercício opcional. Em produção real (fora do Lab), o correto é **OIDC + role IAM**, sem secrets de longa duração.

### 8. Ciclo de Vida da Imagem
![Ciclo Completo](img/rd004.png)
### 9. Visualizando Imagens no Console do ECR

Após o push, as imagens aparecem no **console do Amazon ECR** (Elastic Container Registry → Repositories → `technova-api`):

- Mostra: todas as tags (`sha-...`, `latest`, semver), tamanho e data de push
- Exibe o resultado do **scan de vulnerabilidades**, se habilitado no repositório
- Permite pull por tag (após `docker login`) e aplicar lifecycle policies para limpar imagens antigas

---

## Conteúdo Teórico — Parte 2: IA no CI/CD

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

Na Aula 07, conhecemos o Bedrock para geração de IaC. No CI/CD, o fluxo **de produção** é:

![Fluxo de Integração e Análise](img/rd008.png)

> **☁️ No Learner Lab:** o padrão de produção usa **OIDC + role IAM** para o Actions assumir — o que o Lab **não permite**. Para exercitar o Bedrock dentro do Lab, invoque-o de um script com as credenciais temporárias da sessão (`us-east-1`), como na Aula 07.

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
| Amazon ECR | Registry da AWS, privado; host inclui Account ID + região |
| AWS Academy Learner Lab | Credenciais temporárias, `us-east-1`, sem IAM, mas permite ECR |
| `aws ecr get-login-password` | Gera token temporário p/ `docker login` (usuário `AWS`) |
| `ecr-push.sh` | Script: cria repo, autentica, build e push no ECR |
| Tag: latest | Aponta para build mais recente (evitar em prod) |
| Tag: semver | Versionamento semântico (v1.2.3) para releases |
| Tag: SHA | Hash do commit (rastreabilidade total) |
| Multi-stage build | Dockerfile otimizado (build separado do runtime) |
| `amazon-ecr-login` | Action da AWS p/ login no ECR no CI (opcional, secrets temporários) |
| Console do ECR | Onde as imagens publicadas e suas tags aparecem |
| AI PR Review | IA que analisa PRs automaticamente no pipeline |
| Quality Gate | Regra que bloqueia/permite merge baseado em análise |
| Bedrock no CI/CD | AWS Bedrock invocado via Lambda/script em workflows |
| Prompt de review | Instruções que dizem à IA o que verificar |
| Severidade (CRITICAL/WARNING/INFO) | Classificação dos achados da IA |

---

## Custo — Docker Registry e IA

| Serviço | Custo |
|---------|:-------------------:|
| Amazon ECR (armazenamento) | ~$0.10/GB/mês (imagens pequenas = centavos, cobertos pelos créditos do Lab) |
| Amazon ECR (transferência interna AWS) | **$0.00** |
| GitHub Actions (minutos, repo público) | **$0.00** (ilimitado) |
| Bedrock (se usado) | ~$0.003/1K tokens input |
| AI Review Actions (terceiros) | Varia (muitos gratuitos) |

> **💡 No AWS Academy Learner Lab os custos do ECR são cobertos pelos créditos do Lab.** A análise de IA do laboratório usa pattern matching (custo zero); o Bedrock é opcional.

---

*Próximas etapas: Laboratório Parte 1 (Build e Push para o Amazon ECR no Learner Lab) → Laboratório Parte 2 (PR Review com IA) → TF (Trabalho de Fixação)*
