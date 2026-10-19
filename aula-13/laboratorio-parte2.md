# Laboratório Parte 2 — Pipeline CD + Integração Multi-Serviço + E2E

## Aula 13 — Novo Microserviço com Pipeline End-to-End

### Objetivo

Completar o ciclo DevOps: provisionar infraestrutura com Terraform, automatizar o deploy, integrar o `technova-notifications` com o `technova-api`, e validar com testes end-to-end. A imagem vem do **Amazon ECR** e a infra roda no **AWS Academy Learner Lab**.

**Pré-requisito:** Laboratório Parte 1 completo (microserviço + CI publicando no ECR funcionando)

---

### Contexto

O serviço de notificações está pronto e a CI funcionando, publicando a imagem no Amazon ECR. Agora a TechNova precisa que ele vá para produção — com infraestrutura automatizada, deploy confiável, e comunicação com o serviço principal. O CTO quer ver o fluxo completo funcionando.

> **☁️ AWS Academy Learner Lab:** toda a infraestrutura roda em `us-east-1` com as credenciais temporárias da sessão. O Lab **não permite criar roles IAM**, então a EC2 usa o perfil pré-existente **`LabInstanceProfile`** para conseguir fazer `docker pull` do ECR. Rode `terraform destroy` ao final da sessão para liberar os recursos.

---

## Etapa 1 — Infraestrutura com Terraform

### 1.1 Criar estrutura de diretórios Terraform

```bash
mkdir -p terraform/notifications
cd terraform/notifications
```

### 1.2 Criar main.tf

```hcl
terraform {
  required_version = ">= 1.5.0"

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

# Security Group — controle de acesso ao serviço
resource "aws_security_group" "notifications" {
  name        = "technova-notifications-${var.environment}-sg"
  description = "Security group para technova-notifications (${var.environment})"

  # Porta do serviço
  ingress {
    description = "Acesso ao servico de notificacoes"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = var.allowed_service_cidrs
  }

  # SSH para deploy/manutenção
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Saída irrestrita (para pull de imagens)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "technova-notifications-${var.environment}-sg"
    Project     = "technova"
    Service     = "notifications"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# EC2 Instance — servidor do microserviço
resource "aws_instance" "notifications" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.notifications.id]

  # Learner Lab: perfil pré-existente que permite o docker pull do ECR
  # (o Lab não permite criar roles IAM — usamos o LabInstanceProfile).
  iam_instance_profile = "LabInstanceProfile"

  user_data = templatefile("${path.module}/userdata.sh", {
    docker_image = var.docker_image
    service_port = 3001
    environment  = var.environment
    service_name = "technova-notifications"
    aws_region   = var.aws_region
  })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name        = "technova-notifications-${var.environment}"
    Project     = "technova"
    Service     = "notifications"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
```

### 1.3 Criar variables.tf

```hcl
variable "aws_region" {
  description = "Região AWS (Learner Lab: sempre us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de deploy (staging ou production)"
  type        = string
  default     = "staging"

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment deve ser 'staging' ou 'production'."
  }
}

variable "ami_id" {
  description = "ID da AMI (Amazon Linux 2023)"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nome da key pair para acesso SSH"
  type        = string
}

variable "docker_image" {
  description = "Imagem Docker completa (<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/technova-notifications:tag)"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block permitido para SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_service_cidrs" {
  description = "CIDR blocks permitidos para acessar o serviço"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
```

### 1.4 Criar outputs.tf

```hcl
output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.notifications.id
}

output "instance_public_ip" {
  description = "IP público da instância"
  value       = aws_instance.notifications.public_ip
}

output "service_url" {
  description = "URL base do serviço"
  value       = "http://${aws_instance.notifications.public_ip}:3001"
}

output "health_check_url" {
  description = "URL do health check"
  value       = "http://${aws_instance.notifications.public_ip}:3001/health"
}

output "security_group_id" {
  description = "ID do Security Group"
  value       = aws_security_group.notifications.id
}
```

### 1.5 Criar userdata.sh

O `userdata` instala o Docker, faz **login no Amazon ECR** (usando as credenciais do `LabInstanceProfile`) e sobe o container a partir da imagem publicada no ECR:

