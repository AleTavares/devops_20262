# Aula 09 — Laboratório Parte 1: Build e Push para o Amazon ECR

## Missão

Automatizar o build e a publicação da imagem Docker da TechNova API no **Amazon Elastic Container Registry (ECR)**, usando o **AWS Academy Learner Lab**. Ao final deste laboratório, você vai buildar, tagear e publicar a imagem no ECR — pronta para pull em qualquer servidor (EC2/ECS) do Lab.

**Resultado final:**
- Dockerfile multi-stage otimizado para produção
- Repositório ECR criado (`technova-api`)
- Imagens publicadas no ECR com tags SHA + latest + semver
- Build+push automatizado (local via script e, opcionalmente, no CI)
- Pull e rollback usando tags do registry

> **⚙️ Ambiente — AWS Academy Learner Lab:** usamos o Learner Lab (não conta AWS pessoal). As credenciais são **temporárias** (incluem **Session Token**) e **expiram entre sessões** — sempre reinicie o Lab e recopie as credenciais. Região sempre **`us-east-1`**. O Lab **não permite criar IAM users/groups/roles** — mas **permite criar repositórios ECR** e fazer push/pull com as credenciais da sessão. Nada de custo adicional dentro do Lab.

---

## Pré-requisitos

- [ ] Acesso ao **AWS Academy Learner Lab** (fornecido pelo professor)
- [ ] **AWS CLI** instalado (`aws --version`)
- [ ] Repositório `unifaat-devops-portfolio` (público) com o pipeline CI da Aula 08
- [ ] Pasta `aula-08/technova-api/` já no portfólio (a Aula 09 reaproveita essa API)
- [ ] Docker instalado localmente (`docker --version`)
- [ ] Node.js ≥ 18 (`node --version`)
- [ ] Git configurado com autenticação no GitHub

> **📦 Reaproveitando a TechNova API.** A API usada aqui é a mesma da Aula 08
> (pasta `technova-api/`, disponível na raiz do repositório da disciplina). Nesta
> aula o trabalho fica em `aula-09/`. Copie a pasta para `aula-09/` para começar
> sem recriar os arquivos:
>
> ```bash
> # a partir da raiz do seu unifaat-devops-portfolio
> mkdir -p aula-09
> cp -r /caminho/para/devops_20262/technova-api aula-09/technova-api
> cd aula-09/technova-api
> npm install            # recria node_modules e mantém o package-lock.json
> ```
>
> Os comandos deste laboratório assumem que você está dentro de
> `aula-09/technova-api/` (onde ficam `Dockerfile`, `package.json`, `server.js`).

---

## Parte 1 — ECR e Autenticação no Learner Lab

### 1.1 O que é o Amazon ECR?

O **Amazon ECR** é o registry de containers gerenciado da AWS:
- **URL:** `<ACCOUNT_ID>.dkr.ecr.<REGIAO>.amazonaws.com/IMAGEM:TAG`
- **Privado por padrão:** só quem tem credencial AWS da conta acessa
- **Integrado à AWS:** EC2, ECS e EKS puxam imagens direto do ECR
- **Auth:** via `aws ecr get-login-password` (token temporário de 12h)

No Learner Lab, o ECR é a escolha natural: as imagens ficam na **mesma conta AWS** onde você provisiona EC2/RDS (como fez nas aulas de Terraform), prontas para o deploy do Módulo 4.

### 1.2 Carregar as credenciais do Learner Lab

> As credenciais do Learner Lab são **temporárias** e mudam a cada sessão. Inclui `aws_session_token` — obrigatório.

1. Acesse o **AWS Academy** → curso → **Modules → Learner Lab**
2. Clique em **Start Lab** e aguarde o indicador ficar **verde** (🟢)
3. Clique em **AWS Details → AWS CLI → Show** e copie o bloco de credenciais

Cole o bloco no arquivo `~/.aws/credentials` (substituindo o conteúdo do profile `default`):

