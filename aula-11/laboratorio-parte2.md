# Aula 11 — Laboratório Parte 2: Canary Deployment com Weighted Routing + Monitoramento

## Missão

Implementar Canary Deployment para a TechNova API usando weighted routing no ALB. O deploy será gradual (5%→25%→50%→100%) com monitoramento entre cada etapa e rollback automático se a taxa de erro ultrapassar o threshold. As imagens vêm do **Amazon ECR** e tudo roda no **AWS Academy Learner Lab**.

**Resultado final:**
- ALB configurado com weighted forward action (dois Target Groups com pesos)
- Script de rollout gradual que ajusta pesos e monitora saúde
- Workflow GitHub Actions que executa canary deploy automatizado
- Rollback automático baseado em error rate
- Deploy canary testado end-to-end

---

## Pré-requisitos

- [ ] Laboratório Parte 1 completo (ALB + 2 Target Groups + 2 EC2 instances)
- [ ] Ambas instâncias (Blue/Stable e Green/Canary) com container rodando (imagem do ECR)
- [ ] ALB respondendo corretamente em `/health`
- [ ] Credenciais temporárias de sessão do Learner Lab funcionais (`us-east-1`)
- [ ] AWS CLI funcional (`aws elbv2 describe-listeners` funciona)

---

## Passo 1 — Configurar Weighted Routing no ALB

### 1.1 Entendendo Weighted Forward Actions

O ALB suporta forward actions com múltiplos Target Groups e pesos. Diferente do Blue/Green (que aponta para UM Target Group), aqui dividimos o tráfego proporcionalmente.

### 1.2 Modificar o Listener para Weighted Routing via Terraform

Atualize o listener para usar weighted forward (substitui o forward simples do Lab 1):

```hcl
# terraform/alb-listener-canary.tf

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.technova.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = var.stable_weight
      }

      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = var.canary_weight
      }

      stickiness {
        enabled  = true
        duration = 300  # 5 minutos
      }
    }
  }
}

variable "stable_weight" {
  description = "Peso do tráfego para stable (Blue)"
  type        = number
  default     = 100
}

variable "canary_weight" {
  description = "Peso do tráfego para canary (Green)"
  type        = number
  default     = 0
}
```

### 1.3 Aplicar configuração inicial

```bash
# Aplicar com 100% stable, 0% canary (estado inicial)
terraform apply -var="stable_weight=100" -var="canary_weight=0"

# Verificar que o listener tem weighted forward
aws elbv2 describe-listeners \
  --load-balancer-arn $(terraform output -raw alb_arn) \
  --query 'Listeners[0].DefaultActions[0].ForwardConfig'
```

### 1.4 Testar weighted routing manualmente

```bash
# Mudar para 50/50 e testar
aws elbv2 modify-listener \
  --listener-arn $(terraform output -raw listener_arn) \
  --default-actions '[{
    "Type": "forward",
    "ForwardConfig": {
      "TargetGroups": [
        {"TargetGroupArn": "'$(terraform output -raw blue_tg_arn)'", "Weight": 50},
        {"TargetGroupArn": "'$(terraform output -raw green_tg_arn)'", "Weight": 50}
      ],
      "TargetGroupStickinessConfig": {"Enabled": true, "DurationSeconds": 300}
    }
  }]'

# Fazer 20 requests e ver a distribuição
for i in $(seq 1 20); do
  curl -s http://$(terraform output -raw alb_dns_name)/health | jq -r '.version'
done | sort | uniq -c
# Esperado: ~10 requests para cada versão (distribuição aproximada)

# Voltar para 100/0
aws elbv2 modify-listener \
  --listener-arn $(terraform output -raw listener_arn) \
  --default-actions '[{
    "Type": "forward",
    "ForwardConfig": {
      "TargetGroups": [
        {"TargetGroupArn": "'$(terraform output -raw blue_tg_arn)'", "Weight": 100},
        {"TargetGroupArn": "'$(terraform output -raw green_tg_arn)'", "Weight": 0}
      ]
    }
  }]'
```

> **✅ Checkpoint:** Weighted routing funcional — tráfego dividido corretamente entre TGs.

---

## Passo 2 — Script de Canary Rollout

### 2.1 Criar o script de rollout

Crie o arquivo `scripts/canary-rollout.sh`:

```bash
#!/bin/bash
# scripts/canary-rollout.sh
# Rollout canary gradual com monitoramento e rollback automático

set -e

# === CONFIGURAÇÃO ===
LISTENER_ARN="${LISTENER_ARN:?Defina LISTENER_ARN}"
TG_STABLE_ARN="${TG_STABLE_ARN:?Defina TG_STABLE_ARN}"
TG_CANARY_ARN="${TG_CANARY_ARN:?Defina TG_CANARY_ARN}"
ALB_DNS="${ALB_DNS:?Defina ALB_DNS}"
HEALTH_ENDPOINT="${HEALTH_ENDPOINT:-/health}"
ERROR_THRESHOLD="${ERROR_THRESHOLD:-5}"  # % máximo de erro

# Etapas do rollout: "canary_weight:monitoring_seconds"
STAGES=("5:60" "25:120" "50:180" "100:0")

# === FUNÇÕES ===

update_weights() {
  local stable=$1
  local canary=$2
  
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📊 Atualizando pesos: stable=${stable}% | canary=${canary}%"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  aws elbv2 modify-listener \
    --listener-arn "$LISTENER_ARN" \
    --default-actions "[{
      \"Type\": \"forward\",
      \"ForwardConfig\": {
        \"TargetGroups\": [
          {\"TargetGroupArn\": \"$TG_STABLE_ARN\", \"Weight\": $stable},
          {\"TargetGroupArn\": \"$TG_CANARY_ARN\", \"Weight\": $canary}
        ],
        \"TargetGroupStickinessConfig\": {\"Enabled\": true, \"DurationSeconds\": 300}
      }
    }]" > /dev/null
}

monitor_health() {
  local duration=$1
  local canary_pct=$2
  
  echo "🔍 Monitorando saúde por ${duration}s (canary em ${canary_pct}%)..."
  echo ""
  
  local errors=0
  local total=0
  local interval=2  # Check a cada 2 segundos
  local checks=$((duration / interval))
  
  for i in $(seq 1 $checks); do
    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" "http://${ALB_DNS}${HEALTH_ENDPOINT}" 2>/dev/null || echo "000")
    total=$((total + 1))
    
    if [ "$status" != "200" ]; then
      errors=$((errors + 1))
    fi
    
    # Mostrar progresso a cada 10 checks
    if [ $((i % 10)) -eq 0 ]; then
      local current_rate=$((errors * 100 / total))
      echo "  ⏱️  ${i}/${checks} checks | errors: ${errors}/${total} (${current_rate}%) | threshold: ${ERROR_THRESHOLD}%"
    fi
    
    # Verificar threshold em tempo real (não esperar o fim)
    if [ $total -gt 10 ]; then
      local current_rate=$((errors * 100 / total))
      if [ $current_rate -gt $ERROR_THRESHOLD ]; then
        echo ""
        echo "  ❌ THRESHOLD EXCEDIDO: ${current_rate}% > ${ERROR_THRESHOLD}%"
        return 1
      fi
    fi
    
    sleep $interval
  done
  
  local final_rate=$((errors * 100 / total))
  echo ""
  echo "  ✅ Monitoramento concluído: error rate = ${final_rate}% (dentro do threshold)"
  return 0
}

rollback() {
  echo ""
  echo "🚨 ═══════════════════════════════════════════════════════"
  echo "🚨  ROLLBACK: Revertendo 100% do tráfego para STABLE"
  echo "🚨 ═══════════════════════════════════════════════════════"
  update_weights 100 0
  echo ""
  echo "❌ Deploy canary ABORTADO — stable restaurado"
  exit 1
}

# === MAIN ===

echo "🚀 ═══════════════════════════════════════════════════════"
echo "🚀  CANARY ROLLOUT — TechNova API"
echo "🚀 ═══════════════════════════════════════════════════════"
echo ""
echo "Configuração:"
echo "  ALB DNS:         $ALB_DNS"
echo "  Error threshold: ${ERROR_THRESHOLD}%"
echo "  Etapas:          ${#STAGES[@]} (5% → 25% → 50% → 100%)"
echo ""

STAGE_NUM=0
for stage in "${STAGES[@]}"; do
  STAGE_NUM=$((STAGE_NUM + 1))
  IFS=':' read -r canary_weight monitor_duration <<< "$stage"
  stable_weight=$((100 - canary_weight))
  
  echo ""
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║  ETAPA ${STAGE_NUM}/${#STAGES[@]}: ${canary_weight}% canary"
  echo "╚══════════════════════════════════════════════════════════╝"
  
  update_weights $stable_weight $canary_weight
  
  if [ "$monitor_duration" -gt 0 ]; then
    if ! monitor_health $monitor_duration $canary_weight; then
      rollback
    fi
  fi
done

echo ""
echo "🎉 ═══════════════════════════════════════════════════════"
echo "🎉  SUCESSO! Canary promovido para 100%"
echo "🎉  Nova versão é agora a versão STABLE"
echo "🎉 ═══════════════════════════════════════════════════════"
```