```bash
#!/bin/bash
set -euo pipefail

# Log de instalação
exec > /var/log/userdata.log 2>&1
echo "=== Início da instalação: $(date) ==="

# Atualizar sistema
yum update -y

# Instalar Docker e AWS CLI
yum install -y docker awscli
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Instalar Docker Compose
COMPOSE_VERSION="2.24.0"
curl -L "https://github.com/docker/compose/releases/download/v$${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Login no Amazon ECR (credenciais fornecidas pelo LabInstanceProfile)
echo "=== Login no Amazon ECR ==="
ECR_REGISTRY=$(echo "${docker_image}" | cut -d'/' -f1)
aws ecr get-login-password --region ${aws_region} \
  | docker login --username AWS --password-stdin "$${ECR_REGISTRY}"

# Pull da imagem do serviço
echo "=== Pulling image: ${docker_image} ==="
docker pull ${docker_image}

# Rodar o serviço
echo "=== Starting service: ${service_name} ==="
docker run -d \
  --name ${service_name} \
  --restart unless-stopped \
  -p ${service_port}:${service_port} \
  -e NODE_ENV=${environment} \
  -e PORT=${service_port} \
  --log-driver json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  ${docker_image}

# Aguardar e verificar saúde
echo "=== Aguardando serviço iniciar ==="
sleep 10

for i in $(seq 1 12); do
  if curl -sf http://localhost:${service_port}/health > /dev/null; then
    echo "=== Serviço saudável! ==="
    exit 0
  fi
  echo "Tentativa $i/12 — aguardando..."
  sleep 5
done

echo "=== AVISO: Serviço não respondeu ao health check ==="
docker logs ${service_name}
```

### 1.6 Validar Terraform localmente

```bash
cd terraform/notifications
terraform init
terraform validate
terraform plan -var="ami_id=ami-0c02fb55956c7d316" \
  -var="key_name=minha-chave" \
  -var="docker_image=<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/technova-notifications:latest"
```

**Checkpoint:** Terraform valida e mostra plano de execução correto.

---

## Etapa 2 — Pipeline CD Automatizada

### 2.1 Criar workflow de deploy

Criar `.github/workflows/notifications-cd.yml`:

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
  TF_WORKING_DIR: ./terraform/notifications

jobs:
  deploy-staging:
    name: "Deploy → Staging"
    runs-on: ubuntu-latest
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    environment:
      name: staging
      url: http://${{ steps.get-ip.outputs.ip }}:3001
    outputs:
      staging_ip: ${{ steps.get-ip.outputs.ip }}

    steps:
      - name: Checkout
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

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.6.0"
          terraform_wrapper: false

      - name: Terraform Init
        working-directory: ${{ env.TF_WORKING_DIR }}
        run: terraform init

      - name: Terraform Apply (Staging)
        working-directory: ${{ env.TF_WORKING_DIR }}
        run: |
          terraform apply -auto-approve \
            -var="environment=staging" \
            -var="docker_image=${{ steps.ecr.outputs.registry }}/${{ env.IMAGE_NAME }}:latest" \
            -var="ami_id=${{ secrets.AMI_ID }}" \
            -var="key_name=${{ secrets.KEY_NAME }}"

      - name: Obter IP da instância
        id: get-ip
        working-directory: ${{ env.TF_WORKING_DIR }}
        run: |
          IP=$(terraform output -raw instance_public_ip)
          echo "ip=$IP" >> $GITHUB_OUTPUT
          echo "Serviço será acessível em: http://$IP:${{ env.SERVICE_PORT }}"

      - name: Aguardar inicialização
        run: sleep 45

      - name: Health Check (Staging)
        run: |
          IP="${{ steps.get-ip.outputs.ip }}"
          MAX_RETRIES=12
          RETRY_INTERVAL=10

          echo "Verificando saúde do serviço em http://$IP:${{ env.SERVICE_PORT }}/health"

          for i in $(seq 1 $MAX_RETRIES); do
            HTTP_CODE=$(curl -s -o /tmp/health_response -w "%{http_code}" \
              "http://$IP:${{ env.SERVICE_PORT }}/health" 2>/dev/null || echo "000")

            if [ "$HTTP_CODE" = "200" ]; then
              echo "✅ Health check OK na tentativa $i!"
              cat /tmp/health_response | jq . 2>/dev/null || cat /tmp/health_response
              exit 0
            fi

            echo "⏳ Tentativa $i/$MAX_RETRIES — HTTP $HTTP_CODE — aguardando ${RETRY_INTERVAL}s..."
            sleep $RETRY_INTERVAL
          done

          echo "❌ Health check falhou após $MAX_RETRIES tentativas"
          exit 1

      - name: Smoke Test (Staging)
        run: |
          IP="${{ steps.get-ip.outputs.ip }}"

          # Testar criação de notificação
          RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
            "http://$IP:${{ env.SERVICE_PORT }}/notifications/send" \
            -H "Content-Type: application/json" \
            -d '{"orderId":"smoke-test","customerEmail":"ci@test.com","type":"order_created","message":"Smoke test"}')

          HTTP_CODE=$(echo "$RESPONSE" | tail -1)
          BODY=$(echo "$RESPONSE" | head -n -1)

          if [ "$HTTP_CODE" = "201" ]; then
            echo "✅ Smoke test OK — Notificação criada com sucesso"
            echo "$BODY" | jq .
          else
            echo "❌ Smoke test falhou — HTTP $HTTP_CODE"
            echo "$BODY"
            exit 1
          fi

  deploy-production:
    name: "Deploy → Production"
    runs-on: ubuntu-latest
    needs: deploy-staging
    environment:
      name: production
      url: http://${{ steps.get-ip.outputs.ip }}:3001

    steps:
      - name: Checkout
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

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.6.0"
          terraform_wrapper: false

      - name: Terraform Init & Apply (Production)
        working-directory: ${{ env.TF_WORKING_DIR }}
        run: |
          terraform init
          terraform apply -auto-approve \
            -var="environment=production" \
            -var="docker_image=${{ steps.ecr.outputs.registry }}/${{ env.IMAGE_NAME }}:latest" \
            -var="ami_id=${{ secrets.AMI_ID }}" \
            -var="key_name=${{ secrets.KEY_NAME }}"

      - name: Obter IP da instância
        id: get-ip
        working-directory: ${{ env.TF_WORKING_DIR }}
        run: echo "ip=$(terraform output -raw instance_public_ip)" >> $GITHUB_OUTPUT

      - name: Health Check (Production)
        run: |
          IP="${{ steps.get-ip.outputs.ip }}"
          curl --fail --retry 10 --retry-delay 10 --retry-all-errors \
            "http://$IP:${{ env.SERVICE_PORT }}/health"
          echo ""
          echo "✅ Serviço em produção e saudável!"
