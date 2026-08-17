# DevOps — Informações da Disciplina

**Curso:** Análise e Desenvolvimento de Sistemas (ADS)  
**Instituição:** Centro Universitário UniFAAT  
**Professor:** Alexandre Tavares  
**Semestre:** 2026-2  
**Carga Horária:** 80 horas (15 encontros)


## Objetivo

Capacitar o aluno a projetar, implementar e operar pipelines de integração e entrega contínua (CI/CD) utilizando práticas de DevOps, desde o controle de versão com Git até deploys automatizados na AWS com estratégias de zero downtime, incorporando Infraestrutura como Código (Terraform), containerização (Docker) e inteligência artificial aplicada ao fluxo de trabalho.


## Ementa

Fundamentos de controle de versão (Git) e containerização (Docker). Orquestração de containers com Docker Compose. Infraestrutura como Código com Terraform na AWS (IAM, VPC, EC2, RDS). Gerenciamento de estado remoto e modularização. Integração Contínua com GitHub Actions. Registros de imagens Docker e automação de builds. Entrega Contínua com pipelines automatizados e GitOps. Estratégias de deploy (Blue/Green, Canary). Rollback, Feature Flags e AIOps. Inteligência Artificial como copiloto no ciclo DevOps (Kiro, AWS Bedrock). Projeto integrador com microserviço completo end-to-end.


## Conteúdo Programático

### Módulo 1 — Fundamentos e IA (16h)

1. Controle de versão com Git: repositórios, branches, merge, remotes, boas práticas de commits
2. Containerização com Docker: imagens, Dockerfile, layers, comandos essenciais
3. Orquestração com Docker Compose: services, networks, volumes, variáveis de ambiente
4. IA como copiloto DevOps: introdução ao Kiro, prompting para infraestrutura

### Módulo 2 — Infraestrutura AWS com Terraform (40h)

5. Terraform fundamentals: HCL, providers, init/plan/apply/destroy, state
6. IAM: users, groups, roles, policies, princípio do menor privilégio
7. VPC e Networking: subnets públicas/privadas, Internet Gateway, Route Tables, Security Groups
8. EC2: instâncias, AMIs, key pairs, user data, instance profiles
9. RDS: PostgreSQL gerenciado, DB Subnet Groups, conectividade EC2-RDS
10. Remote State: S3 backend, DynamoDB locking, migração de state
11. Terraform Modules: módulos locais, for_each, Terraform Registry, composição e versionamento
12. Revisão de arquitetura e IA para geração de IaC com Kiro/Bedrock

### Módulo 3 — CI/CD e Automação (16h)

13. GitHub Actions: workflows, triggers, jobs, steps, multi-stage pipelines
14. Testes automatizados: ESLint, Jest, artifacts, status badges
15. Secrets management: GitHub Secrets, GITHUB_TOKEN, environments com protection rules
16. Docker Registry (ghcr.io): build, tag, push automatizado
17. IA no CI/CD: PR review automatizado, security scan de Dockerfiles

### Módulo 4 — Entrega Contínua e Deploy (24h)

18. GitOps: Terraform plan on PR, apply on merge, OIDC com AWS
19. Pipelines de CD: CI → Build → Push → Deploy, health checks
20. Blue/Green Deployment: ALB, Target Groups, traffic switch
21. Canary Deployment: weighted routing, rollout gradual, métricas de decisão
22. Rollback strategies: feature flags, expand-contract migrations, runbooks
23. AIOps: CloudWatch Anomaly Detection, Bedrock para análise de incidentes

### Módulo 5 — Projeto Integrador (24h)

24. Criação de microserviço do zero com pipeline E2E completo
25. Chaos Engineering: Game Day, simulação de desastres, métricas de resiliência
26. Agente DevOps com AWS Bedrock: análise de PRs, detecção de drift, geração de runbooks
27. Apresentação final: demo da plataforma completa com IA integrada


## Bibliografia Básica

1. CHACON, Scott; STRAUB, Ben. **Pro Git**. 2. ed. New York: Apress, 2014. Disponível em: https://git-scm.com/book/pt-br/v2
2. MORRIS, Kief. **Infrastructure as Code: Dynamic Systems for the Cloud Age**. 2. ed. Sebastopol: O'Reilly Media, 2020.
3. KIM, Gene; HUMBLE, Jez; DEBOIS, Patrick; WILLIS, John. **O Projeto Fênix: um romance sobre TI, DevOps e sobre ajudar o seu negócio a vencer**. Rio de Janeiro: Alta Books, 2018.


## Bibliografia Complementar

1. HUMBLE, Jez; FARLEY, David. **Entrega Contínua: como entregar software de forma rápida e confiável**. Porto Alegre: Bookman, 2014.
2. BRIKMAN, Yevgeniy. **Terraform: Up & Running**. 3. ed. Sebastopol: O'Reilly Media, 2022.
3. NICKOLOFF, Jeff; KUENZLI, Stephen. **Docker in Action**. 2. ed. Shelter Island: Manning Publications, 2019.
4. BASS, Len; WEBER, Ingo; ZHU, Liming. **DevOps: A Software Architect's Perspective**. Boston: Addison-Wesley, 2015.
5. FORSGREN, Nicole; HUMBLE, Jez; KIM, Gene. **Accelerate: The Science of Lean Software and DevOps**. Portland: IT Revolution Press, 2018.
