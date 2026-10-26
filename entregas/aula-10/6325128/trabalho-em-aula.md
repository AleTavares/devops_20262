# Trabalho em Aula — Aula 10: GitOps e Estratégias de Deploy

**Aluno:** Felipe Damasceno
**RA:** 6325128
**Data:** 22/10/2026

## Parte 1 — Proteções GitOps

| # | Proteção | Como implementar |
|:-:|----------|-----------------|
| 1 | Branch protection | Settings → Branches → Require PR + approvals (mínimo 2 reviewers) |
| 2 | Terraform plan automático | CI rodando `terraform plan` em cada PR + comentário com preview das mudanças |
| 3 | Testes automatizados de infraestrutura | `terraform validate`, `tflint`, `checkov` (security scanning) no pipeline |
| 4 | Aprovação manual de apply | Workflow com job de `terraform apply` que requer aprovação via GitHub Environments |
| 5 | CODEOWNERS | Arquivo `.github/CODEOWNERS` com owners obrigatórios para paths críticos (ex: `/terraform/production/*`) |

### O que acontece se o apply falhar depois do merge?

**State do Terraform:**
- O state pode ficar **parcialmente aplicado** (algumas resources criadas, outras não)
- O state file permanece consistente com a realidade da AWS, mas não com o código desejado
- Na próxima execução, o Terraform detectará a diferença e tentará corrigir

**Rollback de infraestrutura:**
- `git revert` do commit problemático cria um novo commit revertendo as mudanças
- O pipeline roda `terraform apply` novamente com o código revertido
- **Atenção:** isso pode não restaurar dados perdidos (ex: tabelas de banco de dados destruídas)

**Limitações do git revert:**
- ✅ Funciona para resources stateless (VMs, load balancers, security groups)
- ❌ Não recupera dados (RDS databases, S3 objects deletados)
- ❌ Alguns resources têm retention period ou soft-delete (ex: KMS keys)

### Como prevenir destroy acidental do RDS?

**Solução 1: Proteção no Terraform**
```hcl
resource "aws_db_instance" "main" {
  # ...
  deletion_protection = true
  skip_final_snapshot = false
  final_snapshot_identifier = "pre-deletion-snapshot-${timestamp()}"
  
  lifecycle {
    prevent_destroy = true  # Erro se tentar destruir via Terraform
  }
}
```

**Solução 2: Controle no Pipeline**
- Policy as Code com OPA (Open Policy Agent) ou Sentinel
- Regra: bloquear qualquer `terraform plan` que mostre `-/destroy` em resources críticos (RDS, S3 buckets de produção)
- Requer aprovação adicional de DBA/CTO se detect destroy de databases
```yaml
# Exemplo no CI
- name: Check for destructive changes
  run: |
    if terraform show -json plan.out | jq '.resource_changes[] | select(.change.actions[] == "delete") | .address' | grep -q "aws_db_instance"; then
      echo "❌ Destructive change detected on RDS. Manual approval required."
      exit 1
    fi
```

## Parte 2 — Estratégia de Deploy por Aplicação

| Aplicação | Estratégia escolhida | Justificativa |
|-----------|:--------------------:|---------------|
| Admin Dashboard | **Recreate** | Usado apenas por 5 pessoas em horário comercial. Downtime de 30-60s é aceitável. Não justifica infraestrutura duplicada. Deploy pode ser agendado para horário de menor uso (almoço/fim do dia). |
| API de Pedidos | **Canary** (ideal) ou **Blue-Green** (alternativa) | SLA 99.9% exige zero downtime. Canary permite validar nova versão com 5-10% do tráfego antes de rollout completo, reduzindo blast radius de bugs. Blue-Green é mais simples mas requer infraestrutura 2x durante deploy. |
| Job de Relatórios | **Recreate** | Roda 1x/dia às 3h (fora de horário). Não há tráfego simultâneo. Se falhar, pode ser re-executado manualmente. Zero necessidade de infraestrutura extra. |

### Discussão

#### Downtime aceitável (para quem?):
- **Para usuários internos (Admin Dashboard):** 30-60s é aceitável, especialmente se notificados ("Sistema será atualizado das 12h-12h05")
- **Para clientes externos (API de Pedidos):** Mesmo 5s de downtime pode resultar em pedidos perdidos, insatisfação e perda de receita. SLA 99.9% = máximo 8.76h/ano de downtime.
- **Para jobs batch (Relatórios):** Downtime é irrelevante se agendado para horário sem execução (3h-4h da manhã).

**Regra geral:** Downtime é aceitável quando:
1. Não há usuários ativos no momento
2. O custo do downtime < custo da infraestrutura para zero-downtime
3. Existe comunicação prévia aos usuários

#### Custo de zero downtime:
| Estratégia | Custo adicional | Quando usar |
|------------|-----------------|-------------|
| **Recreate** | $0 (sem custo extra) | Apps internas, baixo tráfego |
| **Rolling** | $0-10% (precisa de mínimo 2 instâncias) | Aplicações stateless, aceita degradação temporária |
| **Blue-Green** | **+100%** durante deploy (infra duplicada) | Apps críticas, rollback instantâneo necessário |
| **Canary** | +10-20% (precisa de infra de roteamento inteligente + observability) | Apps de alta criticidade, validação gradual |

**Para TechNova hoje (startup, 1 servidor):**
- ❌ Blue-Green é inviável (requer 2 ambientes completos)
- ✅ Rolling é possível se subir 1 instância extra temporariamente
- ✅ Recreate é a opção atual mais realista

**O que precisa mudar para Blue-Green:**
- Load balancer (ALB na AWS)
- Auto Scaling Group ou Kubernetes
- Budget para 2x instâncias durante deploy (~15 minutos)

#### Quando Recreate é MELHOR que Blue-Green:

1. **Stateful jobs** que não podem ter 2 versões rodando simultaneamente (ex: job que processa fila única)
2. **Migrações de banco de dados** incompatíveis entre versões antiga/nova
3. **Ambientes de desenvolvimento/staging** onde downtime não impacta usuários
4. **Startup fase inicial** com 1 servidor e budget limitado
5. **Aplicações com mudanças de schema** que requerem maintenance window

### O que a TechNova deve fazer agora vs planejar para 6 meses:

**AGORA (MVP, 1 servidor, poucos usuários):**
- ✅ Recreate para tudo
- ✅ Agendar deploys para horários de baixo tráfego (3-5h da manhã)
- ✅ Notificar usuários internos sobre janelas de manutenção
- ✅ Ter backups automatizados + plano de rollback testado
- ✅ Monitoramento básico (healthcheck, logs, alertas)

**EM 6 MESES (crescimento, SLA com clientes):**
- 🎯 Blue-Green ou Canary para API de Pedidos
- 🎯 Auto Scaling com mínimo 2 instâncias
- 🎯 Load balancer com health checks
- 🎯 Feature flags para desabilitar funcionalidades problemáticas sem redeploy
- 🎯 Observability completa (métricas de negócio, tracing distribuído)

**Critério de decisão:** Quando a perda de receita/confiança por downtime > custo de infraestrutura para zero-downtime, é hora de migrar.