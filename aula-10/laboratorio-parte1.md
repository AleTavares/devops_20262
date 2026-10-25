# Aula 10 — Laboratório Parte 1: Terraform Plan on PR + Apply on Merge (GitOps)

## Missão

Implementar o fluxo GitOps completo para Terraform: ao abrir um PR com mudanças de infraestrutura, o pipeline roda `terraform plan` e posta o resultado como comentário. Ao fazer merge na main, o pipeline roda `terraform apply` automaticamente.

**Resultado final:**
- GitHub Actions autenticado na AWS com as credenciais temporárias de sessão do Learner Lab (como secrets)
- Workflow que roda `terraform plan` em PRs e posta como comentário
- Workflow que roda `terraform apply` no merge para main
- Fluxo testado end-to-end com uma mudança real de infraestrutura

---

## Pré-requisitos

- [ ] Repositório `technova-infra` (ou similar) no GitHub com arquivos Terraform
- [ ] Terraform state remoto configurado (S3 + DynamoDB da Aula 08)
- [ ] Acesso ao **AWS Academy Learner Lab** com a sessão iniciada (credenciais temporárias, `us-east-1`)
- [ ] Infraestrutura TechNova provisionada (EC2, VPC, Security Groups)
- [ ] AWS CLI configurada localmente com as credenciais do Lab (`aws sts get-caller-identity` funciona)

---

## Onde ficam os arquivos Terraform?

Este laboratório **não cria a infraestrutura do zero** — ele adiciona a camada de automação (GitOps: plan no PR, apply no merge) **por cima do Terraform que você já escreveu nas Aulas 03 a 06** (provider, backend S3 remoto, VPC, Security Groups, EC2, RDS e módulos). Os workflows deste lab apenas rodam `terraform init/plan/apply` sobre esses arquivos.

Por isso, o repositório de infraestrutura (`technova-infra` ou similar) deve ter os `.tf` numa pasta **`terraform/`** na raiz — é exatamente para onde a variável `TF_WORKING_DIR: ./terraform` dos workflows aponta. A estrutura esperada é:

```
technova-infra/
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml      # criado no Passo 2 (plan no PR)
│       └── terraform-apply.yml     # criado no Passo 3 (apply no merge)
└── terraform/                      # ← os arquivos .tf ficam AQUI (= TF_WORKING_DIR)
    ├── main.tf                     # composição dos módulos (Aula 06)
    ├── variables.tf
    ├── outputs.tf
    ├── providers.tf                # provider AWS + backend "s3" (Aula 05)
    └── modules/                    # vpc, security-group, ec2, rds (Aulas 03-06)
```

> **💡 Reaproveite o que já existe.** O `aws_security_group.technova_api` usado como exemplo no Passo 4 (regra de HTTPS) vem do módulo de Security Group das Aulas 03-04. Se o seu diretório Terraform usa outro nome ou outra pasta, ajuste `TF_WORKING_DIR` e a referência do recurso de acordo. Se ainda não tem a infra das aulas anteriores à mão, use os módulos da Aula 06 como ponto de partida antes de seguir este lab.

---

## Passo 1 — Autenticação no Learner Lab via Credenciais de Sessão como GitHub Secrets

> **☁️ Learner Lab vs produção:** o padrão **ideal em produção** autentica o GitHub Actions via **OIDC + role IAM** (sem armazenar chave nenhuma). Porém o Learner Lab **não permite criar OIDC Identity Provider nem roles IAM** — então, no laboratório, o fluxo real usa as **credenciais temporárias da sessão** do Lab armazenadas como GitHub Secrets. Elas incluem `aws_session_token` e **expiram por sessão**, então precisam ser atualizadas a cada vez que você reabre o Lab.

### 1.1 Obter as credenciais da sessão do Lab

No AWS Academy Learner Lab, clique em **"AWS Details"** → **"AWS CLI: Show"**. Você verá algo como:

```ini
[default]
aws_access_key_id=ASIA...
aws_secret_access_key=...
aws_session_token=...
```

As três linhas são as credenciais temporárias da sua sessão atual.

### 1.2 Cadastrar as 3 credenciais como GitHub Secrets

No repositório GitHub: Settings → Secrets and variables → Actions → New repository secret

| Secret Name | Valor |
|-------------|-------|
| `AWS_ACCESS_KEY_ID` | `aws_access_key_id` da sessão |
| `AWS_SECRET_ACCESS_KEY` | `aws_secret_access_key` da sessão |
| `AWS_SESSION_TOKEN` | `aws_session_token` da sessão |

> **⚠️ As credenciais do Lab expiram por sessão.** Quando o Lab encerrar e você reabrir, atualize os 3 secrets com os novos valores — caso contrário os workflows falharão com `token has expired` / `ExpiredToken`.

