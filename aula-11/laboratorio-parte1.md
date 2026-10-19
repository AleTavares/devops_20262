# Aula 11 — Laboratório Parte 1: Blue/Green Deployment com ALB + Target Groups

## Missão

Implementar Blue/Green Deployment para a TechNova API usando Application Load Balancer com dois Target Groups. Ao final, você terá zero downtime nos deploys e rollback instantâneo via traffic switch. As imagens vêm do **Amazon ECR** (Aula 09) e tudo roda no **AWS Academy Learner Lab**.

**Resultado final:**
- ALB provisionado via Terraform com 2 Target Groups (Blue e Green)
- EC2 instances registradas nos Target Groups com a API rodando (imagem do ECR)
- Traffic switch funcional (Blue→Green e Green→Blue)
- Deploy workflow que atualiza Green e faz o switch
- Rollback testado e documentado

---

## Pré-requisitos

- [ ] Pipeline CD funcional da Aula 10 (CI→Build→Push ECR→Deploy)
- [ ] Imagem da TechNova API publicada no **Amazon ECR** (`<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/technova-api`)
- [ ] Terraform state remoto configurado (S3 + DynamoDB)
- [ ] VPC com pelo menos 2 subnets públicas em AZs diferentes
- [ ] Security Groups configurados para EC2 e ALB
- [ ] Credenciais temporárias de sessão do Learner Lab configuradas (`aws sts get-caller-identity` funcionando em `us-east-1`)

---

## Passo 1 — Provisionar o ALB via Terraform

### 1.1 Security Group para o ALB

O ALB precisa de um Security Group próprio que aceite tráfego HTTP/HTTPS da internet:

```hcl
# terraform/alb-sg.tf

resource "aws_security_group" "alb" {
  name        = "technova-alb-sg"
  description = "Security group para o ALB da TechNova"
  vpc_id      = aws_vpc.main.id

  # Entrada: HTTP da internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }

  # Entrada: HTTPS da internet
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from anywhere"
  }

  # Saída: tudo (para health checks e forward para EC2)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "technova-alb-sg"
    Project = "technova"
  }
}
```

### 1.2 Atualizar Security Group da EC2

A EC2 deve aceitar tráfego APENAS do ALB (não mais da internet diretamente):

```hcl
# terraform/ec2-sg.tf — adicionar regra para aceitar tráfego do ALB

resource "aws_security_group_rule" "ec2_from_alb" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.technova_api.id
  description              = "Allow traffic from ALB only"
}
```

### 1.3 Criar o ALB

```hcl
# terraform/alb.tf

resource "aws_lb" "technova" {
  name               = "technova-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  enable_deletion_protection = false  # Lab: permitir destruir

  tags = {
    Name    = "technova-alb"
    Project = "technova"
  }
}

output "alb_dns_name" {
  value       = aws_lb.technova.dns_name
  description = "DNS do ALB para acessar a aplicação"
}

output "alb_arn" {
  value       = aws_lb.technova.arn
  description = "ARN do ALB"
}
```

### 1.4 Criar os Target Groups (Blue e Green)

```hcl
# terraform/target-groups.tf

resource "aws_lb_target_group" "blue" {
  name        = "technova-blue"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/health"
    port                = "3000"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
    matcher             = "200"
  }

  tags = {
    Name    = "technova-tg-blue"
    Color   = "blue"
    Project = "technova"
  }
}

resource "aws_lb_target_group" "green" {
  name        = "technova-green"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/health"
    port                = "3000"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
    matcher             = "200"
  }

  tags = {
    Name    = "technova-tg-green"
    Color   = "green"
    Project = "technova"
  }
}

output "blue_tg_arn" {
  value = aws_lb_target_group.blue.arn
}

output "green_tg_arn" {
  value = aws_lb_target_group.green.arn
}
```

### 1.5 Criar o Listener

```hcl
# terraform/alb-listener.tf

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.technova.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  tags = {
    Name = "technova-listener-http"
  }
}

output "listener_arn" {
  value       = aws_lb_listener.http.arn
  description = "ARN do listener (necessário para traffic switch)"
}
```

### 1.6 Registrar EC2 nos Target Groups