```ini
[default]
aws_access_key_id=ASIA_SUA_KEY_AQUI
aws_secret_access_key=SUA_SECRET_AQUI
aws_session_token=SEU_TOKEN_AQUI
```

Defina a região padrão e confirme que a sessão está ativa:

```bash
export AWS_DEFAULT_REGION=us-east-1
aws sts get-caller-identity
```

Resultado esperado (um role temporário do Academy, ex.: `voclabs`):

```json
{
  "UserId": "AROA...:user...",
  "Account": "123456789012",
  "Arn": "arn:aws:sts::123456789012:assumed-role/voclabs/user..."
}
```

> **Se der `ExpiredToken` ou `InvalidClientTokenId`:** a sessão expirou. Volte ao Academy, clique em **Start Lab** e recopie as credenciais.

Guarde o **Account ID** (os 12 dígitos em `Account`) — vamos usá-lo na URL do ECR.

### 1.3 Entendendo a nomenclatura (ECR)

![Anatomia de uma Imagem Docker](img/tf001.png)


Diferente do ghcr.io (onde o host é fixo `ghcr.io`), no ECR **o host inclui o seu Account ID e a região** — ele aponta para a sua conta AWS.

---

## Parte 2 — Dockerfile Multi-Stage para Produção

### 2.1 Por que multi-stage?

Nosso Dockerfile atual pode ter problemas para produção:
- Inclui devDependencies (ESLint, Jest) — desnecessários em runtime
- Imagem grande (mais tempo de push/pull, mais superfície de ataque)
- Roda como root (risco de segurança)

### 2.2 Otimizar o Dockerfile

A pasta `technova-api/` que você copiou já tem um `Dockerfile` multi-stage funcional
(da Aula 08). Agora vamos **evoluí-lo** para produção: adicionar labels OCI, um
usuário não-root nomeado e um HEALTHCHECK. Substitua o conteúdo de
`aula-09/technova-api/Dockerfile` por:

```dockerfile
# ============================================
# Estágio 1: Dependências (builder)
# ============================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar apenas package files primeiro (aproveitar cache de layers)
COPY package*.json ./

# Instalar apenas dependências de produção
RUN npm ci --only=production && npm cache clean --force

# ============================================
# Estágio 2: Runtime (imagem final)
# ============================================
FROM node:20-alpine AS runtime

# Metadata da imagem (aponte para o SEU portfólio público)
LABEL org.opencontainers.image.source="https://github.com/SEU-USUARIO/unifaat-devops-portfolio"
LABEL org.opencontainers.image.description="TechNova API - Sistema de gestão de pedidos"

WORKDIR /app

# Criar usuário não-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S technova -u 1001 -G nodejs

# Copiar dependências do builder
COPY --from=builder /app/node_modules ./node_modules

# Copiar código da aplicação
COPY . .

# Usar usuário não-root
USER technova

# Expor porta
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Comando de execução
CMD ["node", "server.js"]
```

### 2.3 Revisar o .dockerignore

A pasta copiada já traz um `.dockerignore`. Para a imagem de produção ficar enxuta,
confirme (ou ajuste) o conteúdo de `aula-09/technova-api/.dockerignore`:

```
node_modules
npm-debug.log*
.git
.gitignore
.env
.env.*
coverage
__tests__
*.test.js
.eslintrc*
jest.config*
.github
README.md
docker-compose*.yml
```

### 2.4 Testar o build localmente

```bash
# Build
docker build -t technova-api:local .

# Verificar tamanho
docker images technova-api:local

# Testar execução
docker run -p 3000:3000 technova-api:local

# Testar health check (em outro terminal)
curl http://localhost:3000/health
```

> **✅ Checkpoint:** imagem builda sem erros e responde no `/health`

---

## Parte 3 — Criar o Repositório ECR e Fazer Login

### 3.1 Criar o repositório no ECR

Diferente do ghcr.io (onde o repositório surge no primeiro push), no ECR você **cria o repositório antes**. O Learner Lab permite isso com as credenciais da sessão:

```bash
aws ecr create-repository \
  --repository-name technova-api \
  --region us-east-1
```

Se o repositório já existir (de uma sessão anterior), o comando retorna `RepositoryAlreadyExistsException` — pode ignorar. Para conferir:

```bash
aws ecr describe-repositories --region us-east-1 \
  --query "repositories[].repositoryUri" --output text
```

Resultado esperado:

```
123456789012.dkr.ecr.us-east-1.amazonaws.com/technova-api
```

> **💡 Guarde esse `repositoryUri`.** Ele é a base de todas as tags. Para facilitar, exporte variáveis:
>
> ```bash
> export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
> export REGION=us-east-1
> export ECR_URI=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/technova-api
> echo $ECR_URI
> ```

### 3.2 Autenticar o Docker no ECR

O ECR não usa usuário/senha fixos. Você pede um **token temporário** (válido ~12h) e o passa ao `docker login`:

```bash
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin \
    $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
```

Resultado esperado: `Login Succeeded`.

**Como funciona:**
- `aws ecr get-login-password` gera um token de autenticação temporário
- `docker login --username AWS --password-stdin` usa esse token (o usuário é sempre literalmente `AWS`)
- O host é o seu registry (`<ACCOUNT_ID>.dkr.ecr.<REGIAO>.amazonaws.com`), **sem** o nome da imagem

> **⚠️ Se o `docker login` falhar com `denied`/`ExpiredToken`:** o token do Lab expirou. Recarregue as credenciais (Passo 1.2) e repita o login.

### 3.3 Tag + Push manual (entender o fluxo)

Antes de automatizar, faça uma vez na mão para enxergar cada etapa:

```bash
# 1. Taguear a imagem local com o endereço do ECR
docker tag technova-api:local $ECR_URI:sha-manual

# 2. Push para o ECR
docker push $ECR_URI:sha-manual

# 3. Conferir que a imagem chegou
aws ecr list-images --repository-name technova-api --region us-east-1
```

> **✅ Checkpoint:** `docker push` concluiu e a tag `sha-manual` aparece em `list-images`.

---

## Parte 4 — Script de Build e Push

Automatizar o fluxo num script evita erros de digitação e serve de base para o CI.

### 4.1 Criar o script `ecr-push.sh`

Crie `aula-09/technova-api/ecr-push.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# ---- Configuração ----
REGION="us-east-1"
REPO="technova-api"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO"

# Tag pelo SHA curto do commit (rastreabilidade total)
SHA_TAG="sha-$(git rev-parse --short HEAD)"

echo "==> Garantindo o repositório ECR ($REPO)..."
aws ecr describe-repositories --repository-names "$REPO" --region "$REGION" >/dev/null 2>&1 \
  || aws ecr create-repository --repository-name "$REPO" --region "$REGION" >/dev/null

echo "==> Login no ECR..."
aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

echo "==> Build..."
docker build -t "$REPO:local" .

echo "==> Tag ($SHA_TAG + latest) e push..."
docker tag "$REPO:local" "$ECR_URI:$SHA_TAG"
docker tag "$REPO:local" "$ECR_URI:latest"
docker push "$ECR_URI:$SHA_TAG"
docker push "$ECR_URI:latest"

echo "==> Pronto! Imagem publicada:"
echo "    $ECR_URI:$SHA_TAG"
echo "    $ECR_URI:latest"
```

Dê permissão de execução e rode:

```bash
chmod +x ecr-push.sh
./ecr-push.sh
```

### 4.2 Verificar no console e via CLI

```bash
# Listar tags publicadas
aws ecr describe-images --repository-name technova-api --region us-east-1 \
  --query "imageDetails[].imageTags" --output table
```

No console da AWS: **ECR → Repositories → technova-api** mostra as tags, o tamanho e a data de cada imagem.

> **✅ Checkpoint:** o script publica `sha-XXXXXXX` e `latest` no ECR sem erros.

