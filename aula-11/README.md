# Aula 11 — Blue/Green e Canary Deployments

## Objetivos de Aprendizagem

Ao final desta aula, o aluno será capaz de:

1. Explicar o conceito de Blue/Green Deployment e suas vantagens para zero downtime
2. Implementar Blue/Green com Application Load Balancer (ALB) e dois Target Groups na AWS
3. Realizar traffic switch instantâneo entre ambientes Blue e Green via ALB
4. Executar rollback instantâneo em caso de falha no ambiente Green
5. Explicar o conceito de Canary Deployment e a analogia com canários em minas de carvão
6. Implementar Canary com weighted routing no ALB (distribuição gradual de tráfego)
7. Conduzir rollout gradual (5%→25%→50%→100%) com monitoramento entre cada etapa
8. Configurar rollback automático baseado em taxa de erro durante o rollout canary

---

## Contexto Narrativo

> **O Resgate da TechNova — Episódio 11: "Deploy Invisível: Zero Downtime"**

Na última reunião de sprint, o CEO da TechNova trouxe uma reclamação direta de um cliente enterprise:

> "Ontem às 14h, tentei fazer um pedido e o sistema ficou fora por 8 segundos. Meu gerente viu, perguntou se o sistema é confiável. Vocês são uma startup — eu entendo. Mas se isso acontecer de novo, vou avaliar alternativas."

O CTO Carlos Mendes puxou Rafael para uma conversa séria:

> "Rafa, aquele deploy de terça causou 8 segundos de downtime. Para o cliente, foram 8 segundos eternos. Nossa estratégia Recreate — para tudo, sobe novo — funcionou até agora, mas não escala. Precisamos de **zero downtime**. O deploy precisa ser **invisível** para o usuário."

Marina, a consultora DevOps, apresentou a solução na reunião seguinte:

> "Existem duas estratégias que resolvem isso. A primeira é **Blue/Green**: mantemos duas versões da aplicação simultaneamente — Blue (atual) e Green (nova). O ALB redireciona todo o tráfego de Blue para Green instantaneamente. Se der problema, voltamos para Blue em 1 segundo. Zero downtime, rollback instantâneo."

Carlos perguntou: "E se eu quiser testar com poucos usuários antes de migrar todo mundo?"

Marina continuou:

> "Aí usamos **Canary Deployment** — como os canários nas minas de carvão que alertavam sobre gases tóxicos. Enviamos 5% do tráfego para a nova versão. Se tudo estiver saudável, subimos para 25%, depois 50%, depois 100%. Se em qualquer momento a taxa de erro subir, voltamos automaticamente para 0%. É o deploy mais seguro que existe."

Rafael arregalou os olhos: "Podemos implementar as duas? Blue/Green para deploys rápidos e Canary para mudanças críticas?"

Marina sorriu: "Exatamente. E o melhor: ambas usam o mesmo ALB. A diferença é só como você redistribui o tráfego. E as imagens que vamos deployar são as mesmas que você publicou no **Amazon ECR** na Aula 09 — o ALB só decide para qual instância o tráfego vai."

---

## Cronograma da Aula

| Bloco | Atividade |
|:-----:|-----------|
| 1 | Revisão TA + Discussão |
| 2 | Conteúdo Teórico — Blue/Green + Canary Deployments |
| 3 | Laboratório Parte 1 — Blue/Green com ALB + Target Groups |
| 4 | Laboratório Parte 2 — Canary com Weighted Routing + Monitoramento |
| 5 | Encerramento + Orientação TF |

---

## Pré-requisitos

