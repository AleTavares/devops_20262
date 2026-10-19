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

# Aula 10 — Terraform Automatizado e CD Pipelines

**DevOps — Centro Universitário UniFAAT**
Prof. Alexandre Tavares | Semestre 2026-2

---

# O Problema da TechNova

Na Aula 09, a imagem já é publicada no **Amazon ECR**. Mas Rafael e Carlos ainda têm dor de cabeça:

> **Rafael:** "Toda mudança de infra eu rodo `terraform plan` no laptop, mando o output no Slack e rodo `apply` na mão. Um dia vou errar e derrubar produção."

> **Carlos:** "E o deploy também é manual: SSH no servidor, para o container, pull, sobe. Se o Rafael tira férias, ninguém deploya."

**Dois problemas a resolver hoje:**
1. Terraform manual — sem auditoria, sem review formal, risco de erro humano
2. Deploy manual — depende de uma pessoa específica fazer SSH no servidor

> **Solução:** **GitOps** (plan no PR, apply no merge) + um **pipeline CD** que deploya sozinho a cada merge.

---

# Objetivos de Aprendizagem

### Terraform GitOps
- Gerenciar infraestrutura via **Pull Requests** (Git = fonte da verdade)
- `terraform plan` automático postado como **comentário no PR**
- `terraform apply` automático no **merge** para `main`
- Autenticar o Actions na AWS com as **credenciais de sessão do Learner Lab**

### CD Pipelines
- Diferenciar **Continuous Delivery** de **Continuous Deployment**
- Construir o pipeline unificado **CI → Build → Push → Deploy**
- Aplicar a estratégia **Recreate** (stop → pull → start) via SSH
- Configurar **health check** pós-deploy e **rollback** manual

---

# O Problema: Terraform Manual

![Fluxo manual de Terraform na TechNova](img/rd001.png)

**Riscos:**
- Qualquer dev roda `apply` sem review
- State local pode divergir do remoto
- Sem auditoria (quem aplicou o quê e quando)
- Credenciais AWS no laptop do dev

> Review informal "no chat" **não é** revisão de infraestrutura.

---

# GitOps para Infraestrutura

**O repositório Git é a fonte da verdade.** Toda mudança vira um PR.

![Fluxo GitOps: PR dispara plan, review, merge aplica](img/rd002.png)

**Benefícios:**
- Nenhum humano executa Terraform diretamente
- Toda mudança tem review obrigatório
- Histórico completo no Git
- Rollback = `revert` do commit

---

# Autenticação GitHub → AWS

![Autenticação do GitHub Actions na AWS com credenciais de sessão do Learner Lab](img/rd003.png)

**Produção (ideal):** OIDC + role IAM — token temporário, **sem chave armazenada**.

**Learner Lab:** OIDC **não é permitido** (não cria OIDC provider nem role IAM).
→ Usamos as **3 credenciais temporárias de sessão** como GitHub Secrets.

```yaml
# No Learner Lab:
- uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}   # Lab exige
    aws-region: us-east-1
```

> **☁️ As credenciais do Lab expiram por sessão** — atualize os secrets ao reabrir o Lab. Em produção, OIDC elimina esse trabalho e os secrets de credencial.

---

# Plan como Comentário no PR

O output do `terraform plan` é postado direto no PR, para review:

![Terraform plan postado como comentário no Pull Request](img/rd004.png)

O reviewer avalia **antes** do merge:
- "Faz sentido criar esse security group?"
- "O `instance_type` mudou — aumenta custo?"
- "Vai **destruir** um recurso? É intencional?"

---

# Fluxo GitOps: PR → Plan → Merge → Apply

![Fluxo completo: PR dispara plan, review aprova, merge aplica](img/rd005.png)

> `-auto-approve` é seguro aqui: o plan já foi revisado no PR e o merge **é** a aprovação.

---

# Continuous Delivery vs Deployment

| | **Delivery** | **Deployment** |
|---|---|---|
| Deploy em prod | **Aprovação manual** (botão) | **Automático** após checks |
| Lema | "Posso deployar quando quiser" | "Todo commit testado vai pra prod" |
| Ideal para | Compliance, releases planejados | SaaS, iteração rápida |

![Continuous Delivery vs Continuous Deployment](img/rd006.png)

> **Na TechNova:** começamos com **Continuous Deployment** — merge na main deploya sozinho. Simples e eficiente para uma startup.

---

# Pipeline Unificado: CI → Build → Push → Deploy

![Pipeline unificado: lint, test, build, push ECR e deploy](img/rd007.png)

| Job | Depende de | Função |
|-----|-----------|--------|
| `lint` | — | Qualidade do código |
| `test` | lint | Testes (só se lint passar) |
| `build-push` | lint, test | Login ECR + build + push |
| `deploy` | build-push | SSH + login ECR + Recreate |

---

# Estratégia de Deploy: Recreate

