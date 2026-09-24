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

### O que entregar

Cada TF deve ser desenvolvido no **repositório pessoal do aluno** (criado na Aula 01: `unifaat-devops-portfolio`). A entrega neste repositório da disciplina consiste em um **arquivo Markdown (`entrega.md`)** contendo o **link para o seu repositório** e as evidências solicitadas.

### Passo a Passo

1. **Desenvolva o TF** no seu repositório pessoal (`unifaat-devops-portfolio`)
2. Faça **fork** deste repositório da disciplina (se ainda não fez)
3. Crie uma **branch**: `SEU-RA/tf-XX` (ex: `12345/tf-01`)
4. Crie a pasta `entregas/aula-XX/SEU-RA/`
5. Adicione o arquivo **`entrega.md`** com o link do seu repositório + evidências (veja modelo abaixo)
6. Faça commits descritivos seguindo [Conventional Commits](https://www.conventionalcommits.org/pt-br/)
7. Abra um **Pull Request** para o repositório original com título: `[Aula XX] RA: XXXXX - Nome Completo`

### Modelo do arquivo `entrega.md`

```markdown
# Entrega — Aula XX: [Título do TF]

**Aluno:** [Seu nome completo]  
**RA:** [Seu RA]  
**Data:** [Data da entrega]

## Repositório

- URL: https://github.com/SEU-USUARIO/unifaat-devops-portfolio

## Evidências

- [ ] [Liste os entregáveis conforme solicitado no TF]
- [ ] [Adicione screenshots ou logs quando pedido]
```

> **Importante:** O repositório pessoal do aluno deve estar **público** para que o professor consiga avaliar. PRs que não contenham o link para o repositório ou cujo repositório esteja privado serão considerados **incompletos**.

### Arquivos proibidos (nunca commitar):
- `*.tfstate` e `*.tfstate.backup`
- `.env` (variáveis de ambiente com secrets)
- `node_modules/`
- `*.pem` (chaves privadas)

### Como os PRs são avaliados (IA + professor)

> 🤖 **Aviso de transparência:** os Pull Requests de TF passam por uma **avaliação automática assistida por IA** antes da conferência humana.

Quando você abre um PR, um workflow de **GitHub Actions** roda um avaliador que:

1. Identifica a aula e o RA pelo título do PR;
2. Lê os critérios do `TF.md` da aula e o seu `entrega.md`;
3. Acessa o seu repositório de portfólio e verifica o código entregue
   (arquivos obrigatórios, boas práticas, evidências);
4. Envia esse contexto para um **LLM no Amazon Bedrock**, que gera um parecer
   preliminar com nota e comentários, publicado como **comentário no próprio PR**.

**A nota do bot é preliminar.** A avaliação final é sempre **conferida e validada
pelo professor** — inclusive o componente de **execução no AWS Academy**, que não
é verificável pelo PR e é checado manualmente. Em caso de divergência, prevalece
a avaliação do professor.

> 💡 **Isto é a própria disciplina em ação.** Este repositório usa, de verdade, o
> que você vai aprender ao longo do curso: **GitHub Actions** (aula 08),
> **PR review automatizado com IA** (aula 09), **secrets, environments e approval
> gates** (aula 08) e **AWS Bedrock** (aulas 07, 09, 12 e 14). A automação de
> avaliação é um exemplo vivo de CI e AIOps aplicados. O código dela fica em
> `.github/` — sinta-se à vontade para lê-lo como referência.

## Regras de Entrega do Trabalho em Aula

### O que é

Cada aula possui uma atividade de discussão/prática em sala (`trabalho-em-aula.md`). A entrega das respostas vale **1 ponto na nota final** do semestre — contabilizado apenas ao final, com **todos** os trabalhos entregues.

### O que entregar

Um arquivo `trabalho-em-aula.md` com as respostas das atividades realizadas em sala (discussões, análises, tabelas preenchidas). O modelo específico de cada aula está dentro do respectivo `trabalho-em-aula.md`.

### Onde entregar

Na **mesma pasta** da entrega do TF, no fork da disciplina:

```
entregas/aula-XX/SEU-RA/trabalho-em-aula.md
```

### Como entregar

- O arquivo pode ser adicionado no **mesmo PR** do TF ou em PR separado
- A entrega é **individual** — mesmo que a atividade tenha sido em grupo
- Entregas parciais (apenas algumas aulas) **não garantem o ponto**

---

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

## Referências Principais

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