- **Acesso ao AWS Academy Learner Lab** (sessão iniciada, credenciais temporárias ativas, região `us-east-1`, `LabRole`/`LabInstanceProfile`)
- **Terraform** instalado localmente (≥ 1.5) — [Download](https://developer.hashicorp.com/terraform/downloads)
- **Docker** instalado e funcionando (`docker --version`)
- **AWS CLI v2** instalada e configurada com as credenciais do Lab (`aws sts get-caller-identity` funcionando)
- **Repositório `technova-api`** no GitHub com pipeline CI/CD (Aula 10) e imagem publicada no **Amazon ECR** (Aula 09)
- **Infraestrutura Terraform** da TechNova provisionada (EC2, VPC, Security Groups)
- **Pipeline CD funcional** da Aula 10 (CI→Build→Push ECR→Deploy)
- **Conhecimentos das Aulas 01-10:** Git, Docker, Terraform, GitHub Actions, CI/CD, Amazon ECR, deploy Recreate

> **☁️ AWS Academy Learner Lab:** o ALB, as instâncias EC2 e os Target Groups desta aula rodam dentro do Lab. As credenciais da sessão incluem `aws_session_token` e **expiram quando o Lab encerra** — recarregue-as ao reabrir. Trabalhe sempre em `us-east-1`. O Lab **permite criar ALB, Target Groups, Listeners, EC2, VPC e Security Groups**, mas **não permite criar usuários/grupos/roles IAM** — quando um instance profile for necessário, use o `LabRole`/`LabInstanceProfile` já existentes. Os custos ficam **cobertos pelos créditos do Lab**; rode `terraform destroy` ao final da sessão.

---

## Conteúdo Teórico — Parte 1: Blue/Green Deployment

### 1. O Problema: Downtime no Deploy

Com a estratégia Recreate (Aula 10), o fluxo é:

```
┌─── RECREATE (Problema) ─────────────────────────────────────────────┐
│                                                                       │
│  t=0s   [Container v1.0 rodando]  ← tráfego dos clientes            │
│  t=1s   docker stop v1.0          ← DOWNTIME COMEÇA                 │
│  t=2s   docker pull v1.1          ← baixando nova imagem...         │
│  t=5s   docker run v1.1           ← iniciando container...          │
│  t=8s   [Container v1.1 healthy]  ← DOWNTIME TERMINA               │
│                                                                       │
│  Total: 8 segundos de DOWNTIME (pode ser mais se imagem for grande) │
│                                                                       │
│  Para os clientes da TechNova: pedidos falham durante 8 segundos     │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```

### 2. Blue/Green: Conceito Fundamental

Blue/Green mantém **dois ambientes idênticos** rodando simultaneamente:

```
┌─── BLUE/GREEN Deployment ────────────────────────────────────────────┐
│                                                                        │
│                    ┌──────────────────┐                                │
│  Usuários ───────►│  Load Balancer   │                                │
│                    │  (ALB)           │                                │
│                    └────────┬─────────┘                                │
│                             │                                          │
│               ┌─────────────┼─────────────┐                           │
│               │             │             │                            │
│               ▼             │             ▼                            │
│     ┌─────────────────┐    │   ┌─────────────────┐                   │
│     │  Target Group   │    │   │  Target Group   │                   │
│     │     BLUE        │◄───┘   │     GREEN       │                   │
│     │   (v1.0 atual)  │        │   (v1.1 nova)   │                   │
│     │  ✅ recebendo    │        │  ⏳ standby      │                   │
│     │     tráfego     │        │                  │                   │
│     └─────────────────┘        └─────────────────┘                   │
│                                                                        │
│  Deploy = apenas mudar para onde o ALB aponta                         │
│  Rollback = voltar o ALB para o grupo anterior                        │
│  Downtime = ZERO (tráfego nunca para)                                 │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

**Analogia:** Imagine um palco de teatro com duas cortinas. Enquanto o público assiste ao cenário atual (Blue), os técnicos montam o novo cenário atrás da outra cortina (Green). Quando pronto, a cortina simplesmente muda — o público não percebe transição.

### 3. Componentes AWS para Blue/Green

```
┌─── Arquitetura AWS ──────────────────────────────────────────────────┐
│                                                                        │
│  Application Load Balancer (ALB)                                      │
│  ├── Listener (porta 80/443)                                          │
│  │   └── Default Action: forward to Target Group                      │
│  │                                                                    │
│  ├── Target Group BLUE (tg-blue)                                      │
│  │   └── EC2 Instance(s) rodando v1.0 (imagem do ECR)               │
│  │                                                                    │
│  └── Target Group GREEN (tg-green)                                    │
│      └── EC2 Instance(s) rodando v1.1 (imagem do ECR)               │
│                                                                        │
│  Traffic Switch: mudar o Listener para apontar para GREEN             │
│  Rollback: mudar o Listener de volta para BLUE                        │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

| Componente | Função |
|-----------|--------|
| ALB | Recebe tráfego dos clientes, distribui para Target Groups |
| Listener | Regra que define qual Target Group recebe o tráfego |
| Target Group Blue | Grupo com a versão ATUAL (estável) |
| Target Group Green | Grupo com a NOVA versão (a ser validada) |
| Health Check | ALB verifica saúde de cada instância no Target Group |

### 4. Fluxo de Deploy Blue/Green

```
┌─── Fluxo Blue/Green ─────────────────────────────────────────────────┐
│                                                                        │
│  ESTADO INICIAL: ALB → Target Group BLUE (v1.0)                       │
│                                                                        │
│  Passo 1: Deploy nova versão no ambiente GREEN                        │
│           login ECR → docker pull v1.1 → docker run (instância Green)│
│                                                                        │
│  Passo 2: ALB Health Check verifica GREEN                             │
│           GET /health → 200 OK ✅                                      │
│                                                                        │
│  Passo 3: Traffic Switch — ALB Listener → Target Group GREEN          │
│           (instantâneo, sem perda de conexão)                          │
│                                                                        │
│  Passo 4: Monitorar métricas por N minutos                            │
│           - Taxa de erro (5xx)                                        │
│           - Latência (p99)                                            │
│           - CPU/Memory                                                │
│                                                                        │
│  Se OK: ambiente BLUE fica standby (ou é atualizado para próximo)    │
│  Se ERRO: Rollback → ALB Listener volta para BLUE (1 segundo)        │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 5. Rollback Instantâneo

A grande vantagem do Blue/Green é o rollback:

```
┌─── Rollback ─────────────────────────────────────────────────────────┐
│                                                                        │
│  CENÁRIO: Deploy Green (v1.1) está causando erros                     │
│                                                                        │
│  Antes do rollback:                                                   │
│  ALB → GREEN (v1.1, com problemas) | BLUE (v1.0, standby)            │
│                                                                        │
│  ROLLBACK (1 comando ou 1 click):                                     │
│  ALB → BLUE (v1.0, estável) | GREEN (v1.1, sendo investigado)        │
│                                                                        │
│  Tempo de rollback: < 1 segundo (apenas muda a regra do listener)    │
│  Perda de dados: nenhuma (Blue nunca foi desligado)                   │
│  Impacto no cliente: imperceptível                                    │
│                                                                        │
│  Comparação com Recreate:                                             │
│  - Recreate rollback: 30s-5min (pull + stop + start da versão antiga)│
│  - Blue/Green rollback: < 1 segundo (muda ponteiro no ALB)           │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 6. Implementação Terraform — ALB + Target Groups

```hcl
# alb.tf — Application Load Balancer para Blue/Green

resource "aws_lb" "technova" {
  name               = "technova-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name    = "technova-alb"
    Project = "technova"
  }
}

# Target Group BLUE
resource "aws_lb_target_group" "blue" {
  name     = "technova-blue"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
    matcher             = "200"
  }

  tags = { Name = "technova-tg-blue", Color = "blue" }
}

# Target Group GREEN
resource "aws_lb_target_group" "green" {
  name     = "technova-green"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
    matcher             = "200"
  }

  tags = { Name = "technova-tg-green", Color = "green" }
}

# Listener — aponta para o ambiente ATIVO
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.technova.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn  # Blue é o padrão
  }
}
```

### 7. Traffic Switch via AWS CLI

O deploy (traffic switch) pode ser feito com um único comando:

```bash
# Mudar tráfego de Blue para Green
aws elbv2 modify-listener \
  --listener-arn arn:aws:elasticloadbalancing:us-east-1:ACCOUNT:listener/app/technova-alb/xxx/yyy \
  --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-east-1:ACCOUNT:targetgroup/technova-green/zzz

# Rollback: voltar para Blue
aws elbv2 modify-listener \
  --listener-arn arn:aws:elasticloadbalancing:us-east-1:ACCOUNT:listener/app/technova-alb/xxx/yyy \
  --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-east-1:ACCOUNT:targetgroup/technova-blue/zzz
```

---

## Conteúdo Teórico — Parte 2: Canary Deployment

### 1. A Analogia: Canários na Mina de Carvão

No século XIX, mineradores levavam canários para dentro das minas de carvão. Se houvesse gases tóxicos (monóxido de carbono, metano), o canário — mais sensível — morria primeiro, alertando os mineradores para evacuar antes que fosse tarde demais.

```
┌─── Analogia: Canary Deployment ──────────────────────────────────────┐
│                                                                        │
│  MINERAÇÃO (século XIX)              DEPLOY (século XXI)              │
│  ─────────────────────               ──────────────────               │
│  Mina de carvão                      Produção                         │
│  Canário                             Pequeno % de tráfego             │
│  Gases tóxicos                       Bugs, erros, crashes             │
│  Canário morre = ALERTA              Taxa de erro sobe = ROLLBACK     │
│  Mineradores evacuam                 Tráfego volta p/ versão estável  │
│  Canário vive = SEGURO               Métricas ok = continua rollout   │
│                                                                        │
│  O princípio: testar com pouco antes de comprometer com tudo          │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 2. Canary vs Blue/Green: Quando Usar Cada Um

```
┌─── Comparação ───────────────────────────────────────────────────────┐
│                                                                        │
│  BLUE/GREEN                          CANARY                           │
│  ──────────                          ──────                           │
│  100% do tráfego muda de uma vez     Tráfego muda gradualmente       │
│  Rollback: voltar 100% p/ Blue       Rollback: voltar 5% p/ 0%       │
│  Detecção de problemas: pós-switch   Detecção: durante o rollout     │
│  Impacto se der errado: 100% users   Impacto: apenas 5% users        │
│  Complexidade: média                 Complexidade: alta               │
│  Tempo de deploy: instantâneo        Tempo de deploy: gradual (min/h)│
│                                                                        │
│  Melhor para:                        Melhor para:                     │
│  • Deploys com alta confiança        • Mudanças de alto risco         │
│  • Rollback precisa ser instantâneo  • Muitos usuários em produção    │
│  • Apps internas ou baixo tráfego    • Validação com dados reais      │
│  • Hotfixes urgentes                 • Features novas incertas        │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 3. Weighted Routing com ALB

O ALB suporta **forward actions com pesos** (weights), permitindo dividir tráfego entre dois Target Groups:

```
┌─── Weighted Routing ─────────────────────────────────────────────────┐
│                                                                        │
│                    ┌──────────────────┐                                │
│  100 requests ───►│  Load Balancer   │                                │
│                    │  (ALB)           │                                │
│                    └────────┬─────────┘                                │
│                             │                                          │
│                    Weighted Forward Action                             │
│                    weight=95 │ weight=5                                │
│               ┌─────────────┼─────────────┐                           │
│               ▼                           ▼                            │
│     ┌─────────────────┐        ┌─────────────────┐                   │
│     │  Target Group   │        │  Target Group   │                   │
│     │  STABLE (v1.0)  │        │  CANARY (v1.1)  │                   │
│     │  95 requests    │        │  5 requests     │                   │
│     └─────────────────┘        └─────────────────┘                   │
│                                                                        │
│  Se Canary saudável: mudar pesos → 75/25 → 50/50 → 0/100            │
│  Se Canary com erro: mudar pesos → 100/0 (rollback)                  │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 4. Rollout Gradual: Etapas Recomendadas

```
┌─── Rollout Canary ───────────────────────────────────────────────────┐
│                                                                        │
│  Etapa 1: 5% canary (95% stable)                                     │
│  ├── Duração: 5-10 minutos                                           │
│  ├── Monitorar: error rate, latência p99, logs                       │
│  └── Decisão: métricas OK? → próxima etapa                           │
│                                                                        │
│  Etapa 2: 25% canary (75% stable)                                    │
│  ├── Duração: 10-15 minutos                                          │
│  ├── Monitorar: error rate, latência, CPU, memory                    │
│  └── Decisão: métricas OK? → próxima etapa                           │
│                                                                        │
│  Etapa 3: 50% canary (50% stable)                                    │
│  ├── Duração: 15-20 minutos                                          │
│  ├── Monitorar: todos os indicadores + feedback de usuários          │
│  └── Decisão: métricas OK? → promoção total                          │
│                                                                        │
│  Etapa 4: 100% canary (0% stable) = PROMOÇÃO COMPLETA               │
│  └── Nova versão é agora a versão estável                            │
│                                                                        │
│  ⚠️ Em QUALQUER etapa, se error rate > threshold → ROLLBACK para 0%  │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 5. Implementação Terraform — Weighted Forward Action

```hcl
# canary.tf — ALB Listener com weighted routing

resource "aws_lb_listener" "http_canary" {
  load_balancer_arn = aws_lb.technova.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.stable.arn
        weight = var.stable_weight  # Padrão: 100
      }

      target_group {
        arn    = aws_lb_target_group.canary.arn
        weight = var.canary_weight  # Padrão: 0
      }

      stickiness {
        enabled  = true
        duration = 300  # 5 min — mesmo usuário vai pro mesmo TG
      }
    }
  }
}

variable "stable_weight" {
  description = "Peso do tráfego para o Target Group estável"
  type        = number
  default     = 100
}

variable "canary_weight" {
  description = "Peso do tráfego para o Target Group canary"
  type        = number
  default     = 0
}
```

### 6. Script de Rollout Gradual

```bash
#!/bin/bash
# canary-rollout.sh — Rollout gradual com verificação de saúde

ALB_LISTENER_ARN="arn:aws:elasticloadbalancing:..."
TG_STABLE_ARN="arn:aws:elasticloadbalancing:.../technova-stable/..."
TG_CANARY_ARN="arn:aws:elasticloadbalancing:.../technova-canary/..."
HEALTH_URL="http://ALB_DNS/health"
ERROR_THRESHOLD=5  # % de erro máximo tolerado

# Função para atualizar pesos
update_weights() {
  local stable_weight=$1
  local canary_weight=$2
  
  echo "📊 Atualizando pesos: stable=$stable_weight%, canary=$canary_weight%"
  
  aws elbv2 modify-listener \
    --listener-arn $ALB_LISTENER_ARN \
    --default-actions "[{
      \"Type\": \"forward\",
      \"ForwardConfig\": {
        \"TargetGroups\": [
          {\"TargetGroupArn\": \"$TG_STABLE_ARN\", \"Weight\": $stable_weight},
          {\"TargetGroupArn\": \"$TG_CANARY_ARN\", \"Weight\": $canary_weight}
        ]
      }
    }]"
}

# Função para verificar saúde
check_health() {
  local duration=$1
  echo "🔍 Monitorando por ${duration}s..."
  
  local errors=0
  local total=0
  
  for i in $(seq 1 $duration); do
    status=$(curl -s -o /dev/null -w "%{http_code}" $HEALTH_URL)
    total=$((total + 1))
    if [ "$status" != "200" ]; then
      errors=$((errors + 1))
    fi
    sleep 1
  done
  
  error_rate=$((errors * 100 / total))
  echo "📈 Error rate: ${error_rate}% (threshold: ${ERROR_THRESHOLD}%)"
  
  if [ $error_rate -gt $ERROR_THRESHOLD ]; then
    echo "❌ Error rate excede threshold! Rollback!"
    return 1
  fi
  echo "✅ Saúde OK"
  return 0
}

# Rollback
rollback() {
  echo "🔄 ROLLBACK: voltando 100% para stable"
  update_weights 100 0
  echo "❌ Deploy canary ABORTADO"
  exit 1
}

# === ROLLOUT ===
echo "🚀 Iniciando Canary Rollout..."

# Etapa 1: 5% canary
update_weights 95 5
check_health 60 || rollback

# Etapa 2: 25% canary
update_weights 75 25
check_health 120 || rollback

# Etapa 3: 50% canary
update_weights 50 50
check_health 180 || rollback

# Etapa 4: 100% canary (promoção)
update_weights 0 100
echo "🎉 Canary promovido! Nova versão é agora 100% do tráfego."
```

### 7. Monitoramento Durante o Rollout

Métricas essenciais para observar durante um canary:

| Métrica | O que observar | Threshold de rollback |
|---------|---------------|:--------------------:|
| Error Rate (5xx) | Taxa de respostas com erro do servidor | > 5% |
| Latência p99 | Tempo de resposta dos 1% mais lentos | > 2x do baseline |
| CPU Usage | Utilização de CPU na instância canary | > 80% |
| Memory Usage | Utilização de memória | > 85% |
| Healthy Targets | Instâncias saudáveis no Target Group | < 100% |
| Request Count | Volume de requests no canary | Comparar com esperado |

```
┌─── Dashboard de Monitoramento ───────────────────────────────────────┐
│                                                                        │
│  Canary Rollout - TechNova API v1.1                                   │
│                                                                        │
│  Etapa atual: 2/4 (25% canary)                                       │
│  Tempo nesta etapa: 8min / 15min                                      │
│                                                                        │
│  Error Rate:  ████░░░░░░░░░░░░░░░░  2.1% ✅ (threshold: 5%)          │
│  Latência p99: ██████░░░░░░░░░░░░░░  180ms ✅ (baseline: 150ms)      │
│  CPU:         █████████░░░░░░░░░░░  45% ✅                            │
│  Memory:      ███████░░░░░░░░░░░░░  38% ✅                            │
│                                                                        │
│  Decisão automática em: 7 minutos                                     │
│  [Rollback Manual] [Promover Agora] [Pausar]                         │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

### 8. Rollback Automático por Taxa de Erro

```yaml
# Trecho do workflow GitHub Actions para canary com rollback automático
- name: Canary Health Check
  run: |
    echo "Monitorando canary por 60 segundos..."
    ERRORS=0
    TOTAL=0
    for i in $(seq 1 60); do
      STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$ALB_DNS/health)
      TOTAL=$((TOTAL + 1))
      if [ "$STATUS" != "200" ]; then
        ERRORS=$((ERRORS + 1))
      fi
      sleep 1
    done
    ERROR_RATE=$((ERRORS * 100 / TOTAL))
    echo "Error rate: ${ERROR_RATE}%"
    if [ $ERROR_RATE -gt 5 ]; then
      echo "::error::Error rate ${ERROR_RATE}% excede threshold de 5%"
      echo "ROLLBACK=true" >> $GITHUB_ENV
    fi

