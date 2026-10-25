---
marp: true
paginate: true
backgroundColor: '#F5F7FA'
footer: 'DevOps — UniFAAT 2026-2 | Prof. Alexandre Tavares'
style: |
  section {
    font-family: 'Segoe UI', Arial, sans-serif;
    font-size: 17px;
    padding: 35px 48px 28px 48px;
    color: #333333;
  }
  h1 {
    color: #0D2B45;
    border-bottom: 3px solid #F58220;
    padding-bottom: 5px;
    font-size: 1.45em;
    margin-bottom: 8px;
    margin-top: 0;
  }
  h2 { color: #1B3A5C; font-size: 1.2em; margin: 4px 0; }
  h3 { color: #2E86C1; font-size: 0.98em; margin: 4px 0; }
  p, li { margin: 2px 0; line-height: 1.35; }
  ul, ol { margin: 3px 0; padding-left: 18px; }
  strong { color: #F58220; }
  pre { margin: 4px 0; font-size: 0.72em; line-height: 1.25; }
  code { background-color: #e8eef4; color: #1B3A5C; font-size: 0.82em; padding: 1px 4px; }
  pre code { font-size: 1em; padding: 0; }
  table { font-size: 0.82em; width: 100%; margin: 4px 0; border-collapse: collapse; }
  table th { background-color: #1B3A5C; color: white; padding: 3px 7px; }
  table td { padding: 2px 7px; border-bottom: 1px solid #ddd; }
  blockquote { font-size: 0.88em; border-left: 4px solid #F58220; padding-left: 10px; margin: 4px 0; color: #555; }
  section.title {
    background-color: #1B3A5C;
    color: white !important;
    text-align: center;
    justify-content: center;
    padding: 60px;
  }
  section.title h1 { color: #F58220 !important; border-bottom: 3px solid #F58220; font-size: 2.2em; }
  section.title h2 { color: #F58220 !important; font-size: 1.3em; }
  section.title h3 { color: #ccc !important; }
  section.title p { color: #ccc !important; }
  section.title strong { color: #F58220 !important; }
  footer { color: #888; font-size: 0.62em; }
  img { max-height: 340px; display: block; margin: 6px auto; }
---

<!-- _class: title -->

# Aula 13 — Novo Microserviço com Pipeline End-to-End

**DevOps — Centro Universitário UniFAAT**
Prof. Alexandre Tavares | Semestre 2026-2

---

# O Desafio da TechNova

Episódio 13: a equipe amadureceu. Monolito domado, infra automatizada, CI/CD consolidado.

O CTO Carlos Mendes propõe o teste definitivo:

> "Precisamos de um serviço de notificações. Mas dessa vez quero que **nasça certo** — testes, container, pipeline, IaC, deploy automatizado e integração com o serviço principal. Autonomia total."

**O que muda:** a equipe deixa de ser guiada e passa a **demonstrar domínio**. Tudo aplicado de forma independente para criar o `technova-notifications`.

> Registry oficial: **Amazon ECR** · Nuvem: **AWS Academy Learner Lab**

---

# Objetivos de Aprendizagem

- **Aplicar princípios de microserviços** — responsabilidade única, deploy independente
- **Criar um serviço do zero** com Express.js (rotas, testes, lint)
- **Containerizar** com Dockerfile multi-stage, non-root e HEALTHCHECK
- **Pipeline CI** no GitHub Actions: lint → test → build → push no **Amazon ECR**
- **Provisionar infra** com Terraform (EC2, SG, `LabInstanceProfile`) no Learner Lab
- **Automatizar o deploy (CD)** com health check e rollback
- **Integrar serviços** via HTTP (technova-api → technova-notifications)
- **Validar E2E** a cadeia completa: pedido → notificação → confirmação

---

# Princípios de Microserviços

Dividir o sistema em serviços pequenos e independentes:

| Princípio | Significado |
|-----------|-------------|
| **Responsabilidade única** | Cada serviço faz uma coisa bem feita |
| **Independência de deploy** | Atualizar um não exige redeployar os outros |
| **Comunicação via contrato** | APIs bem definidas, não acesso direto |
| **Dados próprios** | Cada serviço gerencia seus dados |
| **Observabilidade** | Health check + logs estruturados |

> **Trade-off:** ganho de autonomia vs custo de rede/latência/falhas parciais. Só divida quando compensar.

---

# Escopo do technova-notifications

Serviço deliberadamente enxuto:

- Recebe `POST` com dados de pedido e registra a notificação (simula email/SMS)
- Expõe `GET` para consultar notificações
- Health check próprio
- **Independente** do technova-api, mas **se comunica** com ele

```
┌─────────────────┐        HTTP POST         ┌──────────────────────┐
│  technova-api   │ ─────────────────────────▶│ technova-notifications│
│  (Port 3000)    │   /notifications/send     │   (Port 3001)        │
└─────────────────┘                           └──────────────────────┘
```

---

# Contrato de API

A fronteira estável entre os serviços — o que entra e o que sai:

| Método | Rota | Descrição |
|--------|------|-----------|
| POST | `/notifications/send` | Registra notificação |
| GET | `/notifications` | Lista notificações |
| GET | `/notifications/:orderId` | Filtra por pedido |
| GET | `/health` | Health check |

```json
{
  "orderId": "abc-123",
  "customerEmail": "cliente@email.com",
  "type": "order_created",
  "message": "Seu pedido abc-123 foi criado"
}
```

---

# O Microserviço (Express.js)

Estrutura limpa, separando rotas e serviço:

```javascript
// src/server.js
app.get('/health', (req, res) => res.json({
  status: 'healthy', service: 'technova-notifications',
  timestamp: new Date().toISOString(), uptime: process.uptime()
}));
app.use('/notifications', notificationRoutes);
```

```javascript
// POST /notifications/send — valida campos obrigatórios + tipo
if (!orderId || !customerEmail || !type || !message)
  return res.status(400).json({ error: 'Campos obrigatórios: ...' });
```

> Validação de entrada desde o primeiro commit — o serviço nasce certo.

---

# Testes Unitários (Jest + Supertest)

Qualidade garantida antes de qualquer deploy:

```javascript
describe('POST /notifications/send', () => {
  it('cria notificação com payload válido', async () => {
    const res = await request(app)
      .post('/notifications/send').send(validPayload);
    expect(res.status).toBe(201);
    expect(res.body.notification.status).toBe('sent');
  });
});
```

- Cobre health, criação, validação (400), listagem e filtro por pedido
- **Cobertura > 80%** (coverageThreshold no package.json)
- ESLint sem erros

---

# Dockerfile Multi-Stage

Separar teste, dependências e runtime deixa a imagem enxuta e segura:

```dockerfile
FROM node:18-alpine AS test
RUN npm ci && npm run lint && npm test

FROM node:18-alpine AS dependencies
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS production
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=dependencies /app/node_modules ./node_modules
HEALTHCHECK CMD wget --spider http://localhost:3001/health || exit 1
USER appuser
CMD ["node", "src/server.js"]
```

> **non-root + HEALTHCHECK** = menos superfície de ataque, auto-recuperação.

---

# Pipeline CI — lint → test → build → push

Jobs encadeados com `needs`; só avança se o anterior passou:

```
[Push/PR] → [1. Lint] → [2. Test] → [3. Build & Push ECR]
```

```yaml
jobs:
  lint:  { ... }
  test:  { needs: lint, ... }
  build-and-push:
    needs: test
    # configure-aws-credentials + amazon-ecr-login
```

> A imagem buildada **não morre no runner** — vai versionada para o Amazon ECR.

---

# Login no Amazon ECR (Learner Lab)

As credenciais do Lab são **temporárias** e exigem o `aws-session-token`:

```yaml
- uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}   # Learner Lab exige
    aws-region: us-east-1
- id: ecr
  uses: aws-actions/amazon-ecr-login@v2
```

> O host resolve para `<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com` — já inclui conta + região.

---

# ☁️ Regras do AWS Academy Learner Lab

| Regra | Detalhe |
|-------|---------|
| **Credenciais temporárias** | 3 chaves (inclui `aws_session_token`), expiram por sessão |
| **Região** | Sempre `us-east-1` |
| **Sem IAM** | Não cria user/group/role — use `LabRole` / `LabInstanceProfile` |
| **ECR** | Pode criar repositórios |
| **Encerramento** | `terraform destroy` ao final |

> OIDC + role IAM é o padrão ideal em **produção**, porém **indisponível** no Lab (exige criar role). Aqui usamos as 3 credenciais temporárias como secrets.

---

# Infraestrutura com Terraform

EC2 + Security Group provisionados como código:

```hcl
resource "aws_instance" "notifications" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.notifications.id]

  # Learner Lab: permite o docker pull do ECR sem role IAM nova
  iam_instance_profile = "LabInstanceProfile"

  user_data = templatefile("userdata.sh", { ... })
}
```

> O **`LabInstanceProfile`** dá à instância a permissão para autenticar no ECR — sem criar role (que o Lab proíbe).

---

# Userdata — Deploy do Container

A instância faz login no ECR e sobe o serviço no boot:

```bash
yum install -y docker awscli
systemctl start docker

# Login no ECR com as credenciais do LabInstanceProfile
ECR_REGISTRY=$(echo "${docker_image}" | cut -d'/' -f1)
aws ecr get-login-password --region ${aws_region} \
  | docker login --username AWS --password-stdin "$${ECR_REGISTRY}"

docker pull ${docker_image}
docker run -d --name technova-notifications \
  --restart unless-stopped -p 3001:3001 ${docker_image}
```

---

# Pipeline CD + Health Check

Deploy automatizado com promoção staging → production:

```
CI (push ECR) → Deploy Staging → Health Check → Smoke Test
             → Aprovação Manual → Deploy Production → Health Check
```

```bash
for i in $(seq 1 12); do
  HTTP=$(curl -s -o /dev/null -w "%{http_code}" "$IP:3001/health")
  [ "$HTTP" = "200" ] && echo "Health OK" && exit 0
  sleep 10
done
```

> O deploy só é "sucesso" quando o `/health` responde 200.

---

# Integração Inter-Serviço (com resiliência)

O technova-api dispara a notificação ao criar o pedido — **sem deixar a falha derrubar o pedido**:

```javascript
async function sendNotification(orderData) {
  try {
    const r = await axios.post(`${NOTIFICATIONS_URL}/notifications/send`,
      { orderId: orderData.id, type: 'order_created', ... },
      { timeout: 5000 });
    return { sent: true, notificationId: r.data.notification.id };
  } catch (error) {
    console.error(`[NOTIFICATION ERROR] ${error.message}`);
    return { sent: false, error: error.message };  // fallback
  }
}
```

> O pedido é o fluxo crítico; a notificação é desejável. O código reflete a prioridade.

---

# Testes End-to-End

Validam a cadeia inteira, não só peças isoladas:

```javascript
it('1. Cria pedido no technova-api', async () => {
  const res = await axios.post(`${API_URL}/orders`, { ... });
  expect(res.data.notification.sent).toBe(true);
});

it('2. Notificação registrada no technova-notifications', async () => {
  const res = await axios.get(`${NOTIFICATIONS_URL}/notifications/${id}`);
  expect(res.data.notifications[0].type).toBe('order_created');
});
```

> Prova de que os serviços, **juntos**, entregam o valor esperado.

---

# Pipeline End-to-End — Visão Completa

```
[Push]
  → [Lint] → [Test]
  → [Build Docker] → [Push Amazon ECR]
  → [Terraform Apply] → [Deploy EC2]
  → [Health Check] → [E2E Test]
```

- Cada etapa só roda se a anterior passou
- A **mesma imagem** testada é a que vai para produção (build once, run anywhere)
- Infra reproduzível, deploy observável, cadeia validada ponta a ponta

> É o retrato da maturidade DevOps da equipe.

---

# Resumo dos Conceitos

| Conceito | Descrição |
|----------|-----------|
| Microserviço | Serviço pequeno, independente, responsabilidade única |
| Contrato de API | Fronteira estável entre serviços |
| Multi-stage build | Imagem enxuta (teste/deps/runtime separados) |
| Amazon ECR | Registry da AWS; host inclui Account ID + região |
| Learner Lab | Credenciais temporárias, `us-east-1`, sem IAM, `LabInstanceProfile` |
| CI | lint → test → build → push ECR |
| CD | Deploy automatizado + health check |
| Resiliência | Falha da notificação não derruba o pedido |
| E2E | Valida a cadeia completa order → notification |

---

# Referências e Próximos Passos

**Referências:**
- Microservices Patterns — [microservices.io/patterns](https://microservices.io/patterns/)
- 12-Factor App — [12factor.net/pt_br](https://12factor.net/pt_br/)
- Amazon ECR — [docs.aws.amazon.com/AmazonECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
- amazon-ecr-login — [github.com/aws-actions/amazon-ecr-login](https://github.com/aws-actions/amazon-ecr-login)
- Terraform AWS Provider — [registry.terraform.io](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

**Para o TF:**
- Entregar o `technova-notifications` completo com pipeline E2E (portfólio + PR)
- Evidências: CI verde, imagem no console do ECR, health check, E2E passando

**Próxima aula:**
Continuamos o Projeto Integrador, reutilizando o padrão de serviço independente e pipeline montado aqui.