```

> **☁️ Learner Lab:** os secrets `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` e `AWS_SESSION_TOKEN` são **temporários** e precisam ser atualizados a cada nova sessão do Lab. Se o deploy falhar com erro de credencial expirada, reabra o Lab e atualize os três secrets.

**Checkpoint:** Pipeline CD configurada com promoção staging → production.

---

## Etapa 3 — Comunicação Inter-Serviço

### 3.1 Modificar technova-api para chamar notifications

Instalar axios no technova-api:

```bash
cd technova-api
npm install axios
```

Atualizar a rota de criação de pedidos para disparar notificação:

**technova-api/routes/orders.js** — adicionar integração:

```javascript
const axios = require('axios');

const NOTIFICATIONS_URL = process.env.NOTIFICATIONS_URL || 'http://localhost:3001';

// Função helper para enviar notificação (com resiliência)
async function sendNotification(orderData) {
  try {
    const response = await axios.post(
      `${NOTIFICATIONS_URL}/notifications/send`,
      {
        orderId: orderData.id,
        customerEmail: orderData.customerEmail || 'cliente@technova.com',
        type: 'order_created',
        message: `Pedido ${orderData.id} criado: ${orderData.quantity}x ${orderData.product}`
      },
      { timeout: 5000 } // timeout de 5 segundos
    );
    return { sent: true, notificationId: response.data.notification.id };
  } catch (error) {
    console.error(`[NOTIFICATION ERROR] ${error.message}`);
    // Não falhar o pedido por causa de notificação (circuit breaker simplificado)
    return { sent: false, error: error.message };
  }
}

// Rota de criação de pedido com notificação
router.post('/', async (req, res) => {
  const { product, quantity, customerEmail } = req.body;

  if (!product || !quantity) {
    return res.status(400).json({ error: 'product e quantity são obrigatórios' });
  }

  const order = {
    id: `order-${Date.now()}-${Math.random().toString(36).substr(2, 6)}`,
    product,
    quantity: parseInt(quantity),
    customerEmail: customerEmail || 'cliente@technova.com',
    status: 'created',
    createdAt: new Date().toISOString()
  };

  // Disparar notificação (não bloqueia em caso de falha)
  const notificationResult = await sendNotification(order);
  order.notification = notificationResult;

  console.log(`[ORDER] Pedido ${order.id} criado | Notificação: ${notificationResult.sent}`);

  res.status(201).json(order);
});
```

### 3.2 Configurar variável de ambiente

Atualizar `.env` do technova-api:

```env
PORT=3000
NOTIFICATIONS_URL=http://localhost:3001
```

### 3.3 Docker Compose multi-serviço

Criar `docker-compose.multi.yml` na raiz do projeto:

```yaml
version: '3.8'

