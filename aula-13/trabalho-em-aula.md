# Aula 13 — Trabalho em Aula

## Objetivo

Criar o microserviço `technova-notifications` do zero e montar seu pipeline end-to-end — código com testes, container, CI publicando no **Amazon ECR**, infraestrutura com Terraform no **Learner Lab**, deploy automatizado, integração inter-serviço e validação E2E —, demonstrando domínio de todas as práticas DevOps do curso.

**Formato:** Atividade prática individual (código em sala) + checklist de progresso

> **Contexto narrativo:** o CTO Carlos Mendes convocou a equipe: *"Precisamos de um serviço de notificações independente. Vocês têm autonomia total para criá-lo do zero — mas ele precisa nascer com tudo: testes, container, pipeline e deploy automatizado. Mostrem que aprenderam."* Este é o momento de demonstrar domínio.

> **☁️ Learner Lab:** o push de imagens e a infraestrutura usam o **Amazon ECR** e o **AWS Academy Learner Lab** (`us-east-1`, credenciais temporárias com `aws_session_token`, roles `LabRole`/`LabInstanceProfile`). Rode `terraform destroy` ao final.

---

## Parte 1 — Criação do Microserviço + Pipeline CI

### Atividade 1.1 — Estrutura do Projeto

**Objetivo:** Criar o microserviço technova-notifications do zero.

**Tarefas:**

1. Criar a estrutura de diretórios:

```
technova-notifications/
├── src/
│   ├── routes/
│   │   └── notifications.js
│   ├── services/
│   │   └── notificationService.js
│   └── server.js
├── tests/
│   ├── notifications.test.js
│   └── service.test.js
├── .eslintrc.json
├── .dockerignore
├── Dockerfile
├── docker-compose.yml
├── package.json
└── README.md
```

2. Inicializar o projeto Node.js:

```bash
mkdir technova-notifications && cd technova-notifications
npm init -y
npm install express cors dotenv
npm install --save-dev jest supertest eslint nodemon
```

3. Configurar scripts no `package.json`:

```json
{
  "name": "technova-notifications",
  "version": "1.0.0",
  "description": "Serviço de notificações da TechNova",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js",
    "test": "jest --coverage",
    "lint": "eslint src/ tests/"
  }
}
```

### Atividade 1.2 — Implementação das Rotas

**Objetivo:** Implementar a API do serviço de notificações.

**Código-base — src/server.js:**

```javascript
const express = require('express');
const cors = require('cors');
const notificationRoutes = require('./routes/notifications');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'technova-notifications',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Rotas de notificações
app.use('/notifications', notificationRoutes);

// Só inicia o servidor se não estiver em modo de teste
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`[technova-notifications] Rodando na porta ${PORT}`);
  });
}

module.exports = app;
```

**Código-base — src/routes/notifications.js:**

```javascript
const express = require('express');
const router = express.Router();
const notificationService = require('../services/notificationService');

// POST /notifications/send — Recebe e registra notificação
router.post('/send', (req, res) => {
  const { orderId, customerEmail, type, message } = req.body;

  // Validação
  if (!orderId || !customerEmail || !type || !message) {
    return res.status(400).json({
      error: 'Campos obrigatórios: orderId, customerEmail, type, message'
    });
  }

  const notification = notificationService.create({
    orderId, customerEmail, type, message
  });

  console.log(`[NOTIFICATION] Enviada: ${type} para ${customerEmail} (pedido: ${orderId})`);

  res.status(201).json({
    success: true,
    notification
  });
});

// GET /notifications — Lista todas as notificações
router.get('/', (req, res) => {
  const notifications = notificationService.getAll();
  res.json({
    total: notifications.length,
    notifications
  });
});

// GET /notifications/:orderId — Notificações de um pedido específico
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

**Código-base — src/services/notificationService.js:**

```javascript
const notifications = [];

const notificationService = {
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

  getAll() {
    return [...notifications];
  },

  getByOrderId(orderId) {
    return notifications.filter(n => n.orderId === orderId);
  },

  // Para testes — limpa o estado
  clear() {
    notifications.length = 0;
  }
};

module.exports = notificationService;
```

### Atividade 1.3 — Testes Unitários

**Objetivo:** Garantir qualidade com testes automatizados desde o início.

**Código — tests/notifications.test.js:**

```javascript
const request = require('supertest');
const app = require('../src/server');
const notificationService = require('../src/services/notificationService');

