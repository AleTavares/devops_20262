# Trabalho de Fixação (TF) — Aula 10: Terraform Automatizado e CD Pipelines

## Desafio

Consolidar o aprendizado sobre **Terraform GitOps** e **CD Pipelines** implementando o fluxo completo: infraestrutura gerenciada via PRs (plan + apply automáticos) e deploy contínuo com health check. Publique via Pull Request no repositório da disciplina.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | 1 semana a partir da data da aula |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork** | `entregas/aula-10/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com link do repositório + evidências |
| **Arquivos do projeto** | No repositório `unifaat-devops-portfolio`, pasta `aula-10/` |

### Como Entregar via Pull Request

1. Faça um **fork** do repositório da disciplina (se ainda não fez)
2. Clone o seu fork localmente
3. Crie a pasta `entregas/aula-10/SEU-RA/`
4. Adicione **apenas** o arquivo `entrega.md` (modelo abaixo) — os arquivos do projeto ficam no `unifaat-devops-portfolio`
5. Faça commit e push para o seu fork
6. Abra um **Pull Request** para o repositório original

**Modelo do arquivo `entrega.md`:**

```markdown
# Entrega — Aula 10: Terraform Automatizado e CD Pipelines

**Aluno:** [Seu nome completo]
**RA:** [Seu RA]
**Data:** [Data da entrega]

## Repositório

- URL: https://github.com/SEU-USUARIO/unifaat-devops-portfolio

## Evidências

- [ ] Workflow `terraform-plan.yml` postando o plan como comentário no PR
- [ ] Workflow `terraform-apply.yml` aplicando no merge para main
- [ ] Autenticação na AWS via credenciais temporárias de sessão do Lab (secrets)
- [ ] Pipeline CD completo: lint → test → build → push (ECR) → deploy
- [ ] Deploy Recreate via SSH na EC2 (login ECR antes do pull)
- [ ] Health check pós-deploy funcionando
- [ ] `gitops-cd-analise.md` preenchido
- [ ] Screenshots (plan no PR, apply após merge, pipeline CD verde, health check)

## Evidência do Pipeline Rodando

[Cole aqui o link da execução ou screenshots]
```

---

## Exercício: GitOps + CD Pipeline Completo

### Contexto

O CTO da TechNova decretou: "A partir de hoje, nenhum humano executa Terraform diretamente e nenhum deploy é manual." Implemente ambos os fluxos automatizados usando o **AWS Academy Learner Lab**.

> **☁️ Learner Lab:** você vai usar as credenciais temporárias da sessão do Lab (com `aws_session_token`), sempre na região `us-east-1`, armazenadas como GitHub Secrets. O Lab **não permite criar OIDC provider nem roles IAM** — por isso a autenticação do GitHub Actions usa as 3 credenciais de sessão. O padrão ideal de produção (OIDC + role IAM, sem chaves) fica documentado como referência, mas **não é implementável no Lab**.

### Requisitos

#### 1. Terraform GitOps — Plan on PR + Apply on Merge (40%)

**Workflow `terraform-plan.yml`:**
- Trigger em `pull_request` para branch `main` (apenas quando `.tf`/`.tfvars` mudarem)
- Autentica na AWS com as credenciais temporárias de sessão do Lab (secrets)
- Executa `terraform init` + `terraform validate` + `terraform plan`
- Posta o output do plan como **comentário no PR** (formatado)
- Se o plan falhar, o workflow falha (PR não pode ser mergeado sem plan válido)

**Workflow `terraform-apply.yml`:**
- Trigger em `push` para branch `main` (apenas quando `.tf`/`.tfvars` mudarem)
- Autentica na AWS com as credenciais temporárias de sessão do Lab
- Executa `terraform init` + `terraform apply -auto-approve`
- Output do apply visível nos logs do workflow

**Autenticação no Learner Lab:**
- As 3 credenciais de sessão (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`) configuradas como GitHub Secrets
- `aws-actions/configure-aws-credentials@v4` recebendo as 3 credenciais
- Documente que, em produção fora do Lab, isto seria substituído por OIDC + role IAM (sem chaves)