### 2.2 Tornar executável e testar

```bash
chmod +x scripts/canary-rollout.sh

# Testar (certifique-se de exportar as variáveis)
export LISTENER_ARN=$(terraform output -raw listener_arn)
export TG_STABLE_ARN=$(terraform output -raw blue_tg_arn)
export TG_CANARY_ARN=$(terraform output -raw green_tg_arn)
export ALB_DNS=$(terraform output -raw alb_dns_name)
export ERROR_THRESHOLD=5

./scripts/canary-rollout.sh
```

> **✅ Checkpoint:** Script executa rollout completo 5%→25%→50%→100% com monitoramento.

---

## Passo 3 — Simular Falha e Testar Rollback

### 3.1 Criar versão "bugada" para testar rollback

Modifique temporariamente a aplicação na instância Canary para simular erros (login no ECR antes do pull):

```bash
# SSH na instância Green/Canary
ssh -i ~/.ssh/technova-key.pem ubuntu@<GREEN_IP>

# Autenticar no ECR
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$REGISTRY"

# Parar container atual
docker stop technova-api && docker rm technova-api

# Rodar versão que retorna erro em 50% dos requests (simulação)
docker run -d --name technova-api \
  -p 3000:3000 \
  --restart unless-stopped \
  -e NODE_ENV=production \
  -e SIMULATE_ERRORS=50 \
  "$REGISTRY/technova-api:latest"
```

> **💡 Se sua app não tem SIMULATE_ERRORS:** Alternativamente, pare o container do canary durante o rollout para simular uma falha completa (todas as requests retornam erro).

### 3.2 Executar rollout e observar rollback

```bash
# Com o canary "bugado", o script deve detectar e fazer rollback
export ERROR_THRESHOLD=5
./scripts/canary-rollout.sh
```

Output esperado:
```
🚀 CANARY ROLLOUT — TechNova API
...
╔══════════════════════════════════════════════════════════╗
║  ETAPA 1/4: 5% canary
╚══════════════════════════════════════════════════════════╝
📊 Atualizando pesos: stable=95% | canary=5%
🔍 Monitorando saúde por 60s (canary em 5%)...
  ⏱️  10/30 checks | errors: 3/10 (30%) | threshold: 5%
  ❌ THRESHOLD EXCEDIDO: 30% > 5%

🚨 ROLLBACK: Revertendo 100% do tráfego para STABLE
📊 Atualizando pesos: stable=100% | canary=0%
❌ Deploy canary ABORTADO — stable restaurado
```

### 3.3 Restaurar canary saudável

```bash
# SSH na instância Green e restaurar versão saudável
ssh -i ~/.ssh/technova-key.pem ubuntu@<GREEN_IP>
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$REGISTRY"
docker stop technova-api && docker rm technova-api
docker run -d --name technova-api \
  -p 3000:3000 \
  --restart unless-stopped \
  -e NODE_ENV=production \
  "$REGISTRY/technova-api:latest"
```

> **✅ Checkpoint:** Rollback automático funciona quando error rate excede threshold.

---

## Passo 4 — Workflow GitHub Actions com Canary

### 4.1 Criar workflow de deploy canary

Crie `.github/workflows/deploy-canary.yml`. A autenticação na AWS usa as credenciais temporárias de sessão do Learner Lab como secrets:

```yaml
name: Canary Deploy

on:
  workflow_dispatch:  # Apenas manual (canary é para releases cuidadosas)
    inputs:
      error_threshold:
        description: 'Error rate threshold para rollback (%)'
        required: false
        default: '5'

env:
  AWS_REGION: us-east-1

jobs:
  build-and-push:
    runs-on: ubuntu-latest
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

      - name: Build e Push para o ECR
        run: |
          REGISTRY=${{ steps.ecr.outputs.registry }}
          docker build -t "$REGISTRY/technova-api:${{ github.sha }}" -t "$REGISTRY/technova-api:canary" .
          docker push "$REGISTRY/technova-api:${{ github.sha }}"
          docker push "$REGISTRY/technova-api:canary"

  deploy-canary-instance:
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
      - name: Deploy nova versão na instância Canary
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.GREEN_EC2_HOST }}
          username: ubuntu
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
            REGISTRY="${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
            aws ecr get-login-password --region us-east-1 \
              | docker login --username AWS --password-stdin "$REGISTRY"
            docker pull "$REGISTRY/technova-api:${{ github.sha }}"
            docker stop technova-api || true
            docker rm technova-api || true
            docker run -d --name technova-api \
              -p 3000:3000 \
              --restart unless-stopped \
              -e NODE_ENV=production \
              -e APP_VERSION=${{ github.sha }} \
              "$REGISTRY/technova-api:${{ github.sha }}"

      - name: Verificar instância Canary saudável
        run: |
          for i in $(seq 1 20); do
            STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${{ secrets.GREEN_EC2_HOST }}:3000/health)
            if [ "$STATUS" = "200" ]; then
              echo "✅ Canary instance healthy"
              exit 0
            fi
            sleep 5
          done
          echo "❌ Canary não ficou healthy"
          exit 1

  canary-rollout:
    needs: deploy-canary-instance
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Configurar credenciais AWS (Learner Lab)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
          aws-region: ${{ env.AWS_REGION }}

      - name: "Etapa 1: 5% canary"
        run: |
          echo "📊 Canary: 5% | Stable: 95%"
          aws elbv2 modify-listener \
            --listener-arn ${{ secrets.ALB_LISTENER_ARN }} \
            --default-actions '[{"Type":"forward","ForwardConfig":{"TargetGroups":[{"TargetGroupArn":"${{ secrets.BLUE_TG_ARN }}","Weight":95},{"TargetGroupArn":"${{ secrets.GREEN_TG_ARN }}","Weight":5}],"TargetGroupStickinessConfig":{"Enabled":true,"DurationSeconds":300}}}]'

      - name: "Monitor Etapa 1 (60s)"
        run: |
          ERRORS=0; TOTAL=0
          for i in $(seq 1 30); do
            STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${{ secrets.ALB_DNS }}/health)
            TOTAL=$((TOTAL+1))
            [ "$STATUS" != "200" ] && ERRORS=$((ERRORS+1))
            sleep 2
          done
          RATE=$((ERRORS*100/TOTAL))
          echo "Error rate: ${RATE}%"
          if [ $RATE -gt ${{ inputs.error_threshold }} ]; then
            echo "ROLLBACK=true" >> $GITHUB_ENV
            echo "::error::Error rate ${RATE}% excede threshold"
          fi

      - name: "Rollback Etapa 1"
        if: env.ROLLBACK == 'true'
        run: |
          aws elbv2 modify-listener \
            --listener-arn ${{ secrets.ALB_LISTENER_ARN }} \
            --default-actions '[{"Type":"forward","ForwardConfig":{"TargetGroups":[{"TargetGroupArn":"${{ secrets.BLUE_TG_ARN }}","Weight":100},{"TargetGroupArn":"${{ secrets.GREEN_TG_ARN }}","Weight":0}]}}]'
          echo "🔄 Rollback executado"
          exit 1

      - name: "Etapa 2: 25% canary"
        run: |
          echo "📊 Canary: 25% | Stable: 75%"
          aws elbv2 modify-listener \
            --listener-arn ${{ secrets.ALB_LISTENER_ARN }} \
            --default-actions '[{"Type":"forward","ForwardConfig":{"TargetGroups":[{"TargetGroupArn":"${{ secrets.BLUE_TG_ARN }}","Weight":75},{"TargetGroupArn":"${{ secrets.GREEN_TG_ARN }}","Weight":25}],"TargetGroupStickinessConfig":{"Enabled":true,"DurationSeconds":300}}}]'

      - name: "Monitor Etapa 2 (120s)"
        run: |
          ERRORS=0; TOTAL=0
          for i in $(seq 1 60); do
            STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${{ secrets.ALB_DNS }}/health)
            TOTAL=$((TOTAL+1))
            [ "$STATUS" != "200" ] && ERRORS=$((ERRORS+1))
            sleep 2
          done
          RATE=$((ERRORS*100/TOTAL))
          echo "Error rate: ${RATE}%"
          if [ $RATE -gt ${{ inputs.error_threshold }} ]; then
            echo "ROLLBACK=true" >> $GITHUB_ENV
            echo "::error::Error rate ${RATE}% excede threshold"
          fi

      - name: "Rollback Etapa 2"
        if: env.ROLLBACK == 'true'
        run: |
          aws elbv2 modify-listener \
            --listener-arn ${{ secrets.ALB_LISTENER_ARN }} \
            --default-actions '[{"Type":"forward","ForwardConfig":{"TargetGroups":[{"TargetGroupArn":"${{ secrets.BLUE_TG_ARN }}","Weight":100},{"TargetGroupArn":"${{ secrets.GREEN_TG_ARN }}","Weight":0}]}}]'
          echo "🔄 Rollback executado"
          exit 1

      - name: "Etapa 3: 50% canary"
        run: |
          echo "📊 Canary: 50% | Stable: 50%"
          aws elbv2 modify-listener \
            --listener-arn ${{ secrets.ALB_LISTENER_ARN }} \
            --default-actions '[{"Type":"forward","ForwardConfig":{"TargetGroups":[{"TargetGroupArn":"${{ secrets.BLUE_TG_ARN }}","Weight":50},{"TargetGroupArn":"${{ secrets.GREEN_TG_ARN }}","Weight":50}],"TargetGroupStickinessConfig":{"Enabled":true,"DurationSeconds":300}}}]'

      - name: "Monitor Etapa 3 (180s)"
        run: |
          ERRORS=0; TOTAL=0
          for i in $(seq 1 90); do
            STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${{ secrets.ALB_DNS }}/health)
            TOTAL=$((TOTAL+1))
            [ "$STATUS" != "200" ] && ERRORS=$((ERRORS+1))
            sleep 2
          done
          RATE=$((ERRORS*100/TOTAL))
          echo "Error rate: ${RATE}%"
          if [ $RATE -gt ${{ inputs.error_threshold }} ]; then
            echo "ROLLBACK=true" >> $GITHUB_ENV
            echo "::error::Error rate ${RATE}% excede threshold"
          fi

      - name: "Rollback Etapa 3"
        if: env.ROLLBACK == 'true'
        run: |
          aws elbv2 modify-listener \
            --listener-arn ${{ secrets.ALB_LISTENER_ARN }} \
            --default-actions '[{"Type":"forward","ForwardConfig":{"TargetGroups":[{"TargetGroupArn":"${{ secrets.BLUE_TG_ARN }}","Weight":100},{"TargetGroupArn":"${{ secrets.GREEN_TG_ARN }}","Weight":0}]}}]'
          echo "🔄 Rollback executado"
          exit 1

      - name: "Etapa 4: 100% canary — PROMOÇÃO"
        run: |
          echo "🎉 Promovendo canary para 100%!"
          aws elbv2 modify-listener \
            --listener-arn ${{ secrets.ALB_LISTENER_ARN }} \
            --default-actions '[{"Type":"forward","ForwardConfig":{"TargetGroups":[{"TargetGroupArn":"${{ secrets.BLUE_TG_ARN }}","Weight":0},{"TargetGroupArn":"${{ secrets.GREEN_TG_ARN }}","Weight":100}]}}]'
          echo "✅ Nova versão promovida com sucesso!"
```