describe('API de Notificações', () => {
  beforeEach(() => {
    notificationService.clear();
  });

  describe('GET /health', () => {
    it('deve retornar status healthy', async () => {
      const res = await request(app).get('/health');
      expect(res.status).toBe(200);
      expect(res.body.status).toBe('healthy');
      expect(res.body.service).toBe('technova-notifications');
    });
  });

  describe('POST /notifications/send', () => {
    it('deve criar notificação com dados válidos', async () => {
      const payload = {
        orderId: 'order-001',
        customerEmail: 'teste@email.com',
        type: 'order_created',
        message: 'Seu pedido foi criado'
      };

      const res = await request(app)
        .post('/notifications/send')
        .send(payload);

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.notification.orderId).toBe('order-001');
      expect(res.body.notification.status).toBe('sent');
    });

    it('deve retornar 400 sem campos obrigatórios', async () => {
      const res = await request(app)
        .post('/notifications/send')
        .send({ orderId: 'order-001' });

      expect(res.status).toBe(400);
      expect(res.body.error).toContain('Campos obrigatórios');
    });
  });

  describe('GET /notifications', () => {
    it('deve listar notificações enviadas', async () => {
      // Cria uma notificação primeiro
      await request(app)
        .post('/notifications/send')
        .send({
          orderId: 'order-002',
          customerEmail: 'teste@email.com',
          type: 'order_created',
          message: 'Pedido criado'
        });

      const res = await request(app).get('/notifications');
      expect(res.status).toBe(200);
      expect(res.body.total).toBe(1);
      expect(res.body.notifications[0].orderId).toBe('order-002');
    });
  });
});
```

**Configuração Jest no package.json:**

```json
{
  "jest": {
    "testEnvironment": "node",
    "coverageThreshold": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80
      }
    }
  }
}
```

**Configuração ESLint — .eslintrc.json:**

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

**Verificação local:**

```bash
npm run lint
npm test
```

Todos os testes devem passar e o lint não deve ter erros antes de prosseguir.

### Atividade 1.4 — Containerização

**Objetivo:** Criar Dockerfile otimizado para produção.

**Dockerfile:**

```dockerfile
# Stage 1: Dependências
FROM node:18-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Build de teste (validação)
FROM node:18-alpine AS test
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run lint && npm test

# Stage 3: Produção
FROM node:18-alpine AS production
WORKDIR /app

# Segurança: usuário não-root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=dependencies /app/node_modules ./node_modules
COPY src/ ./src/
COPY package.json ./

# Health check integrado
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3001/health || exit 1

USER appuser
EXPOSE 3001

ENV NODE_ENV=production
ENV PORT=3001

CMD ["node", "src/server.js"]
```

**.dockerignore:**

```
node_modules
npm-debug.log
.git
.gitignore
tests/
coverage/
.env
*.md
```

**docker-compose.yml (desenvolvimento local):**

```yaml
version: '3.8'

services:
  technova-notifications:
    build: .
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=development
      - PORT=3001
    healthcheck:
      test: ["CMD", "wget", "--spider", "http://localhost:3001/health"]
      interval: 10s
      timeout: 3s
      retries: 3
```

**Teste local do container:**

```bash
docker build -t technova-notifications:local .
docker run -d -p 3001:3001 --name notif-test technova-notifications:local
curl http://localhost:3001/health
docker stop notif-test && docker rm notif-test
```

### Atividade 1.5 — Pipeline CI no GitHub Actions (push ECR)

**Objetivo:** Automatizar lint, testes, build e push da imagem para o Amazon ECR.

**Arquivo: .github/workflows/notifications-ci.yml**

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
    name: Lint
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./technova-notifications
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: technova-notifications/package-lock.json
      - run: npm ci
      - run: npm run lint

  test:
    name: Test
    runs-on: ubuntu-latest
    needs: lint
    defaults:
      run:
        working-directory: ./technova-notifications
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: technova-notifications/package-lock.json
      - run: npm ci
      - run: npm test
      - name: Upload coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: technova-notifications/coverage/

  build-and-push:
    name: Build & Push Docker Image (Amazon ECR)
    runs-on: ubuntu-latest
    needs: test
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
            type=sha,prefix=sha-
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build e Push
        uses: docker/build-push-action@v5
        with:
          context: ./technova-notifications
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

**Checklist Parte 1:**

- [ ] Microserviço roda localmente (`npm start`)
- [ ] Testes passam (`npm test`)
- [ ] Lint sem erros (`npm run lint`)
- [ ] Container builda e roda (`docker build` + `docker run`)
- [ ] Health check responde (`curl /health`)
- [ ] Pipeline CI executa com sucesso e publica a imagem no Amazon ECR

---

## Parte 2 — CD + Integração Multi-Serviço + E2E

### Atividade 2.1 — Infraestrutura com Terraform

**Objetivo:** Provisionar EC2 para o serviço de notificações no Learner Lab.

**Estrutura Terraform:**

```
terraform/
├── notifications/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── userdata.sh
```

**terraform/notifications/main.tf:**

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Security Group para o serviço de notificações
resource "aws_security_group" "notifications" {
  name        = "technova-notifications-sg"
  description = "Security group para technova-notifications"

  ingress {
    description = "HTTP do servico"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH para deploy"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "technova-notifications-sg"
    Project = "technova"
    Service = "notifications"
  }
}

# EC2 para technova-notifications
resource "aws_instance" "notifications" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.notifications.id]

  # Learner Lab: perfil pré-existente que permite o docker pull do ECR
  iam_instance_profile = "LabInstanceProfile"

  user_data = templatefile("userdata.sh", {
    docker_image = var.docker_image
    service_port = 3001
    aws_region   = var.aws_region
  })

  tags = {
    Name        = "technova-notifications"
    Project     = "technova"
    Service     = "notifications"
    Environment = var.environment
  }
}
```

