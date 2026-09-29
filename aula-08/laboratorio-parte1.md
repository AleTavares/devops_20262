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

### 1.1 Criar/Atualizar o repositório

Se ainda não tem o repositório `unifaat-devops-portfolio`, crie:

```bash
cd unifaat-devops-portfolio
mkdir -p aula-08/technova-api
cd aula-08/technova-api
```

### 1.2 Configurar package.json

Crie ou atualize o `package.json` com as dependências e scripts necessários:

```json
{
  "name": "technova-api",
  "version": "1.0.0",
  "description": "TechNova API - Sistema de gestão de pedidos",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "node server.js",
    "test": "jest --coverage --forceExit",
    "test:ci": "jest --coverage --forceExit --ci",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "build": "echo 'Build step - verificação de sintaxe' && node --check server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "dotenv": "^16.3.1",
    "cors": "^2.8.5"
  },
  "devDependencies": {
    "eslint": "^8.56.0",
    "jest": "^29.7.0",
    "supertest": "^6.3.3"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

### 1.3 Instalar dependências

```bash
npm install
```

### 1.4 Criar o servidor (server.js)

Se ainda não existe, crie o `server.js`:

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

### 1.5 Configurar ESLint (.eslintrc.json)

Crie o arquivo `.eslintrc.json` na raiz do projeto:

```json
{
  "env": {
    "node": true,
    "es2021": true,
    "jest": true
  },
  "extends": "eslint:recommended",
  "parserOptions": {
    "ecmaVersion": "latest"
  },
  "rules": {
    "no-unused-vars": ["warn", { "argsIgnorePattern": "^_" }],
    "no-console": "off",
    "semi": ["error", "always"],
    "quotes": ["error", "single"],
    "indent": ["error", 2],
    "no-trailing-spaces": "error",
    "eol-last": ["error", "always"]
  },
  "ignorePatterns": [
    "node_modules/",
    "coverage/",
    "dist/"
  ]
}
```

### 1.6 Criar testes (__tests__/server.test.js)

Crie o diretório e arquivo de testes:

```bash
mkdir -p __tests__
```

Crie `__tests__/server.test.js`:

```javascript
const request = require('supertest');
const app = require('../server');

describe('Health Check', () => {
  it('GET /health deve retornar status 200', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
  });

  it('GET /health deve retornar status ok', async () => {
    const res = await request(app).get('/health');
    expect(res.body.status).toBe('ok');
  });

  it('GET /health deve retornar timestamp', async () => {
    const res = await request(app).get('/health');
    expect(res.body.timestamp).toBeDefined();
  });
});

describe('Orders API', () => {
  it('GET /api/orders deve retornar array', async () => {
    const res = await request(app).get('/api/orders');
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/orders deve retornar orders com campos corretos', async () => {
    const res = await request(app).get('/api/orders');
    expect(res.body.length).toBeGreaterThan(0);
    expect(res.body[0]).toHaveProperty('id');
    expect(res.body[0]).toHaveProperty('product');
    expect(res.body[0]).toHaveProperty('quantity');
    expect(res.body[0]).toHaveProperty('status');
  });

  it('GET /api/orders/:id deve retornar order específica', async () => {
    const res = await request(app).get('/api/orders/1');
    expect(res.statusCode).toBe(200);
    expect(res.body.id).toBe(1);
  });

  it('GET /api/orders/:id deve retornar 404 para id inexistente', async () => {
    const res = await request(app).get('/api/orders/999');
    expect(res.statusCode).toBe(404);
    expect(res.body.error).toBe('Order not found');
  });

  it('POST /api/orders deve criar nova order', async () => {
    const newOrder = { product: 'Mouse Gamer', quantity: 3 };
    const res = await request(app).post('/api/orders').send(newOrder);
    expect(res.statusCode).toBe(201);
    expect(res.body.product).toBe('Mouse Gamer');
    expect(res.body.status).toBe('pending');
  });

  it('POST /api/orders deve retornar 400 sem campos obrigatórios', async () => {
    const res = await request(app).post('/api/orders').send({});
    expect(res.statusCode).toBe(400);
    expect(res.body.error).toBeDefined();
  });
});
```

### 1.7 Configurar Jest no package.json

Adicione a configuração do Jest (se não estiver no package.json):

```json
{
  "jest": {
    "testEnvironment": "node",
    "coverageDirectory": "coverage",
    "collectCoverageFrom": [
      "**/*.js",
      "!node_modules/**",
      "!coverage/**",
      "!__tests__/**"
    ]
  }
}
```

> **Nota:** Adicione esse bloco `"jest"` no final do seu `package.json`, no mesmo nível de `"scripts"`.

### 1.8 Criar Dockerfile

Se ainda não existe, crie o `Dockerfile`:

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

### 1.9 Criar .gitignore

```
node_modules/
coverage/
.env
*.log
dist/
```

### 1.10 Verificar localmente

Antes de criar o pipeline, verifique que tudo funciona localmente:

```bash
# Lint
npm run lint

# Testes
npm test

# Build check
npm run build
```

> **✅ Checkpoint:** Todos os 3 comandos devem passar sem erros antes de prosseguir.

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

```bash
git add .
git commit -m "feat: adicionar configuração de CI com ESLint"
git branch -M main
# (repositório unifaat-devops-portfolio já existe — apenas faça push na branch)
git push -u origin main
```

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

```bash
# Gere o lock file localmente
npm install
git add package-lock.json
git commit -m "fix: adicionar package-lock.json"
git push
```

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