services:
  technova-api:
    build:
      context: ./technova-api
    ports:
      - "3000:3000"
    environment:
      - PORT=3000
      - NODE_ENV=development
      - NOTIFICATIONS_URL=http://technova-notifications:3001
    depends_on:
      technova-notifications:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "--spider", "http://localhost:3000/health"]
      interval: 10s
      timeout: 3s
      retries: 5
    networks:
      - technova-network

  technova-notifications:
    build:
      context: ./technova-notifications
    ports:
      - "3001:3001"
    environment:
      - PORT=3001
      - NODE_ENV=development
    healthcheck:
      test: ["CMD", "wget", "--spider", "http://localhost:3001/health"]
      interval: 10s
      timeout: 3s
      start_period: 5s
      retries: 3
    networks:
      - technova-network

networks:
  technova-network:
    driver: bridge
```

### 3.4 Testar comunicação localmente

```bash
# Subir ambos os serviços
docker-compose -f docker-compose.multi.yml up --build -d

# Verificar que ambos estão saudáveis
docker-compose -f docker-compose.multi.yml ps

# Criar pedido (deve disparar notificação automaticamente)
curl -X POST http://localhost:3000/orders \
  -H "Content-Type: application/json" \
  -d '{
    "product": "Notebook Dell",
    "quantity": 1,
    "customerEmail": "joao@empresa.com"
  }'

# Verificar que a notificação foi registrada
curl http://localhost:3001/notifications | jq .

# Verificar logs de comunicação
docker-compose -f docker-compose.multi.yml logs technova-api | grep NOTIFICATION
docker-compose -f docker-compose.multi.yml logs technova-notifications | grep NOTIFICATION
```

**Resultado esperado:**
- Pedido criado com `notification.sent: true`
- Notificação aparece no GET /notifications
- Logs mostram comunicação entre serviços

**Checkpoint:** Serviços se comunicam via HTTP com sucesso.

---

## Etapa 4 — Testes End-to-End

### 4.1 Criar estrutura de testes E2E

```bash
mkdir -p tests/e2e
```

### 4.2 Criar teste E2E — tests/e2e/order-notification-flow.test.js

```javascript
const axios = require('axios');

// URLs configuráveis via variável de ambiente
const API_URL = process.env.API_URL || 'http://localhost:3000';
const NOTIFICATIONS_URL = process.env.NOTIFICATIONS_URL || 'http://localhost:3001';

// Timeout maior para E2E
jest.setTimeout(30000);

