# Analise e Desenvolvimento de Sistemas( ADS ) — Centro Universitário UniFAAT

**Disciplina:** DevOps  
**Professor:** Alexandre Tavares  
**Instituição:** [Centro Universitário UniFAAT](https://www.unifaat.com.br/curso/atibaia/analise-e-desenvolvimento-de-sistemas)  
**Semestre:** 2026-2  
**Carga Horária:** 80 horas


## A Narrativa: O Resgate da TechNova

Você faz parte da nova equipe de **Platform Engineering** da TechNova — uma startup promissora cuja API crítica está à beira do colapso. Sem controle de versão, sem testes, sem automação. Sua missão: transformar o caos em uma plataforma escalável, segura e totalmente automatizada na AWS.

Ao longo de 15 aulas, você vai resgatar a TechNova desde o primeiro `git init` até pipelines de CI/CD completas com deploy Blue/Green e Canary na nuvem — com IA integrada ao fluxo de trabalho usando Kiro e AWS Bedrock.

## Stack Tecnológica

| Ferramenta | Uso |
|------------|-----|
| **Git + GitHub** | Controle de versão, colaboração e entrega via PR |
| **Docker + Docker Compose** | Containerização e ambiente local |
| **Terraform** | Infraestrutura como Código (AWS) |
| **AWS** (Free Tier) | EC2, VPC, RDS, S3, IAM, ALB |
| **GitHub Actions** | CI/CD — Integração e Entrega Contínua |
| **Node.js + Express** | Aplicação base (API de pedidos) |
| **Kiro** | IDE com IA integrada (copiloto DevOps) |
| **AWS Bedrock** | IA generativa para automação inteligente |


## Estrutura do Repositório

```
unifaat-2026-2-devops/
├── README.md                    # Este arquivo
├── app-technova/                # Aplicação base (API Node.js)
├── modulo-01/                   # Fundamentos e IA
│   ├── aula-01/                 # Git + Docker
│   └── aula-02/                 # Docker Compose + Intro IA/Kiro
├── modulo-02/                   # Infraestrutura AWS com Terraform
│   ├── aula-03/                 # Terraform Fundamentals + IAM
│   ├── aula-04/                 # VPC, Networking e EC2
│   ├── aula-05/                 # RDS e Remote State
│   ├── aula-06/                 # Terraform Modules (Básico ao Avançado)
│   └── aula-07/                 # Revisão Arquitetura + IA para IaC
├── modulo-03/                   # CI/CD e Automação
│   ├── aula-08/                 # GitHub Actions + CI + Secrets
│   └── aula-09/                 # Docker Registry + IA no CI/CD
├── modulo-04/                   # Entrega Contínua e Deploy
│   ├── aula-10/                 # Terraform Automatizado + CD Pipelines
│   ├── aula-11/                 # Blue/Green + Canary Deployments
│   └── aula-12/                 # Rollback Strategies + AIOps
├── modulo-05/                   # Projeto Integrador
│   ├── aula-13/                 # Novo Microserviço + Pipeline E2E
│   ├── aula-14/                 # Disaster Simulation + Code Review + Agente Bedrock
│   └── aula-15/                 # Apresentação Final
├── entregas/                    # Pasta para entregas dos alunos via PR
│   ├── aula-01/ ... aula-15/
└── .github/
    └── pull_request_template.md # Template para PRs de entrega
```

## Grade Curricular

### Módulo 1 — Fundamentos e IA (Aulas 01–02)

| Aula | Tema | Descrição |
|:----:|------|-----------|
| 01 | Git + Docker | Controle de versão, branches, merge, remotes + Containers, Dockerfile, imagens |
| 02 | Docker Compose + Intro IA | Orquestração multi-container + Introdução ao Kiro como copiloto DevOps |

### Módulo 2 — Infraestrutura AWS com Terraform (Aulas 03–07)

| Aula | Tema | Descrição |
|:----:|------|-----------|
| 03 | Terraform + IAM | IaC, HCL, providers, init/plan/apply + Users, roles, policies, least privilege |
| 04 | VPC + EC2 | Subnets públicas/privadas, IGW, Route Tables + Instâncias, Security Groups, SSH |
| 05 | RDS + Remote State | PostgreSQL gerenciado + S3 backend, DynamoDB locking |
| 06 | Terraform Modules | Módulos locais, for_each, Registry, composição, versionamento |
| 07 | Revisão + IA para IaC | Arquitetura completa, validação E2E + Kiro/Bedrock para geração de Terraform |

### Módulo 3 — CI/CD e Automação (Aulas 08–09)

| Aula | Tema | Descrição |
|:----:|------|-----------|
| 08 | GitHub Actions + CI + Secrets | Workflows, lint, test, build, artifacts + Secrets, environments, approval gates |
| 09 | Docker Registry + IA no CI/CD | Build/push ghcr.io + PR review automatizado com IA |

### Módulo 4 — Entrega Contínua e Deploy (Aulas 10–12)

| Aula | Tema | Descrição |
|:----:|------|-----------|
| 10 | Terraform Automatizado + CD | GitOps (plan on PR, apply on merge) + Pipeline CI→Build→Deploy |
| 11 | Blue/Green + Canary | Zero downtime com ALB + Rollout gradual com weighted routing |
| 12 | Rollback + AIOps | Feature flags, DB migrations, runbooks + Anomaly detection com Bedrock |

### Módulo 5 — Projeto Integrador (Aulas 13–15)

| Aula | Tema | Descrição |
|:----:|------|-----------|
| 13 | Novo Microserviço + E2E | Criar technova-notifications do zero com pipeline completo |
| 14 | Disaster Simulation + Agente Bedrock | Chaos Engineering, Game Day + Agente DevOps com Bedrock |
| 15 | Apresentação Final | Demo da plataforma completa com IA integrada |

## Integração com IA (Kiro + AWS Bedrock)

O curso incorpora IA de forma progressiva em **5 aulas**:

| Aula | Tema IA | Nível | Ferramentas |
|:----:|---------|:-----:|-------------|
| 02 | Introdução: IA como copiloto no DevOps | Demo | Kiro |
| 07 | Geração de IaC com IA (Terraform via prompts) | Hands-on | Kiro + Bedrock |
| 09 | PR Review automatizado, análise de código | Hands-on | Bedrock + GitHub Actions |
| 12 | AIOps: detecção de anomalias, monitoramento preditivo | Hands-on | Bedrock + CloudWatch |
| 14 | Agente DevOps completo integrado ao pipeline | Avançado | Bedrock Agent + Lambda |

## Cada Aula Contém

Cada pasta `aula-XX/` possui **7 arquivos padronizados**:

| Arquivo | Conteúdo |
|---------|----------|
| `README.md` | Visão geral, objetivos, contexto narrativo e cronograma (~5h) |
| `TA.md` | Trabalho Anterior — leitura prévia com teoria completa + 3 questões |
| `trabalho-em-aula.md` | Atividade prática guiada em sala |
| `laboratorio-parte1.md` | Lab hands-on parte 1 (~120 min) |
| `laboratorio-parte2.md` | Lab hands-on parte 2 (~120 min) |
| `TF.md` | Trabalho de Fixação — exercício semanal com entrega via PR |
| `materiais-complementares.md` | Links, vídeos e referências extras |

## Regras de Entrega dos Trabalhos de Fixação (TF)

1. Faça **fork** deste repositório
2. Crie uma **branch**: `SEU-RA/tx-XX` (ex: `12345/tf-01`)
3. Crie a pasta `entregas/SEU-RA/tf-XX/` com os artefatos solicitados
4. Faça commits descritivos seguindo [Conventional Commits](https://www.conventionalcommits.org/pt-br/)
5. Abra um **Pull Request** com título: `[Aula XX] RA: XXXXX - Nome Completo`

### Arquivos proibidos (nunca commitar):
- `*.tfstate` e `*.tfstate.backup`
- `.env` (variáveis de ambiente com secrets)
- `node_modules/`
- `*.pem` (chaves privadas)

## Pré-requisitos

- Conta GitHub (gratuita)
- Docker Desktop instalado
- Node.js 18+ instalado
- Editor de código (Kiro ou VS Code recomendado)
- Conta AWS (Free Tier) — a partir do Módulo 2
- Terminal (Git Bash no Windows, Terminal no macOS/Linux)
- Terraform instalado (>= 1.0)

## Custos AWS

Todos os exercícios utilizam apenas recursos elegíveis ao **AWS Free Tier**:

| Recurso | Limite Gratuito |
|---------|-----------------|
| EC2 t2.micro | 750 horas/mês |
| RDS db.t3.micro | 750 horas/mês |
| S3 | 5 GB |
| DynamoDB | 25 GB |
| ALB | 750 horas/mês |
| Lambda | 1M requests/mês |
| VPC, IAM, Security Groups | Sempre gratuitos |

> ⚠️ **Sempre execute `terraform destroy` após os laboratórios** para evitar custos.

## Objetivo da Disciplina

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

## Referências e Documentação Online

- [Pro Git Book (PT-BR)](https://git-scm.com/book/pt-br/v2)
- [Docker Documentation](https://docs.docker.com/)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [AWS Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)
- [Kiro IDE](https://kiro.dev/)

## 👨‍🏫 Sobre o Professor

**Alexandre Tavares**  
Docente de DevOps, Engenharia de Dados e Cloud Computing  
Centro Universitário UniFAAT — Atibaia/SP

---

*Este repositório é material didático do curso de Análise e Desenvolvimento de Sistemas do Centro Universitário UniFAAT.*
