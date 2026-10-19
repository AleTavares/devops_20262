# Laboratório Parte 1 — Criar Microserviço do Zero + Pipeline CI

## Aula 13 — Novo Microserviço com Pipeline End-to-End

### Objetivo

Criar o microserviço `technova-notifications` completamente do zero, aplicando todas as práticas do curso: código limpo, testes, containerização e integração contínua com push da imagem para o **Amazon ECR**.

---

### Contexto

Você é desenvolvedor(a) na TechNova. O CTO pediu um novo serviço de notificações que deve **nascer certo** — com qualidade desde o primeiro commit. Você tem autonomia total, mas o serviço precisa seguir os padrões da empresa.

> **☁️ AWS Academy Learner Lab:** o push de imagens desta aula usa o **Amazon ECR** com as credenciais temporárias da sessão (`aws_session_token`), sempre em `us-east-1`. O Lab **permite criar repositórios ECR**, mas **não permite criar usuários/grupos/roles IAM** — a autenticação usa as credenciais da sua sessão. Recarregue-as ao reabrir o Lab.

---

### Pré-requisitos

- Node.js 18+ instalado
- Docker instalado e rodando
- AWS CLI v2 configurada com as credenciais do Learner Lab (`aws sts get-caller-identity` funcionando, região `us-east-1`)
- Conta no GitHub com acesso ao repositório da disciplina
- Conhecimento das aulas anteriores (Git, Docker, CI, registry/Amazon ECR)

---

## Etapa 1 — Inicialização do Projeto

### 1.1 Criar estrutura de diretórios

```bash
# Na raiz do seu repositório
mkdir -p technova-notifications/src/routes
mkdir -p technova-notifications/src/services
mkdir -p technova-notifications/tests
cd technova-notifications
```

### 1.2 Inicializar Node.js e instalar dependências

```bash
npm init -y
npm install express cors dotenv
npm install --save-dev jest supertest eslint nodemon
```

### 1.3 Configurar package.json

Edite o `package.json` para incluir os scripts e configuração de testes:

```json
{
  "name": "technova-notifications",
  "version": "1.0.0",
  "description": "Serviço de notificações da TechNova",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js",
    "test": "jest --coverage --forceExit",
    "lint": "eslint src/ tests/"
  },
  "jest": {
    "testEnvironment": "node",
    "coverageThreshold": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80
      }
    }
  },
  "keywords": ["technova", "notifications", "microservice"],
  "license": "MIT"
}
```

### 1.4 Configurar ESLint

Criar `.eslintrc.json`:

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
    "no-unused-vars": "warn",
    "no-console": "off",
    "semi": ["error", "always"],
    "quotes": ["error", "single"]
  }
}
```

### 1.5 Criar .gitignore

```
node_modules/
coverage/
.env
*.log
dist/
```

**Checkpoint:** Projeto inicializado com dependências instaladas.

---

## Etapa 2 — Implementação do Serviço

### 2.1 Criar o servidor principal — src/server.js

```javascript
const express = require('express');
const cors = require('cors');
const notificationRoutes = require('./routes/notifications');

const app = express();
const PORT = process.env.PORT || 3001;

// Middlewares
app.use(cors());
app.use(express.json());

// Logging simples
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'technova-notifications',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Rotas
app.use('/notifications', notificationRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Rota não encontrada' });
});

// Iniciar servidor (exceto em testes)
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`[technova-notifications] Serviço rodando na porta ${PORT}`);
    console.log(`[technova-notifications] Health check: http://localhost:${PORT}/health`);
  });
}

module.exports = app;
```

### 2.2 Criar o serviço de notificações — src/services/notificationService.js

```javascript
// Armazenamento in-memory (em produção seria um banco de dados)
const notifications = [];