![Estratégia Recreate: para o container antigo, puxa e sobe o novo (com downtime)](img/rd008.png)

**Prós:** simples, sem conflito de portas, sem load balancer, estado limpo.
**Contras:** **downtime inevitável** (segundos a minutos), ruim para SLA rigoroso.

> **Quando usar:** apps internas, staging, MVPs e startups que aceitam segundos de downtime.

---

# Deploy via SSH — login no ECR antes do pull

```yaml
- uses: appleboy/ssh-action@v1
  with:
    host: ${{ secrets.EC2_HOST }}
    username: ubuntu
    key: ${{ secrets.EC2_SSH_KEY }}
    script: |
      REGISTRY=${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com
      aws ecr get-login-password --region us-east-1 \
        | docker login --username AWS --password-stdin "$REGISTRY"
      docker pull "$REGISTRY/technova-api:latest"
      docker stop technova-api || true
      docker rm technova-api || true
      docker run -d --name technova-api -p 3000:3000 \
        --restart unless-stopped "$REGISTRY/technova-api:latest"
```

> O `|| true` evita erro no primeiro deploy (container ainda não existe). O **login no ECR vem antes** do `docker pull`.

---

# Health Check Pós-Deploy

```yaml
- name: Health Check
  run: |
    for i in $(seq 1 30); do
      if curl -s http://${{ secrets.EC2_HOST }}:3000/health | grep -q "ok"; then
        echo "✅ Aplicação saudável!"; exit 0
      fi
      echo "Tentativa $i/30 - aguardando..."; sleep 5
    done
    echo "❌ Health check falhou"; exit 1
```

**Por que importa:**
- Garante que o deploy não só "rodou", mas está **funcional**
- Detecta variável de ambiente errada, porta errada
- Se falhar → pipeline reporta erro → time é notificado

---

# Rollback (manual nesta etapa)

Pré-requisito: **imagens versionadas no ECR** (tag SHA por commit).

```bash
ssh ubuntu@EC2_HOST
REGISTRY=<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$REGISTRY"
docker stop technova-api && docker rm technova-api
docker run -d --name technova-api -p 3000:3000 \
  --restart unless-stopped "$REGISTRY/technova-api:sha-COMMIT_BOM"
```

> **💡 Nas próximas aulas (Blue-Green, Canary) o rollback será automatizado.** Por agora, a tag SHA é o que torna o rollback possível e rastreável.

---

# Segurança do Pipeline de Deploy

| Preocupação | Solução |
|-------------|---------|
| Chave SSH exposta | GitHub Secret (criptografada) |
| Acesso irrestrito à EC2 | SG libera SSH só do IP do runner |
| Credenciais AWS | Credenciais de sessão do Lab como secrets (prod: OIDC + role) |
| Imagem comprometida | Deploy só de imagens que passaram no CI |
| Deploy não-autorizado | Só push na main (merge requer aprovação) |

> As credenciais do Lab são **temporárias** — menor janela de exposição que uma access key permanente.

---

# Resumo dos Conceitos

| Conceito | Descrição |
|----------|-----------|
| GitOps | Git como fonte da verdade — PR = change request |
| Plan on PR / Apply on Merge | Plan vira comentário; merge dispara apply |
| Credenciais de sessão do Lab | 3 secrets temporários (key id, secret, session token) |
| OIDC | Ideal em produção (sem chaves); **indisponível no Lab** |
| Continuous Delivery / Deployment | Humano aprova / deploy automático |
| Pipeline unificado | CI → Build → Push (ECR) → Deploy |
| Recreate | Para antigo, sobe novo (com downtime) |
| Login ECR no deploy | `aws ecr get-login-password` antes do `docker pull` |
| Health check | Verifica se a app responde após o deploy |
| Rollback | Voltar à tag SHA anterior (manual nesta etapa) |

---

# Referências e Próximos Passos

**Referências:**
- Terraform plan/apply — [developer.hashicorp.com/terraform/cli](https://developer.hashicorp.com/terraform/cli/commands/plan)
- configure-aws-credentials — [github.com/aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials)
- amazon-ecr-login — [github.com/aws-actions/amazon-ecr-login](https://github.com/aws-actions/amazon-ecr-login)
- appleboy/ssh-action — [github.com/appleboy/ssh-action](https://github.com/appleboy/ssh-action)
- Delivery vs Deployment — [atlassian.com/continuous-delivery](https://www.atlassian.com/continuous-delivery/principles/continuous-integration-vs-delivery-vs-deployment)

**Para a próxima aula:**
- Completar o TF: GitOps (plan/apply) + pipeline CD com deploy na EC2
- Guardar os workflows funcionando — pré-requisito das estratégias avançadas

**Próxima aula:**
**Aula 11 — Blue-Green Deploy:** duas versões simultâneas, **zero downtime** — a evolução do Recreate.