```hcl
# terraform/target-group-attachments.tf

# Instância Blue (a que já existe rodando v1.0)
resource "aws_lb_target_group_attachment" "blue" {
  target_group_arn = aws_lb_target_group.blue.arn
  target_id        = aws_instance.technova_blue.id
  port             = 3000
}

# Instância Green (nova, para receber deploys)
resource "aws_lb_target_group_attachment" "green" {
  target_group_arn = aws_lb_target_group.green.arn
  target_id        = aws_instance.technova_green.id
  port             = 3000
}
```

### 1.7 Aplicar a infraestrutura

```bash
terraform init
terraform plan    # Revisar: ALB, 2 TGs, Listener, SGs, Attachments
terraform apply
```

> **✅ Checkpoint:** ALB criado, acessível via DNS. Target Group Blue com instância saudável. Acesse `http://<ALB_DNS>/health` e confirme resposta 200.

---

## Passo 2 — Configurar a Segunda Instância EC2 (Green)

### 2.1 Criar a instância Green

A instância Green usa o `LabInstanceProfile` do Learner Lab para poder autenticar no ECR e puxar a imagem:

```hcl
# terraform/ec2-green.tf

resource "aws_instance" "technova_green" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = aws_subnet.public_b.id
  vpc_security_group_ids = [aws_security_group.technova_api.id]
  iam_instance_profile   = "LabInstanceProfile"  # Learner Lab (não cria role IAM)

  user_data = <<-EOF
    #!/bin/bash
    # Instalar Docker e AWS CLI
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker ubuntu

    # A imagem vem do Amazon ECR; o login é feito pelo workflow de deploy
    # usando: aws ecr get-login-password | docker login ...

    echo "Green instance ready for deployment" > /home/ubuntu/status.txt
  EOF

  tags = {
    Name    = "technova-api-green"
    Color   = "green"
    Project = "technova"
  }
}

output "green_instance_public_ip" {
  value = aws_instance.technova_green.public_ip
}
```

### 2.2 Aplicar e verificar

```bash
terraform apply

# Verificar que ambas instâncias estão rodando
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=technova" "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].{ID:InstanceId,IP:PublicIpAddress,Name:Tags[?Key==`Name`].Value|[0]}' \
  --output table
```

> **✅ Checkpoint:** Duas instâncias EC2 rodando (Blue e Green), ambas com Docker instalado.

---

## Passo 3 — Deploy na Instância Green

### 3.1 Deploy manual para teste

Antes de automatizar, faça um deploy manual na instância Green para validar (login no ECR antes do pull):

```bash
# SSH na instância Green
ssh -i ~/.ssh/technova-key.pem ubuntu@<GREEN_IP>

# Autenticar no Amazon ECR e fazer pull da imagem
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$REGISTRY"

docker pull "$REGISTRY/technova-api:latest"
docker run -d --name technova-api \
  -p 3000:3000 \
  --restart unless-stopped \
  -e NODE_ENV=production \
  "$REGISTRY/technova-api:latest"

# Verificar se está rodando
curl http://localhost:3000/health
# Esperado: {"status":"ok","version":"..."}
```

### 3.2 Verificar Health Check do ALB

Após a aplicação estar rodando no Green, o ALB deve detectar a instância como saudável:

```bash
# Verificar targets saudáveis em cada Target Group
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw blue_tg_arn)

aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw green_tg_arn)
```

Ambos devem mostrar `"State": "healthy"`.

> **✅ Checkpoint:** Ambos Target Groups com instâncias saudáveis.

---

## Passo 4 — Traffic Switch: Blue → Green

### 4.1 Verificar que o tráfego está no Blue

```bash
# Acessar via ALB — deve retornar versão do Blue
curl http://$(terraform output -raw alb_dns_name)/health
# Retorna versão v1.0 (Blue)
```

### 4.2 Executar o Traffic Switch

```bash
# Mudar o Listener para apontar para Green
aws elbv2 modify-listener \
  --listener-arn $(terraform output -raw listener_arn) \
  --default-actions Type=forward,TargetGroupArn=$(terraform output -raw green_tg_arn)

echo "✅ Traffic switch executado: ALB agora aponta para GREEN"
```

### 4.3 Verificar que o tráfego está no Green

