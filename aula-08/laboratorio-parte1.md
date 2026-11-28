# Aula 08 — Laboratório Parte 1: CI Pipeline Completo

## Missão

Construir um pipeline CI completo para a TechNova API usando GitHub Actions. Ao final deste laboratório, cada push e pull request será automaticamente verificado com lint, testes e build Docker.


**Resultado final:**
- ESLint configurado e verificando código
- Jest rodando testes unitários com coverage
- Docker build verificando que a imagem compila
- Pipeline multi-estágio: lint → test → build
- Status badge no README do repositório

---

## Pré-requisitos

- [ ] Conta GitHub ativa
- [ ] Node.js ≥ 18 instalado (`node --version`)
- [ ] npm instalado (`npm --version`)
- [ ] Git configurado com autenticação no GitHub
- [ ] Repositório `unifaat-devops-portfolio` no GitHub (pode ser novo)

> **Repositório público = GitHub Actions gratuito (minutos ilimitados para repos públicos)**

---

## Parte 1 — Setup do Projeto

> **📦 Você NÃO precisa digitar os arquivos da API à mão.** O repositório da disciplina já traz a pasta `technova-api/` pronta e testada (API Express, testes Jest, ESLint, Dockerfile). Basta **copiar essa pasta** para dentro de `aula-08/` no seu portfólio. A seção 1.1 mostra como. As seções 1.2 a 1.8 ficam como **referência** do que há dentro da pasta — leia para entender, mas não precisa recriar nada.

### 1.1 Copiar a pasta `technova-api` para o portfólio

A pasta base vive na raiz do repositório da disciplina (`devops_20262/technova-api`). Copie-a para dentro de `aula-08/` no seu `unifaat-devops-portfolio`:

```bash
# a partir da raiz do seu unifaat-devops-portfolio
mkdir -p aula-08
cp -r /caminho/para/devops_20262/technova-api aula-08/technova-api
cd aula-08/technova-api
```

> Se você clonou o repositório da disciplina, troque `/caminho/para/devops_20262` pelo caminho real onde ele está na sua máquina.

Instale as dependências (isso recria o `node_modules/` localmente; o `package-lock.json` já vem na pasta):

```bash
npm install
```

> **Por que `npm install` mesmo com o lock file pronto?** Ele baixa o `node_modules/` para você rodar lint e testes localmente. O `package-lock.json` já está versionado na pasta — ele é o que o CI usa com `npm ci`.

### 1.2 O que vem dentro da pasta (referência)

A pasta `technova-api/` já contém tudo que o pipeline precisa:

```
technova-api/
├── server.js              # API Express (health check + CRUD de orders)
├── package.json           # Dependências e scripts (start, test, lint, build)
├── package-lock.json      # Lock file (necessário para npm ci no CI)
├── .eslintrc.json         # Configuração do ESLint
├── Dockerfile             # Imagem multi-stage, usuário não-root
├── .dockerignore          # Exclusões do contexto de build
├── .gitignore             # node_modules, coverage, .env, etc.
└── __tests__/
    └── server.test.js     # Testes Jest (health + orders)
```

Nas seções abaixo (1.3 a 1.8) estão os conteúdos principais, apenas para você conhecer o que vai rodar no pipeline.

### 1.3 O servidor (`server.js`)

A API expõe um health check e um CRUD de pedidos em memória:

```javascript
const express = require('express');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0'
  });
});

// Orders routes
const orders = [
  { id: 1, product: 'Notebook TechNova Pro', quantity: 2, status: 'pending' },
  { id: 2, product: 'Monitor UltraWide 34"', quantity: 1, status: 'shipped' },
  { id: 3, product: 'Teclado Mecânico RGB', quantity: 5, status: 'delivered' }
];

app.get('/api/orders', (req, res) => {
  res.json(orders);
});

app.get('/api/orders/:id', (req, res) => {
  const order = orders.find(o => o.id === parseInt(req.params.id));
  if (!order) {
    return res.status(404).json({ error: 'Order not found' });
  }
  res.json(order);
});

app.post('/api/orders', (req, res) => {
  const { product, quantity } = req.body;
  if (!product || !quantity) {
    return res.status(400).json({ error: 'Product and quantity are required' });
  }
  const newOrder = {
    id: orders.length + 1,
    product,
    quantity,
    status: 'pending'
  };
  orders.push(newOrder);
  res.status(201).json(newOrder);
});

// Só inicia o servidor se não estiver em modo de teste
if (process.env.NODE_ENV !== 'test') {
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`TechNova API rodando na porta ${PORT}`);
  });
}

module.exports = app;
```

### 1.4 Scripts e dependências (`package.json`)

O `package.json` já traz os scripts que o pipeline usa (`lint`, `test`, `test:ci`, `build`) e a configuração do Jest:

```json
{
  "scripts": {
    "start": "node server.js",
    "test": "jest --coverage --forceExit",
    "test:ci": "jest --coverage --forceExit --ci",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "build": "echo 'Build step - verificação de sintaxe' && node --check server.js"
  }
}
```

### 1.5 ESLint (`.eslintrc.json`)

As regras de lint já estão configuradas (ponto-e-vírgula obrigatório, aspas simples, indentação de 2 espaços, etc.).

### 1.6 Testes (`__tests__/server.test.js`)

A pasta já inclui **9 testes** cobrindo o health check e o CRUD de orders (GET lista, GET por id, GET 404, POST válido, POST 400).

### 1.7 Dockerfile

Imagem multi-stage com usuário não-root, pronta para o job de build:

```dockerfile
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM base AS production
COPY . .
EXPOSE 3000
USER node
CMD ["node", "server.js"]
```

### 1.8 `.gitignore` e `.dockerignore`

Já vêm configurados para excluir `node_modules/`, `coverage/`, `.env` e logs do versionamento e do contexto de build.

### 1.9 Verificar localmente

Antes de criar o pipeline, verifique que tudo funciona localmente:

```bash
# Lint
npm run lint

# Testes
npm test

# Build check
npm run build
```

> **✅ Checkpoint:** Todos os 3 comandos devem passar sem erros antes de prosseguir. Como a pasta já vem testada, eles devem passar de primeira — se algum falhar, confira se rodou `npm install` após copiar a pasta.

---

## Parte 2 — Primeiro Workflow GitHub Actions

### 2.1 Criar a estrutura de diretórios

O GitHub Actions procura workflows em `.github/workflows/` **na raiz do `unifaat-devops-portfolio`** (não dentro de `aula-08/`):

```bash
# Na raiz do unifaat-devops-portfolio
mkdir -p .github/workflows
```

### 2.2 Criar o workflow CI

Crie o arquivo `.github/workflows/ci-aula08.yml`:

```yaml
name: CI Pipeline — Aula 08

on:
  push:
    branches: [main, develop]
    paths:
      - 'aula-08/technova-api/**'
      - '.github/workflows/ci-aula08.yml'
  pull_request:
    branches: [main]
    paths:
      - 'aula-08/technova-api/**'
  workflow_dispatch:

defaults:
  run:
    working-directory: aula-08/technova-api

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
          cache-dependency-path: aula-08/technova-api/package-lock.json

      - name: Instalar dependências
        run: npm ci

      - name: Executar ESLint
        run: npm run lint
```

### 2.3 Commit e push

Faça o commit da **pasta `technova-api` copiada** (com o `package-lock.json`) e do workflow:

```bash
git add aula-08/technova-api .github/workflows/ci-aula08.yml
git commit -m "feat: adicionar TechNova API e configuração de CI com ESLint"
git branch -M main
# (repositório unifaat-devops-portfolio já existe — apenas faça push na branch)
git push -u origin main
```

> **⚠️ Confirme que o `package-lock.json` foi commitado** (`git status` não deve listá-lo como ignorado). Ele é obrigatório para o `npm ci` do pipeline funcionar.

### 2.4 Verificar a execução

1. Acesse seu repositório no GitHub
2. Clique na aba **Actions**
3. Veja o workflow "CI Pipeline" executando
4. Clique no run para ver os logs em tempo real
5. O job `lint` deve ficar verde ✅

> **⚠️ Se falhar:** Leia a mensagem de erro. Erros comuns:
> - `npm ci` falha → verifique se `aula-08/technova-api/package-lock.json` está commitado
> - ESLint errors → corrija o código localmente e faça novo push

---

## Parte 3 — Adicionar Job de Lint Robusto

### 3.1 Entender exit codes

Quando ESLint encontra erros:
- **Exit 0:** Nenhum erro → step passa ✅
- **Exit 1:** Erros encontrados → step falha ❌
- **Exit 2:** Erro de configuração → step falha ❌

### 3.2 Melhorar o step de lint

Atualize o job `lint` para ter melhor output:

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

      - name: Instalar dependências
        run: npm ci

      - name: Executar ESLint
        run: npm run lint

      - name: Lint passou
        if: success()
        run: echo "✅ Código aprovado pelo ESLint!"
```

---

## Parte 4 — Adicionar Job de Testes

### 4.1 Adicionar job test ao workflow

Edite `.github/workflows/ci-aula08.yml` e adicione o job `test` após o job `lint`:

```yaml
  test:
    name: Tests (Jest)
    needs: lint
    runs-on: ubuntu-latest

    steps:
      - name: Checkout do código
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: aula-08/technova-api/package-lock.json

      - name: Instalar dependências
        run: npm ci

      - name: Executar testes com coverage
        run: npm run test:ci

      - name: Upload coverage report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: aula-08/technova-api/coverage/
          retention-days: 14
