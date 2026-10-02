# Aula 08 — Laboratório Parte 2: Secrets + Advanced CI

## Missão

Proteger o pipeline CI com GitHub Secrets, configurar environments com approval gates, e implementar features avançadas como matrix strategy, caching e concurrency control.


**Resultado final:**
- GitHub Secrets configurados e referenciados no workflow
- Environments "staging" e "production" com protection rules
- GITHUB_TOKEN usado para comentar em PRs
- Matrix strategy testando múltiplas versões de Node.js
- Cache de dependências acelerando o pipeline
- Concurrency control evitando runs duplicados

---

## Pré-requisitos

- [ ] Laboratório Parte 1 concluído (pipeline lint→test→build funcionando)
- [ ] Repositório `unifaat-devops-portfolio` com CI verde no GitHub
- [ ] Acesso às Settings do repositório (você é o owner)

---

## Parte 1 — Configurar GitHub Secrets

### 1.1 Acessar configuração de Secrets

1. No GitHub, acesse seu repositório `unifaat-devops-portfolio`
2. Clique em **Settings** (aba superior)
3. No menu lateral, clique em **Secrets and variables** → **Actions**
4. Clique em **New repository secret**

### 1.2 Adicionar secrets

Adicione os seguintes secrets (use valores fictícios para este lab):

| Nome | Valor (fictício) | Propósito |
|------|-------------------|-----------|
| `AWS_ACCESS_KEY_ID` | `AKIAEXEMPLO123456789` | Credencial AWS (simulada) |
| `AWS_SECRET_ACCESS_KEY` | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLE` | Credencial AWS (simulada) |
| `AWS_REGION` | `us-east-1` | Região AWS |
| `DB_PASSWORD` | `technova_secret_2024` | Senha do banco (simulada) |

> **⚠️ IMPORTANTE:** Estamos usando valores fictícios para aprendizado. Em um projeto real, use credenciais reais de uma conta AWS de desenvolvimento (NUNCA produção).

Para cada secret:
1. Clique em **New repository secret**
2. Digite o **Name** (ex: `AWS_ACCESS_KEY_ID`)
3. Digite o **Value** (ex: `AKIAEXEMPLO123456789`)
4. Clique em **Add secret**

### 1.3 Verificar que secrets foram criados

Após adicionar todos, você deve ver a lista:
```
AWS_ACCESS_KEY_ID       Updated just now
AWS_SECRET_ACCESS_KEY   Updated just now
AWS_REGION              Updated just now
DB_PASSWORD             Updated just now
```

> **Nota:** Você não consegue VER o valor após criar. Só pode atualizar ou deletar.

### 1.4 Entender mascaramento

O GitHub automaticamente mascara secrets nos logs. Se um log tentar imprimir `AKIAEXEMPLO123456789`, aparecerá `***` no output.

---

## Parte 2 — Usar Secrets no Workflow

### 2.1 Criar workflow para demonstrar secrets

Crie um novo arquivo `.github/workflows/secrets-demo.yml`:

```yaml
name: Secrets Demo

on:
  workflow_dispatch:

jobs:
  demonstrate-secrets:
    name: Demonstrar uso de Secrets
    runs-on: ubuntu-latest

    steps:
      - name: Checkout do código
        uses: actions/checkout@v4

      - name: Mostrar que secrets são mascarados
        env:
          MY_SECRET: ${{ secrets.AWS_REGION }}
        run: |
          echo "Tentando imprimir secret..."
          echo "Region: $MY_SECRET"
          echo "O valor acima aparece mascarado (***) nos logs"

      - name: Usar secrets como variáveis de ambiente
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_DEFAULT_REGION: ${{ secrets.AWS_REGION }}
        run: |
          echo "AWS configurada via secrets"
          echo "Region configurada: verificando variável de ambiente..."
          # Em um cenário real, aqui usaríamos:
          # aws sts get-caller-identity
          # Mas como são credenciais fictícias, apenas verificamos que existem
          if [ -n "$AWS_ACCESS_KEY_ID" ]; then
            echo "✅ AWS_ACCESS_KEY_ID está configurada"
          else
            echo "❌ AWS_ACCESS_KEY_ID não está configurada"
          fi

      - name: Verificar que secret inexistente retorna vazio
        env:
          FAKE_SECRET: ${{ secrets.THIS_DOES_NOT_EXIST }}
        run: |
          if [ -z "$FAKE_SECRET" ]; then
            echo "⚠️ Secret inexistente retorna string vazia (não erro!)"
          fi

      - name: Simular uso de DB_PASSWORD
        env:
          DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
        run: |
          echo "Conectando ao banco de dados..."
          echo "Password length: ${#DB_PASSWORD} caracteres"
          echo "✅ Senha carregada do secret (valor mascarado)"
