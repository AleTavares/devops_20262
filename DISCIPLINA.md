# DevOps — Informações da Disciplina

**Curso:** Análise e Desenvolvimento de Sistemas (ADS)  
**Instituição:** Centro Universitário UniFAAT  
**Professor:** Alexandre Tavares  
**Semestre:** 2026-2  
**Carga Horária:** 80 horas (15 encontros)

---

## Objetivo

Capacitar o aluno a projetar, implementar e operar pipelines de integração e entrega contínua (CI/CD) utilizando práticas de DevOps, desde o controle de versão com Git até deploys automatizados na AWS com estratégias de zero downtime, incorporando Infraestrutura como Código (Terraform), containerização (Docker) e inteligência artificial aplicada ao fluxo de trabalho.

---

## Ementa

Fundamentos de controle de versão (Git) e containerização (Docker). Orquestração de containers com Docker Compose. Infraestrutura como Código com Terraform na AWS (IAM, VPC, EC2, RDS). Gerenciamento de estado remoto e modularização. Resolução de problemas complexos com IA (decomposição, Harness e Spec-Driven Development). Integração Contínua com GitHub Actions. Registros de imagens Docker e automação de builds. Entrega Contínua com pipelines automatizados e GitOps. Estratégias de deploy (Blue/Green, Canary). Rollback, Feature Flags e AIOps. Inteligência Artificial como copiloto no ciclo DevOps (Kiro, AWS Bedrock). Projeto integrador com microserviço completo end-to-end.

---

## Conteúdo Programático

O curso é organizado em **5 módulos** distribuídos ao longo de **15 encontros (aulas)**, seguindo a narrativa "O Resgate da TechNova".

### Módulo 1 — Fundamentos e IA (Aulas 01–02)

- **Aula 01 — Git e Docker:** controle de versão (repositórios, branches, merge, remotes, boas práticas de commits); containerização com Docker (imagens, Dockerfile, layers, comandos essenciais)
- **Aula 02 — Docker Compose e IA como Copiloto:** orquestração multi-container (services, networks, volumes, variáveis de ambiente); introdução ao Kiro como copiloto DevOps

### Módulo 2 — Infraestrutura AWS com Terraform (Aulas 03–07)

- **Aula 03 — Terraform e Segurança AWS (IAM):** HCL, providers, init/plan/apply/destroy, state; users, groups, roles, policies, princípio do menor privilégio
- **Aula 04 — VPC, Networking e EC2:** subnets públicas/privadas, Internet Gateway, Route Tables, Security Groups; instâncias EC2, key pairs, user data
- **Aula 05 — RDS e Remote State:** PostgreSQL gerenciado, DB Subnet Groups, conectividade EC2-RDS; S3 backend e DynamoDB locking
- **Aula 06 — Terraform Modules (do Básico ao Avançado):** módulos locais, for_each, Terraform Registry, composição e versionamento
- **Aula 07 — Resolvendo Problemas Complexos com IA:** decomposição, Harness e Spec-Driven Development; geração de IaC com Kiro/Bedrock

### Módulo 3 — CI/CD e Automação (Aulas 08–09)

- **Aula 08 — GitHub Actions: CI Completo com Secrets:** workflows, triggers, jobs, steps; lint, testes, artifacts; GitHub Secrets, environments e approval gates
- **Aula 09 — Docker Registry e IA no CI/CD:** build/tag/push automatizado para ghcr.io; PR review automatizado e security scan com IA

### Módulo 4 — Entrega Contínua e Deploy (Aulas 10–12)

- **Aula 10 — Terraform Automatizado e CD Pipelines:** GitOps (plan on PR, apply on merge), OIDC com AWS; pipeline CI → Build → Push → Deploy com health checks
- **Aula 11 — Blue/Green e Canary Deployments:** zero downtime com ALB e Target Groups; weighted routing, rollout gradual e métricas de decisão
- **Aula 12 — Rollback Strategies e AIOps:** feature flags, expand-contract migrations, runbooks; CloudWatch Anomaly Detection e Bedrock para análise de incidentes

### Módulo 5 — Projeto Integrador (Aulas 13–15)

- **Aula 13 — Novo Microserviço com Pipeline End-to-End:** criação de microserviço do zero com pipeline E2E completo
- **Aula 14 — Disaster Simulation, Code Review e Agente Bedrock:** Chaos Engineering, Game Day; code review automatizado; agente DevOps com AWS Bedrock
- **Aula 15 — Apresentação Final:** demo da plataforma completa da TechNova com IA integrada

---

## Bibliografia Básica

1. CHACON, Scott; STRAUB, Ben. **Pro Git**. 2. ed. New York: Apress, 2014. Disponível em: https://git-scm.com/book/pt-br/v2
2. MORRIS, Kief. **Infrastructure as Code: Dynamic Systems for the Cloud Age**. 2. ed. Sebastopol: O'Reilly Media, 2020.
3. KIM, Gene; HUMBLE, Jez; DEBOIS, Patrick; WILLIS, John. **O Projeto Fênix: um romance sobre TI, DevOps e sobre ajudar o seu negócio a vencer**. Rio de Janeiro: Alta Books, 2018.

---

## Bibliografia Complementar

1. HUMBLE, Jez; FARLEY, David. **Entrega Contínua: como entregar software de forma rápida e confiável**. Porto Alegre: Bookman, 2014.
2. BRIKMAN, Yevgeniy. **Terraform: Up & Running**. 3. ed. Sebastopol: O'Reilly Media, 2022.
3. NICKOLOFF, Jeff; KUENZLI, Stephen. **Docker in Action**. 2. ed. Shelter Island: Manning Publications, 2019.
4. BASS, Len; WEBER, Ingo; ZHU, Liming. **DevOps: A Software Architect's Perspective**. Boston: Addison-Wesley, 2015.
5. FORSGREN, Nicole; HUMBLE, Jez; KIM, Gene. **Accelerate: The Science of Lean Software and DevOps**. Portland: IT Revolution Press, 2018.