---

## Parte 5 — Tagging com Semantic Versioning

Além do SHA e do `latest`, releases usam **semver** (`1.2.3`). Vamos publicar uma versão:

```bash
# Reaproveita o login e a imagem já buildada
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export ECR_URI=$ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/technova-api

# Taguear a release
docker tag technova-api:local $ECR_URI:1.0.0
docker tag technova-api:local $ECR_URI:1.0
docker push $ECR_URI:1.0.0
docker push $ECR_URI:1.0

# (Opcional) registrar a release também no Git
git tag v1.0.0 -m "Release 1.0.0 - primeira imagem no ECR"
git push origin v1.0.0
```

**Estratégia combinada (igual à teoria):**

```
$ECR_URI:sha-a1b2c3d   ← todo build (rastreável)
$ECR_URI:latest        ← último build da main (conveniência)
$ECR_URI:1.0.0         ← release (semver, comunicação com a equipe)
```

> **✅ Checkpoint:** as tags `1.0.0` e `1.0` aparecem no ECR ao lado de `sha-...` e `latest`.

---

## Parte 6 — Pull, Execução e Rollback

### 6.1 Simular deploy em "outro servidor"

```bash
# Remover imagens locais para forçar o pull do registry
docker rmi $ECR_URI:latest $ECR_URI:1.0.0 technova-api:local 2>/dev/null || true

# Pull da imagem publicada (como um servidor EC2 faria)
docker pull $ECR_URI:1.0.0
```

> Em uma EC2 do Lab, a instância precisa das credenciais do Lab (ou do `LabInstanceProfile`) e do mesmo `aws ecr get-login-password` antes do `docker pull`.

### 6.2 Executar a imagem publicada

```bash
docker run -d --name technova-prod -p 3000:3000 $ECR_URI:1.0.0
curl http://localhost:3000/health
docker logs technova-prod
```

### 6.3 Simular rollback

```bash
# Algo deu errado na 1.0.1 — voltar para a 1.0.0
docker stop technova-prod && docker rm technova-prod
docker run -d --name technova-prod -p 3000:3000 $ECR_URI:1.0.0
curl http://localhost:3000/health
```

> **✅ Checkpoint:** pull, execução e rollback usando tags do ECR funcionam.

---

## Parte 7 — (Opcional) Build e Push no CI com credenciais do Lab

> **Leia com atenção.** No GitHub Actions, o build+push para o ECR precisa de credenciais AWS. No Learner Lab essas credenciais são **temporárias e expiram a cada sessão** — então o push automático no CI **só funciona enquanto a sessão do Lab estiver válida**. Em um projeto real, usaríamos **OIDC** (role de curta duração sem segredo fixo) ou um usuário IAM dedicado — mas o Lab **não permite criar IAM**. Por isso, nesta disciplina o fluxo principal é o **script local** (Partes 3–6). O CI abaixo é um exercício complementar.

### 7.1 Guardar as credenciais do Lab como secrets

No `unifaat-devops-portfolio`: **Settings → Secrets and variables → Actions → New repository secret**. Crie os três (copiando os valores atuais do **AWS Details** do Lab):

| Secret | Valor |
|--------|-------|
| `AWS_ACCESS_KEY_ID` | `ASIA...` (da sessão atual) |
| `AWS_SECRET_ACCESS_KEY` | `...` |
| `AWS_SESSION_TOKEN` | `...` |

> **⚠️ A cada nova sessão do Lab esses três valores mudam.** Você terá que atualizá-los nos secrets para o push no CI voltar a funcionar. É exatamente a dor que o OIDC resolve em produção.

### 7.2 Workflow de build+push para o ECR

Crie `.github/workflows/build-push-ecr.yml`:

