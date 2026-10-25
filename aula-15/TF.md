# Trabalho de Fixação (TF) — Aula 15: Apresentação Final e Entrega do Portfólio

## Desafio

Esta é a **entrega final do curso**: consolidar tudo o que você construiu num portfólio DevOps completo, público e funcional — o `unifaat-devops-portfolio` — e **apresentá-lo ao vivo** demonstrando o pipeline end-to-end e a integração de IA. O portfólio representa a jornada inteira: de Git/Docker e Terraform/IaC na AWS, passando por CI/CD com GitHub Actions e **Amazon ECR**, estratégias de deploy (Blue/Green e Canary), rollback e AIOps, até o projeto integrador com microserviço end-to-end e agente de IA (**AWS Bedrock**), tudo operando no **AWS Academy Learner Lab**. Registre a entrega via Pull Request no repositório da disciplina.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | 1 semana a partir da data da aula |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork** | `entregas/aula-15/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com link do portfólio + evidências |
| **Arquivos do projeto** | No repositório `unifaat-devops-portfolio` (público) |

### Como Entregar via Pull Request

1. Faça um **fork** do repositório da disciplina (se ainda não fez)
2. Clone o seu fork localmente
3. Crie a pasta `entregas/aula-15/SEU-RA/`
4. Adicione **apenas** o arquivo `entrega.md` (modelo abaixo) — o portfólio completo fica no `unifaat-devops-portfolio`
5. Faça commit e push para o seu fork
6. Abra um **Pull Request** para o repositório original

**Modelo do arquivo `entrega.md`:**

```markdown
# Entrega — Aula 15: Apresentação Final e Portfólio DevOps

**Aluno:** [Seu nome completo]
**RA:** [Seu RA]
**Data:** [Data da entrega]

## Repositório do Portfólio

- URL (público): https://github.com/SEU-USUARIO/unifaat-devops-portfolio

## Evidências

- [ ] Portfólio público com o README da jornada (Aula 01 → 15)
- [ ] Conteúdo de todas as etapas do curso documentado (conforme a grade real)
- [ ] Pipeline CI/CD funcional: lint/test/build → push no **Amazon ECR** → deploy
- [ ] Estratégia de deploy demonstrada (Blue/Green ou Canary) e rollback
- [ ] Integração de IA (review de PR, IaC por IA ou agente Bedrock) funcionando
- [ ] Projeto integrador (microserviço E2E) rodando no Learner Lab (`us-east-1`)
- [ ] Autoavaliação de maturidade DevOps + próximos passos (retrospectiva)
- [ ] Link/screenshots da execução do pipeline e da imagem no console do ECR

## Evidência do Pipeline e da Apresentação

[Cole aqui o link da execução do CI/CD, screenshots do console do ECR,
 e o link do vídeo/slides da apresentação, se houver]