#### 2. CD Pipeline — CI→Build→Push→Deploy (40%)

**Workflow `cd.yml`:**
- Trigger em `push` para branch `main`
- **Job lint:** ESLint verifica o código
- **Job test:** Jest roda testes
- **Job build-push:** (depende de lint e test)
  - Login no **Amazon ECR** via `aws-actions/amazon-ecr-login@v2` (credenciais de sessão do Lab)
  - Build da imagem Docker (multi-stage), context `aula-10/technova-api/`
  - Push com tags SHA + latest
- **Job deploy:** (depende de build-push)
  - SSH na EC2 usando `appleboy/ssh-action`
  - **Login no ECR** (`aws ecr get-login-password`) **antes** do `docker pull`
  - Estratégia Recreate: stop → rm → pull → run
  - Health check pós-deploy (verifica `/health`)
  - Pipeline falha se health check não passar

#### 3. Documentação e Evidências (20%)

Crie o arquivo `gitops-cd-analise.md` com:

- Explicação do fluxo GitOps (por que plan no PR e apply no merge)
- Autenticação no Learner Lab (credenciais de sessão como secrets) e por que OIDC seria o ideal em produção (e por que o Lab não permite)
- Descrição da estratégia Recreate (prós, contras, quando usar)
- Comparação: Continuous Delivery vs Continuous Deployment
- Procedimento de rollback documentado (incluindo login no ECR antes do pull)
- Limitações identificadas e o que melhoraria

**Screenshots obrigatórios:**
- Plan como comentário no PR
- Apply executado com sucesso após merge
- Pipeline CD completo passando (lint → test → build → deploy)
- Health check passando no log do workflow

---

## Estrutura de Entrega

```
entregas/aula-10/RA/   (apenas o entrega.md; o projeto fica no portfólio)

unifaat-devops-portfolio/aula-10/
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml    # Plan automático em PRs
│       ├── terraform-apply.yml   # Apply automático no merge
│       └── cd.yml                # Pipeline CD: lint→test→build→push→deploy
├── terraform/
│   ├── main.tf                   # Recursos principais
│   ├── variables.tf              # Variáveis
│   ├── outputs.tf                # Outputs
│   └── provider.tf               # Provider + backend
├── Dockerfile                    # Multi-stage para produção
├── gitops-cd-analise.md          # Documentação e análise
├── docs/
│   └── runbook-rollback.md       # Procedimento de rollback
├── screenshots/
│   ├── plan-pr-comment.png       # Plan como comentário no PR
│   ├── apply-success.png         # Apply após merge
│   ├── cd-pipeline-green.png     # Pipeline CD completo verde
│   └── health-check-pass.png     # Health check no log
└── README.md                     # Instruções de como reproduzir
```

> **📁 Na pasta de entrega do fork (`entregas/aula-10/RA/`) vai _somente_ o `entrega.md`.** Todo o código, workflows, Terraform, docs e os screenshots/evidências ficam no seu repositório de portfólio (`unifaat-devops-portfolio/aula-10/`). PRs que alterem arquivos fora da sua pasta de entrega são bloqueados automaticamente.

> **☁️ Nota (Learner Lab):** não há `oidc.tf` nem recursos de IAM OIDC/role como entregáveis — o Lab não permite criá-los. A autenticação do GitHub Actions usa as credenciais temporárias de sessão como secrets. Deixe isso explícito no `gitops-cd-analise.md`.

---

## Critérios de Avaliação