```

### 2.2 Executar manualmente

1. Push o arquivo:
```bash
git add .github/workflows/secrets-demo.yml
git commit -m "feat: adicionar demo de secrets"
git push
```

2. No GitHub, vá em **Actions** → **Secrets Demo** → **Run workflow** → **Run workflow**

3. Observe os logs:
   - Onde deveria aparecer o valor do secret, aparece `***`
   - O step com secret inexistente mostra string vazia
   - Nenhum valor real é exposto

### 2.3 Adicionar secrets ao pipeline CI principal

Atualize `.github/workflows/ci-aula08.yml` adicionando um job que usa secrets:

```yaml
  verify-credentials:
    name: Verify Credentials
    needs: build
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'

    steps:
      - name: Checkout do código
        uses: actions/checkout@v4

      - name: Verificar configuração AWS
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_DEFAULT_REGION: ${{ secrets.AWS_REGION }}
        run: |
          echo "Verificando credenciais AWS..."
          if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
            echo "✅ Credenciais AWS configuradas"
            echo "Região: $AWS_DEFAULT_REGION"
            # Com credenciais reais, aqui faria:
            # aws sts get-caller-identity
          else
            echo "❌ Credenciais AWS NÃO configuradas"
            exit 1
          fi
```

> **Nota:** O `if:` garante que este job só roda em push para main (não em PRs), pois secrets não são disponibilizados em PRs de forks.

---

## Parte 3 — GitHub Environments

### 3.1 Criar environment "staging"

1. No repositório, vá em **Settings** → **Environments**
2. Clique em **New environment**
3. Nome: `staging`
4. Clique em **Configure environment**
5. **Deployment branches:** Selecione "All branches" (qualquer branch pode deployar para staging)
6. Clique em **Save protection rules**

### 3.2 Criar environment "production"

1. Clique em **New environment**
2. Nome: `production`
3. Clique em **Configure environment**
4. Em **Environment protection rules:**
   - Marque ✅ **Required reviewers**
   - Adicione seu próprio username como reviewer (para teste)
   - Opcionalmente: marque **Wait timer** com 1 minuto (para demonstrar delay)
5. **Deployment branches:** Selecione "Selected branches" → adicione `main`
6. Clique em **Save protection rules**

### 3.3 Adicionar environment secrets

No environment "production":
1. Role até **Environment secrets**
2. Clique em **Add secret**
3. Adicione:
   - `DB_HOST`: `prod-db.technova.internal`
   - `DB_NAME`: `technova_production`

No environment "staging":
1. Volte para Environments → staging → Configure
2. Adicione:
   - `DB_HOST`: `staging-db.technova.internal`
   - `DB_NAME`: `technova_staging`

### 3.4 Criar workflow com environments

Crie `.github/workflows/deploy.yml`:

```yaml
name: Deploy Pipeline

on:
  workflow_dispatch:
    inputs:
      skip-staging:
        description: 'Pular deploy em staging?'
        required: false
        type: boolean
        default: false

jobs:
  ci:
    name: CI Checks
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run test:ci

  deploy-staging:
    name: Deploy to Staging
    needs: ci
    if: ${{ !inputs.skip-staging }}
    runs-on: ubuntu-latest
    environment: staging

    steps:
      - uses: actions/checkout@v4

      - name: Deploy para Staging
        env:
          DB_HOST: ${{ secrets.DB_HOST }}
          DB_NAME: ${{ secrets.DB_NAME }}
          AWS_REGION: ${{ secrets.AWS_REGION }}
        run: |
          echo "🚀 Deploying to STAGING..."
          echo "Database: $DB_NAME @ $DB_HOST"
          echo "Region: $AWS_REGION"
          echo ""
          echo "Simulando deploy..."
          sleep 5
          echo "✅ Deploy para staging concluído!"

  deploy-production:
    name: Deploy to Production
    needs: [ci, deploy-staging]
    if: always() && needs.ci.result == 'success'
    runs-on: ubuntu-latest
    environment: production

    steps:
      - uses: actions/checkout@v4

      - name: Deploy para Production
        env:
          DB_HOST: ${{ secrets.DB_HOST }}
          DB_NAME: ${{ secrets.DB_NAME }}
          AWS_REGION: ${{ secrets.AWS_REGION }}
        run: |
          echo "🚀 Deploying to PRODUCTION..."
          echo "Database: $DB_NAME @ $DB_HOST"
          echo "Region: $AWS_REGION"
          echo ""
          echo "Simulando deploy..."
          sleep 5
          echo "✅ Deploy para production concluído!"
