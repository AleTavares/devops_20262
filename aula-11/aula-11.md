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

# Aula 11 — Blue/Green e Canary Deployments

**DevOps — Centro Universitário UniFAAT**
Prof. Alexandre Tavares | Semestre 2026-2

---

# O Problema da TechNova

Um cliente enterprise reclamou: o sistema ficou fora por **8 segundos** durante um deploy.

> **Episódio 11 — "Deploy Invisível: Zero Downtime"**

- A estratégia **Recreate** (Aula 10) para o container antigo e sobe o novo
- Entre o `stop` e o `healthy`, a aplicação fica **indisponível**
- SLA de 99.9% não tolera downtime a cada release

> **Meta:** o deploy precisa ser **invisível** para o usuário — zero downtime e rollback em segundos.

---

# Objetivos de Aprendizagem

### Blue/Green
- Entender dois ambientes idênticos (Blue ativo, Green standby)
- Implementar com **ALB + 2 Target Groups**
- Fazer **traffic switch** instantâneo e **rollback** em < 1 segundo

### Canary
- Entender a analogia do canário na mina de carvão
- Implementar **weighted routing** no ALB
- Conduzir **rollout gradual** (5%→25%→50%→100%) com monitoramento
- Configurar **rollback automático** por taxa de erro

---

# O Downtime do Recreate

```
t=0s   [Container v1.0 rodando]   ← tráfego dos clientes
t=1s   docker stop v1.0           ← DOWNTIME COMEÇA
t=2s   docker pull v1.1           ← baixando imagem do ECR...
t=5s   docker run v1.1            ← iniciando container...
t=8s   [Container v1.1 healthy]   ← DOWNTIME TERMINA
```

- **8 segundos** de pedidos falhando (pode ser mais com imagens grandes)
- Sem lugar para onde voltar rápido se o deploy quebrar

> A imagem já está versionada no **Amazon ECR** (Aula 09) — o problema não é a imagem, é **como trocamos a versão em produção**.

---

# Blue/Green: Conceito

Dois ambientes idênticos rodando ao mesmo tempo:

```
                 ┌──────────────┐
 Usuários ─────►│  ALB         │
                 └──────┬───────┘
          ┌─────────────┴─────────────┐
          ▼                           ▼
  ┌───────────────┐          ┌───────────────┐
  │  TG BLUE      │          │  TG GREEN     │
  │  v1.0 (ativo) │          │  v1.1 (standby)│
  └───────────────┘          └───────────────┘
```

- **Deploy** = mudar para onde o ALB aponta
- **Rollback** = voltar o ALB para o grupo anterior
- **Downtime** = ZERO

> **Analogia:** duas cortinas de teatro — troca-se a cena sem o público perceber.

---

# Componentes AWS do Blue/Green

| Componente | Função |
|-----------|--------|
| **ALB** | Recebe o tráfego e distribui para Target Groups |
| **Listener** | Define qual Target Group recebe o tráfego |
| **TG Blue** | Versão ATUAL (estável) |
| **TG Green** | NOVA versão (a validar) |
| **Health Check** | Verifica saúde de cada instância |

> **☁️ Learner Lab:** ALB, Target Groups e EC2 são **permitidos**. Região `us-east-1`, credenciais temporárias de sessão, instance profile = `LabInstanceProfile`.

---

# Fluxo de Deploy Blue/Green

```
ESTADO INICIAL: ALB → TG BLUE (v1.0)

1. Deploy no GREEN   → login ECR + docker pull v1.1 + docker run
2. Health Check      → GET /health → 200 OK ✅
3. Traffic Switch    → ALB Listener → TG GREEN (instantâneo)
4. Monitorar         → erro 5xx, latência p99, CPU/memory

OK   → BLUE fica standby
ERRO → Rollback: ALB volta p/ BLUE (< 1 segundo)
```

> O switch é só mudar o `default_action` do listener — nenhuma conexão é perdida.

---

# Traffic Switch e Rollback via CLI

```bash
# Switch: Blue → Green
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$GREEN_TG_ARN

# Rollback: Green → Blue
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$BLUE_TG_ARN
```

| | Recreate | Blue/Green |
|---|---|---|
| Rollback | 30s–5min (pull + restart) | **< 1 segundo** (muda ponteiro) |
| Downtime | segundos | **zero** |

---

# Terraform — ALB + Target Groups

```hcl
resource "aws_lb_target_group" "blue" {
  name     = "technova-blue"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path = "/health"
    matcher = "200"
    interval = 10
  }
}
# ... "green" idêntico ...

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.technova.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.blue.arn  # Blue é o padrão
  }
}
```

---

# Canary: a Analogia do Canário

No século XIX, mineradores levavam canários — mais sensíveis a gases tóxicos — para alertar sobre perigo antes que atingisse a todos.