```yaml
name: Build and Push to Amazon ECR

on:
  push:
    branches: [main]
    tags: ['v*.*.*']
  workflow_dispatch:

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: technova-api

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout do código
        uses: actions/checkout@v4

      - name: Configurar credenciais AWS (Learner Lab)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login no Amazon ECR
        id: ecr-login
        uses: aws-actions/amazon-ecr-login@v2

      - name: Garantir o repositório ECR
        run: |
          aws ecr describe-repositories --repository-names "$ECR_REPOSITORY" --region "$AWS_REGION" \
            || aws ecr create-repository --repository-name "$ECR_REPOSITORY" --region "$AWS_REGION"

      - name: Build, tag e push
        env:
          REGISTRY: ${{ steps.ecr-login.outputs.registry }}
        run: |
          IMAGE="$REGISTRY/$ECR_REPOSITORY"
          SHA_TAG="sha-$(git rev-parse --short HEAD)"
          docker build -t "$IMAGE:$SHA_TAG" -t "$IMAGE:latest" aula-09/technova-api
          docker push "$IMAGE:$SHA_TAG"
          docker push "$IMAGE:latest"
```

**O que muda em relação ao ghcr.io da Aula 08:**
- `aws-actions/configure-aws-credentials` carrega as 3 credenciais temporárias
- `aws-actions/amazon-ecr-login` faz o `docker login` no ECR e devolve o `registry` como output
- O host da imagem agora é o seu `<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com`

> **✅ Checkpoint (se a sessão do Lab estiver válida):** o workflow publica a imagem no ECR. Se falhar com `ExpiredToken`, atualize os 3 secrets com as credenciais da sessão atual.

---

## Troubleshooting

| Problema | Causa Provável | Solução |
|----------|---------------|---------|
| `ExpiredToken` / `InvalidClientTokenId` | Sessão do Lab expirou | Reinicie o Lab e recopie as credenciais (Passo 1.2) |
| `docker login` falha com `denied` | Token do ECR expirou ou região errada | Rode `aws ecr get-login-password` de novo; confirme `us-east-1` |
| `RepositoryAlreadyExistsException` | Repositório já criado em sessão anterior | Ignore — pode seguir para o login/push |
| `name unknown: repository not found` no push | Esqueceu de criar o repositório, ou tag com URI errado | `aws ecr create-repository ...` e confira o `$ECR_URI` |
| `no basic auth credentials` no push | Fez `docker tag` mas não fez `docker login` no ECR | Refaça o login (Passo 3.2) |
| Build falha no CI mas funciona local | `.dockerignore` não exclui `node_modules` | Verificar `.dockerignore` |
| CI falha com `ExpiredToken` | Credenciais do Lab nos secrets expiraram | Atualize `AWS_ACCESS_KEY_ID`/`SECRET`/`SESSION_TOKEN` |
| Imagem muito grande (>500MB) | Multi-stage não aplicado | Verificar que o Dockerfile tem dois estágios |

---

## Checklist de Validação

Antes de seguir para o Laboratório Parte 2, confirme:

- [ ] Pasta `technova-api` copiada para `aula-09/` e `npm install` executado
- [ ] Credenciais do Learner Lab carregadas (`aws sts get-caller-identity` OK)
- [ ] Dockerfile otimizado (labels OCI, usuário não-root, HEALTHCHECK) buildando localmente
- [ ] `.dockerignore` revisado (exclui node_modules, .git, testes)
- [ ] Repositório ECR `technova-api` criado (`aws ecr describe-repositories`)
- [ ] `docker login` no ECR com sucesso (`aws ecr get-login-password`)
- [ ] Script `ecr-push.sh` publica `sha-XXXXXXX` + `latest` no ECR
- [ ] Release semver (`1.0.0`, `1.0`) publicada no ECR
- [ ] Pull, execução e rollback usando tags do ECR funcionam
- [ ] (Opcional) Workflow `build-push-ecr.yml` publicou no ECR com os secrets do Lab

> **🎯 Se os itens obrigatórios estão ✅, você completou a Parte 1!** Siga para o Laboratório Parte 2: PR Review Automatizado com IA.