```

### 3.5 Testar o approval gate

1. Push o workflow:
```bash
git add .github/workflows/deploy.yml
git commit -m "feat: adicionar deploy pipeline com environments"
git push
```

2. Vá em **Actions** → **Deploy Pipeline** → **Run workflow**

3. Observe:
   - `CI Checks` executa automaticamente
   - `Deploy to Staging` executa automaticamente (sem protection rules)
   - `Deploy to Production` **PARA** e mostra "Waiting for review"
   - Você (como reviewer) receberá notificação
   - Clique em **Review deployments** → **Approve and deploy**
   - O job de produção executa após aprovação

> **💡 Em um time real:** O reviewer seria outra pessoa (tech lead, DevOps engineer). Nunca a mesma pessoa que fez o push.

---

## Parte 4 — GITHUB_TOKEN para Comentar em PR

### 4.1 Adicionar step para comentar em PRs

Atualize `.github/workflows/ci-aula08.yml` adicionando um job no final:

```yaml
  pr-comment:
    name: PR Comment
    needs: [lint, test, build]
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write

    steps:
      - name: Comentar resultado do CI no PR
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const { data: comments } = await github.rest.issues.listComments({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
            });

            // Evitar comentários duplicados
            const botComment = comments.find(comment =>
              comment.body.includes('## 🤖 CI Pipeline Results')
            );

            const body = `## 🤖 CI Pipeline Results

            | Stage | Status |
            |-------|--------|
            | Lint (ESLint) | ✅ Passed |
            | Tests (Jest) | ✅ Passed |
            | Build (Docker) | ✅ Passed |

            **Commit:** \`${context.sha.substring(0, 7)}\`
            **Workflow:** [Ver detalhes](${context.payload.repository.html_url}/actions/runs/${context.runId})

            ---
            _Gerado automaticamente pelo CI Pipeline_`;

            if (botComment) {
              await github.rest.issues.updateComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                comment_id: botComment.id,
                body: body,
              });
            } else {
              await github.rest.issues.createComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: context.issue.number,
                body: body,
              });
            }
```

### 4.2 Testar com um PR

```bash
# Criar branch
git checkout -b feature/test-pr-comment

# Fazer uma mudança simples
echo "// test comment" >> server.js

# Commit e push
git add server.js
git commit -m "test: verificar PR comment do CI"
git push -u origin feature/test-pr-comment
```

Agora crie um PR no GitHub:
1. Vá ao repositório → "Compare & pull request"
2. Crie o PR
3. Aguarde o CI executar
4. Observe o comentário automático do bot no PR

> **Nota:** Lembre de remover o `// test comment` depois e fazer merge ou fechar o PR.

---

## Parte 5 — Features Avançadas de CI

### 5.1 Matrix Strategy — Testar múltiplas versões

A matrix strategy permite rodar o mesmo job com diferentes configurações:

Atualize o job `test` em `.github/workflows/ci-aula08.yml`:

```yaml
  test:
    name: Tests (Node ${{ matrix.node-version }})
    needs: lint
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: ['18', '20']

    steps:
      - name: Checkout do código
        uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - name: Instalar dependências
        run: npm ci

      - name: Executar testes com coverage
        run: npm run test:ci

      - name: Upload coverage report
        if: matrix.node-version == '20'
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/
          retention-days: 14
```

**O que muda:**
- O job `test` agora executa **2 vezes** (Node 18 e Node 20)
- Garante compatibilidade entre versões
- O upload de coverage só acontece na versão 20 (evita duplicação)

### 5.2 Cache de dependências