```
MINERAÇÃO                  DEPLOY
──────────                 ──────
Canário                    Pequeno % de tráfego
Gases tóxicos              Bugs, erros, crashes
Canário morre = ALERTA     Taxa de erro sobe = ROLLBACK
Canário vive = SEGURO      Métricas ok = continua rollout
```

> O princípio: **testar com pouco antes de comprometer com tudo**.

---

# Weighted Routing no ALB

Uma única regra encaminha para dois Target Groups com **pesos**:

```
 100 requests ──► ALB ──► weight=95 │ weight=5
                          ▼              ▼
                  ┌──────────────┐ ┌──────────────┐
                  │ STABLE v1.0  │ │ CANARY v1.1  │
                  │ 95 requests  │ │ 5 requests   │
                  └──────────────┘ └──────────────┘
```

- Canary saudável → ajustar pesos: 75/25 → 50/50 → 0/100
- Canary com erro → voltar para 100/0 (rollback)

---

# Rollout Gradual — Etapas

```
Etapa 1: 5% canary   ├─ Duração: 5-10 minutos
Etapa 2: 25% canary  ├─ Duração: 10-15 minutos
Etapa 3: 50% canary  ├─ Duração: 15-20 minutos
Etapa 4: 100% canary = PROMOÇÃO COMPLETA

⚠️ Em QUALQUER etapa: erro > threshold → ROLLBACK para 0%
```

Entre cada etapa, observa-se: error rate, latência p99, CPU, memory.

> O rollout avança **somente** se as métricas da etapa estiverem dentro do threshold.

---

# Terraform — Weighted Forward

```hcl
default_action {
  type = "forward"
  forward {
    target_group {
      arn    = aws_lb_target_group.stable.arn
      weight = var.stable_weight   # padrão 100
    }
    target_group {
      arn    = aws_lb_target_group.canary.arn
      weight = var.canary_weight   # padrão 0
    }
    stickiness {
      enabled  = true
      duration = 300   # 5 min — mesmo usuário no mesmo TG
    }
  }
}
```

---

# Decisão por Métrica

| Métrica | Threshold de rollback |
|---------|:---------------------:|
| Error rate (5xx) | > 5% (ou 2x do baseline) |
| Latência p99 | > 2x do baseline |
| CPU | > 80% |
| Memory | > 85% |
| Healthy targets | < 100% |

```bash
error_rate=$((errors * 100 / total))
if [ $error_rate -gt $ERROR_THRESHOLD ]; then
  echo "❌ Rollback!"; update_weights 100 0; exit 1
fi
```

> A decisão de promover ou reverter é **objetiva**, baseada em números — não em "achismo".

---

# Deploy puxando do ECR

O deploy nas instâncias Blue/Green sempre **loga no ECR antes do pull**:

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$REGISTRY"
docker pull "$REGISTRY/technova-api:$SHA"
```

> **☁️ Learner Lab:** no GitHub Actions, as 3 credenciais de sessão (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`) entram como **secrets** e expiram por sessão. Em produção real, o ideal seria **OIDC + role IAM** — que o Lab não permite.

---

# Canary vs Blue/Green: Quando Usar

| | Blue/Green | Canary |
|---|---|---|
| Troca de tráfego | 100% de uma vez | gradual |
| Impacto se der errado | 100% dos usuários | ~5% dos usuários |
| Tempo de deploy | instantâneo | gradual (min/h) |
| Complexidade | média | alta |

**Blue/Green:** alta confiança, hotfix testado, baixo tráfego.
**Canary:** mudança de alto risco, muitos usuários, validar com dados reais.

---

# Resumo dos Conceitos

| Conceito | Descrição |
|----------|-----------|
| Blue/Green | Dois ambientes; tráfego chaveado de uma vez |
| Canary | Rollout gradual com % crescente de tráfego |
| Target Group | Grupo de EC2 registradas no ALB |
| Traffic Switch | Mudar o listener para outro TG |
| Weighted Routing | ALB divide tráfego por pesos |
| Stickiness | Fixa o usuário no mesmo TG na sessão |
| Rollback | Voltar o tráfego para a versão estável |
| Error Rate Threshold | Limite que dispara rollback automático |

---

# Referências e Próximos Passos

**Referências:**
- Blue/Green — [martinfowler.com/bliki/BlueGreenDeployment](https://martinfowler.com/bliki/BlueGreenDeployment.html)
- Canary Release — [martinfowler.com/bliki/CanaryRelease](https://martinfowler.com/bliki/CanaryRelease.html)
- ALB — [docs.aws.amazon.com/elasticloadbalancing](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- Weighted Target Groups — [forward-actions](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#forward-actions)

**Para a próxima aula:**
- Completar o TF: Blue/Green **ou** Canary com ALB + ECR
- Guardar a infraestrutura — a Aula 12 a reaproveita

**Próxima aula:**
**Aula 12 — Observabilidade e Rollback Automatizado**
CloudWatch, alarmes e rollback disparado por métrica.