### 1.3 Validar a autenticação com um workflow simples

Antes de rodar Terraform, teste que a autenticação funciona. Crie `.github/workflows/aws-check.yml`:

```yaml
name: AWS Check
on: workflow_dispatch

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}   # Learner Lab exige
          aws-region: us-east-1
      - run: aws sts get-caller-identity
```

Dispare o workflow (aba Actions → Run workflow). Se o `get-caller-identity` retornar o Account ID, a autenticação está correta.

> **💡 Referência de produção (não executar no Lab):** em produção o `configure-aws-credentials` usaria `role-to-assume: arn:aws:iam::<ACCOUNT_ID>:role/github-actions-terraform` com OIDC, sem nenhum secret de credencial. O Lab não permite esse recurso.

> **✅ Checkpoint:** os 3 secrets de sessão criados e `aws sts get-caller-identity` funcionando no Actions.

---

## Passo 2 — Workflow: Terraform Plan on PR

### 2.1 Criar o workflow de plan

Crie `.github/workflows/terraform-plan.yml`:

```yaml
name: Terraform Plan

on:
  pull_request:
    branches: [main]
    paths:
      - '**.tf'
      - '**.tfvars'

permissions:
  contents: read        # Ler código
  pull-requests: write  # Postar comentário no PR

env:
  AWS_REGION: us-east-1
  TF_WORKING_DIR: ./terraform

jobs:
  terraform-plan:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ${{ env.TF_WORKING_DIR }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configurar credenciais AWS (Learner Lab)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}   # Learner Lab exige
          aws-region: ${{ env.AWS_REGION }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.7.0

      - name: Terraform Init
        id: init
        run: terraform init

      - name: Terraform Validate
        id: validate
        run: terraform validate -no-color

      - name: Terraform Plan
        id: plan
        run: terraform plan -no-color -out=tfplan
        continue-on-error: true

      - name: Postar Plan como comentário no PR
        uses: actions/github-script@v7
        if: github.event_name == 'pull_request'
        env:
          PLAN: ${{ steps.plan.outputs.stdout }}
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const output = `#### Terraform Plan 📖
            
            \`\`\`
            ${process.env.PLAN}
            \`\`\`
            
            *Triggered by @${{ github.actor }} on \`${{ github.event.pull_request.head.ref }}\`*`;

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            });

      - name: Falhar se plan falhou
        if: steps.plan.outcome == 'failure'
        run: exit 1
```

### 2.2 Entendendo cada componente

| Componente | Função |
|-----------|--------|
| `paths: ['**.tf', '**.tfvars']` | Workflow só dispara se arquivos Terraform mudarem |
| `pull-requests: write` | Permissão para postar comentário no PR |
| `aws-actions/configure-aws-credentials` | Autentica com as 3 credenciais de sessão do Lab |
| `hashicorp/setup-terraform` | Instala Terraform no runner |
| `terraform plan -no-color` | Plan sem cores ANSI (para formatação no comentário) |
| `actions/github-script` | Executa JavaScript com acesso à API GitHub |
| `continue-on-error: true` | Permite capturar o output mesmo se plan falhar |

> **✅ Checkpoint:** workflow de plan criado. Agora vamos criar o de apply.

---

## Passo 3 — Workflow: Terraform Apply on Merge

### 3.1 Criar o workflow de apply

Crie `.github/workflows/terraform-apply.yml`:

```yaml
name: Terraform Apply

on:
  push:
    branches: [main]
    paths:
      - '**.tf'
      - '**.tfvars'

permissions:
  contents: read

env:
  AWS_REGION: us-east-1
  TF_WORKING_DIR: ./terraform

