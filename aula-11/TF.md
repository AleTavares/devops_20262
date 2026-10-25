# Trabalho de Fixação (TF) — Aula 11: Blue/Green e Canary Deployments

## Desafio

Consolidar o aprendizado sobre **zero downtime** implementando **uma das duas estratégias** de deploy — Blue/Green **OU** Canary — para a TechNova API, usando Application Load Balancer (ALB), infraestrutura como código (Terraform) e automação via GitHub Actions, com as imagens publicadas no **Amazon ECR** (Aula 09) e operando no **AWS Academy Learner Lab**. Publique via Pull Request no repositório da disciplina.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | 1 semana a partir da data da aula |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork** | `entregas/aula-11/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com link do repositório + evidências |
| **Arquivos do projeto** | No repositório `unifaat-devops-portfolio`, pasta `aula-11/` |

### Como Entregar via Pull Request

1. Faça um **fork** do repositório da disciplina (se ainda não fez)
2. Clone o seu fork localmente
3. Crie a pasta `entregas/aula-11/SEU-RA/`
4. Adicione **apenas** o arquivo `entrega.md` (modelo abaixo) — os arquivos do projeto ficam no `unifaat-devops-portfolio`
5. Faça commit e push para o seu fork
6. Abra um **Pull Request** para o repositório original

**Modelo do arquivo `entrega.md`:**

```markdown
# Entrega — Aula 11: Blue/Green e Canary Deployments

**Aluno:** [Seu nome completo]
**RA:** [Seu RA]
**Data:** [Data da entrega]

## Repositório

- URL: https://github.com/SEU-USUARIO/unifaat-devops-portfolio

## Estratégia escolhida

- [ ] Opção A — Blue/Green
- [ ] Opção B — Canary

## Evidências

- [ ] Terraform do ALB + 2 Target Groups aplicável (`terraform validate`/`plan`)
- [ ] Workflow (ou script) de deploy com validação e rollback
- [ ] Imagem puxada do **Amazon ECR** no deploy das instâncias
- [ ] `EXPLICACAO.md` preenchido
- [ ] Screenshots (ALB respondendo, traffic switch/rollout, rollback acionado)

## Evidência do Deploy Rodando

