# Trabalho de Fixação (TF) — Aula 09: Docker Registry e IA no CI/CD

## Desafio

Consolidar o aprendizado sobre **Docker Registry** e **IA no CI/CD** construindo um pipeline completo que builda, publica e revisa código automaticamente. Publique via Pull Request no repositório da disciplina.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | 1 semana a partir da data da aula |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork** | `entregas/aula-09/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com link do repositório + evidências |
| **Arquivos do projeto** | No repositório `unifaat-devops-portfolio`, pasta `aula-09/` |

### Como Entregar via Pull Request

1. Faça um **fork** do repositório da disciplina (se ainda não fez)
2. Clone o seu fork localmente
3. Crie a pasta `entregas/aula-09/SEU-RA/`
4. Adicione **apenas** o arquivo `entrega.md` (modelo abaixo) — os arquivos do projeto ficam no `unifaat-devops-portfolio`
5. Faça commit e push para o seu fork
6. Abra um **Pull Request** para o repositório original

**Modelo do arquivo `entrega.md`:**

```markdown
# Entrega — Aula 09: Docker Registry e IA no CI/CD

**Aluno:** [Seu nome completo]
**RA:** [Seu RA]
**Data:** [Data da entrega]

## Repositório

- URL: https://github.com/SEU-USUARIO/unifaat-devops-portfolio

## Evidências

- [ ] Script `ecr-push.sh` publicando no **Amazon ECR** com tags (sha, latest, semver)
- [ ] Repositório ECR `technova-api` criado no Learner Lab (`us-east-1`)
- [ ] Pull da imagem a partir do ECR funcionando (rollback por tag)
- [ ] Workflow de AI Review disparando em PRs
- [ ] Quality gate (CRITICAL bloqueia o PR)
- [ ] `ia-cicd-analise.md` preenchido
- [ ] Screenshots (console ECR com as tags, AI review, pipeline verde, gate bloqueando)

## Evidência do Pipeline Rodando

[Cole aqui o link da execução ou screenshots]
```

---

## Exercício: Pipeline Completo com Registry + AI Review

### Contexto

O CTO da TechNova quer o pipeline definitivo: código é verificado (lint, test), a imagem é publicada no **Amazon ECR** (o registry da própria AWS, onde a infra da TechNova já roda), e cada PR é revisado por IA antes de qualquer humano olhar. Implemente esse pipeline completo usando o **AWS Academy Learner Lab**.

> **☁️ Learner Lab:** você vai usar as credenciais temporárias da sessão do Lab (com `aws_session_token`), sempre na região `us-east-1`. O Lab **permite criar repositórios ECR**, mas **não permite criar usuários/grupos/roles IAM** — por isso a autenticação usa as credenciais da sua sessão, não um usuário novo.

### Requisitos

#### 1. Build e Push para o Amazon ECR (40%)

Crie o repositório ECR e um script `ecr-push.sh` (fluxo principal) que:

- Cria/garante o repositório `technova-api` no ECR (`aws ecr create-repository`, idempotente)
- Faz login no ECR: `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com`
- Builda a imagem Docker (multi-stage)
- Faz push com as tags:
  - `sha-XXXXXXX` (SHA curto do commit — rastreável)
  - `latest` (conveniência)
  - Semver (`1.2.3`, `1.2`, `1`) a partir da git tag `v*.*.*`
- Opcional (Parte 7 do lab): workflow `.github/workflows/ci.yml` que faz o mesmo via `aws-actions/configure-aws-credentials@v4` + `aws-actions/amazon-ecr-login@v2`, usando as 3 credenciais temporárias como secrets. Lembre que as credenciais do Lab **expiram a cada sessão**, então o script local é o fluxo confiável.

#### 2. Workflow de AI Review (30%)

Crie `.github/workflows/ai-review.yml` com:

- Trigger em `pull_request` (opened, synchronize, reopened)
- Coleta o diff dos arquivos alterados
- Executa script de análise (`.github/scripts/ai-review.js`)
- Posta comentário no PR com resultado formatado
- Detecta ao menos: secrets hardcoded, eval(), SQL injection, console.log, catch vazio

#### 3. Quality Gate (10%)

- Se achados CRITICAL → workflow falha (`exit 1`) → PR bloqueado
- Se apenas WARNING/INFO → workflow passa → PR pode ser mergeado
- Documentar no `ia-cicd-analise.md` a lógica de decisão

#### 4. Documentação e Evidências (20%)

Crie o arquivo `ia-cicd-analise.md` com:

- Explicação de por que o ECR foi escolhido como registry (vs ghcr.io/Docker Hub) e as restrições do Learner Lab
- Explicação da estratégia de tagging escolhida (e por quê)
- Descrição dos padrões que o AI review verifica
- Prompt/lógica utilizada para a análise
- Quando confiar na IA vs quando exige review humano
- Limitações identificadas (falsos positivos, contexto limitado)

**Screenshots obrigatórios:**
- Repositório `technova-api` no console do Amazon ECR mostrando as tags (sha, latest, semver)
- Comentário do AI review em um PR (com achados detectados)
- Execução do `ecr-push.sh` concluída (ou pipeline CI verde, se fez a Parte 7)
- Quality gate bloqueando um PR com problema CRITICAL

---

## Estrutura de Entrega

```
entregas/aula-09/RA/   (apenas o entrega.md; o projeto fica no portfólio)