O cache evita reinstalar node_modules a cada execução:

Adicione cache ao job `lint`:

```yaml
  lint:
    name: Lint (ESLint)
    runs-on: ubuntu-latest

    steps:
      - name: Checkout do código
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Cache node_modules
        uses: actions/cache@v4
        with:
          path: node_modules
          key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
          restore-keys: |
            ${{ runner.os }}-node-

      - name: Instalar dependências
        run: npm ci

      - name: Executar ESLint
        run: npm run lint
```

**Como funciona:**
- Primeira execução: instala normalmente, salva cache
- Execuções seguintes: restaura cache (se package-lock.json não mudou)
- Economia: ~30-60 segundos por job

> **Nota:** O `actions/setup-node@v4` com `cache: 'npm'` já faz cache do registro npm. O `actions/cache@v4` adicional faz cache do `node_modules` completo.

### 5.3 Concurrency Control

Evita que múltiplos pushes em sequência executem pipelines desnecessários:

Adicione no topo do workflow, após `on:`:

```yaml
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
```

**O que faz:**
- Se um novo push chegar enquanto o pipeline anterior ainda está rodando para o mesmo branch...
- O pipeline anterior é **cancelado** (`cancel-in-progress: true`)
- Apenas o pipeline mais recente executa
- Economiza minutos e evita resultados desatualizados

### 5.4 Path Filters

Execute CI apenas quando código relevante muda:

```yaml
on:
  push:
    branches: [main, develop]
    paths:
      - '**.js'
      - 'package.json'
      - 'package-lock.json'
      - 'Dockerfile'
      - '.github/workflows/ci-aula08.yml'
      - '.eslintrc.json'
    paths-ignore:
      - '**.md'
      - 'docs/**'
      - '.gitignore'
  pull_request:
    branches: [main]
```

**O que faz:**
- Pipeline só dispara se arquivos relevantes mudaram
- Mudanças apenas em README, docs, etc. NÃO disparam CI
- Economia de minutos quando só documentação é alterada

### 5.5 Commit com features avançadas

```bash
git add .github/workflows/ci-aula08.yml
git commit -m "feat: adicionar matrix, cache, concurrency e path filters"
git push
```

---

## Parte 6 — PR Workflow Completo

### 6.1 Criar branch com changes

```bash
git checkout main
git pull
git checkout -b feature/add-delete-endpoint
```

### 6.2 Adicionar funcionalidade

Adicione no `server.js` antes do `module.exports`:

```javascript
app.delete('/api/orders/:id', (req, res) => {
  const index = orders.findIndex(o => o.id === parseInt(req.params.id));
  if (index === -1) {
    return res.status(404).json({ error: 'Order not found' });
  }
  const deleted = orders.splice(index, 1);
  res.json({ message: 'Order deleted', order: deleted[0] });
});
```

### 6.3 Adicionar teste para nova funcionalidade

Adicione no `__tests__/server.test.js`:

```javascript
describe('DELETE /api/orders/:id', () => {
  it('deve deletar order existente', async () => {
    const res = await request(app).delete('/api/orders/1');
    expect(res.statusCode).toBe(200);
    expect(res.body.message).toBe('Order deleted');
  });

  it('deve retornar 404 para order inexistente', async () => {
    const res = await request(app).delete('/api/orders/999');
    expect(res.statusCode).toBe(404);
  });
});
```

### 6.4 Verificar localmente

```bash
npm run lint
npm test
```

### 6.5 Push e criar PR

```bash
git add .
git commit -m "feat: adicionar endpoint DELETE /api/orders/:id"
git push -u origin feature/add-delete-endpoint
```

No GitHub:
1. Clique em **"Compare & pull request"**
2. Preencha título e descrição
3. Observe o CI executar automaticamente no PR
4. Aguarde todos os checks passarem
5. O comentário automático do bot deve aparecer
6. Faça o merge

### 6.6 Configurar branch protection (opcional)

Para bloquear merge quando CI falha:
1. **Settings** → **Branches** → **Add branch protection rule**
2. Branch name pattern: `main`
3. Marque: ✅ **Require status checks to pass before merging**
4. Selecione os checks: `Lint (ESLint)`, `Tests (Jest)`, `Build (Docker)`
5. Salve

Agora PRs com CI falhando não podem ser merged!

---