describe('E2E: Fluxo Completo — Pedido → Notificação', () => {

  describe('Pré-condições', () => {
    it('technova-api está saudável', async () => {
      const res = await axios.get(`${API_URL}/health`);
      expect(res.status).toBe(200);
      expect(res.data.status).toBe('healthy');
    });

    it('technova-notifications está saudável', async () => {
      const res = await axios.get(`${NOTIFICATIONS_URL}/health`);
      expect(res.status).toBe(200);
      expect(res.data.status).toBe('healthy');
      expect(res.data.service).toBe('technova-notifications');
    });
  });

  describe('Fluxo: Criar Pedido → Receber Notificação', () => {
    let createdOrderId;

    it('1. Cria pedido no technova-api', async () => {
      const res = await axios.post(`${API_URL}/orders`, {
        product: 'Monitor Ultrawide 34"',
        quantity: 2,
        customerEmail: 'e2e-test@technova.com'
      });

      expect(res.status).toBe(201);
      expect(res.data).toHaveProperty('id');
      expect(res.data.product).toBe('Monitor Ultrawide 34"');
      expect(res.data.quantity).toBe(2);
      expect(res.data.notification.sent).toBe(true);

      createdOrderId = res.data.id;
      console.log(`Pedido criado: ${createdOrderId}`);
    });

    it('2. Notificação foi registrada no technova-notifications', async () => {
      const res = await axios.get(
        `${NOTIFICATIONS_URL}/notifications/${createdOrderId}`
      );

      expect(res.status).toBe(200);
      expect(res.data.orderId).toBe(createdOrderId);
      expect(res.data.total).toBeGreaterThan(0);

      const notification = res.data.notifications[0];
      expect(notification.orderId).toBe(createdOrderId);
      expect(notification.customerEmail).toBe('e2e-test@technova.com');
      expect(notification.type).toBe('order_created');
      expect(notification.status).toBe('sent');
      expect(notification).toHaveProperty('createdAt');
    });

    it('3. Notificação contém mensagem descritiva do pedido', async () => {
      const res = await axios.get(
        `${NOTIFICATIONS_URL}/notifications/${createdOrderId}`
      );

      const notification = res.data.notifications[0];
      expect(notification.message).toContain(createdOrderId);
      expect(notification.message).toContain('Monitor Ultrawide');
    });
  });

  describe('Fluxo: Múltiplos Pedidos', () => {
    it('cada pedido gera sua própria notificação', async () => {
      const orders = [];

      // Criar 3 pedidos
      for (let i = 0; i < 3; i++) {
        const res = await axios.post(`${API_URL}/orders`, {
          product: `Produto E2E #${i + 1}`,
          quantity: i + 1,
          customerEmail: `bulk-test-${i}@technova.com`
        });
        expect(res.status).toBe(201);
        orders.push(res.data);
      }

      // Verificar cada notificação
      for (const order of orders) {
        const res = await axios.get(
          `${NOTIFICATIONS_URL}/notifications/${order.id}`
        );
        expect(res.data.total).toBe(1);
        expect(res.data.notifications[0].customerEmail).toContain('bulk-test');
      }
    });
  });

  describe('Resiliência', () => {
    it('pedido é criado mesmo se campos opcionais faltam', async () => {
      const res = await axios.post(`${API_URL}/orders`, {
        product: 'Teclado Mecânico',
        quantity: 1
        // customerEmail omitido — deve usar default
      });

      expect(res.status).toBe(201);
      expect(res.data.notification.sent).toBe(true);
    });
  });

  describe('Estatísticas', () => {
    it('stats refletem notificações criadas durante o teste', async () => {
      const res = await axios.get(`${NOTIFICATIONS_URL}/notifications/stats`);

      expect(res.status).toBe(200);
      expect(res.data.total).toBeGreaterThan(0);
      expect(res.data.byType).toHaveProperty('order_created');
    });
  });
});
```

### 4.3 Criar script de execução E2E

Criar `scripts/run-e2e.sh`:

```bash
#!/bin/bash
set -e

echo "╔══════════════════════════════════════════╗"
echo "║  E2E Test — TechNova Multi-Service      ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Configuração
COMPOSE_FILE="docker-compose.multi.yml"
API_URL="http://localhost:3000"
NOTIFICATIONS_URL="http://localhost:3001"
MAX_WAIT=60

# 1. Subir serviços
echo "▶ Iniciando serviços..."
docker-compose -f $COMPOSE_FILE up -d --build
echo ""

# 2. Aguardar serviços ficarem saudáveis
echo "▶ Aguardando serviços ficarem saudáveis (máx ${MAX_WAIT}s)..."
SECONDS=0
until curl -sf "$NOTIFICATIONS_URL/health" > /dev/null 2>&1 && \
      curl -sf "$API_URL/health" > /dev/null 2>&1; do
  if [ $SECONDS -ge $MAX_WAIT ]; then
    echo "❌ Timeout! Serviços não ficaram saudáveis em ${MAX_WAIT}s"
    docker-compose -f $COMPOSE_FILE logs
    docker-compose -f $COMPOSE_FILE down
    exit 1
  fi
  echo "  ⏳ Aguardando... (${SECONDS}s)"
  sleep 5
done
echo "✅ Ambos os serviços estão saudáveis!"
echo ""

# 3. Rodar testes E2E
echo "▶ Executando testes E2E..."
echo ""
API_URL=$API_URL \
NOTIFICATIONS_URL=$NOTIFICATIONS_URL \
npx jest tests/e2e/ --runInBand --verbose

EXIT_CODE=$?

# 4. Cleanup
echo ""
echo "▶ Parando serviços..."
docker-compose -f $COMPOSE_FILE down

# 5. Resultado
echo ""
if [ $EXIT_CODE -eq 0 ]; then
  echo "╔══════════════════════════════════════════╗"
  echo "║  ✅ TODOS OS TESTES E2E PASSARAM!       ║"
  echo "╚══════════════════════════════════════════╝"