**terraform/notifications/variables.tf:**

```hcl
variable "aws_region" {
  description = "Região AWS (Learner Lab: us-east-1)"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI do Amazon Linux 2023"
  type        = string
}

variable "key_name" {
  description = "Nome da key pair SSH"
  type        = string
}

variable "docker_image" {
  description = "Imagem Docker do serviço (ECR)"
  type        = string
}

variable "environment" {
  description = "Ambiente (staging/production)"
  default     = "staging"
}

variable "allowed_ssh_cidr" {
  description = "CIDR permitido para SSH"
  default     = "0.0.0.0/0"
}
```

**terraform/notifications/outputs.tf:**

```hcl
output "instance_public_ip" {
  description = "IP público da instância"
  value       = aws_instance.notifications.public_ip
}

output "instance_id" {
  description = "ID da instância"
  value       = aws_instance.notifications.id
}

output "service_url" {
  description = "URL do serviço"
  value       = "http://${aws_instance.notifications.public_ip}:3001"
}

output "health_check_url" {
  description = "URL do health check"
  value       = "http://${aws_instance.notifications.public_ip}:3001/health"
}
```

**terraform/notifications/userdata.sh:**

```bash
#!/bin/bash
set -e

# Instalar Docker e AWS CLI
yum update -y
yum install -y docker awscli
systemctl start docker
systemctl enable docker

# Login no Amazon ECR (credenciais do LabInstanceProfile)
ECR_REGISTRY=$(echo "${docker_image}" | cut -d'/' -f1)
aws ecr get-login-password --region ${aws_region} \
  | docker login --username AWS --password-stdin "$${ECR_REGISTRY}"

# Pull e run do serviço
docker pull ${docker_image}
docker run -d \
  --name technova-notifications \
  --restart unless-stopped \
  -p ${service_port}:${service_port} \
  -e NODE_ENV=production \
  -e PORT=${service_port} \
  ${docker_image}
```

### Atividade 2.2 — Pipeline CD com Deploy Automatizado

**Objetivo:** Automatizar deploy com health check e possibilidade de rollback.

**Arquivo: .github/workflows/notifications-cd.yml**

```yaml
name: CD — technova-notifications

on:
  workflow_run:
    workflows: ["CI — technova-notifications"]
    types: [completed]
    branches: [main]

env:
  IMAGE_NAME: technova-notifications
  AWS_REGION: us-east-1
  SERVICE_PORT: 3001

jobs:
  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    environment: staging
    steps:
      - uses: actions/checkout@v4

      - name: Configurar credenciais AWS (Learner Lab)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login no Amazon ECR
        id: ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.0

      - name: Terraform Init
        working-directory: ./terraform/notifications
        run: terraform init

      - name: Terraform Apply
        working-directory: ./terraform/notifications
        run: |
          terraform apply -auto-approve \
            -var="environment=staging" \
            -var="docker_image=${{ steps.ecr.outputs.registry }}/${{ env.IMAGE_NAME }}:latest" \
            -var="ami_id=${{ secrets.AMI_ID }}" \
            -var="key_name=${{ secrets.KEY_NAME }}"

      - name: Obter IP do serviço
        id: get-ip
        working-directory: ./terraform/notifications
        run: |
          echo "service_ip=$(terraform output -raw instance_public_ip)" >> $GITHUB_OUTPUT

      - name: Aguardar serviço iniciar
        run: sleep 30

      - name: Health Check
        run: |
          MAX_RETRIES=10
          RETRY_INTERVAL=10
          for i in $(seq 1 $MAX_RETRIES); do
            echo "Tentativa $i de $MAX_RETRIES..."
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
              http://${{ steps.get-ip.outputs.service_ip }}:${{ env.SERVICE_PORT }}/health || echo "000")
            if [ "$HTTP_CODE" = "200" ]; then
              echo "Health check OK!"
              exit 0
            fi
            echo "HTTP $HTTP_CODE — aguardando..."
            sleep $RETRY_INTERVAL
          done
          echo "Health check falhou após $MAX_RETRIES tentativas"
          exit 1

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: deploy-staging
    environment: production
    steps:
      - uses: actions/checkout@v4

      - name: Configurar credenciais AWS (Learner Lab)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login no Amazon ECR
        id: ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Deploy para Production
        working-directory: ./terraform/notifications
        run: |
          terraform init
          terraform apply -auto-approve \
            -var="environment=production" \
            -var="docker_image=${{ steps.ecr.outputs.registry }}/${{ env.IMAGE_NAME }}:latest" \
            -var="ami_id=${{ secrets.AMI_ID }}" \
            -var="key_name=${{ secrets.KEY_NAME }}"

      - name: Health Check Produção
        run: |
          IP=$(cd terraform/notifications && terraform output -raw instance_public_ip)
          curl --fail --retry 5 --retry-delay 10 \
            http://$IP:${{ env.SERVICE_PORT }}/health
```

