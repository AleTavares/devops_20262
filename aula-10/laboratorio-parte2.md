# Aula 10 — Laboratório Parte 2: Pipeline CD Completo (CI→Build→Push→Deploy)

## Missão

Construir um pipeline de Continuous Deployment que, ao fazer merge na main, executa lint, testes, build da imagem Docker, push para o **Amazon ECR** e deploy automático na EC2 usando a estratégia Recreate. Ao final, cada merge gera um deploy automático com health check.

**Resultado final:**
- Pipeline unificado: lint → test → build → push (ECR) → deploy
- Deploy automático na EC2 via SSH (estratégia Recreate)
- Health check pós-deploy verificando que a app está saudável
- Deploy só acontece em push para main (não em PRs)
- Procedimento de rollback documentado

---

## Pré-requisitos

- [ ] Repositório `technova-api` no GitHub com CI e build+push no ECR funcionando (Aula 09)
- [ ] Acesso ao **AWS Academy Learner Lab** (credenciais de sessão como secrets, `us-east-1`)
- [ ] EC2 rodando com Docker e AWS CLI instalados (provisionada via Terraform)
- [ ] Chave SSH para acessar a EC2 (par de chaves gerado na AWS)
- [ ] Imagem da TechNova API publicada no **Amazon ECR** (repositório `technova-api`, pelo menos uma vez)
- [ ] EC2 com acesso ao ECR (internet pública ou NAT gateway) e credenciais da sessão disponíveis

---

## Passo 1 — Preparar a EC2 para Receber Deploys

### 1.1 Verificar que o Security Group permite SSH do GitHub Actions

> **⚠️ Passo obrigatório antes de continuar:** o deploy via SSH exige que a EC2 aceite conexões na porta 22 vindas dos runners do GitHub Actions. Sem isso, o step de deploy vai expirar por timeout.

Verifique ou adicione a regra no Security Group da EC2 (via Terraform ou Console):

```hcl
# No seu módulo security-group, adicione a regra para SSH dos runners do GitHub Actions
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]   # GitHub Actions usa IPs variáveis — precisa abrir para todos
  description = "SSH para GitHub Actions runners (CD pipeline)"
}
```

Ou via Console AWS: **EC2 → Security Groups → technova-api-sg → Edit inbound rules → Add rule: SSH, 0.0.0.0/0**.