```

### 4.2 Entender `needs: lint`

A linha `needs: lint` significa:
- O job `test` **não inicia** até que `lint` termine com sucesso
- Se `lint` falhar, `test` é **pulado** (skipped)
- Isso economiza minutos de execução e dá feedback mais rápido

### 4.3 Entender artifacts

O step `Upload coverage report`:
- Salva a pasta `coverage/` como artifact
- Disponível para download na UI do GitHub Actions
- Retido por 14 dias
- `if: always()` faz upload mesmo se testes falharem (para debugar)

### 4.4 Commit e push

```bash
git add .github/workflows/ci-aula08.yml
git commit -m "feat: adicionar job de testes com coverage"
git push
```

Verifique na aba Actions:
- Job `lint` executa primeiro
- Job `test` espera lint terminar
- Após ambos passarem, o artifact `coverage-report` aparece no run

---

## Parte 5 — Adicionar Job de Build Docker

### 5.1 Adicionar job build

Adicione o job `build` ao workflow:

```yaml
  build:
    name: Build (Docker)
    needs: [lint, test]
    runs-on: ubuntu-latest

    steps:
      - name: Checkout do código
        uses: actions/checkout@v4

      - name: Build da imagem Docker
        run: docker build -t technova-api:${{ github.sha }} aula-08/technova-api/

      - name: Verificar imagem criada
        run: docker images technova-api

      - name: Testar container (smoke test)
        run: |
          docker run -d --name test-container -p 3000:3000 technova-api:${{ github.sha }}
          sleep 3
          curl -f http://localhost:3000/health || exit 1
          docker stop test-container
          docker rm test-container
```

### 5.2 Entender `needs: [lint, test]`

O job `build` depende de **ambos** lint e test:
- Se lint falhar → test é pulado → build é pulado
- Se lint passar e test falhar → build é pulado
- Só executa se AMBOS passarem

### 5.3 Entender `${{ github.sha }}`

- `github.sha` é o hash do commit que disparou o workflow
- Usar como tag da imagem Docker garante rastreabilidade
- Cada commit gera uma tag única (ex: `technova-api:a1b2c3d4`)

### 5.4 Commit e push

```bash
git add .github/workflows/ci-aula08.yml
git commit -m "feat: adicionar job de build Docker ao pipeline"
git push
```

---

## Parte 6 — Pipeline Completo + Status Badge

### 6.1 Workflow final completo

Verifique que seu `.github/workflows/ci-aula08.yml` está assim:

```yaml
name: CI Pipeline — Aula 08

on:
  push:
    branches: [main, develop]
    paths:
      - 'aula-08/technova-api/**'
      - '.github/workflows/ci-aula08.yml'
  pull_request:
    branches: [main]
    paths:
      - 'aula-08/technova-api/**'
  workflow_dispatch:

defaults:
  run:
    working-directory: aula-08/technova-api

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
          cache-dependency-path: aula-08/technova-api/package-lock.json

      - name: Instalar dependências
        run: npm ci

      - name: Executar ESLint
        run: npm run lint

  test:
    name: Tests (Jest)
    needs: lint
    runs-on: ubuntu-latest

    steps:
      - name: Checkout do código
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: aula-08/technova-api/package-lock.json

      - name: Instalar dependências
        run: npm ci

      - name: Executar testes com coverage
        run: npm run test:ci

      - name: Upload coverage report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: aula-08/technova-api/coverage/
          retention-days: 14

  build:
    name: Build (Docker)
    needs: [lint, test]
    runs-on: ubuntu-latest

    steps:
      - name: Checkout do código
        uses: actions/checkout@v4

      - name: Build da imagem Docker
        run: docker build -t technova-api:${{ github.sha }} aula-08/technova-api/

      - name: Verificar imagem criada
        run: docker images technova-api

      - name: Testar container (smoke test)
        run: |
          docker run -d --name test-container -p 3000:3000 technova-api:${{ github.sha }}
          sleep 3
          curl -f http://localhost:3000/health || exit 1
          docker stop test-container
          docker rm test-container
```

### 6.2 Adicionar Status Badge ao README

Crie ou atualize o `README.md` na raiz do projeto:

```markdown
# TechNova API