### Atividade 2.3 — Comunicação Inter-Serviço

**Objetivo:** Integrar technova-api com technova-notifications via HTTP.

**Modificação no technova-api — nova rota que dispara notificação:**

Adicionar ao `technova-api/routes/orders.js`:

```javascript
const axios = require('axios');

const NOTIFICATIONS_URL = process.env.NOTIFICATIONS_URL || 'http://localhost:3001';

// Ao criar um pedido, dispara notificação
router.post('/', async (req, res) => {
  const { product, quantity, customerEmail } = req.body;

  // Criar o pedido (lógica existente)
  const order = {
    id: `order-${Date.now()}`,
    product,
    quantity,
    customerEmail,
    status: 'created',
    createdAt: new Date().toISOString()
  };

  // Disparar notificação para o serviço de notificações
  try {
    await axios.post(`${NOTIFICATIONS_URL}/notifications/send`, {
      orderId: order.id,
      customerEmail: customerEmail || 'cliente@technova.com',
      type: 'order_created',
      message: `Pedido ${order.id} criado: ${quantity}x ${product}`
    });
    order.notificationSent = true;
    console.log(`[ORDER] Notificação enviada para pedido ${order.id}`);
  } catch (error) {
    order.notificationSent = false;
    console.error(`[ORDER] Falha ao enviar notificação: ${error.message}`);
    // Não falha o pedido por causa da notificação (resiliência)
  }

  res.status(201).json(order);
});
```

**Atualizar docker-compose.yml para rodar ambos os serviços:**

```yaml
version: '3.8'

services:
  technova-api:
    build: ../technova-api
    ports:
      - "3000:3000"
    environment:
      - NOTIFICATIONS_URL=http://technova-notifications:3001
    depends_on:
      technova-notifications:
        condition: service_healthy

  technova-notifications:
    build: ../technova-notifications
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=production
      - PORT=3001
    healthcheck:
      test: ["CMD", "wget", "--spider", "http://localhost:3001/health"]
      interval: 10s
      timeout: 3s
      retries: 3
```

**Teste manual da integração:**

```bash
# Terminal 1: subir serviços
docker-compose up --build

# Terminal 2: criar pedido (deve disparar notificação)
curl -X POST http://localhost:3000/orders \
  -H "Content-Type: application/json" \
  -d '{"product": "Notebook", "quantity": 1, "customerEmail": "teste@email.com"}'

# Verificar se notificação foi registrada
curl http://localhost:3001/notifications
```

### Atividade 2.4 — Testes End-to-End

**Objetivo:** Validar o fluxo completo: criar pedido → notificação disparada → confirmação.

**Arquivo: tests/e2e/order-notification.e2e.test.js**

