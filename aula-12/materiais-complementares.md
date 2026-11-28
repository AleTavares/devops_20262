# Materiais Complementares | Aula 12

## Documentação Oficial

### Rollback & Deploy Strategies
- [AWS CodeDeploy — Rollbacks](https://docs.aws.amazon.com/codedeploy/latest/userguide/deployments-rollback-and-redeploy.html) — Documentação oficial sobre rollback automático no CodeDeploy
- [GitHub Actions — Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions) — Referência completa para workflows CD
- [Docker — Container Lifecycle](https://docs.docker.com/engine/reference/commandline/container/) — Comandos para gerenciar containers (stop, rm, run)
- [Amazon ECR — Pulling an image](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-pull-ecr-image.html) — Pull de imagens versionadas no rollback (login via `aws ecr get-login-password`)

### Feature Flags
- [Martin Fowler — Feature Toggles](https://martinfowler.com/articles/feature-toggles.html) — Artigo seminal sobre tipos e padrões de feature flags
- [AWS AppConfig](https://docs.aws.amazon.com/appconfig/latest/userguide/what-is-appconfig.html) — Feature flags dinâmicas com AWS (sem restart)
- [LaunchDarkly Docs](https://docs.launchdarkly.com/) — Referência do principal serviço de feature flags

### Database Migrations
- [Prisma — Expand and Contract Pattern](https://www.prisma.io/dataguide/types/relational/expand-and-contract-pattern) — Guia detalhado do padrão expand-contract
- [Flyway — Database Migrations](https://documentation.red-gate.com/fd) — Ferramenta popular de migrações (Java/JVM)

### AIOps & Monitoramento (no Learner Lab)
- [AWS CloudWatch Anomaly Detection](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Anomaly_Detection.html) — ML para detecção de anomalias em métricas (coberto pelos créditos do Lab)
- [AWS CloudWatch — Custom Metrics (PutMetricData)](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/publishingMetrics.html) — Emitir métricas de negócio da aplicação
- [Amazon Bedrock — User Guide](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html) — Guia completo do Bedrock (LLMs via API; requer Request Access)
- [AWS Lambda — Developer Guide](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html) — Funções serverless; no Lab, use a role pré-existente `LabRole`
- [Amazon EventBridge — Rules](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html) — Conectar eventos (alarme CloudWatch) a targets (Lambda)
- [Amazon DevOps Guru](https://docs.aws.amazon.com/devops-guru/latest/userguide/welcome.html) — AIOps managed service da AWS

---

## Vídeos Recomendados

### Rollback & Resilience
- [Deployment Strategies Explained (TechWorld with Nana)](https://www.youtube.com/watch?v=AWVTKBUnoIg) — Blue-Green, Canary, Rolling explicados visualmente (~15 min)
- [How to Write Great Runbooks (PagerDuty)](https://www.youtube.com/watch?v=jMYVR7G8Nlk) — Boas práticas para runbooks operacionais (~20 min)
- [Feature Flags Best Practices (DevOps Toolkit)](https://www.youtube.com/watch?v=DE3i3rGpOFE) — Como usar feature flags corretamente (~25 min)

### AIOps
- [What is AIOps? (IBM Technology)](https://www.youtube.com/watch?v=J-7m3KCcC4c) — Introdução conceitual a AIOps (~8 min)
- [CloudWatch Anomaly Detection Demo (AWS)](https://www.youtube.com/watch?v=DnWpIq7hPVQ) — Demonstração prática do anomaly detection (~12 min)
- [Amazon Bedrock — Getting Started (AWS)](https://www.youtube.com/watch?v=ab1mbj0acDo) — Como usar LLMs via Bedrock (~15 min)

### DORA Metrics & MTTR
- [DORA Metrics Explained (Google Cloud)](https://www.youtube.com/watch?v=0pPR03urW-Q) — As 4 métricas DORA incluindo MTTR (~10 min)

---

## Artigos e Tutoriais

### Rollback
- [Zero-Downtime Deployments with Blue-Green (DigitalOcean)](https://www.digitalocean.com/community/tutorials/how-to-use-blue-green-deployments-to-release-software-safely) — Tutorial prático de Blue-Green
- [Database Migrations Done Right (Thoughtbot)](https://thoughtbot.com/blog/database-migrations-with-zero-downtime) — Migrações sem downtime
- [Automated Rollback with GitHub Actions (Dev.to)](https://dev.to/github/automated-rollback-with-github-actions-3j5l) — Rollback no pipeline CI/CD

### AIOps
- [AIOps — Gartner Definition](https://www.gartner.com/en/information-technology/glossary/aiops-artificial-intelligence-operations) — Definição formal de AIOps pelo Gartner
- [Building an AI-Powered Alert System (AWS Blog)](https://aws.amazon.com/blogs/machine-learning/building-an-ai-powered-alerting-system/) — Padrão Lambda + Bedrock para alertas
- [Anomaly Detection Best Practices (Datadog)](https://www.datadoghq.com/blog/anomaly-detection-best-practices/) — Como configurar anomaly detection eficazmente

### Feature Flags
- [Feature Flags in Node.js (FreeCodeCamp)](https://www.freecodecamp.org/news/feature-flags-in-node-js/) — Implementação prática em Node.js
- [Kill Switches: Feature Flags for Production Safety (LaunchDarkly Blog)](https://launchdarkly.com/blog/kill-switches/) — Ops flags como safety net

---

## Ferramentas

### Feature Flags
- [Unleash](https://github.com/Unleash/unleash) — Open-source feature flag server (self-hosted, gratuito)
- [Flagsmith](https://github.com/Flagsmith/flagsmith) — Open-source feature flags com API REST
- [AWS AppConfig](https://aws.amazon.com/systems-manager/features/appconfig/) — Feature flags integradas ao ecossistema AWS

### Database Migrations
- [node-pg-migrate](https://github.com/salsita/node-pg-migrate) — Migrações PostgreSQL para Node.js (up/down)
- [Knex.js](https://knexjs.org/guide/migrations.html) — Query builder com sistema de migrações
- [Prisma Migrate](https://www.prisma.io/docs/orm/prisma-migrate) — Migrações ORM modernas para Node.js

### Monitoramento & AIOps
- [CloudWatch Custom Metrics SDK](https://www.npmjs.com/package/@aws-sdk/client-cloudwatch) — SDK para emitir métricas customizadas
- [Bedrock Runtime SDK](https://www.npmjs.com/package/@aws-sdk/client-bedrock-runtime) — SDK para invocar modelos do Bedrock na Lambda
- [Grafana](https://grafana.com/) — Dashboards de observabilidade (complementa CloudWatch)
- [PagerDuty](https://www.pagerduty.com/) — Gestão de incidentes e on-call (AIOps features)
- [AWS CDK](https://docs.aws.amazon.com/cdk/v2/guide/home.html) — Infraestrutura como código para Lambda, EventBridge, etc.

### Runbooks & Incident Management
- [Notion Templates — Runbooks](https://www.notion.so/templates/runbook) — Templates de runbooks para equipes
- [OpsGenie](https://www.atlassian.com/software/opsgenie) — Gestão de incidentes com runbook automation
- [Blameless](https://www.blameless.com/) — Plataforma de SRE com runbooks executáveis

---

## Livros Recomendados

| Livro | Relevância para esta aula |
|-------|---------------------------|
| *Site Reliability Engineering* (Google) | Capítulos sobre incident response e postmortems |
| *Accelerate* (Forsgren, Humble, Kim) | DORA metrics, MTTR, deploy frequency |
| *Release It!* (Michael Nygard) | Circuit breakers, feature flags, deploy patterns |
| *Database Reliability Engineering* (Campbell, Majors) | Migrações seguras, schema versioning |

---

## Conceitos-Chave para Revisão

| Conceito | Onde aprofundar |
|----------|-----------------|
| MTTR | Livro *Accelerate*, relatório DORA |
| Expand-Contract | Artigo Prisma DataGuide |
| Feature Toggles | Artigo Martin Fowler |
| AIOps | Gartner Research, AWS DevOps Guru docs |
| Anomaly Detection | AWS CloudWatch docs, Datadog blog |
| Bedrock API | AWS Bedrock User Guide |
| Lambda com LabRole | AWS Lambda docs (role pré-existente no Learner Lab) |
| Runbooks | PagerDuty video, Google SRE book |
| Circuit Breaker | *Release It!* (Nygard), pattern resilience4j |