```bash
# Acessar via ALB — deve retornar versão do Green
curl http://$(terraform output -raw alb_dns_name)/health
# Retorna versão v1.1 (Green)
```

### 4.4 Testar Rollback

```bash
# ROLLBACK: voltar para Blue
aws elbv2 modify-listener \
  --listener-arn $(terraform output -raw listener_arn) \
  --default-actions Type=forward,TargetGroupArn=$(terraform output -raw blue_tg_arn)

echo "🔄 Rollback executado: ALB voltou para BLUE"

# Verificar
curl http://$(terraform output -raw alb_dns_name)/health
# Retorna versão v1.0 (Blue) ← rollback funcionou!
```

> **✅ Checkpoint:** Traffic switch e rollback testados com sucesso.

---

## Passo 5 — Workflow de Deploy Blue/Green

### 5.1 Criar o workflow

Crie `.github/workflows/deploy-blue-green.yml`. O workflow builda a imagem, publica no **Amazon ECR**, faz deploy no Green e troca o tráfego. A autenticação na AWS usa as **credenciais temporárias de sessão** do Learner Lab como secrets:

```yaml
name: Blue/Green Deploy

on:
  push:
    branches: [main]
    paths:
      - 'src/**'
      - 'package.json'
      - 'Dockerfile'

env:
  AWS_REGION: us-east-1

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    outputs:
      image: ${{ steps.image.outputs.uri }}
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

      - name: Build e Push para o ECR
        id: image
        run: |
          REGISTRY=${{ steps.ecr.outputs.registry }}
          IMAGE="$REGISTRY/technova-api:${{ github.sha }}"
          docker build -t "$IMAGE" -t "$REGISTRY/technova-api:latest" .
          docker push "$IMAGE"
          docker push "$REGISTRY/technova-api:latest"
          echo "uri=$IMAGE" >> "$GITHUB_OUTPUT"

  deploy-green:
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
      - name: Deploy nova versão no Green
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.GREEN_EC2_HOST }}
          username: ubuntu
          key: ${{ secrets.EC2_SSH_KEY }}
          envs: IMAGE
          script: |
            IMAGE="${{ needs.build-and-push.outputs.image }}"
            REGISTRY="$(echo "$IMAGE" | cut -d/ -f1)"
            aws ecr get-login-password --region us-east-1 \
              | docker login --username AWS --password-stdin "$REGISTRY"
            docker pull "$IMAGE"
            docker stop technova-api || true
            docker rm technova-api || true
            docker run -d --name technova-api \
              -p 3000:3000 \
              --restart unless-stopped \
              -e NODE_ENV=production \
              -e APP_VERSION=${{ github.sha }} \
              "$IMAGE"

      - name: Aguardar Health Check do Green
        run: |
          echo "Aguardando instância Green ficar saudável..."
          for i in $(seq 1 30); do
            STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${{ secrets.GREEN_EC2_HOST }}:3000/health)
            if [ "$STATUS" = "200" ]; then
              echo "✅ Green está saudável!"
              exit 0
            fi
            echo "Tentativa $i/30 — status: $STATUS"
            sleep 5
          done
          echo "❌ Green não ficou saudável em 150s"
          exit 1

  traffic-switch:
    needs: deploy-green
    runs-on: ubuntu-latest
    steps:
      - name: Configurar credenciais AWS (Learner Lab)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Traffic Switch — Blue para Green
        run: |
          aws elbv2 modify-listener \
            --listener-arn ${{ secrets.ALB_LISTENER_ARN }} \
            --default-actions Type=forward,TargetGroupArn=${{ secrets.GREEN_TG_ARN }}
          echo "✅ Tráfego redirecionado para GREEN"

      - name: Validar tráfego no Green
        run: |
          sleep 10
          STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${{ secrets.ALB_DNS }}/health)
          if [ "$STATUS" = "200" ]; then
            echo "✅ ALB respondendo corretamente via Green"
          else
            echo "❌ ALB não respondendo — executando rollback"
            aws elbv2 modify-listener \
              --listener-arn ${{ secrets.ALB_LISTENER_ARN }} \
              --default-actions Type=forward,TargetGroupArn=${{ secrets.BLUE_TG_ARN }}
            echo "🔄 Rollback para Blue executado"
            exit 1
          fi
```