const notificationService = {
  /**
   * Cria e registra uma nova notificação
   */
  create({ orderId, customerEmail, type, message }) {
    const notification = {
      id: `notif-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      orderId,
      customerEmail,
      type,
      message,
      status: 'sent',
      createdAt: new Date().toISOString()
    };

    notifications.push(notification);
    return notification;
  },

  /**
   * Retorna todas as notificações
   */
  getAll() {
    return [...notifications];
  },

  /**
   * Retorna notificações filtradas por orderId
   */
  getByOrderId(orderId) {
    return notifications.filter(n => n.orderId === orderId);
  },

  /**
   * Retorna estatísticas do serviço
   */
  getStats() {
    return {
      total: notifications.length,
      byType: notifications.reduce((acc, n) => {
        acc[n.type] = (acc[n.type] || 0) + 1;
        return acc;
      }, {})
    };
  },

  /**
   * Limpa todas as notificações (para testes)
   */
  clear() {
    notifications.length = 0;
  }
};

module.exports = notificationService;
```

### 2.3 Criar as rotas — src/routes/notifications.js

```javascript
const express = require('express');
const router = express.Router();
const notificationService = require('../services/notificationService');

/**
 * POST /notifications/send
 * Recebe dados de pedido e registra notificação
 */
router.post('/send', (req, res) => {
  const { orderId, customerEmail, type, message } = req.body;

  // Validação de campos obrigatórios
  if (!orderId || !customerEmail || !type || !message) {
    return res.status(400).json({
      error: 'Campos obrigatórios: orderId, customerEmail, type, message'
    });
  }

  // Validação de tipo de notificação
  const validTypes = ['order_created', 'order_shipped', 'order_delivered', 'order_cancelled'];
  if (!validTypes.includes(type)) {
    return res.status(400).json({
      error: `Tipo inválido. Tipos aceitos: ${validTypes.join(', ')}`
    });
  }

  const notification = notificationService.create({
    orderId, customerEmail, type, message
  });

  console.log(`[NOTIFICATION] ${type} → ${customerEmail} (pedido: ${orderId})`);

  res.status(201).json({
    success: true,
    notification
  });
});

/**
 * GET /notifications
 * Lista todas as notificações
 */
router.get('/', (req, res) => {
  const notifications = notificationService.getAll();
  res.json({
    total: notifications.length,
    notifications
  });
});

/**
 * GET /notifications/stats
 * Retorna estatísticas de notificações
 */
router.get('/stats', (req, res) => {
  const stats = notificationService.getStats();
  res.json(stats);
});

/**
 * GET /notifications/:orderId
 * Retorna notificações de um pedido específico
 */
router.get('/:orderId', (req, res) => {
  const notifications = notificationService.getByOrderId(req.params.orderId);
  res.json({
    orderId: req.params.orderId,
    total: notifications.length,
    notifications
  });
});

module.exports = router;
```

### 2.4 Testar manualmente

```bash
npm start
# Em outro terminal:
curl http://localhost:3001/health
curl -X POST http://localhost:3001/notifications/send \
  -H "Content-Type: application/json" \
  -d '{"orderId":"order-001","customerEmail":"teste@email.com","type":"order_created","message":"Pedido criado"}'
curl http://localhost:3001/notifications
```

**Checkpoint:** Serviço rodando e respondendo a requisições.

---

## Etapa 3 — Testes Automatizados

### 3.1 Testes da API — tests/notifications.test.js

```javascript
const request = require('supertest');
const app = require('../src/server');
const notificationService = require('../src/services/notificationService');

describe('technova-notifications API', () => {
  beforeEach(() => {
    notificationService.clear();
  });

  describe('GET /health', () => {
    it('retorna status healthy com informações do serviço', async () => {
      const res = await request(app).get('/health');

      expect(res.status).toBe(200);
      expect(res.body.status).toBe('healthy');
      expect(res.body.service).toBe('technova-notifications');
      expect(res.body).toHaveProperty('timestamp');
      expect(res.body).toHaveProperty('uptime');
    });
  });

  describe('POST /notifications/send', () => {
    const validPayload = {
      orderId: 'order-test-001',
      customerEmail: 'cliente@test.com',
      type: 'order_created',
      message: 'Seu pedido foi criado com sucesso'
    };

    it('cria notificação com payload válido', async () => {
      const res = await request(app)
        .post('/notifications/send')
        .send(validPayload);

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.notification).toMatchObject({
        orderId: 'order-test-001',
        customerEmail: 'cliente@test.com',
        type: 'order_created',
        status: 'sent'
      });
      expect(res.body.notification).toHaveProperty('id');
      expect(res.body.notification).toHaveProperty('createdAt');
    });

    it('retorna 400 quando orderId está ausente', async () => {
      const { orderId, ...payload } = validPayload;
      const res = await request(app)
        .post('/notifications/send')
        .send(payload);

      expect(res.status).toBe(400);
      expect(res.body.error).toContain('Campos obrigatórios');
    });

    it('retorna 400 quando customerEmail está ausente', async () => {
      const { customerEmail, ...payload } = validPayload;
      const res = await request(app)
        .post('/notifications/send')
        .send(payload);

      expect(res.status).toBe(400);
    });

    it('retorna 400 para tipo de notificação inválido', async () => {
      const res = await request(app)
        .post('/notifications/send')
        .send({ ...validPayload, type: 'tipo_invalido' });

      expect(res.status).toBe(400);
      expect(res.body.error).toContain('Tipo inválido');
    });

    it('aceita todos os tipos válidos', async () => {
      const types = ['order_created', 'order_shipped', 'order_delivered', 'order_cancelled'];

      for (const type of types) {
        const res = await request(app)
          .post('/notifications/send')
          .send({ ...validPayload, type });

        expect(res.status).toBe(201);
      }
    });
  });

  describe('GET /notifications', () => {
    it('retorna lista vazia quando não há notificações', async () => {
      const res = await request(app).get('/notifications');

      expect(res.status).toBe(200);
      expect(res.body.total).toBe(0);
      expect(res.body.notifications).toEqual([]);
    });

    it('retorna notificações criadas', async () => {
      // Criar 2 notificações
      await request(app).post('/notifications/send').send({
        orderId: 'order-1', customerEmail: 'a@test.com',
        type: 'order_created', message: 'Pedido 1'
      });
      await request(app).post('/notifications/send').send({
        orderId: 'order-2', customerEmail: 'b@test.com',
        type: 'order_shipped', message: 'Pedido 2'
      });

      const res = await request(app).get('/notifications');

      expect(res.status).toBe(200);
      expect(res.body.total).toBe(2);
      expect(res.body.notifications).toHaveLength(2);
    });
  });

  describe('GET /notifications/:orderId', () => {
    it('retorna notificações de um pedido específico', async () => {
      await request(app).post('/notifications/send').send({
        orderId: 'order-abc', customerEmail: 'x@test.com',
        type: 'order_created', message: 'Criado'
      });
      await request(app).post('/notifications/send').send({
        orderId: 'order-xyz', customerEmail: 'y@test.com',
        type: 'order_created', message: 'Outro pedido'
      });

      const res = await request(app).get('/notifications/order-abc');

      expect(res.status).toBe(200);
      expect(res.body.orderId).toBe('order-abc');
      expect(res.body.total).toBe(1);
      expect(res.body.notifications[0].orderId).toBe('order-abc');
    });

    it('retorna lista vazia para pedido sem notificações', async () => {
      const res = await request(app).get('/notifications/inexistente');

      expect(res.status).toBe(200);
      expect(res.body.total).toBe(0);
    });
  });

  describe('GET /notifications/stats', () => {
    it('retorna estatísticas por tipo', async () => {
      await request(app).post('/notifications/send').send({
        orderId: 'o1', customerEmail: 'a@t.com',
        type: 'order_created', message: 'm'
      });
      await request(app).post('/notifications/send').send({
        orderId: 'o2', customerEmail: 'b@t.com',
        type: 'order_created', message: 'm'
      });
      await request(app).post('/notifications/send').send({
        orderId: 'o3', customerEmail: 'c@t.com',
        type: 'order_shipped', message: 'm'
      });

      const res = await request(app).get('/notifications/stats');

      expect(res.status).toBe(200);
      expect(res.body.total).toBe(3);
      expect(res.body.byType.order_created).toBe(2);
      expect(res.body.byType.order_shipped).toBe(1);
    });
  });

  describe('404 handler', () => {
    it('retorna 404 para rotas inexistentes', async () => {
      const res = await request(app).get('/rota-que-nao-existe');
      expect(res.status).toBe(404);
    });
  });
});
```

### 3.2 Rodar testes e verificar cobertura

```bash
npm test
```

**Resultado esperado:** Todos os testes passam com cobertura > 80%.

**Checkpoint:** Testes passando com boa cobertura.

---

## Etapa 4 — Containerização

### 4.1 Criar Dockerfile multi-stage

```dockerfile
# === Stage 1: Testes (validação de qualidade) ===
FROM node:18-alpine AS test
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run lint && npm test

# === Stage 2: Dependências de produção ===
FROM node:18-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# === Stage 3: Imagem final de produção ===
FROM node:18-alpine AS production
WORKDIR /app

# Criar usuário não-root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copiar apenas o necessário
COPY --from=dependencies /app/node_modules ./node_modules
COPY src/ ./src/
COPY package.json ./

# Health check nativo do Docker
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3001/health || exit 1

# Configurações de segurança e runtime
USER appuser
EXPOSE 3001
ENV NODE_ENV=production
ENV PORT=3001

CMD ["node", "src/server.js"]
```

### 4.2 Criar .dockerignore

```
node_modules
npm-debug.log
.git
.gitignore
tests/
coverage/
.env
*.md
.eslintrc.json
```

### 4.3 Criar docker-compose.yml para desenvolvimento

```yaml
version: '3.8'

services:
  technova-notifications:
    build:
      context: .
      target: production
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=production
      - PORT=3001
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--spider", "http://localhost:3001/health"]
      interval: 10s
      timeout: 3s
      start_period: 5s
      retries: 3
    restart: unless-stopped
```

### 4.4 Build e teste do container

```bash
# Build da imagem
docker build -t technova-notifications:latest .

# Verificar tamanho da imagem
docker images technova-notifications:latest

# Rodar container
docker run -d --name notif-test -p 3001:3001 technova-notifications:latest

# Testar
curl http://localhost:3001/health

# Verificar logs
docker logs notif-test

# Limpar
docker stop notif-test && docker rm notif-test
```

**Checkpoint:** Container builda, roda e responde ao health check.

---

## Etapa 5 — Pipeline CI no GitHub Actions (push para o Amazon ECR)

### 5.1 Criar o repositório ECR e validar o login localmente

Antes do primeiro push, crie o repositório no ECR com as credenciais da sessão do Lab:

```bash
aws ecr create-repository \
  --repository-name technova-notifications \
  --region us-east-1
```

Confirme que você consegue autenticar o Docker no ECR a partir da sua máquina (o usuário é sempre literalmente `AWS`) — é o mesmo login que o CI faz via action:

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$REGISTRY"
```

### 5.2 Configurar os secrets do GitHub

As credenciais do Learner Lab são **temporárias** e precisam ser coladas como secrets do repositório (e atualizadas a cada nova sessão do Lab):

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`

> **☁️ Learner Lab:** o padrão ideal em produção (OIDC + role IAM assumida pelo Actions) fica **indisponível** no Lab, que não permite criar roles IAM. Por isso usamos as 3 credenciais temporárias da sessão como secrets. Quando o push falhar com `token has expired`, reabra o Lab e atualize os três secrets.

### 5.3 Criar o workflow

Criar `.github/workflows/notifications-ci.yml`:

```yaml
name: CI — technova-notifications

on:
  push:
    branches: [main, develop]
    paths:
      - 'technova-notifications/**'
  pull_request:
    branches: [main]
    paths:
      - 'technova-notifications/**'

env:
  IMAGE_NAME: technova-notifications
  AWS_REGION: us-east-1

jobs:
  lint:
    name: "1. Lint"
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./technova-notifications
    steps:
      - name: Checkout código
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: technova-notifications/package-lock.json

      - name: Instalar dependências
        run: npm ci

      - name: Executar lint
        run: npm run lint

  test:
    name: "2. Test"
    runs-on: ubuntu-latest
    needs: lint
    defaults:
      run:
        working-directory: ./technova-notifications
    steps:
      - name: Checkout código
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: technova-notifications/package-lock.json

      - name: Instalar dependências
        run: npm ci

      - name: Executar testes com cobertura
        run: npm test

      - name: Upload relatório de cobertura
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-report
          path: technova-notifications/coverage/
          retention-days: 7

  build-and-push:
    name: "3. Build & Push (Amazon ECR)"
    runs-on: ubuntu-latest
    needs: test
    steps:
      - name: Checkout código
        uses: actions/checkout@v4

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

      - name: Extrair metadata para tags
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ steps.ecr.outputs.registry }}/${{ env.IMAGE_NAME }}
          tags: |
            type=sha,prefix=sha-
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build e Push da imagem
        uses: docker/build-push-action@v5
        with:
          context: ./technova-notifications
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}

      - name: Resumo do build
        run: |
          echo "### Build realizado com sucesso! :rocket:" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "**Registry:** ${{ steps.ecr.outputs.registry }}" >> $GITHUB_STEP_SUMMARY
          echo "**Imagem:** ${{ env.IMAGE_NAME }}" >> $GITHUB_STEP_SUMMARY
          echo "**Tags:** ${{ steps.meta.outputs.tags }}" >> $GITHUB_STEP_SUMMARY
```

> O `steps.ecr.outputs.registry` resolve para `<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com` — o host do ECR já inclui o seu Account ID e a região.

### 5.4 Commit e push para testar

```bash
git checkout -b feature/technova-notifications
git add technova-notifications/ .github/
git commit -m "feat: criar microserviço technova-notifications com CI (push ECR)"
git push -u origin feature/technova-notifications
```

### 5.5 Verificar no GitHub e no console do ECR

1. Acessar a aba **Actions** do repositório
2. Verificar que o workflow `CI — technova-notifications` foi disparado
3. Acompanhar execução: Lint → Test → Build & Push
4. Confirmar que a imagem aparece no **console do Amazon ECR** (Elastic Container Registry → Repositories → `technova-notifications`), com as tags `sha-...` e `latest`

**Checkpoint:** Pipeline CI executando com sucesso e imagem publicada no Amazon ECR.

---

## Validação Final — Parte 1

### Testes de verificação

Execute localmente:

```bash
# 1. Lint sem erros
npm run lint && echo "LINT OK"

# 2. Testes passando
npm test && echo "TESTS OK"

# 3. Docker build sem erros
docker build -t technova-notifications:check . && echo "DOCKER OK"

# 4. Container respondendo
docker run -d --name check -p 3001:3001 technova-notifications:check
sleep 3
curl -f http://localhost:3001/health && echo "HEALTH OK"
docker stop check && docker rm check
```

### Critérios de sucesso

| Critério | Status |
|----------|--------|
| Estrutura de projeto organizada | ⬜ |
| Código com lint passando | ⬜ |
| Testes unitários >80% cobertura | ⬜ |
| Dockerfile multi-stage funcional | ⬜ |
| Container respondendo health check | ⬜ |
| Pipeline CI no GitHub Actions verde | ⬜ |
| Imagem publicada no Amazon ECR | ⬜ |

---

## Problemas Comuns

| Problema | Solução |
|----------|---------|
| `npm test` falha com "Cannot find module" | Verificar paths nos imports (`require('../src/server')`) |
| Docker build falha no stage de teste | Verificar se `.dockerignore` não exclui `package-lock.json` |
| Push ao ECR falha com `token has expired` | As credenciais do Lab expiraram — reabra o Lab e atualize os 3 secrets AWS |
| Push ao ECR falha com `repository does not exist` | Rode `aws ecr create-repository --repository-name technova-notifications --region us-east-1` |
| Health check timeout no container | Aumentar `start-period` no HEALTHCHECK |
| Lint erro de "unexpected console" | Confirmar `"no-console": "off"` no `.eslintrc.json` |

---

## Próximo Passo

Continue para o **Laboratório Parte 2** onde você vai criar a pipeline CD, provisionar infraestrutura com Terraform (com `LabInstanceProfile`), integrar os serviços e validar com testes E2E.