else
  echo "╔══════════════════════════════════════════╗"
  echo "║  ❌ TESTES E2E FALHARAM                 ║"
  echo "╚══════════════════════════════════════════╝"
fi

exit $EXIT_CODE
```

```bash
chmod +x scripts/run-e2e.sh
./scripts/run-e2e.sh
```

### 4.4 Adicionar E2E à pipeline (opcional)

Adicionar job de E2E no workflow CD, após deploy em staging:

```yaml
  e2e-tests:
    name: "E2E Tests"
    runs-on: ubuntu-latest
    needs: deploy-staging
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: Instalar dependências de teste
        run: npm install axios jest

      - name: Executar testes E2E contra staging
        env:
          API_URL: http://${{ needs.deploy-staging.outputs.staging_ip }}:3000
          NOTIFICATIONS_URL: http://${{ needs.deploy-staging.outputs.staging_ip }}:3001
        run: npx jest tests/e2e/ --runInBand
```

**Checkpoint:** Testes E2E passando com fluxo completo validado.

---

## Etapa 5 — Promoção de Ambientes

### 5.1 Entender o fluxo de promoção

```
Developer Push → CI (lint+test+build+push ECR) → Deploy Staging → E2E Tests → Aprovação Manual → Deploy Production
```

### 5.2 Configurar environments no GitHub

1. Acessar **Settings → Environments** no repositório
2. Criar environment `staging` (deploy automático)
3. Criar environment `production` com:
   - Required reviewers: adicionar professor ou colega
   - Wait timer (opcional)

### 5.3 Verificar fluxo completo

```bash
# Fazer uma alteração no serviço
echo "// versão 1.1" >> technova-notifications/src/server.js
git add -A
git commit -m "feat(notifications): bump version para testar pipeline completa"
git push
```

Observar no GitHub Actions:
1. CI executa (lint → test → build → push ECR)
2. CD dispara automaticamente após CI
3. Deploy em staging + health check
4. Aguarda aprovação para production
5. Deploy em production + health check final

---

## Validação Final — Parte 2

### Testes de verificação completa

```bash
# 1. Terraform válido
cd terraform/notifications && terraform validate && echo "TF OK"

# 2. Multi-serviço funcionando
cd ../.. && docker-compose -f docker-compose.multi.yml up -d --build
sleep 15

# 3. Comunicação inter-serviço
curl -X POST http://localhost:3000/orders \
  -H "Content-Type: application/json" \
  -d '{"product":"Teste Final","quantity":1,"customerEmail":"final@test.com"}' | jq .

# 4. Notificação recebida
curl http://localhost:3001/notifications | jq .

# 5. E2E passando
./scripts/run-e2e.sh

# 6. Cleanup
docker-compose -f docker-compose.multi.yml down
```

### Critérios de sucesso

| Critério | Status |
|----------|--------|
| Terraform valida sem erros | ⬜ |
| `LabInstanceProfile` associado à EC2 | ⬜ |
| Pipeline CD configurada (staging → production) | ⬜ |
| Health check automatizado no deploy | ⬜ |
| Comunicação HTTP entre serviços funciona | ⬜ |
| Resiliência: pedido não falha se notificação falhar | ⬜ |
| Teste E2E valida fluxo completo | ⬜ |
| Pipeline completa executa no GitHub Actions | ⬜ |

---

## Problemas Comuns

| Problema | Solução |
|----------|---------|
| Serviços não se comunicam no docker-compose | Verificar `network` e nome do serviço na URL |
| `docker pull` do ECR falha na EC2 | Confirmar que a instância tem o `LabInstanceProfile` e que o login ECR rodou no userdata |
| Terraform falha com "credentials" / token expirado | Reabra o Learner Lab e atualize os secrets AWS no GitHub |
| Health check timeout no deploy | Aumentar `sleep` antes do check e número de retries |
| E2E falha com "ECONNREFUSED" | Serviços ainda não estão prontos — aumentar tempo de espera |
| axios timeout na comunicação | Verificar se notifications está rodando na porta correta |

---

## Entrega

Após completar ambas as partes, publique o projeto no `unifaat-devops-portfolio` (pasta `aula-13/`) e registre a entrega via PR em `entregas/aula-13/SEU-RA/` (ver TF.md). **Lembre-se de rodar `terraform destroy` ao final da sessão do Learner Lab.**