jobs:
  terraform-apply:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ${{ env.TF_WORKING_DIR }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configurar credenciais AWS (Learner Lab)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}   # Learner Lab exige
          aws-region: ${{ env.AWS_REGION }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.7.0

      - name: Terraform Init
        run: terraform init

      - name: Terraform Apply
        run: terraform apply -auto-approve
```

### 3.2 Por que `-auto-approve`?

O `-auto-approve` pula a confirmação interativa ("Do you want to perform these actions?"). Isso é seguro aqui porque:
- O plan já foi revisado no PR
- O merge na main é a aprovação humana
- Não há como interagir com o CI (não tem terminal)

> **✅ Checkpoint:** workflows de plan e apply criados.

---

## Passo 4 — Testar o Fluxo GitOps End-to-End

### 4.1 Commitar os workflows na main

```bash
# Primeiro, commitar os workflows diretamente na main
git add .github/workflows/terraform-plan.yml .github/workflows/terraform-apply.yml
git commit -m "ci: add terraform GitOps workflows (plan on PR, apply on merge)"
git push origin main
```

### 4.2 Criar uma branch com mudança de infraestrutura

```bash
# Criar branch para mudança
git checkout -b feat/add-https-sg-rule

# Adicionar uma regra de security group (exemplo simples)
```

Edite um arquivo Terraform (ex: `terraform/security-groups.tf`):

```hcl
# Adicionar regra para HTTPS (porta 443)
resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.technova_api.id
  description       = "Allow HTTPS inbound"
}
```

### 4.3 Abrir Pull Request

```bash
git add terraform/security-groups.tf
git commit -m "feat: add HTTPS ingress rule to API security group"
git push origin feat/add-https-sg-rule
```

Abra um PR no GitHub: `feat/add-https-sg-rule` → `main`

### 4.4 Verificar o Plan como comentário

1. Vá para a aba **Actions** — o workflow "Terraform Plan" deve estar rodando
2. Aguarde finalizar
3. Volte ao PR — deve ter um **comentário** com o output do plan:

```
#### Terraform Plan 📖

Terraform will perform the following actions:

  # aws_security_group_rule.allow_https will be created
  + resource "aws_security_group_rule" "allow_https" {
      + cidr_blocks       = ["0.0.0.0/0"]
      + from_port         = 443
      + protocol          = "tcp"
      + to_port           = 443
      + type              = "ingress"
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

### 4.5 Fazer merge e verificar apply

1. Revise o plan no comentário — está correto?
2. Clique **Merge pull request**
3. Vá para **Actions** — o workflow "Terraform Apply" deve disparar
4. Verifique que o apply completou com sucesso
5. Confirme na AWS: a nova regra de security group existe

```bash
# Verificar na AWS CLI
aws ec2 describe-security-group-rules \
  --filters Name=group-id,Values=sg-XXXXXXXX \
  --query 'SecurityGroupRules[?FromPort==`443`]'
```

> **✅ Checkpoint:** Fluxo completo funcionando — plan no PR, apply no merge!

---

## Passo 5 — Proteções Adicionais

### 5.1 Configurar Branch Protection

No GitHub: Settings → Branches → Add rule para `main`:

- [x] Require a pull request before merging
- [x] Require approvals (1)
- [x] Require status checks to pass (selecionar "Terraform Plan")
- [x] Do not allow bypassing the above settings

### 5.2 Adicionar CODEOWNERS (opcional)

Crie `.github/CODEOWNERS`:

```
# Mudanças em Terraform requerem aprovação do time de DevOps
*.tf       @SEU-USUARIO
*.tfvars   @SEU-USUARIO
```

### 5.3 Proteger contra destroy acidental

Adicione lifecycle rules nos recursos críticos:

```hcl
resource "aws_db_instance" "technova" {
  # ... configurações ...

  lifecycle {
    prevent_destroy = true
  }
}
```

---

## Troubleshooting

| Problema | Causa Provável | Solução |
|----------|---------------|---------|
| `ExpiredToken` / `token has expired` | Credenciais do Lab expiraram | Reabrir o Learner Lab e atualizar os 3 secrets |
| `Error: No valid credential sources` | Secrets não configurados ou faltou `aws-session-token` | Conferir os 3 secrets no repositório |
| Plan não posta comentário | Falta `pull-requests: write` | Adicionar permissão |
| Apply falha com state lock | Outro apply rodando | Verificar DynamoDB lock, aguardar |
| `Error: Backend initialization` | Credenciais não autenticaram antes do init | Verificar ordem dos steps |
| Workflow não dispara | Paths filter não match | Verificar que `.tf` está no path correto |
| Comentário truncado | Plan muito grande | Truncar output no script |

---

## Checklist de Validação

Antes de seguir para o Laboratório Parte 2, confirme:

- [ ] 3 credenciais de sessão do Lab configuradas como GitHub Secrets
- [ ] `aws sts get-caller-identity` funcionando no Actions
- [ ] Workflow terraform-plan.yml dispara em PRs que modificam `.tf`
- [ ] Plan é postado como comentário no PR automaticamente
- [ ] Workflow terraform-apply.yml dispara no merge para main
- [ ] Apply executa com sucesso usando as credenciais de sessão
- [ ] Branch protection configurada (requer PR + status checks)
- [ ] Testado end-to-end com uma mudança real (security group rule)
- [ ] Documentado que, em produção, OIDC + role IAM substituiria as credenciais de sessão

> **🎯 Se todos os itens estão ✅, você completou a Parte 1!** Siga para o Laboratório Parte 2: Pipeline CD Completo.
