# Materiais Complementares — Aula 13: Novo Microserviço com Pipeline End-to-End

## Microserviços — Conceitos e Arquitetura

### Artigos e Documentação

| Recurso | Descrição | Link |
|---------|-----------|------|
| 12-Factor App (PT-BR) | Os 12 fatores para aplicações modernas | https://12factor.net/pt_br/ |
| Microservices.io | Padrões de microserviços — Chris Richardson | https://microservices.io/patterns/ |
| Martin Fowler — Microservices | Artigo seminal sobre a arquitetura | https://martinfowler.com/articles/microservices.html |
| Comunicação entre microserviços | Síncrona vs assíncrona | https://microservices.io/patterns/communication-style/ |

### Vídeos

| Recurso | Link |
|---------|------|
| Microservices explained (IBM) | https://www.youtube.com/watch?v=CdBtNQZH8a4 |
| Design Microservice Architectures | https://www.youtube.com/watch?v=cCErSMsJqbY |

---

## Node.js / Express — Boas Práticas

### Documentação Oficial

| Recurso | Descrição | Link |
|---------|-----------|------|
| Express.js — Getting Started | Guia oficial do Express | https://expressjs.com/pt-br/starter/installing.html |
| Express — Boas práticas de produção | Segurança e performance | https://expressjs.com/pt-br/advanced/best-practice-security.html |
| Jest — Documentação | Framework de testes | https://jestjs.io/pt-BR/docs/getting-started |
| Supertest | Testes HTTP para Node.js | https://github.com/ladjs/supertest |

### Padrões de Código

| Recurso | Descrição | Link |
|---------|-----------|------|
| ESLint — Configuração | Guia de configuração | https://eslint.org/docs/latest/use/configure/ |
| Node.js Best Practices | Lista curada de boas práticas | https://github.com/goldbergyoni/nodebestpractices |
| Estrutura de projeto Node.js | Organização recomendada | https://github.com/goldbergyoni/nodebestpractices#1-project-structure-practices |

---

## Docker — Otimização e Segurança

### Documentação

| Recurso | Descrição | Link |
|---------|-----------|------|
| Multi-stage Builds | Otimizar imagens com múltiplos estágios | https://docs.docker.com/build/building/multi-stage/ |
| Dockerfile Best Practices | Guia oficial de boas práticas | https://docs.docker.com/develop/develop-images/dockerfile_best-practices/ |
| HEALTHCHECK instruction | Configurar health checks nativos | https://docs.docker.com/engine/reference/builder/#healthcheck |
| Docker Security | Boas práticas de segurança | https://docs.docker.com/engine/security/ |
| .dockerignore | Otimizar contexto de build | https://docs.docker.com/engine/reference/builder/#dockerignore-file |

### Dicas de Otimização

```dockerfile
# Usar alpine para imagens menores
FROM node:18-alpine

# Cache de dependências (copiar package.json antes do código)
COPY package*.json ./
RUN npm ci --only=production

# Depois copiar o código (muda com mais frequência)
COPY src/ ./src/
```

---

## Registry — Amazon ECR

### Documentação

| Recurso | Descrição | Link |
|---------|-----------|------|
| Amazon ECR — User Guide | Registry da AWS (**usado nesta aula**) | https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html |
| Push de imagem no Amazon ECR | Build + push passo a passo | https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html |
| Autenticação no ECR (`get-login-password`) | Login do Docker com token temporário | https://docs.aws.amazon.com/AmazonECR/latest/userguide/registry_auth.html |
| aws-actions/amazon-ecr-login | Action da AWS para login no ECR no CI | https://github.com/aws-actions/amazon-ecr-login |
| aws-actions/configure-aws-credentials | Configurar credenciais AWS no CI (com session token) | https://github.com/aws-actions/configure-aws-credentials |

> O registry oficial do curso é o **Amazon ECR**, no AWS Academy Learner Lab. Docker Hub e GitHub Container Registry (ghcr.io) aparecem apenas como alternativas de comparação.

---

## GitHub Actions — Pipelines CI/CD

### Documentação Oficial

| Recurso | Descrição | Link |
|---------|-----------|------|
| GitHub Actions — Quickstart | Começar com Actions | https://docs.github.com/en/actions/quickstart |
| Workflow Syntax | Referência completa da sintaxe YAML | https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions |
| Environments | Configurar staging/production | https://docs.github.com/en/actions/deployment/targeting-different-environments |
| Reusable Workflows | Reutilizar workflows entre repos | https://docs.github.com/en/actions/using-workflows/reusing-workflows |

### Actions Úteis

| Action | Uso | Link |
|--------|-----|------|
| actions/checkout@v4 | Checkout do código | https://github.com/actions/checkout |
| actions/setup-node@v4 | Configurar Node.js | https://github.com/actions/setup-node |
| docker/build-push-action@v5 | Build e push Docker | https://github.com/docker/build-push-action |
| docker/metadata-action@v5 | Gerar tags automáticas | https://github.com/docker/metadata-action |
| hashicorp/setup-terraform@v3 | Setup Terraform | https://github.com/hashicorp/setup-terraform |
| aws-actions/configure-aws-credentials@v4 | Credenciais AWS (Learner Lab: com session token) | https://github.com/aws-actions/configure-aws-credentials |
| aws-actions/amazon-ecr-login@v2 | Login no Amazon ECR | https://github.com/aws-actions/amazon-ecr-login |

---

## Terraform — Infraestrutura como Código

### Documentação

