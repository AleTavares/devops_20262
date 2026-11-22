---
marp: true
theme: unset
paginate: true
backgroundColor: #F5F7FA
style: |
  section {
    font-family: 'Segoe UI', Arial, sans-serif;
    font-size: 17px;
    padding: 35px 48px 28px 48px;
    color: #333333;
  }
  h1 {
    color: #1B3A5C;
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
  img.diagram { display: block; margin: 6px auto 0; max-height: 310px; width: auto; }
  img.diagram-wide { display: block; margin: 6px auto 0; max-height: 260px; width: auto; }
  img.diagram-side { float: right; margin: 0 0 6px 18px; max-height: 320px; width: auto; }
  section.title {
    background-color: #1B3A5C;
    color: white !important;
    text-align: center;
    justify-content: center;
    padding: 60px;
  }
  section.title h1 { color: white !important; border-bottom: 3px solid #F58220; font-size: 2.2em; }
  section.title h2 { color: #F58220 !important; font-size: 1.3em; }
  section.title h3 { color: #ccc !important; }
  section.title p { color: #ccc !important; }
  section.title strong { color: #F58220 !important; }
  footer { color: #888; font-size: 0.62em; }
footer: "DevOps — UniFAAT 2026-2 | Prof. Alexandre Tavares"
---

<!-- _class: title -->
<!-- _backgroundColor: #1B3A5C -->
<!-- _color: white -->

![bg right:40%](img/aula-11/rd002.png)

# Aula 11 — Blue/Green e Canary Deployments

## <span style="color:#F58220">DevOps — Centro Universitário UniFAAT</span>

<span style="color:#cccccc">Prof. Alexandre Tavares | Semestre 2026-2</span>

---

# Objetivos de Aprendizagem 🎯

1. Compreender o conceito de **Blue/Green deployment** e zero downtime
2. Configurar **ALB + Target Groups** no Terraform para Blue/Green
3. Executar o **traffic switch** via AWS CLI em < 1 segundo
4. Realizar **rollback instantâneo** voltando o listener para Blue
5. Compreender o conceito de **Canary deployment** e a analogia da mineração
6. Implementar **weighted routing** no ALB para divisão gradual de tráfego
7. Executar um **rollout gradual** 5% → 25% → 50% → 100%
8. Implementar **auto-rollback** por taxa de erro no pipeline

---

# O Problema: Downtime no Recreate 😱

### O incidente TechNova — 8 segundos que custaram caro:

- Durante a demo ao investidor, **8 segundos de tela de erro**
- Causa: estratégia Recreate para o container antes de subir o novo
- Resultado: cliente enterprise ameaçou cancelar contrato

<img src="img/aula-11/rd001.png" class="diagram" />

> **SLA 99.9% = máximo 8.76h de downtime por ANO.** Um deploy manual por semana = SLA violado em 2 meses.

---

# Blue/Green — Conceito Fundamental 🎭

### Dois ambientes idênticos — switch instantâneo no ALB:

- **Blue:** ambiente ATIVO, recebendo tráfego dos usuários
- **Green:** standby, nova versão sendo preparada nos bastidores
- **Switch:** Listener muda de Blue para Green — **usuário não percebe**

<img src="img/aula-11/rd002.png" class="diagram" />

**Deploy = apenas mudar o apontamento do Listener**

---

# Componentes AWS — ALB + Target Groups ⚙️

<img src="img/aula-11/rd003.png" class="diagram-side" />

| Componente | Função |
|---|---|
| **ALB** | Recebe tráfego, distribui para TGs |
| **Listener** | Define qual TG recebe o tráfego |
| **Target Group Blue** | Versão ATUAL (estável) |
| **Target Group Green** | NOVA versão |
| **Health Check** | Verifica saúde das instâncias |

### Fluxo do switch:
1. ALB recebe requisição do cliente
2. Listener decide: **qual Target Group?**
3. Modificar o Listener = **mudar destino**
4. TGs não mudam — só o apontamento

**Switch é uma chamada de API → < 1 segundo**

---

# Terraform para Blue/Green 🏗️

```hcl
resource "aws_lb" "main" {
  name               = "technova-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets
}
resource "aws_lb_target_group" "blue" {
  name     = "technova-blue"
  port     = 3000;  protocol = "HTTP";  vpc_id = var.vpc_id
  health_check { path = "/health";  matcher = "200" }
}
resource "aws_lb_target_group" "green" {
  name     = "technova-green"
  port     = 3000;  protocol = "HTTP";  vpc_id = var.vpc_id
  health_check { path = "/health";  matcher = "200" }
}
# Listener aponta inicialmente para Blue
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}
```

---

# Fluxo de Deploy Blue/Green 🚀

<img src="img/aula-11/rd004.png" class="diagram-side" />

**Passo 1:** Deploy v1.1 no **Green**
*(Blue continua 100%)*

**Passo 2:** ALB Health Check verifica Green
`GET /health → 200 OK ✅`

**Passo 3:** Traffic Switch — Listener → Green
*(instantâneo — sem downtime)*

**Passo 4:** Monitorar métricas:
- Error rate 5xx < 5%
- Latência p99 dentro do baseline
- CPU/Memory normais

**Passo 5A ✅:** Métricas OK → Blue fica standby

**Passo 5B ❌:** Problema → **Rollback em < 1s**

---

# Traffic Switch — AWS CLI ⚡

### O comando que faz o switch:

```bash
# Switch Blue → Green
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$GREEN_TG_ARN

echo "✅ Switch concluído — 100% no Green"

# Rollback: voltar para Blue
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$BLUE_TG_ARN
```

| Etapa | Tempo |
|---|---|
| Preparar Green (subir containers) | 1–3 min |
| Health check do Target Group | 30s |
| **Modificar Listener (switch)** | **< 1 segundo** |
| Usuários percebem downtime | **Zero** |

---

# Rollback Instantâneo 🔙

<img src="img/aula-11/rd005.png" class="diagram-wide" />

| Estratégia | Tempo | Reinicia containers? |
|---|---|---|
| Recreate | 30s a 5 min | **Sim** |
| **Blue/Green** | **< 1 segundo** | **Não** |
| Canary | 5–30s | Não |

> Blue **nunca foi desligado** — apenas uma chamada de API ao ALB.

---

# Canary — A Analogia da Mina 🐦

<img src="img/aula-11/rd006.png" class="diagram-wide" />

> Mineradores levavam canários para detectar gases tóxicos **antes** de serem afetados. No deploy, 5% do tráfego é o "canário" — se houver erros, o rollback protege os 95% restantes.

---

# Blue/Green vs Canary — Quando Usar 📊

<img src="img/aula-11/rd007.png" class="diagram-side" />

| Critério | Blue/Green | Canary |
|---|---|---|
| Switch | 100% de uma vez | Gradual 5→100% |
| Rollback | < 1 segundo | 5–30 segundos |
| Impacto se falhar | Zero | Só X% |
| Teste em produção | Não | Sim |
| Complexidade | Média | Alta |

### Regra prática TechNova:
- **Blue/Green:** correção urgente
- **Canary:** feature nova incerta

---

# Weighted Routing com ALB ⚖️

<img src="img/aula-11/rd008.png" class="diagram-side" />

```bash
# Canary inicial: 95% stable + 5% canary
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions '[{
    "Type": "forward",
    "ForwardConfig": {
      "TargetGroups": [
        {"TargetGroupArn":"'$BLUE_TG'","Weight":95},
        {"TargetGroupArn":"'$GREEN_TG'","Weight":5}
      ],
      "TargetGroupStickinessConfig": {
        "Enabled": true, "DurationSeconds": 300
      }
    }
  }]'
```

> **Stickiness:** mesmo usuário sempre cai no mesmo TG durante a sessão.

---

# Rollout Gradual — 5 → 25 → 50 → 100 📈

<img src="img/aula-11/rd009.png" class="diagram-wide" />

| Etapa | Canary % | Duração | Decisão |
|---|---|---|---|
| Inicial | **5%** | 15–30 min | Error rate < 5%? |
| Expansão | **25%** | 15–30 min | Latência OK? |
| Metade | **50%** | 10–15 min | CPU/Memory OK? |
| Promoção | **100%** | — | ✅ Finalizado |

---

# Monitoramento do Canary 📊

<img src="img/aula-11/rd010.png" class="diagram-side" />

| Métrica | Threshold de Rollback |
|---|---|
| Error Rate 5xx | > 5% |
| Latência p99 | > 2x baseline |
| CPU | > 85% por 5 min |
| Healthy targets | < 50% do TG |

```bash
# Rollback automático no pipeline
RATE=$((ERRORS * 100 / TOTAL))
if [ $RATE -gt 5 ]; then
  aws elbv2 modify-listener \
    --listener-arn $LISTENER_ARN \
    --default-actions \
      Type=forward,TargetGroupArn=$BLUE_TG_ARN
  exit 1
fi
```

---

# Script de Rollout Gradual 💻

```bash
#!/bin/bash
update_weights() {
  aws elbv2 modify-listener --listener-arn $LISTENER_ARN \
    --default-actions "[{\"Type\":\"forward\",\"ForwardConfig\":{
      \"TargetGroups\":[
        {\"TargetGroupArn\":\"$BLUE_TG\",\"Weight\":$1},
        {\"TargetGroupArn\":\"$GREEN_TG\",\"Weight\":$2}
      ]}}]"
  echo "Pesos: Blue=$1% Green=$2%"
}

check_health() {
  RATE=$(aws cloudwatch get-metric-statistics \
    --metric-name HTTPCode_Target_5XX_Count \
    --namespace AWS/ApplicationELB \
    --query 'Datapoints[0].Sum' --output text)
  [ "${RATE:-0}" -gt 10 ] && return 1; return 0
}

rollback() { echo "🔄 ROLLBACK"; update_weights 100 0; exit 1; }

for weights in "95 5" "75 25" "50 50" "0 100"; do
  read blue green <<< $weights
  update_weights $blue $green
  sleep 1800          # observar 30 min
  check_health || rollback
done
echo "🎉 Canary promovido!"
```

---

# Comparação Final 📋

| Critério | Recreate | Blue/Green | Canary |
|---|---|---|---|
| **Downtime** | Sim | **Zero** | **Zero** |
| **Rollback** | 1–5 min | **< 1s** | 5–30s |
| **Complexidade** | Baixa | Média | Alta |
| **Custo infra** | 1x | 2x | 2x |
| **Teste em prod** | Não | Não | **Sim** |
| **Impacto falha** | 100% | Zero | X% |
| **Ideal para** | Dev/staging | Releases críticas | Features novas |

### Evolução recomendada:
1. **Aula 11:** Blue/Green → zero downtime em produção
2. **Próximo semestre:** Canary → releases de alto risco
3. **Aula 12:** Feature flags → controle ainda mais granular

---

# Revisão do TA — Blue/Green 📖

<img src="img/aula-11/ta002.png" class="diagram-side" />

### O que você estudou no TA — Parte 1:

- O problema do Recreate: **8 segundos de downtime**
- Blue = ambiente ativo; Green = standby
- ALB Listener como **ponto de controle do tráfego**
- Rollback em < 1 segundo vs 30s–5min no Recreate
- Custo: infraestrutura dobrada durante o deploy

### Questão de aquecimento:
> No Blue/Green, o que acontece com o ambiente Blue **após** o traffic switch para Green?

---

# Revisão do TA — Canary 📖

<img src="img/aula-11/ta004.png" class="diagram-side" />

### O que você estudou no TA — Parte 2:

- **Analogia:** canário na mina detecta perigo antes dos humanos
- Rollout gradual: **5% → 25% → 50% → 100%**
- **Stickiness:** mesmo usuário sempre vai ao mesmo Target Group
- Métricas: error rate, latência p99, CPU, memory
- Rollback automático quando métrica > threshold

### Questão de aquecimento:
> Error rate sobe para 12% (threshold = 5%). O que deve acontecer?

---

# Cronograma da Aula ⏰

| Bloco | Atividade | Duração |
|---|---|---|
| 1 | Revisão TA + Discussão | 30 min |
| 2 | Teoria — Blue/Green e ALB | 50 min |
| 3 | Lab Parte 1 — Terraform ALB + traffic switch | 60 min |
| 4 | Teoria — Canary e weighted routing | 40 min |
| 5 | Lab Parte 2 — Rollout gradual + auto-rollback | 60 min |
| 6 | Encerramento + Trabalho Final (TF) | 15 min |

### Sobre os laboratórios:
- **Lab 1:** Provisionar ALB + 2 Target Groups Blue/Green via Terraform, executar switch e rollback via AWS CLI
- **Lab 2:** Implementar weighted routing, script de rollout gradual e rollback automático por taxa de erro

---

# Referências e Próximos Passos 📚

### Referências:
- **AWS ALB Weighted Routing** — docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html
- **Blue/Green Deployments na AWS** — docs.aws.amazon.com/whitepapers/latest/blue-green-deployments
- **Canary Release (Martin Fowler)** — martinfowler.com/bliki/CanaryRelease.html
- **AWS CLI — modify-listener** — awscli.amazonaws.com/v2/documentation/api/latest/reference/elbv2/modify-listener.html

### Próxima aula:
> **Aula 12 — Rollback Strategies e AIOps**
> MTTR, expand-contract migrations, feature flags, anomaly detection com Bedrock.

### Para a próxima aula:
- ✅ Estudar o **TA.md** da Aula 12
- ✅ Ter Blue/Green funcionando com ALB
- ✅ Revisar conceitos de CloudWatch Metrics
- ✅ Completar o TF desta aula

---

# Prova do Segundo Bimestre — Como Funciona

A prova vale **10 pontos** e acontece em **dois momentos**:

| Momento | O que é | Quando | Valor |
|---------|---------|--------|:-----:|
| **1 — Parte Prática** | Desafio técnico individual | Aulas 11 a 15 — entrega acumulativa | **5,0 pts** |
| **2 — Parte Teórica** | Prova escrita em sala | Dia da prova, conforme calendário | **5,0 pts** |

**Parte Teórica (no dia da prova):** 7 múltipla escolha + 3 dissertativas
sobre o conteúdo das aulas 8–15 e sobre o próprio desafio técnico.

---

# Desafio Técnico — Moodle Docker AWS Challenge

**Você tem as próximas semanas para desenvolver e entregar.**

📦 **Template:** [github.com/AleTavares/implement_Moodle](https://github.com/AleTavares/implement_Moodle)

**O que você vai construir:**
- Ambiente Docker local do Moodle (`docker compose up -d`)
- Módulos Terraform: **networking** · **compute** (EC2 + user_data.sh) · **database** (RDS privado)
- Workflow `terraform-plan.yml` em cada PR
- Documento de arquitetura `docs/architecture-design.md` ⚠️ **eliminatório**
- Evidência de uso do **Kiro** e **Kiro Workflows**

**Faça agora:** fork → `docker compose up -d` → leia o `CHALLENGE.md`