## Troubleshooting

### Secrets não aparecem no workflow

- Verifique se o nome está correto (case-sensitive)
- Secrets de forks não são passados para PRs
- Secrets de environment só funcionam em jobs com `environment:`

### Approval gate não aparece

- Verifique se o environment "production" tem required reviewers configurado
- O job precisa ter `environment: production` explicitamente
- Você precisa ter permissão de reviewer no ambiente

### Matrix com falha em uma versão

- Se Node 18 falha mas 20 passa: verifique compatibilidade de sintaxe
- `fail-fast: false` na strategy faz os outros continuarem mesmo se um falhar:
  ```yaml
  strategy:
    fail-fast: false
    matrix:
      node-version: ['18', '20']
  ```

### Cache não está sendo usado

- O cache key precisa match exato: `${{ hashFiles('**/package-lock.json') }}`
- Se `package-lock.json` mudou, o cache é invalidado (correto!)
- Primeira execução após criar o workflow não terá cache

### GITHUB_TOKEN permission denied

Adicione permissions no job:
```yaml
permissions:
  pull-requests: write
  contents: read
```

### Concurrency cancelando runs desejados

- Se está cancelando runs que você quer, mude `cancel-in-progress: false`
- Ou use groups mais específicos: `ci-${{ github.ref }}-${{ github.event_name }}`

---

## Checklist de Validação

Ao final desta parte do laboratório, verifique:

- [ ] 4 secrets configurados no repositório (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION, DB_PASSWORD)
- [ ] Secrets aparecem mascarados (`***`) nos logs do workflow
- [ ] Environment "staging" criado e funcionando
- [ ] Environment "production" criado com required reviewers
- [ ] Approval gate testado (pipeline pausou e esperou aprovação)
- [ ] GITHUB_TOKEN usado para comentar em PR
- [ ] Matrix strategy testando Node 18 e 20
- [ ] Cache de node_modules configurado
- [ ] Concurrency control evitando runs duplicados
- [ ] PR workflow completo testado (push → CI → review → merge)
- [ ] Branch protection rules configurados (opcional)

> **✅ Se todos os itens estão marcados, parabéns! Você tem um pipeline CI profissional com segurança completa.**

---

## Workflow Final Completo (Referência)

Para referência, o workflow `ci.yml` final deve estar similar a:

```yaml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
    paths-ignore:
      - '**.md'
      - 'docs/**'
  pull_request:
    branches: [main]
  workflow_dispatch:

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint:
    name: Lint (ESLint)
    runs-on: ubuntu-latest

    steps:
      - name: Checkout do código
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Instalar dependências
        run: npm ci

      - name: Executar ESLint
        run: npm run lint

  test:
    name: Tests (Node ${{ matrix.node-version }})
    needs: lint
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: ['18', '20']

    steps:
      - name: Checkout do código
        uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - name: Instalar dependências
        run: npm ci

      - name: Executar testes com coverage
        run: npm run test:ci

      - name: Upload coverage report
        if: matrix.node-version == '20'
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/
          retention-days: 14

  build:
    name: Build (Docker)
    needs: [lint, test]
    runs-on: ubuntu-latest

    steps:
      - name: Checkout do código
        uses: actions/checkout@v4

      - name: Build da imagem Docker
        run: docker build -t technova-api:${{ github.sha }} .

      - name: Verificar imagem criada
        run: docker images technova-api

      - name: Testar container (smoke test)
        run: |
          docker run -d --name test-container -p 3000:3000 technova-api:${{ github.sha }}
          sleep 3
          curl -f http://localhost:3000/health || exit 1
          docker stop test-container
          docker rm test-container

  pr-comment:
    name: PR Comment
    needs: [lint, test, build]
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write

    steps:
      - name: Comentar resultado do CI no PR
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const body = `## 🤖 CI Pipeline Results

            | Stage | Status |
            |-------|--------|
            | Lint (ESLint) | ✅ Passed |
            | Tests (Jest) | ✅ Passed |
            | Build (Docker) | ✅ Passed |

            **Commit:** \`${context.sha.substring(0, 7)}\`

            ---
            _Gerado automaticamente pelo CI Pipeline_`;

            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: body,
            });
```

---

*Próximo: TF (Trabalho de Fixação) — Pipeline CI completo como entrega avaliativa*
