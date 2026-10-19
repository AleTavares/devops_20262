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

# Aula 15 — Apresentação Final

**DevOps — Centro Universitário UniFAAT**
Prof. Alexandre Tavares | Semestre 2026-2

---

# O Dia Chegou

> **O Resgate da TechNova — Episódio Final: "Missão Cumprida"**

Depois de 15 encontros, a TechNova não é mais a empresa em crise da Aula 01. Deploys manuais, infra frágil e ausência de automação deram lugar a:

- Pipelines de **CI/CD** automatizados
- **Infraestrutura como código** na AWS (Terraform)
- Imagens versionadas num **registry** (Amazon ECR)
- Deploy com **zero downtime** (Blue/Green e Canary)
- **IA** integrada ao ciclo DevOps

> Hoje é o dia de cada engenheiro apresentar sua jornada — do caos à excelência operacional.

---

# O Que Esta Aula Entrega

Esta é a **síntese de todo o curso**. O objetivo:

1. **Apresentar** o portfólio DevOps completo de forma profissional
2. **Demonstrar** o pipeline end-to-end funcionando ao vivo
3. **Articular** a evolução técnica da Aula 01 à Aula 15
4. **Demonstrar** a integração de IA no fluxo DevOps
5. **Avaliar** os colegas com feedback construtivo

> Não é sobre ser perfeito — é sobre mostrar o que você construiu e como evoluiu.

---

# A Jornada: Fundação (Aulas 01-04)

| Tema | O que você domina |
|------|-------------------|
| **Git** | Repositórios, branches, merge, remotes, bons commits |
| **Docker** | Imagens, Dockerfile, layers, comandos essenciais |
| **Docker Compose** | Services, networks, volumes, variáveis de ambiente |
| **IA copiloto** | Kiro e prompting para infraestrutura |

> A base: versionar, containerizar e já colocar a IA como copiloto do desenvolvimento.

---

# A Jornada: Infra na AWS (Aulas 05-12)

| Tema | O que você domina |
|------|-------------------|
| **Terraform** | HCL, providers, `init/plan/apply/destroy`, state |
| **IAM / VPC** | Menor privilégio, subnets, SGs, Internet Gateway |
| **EC2 / RDS** | Instâncias, user data, PostgreSQL gerenciado |
| **Remote State / Módulos** | Backend S3 + DynamoDB lock, módulos reutilizáveis |
| **IA para IaC** | Geração de Terraform com Kiro/Bedrock |

> Tudo provisionado por código no **AWS Academy Learner Lab** (`us-east-1`).

---

# A Jornada: CI/CD e Deploy (Aulas 13-18)

| Tema | O que você domina |
|------|-------------------|
| **GitHub Actions** | Workflows, triggers, jobs, testes, Secrets |
| **Amazon ECR + IA no CI/CD** | Push de imagens, review de PR por IA |
| **GitOps / CD** | Plan on PR, apply on merge, health checks |
| **Blue/Green e Canary** | ALB, target groups, rollout gradual |
| **Rollback e AIOps** | Feature flags, runbooks, CloudWatch + Bedrock |
| **Projeto Integrador** | Microserviço E2E + agente DevOps |

> A orquestração em produção usa **EC2/ALB** via Terraform no Lab (sem plataformas de orquestração de containers).

---

# A Arquitetura Final

```
[Dev Push]
   │
   ▼
[GitHub Actions CI] ── lint ── test ── build
   │                                   │
   │                           [AI Review no PR]
   ▼
[Push da imagem → Amazon ECR]  (<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com)
   │
   ▼
[CD / GitOps] ── terraform apply ── deploy (EC2 + ALB)
   │
   ▼
[Blue/Green | Canary] ── health check ── rollback por tag
   │
   ▼
[Observabilidade: CloudWatch] ── [AIOps: Bedrock]
```

> Uma plataforma única que cobre do commit ao deploy observável, com IA no caminho.

---

# Demo (1/3): Pipeline CI/CD

O coração da apresentação — o pipeline rodando de verdade:

```bash
git checkout -b demo/aula-15
echo "# Demo Aula 15" >> demo-test.md
git add demo-test.md && git commit -m "feat: demo aula 15"
git push origin demo/aula-15
```

**Mostrar ao vivo:**
- O CI dispara: **lint → test → build**
- A imagem é publicada no **Amazon ECR**
- O CD faz o deploy com health check

> **☁️ Learner Lab:** sessão ativa, credenciais temporárias e `us-east-1` confirmados antes da demo.

---

# Demo (1/3): Publicar no Amazon ECR

O registry do curso é o **Amazon ECR**, na mesma conta AWS onde a infra roda:

```bash
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin \
    <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

docker build -t technova-api .
SHA=$(git rev-parse --short HEAD)
docker tag technova-api <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/technova-api:sha-$SHA
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/technova-api:sha-$SHA
```

> No console do ECR, mostre as tags (`sha-...`, `latest`, semver). **Build once, run anywhere.**

---

# Demo (2/3): Deploy e Rollback

Mesma imagem testada no CI roda em produção — e o rollback vira trivial:

| Estratégia | Ideia | Benefício |
|------------|-------|-----------|
| **Blue/Green** | Dois ambientes, troca de tráfego no ALB | Troca instantânea, rollback imediato |
| **Canary** | Tráfego gradual para a nova versão | Risco controlado, métricas de decisão |