```

---

## Exercício: Portfólio Integrador Completo + Demo ao Vivo

### Contexto

O CTO da TechNova pede o relatório final de cada engenheiro: um portfólio documentado de tudo que foi construído, com código funcional, pipelines ativos e documentação clara. Esse portfólio será a referência para futuros engenheiros da empresa — e o seu cartão de visitas no mercado. Além de entregar o repositório, você vai **apresentá-lo ao vivo**, demonstrando o sistema real.

> **☁️ Learner Lab:** a demo e as evidências que dependem de AWS (ECR, EC2, ALB, RDS,
> Bedrock) usam as credenciais temporárias da sessão do Lab (com `aws_session_token`),
> sempre em `us-east-1`. O Lab **permite criar repositórios ECR** e usar a role
> pré-existente `LabRole`/`LabInstanceProfile`, mas **não permite criar usuários/grupos/roles
> IAM**. As credenciais **expiram por sessão** — recarregue antes de apresentar.

### Requisitos

#### 1. Portfólio Completo e Documentado (30%)

O repositório `unifaat-devops-portfolio` (público) deve consolidar a jornada do curso, conforme a grade real da disciplina, com documentação por etapa:

- `README.md` principal com a **jornada de aprendizagem** (onde começou, o que aprendeu, onde está agora), stack tecnológica, diagrama de arquitetura (ASCII ou imagem) e instruções de "como rodar"
- Fundação: Git/Docker, Docker Compose, IA copiloto (Kiro)
- Infra: Terraform (IAM, VPC, EC2, RDS), remote state (S3/DynamoDB) e módulos
- CI/CD: GitHub Actions (lint/test/build, Secrets), **Amazon ECR**, GitOps/CD
- Deploy: Blue/Green e Canary, rollback e AIOps
- Projeto integrador: microserviço end-to-end + agente DevOps (**AWS Bedrock**)

#### 2. Pipeline End-to-End Funcional (25%)

Demonstre, ao vivo, o fluxo completo:

- Push de código dispara o **CI** (lint → test → build)
- A imagem é publicada no **Amazon ECR**: `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com`
- O **CD** faz o deploy (EC2/ALB no Learner Lab) com health check
- Estratégia de deploy (Blue/Green ou Canary) e **rollback** por tag de imagem

#### 3. Integração de IA no Fluxo (15%)

Demonstre pelo menos uma integração de IA, entre as que o curso cobriu:

- **Review automático de PR** com IA (quality gate)
- **Geração/validação de IaC** com assistente (Kiro/Bedrock)
- **Agente DevOps** com AWS Bedrock (análise de PR, detecção de drift, geração de runbook)

#### 4. Apresentação e Evolução (30%)

- Apresentação estruturada (arquitetura → demo pipeline → demo IA → lições/evolução → perguntas)
- Narrativa clara da evolução Aula 01 → 15
- Autoavaliação de maturidade DevOps + próximos passos (certificações/tecnologias)
- Participação como avaliador dos colegas (feedback construtivo)

---

## Estrutura de Entrega

```
entregas/aula-15/RA/
└── entrega.md                  # Link do portfólio público + evidências + apresentação