> **☁️ Learner Lab:** as 3 credenciais (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`) são **temporárias** e precisam ser atualizadas como secrets a cada nova sessão do Lab. Em produção real (fora do Lab), o padrão ideal é **OIDC + role IAM**, sem secrets de longa duração — mas o Lab não permite criar OIDC provider nem roles.

### 5.2 Configurar Secrets necessários

No repositório GitHub → Settings → Secrets and variables → Actions:

| Secret | Valor | Descrição |
|--------|-------|-----------|
| `AWS_ACCESS_KEY_ID` | Credencial de sessão do Lab | Autenticação AWS (temporária) |
| `AWS_SECRET_ACCESS_KEY` | Credencial de sessão do Lab | Autenticação AWS (temporária) |
| `AWS_SESSION_TOKEN` | Token de sessão do Lab | Exigido pelo Learner Lab |
| `GREEN_EC2_HOST` | IP público da instância Green | Para SSH deploy |
| `BLUE_EC2_HOST` | IP público da instância Blue | Para rollback SSH |
| `EC2_SSH_KEY` | Chave privada SSH | Autenticação SSH |
| `ALB_LISTENER_ARN` | ARN do listener | Para traffic switch |
| `GREEN_TG_ARN` | ARN do Target Group Green | Destino do switch |
| `BLUE_TG_ARN` | ARN do Target Group Blue | Destino do rollback |
| `ALB_DNS` | DNS do ALB | Para health check pós-switch |

### 5.3 Testar o workflow

```bash
# Fazer uma mudança no código
echo "// Blue/Green deploy test" >> src/server.js
git add src/server.js
git commit -m "feat: test blue/green deploy"
git push origin main
```

Observe no GitHub Actions:
1. Job `build-and-push` — build e push da imagem para o ECR
2. Job `deploy-green` — login ECR + pull + deploy na instância Green + health check
3. Job `traffic-switch` — ALB redireciona para Green

> **✅ Checkpoint:** Workflow executado com sucesso — deploy zero downtime via Blue/Green!

---

## Troubleshooting

| Problema | Causa Provável | Solução |
|----------|---------------|---------|
| ALB retorna 502 Bad Gateway | Target Group sem instâncias saudáveis | Verificar health check path e porta |
| Health check failing | App não responde em /health na porta 3000 | Verificar se container está rodando |
| `UnhealthyHostCount` alto | Security Group não permite tráfego ALB→EC2 | Adicionar regra ingress com SG do ALB |
| Traffic switch sem efeito | Listener ARN incorreto | Verificar com `aws elbv2 describe-listeners` |
| 503 após switch | Green não está pronto (container iniciando) | Aumentar tempo de espera no health check |
| `denied` / `token has expired` no login ECR | Credenciais de sessão do Lab expiraram | Reabrir o Learner Lab e recarregar as credenciais da sessão (secrets) |
| `Target group has no targets` | Attachment não criado | Verificar `aws_lb_target_group_attachment` |
| ALB requer 2 AZs | Apenas 1 subnet configurada | Criar subnet em segunda AZ |

---

## Checklist de Validação

Antes de seguir para o Laboratório Parte 2, confirme:

- [ ] ALB provisionado via Terraform e acessível pela internet
- [ ] 2 Target Groups criados (Blue e Green) com health checks configurados
- [ ] 2 EC2 instances rodando, cada uma registrada em seu Target Group
- [ ] Ambas instâncias mostram "healthy" no health check do ALB
- [ ] Imagem puxada do Amazon ECR (login ECR antes do pull) nas instâncias
- [ ] Traffic switch Blue→Green funciona (via AWS CLI)
- [ ] Rollback Green→Blue funciona (via AWS CLI)
- [ ] Workflow `deploy-blue-green.yml` criado e commitado
- [ ] Workflow testado: push na main → build → push ECR → deploy Green → switch
- [ ] Zero downtime confirmado (acessar ALB durante switch não retorna erro)
- [ ] Secrets configurados no GitHub (credenciais do Lab, ARNs, IPs, SSH key)

> **🎯 Se todos os itens estão ✅, você completou a Parte 1!** Siga para o Laboratório Parte 2: Canary com Weighted Routing.