| Recurso | Descrição | Link |
|---------|-----------|------|
| Terraform — Get Started (AWS) | Tutorial para iniciantes com AWS | https://developer.hashicorp.com/terraform/tutorials/aws-get-started |
| AWS Provider | Documentação do provider AWS | https://registry.terraform.io/providers/hashicorp/aws/latest/docs |
| aws_instance | Recurso EC2 | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance |
| aws_security_group | Recurso Security Group | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group |
| templatefile() | Função para templates | https://developer.hashicorp.com/terraform/language/functions/templatefile |
| Terraform Best Practices | Guia de boas práticas | https://developer.hashicorp.com/terraform/cloud-docs/recommended-practices |

### Comandos Essenciais

```bash
terraform init       # Inicializar providers
terraform validate   # Validar sintaxe HCL
terraform plan       # Prever alterações
terraform apply      # Aplicar alterações
terraform output     # Ver outputs
terraform destroy    # Destruir infraestrutura (rode ao final da sessão do Lab)
```

---

## Testes — Unitários e E2E

### Frameworks e Ferramentas

| Recurso | Descrição | Link |
|---------|-----------|------|
| Jest — Expect API | Assertions disponíveis | https://jestjs.io/pt-BR/docs/expect |
| Jest — Mock Functions | Mockar dependências | https://jestjs.io/pt-BR/docs/mock-functions |
| Supertest — Exemplos | Testes de API HTTP | https://github.com/ladjs/supertest#example |
| Axios | Cliente HTTP para E2E | https://axios-http.com/ptbr/docs/intro |

### Padrão de Teste AAA

```javascript
describe('Funcionalidade', () => {
  it('deve fazer algo específico', async () => {
    // Arrange — preparar dados
    const input = { ... };

    // Act — executar a ação
    const result = await request(app).post('/rota').send(input);

    // Assert — verificar resultado
    expect(result.status).toBe(201);
  });
});
```

---

## Comunicação entre Serviços

### Padrões

| Padrão | Quando Usar | Complexidade |
|--------|-------------|-------------|
| HTTP/REST síncrono | Comunicação simples, resposta imediata | Baixa |
| Mensageria (RabbitMQ, SQS) | Desacoplamento, processamento assíncrono | Média |
| gRPC | Alta performance, contratos fortes | Alta |
| Event Sourcing | Histórico completo, auditoria | Alta |

**Nesta aula usamos HTTP/REST síncrono** — o padrão mais simples e adequado para o cenário.

### Resiliência na Comunicação

```javascript
// Padrão: timeout + retry + fallback
async function callService(url, data) {
  try {
    const response = await axios.post(url, data, {
      timeout: 5000,  // timeout de 5s
      // retry pode ser adicionado com axios-retry
    });
    return { success: true, data: response.data };
  } catch (error) {
    // Fallback: log e continua sem falhar
    console.error(`Serviço indisponível: ${error.message}`);
    return { success: false, error: error.message };
  }
}
```

---

## Deploy — Estratégias e Health Checks

### Estratégias de Deploy

| Estratégia | Descrição | Risco |
|------------|-----------|-------|
| Recreate | Para tudo, sobe nova versão | Alto (downtime) |
| Rolling | Atualiza instâncias gradualmente | Médio |
| Blue/Green | Dois ambientes, troca de tráfego | Baixo |
| Canary | Porcentagem pequena recebe nova versão | Baixo |

### Health Check Best Practices

```javascript
// Health check completo
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'nome-do-servico',
    version: process.env.npm_package_version || '1.0.0',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    // Checks adicionais (DB, cache, etc.)
    checks: {
      memory: process.memoryUsage().heapUsed < 500 * 1024 * 1024,
      uptime: process.uptime() > 0
    }
  });
});
```

---

## Ferramentas Úteis para Desenvolvimento Local

| Ferramenta | Uso | Link |
|------------|-----|------|
| Postman | Testar APIs graficamente | https://www.postman.com/ |
| curl | Testar APIs via terminal | Built-in |
| jq | Formatar JSON no terminal | https://jqlang.github.io/jq/ |
| Docker Desktop | Gerenciar containers | https://www.docker.com/products/docker-desktop/ |
| act | Rodar GitHub Actions localmente | https://github.com/nektos/act |
| AWS CLI v2 | Criar repo ECR e gerar token de login | https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html |

---

## Referência Rápida — Comandos da Aula

```bash
# === Node.js ===
npm init -y                    # Inicializar projeto
npm install express cors       # Instalar dependências
npm run test                   # Rodar testes
npm run lint                   # Verificar estilo

# === Docker ===
docker build -t img:tag .      # Buildar imagem
docker run -d -p 3001:3001 img # Rodar container
docker logs container-name     # Ver logs
docker-compose up --build -d   # Subir com compose

# === Amazon ECR (Learner Lab) ===
aws ecr create-repository --repository-name technova-notifications --region us-east-1
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# === Terraform ===
terraform init                 # Inicializar
terraform validate             # Validar
terraform plan                 # Planejar
terraform apply -auto-approve  # Aplicar
terraform destroy              # Destruir (ao final da sessão do Lab)

# === Git ===
git checkout -b feature/name   # Criar branch
git add .                      # Staging
git commit -m "tipo: msg"      # Commit
git push -u origin branch      # Push

# === Testes ===
npm test                       # Unitários
./scripts/run-e2e.sh           # E2E completo
curl http://localhost:3001/health  # Health check manual
```

---

## Leitura Recomendada para Aprofundamento

1. **"Building Microservices"** — Sam Newman (O'Reilly)
2. **"Continuous Delivery"** — Jez Humble, David Farley
3. **"Infrastructure as Code"** — Kief Morris (O'Reilly)
4. **"The DevOps Handbook"** — Gene Kim et al.
5. **"Release It!"** — Michael Nygard (padrões de resiliência)
