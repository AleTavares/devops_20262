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

# Onde estamos na jornada

- Aulas 03–06: Terraform provisionando infra ✅
- Aula 08–09: CI/CD com GitHub Actions + imagem no ECR ✅
- **Aula 10: unir tudo — infra e deploy virando código revisável**

**Dois problemas que ainda existem na TechNova:**

> "Toda mudança de infra eu rodo `terraform plan` no laptop e mando o output no Slack. Um dia vou errar e derrubar produção." — **Rafael**

> "O deploy ainda é manual: SSH, para o container, sobe. Se eu tirar férias, ninguém deploya." — **Carlos**

> **Hoje resolvemos os dois com o mesmo princípio: Git como fonte da verdade.**

---

# O Problema: Terraform Manual

![Problema atual — Terraform manual na TechNova](img/rd001.png)

Sem automação, qualquer desenvolvedor:
- Aplica infra **sem review formal** (Slack não é aprovação)
- Usa credenciais locais — se o laptop sumir, some o acesso
- Não deixa **rastro auditável** de quem mudou o quê e quando
- Pode divergir o estado real da infra do que está no repositório

> **A pergunta certa:** "O repositório Git reflete o que está na AWS agora?"
> Com Terraform manual, a resposta honesta é: "Talvez."

---

# GitOps — Git como Fonte da Verdade

**GitOps** é o princípio de que toda mudança de infraestrutura passa pelo Git — e o Git é sempre a verdade sobre o que deve existir.

![GitOps para infraestrutura](img/rd002.png)

**A mudança de mentalidade:**

| Antes (Terraform Manual) | Depois (GitOps) |
|---|---|
| Dev executa `apply` localmente | Só o pipeline executa `apply` |
| Review informal no Slack | PR com output do plan para revisar |
| Sem histórico de quem aplicou | Git log = auditoria completa |
| Credenciais no laptop | Credenciais no GitHub Secrets |

> "Toda mudança de infra passa pelo mesmo fluxo de uma mudança de código."

---

# GitOps na Prática: Plan on PR

Ao abrir um PR com mudanças nos arquivos `.tf`, o pipeline roda `terraform plan` e posta o output **direto no PR como comentário**:

![Terraform plan postado como comentário no PR](img/rd004.png)

O reviewer agora pode responder perguntas concretas:
- Esta mudança vai criar, alterar ou **destruir** o quê?
- O custo vai aumentar?
- Faz sentido para o que foi pedido?

> **O plan no PR é o diff de infraestrutura — tão importante quanto o diff de código.**

---

# GitOps na Prática: Apply on Merge

Depois que o PR é aprovado e mergeado, o pipeline roda `terraform apply` automaticamente.

![Fluxo completo GitOps: PR → plan → review → merge → apply](img/rd005.png)

**Por que isso funciona:**
- O merge na main **é** a aprovação — não precisa de outro passo
- O apply usa as credenciais do pipeline, não do laptop de ninguém
- Se der errado, o `revert` do commit é o rollback de infraestrutura

> **O Git vira o "botão de aprovação" da infra.**

---

# Autenticação: GitHub Actions → AWS

**Como o pipeline se autentica na AWS para rodar o Terraform?**

![Autenticação do Actions na AWS](img/rd003.png)

**Produção (ideal): OIDC + role IAM**
- Nenhuma chave armazenada em lugar nenhum
- Token gerado na hora, válido por minutos
- Segurança máxima, zero manutenção

**Learner Lab: credenciais de sessão**
- OIDC **não está disponível** no Learner Lab (requer criar OIDC provider e roles IAM — ambos bloqueados)
- Usamos as 3 credenciais temporárias da sessão como GitHub Secrets
- Funcionam, mas **expiram** quando a sessão do Lab fecha

> A diferença entre produção e Lab não é de conceito — é de permissão disponível.

---

# Continuous Delivery vs Continuous Deployment

São dois pontos diferentes na escala de automação:

![Continuous Delivery vs Continuous Deployment](img/rd006.png)

| | **Continuous Delivery** | **Continuous Deployment** |
|---|---|---|
| **O que é** | Sempre pronto para deployar | Deploya automaticamente |
| **Aprovação** | Botão manual antes do deploy | Nenhuma — todo merge vai |
| **Ideal para** | Compliance, releases planejados | SaaS, startups, iteração rápida |
| **Lema** | "Posso deployar quando quiser" | "Todo commit testado vai pra prod" |