| Critério | Peso | Descrição |
|----------|:----:|-----------|
| Terraform Plan on PR | 15% | Workflow dispara em PR, posta plan como comentário |
| Terraform Apply on Merge | 15% | Workflow dispara no merge, apply funciona com credenciais de sessão |
| Autenticação no Lab | 10% | 3 credenciais de sessão como secrets; nota sobre OIDC em produção |
| Pipeline CD funcional | 15% | lint → test → build → push (ECR) → deploy funciona |
| Deploy Recreate | 10% | Login ECR → stop → rm → pull → run via SSH |
| Health check | 10% | Verificação pós-deploy com retry e falha se não responder |
| Documentação (`gitops-cd-analise.md`) | 10% | Análise crítica dos conceitos e decisões |
| Runbook de rollback | 5% | Procedimento claro e testado |
| Screenshots | 5% | 4 screenshots comprovando funcionamento |
| Organização | 5% | Estrutura limpa, commits claros, README com instruções |

---

## Critérios de Excelência (Bônus)

Para nota acima da média, implemente adicionalmente:

- [ ] Terraform plan que detecta destroy e exige aprovação extra
- [ ] Comentário no PR atualizado (não duplicado) em novos pushes
- [ ] Deploy com variável GITHUB_SHA para rastreabilidade
- [ ] Notificação de deploy (Slack, Discord ou comentário no commit)
- [ ] `terraform fmt -check` no workflow de plan
- [ ] Cost estimation no plan (usando Infracost)
- [ ] Workflow separado para destroy com aprovação manual
- [ ] GitHub Environment com protection rules (approval antes do deploy)

---

## Entrega

### 1 — Publicar no portfólio

Os arquivos do projeto ficam no seu `unifaat-devops-portfolio`, pasta `aula-10/`:

```bash
cd unifaat-devops-portfolio
git checkout -b feature/aula-10-gitops-cd
mkdir -p aula-10/.github/workflows
mkdir -p aula-10/terraform
mkdir -p aula-10/screenshots
# copie os arquivos do seu projeto para aula-10/ (workflows, terraform, Dockerfile...)
git add aula-10/
git commit -m "feat(aula-10): GitOps Terraform + pipeline CD"
git checkout main
git merge feature/aula-10-gitops-cd
git push origin main
git push origin feature/aula-10-gitops-cd
```

### 2 — Registrar entrega no fork da disciplina

```bash
cd /caminho/para/seu-fork-da-disciplina
git checkout -b entregas/aula-10/SEU-RA
mkdir -p entregas/aula-10/SEU-RA
# Crie o arquivo entrega.md (modelo na seção Informações de Entrega)
git add entregas/aula-10/SEU-RA/entrega.md
git commit -m "feat(aula-10): entrega TF - SEU NOME (RA: SEU-RA)"
git push -u origin entregas/aula-10/SEU-RA
```

Abra o Pull Request no GitHub com:
- **Título:** `[Aula 10] RA: SEU-RA - SEU NOME`
- **Base:** `main`
- **Compare:** `entregas/aula-10/SEU-RA`

---

## Dicas

- Comece pela autenticação — teste as credenciais de sessão com um workflow simples (`aws sts get-caller-identity`) antes de rodar Terraform
- Para o CD pipeline, adapte o workflow da Aula 09 (build+push no ECR) adicionando o job de deploy
- Use `continue-on-error: true` no step de plan para capturar o output mesmo em falha
- O `|| true` após `docker stop` evita erro se o container não existir (primeiro deploy)
- No deploy, lembre de fazer `aws ecr get-login-password | docker login ...` **antes** do `docker pull`
- Se o push/pull falhar com `token has expired`, suas credenciais do Lab expiraram — reabra o Learner Lab e atualize os secrets
- Confirme sempre a região `us-east-1` e o Account ID correto no URI (`<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com`)
- Se a EC2 não responder ao health check: verifique Security Group (porta 3000 liberada?)

---

## Conexão com Próximas Aulas

Os pipelines que você constrói aqui serão **evoluídos** nas próximas aulas:
- **Aula 11:** Blue-Green Deploy — duas versões simultâneas, zero downtime
- **Aula 12:** Canary Deploy — deploy gradual para percentual de usuários
- O fluxo GitOps de Terraform será base para toda gestão de infraestrutura futura

> **💡 Guarde tudo funcionando** — esses workflows são pré-requisito para as estratégias avançadas de deploy.
