# Aula 10 — Materiais Complementares

## Terraform GitOps

### Documentação Oficial

- [Terraform CLI - Plan Command](https://developer.hashicorp.com/terraform/cli/commands/plan) — Referência completa do `terraform plan`
- [Terraform CLI - Apply Command](https://developer.hashicorp.com/terraform/cli/commands/apply) — Referência do `terraform apply`
- [Terraform Backend - S3](https://developer.hashicorp.com/terraform/language/settings/backends/s3) — Configuração do backend remoto S3
- [Terraform Lifecycle - prevent_destroy](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle) — Proteção contra destroy acidental

### Autenticação na AWS (Learner Lab e produção)

- [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials) — Action oficial; no Learner Lab recebe as credenciais temporárias de sessão
- [AWS CLI - Credenciais temporárias e session token](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) — Como as credenciais de sessão (incl. `AWS_SESSION_TOKEN`) funcionam
- [GitHub Actions OIDC - AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services) — **Referência de produção** (OIDC + role IAM; **não disponível no Learner Lab**)
- [AWS Security Blog - OIDC with GitHub](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/) — Blog AWS sobre OIDC (padrão ideal em produção)

### GitHub Actions para Terraform

- [hashicorp/setup-terraform](https://github.com/hashicorp/setup-terraform) — Action oficial para instalar Terraform
- [actions/github-script](https://github.com/actions/github-script) — Executar JavaScript com acesso à API GitHub (para postar comentários)
- [dflook/terraform-plan](https://github.com/dflook/terraform-github-actions) — Actions community para Terraform com PR comments

### GitOps

- [GitOps Principles](https://opengitops.dev/) — Princípios oficiais do OpenGitOps
- [Weaveworks - Guide to GitOps](https://www.weave.works/technologies/gitops/) — Guia conceitual de GitOps
- [Atlantis - Terraform Pull Request Automation](https://www.runatlantis.io/) — Ferramenta dedicada para Terraform GitOps

---

## CD Pipelines e Deploy

### Documentação Oficial

- [Amazon ECR User Guide](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html) — Registry da AWS usado no deploy
- [Autenticação no ECR (`get-login-password`)](https://docs.aws.amazon.com/AmazonECR/latest/userguide/registry_auth.html) — Login do Docker com token temporário (necessário antes do pull)
- [GitHub Actions - Deployment Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) — Environments com protection rules
- [Docker - docker run reference](https://docs.docker.com/engine/reference/run/) — Referência completa do docker run

### Actions para Deploy

- [appleboy/ssh-action](https://github.com/appleboy/ssh-action) — Executar comandos remotos via SSH
- [aws-actions/amazon-ecr-login](https://github.com/aws-actions/amazon-ecr-login) — Login no Amazon ECR no CI
- [docker/build-push-action](https://github.com/docker/build-push-action) — Build + push de imagens

### Estratégias de Deploy

- [Kubernetes Deployment Strategies](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy) — Recreate e RollingUpdate no K8s
- [Martin Fowler - Blue Green Deployment](https://martinfowler.com/bliki/BlueGreenDeployment.html) — Artigo clássico
- [AWS - Deployment Strategies](https://docs.aws.amazon.com/whitepapers/latest/practicing-continuous-integration-continuous-delivery/deployment-methods.html) — Whitepaper AWS

---

## Vídeos Recomendados

### Terraform GitOps
- [Terraform GitHub Actions Tutorial](https://www.youtube.com/results?search_query=terraform+github+actions+plan+apply+tutorial) — Tutoriais práticos
- [GitHub Actions AWS Credentials](https://www.youtube.com/results?search_query=github+actions+aws+credentials+tutorial) — Autenticação do Actions na AWS
- [Atlantis Terraform PR Automation](https://www.youtube.com/results?search_query=atlantis+terraform+pull+request+automation) — Alternativa ao workflow manual

### CD Pipelines
- [GitHub Actions Deploy to EC2](https://www.youtube.com/results?search_query=github+actions+deploy+ec2+ssh) — Deploy SSH em EC2
- [CI/CD Pipeline Complete Tutorial](https://www.youtube.com/results?search_query=cicd+pipeline+complete+github+actions+docker) — Pipeline completo
- [Deployment Strategies Explained](https://www.youtube.com/results?search_query=deployment+strategies+blue+green+canary+recreate) — Comparativo de estratégias

---

## Ferramentas Úteis

| Ferramenta | Propósito | Custo |
|-----------|----------|:-----:|
| **Amazon ECR** | Container registry da AWS (destino do build/push) | ~$0.10/GB/mês (créditos do Lab) |
| **Atlantis** | Terraform PR automation (alternativa completa) | Open Source |
| **Infracost** | Estimativa de custos no plan do Terraform | Gratuito (open source) |
| **tfsec** | Security scanner para Terraform | Open Source |
| **checkov** | Policy-as-code para IaC | Open Source |
| **appleboy/ssh-action** | Deploy via SSH em GitHub Actions | Gratuito |
| **GitHub Environments** | Protection rules para deploy (approvals) | Gratuito |
| **Terraform Cloud** | Plataforma gerenciada para Terraform (alternativa ao self-hosted) | Gratuito (até 5 users) |
| **AWS Systems Manager** | Alternativa ao SSH direto (Session Manager) | Gratuito |

---

## Conexão com Outros Módulos

### Módulo 3 (CI/CD) — Aulas Anteriores
- **Aula 08 (GitHub Actions CI):** Pipeline CI que agora é estendido com deploy automático
- **Aula 09 (Docker Registry):** Imagens publicadas no **Amazon ECR** são usadas no deploy

### Módulo 4 (Deploy) — Aulas Seguintes
- **Aula 11 (Blue-Green):** Evolução do Recreate — zero downtime com duas versões
- **Aula 12 (Canary):** Deploy gradual para percentual de usuários

### Módulo 2 (Infraestrutura)
- **Aula 07 (IA para IaC):** Terraform gerado por IA agora é aplicado automaticamente via GitOps
- **Aula 06 (EC2/RDS):** Infraestrutura provisionada é destino do deploy

---

## Leitura Adicional

### Artigos Técnicos
- [The Twelve-Factor App: Build, Release, Run](https://12factor.net/build-release-run) — Separação entre build e deploy
- [Continuous Delivery vs Continuous Deployment](https://www.atlassian.com/continuous-delivery/principles/continuous-integration-vs-delivery-vs-deployment) — Atlassian sobre as diferenças
- [HashiCorp - Running Terraform in Automation](https://developer.hashicorp.com/terraform/tutorials/automation/automate-terraform) — Guia oficial para automação

### Sobre Segurança em Pipelines
- [OWASP - CI/CD Security](https://owasp.org/www-project-top-10-ci-cd-security-risks/) — Top 10 riscos em pipelines
- [Supply Chain Security](https://slsa.dev/) — Framework SLSA para segurança da cadeia de build
- [GitHub - Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions) — Boas práticas de segurança em Actions

---

## Glossário Rápido

| Termo | Definição |
|-------|-----------|
| **GitOps** | Princípio: Git como fonte da verdade para infra e deploy |
| **Learner Lab** | Ambiente AWS Academy com credenciais temporárias (`us-east-1`, sem IAM) |
| **Credenciais de sessão** | Trio temporário (key id, secret, session token) usado como secrets no Lab |
| **OIDC** | OpenID Connect — autenticação federada sem credenciais permanentes (ideal em produção; indisponível no Lab) |
| **Plan on PR** | terraform plan executado automaticamente ao abrir PR |
| **Apply on Merge** | terraform apply executado automaticamente ao mergear |
| **-auto-approve** | Flag que pula confirmação interativa do terraform apply |
| **Continuous Delivery** | Pipeline prepara deploy; humano aprova quando deployar |
| **Continuous Deployment** | Pipeline deploya automaticamente após checks |
| **Recreate** | Estratégia: para tudo, sobe novo (com downtime) |
| **Health Check** | Verificação pós-deploy se a aplicação está funcional |
| **Rollback** | Voltar para versão anterior quando deploy falha |
| **SSH Action** | Action que executa comandos remotos via SSH |
| **`aws ecr get-login-password`** | Gera o token temporário para `docker login` no ECR (antes do pull) |
| **Environment** | GitHub feature para regras de proteção em deploys |
| **Branch Protection** | Regras que impedem push direto na main |