```javascript
const axios = require('axios');

const API_URL = process.env.API_URL || 'http://localhost:3000';
const NOTIFICATIONS_URL = process.env.NOTIFICATIONS_URL || 'http://localhost:3001';

describe('E2E: Fluxo Pedido → Notificação', () => {
  it('deve disparar notificação ao criar pedido', async () => {
    // 1. Criar pedido no technova-api
    const orderResponse = await axios.post(`${API_URL}/orders`, {
      product: 'Monitor 4K',
      quantity: 2,
      customerEmail: 'e2e-test@technova.com'
    });

    expect(orderResponse.status).toBe(201);
    expect(orderResponse.data.notificationSent).toBe(true);

    const orderId = orderResponse.data.id;

    // 2. Verificar notificação no technova-notifications
    const notifResponse = await axios.get(
      `${NOTIFICATIONS_URL}/notifications/${orderId}`
    );

    expect(notifResponse.status).toBe(200);
    expect(notifResponse.data.total).toBeGreaterThan(0);
    expect(notifResponse.data.notifications[0].orderId).toBe(orderId);
    expect(notifResponse.data.notifications[0].type).toBe('order_created');
    expect(notifResponse.data.notifications[0].customerEmail).toBe('e2e-test@technova.com');
  });

  it('deve registrar múltiplas notificações para pedidos diferentes', async () => {
    // Criar 3 pedidos
    const orders = [];
    for (let i = 0; i < 3; i++) {
      const res = await axios.post(`${API_URL}/orders`, {
        product: `Produto E2E ${i}`,
        quantity: i + 1,
        customerEmail: `e2e-${i}@technova.com`
      });
      orders.push(res.data);
    }

    // Verificar que todas as notificações existem
    const allNotifs = await axios.get(`${NOTIFICATIONS_URL}/notifications`);
    expect(allNotifs.data.total).toBeGreaterThanOrEqual(3);

    // Verificar cada pedido individualmente
    for (const order of orders) {
      const notif = await axios.get(
        `${NOTIFICATIONS_URL}/notifications/${order.id}`
      );
      expect(notif.data.total).toBe(1);
    }
  });

  it('health checks de ambos os serviços devem responder', async () => {
    const apiHealth = await axios.get(`${API_URL}/health`);
    const notifHealth = await axios.get(`${NOTIFICATIONS_URL}/health`);

    expect(apiHealth.status).toBe(200);
    expect(notifHealth.status).toBe(200);
    expect(notifHealth.data.service).toBe('technova-notifications');
  });
});
```

**Script para rodar E2E localmente:**

```bash
#!/bin/bash
# scripts/run-e2e.sh

echo "=== Iniciando serviços ==="
docker-compose up -d --build
sleep 10

echo "=== Verificando health checks ==="
curl -f http://localhost:3000/health || exit 1
curl -f http://localhost:3001/health || exit 1

echo "=== Rodando testes E2E ==="
API_URL=http://localhost:3000 \
NOTIFICATIONS_URL=http://localhost:3001 \
npx jest tests/e2e/ --runInBand

EXIT_CODE=$?

echo "=== Parando serviços ==="
docker-compose down

exit $EXIT_CODE
```

**Checklist Parte 2:**

- [ ] Terraform para infraestrutura (EC2 + SG + `LabInstanceProfile`)
- [ ] `terraform validate` passando
- [ ] Pipeline CD com deploy e health check
- [ ] Comunicação inter-serviço implementada
- [ ] Teste E2E validando fluxo completo

---

## Critérios de Avaliação

| Critério | Peso |
|----------|:----:|
| Microserviço funcional com testes passando | 30% |
| Containerização (multi-stage, non-root, healthcheck) | 20% |
| Pipeline CI publicando no Amazon ECR | 25% |
| Terraform + CD + integração/E2E | 25% |

---

## Entrega

### Onde entregar

No fork do repositório da disciplina, na pasta de entrega da aula:

```
entregas/aula-13/SEU-RA/trabalho-em-aula.md
```

### O que entregar

Um arquivo `trabalho-em-aula.md` com o relato das atividades realizadas em sala e os links/evidências:

```markdown
# Trabalho em Aula — Aula 13: Microserviço com Pipeline E2E

**Aluno:** [Seu nome completo]
**RA:** [Seu RA]
**Data:** [Data da aula]

## O que consegui concluir

- [ ] Microserviço technova-notifications rodando com testes
- [ ] Container buildando e respondendo health check
- [ ] Pipeline CI publicando no Amazon ECR
- [ ] Terraform validado (EC2 + SG + LabInstanceProfile)
- [ ] Pipeline CD + health check
- [ ] Integração technova-api → notifications
- [ ] Teste E2E do fluxo completo

## Evidências

- Link do repositório / PR: ...
- Screenshots (CI verde, console ECR, health check, E2E): ...

## Observações

(O que não consegui completar e por quê)
```

### Como entregar

- O arquivo pode ser adicionado no **mesmo PR** do TF ou em PR separado
- A entrega é **individual**
- O trabalho em aula vale **1 ponto na nota final** do semestre (contabilizado apenas ao final, com **todos** os trabalhos entregues)