### 4.2 Testar o workflow

No GitHub: Actions → "Canary Deploy" → "Run workflow" → "Run"

Observe cada etapa executando sequencialmente com monitoramento entre elas.

> **✅ Checkpoint:** Workflow canary funcional com etapas graduais e rollback automático.

---

## Passo 5 — Monitoramento Avançado

### 5.1 Verificar distribuição de tráfego real

Durante o rollout, confirme que os pesos estão funcionando corretamente:

```bash
# Script para verificar distribuição de tráfego
echo "Fazendo 100 requests para verificar distribuição..."
declare -A versions

for i in $(seq 1 100); do
  version=$(curl -s http://$(terraform output -raw alb_dns_name)/health | jq -r '.version // "unknown"')
  versions[$version]=$((${versions[$version]:-0} + 1))
done

echo ""
echo "Distribuição de tráfego:"
for v in "${!versions[@]}"; do
  echo "  $v: ${versions[$v]}%"
done
```

### 5.2 Monitorar via CloudWatch (opcional)

Se quiser monitoramento mais sofisticado, use o CloudWatch:

```bash
# Ver métricas do Target Group canary
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name HTTPCode_Target_5XX_Count \
  --dimensions Name=TargetGroup,Value=$(terraform output -raw green_tg_arn | cut -d: -f6 | cut -d/ -f2-) \
  --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics Sum
```