- name: Rollback se necessário
  if: env.ROLLBACK == 'true'
  run: |
    aws elbv2 modify-listener \
      --listener-arn ${{ secrets.ALB_LISTENER_ARN }} \
      --default-actions '[{"Type":"forward","ForwardConfig":{"TargetGroups":[{"TargetGroupArn":"${{ secrets.TG_STABLE_ARN }}","Weight":100},{"TargetGroupArn":"${{ secrets.TG_CANARY_ARN }}","Weight":0}]}}]'
    echo "🔄 Rollback executado — 100% do tráfego de volta para stable"
    exit 1
```

---

## Resumo dos Conceitos

| Conceito | Descrição |
|----------|-----------|
| Blue/Green Deployment | Dois ambientes idênticos; tráfego chaveado instantaneamente entre eles |
| Target Group | Grupo de instâncias EC2 registradas no ALB para receber tráfego |
| Traffic Switch | Ação de mudar o listener do ALB para apontar para outro Target Group |
| Zero Downtime | Deploy sem interrupção de serviço — tráfego sempre flui |
| Rollback Instantâneo | Reverter para a versão anterior em < 1 segundo via ALB |
| Canary Deployment | Deploy gradual com pequeno % do tráfego para validação |
| Weighted Routing | ALB distribui tráfego entre TGs proporcionalmente aos pesos |
| Rollout Gradual | Aumento progressivo do % de tráfego (5→25→50→100) |
| Error Rate Threshold | Limite de taxa de erro que dispara rollback automático |
| Stickiness | Garante que mesmo usuário vai para o mesmo TG durante sessão |
| ALB Health Check | Verificação periódica se instâncias estão respondendo corretamente |
| Promoção | Quando canary recebe 100% do tráfego e se torna a versão estável |
| Canary (analogia) | Canário em mina de carvão — detectar problemas antes que afetem todos |
| Forward Action | Ação do ALB listener que encaminha tráfego para Target Group(s) |

---

## Custo

| Serviço | Custo |
|---------|:-----:|
| Application Load Balancer | Coberto pelos créditos do Lab |
| ALB LCU (Load Balancer Capacity Units) | Coberto pelos créditos do Lab |
| EC2 t3.micro (Blue) | Coberto pelos créditos do Lab |
| EC2 t3.micro (Green/Canary) | Coberto pelos créditos do Lab |
| GitHub Actions (minutos, repo público) | **$0.00** (ilimitado) |
| Data Transfer (intra-AZ) | **$0.00** |

> **☁️ No AWS Academy Learner Lab os custos do ALB e das 2 instâncias t3.micro são cobertos pelos créditos do Lab.** O custo real para o laboratório é praticamente zero. Rode `terraform destroy` ao final da sessão para liberar os recursos do Lab.

---

*Próximas etapas: Laboratório Parte 1 (Blue/Green) → Laboratório Parte 2 (Canary) → TF (Trabalho de Fixação)*