![CI Pipeline — Aula 08](https://github.com/SEU-USUARIO/unifaat-devops-portfolio/actions/workflows/ci-aula08.yml/badge.svg)

API de gestão de pedidos da TechNova.

## Quick Start

```bash
npm install
npm start
```

## Scripts Disponíveis

| Comando | Descrição |
|---------|-----------|
| `npm start` | Inicia o servidor |
| `npm test` | Roda testes com coverage |
| `npm run lint` | Verifica código com ESLint |
| `npm run lint:fix` | Corrige erros de lint automaticamente |

## CI Pipeline

O pipeline CI roda automaticamente em cada push/PR:

1. **Lint** — ESLint verifica qualidade do código
2. **Test** — Jest roda testes unitários
3. **Build** — Docker build verifica a imagem

## Tech Stack

- Node.js 20
- Express.js
- Jest (testes)
- ESLint (linting)
- Docker
- GitHub Actions (CI)
```

> **⚠️ Substitua `SEU-USUARIO` pelo seu username do GitHub na URL do badge.**

### 6.3 Commit e push final

```bash
git add .
git commit -m "feat: pipeline CI completo com badge no README"
git push
```

### 6.4 Verificar o pipeline completo

Na aba Actions do GitHub:
1. O workflow deve mostrar 3 jobs: Lint → Tests → Build
2. Os jobs devem executar em sequência (setas de dependência)
3. Todos devem ficar verdes ✅
4. O badge no README deve mostrar "passing"

---

## Parte 7 — Quebrar e Consertar o Pipeline

### 7.1 Introduzir erro de lint

Crie um arquivo com erros intencionais:

```bash
cat > test-break.js << 'EOF'
var x = 1
var y = 2
console.log("hello")
EOF
```

**Erros intencionais:**
- `var` ao invés de `const/let`
- Falta de ponto-e-vírgula (se sua regra exige)
- Aspas duplas ao invés de simples

### 7.2 Push e observar falha

```bash
git add test-break.js
git commit -m "test: introduzir erros de lint intencionais"
git push
```

Na aba Actions:
- Job `lint` deve falhar ❌
- Jobs `test` e `build` devem ser **skipped** (pulados)
- O badge muda para "failing"

### 7.3 Corrigir e restaurar

```bash
rm test-break.js
git add -A
git commit -m "fix: remover arquivo com erros de lint"
git push
```

Na aba Actions:
- Pipeline deve voltar a ficar verde ✅
- Badge volta para "passing"

### 7.4 Introduzir teste falhando

Adicione um teste que falha em `__tests__/server.test.js`:

```javascript
describe('Teste intencional de falha', () => {
  it('este teste deve falhar', () => {
    expect(1 + 1).toBe(3); // Obviamente errado
  });
});
```

Push e observe:
- `lint` passa ✅ (código é válido)
- `test` falha ❌ (teste falha)
- `build` é pulado (depende de test)

Remova o teste e push novamente para restaurar o verde.

---

## Troubleshooting

### `npm ci` falha com "no package-lock.json"

A pasta `technova-api` já vem com o `package-lock.json`. Se o erro aparecer, provavelmente ele não foi commitado. Confirme e commite:

```bash
# Dentro de aula-08/technova-api
ls package-lock.json          # deve existir
git add aula-08/technova-api/package-lock.json
git commit -m "fix: adicionar package-lock.json"
git push
```

> Se por algum motivo o arquivo não existir, gere com `npm install` dentro de `aula-08/technova-api` e commite.

### ESLint reporta erros no node_modules

Verifique se `.eslintrc.json` tem:
```json
"ignorePatterns": ["node_modules/", "coverage/"]
```

### Testes falham com "Cannot find module"

Verifique se `server.js` exporta corretamente:
```javascript
module.exports = app;
```

### Docker build falha

Verifique se o `Dockerfile` está na raiz do projeto e se `package.json` está correto.

### Workflow não aparece na aba Actions

Verifique:
- O arquivo está em `.github/workflows/ci-aula08.yml` (caminho exato)
- O YAML não tem erros de indentação
- O branch está correto (push para main)

### Job fica "queued" por muito tempo

- Repositórios públicos: normalmente inicia em < 30 segundos
- Se demorar > 5 minutos: pode ser instabilidade do GitHub (raro)

---

## Checklist de Validação

Ao final desta parte do laboratório, verifique:

- [ ] `.eslintrc.json` configurado e lint passando localmente
- [ ] Testes escritos e passando localmente (`npm test`)
- [ ] `.github/workflows/ci-aula08.yml` com 3 jobs (lint, test, build)
- [ ] Job `test` depende de `lint` (`needs: lint`)
- [ ] Job `build` depende de ambos (`needs: [lint, test]`)
- [ ] Pipeline executou com sucesso no GitHub (todos verdes)
- [ ] Coverage report disponível como artifact
- [ ] Status badge no README mostrando "passing"
- [ ] Consegui quebrar o pipeline intencionalmente e restaurar
- [ ] Entendi a sequência: lint → test → build

> **✅ Se todos os itens estão marcados, prossiga para o Laboratório Parte 2 (Secrets + Advanced CI).**

---

*Próximo: Laboratório Parte 2 — Secrets, Environments e CI Avançado*