```bash
# Rollback por tag de imagem — segundos para voltar
docker run -d -p 3000:3000 <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/technova-api:1.0.0
```

> Deploy com zero downtime: o usuário não percebe a troca de versão.

---

# Demo (3/3): IA no Fluxo DevOps

A IA evoluiu de copiloto a agente autônomo ao longo do curso:

| Modo | Onde | O que faz |
|------|------|-----------|
| **Interativo** | Kiro | Desenvolvimento assistido |
| **Semi-automático** | IaC (Bedrock) | Gera e valida Terraform |
| **Automático** | CI/CD | Review de PR com quality gate |
| **Autônomo** | Agente Bedrock | Analisa PR, detecta drift, gera runbook |

> Demonstre pelo menos uma: review de PR, IaC por IA, ou o agente DevOps com **AWS Bedrock** (via credenciais da sessão do Lab).

---

# Maturidade DevOps — Onde Você Chegou

| Nível | Descrição |
|-------|-----------|
| 1 — Inicial | Manual, "funciona na minha máquina" |
| 2 — Gerenciado | CI básico, automação parcial |
| 3 — Definido | **CI/CD funcional, IaC, containers** |
| 4 — Quantificado | Métricas DORA, monitoramento, SLOs |
| 5 — Otimizado | IA integrada, zero downtime, chaos engineering |

> Avalie cada dimensão (versão, CI, CD, IaC, deploy, observabilidade, IA) comparando a Aula 01 com hoje.

---

# Antes vs Depois

| Dimensão | Aula 01 | Aula 15 |
|----------|---------|---------|
| Deploy | Manual, arriscado | Automatizado, zero downtime |
| Infra | Ad hoc, frágil | Código versionado (Terraform) |
| Imagens | Presas no runner | Versionadas no Amazon ECR |
| Review | Só humano, lento | IA + humano, 24/7 |
| Operação | Reativa | Observável, com AIOps |

> A pergunta-chave da narrativa: "qual era o estado na Aula 01, e o que mudou até hoje?"

---

# A Apresentação na Prática

Estrutura sugerida — foque em **mostrar o sistema**, não em acumular slides:

1. **Arquitetura** — diagrama + stack
2. **Demo do pipeline** — push → CI → ECR → deploy
3. **Demo de IA** — review de PR / IaC / agente Bedrock
4. **Lições e evolução** — Aula 01 → 15
5. **Perguntas** — turma e professor

> Tenha sempre um **plano B** (vídeo/screenshots) caso a sessão do Lab expire na hora.

---

# Avaliação — TF e Trabalho em Aula

**TF (entrega final):** portfólio `unifaat-devops-portfolio` público + demo.

| Critério | Peso |
|----------|:----:|
| Completude do portfólio + README da jornada | 30% |
| Pipeline CI → ECR + CD/rollback + estratégia de deploy | 30% |
| Integração de IA | 15% |
| Apresentação e evolução | 20% |
| Participação como avaliador | 5% |

> O **Trabalho em Aula** (apresentar + avaliar os colegas) vale 1 ponto na nota final.

---

# Próximos Passos na Jornada

**Certificações (alinhadas à stack praticada):**
- AWS Cloud Practitioner → Solutions Architect Associate → DevOps Engineer Pro
- HashiCorp Terraform Associate

**Tecnologias para aprofundar:**
- GitOps avançado (ArgoCD/Flux), Vault, OpenTelemetry
- AIOps (CloudWatch Anomaly Detection, agentes Bedrock)
- Platform Engineering (Backstage), FinOps

> Monte um roadmap pessoal e mantenha o portfólio vivo — ele é seu cartão de visitas.

---

# Retrospectiva: 4Ls

Reflita e compartilhe:

- 😊 **Liked** — o que mais gostou no curso
- 📚 **Learned** — o aprendizado mais importante
- 😕 **Lacked** — o que faltou
- 🌟 **Longed For** — o que gostaria de ter visto mais

> Feedback honesto ajuda a melhorar o curso para as próximas turmas — e consolida o seu próprio aprendizado.

---

# Resumo dos Conceitos

| Conceito | Descrição |
|----------|-----------|
| Portfólio integrador | Repositório público com toda a jornada do curso |
| Pipeline E2E | Push → CI → build → push ECR → deploy |
| Amazon ECR | Registry do curso (`us-east-1`, Learner Lab) |
| Zero downtime | Blue/Green e Canary com rollback por tag |
| AIOps | CloudWatch + Bedrock para operação inteligente |
| Agente DevOps | Bedrock analisa PR, detecta drift, gera runbook |
| Maturidade DevOps | Modelo de 5 níveis de autoavaliação |
| Métricas DORA | Lead time, deploy frequency, MTTR, change failure |

---

# Encerramento do Curso

Você percorreu a jornada completa: do versionamento com Git e da containerização com Docker, à infraestrutura como código na AWS, pipelines de CI/CD com Amazon ECR, deploy com zero downtime, rollback, AIOps e um agente de IA com Bedrock.

O resultado não é uma nota — é uma **plataforma completa, documentada e funcional** que comprova sua capacidade de **projetar, implementar e operar** entrega contínua de ponta a ponta.

> **Guarde e evolua seu portfólio.** DevOps não é um destino, é prática contínua de melhoria.

**Parabéns por chegar até aqui. Missão cumprida.** 🎓