### 5.3 Verificar targets em cada etapa

```bash
# Verificar health de ambos Target Groups
echo "=== STABLE (Blue) ==="
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw blue_tg_arn) \
  --query 'TargetHealthDescriptions[].{Target:Target.Id,Health:TargetHealth.State}'

echo ""
echo "=== CANARY (Green) ==="
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw green_tg_arn) \
  --query 'TargetHealthDescriptions[].{Target:Target.Id,Health:TargetHealth.State}'
```

> **✅ Checkpoint:** Monitoramento funcional — consegue observar distribuição e saúde durante rollout.

---

## Passo 6 — Limpeza (Opcional — apenas se não usar mais)

```bash
# ATENÇÃO: só execute se não for mais usar a infraestrutura
# Voltar pesos para estado seguro primeiro
aws elbv2 modify-listener \
  --listener-arn $(terraform output -raw listener_arn) \
  --default-actions '[{
    "Type": "forward",
    "ForwardConfig": {
      "TargetGroups": [
        {"TargetGroupArn": "'$(terraform output -raw blue_tg_arn)'", "Weight": 100},
        {"TargetGroupArn": "'$(terraform output -raw green_tg_arn)'", "Weight": 0}
      ]
    }
  }]'

# Destruir toda a infraestrutura
terraform destroy
```

> **☁️ Lembrete Learner Lab:** se você pretende continuar usando nas próximas aulas (a Aula 12 reaproveita o ALB), **NÃO destrua** agora. Se não vai mais usar na sessão, rode `terraform destroy` para liberar os recursos do Lab.

---

## Troubleshooting

| Problema | Causa Provável | Solução |
|----------|---------------|---------|
| Tráfego não divide corretamente | Stickiness fixando todos no mesmo TG | Usar browsers diferentes ou desabilitar stickiness para teste |
| Error rate sempre 0% mesmo com canary bugado | Health check vai no ALB, não no canary especificamente | Verificar que requests realmente chegam no canary (ver logs) |
| `modify-listener` falha | JSON malformado no --default-actions | Validar JSON antes com `echo '...' \| jq .` |
| Script não detecta erros | Canary com error rate baixo (5% de 5% = 0.25%) | Aumentar duração do monitoramento ou error threshold |
| Stickiness não funciona | Cookie expirado ou browser diferente | Verificar `duration` e testar com mesmo browser |
| Rollback demora | Script travado no loop de monitoring | Verificar timeout do curl e `set -e` |
| `token has expired` nos comandos AWS | Credenciais de sessão do Lab expiraram | Reabrir o Learner Lab e recarregar as credenciais |

---

## Checklist de Validação Final

- [ ] ALB com weighted forward action configurado via Terraform
- [ ] Variáveis `stable_weight` e `canary_weight` funcionais
- [ ] Script `canary-rollout.sh` executa rollout completo (5→25→50→100)
- [ ] Script detecta error rate acima do threshold e faz rollback
- [ ] Rollback automático testado com canary "bugado"
- [ ] Workflow `deploy-canary.yml` criado com `workflow_dispatch`
- [ ] Workflow executa etapas gradualmente com monitoramento
- [ ] Workflow faz rollback automático quando threshold é excedido
- [ ] Imagem puxada do Amazon ECR (login ECR antes do pull)
- [ ] Distribuição de tráfego verificada (aproximadamente correta)
- [ ] Stickiness habilitada e testada

> **🎯 Parabéns!** Você implementou ambas as estratégias de deploy com zero downtime: Blue/Green (traffic switch instantâneo) e Canary (rollout gradual com monitoramento). A TechNova agora pode fazer deploys invisíveis para seus clientes!