# No repositório unifaat-devops-portfolio (público):
unifaat-devops-portfolio/
├── README.md                   # Jornada de aprendizagem (obrigatório)
├── git-docker/                 # Git + Docker
├── docker-compose/             # Orquestração local
├── ia-copiloto/                # Kiro / prompting para IaC
├── terraform-aws/              # Terraform: IAM, VPC, EC2, RDS
├── terraform-state-modules/    # Remote state + módulos
├── ci-github-actions/          # CI: lint, test, build, Secrets
├── registry-ecr/               # Amazon ECR + IA no CI/CD
├── cd-gitops/                  # GitOps e pipelines de CD
├── deploy-blue-green-canary/   # Blue/Green e Canary
├── rollback-aiops/             # Rollback, feature flags, AIOps
├── projeto-integrador/         # Microserviço E2E + agente Bedrock
├── app-technova/               # Código da aplicação
├── infra/                      # Terraform
├── .github/workflows/          # ci.yml, cd.yml, ai-review.yml
└── docker-compose.yml
```

> **📁 Na pasta de entrega do fork (`entregas/aula-15/RA/`) vai _somente_ o `entrega.md`.** Todo o portfólio (código, infra, workflows e evidências/apresentação) fica no seu repositório `unifaat-devops-portfolio` (público). PRs que alterem arquivos fora da sua pasta de entrega são bloqueados automaticamente.

> A estrutura de pastas é livre — o que importa é demonstrar a jornada completa com código funcional e documentação por etapa.

---

## Critérios de Avaliação

| Critério | Peso | Descrição |
|----------|:----:|-----------|
| Completude do portfólio | 20% | Todas as etapas do curso documentadas (conforme a grade real) |
| README da jornada | 10% | Jornada de aprendizagem, stack, arquitetura e "como rodar" |
| Pipeline CI → ECR | 15% | CI (lint/test/build) + push da imagem no **Amazon ECR** |
| CD + deploy + rollback | 10% | Deploy no Learner Lab com health check e rollback por tag |
| Estratégia de deploy | 5% | Blue/Green ou Canary demonstrada |
| Integração de IA | 15% | Review de PR, IaC por IA ou agente Bedrock funcionando |
| Clareza da apresentação | 10% | Comunicação objetiva e estruturada |
| Evolução demonstrada | 10% | Narrativa coerente da jornada Aula 01 → 15 |
| Participação como avaliador | 5% | Feedback construtivo aos colegas |

---

## Critérios de Excelência (Bônus)

Para nota acima da média, demonstre adicionalmente:

- [ ] Pipeline E2E completo com lifecycle policy no ECR e scan de vulnerabilidades
- [ ] Métricas DORA (lead time, deploy frequency, MTTR, change failure rate) no portfólio
- [ ] Agente Bedrock integrado ao CI/CD (review de PR + detecção de drift + runbook)
- [ ] Observabilidade (CloudWatch) com alarmes e evidência de AIOps
- [ ] Badge de status do pipeline no README do portfólio
- [ ] Vídeo da demo (plano B profissional) publicado no repositório
- [ ] `terraform destroy` documentado ao final (higiene de recursos no Lab)

---

## Entrega

### 1 — Publicar o portfólio

O portfólio completo fica no seu `unifaat-devops-portfolio` (público):

```bash
cd unifaat-devops-portfolio
git checkout -b feature/aula-15-portfolio-final
# consolide o conteúdo das etapas do curso + atualize o README da jornada
git add .
git commit -m "feat(aula-15): portfolio integrador final com pipeline E2E e IA"
git checkout main
git merge feature/aula-15-portfolio-final
git push origin main
git push origin feature/aula-15-portfolio-final
```

### 2 — Registrar entrega no fork da disciplina

```bash
cd /caminho/para/seu-fork-da-disciplina
git checkout -b entregas/aula-15/SEU-RA
mkdir -p entregas/aula-15/SEU-RA
# Crie o arquivo entrega.md (modelo na seção Informações de Entrega)
git add entregas/aula-15/SEU-RA/entrega.md
git commit -m "feat(aula-15): entrega final - SEU NOME (RA: SEU-RA)"
git push -u origin entregas/aula-15/SEU-RA
```

Abra o Pull Request no GitHub com:
- **Título:** `[Aula 15] RA: SEU-RA - SEU NOME`
- **Base:** `main`
- **Compare:** `entregas/aula-15/SEU-RA`

---

## Dicas

- Comece pelo `README.md` da jornada — ele dá o fio condutor da apresentação
- Teste a demo inteira **antes** da aula e cronometre; grave um vídeo de backup
- Confirme a sessão do Learner Lab ativa e a região `us-east-1` se a demo usar AWS
- Não aceite repositório privado nem fork — o portfólio deve ser **seu** e **público**
- Honestidade acima de completude: um portfólio real e bem documentado vale mais que conteúdo copiado
- Trate o portfólio como projeto profissional — recrutadores olham o seu GitHub

---

## Encerramento do Curso

Com a entrega e a apresentação deste portfólio, você fecha a jornada da disciplina de DevOps. Em 15 encontros, saiu do versionamento com Git e da containerização com Docker, atravessou a infraestrutura como código na AWS com Terraform, montou pipelines de CI/CD com GitHub Actions e **Amazon ECR**, dominou estratégias de deploy com zero downtime (Blue/Green e Canary), rollback e AIOps, e integrou **inteligência artificial** ao ciclo DevOps — da geração de IaC ao agente autônomo com AWS Bedrock. O resultado não é uma nota: é uma plataforma completa, documentada e funcional, que comprova sua capacidade de **projetar, implementar e operar** entrega contínua de software de ponta a ponta.

> **💡 Guarde e evolua seu portfólio.** DevOps não é um destino, é prática contínua de
> melhoria. Mantenha o repositório vivo, continue estudando (certificações, novas
> ferramentas) e use este trabalho como o primeiro item do seu currículo DevOps.

*Parabéns por chegar até aqui. Missão cumprida.* 🎓