[Cole aqui o link da execução ou screenshots]
```

---

## Contexto

A TechNova precisa eliminar downtime nos deploys da API de Pedidos. O CTO Carlos Mendes definiu que:

> "Todo deploy deve ser invisível para o usuário. Zero downtime é mandatório. E queremos a capacidade de reverter em segundos se algo der errado."

Sua tarefa é implementar **uma das duas estratégias** de deploy com zero downtime usando o ALB da AWS, Terraform e automação via GitHub Actions, puxando a imagem da TechNova API do **Amazon ECR**.

> **☁️ Learner Lab:** o ALB, os Target Groups e as instâncias EC2 ficam no Lab, sempre em `us-east-1`, com credenciais temporárias de sessão (incluindo `aws_session_token`). O Lab **permite criar ALB/Target Groups/EC2/VPC/Security Groups**, mas **não permite criar OIDC provider nem roles IAM** — quando precisar de instance profile, use o `LabRole`/`LabInstanceProfile`. O deploy faz `aws ecr get-login-password | docker login` antes do `docker pull`.

---

## Exercício — Opção A: Blue/Green Deployment

Implemente Blue/Green Deployment completo para a TechNova API.

### Requisitos — Opção A

1. **Infraestrutura Terraform** com:
   - 1 Application Load Balancer (ALB)
   - 2 Target Groups (Blue e Green) com health check configurado
   - 1 Listener HTTP na porta 80 com forward para Blue (default)
   - Security Group do ALB (aceita 80/443 da internet)
   - Security Group da EC2 (aceita tráfego apenas do ALB na porta 3000)
   - Outputs: `alb_dns_name`, `listener_arn`, `blue_tg_arn`, `green_tg_arn`

2. **Workflow GitHub Actions** (`deploy-blue-green.yml`) que:
   - Faz build e push da imagem Docker para o **Amazon ECR**
   - Faz deploy da nova versão na instância Green (login ECR + `docker pull` via SSH)
   - Aguarda health check do Green ficar saudável
   - Executa traffic switch (ALB Listener → Green)
   - Valida que o ALB responde corretamente após switch
   - Executa rollback automático se validação falhar

3. **Documento de rollback** (`ROLLBACK.md`) com:
   - Comando AWS CLI para rollback manual
   - Critérios que indicam necessidade de rollback
   - Tempo máximo aceitável antes de decidir rollback
   - Checklist pós-rollback (verificar logs, notificar time, criar postmortem)

### Entregáveis — Opção A

```
unifaat-devops-portfolio/aula-11/
├── terraform/
│   ├── alb.tf                  # ALB + Listener
│   ├── target-groups.tf        # Blue e Green Target Groups
│   ├── security-groups.tf      # SGs para ALB e EC2
│   ├── variables.tf            # Variáveis
│   └── outputs.tf              # Outputs necessários
├── .github/workflows/
│   └── deploy-blue-green.yml   # Workflow de deploy
├── ROLLBACK.md                 # Documento de rollback
└── EXPLICACAO.md               # Explicação das decisões (ver abaixo)
```

---

## Exercício — Opção B: Canary Deployment

Implemente Canary Deployment com rollout gradual para a TechNova API.

### Requisitos — Opção B

1. **Infraestrutura Terraform** com:
   - 1 Application Load Balancer (ALB)
   - 2 Target Groups (Stable e Canary) com health check configurado
   - 1 Listener HTTP com weighted forward action (100/0 como default)
   - Stickiness habilitada (300 segundos)
   - Variables para `stable_weight` e `canary_weight`
   - Outputs: `alb_dns_name`, `listener_arn`, `stable_tg_arn`, `canary_tg_arn`

2. **Script de rollout** (`canary-rollout.sh`) que:
   - Aceita variáveis de ambiente para configuração (LISTENER_ARN, TG_ARNs, ALB_DNS)
   - Executa rollout gradual em 4 etapas (5%→25%→50%→100%)
   - Monitora health check entre cada etapa
   - Executa rollback automático se error rate > threshold
   - Mostra output claro do progresso

3. **Workflow GitHub Actions** (`deploy-canary.yml`) que:
   - Trigger: `workflow_dispatch` com input `error_threshold`
   - Faz build/push da imagem Docker para o **Amazon ECR**
   - Deploya na instância Canary (login ECR + `docker pull`)
   - Executa pelo menos 2 etapas do rollout com monitoramento
   - Tem step de rollback condicional em cada etapa

4. **Documento de decisão** (`DECISAO.md`) com:
   - Por que escolheu Canary ao invés de Blue/Green
   - Critérios de promoção (quando avançar para próxima etapa)
   - Critérios de rollback (quando abortar)
   - Trade-offs da stickiness habilitada

### Entregáveis — Opção B

```
unifaat-devops-portfolio/aula-11/
├── terraform/
│   ├── alb.tf                  # ALB
│   ├── target-groups.tf        # Stable e Canary Target Groups
│   ├── listener-weighted.tf    # Listener com weighted forward
│   ├── variables.tf            # Variáveis (incluindo pesos)
│   └── outputs.tf              # Outputs necessários
├── scripts/
│   └── canary-rollout.sh       # Script de rollout gradual
├── .github/workflows/
│   └── deploy-canary.yml       # Workflow canary
├── DECISAO.md                  # Documento de decisão
└── EXPLICACAO.md               # Explicação das decisões (ver abaixo)
```

---

## EXPLICACAO.md (Obrigatório para ambas as opções)

O arquivo `EXPLICACAO.md` deve conter:

1. **Qual opção escolheu** (A ou B) e por quê
2. **Diagrama de arquitetura** em texto/ASCII mostrando o fluxo do tráfego
3. **Como funciona o deploy** — descreva passo a passo o que acontece quando um push é feito (incluindo o pull da imagem do ECR)
4. **Como funciona o rollback** — descreva passo a passo o que acontece quando uma falha é detectada
5. **Quanto tempo leva** cada etapa (estimativa baseada no seu lab)
6. **O que faria diferente em produção real** — ao menos 2 melhorias que faria se não fosse um exercício acadêmico (ex.: OIDC + role IAM no lugar das credenciais temporárias do Lab)

Mínimo: 30 linhas. Máximo: sem limite.

> **📁 Na pasta de entrega do fork (`entregas/aula-11/RA/`) vai _somente_ o `entrega.md`.** Todo o Terraform, workflows, scripts e documentos (`EXPLICACAO.md`, `ROLLBACK.md`/`DECISAO.md`) e as evidências ficam no seu repositório de portfólio (`unifaat-devops-portfolio/aula-11/`). PRs que alterem arquivos fora da sua pasta de entrega são bloqueados automaticamente.

---

## Critérios de Avaliação

| Critério | Peso | Descrição |
|----------|:----:|-----------|
| Terraform funcional e bem estruturado | 30% | Resources, variables e outputs do ALB + 2 Target Groups |
| Workflow GitHub Actions completo | 30% | Build/push ECR + deploy + validação + rollback |
| Mecanismo de rollback correto | 20% | Automático (workflow/script) ou documentado (ROLLBACK.md) |
| `EXPLICACAO.md` com compreensão demonstrada | 20% | Explicação clara dos conceitos e do fluxo |

---

## Critérios de Excelência (Bônus +10%)

Para nota acima da média, implemente adicionalmente:

- [ ] Script/workflow testado com evidência (screenshot do GitHub Actions ou output do terminal)
- [ ] Health check customizado além do `/health` básico (ex: verificar conexão com banco)
- [ ] Integração com notificação (Slack, Discord, email) em caso de rollback
- [ ] Implementar **ambas** as estratégias (A e B)
- [ ] Lifecycle policy no ECR para limpar imagens antigas usadas no deploy

---

## Entrega

### 1 — Publicar no portfólio

Os arquivos do projeto ficam no seu `unifaat-devops-portfolio`, pasta `aula-11/`:

```bash
cd unifaat-devops-portfolio
git checkout -b feature/aula-11-deploy-strategies
mkdir -p aula-11/terraform
mkdir -p aula-11/.github/workflows
# copie os arquivos do seu projeto para aula-11/ (terraform, workflows, scripts...)
git add aula-11/
git commit -m "feat(aula-11): Blue/Green ou Canary com ALB e ECR"
git checkout main
git merge feature/aula-11-deploy-strategies
git push origin main
git push origin feature/aula-11-deploy-strategies
```

### 2 — Registrar entrega no fork da disciplina

```bash
cd /caminho/para/seu-fork-da-disciplina
git checkout -b entregas/aula-11/SEU-RA
mkdir -p entregas/aula-11/SEU-RA
# Crie o arquivo entrega.md (modelo na seção Informações de Entrega)
git add entregas/aula-11/SEU-RA/entrega.md
git commit -m "feat(aula-11): entrega TF - SEU NOME (RA: SEU-RA)"
git push -u origin entregas/aula-11/SEU-RA
```

Abra o Pull Request no GitHub com:
- **Título:** `[Aula 11] RA: SEU-RA - SEU NOME`
- **Base:** `main`
- **Compare:** `entregas/aula-11/SEU-RA`

---

## Dicas

- Comece pelo Terraform — sem infraestrutura, não há o que automatizar
- Teste os comandos AWS CLI manualmente antes de colocar no workflow
- Use `terraform output -raw` para pegar ARNs sem aspas extras
- No workflow, use `set -e` nos scripts bash para falhar rápido
- Para simular erro no health check, pare o container na instância canary/green
- O ALB leva ~10-30 segundos para considerar um target healthy após start
- No deploy, faça `aws ecr get-login-password --region us-east-1 | docker login ...` **antes** do `docker pull`
- Se o `aws elbv2`/push falhar com `token has expired`, suas credenciais do Lab expiraram — reabra o Learner Lab e recarregue as credenciais da sessão
- Ao terminar, rode `terraform destroy` para liberar os recursos do Lab

---

## Conexão com Próximas Aulas

As estratégias que você implementa aqui serão a base da **Aula 12 (Observabilidade e Rollback Automatizado)**:

- O monitoramento do canary (error rate, latência) evolui para **métricas e alarmes** com CloudWatch
- O rollback manual/por-script evolui para **rollback automatizado disparado por alarme**
- O ALB e os Target Groups continuam sendo o ponto central do controle de tráfego

> **💡 Guarde sua infraestrutura funcionando** — ela será reaproveitada na próxima aula.
