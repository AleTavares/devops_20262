# Materiais Complementares | Aula 11 — Blue/Green e Canary Deployments

## Documentação Oficial AWS

- [Application Load Balancer — User Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) — Guia completo do ALB: listeners, target groups, routing, health checks
- [ALB Listener Rules](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-update-rules.html) — Como configurar e modificar regras do listener
- [ALB Target Groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html) — Registro de targets, health checks, stickiness
- [Weighted Target Groups](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html#forward-actions) — Forward actions com múltiplos target groups e pesos
- [ALB Health Checks](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html) — Configuração detalhada dos health checks
- [Amazon ECR — User Guide](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html) — Registry das imagens que o ALB deploya; pull via `aws ecr get-login-password`
- [AWS Academy Learner Lab](https://awsacademy.instructure.com/) — Ambiente do curso: credenciais temporárias, `us-east-1`, custos cobertos pelos créditos do Lab

## Documentação Terraform

- [aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) — Resource do Application Load Balancer
- [aws_lb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) — Resource do Target Group
- [aws_lb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) — Resource do Listener (inclui forward com weights)
- [aws_lb_target_group_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) — Registro de instances nos TGs
- [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) — Security Groups

## AWS CLI — Referência

- [elbv2 modify-listener](https://docs.aws.amazon.com/cli/latest/reference/elbv2/modify-listener.html) — Modificar listener (traffic switch / weight update)
- [elbv2 describe-target-health](https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-target-health.html) — Verificar saúde dos targets
- [elbv2 describe-listeners](https://docs.aws.amazon.com/cli/latest/reference/elbv2/describe-listeners.html) — Listar configuração dos listeners

## Vídeos Recomendados

- [Blue/Green Deployments on AWS — AWS re:Invent](https://www.youtube.com/results?search_query=blue+green+deployment+aws+reinvent) — Apresentação oficial da AWS sobre Blue/Green (~45 min)
- [Canary Deployments Explained — TechWorld with Nana](https://www.youtube.com/results?search_query=canary+deployment+explained+techworld+nana) — Explicação visual clara do conceito Canary (~15 min)
- [AWS ALB Tutorial — Stephane Maarek](https://www.youtube.com/results?search_query=aws+alb+tutorial+stephane+maarek) — ALB, Target Groups e Listeners na prática (~20 min)
- [Zero Downtime Deployments — DevOps Toolkit](https://www.youtube.com/results?search_query=zero+downtime+deployment+devops+toolkit) — Comparação entre estratégias de deploy (~25 min)
- [Terraform ALB Configuration](https://www.youtube.com/results?search_query=terraform+alb+target+group+tutorial) — Provisionando ALB com Terraform passo a passo (~30 min)

## Artigos e Tutoriais

- [Blue/Green Deployments — Martin Fowler](https://martinfowler.com/bliki/BlueGreenDeployment.html) — Artigo clássico que popularizou o termo Blue/Green
- [Canary Releases — Martin Fowler](https://martinfowler.com/bliki/CanaryRelease.html) — Definição e princípios do Canary Release
- [Deployment Strategies Defined — Harness.io](https://www.harness.io/blog/blue-green-canary-deployment-strategies) — Comparação visual entre Blue/Green, Canary e Rolling
- [AWS Blue/Green Deployment Whitepaper](https://docs.aws.amazon.com/whitepapers/latest/blue-green-deployments/welcome.html) — Whitepaper oficial da AWS sobre implementação Blue/Green
- [Progressive Delivery — LaunchDarkly](https://launchdarkly.com/blog/what-is-progressive-delivery/) — Conceito de Progressive Delivery (evolução do Canary)
- [Zero Downtime Deployment Patterns — DZone](https://dzone.com/articles/zero-downtime-deployment) — Padrões de deploy sem downtime

## GitHub Actions — Referência

- [workflow_dispatch event](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#workflow_dispatch) — Trigger manual com inputs
- [appleboy/ssh-action](https://github.com/appleboy/ssh-action) — Action para executar comandos via SSH
- [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials) — Configurar credenciais AWS (no Learner Lab, usando as credenciais temporárias de sessão como secrets)
- [aws-actions/amazon-ecr-login](https://github.com/aws-actions/amazon-ecr-login) — Login no Amazon ECR dentro do workflow
- [Environment variables and conditionals](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#env) — Uso de variáveis e condicionais

## Ferramentas Relacionadas

- [AWS CodeDeploy](https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html) — Serviço gerenciado da AWS para Blue/Green e Canary (fora do escopo do curso, mas bom conhecer)
- [Flagger (Kubernetes)](https://flagger.app/) — Canary automatizado para Kubernetes (referência para entender automação avançada)
- [Argo Rollouts](https://argoproj.github.io/rollouts/) — Progressive delivery para Kubernetes com Blue/Green e Canary
- [LaunchDarkly](https://launchdarkly.com/) — Feature flags que complementam Canary (controle por feature, não por infra)
- [Grafana](https://grafana.com/) — Dashboard para monitoramento durante rollout canary

## Conceitos Relacionados (para aprofundamento)

- **Progressive Delivery:** evolução do CI/CD que inclui Canary, Feature Flags e experimentação
- **Feature Flags:** alternativa ao Canary em nível de código (habilitar feature para % de usuários)
- **Circuit Breaker:** padrão que "abre o circuito" quando taxa de erro é alta (complementa Canary)
- **Chaos Engineering:** testar resiliência injetando falhas (Netflix Chaos Monkey)
- **SLO/SLI/SLA:** métricas de confiabilidade que definem thresholds de rollback
- **Observability (Logs, Metrics, Traces):** fundamento para decisões de promoção/rollback

## Livros Recomendados

- **"Continuous Delivery" — Jez Humble & David Farley** — Capítulo sobre deploy strategies (Blue/Green é apresentado aqui)
- **"Accelerate" — Nicole Forsgren, Jez Humble, Gene Kim** — Métricas de performance em deploy (DORA metrics)
- **"Release It!" — Michael Nygard** — Padrões de estabilidade em produção (circuit breakers, bulkheads)
- **"The Phoenix Project" — Gene Kim** — Romance sobre DevOps (contexto cultural para entender a importância de zero downtime)

## Comparação Rápida: Estratégias de Deploy

| Estratégia | Downtime | Rollback | Complexidade | Custo Infra | Risco |
|-----------|:--------:|:--------:|:------------:|:-----------:|:-----:|
| Recreate | Sim (segundos/minutos) | Lento | Baixa | 1x | Alto |
| Rolling Update | Mínimo | Médio | Média | 1x | Médio |
| **Blue/Green** | **Zero** | **Instantâneo** | **Média** | **2x** | **Baixo** |
| **Canary** | **Zero** | **Instantâneo** | **Alta** | **~1.05x** | **Muito Baixo** |
| A/B Testing | Zero | Instantâneo | Muito Alta | 2x | Muito Baixo |

## Cheat Sheet — Comandos AWS CLI para Blue/Green e Canary

```bash
# === BLUE/GREEN ===

# Traffic switch: Blue → Green
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$GREEN_TG_ARN

# Rollback: Green → Blue
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$BLUE_TG_ARN

# === CANARY (Weighted) ===

# Iniciar canary: 95/5
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions '[{"Type":"forward","ForwardConfig":{"TargetGroups":[
    {"TargetGroupArn":"'$STABLE_TG_ARN'","Weight":95},
    {"TargetGroupArn":"'$CANARY_TG_ARN'","Weight":5}
  ],"TargetGroupStickinessConfig":{"Enabled":true,"DurationSeconds":300}}}]'

# Promover canary: 0/100
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions '[{"Type":"forward","ForwardConfig":{"TargetGroups":[
    {"TargetGroupArn":"'$STABLE_TG_ARN'","Weight":0},
    {"TargetGroupArn":"'$CANARY_TG_ARN'","Weight":100}
  ]}}]'

# Rollback canary: 100/0
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions '[{"Type":"forward","ForwardConfig":{"TargetGroups":[
    {"TargetGroupArn":"'$STABLE_TG_ARN'","Weight":100},
    {"TargetGroupArn":"'$CANARY_TG_ARN'","Weight":0}
  ]}}]'

# === ECR (pull da imagem no deploy) ===

# Login no Amazon ECR (Learner Lab, credenciais de sessão)
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# === DIAGNÓSTICO ===

# Ver health de todos os targets
aws elbv2 describe-target-health --target-group-arn $TG_ARN

# Ver configuração do listener
aws elbv2 describe-listeners --load-balancer-arn $ALB_ARN

# Ver detalhes do ALB
aws elbv2 describe-load-balancers --names technova-alb
```

---

*Estes materiais complementam a Aula 11. Use-os para aprofundar conceitos e resolver dúvidas durante o laboratório e o trabalho de fixação.*