unifaat-devops-portfolio/aula-09/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml              # (opcional) CI com push p/ ECR via amazon-ecr-login
│   │   └── ai-review.yml      # AI review em PRs
│   └── scripts/
│       └── ai-review.js        # Script de análise
├── ecr-push.sh                  # Script principal: cria repo, login, build e push no ECR
├── Dockerfile                   # Multi-stage otimizado
├── .dockerignore               # Exclusões para build
├── ia-cicd-analise.md          # Documentação da estratégia
├── screenshots/
│   ├── ecr-console.png         # Repositório no console ECR com as tags
│   ├── ai-review-comment.png  # Comentário de AI review no PR
│   ├── ecr-push-ok.png        # ecr-push.sh concluído (ou CI verde)
│   └── quality-gate-block.png # PR bloqueado por CRITICAL
└── README.md                   # Instruções de como executar/testar
```

> **📁 Na pasta de entrega do fork (`entregas/aula-09/RA/`) vai _somente_ o `entrega.md`.** Todo o código, workflows, script e os screenshots/evidências ficam no seu repositório de portfólio (`unifaat-devops-portfolio/aula-09/`). PRs que alterem arquivos fora da sua pasta de entrega são bloqueados automaticamente.

---

## Critérios de Avaliação

| Critério | Peso | Descrição |
|----------|:----:|-----------|
| Build e push no ECR | 20% | `ecr-push.sh` cria o repo, autentica e publica a imagem no ECR |
| Tagging correto | 10% | SHA + latest sempre, semver a partir de git tags |
| Repositório ECR + pull | 10% | Repo criado no `us-east-1`; pull por tag funciona (rollback) |
| AI Review workflow | 15% | Dispara em PR, analisa diff, detecta problemas |
| Comentário no PR | 10% | Formatado como tabela, categorizado por severidade |
| Quality gate | 5% | CRITICAL bloqueia, WARNING/INFO não |
| Script de análise | 10% | Detecta ao menos 5 padrões diferentes |
| Documentação (`ia-cicd-analise.md`) | 10% | Análise crítica sobre IA no review |
| Screenshots | 5% | 4 screenshots comprovando funcionamento |
| Organização | 5% | Estrutura de arquivos limpa, commits claros |

---

## Critérios de Excelência (Bônus)

Para nota acima da média, implemente adicionalmente:

- [ ] Lifecycle policy no ECR (expira imagens `untagged` ou mantém só as N mais recentes)
- [ ] Scan de vulnerabilidades do ECR habilitado (`scan on push`) e evidência do resultado
- [ ] Comentário atualizado (não duplicado) em novos pushes ao PR
- [ ] Security scan separado (workflow dedicado para segurança)
- [ ] Badge de status no README do projeto
- [ ] Mais de 8 padrões detectados pelo AI review
- [ ] Dockerfile com score A no Docker Scout ou Trivy

---

## Entrega

### 1 — Publicar no portfólio

Os arquivos do projeto ficam no seu `unifaat-devops-portfolio`, pasta `aula-09/`:

```bash
cd unifaat-devops-portfolio
git checkout -b feature/aula-09-ecr-ai-review
mkdir -p aula-09/.github/workflows
mkdir -p aula-09/.github/scripts
mkdir -p aula-09/screenshots
# copie os arquivos do seu projeto para aula-09/ (ecr-push.sh, Dockerfile, workflows...)
git add aula-09/
git commit -m "feat(aula-09): pipeline com Amazon ECR e AI review"
git checkout main
git merge feature/aula-09-registry-ai-review
git push origin main
git push origin feature/aula-09-registry-ai-review
```

### 2 — Registrar entrega no fork da disciplina

```bash
cd /caminho/para/seu-fork-da-disciplina
git checkout -b entregas/aula-09/SEU-RA
mkdir -p entregas/aula-09/SEU-RA
# Crie o arquivo entrega.md (modelo na seção Informações de Entrega)
git add entregas/aula-09/SEU-RA/entrega.md
git commit -m "feat(aula-09): entrega TF - SEU NOME (RA: SEU-RA)"
git push -u origin entregas/aula-09/SEU-RA
```

Abra o Pull Request no GitHub com:
- **Título:** `[Aula 09] RA: SEU-RA - SEU NOME`
- **Base:** `main`
- **Compare:** `entregas/aula-09/SEU-RA`

---

## Dicas

- Comece pelo `ecr-push.sh` (criar repo + login + build + push) — é a base para tudo
- Use o script da Parte 1 do lab como referência direta
- Para o AI review, o script do lab já funciona — adapte para seu projeto
- Faça commits pequenos e frequentes (facilita debug se algo falhar)
- Se o push falhar com `denied` / `token has expired`, suas credenciais do Lab expiraram — reabra o Learner Lab e recarregue as credenciais da sessão
- Confirme sempre a região `us-east-1` e o Account ID correto no URI (`<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com`)
- Screenshots: use a extensão de captura do browser ou `Cmd/Ctrl+Shift+S`

---

## Conexão com Próximas Aulas

O pipeline que você constrói aqui será **expandido no Módulo 4**:
- Aula 10+: Estratégias de deploy (Blue-Green, Canary) vão fazer **pull** das imagens que você publicou no ECR
- A imagem no Amazon ECR será deployada em EC2/ECS — o mesmo ecossistema AWS do Learner Lab
- O AI review será refinado com mais padrões e integração com Bedrock

> **💡 Guarde seu pipeline funcionando** — ele será pré-requisito para as próximas aulas.