> Em produção você restringiria aos [ranges de IP publicados pelo GitHub](https://api.github.com/meta) — no Lab, `0.0.0.0/0` na porta 22 é aceitável.

### 1.2 Verificar Docker e AWS CLI na EC2

Conecte na EC2 e confirme que Docker e a AWS CLI estão instalados:

```bash
ssh -i ~/.ssh/technova-key.pem ubuntu@SEU_EC2_IP

# Verificar Docker
docker --version
docker ps

# Verificar AWS CLI (necessária para login no ECR)
aws --version

# Verificar que a EC2 consegue acessar a internet
docker pull hello-world
```

### 1.2 Autenticar no Amazon ECR na EC2

Para que a EC2 possa fazer pull de imagens do ECR, é necessário autenticar com um token temporário. Configure as credenciais da sessão do Lab na EC2 (ex: `aws configure` ou variáveis de ambiente) e faça login:

```bash
# Na EC2: definir o registry e logar no ECR (token temporário, usuário sempre "AWS")
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$REGISTRY"
```

> **💡 O token do ECR expira em ~12 horas e as credenciais do Lab por sessão.** Por isso o deploy automático refaz o `docker login` a cada execução, antes do `docker pull`.

### 1.3 Testar pull manual da imagem

```bash
# Na EC2: testar que consegue baixar a imagem do ECR
docker pull "$REGISTRY/technova-api:latest"

# Rodar manualmente para confirmar que funciona
docker run -d --name technova-api-test -p 3000:3000 \
  "$REGISTRY/technova-api:latest"

# Testar
curl http://localhost:3000/health

# Limpar teste
docker stop technova-api-test && docker rm technova-api-test
```

> **✅ Checkpoint:** EC2 consegue fazer login no ECR, pull e rodar a imagem.

---

## Passo 2 — Configurar Secrets no GitHub

### 2.1 Criar os secrets necessários

No repositório GitHub: Settings → Secrets and variables → Actions → New repository secret

| Secret Name | Valor | Descrição |
|-------------|-------|-----------|
| `EC2_HOST` | IP público da EC2 (ex: `54.123.45.67`) | Destino do deploy |
| `EC2_SSH_KEY` | Conteúdo da chave privada `.pem` | Para conexão SSH |
| `EC2_USERNAME` | `ubuntu` | Usuário SSH padrão do Ubuntu AMI |
| `AWS_ACCESS_KEY_ID` | Credencial temporária de sessão do Lab | Login no ECR (CI e EC2) |
| `AWS_SECRET_ACCESS_KEY` | Credencial temporária de sessão do Lab | Login no ECR |
| `AWS_SESSION_TOKEN` | Token de sessão do Lab (expira por sessão) | Login no ECR |
| `AWS_ACCOUNT_ID` | Account ID da sua conta do Lab | Compor o URI do ECR |

### 2.2 Como copiar a chave SSH para o secret

```bash
# No seu laptop, copie o conteúdo da chave privada
cat ~/.ssh/technova-key.pem
```

Copie **TODO** o conteúdo (incluindo `-----BEGIN RSA PRIVATE KEY-----` e `-----END RSA PRIVATE KEY-----`) e cole no campo do secret `EC2_SSH_KEY`.

> **⚠️ A chave SSH e as credenciais do Lab são sensíveis.** Nunca commite no repositório. GitHub Secrets criptografa o valor.
>
> **As credenciais do Lab expiram por sessão** — ao reabrir o Lab, atualize-as assim:
> 1. **Start Lab** → aguardar verde → **AWS Details → AWS CLI → Show**
> 2. **GitHub → Settings → Secrets and variables → Actions**
> 3. Atualizar `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` e `AWS_SESSION_TOKEN`
> 4. Reexecutar o workflow que falhou com `ExpiredToken` (aba Actions → rerun)

> **✅ Checkpoint:** secrets criados no repositório (EC2 + credenciais do ECR).

---

## Passo 3 — Criar o Pipeline CD Unificado

### 3.1 Workflow completo

Crie (ou atualize) `.github/workflows/cd.yml`:

```yaml
name: CD Pipeline - Build and Deploy

on:
  push:
    branches: [main]

env:
  AWS_REGION: us-east-1
  IMAGE_NAME: technova-api

jobs:
  # ============================
  # Job 1: Lint
  # ============================
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  # ============================
  # Job 2: Test
  # ============================
  test:
    needs: lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test

  # ============================
  # Job 3: Build e Push (Amazon ECR)
  # ============================
  build-push:
    needs: [lint, test]
    runs-on: ubuntu-latest
    outputs:
      registry: ${{ steps.ecr.outputs.registry }}

    steps:
      - uses: actions/checkout@v4

      - name: Configurar credenciais AWS (Learner Lab)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}   # Learner Lab exige
          aws-region: ${{ env.AWS_REGION }}

      - name: Login no Amazon ECR
        id: ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Extrair metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ steps.ecr.outputs.registry }}/${{ env.IMAGE_NAME }}
          tags: |
            type=sha,prefix=sha-,format=short
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build e Push
        uses: docker/build-push-action@v5
        with:
          context: .                    # raiz do repositório (onde está a app)
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}

  # ============================
  # Job 4: Deploy na EC2
  # ============================
  deploy:
    needs: build-push
    runs-on: ubuntu-latest
    environment: production

    steps:
      - name: Deploy via SSH (Recreate Strategy)
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USERNAME }}
          key: ${{ secrets.EC2_SSH_KEY }}
          envs: AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_SESSION_TOKEN,AWS_ACCOUNT_ID
          script: |
            REGISTRY=${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com

            echo "🔐 Login no Amazon ECR..."
            aws ecr get-login-password --region us-east-1 \
              | docker login --username AWS --password-stdin "$REGISTRY"

            echo "📦 Fazendo pull da nova imagem..."
            docker pull "$REGISTRY/technova-api:latest"

            echo "🛑 Parando container atual..."
            docker stop technova-api || true
            docker rm technova-api || true

            echo "▶️ Iniciando novo container..."
            docker run -d \
              --name technova-api \
              -p 3000:3000 \
              --restart unless-stopped \
              -e NODE_ENV=production \
              "$REGISTRY/technova-api:latest"

            echo "✅ Container iniciado!"
            docker ps | grep technova-api
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_SESSION_TOKEN: ${{ secrets.AWS_SESSION_TOKEN }}
          AWS_ACCOUNT_ID: ${{ secrets.AWS_ACCOUNT_ID }}

      - name: Health Check
        run: |
          echo "⏳ Aguardando aplicação iniciar..."
          sleep 10
          for i in $(seq 1 20); do
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
              http://${{ secrets.EC2_HOST }}:3000/health || echo "000")
            if [ "$HTTP_CODE" = "200" ]; then
              echo "✅ Health check passed! (HTTP $HTTP_CODE)"
              exit 0
            fi
            echo "⏳ Tentativa $i/20 - HTTP $HTTP_CODE - aguardando 5s..."
            sleep 5
          done
          echo "❌ Health check falhou após 20 tentativas!"
          exit 1
```

### 3.2 Entendendo o pipeline

| Job | Depende de | Função |
|-----|-----------|--------|
| `lint` | — | Verifica qualidade do código |
| `test` | lint | Roda testes (só se lint passar) |
| `build-push` | lint, test | Login no ECR + build Docker + push |
| `deploy` | build-push | SSH na EC2 + login ECR + docker run (Recreate) |

**Fluxo visual:**
```
lint → test → build-push → deploy → health-check
                                          │
                                    ✅ ou ❌
```

### 3.3 O que é `environment: production`?

O `environment: production` permite:
- Adicionar regras de proteção (requerer aprovação manual antes do deploy)
- Secrets específicos por ambiente (produção vs staging)
- Histórico de deployments visível na aba Deployments do GitHub

> **💡 Para Continuous Delivery (em vez de Deployment):** adicione "Required reviewers" no environment.

> **✅ Checkpoint:** workflow CD criado com 4 jobs sequenciais, publicando no ECR.

---

## Passo 4 — Primeiro Deploy Automático

### 4.1 Fazer push e observar o pipeline

```bash
# Commitar o workflow
git add .github/workflows/cd.yml
git commit -m "ci: add CD pipeline with automatic deploy to EC2 (ECR)"
git push origin main
```

### 4.2 Acompanhar a execução

1. Vá para a aba **Actions**
2. Observe o pipeline executando em sequência: lint → test → build-push → deploy
3. Clique no job **deploy** para ver os logs do SSH
4. Verifique o step **Health Check** — deve mostrar "✅ Health check passed!"

### 4.3 Verificar o deploy na EC2

```bash
# Conectar na EC2 e verificar
ssh -i ~/.ssh/technova-key.pem ubuntu@SEU_EC2_IP

# Verificar container rodando
docker ps
# Deve mostrar: technova-api com status "Up X seconds"

# Testar a aplicação
curl http://localhost:3000/health
# Deve retornar: {"status":"ok"}
```

### 4.4 Testar acesso externo

```bash
# Do seu laptop (substituir pelo IP da EC2)
curl http://SEU_EC2_IP:3000/health
```

> **⚠️ Se não funcionar externamente:** verifique que o Security Group permite tráfego na porta 3000 (ingress rule criada no Lab Parte 1!).

> **✅ Checkpoint:** deploy automático funcionando — push na main → app atualizada na EC2.

---

## Passo 5 — Testar o Ciclo Completo com Mudança de Código

### 5.1 Fazer uma mudança na aplicação

Edite `server.js` para adicionar uma rota de versão:

```javascript
// Adicionar antes do app.listen()
app.get('/version', (req, res) => {
  res.json({
    version: '1.1.0',
    deployedAt: new Date().toISOString(),
    commit: process.env.GITHUB_SHA || 'local'
  });
});
```

### 5.2 Push e observar deploy automático

```bash
git add server.js
git commit -m "feat: add /version endpoint with deploy timestamp"
git push origin main
```

### 5.3 Verificar que o novo endpoint existe

Aguarde o pipeline completar, então:

```bash
curl http://SEU_EC2_IP:3000/version
# Deve retornar: {"version":"1.1.0","deployedAt":"2025-...","commit":"..."}
```

> **✅ Checkpoint:** mudança de código → deploy automático → nova funcionalidade disponível!

---

## Passo 6 — Rollback Manual

### 6.1 Identificar a versão anterior

No **console do Amazon ECR** (Elastic Container Registry → Repositories → `technova-api`), veja as tags disponíveis e suas datas de push.

Ou via CLI:
```bash
# Ver tags do repositório no ECR
aws ecr list-images --repository-name technova-api --region us-east-1

# Ver commits recentes para mapear o SHA
git log --oneline -5
# Identificar o SHA do commit anterior (ex: abc1234)
```

### 6.2 Executar rollback

```bash
# Conectar na EC2
ssh -i ~/.ssh/technova-key.pem ubuntu@SEU_EC2_IP

# Login no ECR antes do pull
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$REGISTRY"

# Rollback para versão anterior (substituir SHA)
docker stop technova-api
docker rm technova-api
docker pull "$REGISTRY/technova-api:sha-abc1234"
docker run -d --name technova-api \
  -p 3000:3000 \
  --restart unless-stopped \
  "$REGISTRY/technova-api:sha-abc1234"

# Verificar que está na versão anterior
curl http://localhost:3000/version
# Deve dar 404 (endpoint não existia na versão anterior) ou versão antiga
```

### 6.3 Documentar o procedimento de rollback

Crie um arquivo `docs/runbook-rollback.md` no repositório:

```markdown
# Runbook: Rollback de Deploy

## Quando usar
- Deploy causou erros na aplicação
- Health check passa mas funcionalidade está quebrada
- Bug crítico detectado após deploy

## Procedimento
1. Identificar SHA do último deploy estável (console do Amazon ECR)
2. SSH na EC2: `ssh -i key.pem ubuntu@HOST`
3. Executar:
   ```bash
   REGISTRY=<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
   aws ecr get-login-password --region us-east-1 \
     | docker login --username AWS --password-stdin "$REGISTRY"
   docker stop technova-api && docker rm technova-api
   docker run -d --name technova-api -p 3000:3000 \
     --restart unless-stopped \
     "$REGISTRY/technova-api:sha-COMMIT_BOM"
   ```
4. Verificar: `curl http://localhost:3000/health`
5. Comunicar o time no Slack
```

> **✅ Checkpoint:** rollback manual executado e documentado.

---

## Passo 7 — Melhorias Opcionais

### 7.1 Adicionar SHA do commit como variável de ambiente

Atualize o step de deploy para passar o SHA:

```yaml
      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USERNAME }}
          key: ${{ secrets.EC2_SSH_KEY }}
          envs: AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_SESSION_TOKEN,AWS_ACCOUNT_ID,GITHUB_SHA
          script: |
            REGISTRY=${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com
            aws ecr get-login-password --region us-east-1 \
              | docker login --username AWS --password-stdin "$REGISTRY"
            docker pull "$REGISTRY/technova-api:latest"
            docker stop technova-api || true
            docker rm technova-api || true
            docker run -d \
              --name technova-api \
              -p 3000:3000 \
              --restart unless-stopped \
              -e NODE_ENV=production \
              -e GITHUB_SHA="$GITHUB_SHA" \
              -e DEPLOY_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
              "$REGISTRY/technova-api:latest"
```

### 7.2 Notificação de deploy (conceito)

Após o health check passar, adicione notificação:

```yaml
      - name: Notificar deploy bem-sucedido
        if: success()
        run: |
          echo "✅ Deploy da versão ${{ github.sha }} concluído com sucesso!"
          echo "Deployed by: ${{ github.actor }}"
          echo "Commit message: ${{ github.event.head_commit.message }}"
```

---

## Troubleshooting

| Problema | Causa Provável | Solução |
|----------|---------------|---------|
| SSH connection timeout | Security group não libera porta 22 | Adicionar ingress rule SSH para IP do runner |
| `Permission denied (publickey)` | Chave SSH incorreta ou formato errado | Verificar que copiou todo conteúdo incluindo headers |
| `denied` / `token has expired` no ECR | Credenciais do Lab expiraram | Atualizar os secrets AWS do Lab e reexecutar |
| Health check falha | App não está escutando na porta 3000 | Verificar logs: `docker logs technova-api` |
| `docker: command not found` na EC2 | Docker não instalado | Instalar Docker na EC2 |
| `aws: command not found` na EC2 | AWS CLI não instalada | Instalar AWS CLI v2 (necessária p/ login no ECR) |
| Container exits immediately | Erro na aplicação | Ver logs: `docker logs technova-api` |
| Port already in use | Container antigo não foi removido | `docker rm -f technova-api` antes do run |

---

## Checklist de Validação

Antes de finalizar, confirme:

- [ ] Pipeline CD com 4 jobs: lint → test → build-push → deploy
- [ ] Build e push publicando no **Amazon ECR** (`<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com`)
- [ ] Deploy acontece apenas em push para main (não em PRs)
- [ ] Deploy via SSH usando `appleboy/ssh-action`
- [ ] Login no ECR (`aws ecr get-login-password`) antes do `docker pull`
- [ ] Estratégia Recreate: stop → rm → pull → run
- [ ] Health check pós-deploy verifica que app está respondendo
- [ ] Pipeline falha se health check não passar
- [ ] Secrets configurados (EC2 + credenciais do Lab + Account ID)
- [ ] Testado end-to-end: mudança de código → push → deploy automático
- [ ] Rollback manual executado com sucesso
- [ ] Procedimento de rollback documentado

> **🎯 Se todos os itens estão ✅, você completou o Laboratório Parte 2!** O pipeline CD da TechNova está automatizado de ponta a ponta.