> **Na TechNova:** começamos com **Continuous Deployment** — simples, eficiente, sem cerimônia desnecessária para uma startup.

---

# Pipeline Unificado: CI → Build → Push → Deploy

Tudo em um único fluxo acionado pelo push na `main`:

![Pipeline unificado da TechNova](img/rd007.png)

**Cada job tem uma responsabilidade clara:**
- **lint / test** — o código está correto?
- **build-push** — gera e publica a imagem no ECR
- **deploy** — coloca a nova versão no ar na EC2

> Se qualquer etapa falhar, o deploy não acontece. A EC2 fica na versão anterior.

---

# Estratégias de Deploy

Existem diferentes formas de trocar uma versão por outra. A escolha impacta **downtime**, **complexidade** e **custo**.

![Estratégia Recreate](img/rd008.png)

**Recreate (hoje):**
Para o container antigo → sobe o novo → downtime de segundos.
Simples, sem infraestrutura extra. Aceitável para startups.

**Blue-Green (próxima aula):**
Mantém duas versões simultâneas → troca o tráfego instantaneamente → zero downtime.

**Canary (aula seguinte):**
Envia 10% do tráfego para a nova versão → valida → escala gradualmente → zero risco.

> **Cada estratégia é uma troca entre complexidade, custo e disponibilidade.**

---

# Por que Health Check pós-deploy?

O pipeline não termina no `docker run`. Ele verifica se a aplicação **realmente funciona**:

**O que pode acontecer sem health check:**
- Container sobe, mas a app trava por variável de ambiente errada
- Porta configurada diferente do esperado
- Bug só aparece em produção (config de prod diferente)

**Com health check:**
- O pipeline fica tentando por até 2 minutos
- Se a app não responder, o job falha e o time é notificado
- A EC2 fica com a versão anterior rodando (o container novo falhou)

> **"Deployou" e "está funcionando" são coisas diferentes.**

---

# Rollback: por que imagens versionadas importam

No pipeline, cada commit gera uma imagem com **tag única** (o SHA do commit).

**Sem tags versionadas:**
- Só existe `latest`
- Rollback = redeployar `latest` = mesma versão com problema
- Impossível voltar para "a versão de quinta-feira"

**Com tags versionadas (SHA):**
- Cada imagem = um momento específico no tempo
- Rollback = trocar para uma tag anterior conhecida
- Rastreabilidade completa: commit no Git ↔ imagem no ECR ↔ deploy na EC2

> **As estratégias avançadas (Blue-Green, Canary) dependem de imagens versionadas. A tag SHA é a fundação.**

---

# Segurança do Pipeline

| Preocupação | Solução | Por quê funciona |
|-------------|---------|-----------------|
| Chave SSH exposta | GitHub Secret | Criptografada, mascarada nos logs |
| Credenciais AWS permanentes | Credenciais de sessão do Lab (temporárias) | Expiram — janela de exposição mínima |
| Qualquer branch deploya | Só push na `main` dispara o deploy | Branch protection + fluxo de PR |
| Imagem não testada | Build só acontece se lint e test passam | Dependência entre jobs (`needs`) |
| Deploy sem review | PR obrigatório com plan como comentário | GitOps — merge = aprovação |

---

# Resumo: o que mudou hoje na TechNova

**Antes desta aula:**
- Terraform: laptop do Rafael, sem review, sem auditoria
- Deploy: SSH manual, depende de uma pessoa

**Depois desta aula:**
- Toda mudança de infra → PR → plan como comentário → review → merge → apply
- Todo push na main → lint → test → build → push ECR → deploy EC2 → health check
- Git = auditoria completa de infra e deploy
- Rollback = tag SHA no ECR

> **O próximo passo (Aula 11):** eliminar o downtime do Recreate com Blue-Green Deploy.

---

# Referências e Próximos Passos

**Para aprofundar:**
- GitOps — [opengitops.dev](https://opengitops.dev/)
- Terraform plan in CI — [developer.hashicorp.com/terraform/tutorials/automation](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions)
- Delivery vs Deployment — [atlassian.com](https://www.atlassian.com/continuous-delivery/principles/continuous-integration-vs-delivery-vs-deployment)

**Para a próxima aula:**
- Completar o TF: GitOps (plan/apply) + pipeline CD com deploy na EC2
- Guardar os workflows funcionando — base para Blue-Green e Canary

**Próxima aula:**
**Aula 11 — Blue-Green Deploy**
Duas versões simultâneas, troca instantânea, **zero downtime**.
