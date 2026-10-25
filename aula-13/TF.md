# Trabalho de Fixação (TF) — Aula 13: Novo Microserviço com Pipeline End-to-End

## Desafio

Entregar o microserviço `technova-notifications` completo com um **pipeline end-to-end** funcional, demonstrando autonomia na aplicação de todas as práticas DevOps do curso: código com testes, container, CI publicando no **Amazon ECR**, infraestrutura com Terraform no **Learner Lab**, deploy automatizado, integração inter-serviço e validação E2E. Publique via Pull Request no repositório da disciplina.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | 1 semana a partir da data da aula |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork** | `entregas/aula-13/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com link do repositório + evidências |
| **Arquivos do projeto** | No repositório `unifaat-devops-portfolio`, pasta `aula-13/` |

### Como Entregar via Pull Request

1. Faça um **fork** do repositório da disciplina (se ainda não fez)
2. Clone o seu fork localmente
3. Crie a pasta `entregas/aula-13/SEU-RA/`
4. Adicione **apenas** o arquivo `entrega.md` (modelo abaixo) — os arquivos do projeto ficam no `unifaat-devops-portfolio`
5. Faça commit e push para o seu fork
6. Abra um **Pull Request** para o repositório original

**Modelo do arquivo `entrega.md`:**

```markdown
# Entrega — Aula 13: Novo Microserviço com Pipeline End-to-End

**Aluno:** [Seu nome completo]
**RA:** [Seu RA]
**Data:** [Data da entrega]

## Repositório

- URL: https://github.com/SEU-USUARIO/unifaat-devops-portfolio

## Evidências

- [ ] Microserviço `technova-notifications` com rotas e testes passando
- [ ] Dockerfile multi-stage (non-root + HEALTHCHECK)
- [ ] Pipeline CI (lint → test → build → push) publicando no **Amazon ECR**
- [ ] Imagem versionada no console do Amazon ECR (`us-east-1`)
- [ ] Terraform (EC2 + Security Group + `LabInstanceProfile`) com `terraform validate` OK
- [ ] Pipeline CD com deploy + health check
- [ ] Integração HTTP technova-api → technova-notifications
- [ ] Teste E2E validando o fluxo order → notification
- [ ] Screenshots (CI verde, console ECR com a imagem, health check, E2E passando)

## Evidência do Pipeline Rodando

[Cole aqui o link da execução ou screenshots]
```

---

## Exercício: Microserviço `technova-notifications` com Pipeline E2E

### Contexto

O CTO Carlos Mendes quer um serviço de notificações que **nasça certo**: com qualidade desde o primeiro commit, pipeline completo e deploy automatizado. Você tem autonomia total, mas o serviço precisa seguir os padrões da empresa — e usar o **Amazon ECR** no **AWS Academy Learner Lab**.

> **☁️ Learner Lab:** você vai usar as credenciais temporárias da sessão (com `aws_session_token`), sempre na região `us-east-1`. O Lab **permite criar repositórios ECR** e usar as roles pré-existentes `LabRole`/`LabInstanceProfile`, mas **não permite criar usuários/grupos/roles IAM**. Rode `terraform destroy` ao final da sessão.

### Requisitos

#### 1. Microserviço funcional com testes (25%)

- Serviço Node.js/Express na porta `3001` com as rotas: `POST /notifications/send` (com validação), `GET /notifications`, `GET /notifications/:orderId` e `GET /health`
- Testes unitários com Jest + Supertest (mínimo 5 testes passando, cobertura > 80%)
- ESLint configurado e sem erros
- `package.json` com scripts `start`, `test`, `lint`

#### 2. Containerização (15%)

- Dockerfile **multi-stage** (pelo menos 2 estágios)
- Usuário **não-root** no container
- `HEALTHCHECK` configurado
- `.dockerignore` adequado
- `docker-compose.yml` para execução local

#### 3. Pipeline CI com push para o Amazon ECR (20%)

- Workflow GitHub Actions com jobs encadeados: `lint → test → build-and-push`
- Login no ECR via `aws-actions/configure-aws-credentials@v4` (com `aws-session-token`) + `aws-actions/amazon-ecr-login@v2`
- Build e push da imagem com tagging (SHA + latest) para `<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/technova-notifications`
- Trigger em push e PR para as branches corretas

#### 4. Infraestrutura Terraform + CD (25%)

- Terraform com **EC2 + Security Group + `LabInstanceProfile`** (para o `docker pull` do ECR)
- `variables.tf` com validações e `outputs.tf` com IP/URL/health check URL
- `terraform validate` passando
- Pipeline CD com deploy automatizado e **health check pós-deploy**

#### 5. Integração + E2E (15%)

- Comunicação HTTP `technova-api → technova-notifications` com resiliência (o pedido não falha se a notificação falhar)
- `docker-compose.multi.yml` com os dois serviços
- Teste **E2E** validando o fluxo `order → notification`
- Script de execução E2E

**Screenshots obrigatórios:**
- Pipeline CI verde (aba Actions do GitHub)
- Imagem `technova-notifications` no console do **Amazon ECR** com as tags
- Health check respondendo (terminal com `curl`)
- Testes E2E passando (output do Jest)

---

## Estrutura de Entrega

```
entregas/aula-13/RA/   (apenas o entrega.md; o projeto fica no portfólio)

unifaat-devops-portfolio/aula-13/
├── technova-notifications/
│   ├── src/
│   │   ├── server.js
│   │   ├── routes/notifications.js
│   │   └── services/notificationService.js
│   ├── tests/notifications.test.js
│   ├── .eslintrc.json
│   ├── .dockerignore
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── package.json
│   └── package-lock.json
├── .github/workflows/
│   ├── notifications-ci.yml       # lint → test → build & push (Amazon ECR)
│   └── notifications-cd.yml       # deploy + health check
├── terraform/notifications/
│   ├── main.tf                    # EC2 + SG + LabInstanceProfile
│   ├── variables.tf
│   ├── outputs.tf
│   └── userdata.sh
├── tests/e2e/order-notification-flow.test.js
├── docker-compose.multi.yml
├── scripts/run-e2e.sh
└── evidencias/
    ├── ci-pipeline-success.png
    ├── ecr-console.png
    ├── health-check-response.png
    └── e2e-tests-passing.png
```

> **📁 Na pasta de entrega do fork (`entregas/aula-13/RA/`) vai _somente_ o `entrega.md`.** Todo o microserviço, workflows, Terraform e as evidências ficam no seu repositório de portfólio (`unifaat-devops-portfolio/aula-13/`). PRs que alterem arquivos fora da sua pasta de entrega são bloqueados automaticamente.

---

## Critérios de Avaliação

| Critério | Peso | Descrição |
|----------|:----:|-----------|
| Microserviço funcional | 15% | Rotas respondem corretamente, com validação |
| Testes unitários | 10% | Jest + Supertest, ≥ 5 testes, cobertura > 80% |
| Containerização | 15% | Multi-stage, non-root, HEALTHCHECK, `.dockerignore` |
| Pipeline CI (push ECR) | 20% | Jobs encadeados; login ECR com session token; imagem publicada |
| Infraestrutura Terraform | 15% | EC2 + SG + `LabInstanceProfile`; `terraform validate` OK |
| Deploy automatizado (CD) | 10% | Deploy + health check pós-deploy |
| Integração + E2E | 10% | Comunicação resiliente + teste E2E do fluxo completo |
| Screenshots | 5% | 4 evidências comprovando funcionamento |

---

## Critérios de Excelência (Bônus)

Para nota acima da média, implemente adicionalmente:

- [ ] Lifecycle policy no ECR (expira imagens `untagged` ou mantém só as N mais recentes)
- [ ] Scan de vulnerabilidades do ECR habilitado (`scan on push`) e evidência do resultado
- [ ] Promoção `staging → production` com aprovação manual (environments do GitHub)
- [ ] Rate limiting na API de notificações
- [ ] Logging estruturado (JSON com request ID)
- [ ] Documentação Swagger/OpenAPI da API
- [ ] Mais de 8 testes unitários cobrindo casos de borda

---

## Entrega

### 1 — Publicar no portfólio

Os arquivos do projeto ficam no seu `unifaat-devops-portfolio`, pasta `aula-13/`:

```bash
cd unifaat-devops-portfolio
git checkout -b feature/aula-13-notifications-e2e
mkdir -p aula-13/technova-notifications
mkdir -p aula-13/.github/workflows
mkdir -p aula-13/terraform/notifications
mkdir -p aula-13/tests/e2e aula-13/scripts aula-13/evidencias
# copie os arquivos do seu projeto para aula-13/
git add aula-13/
git commit -m "feat(aula-13): microserviço notifications com pipeline E2E e Amazon ECR"
git checkout main
git merge feature/aula-13-notifications-e2e
git push origin main
git push origin feature/aula-13-notifications-e2e
```

### 2 — Registrar entrega no fork da disciplina

```bash
cd /caminho/para/seu-fork-da-disciplina
git checkout -b entregas/aula-13/SEU-RA
mkdir -p entregas/aula-13/SEU-RA
# Crie o arquivo entrega.md (modelo na seção Informações de Entrega)
git add entregas/aula-13/SEU-RA/entrega.md
git commit -m "feat(aula-13): entrega TF - SEU NOME (RA: SEU-RA)"
git push -u origin entregas/aula-13/SEU-RA
```

Abra o Pull Request no GitHub com:
- **Título:** `[Aula 13] RA: SEU-RA - SEU NOME`
- **Base:** `main`
- **Compare:** `entregas/aula-13/SEU-RA`

---

## Dicas

- Comece pelo microserviço funcionando com testes — é a base para tudo
- Teste localmente (`npm run lint && npm test`) antes de cada push para evitar ciclos de CI falhando
- Para o push no ECR, crie o repositório antes (`aws ecr create-repository --repository-name technova-notifications --region us-east-1`)
- Se o push falhar com `denied` / `token has expired`, suas credenciais do Lab expiraram — reabra o Learner Lab e atualize os secrets `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` e `AWS_SESSION_TOKEN`
- Confirme sempre a região `us-east-1` e o Account ID correto no URI do ECR
- Faça commits pequenos e frequentes (facilita debug e demonstra progresso)
- Entrega parcial é melhor que não entregar — vá o mais longe possível na esteira

---

## Conexão com Próximas Aulas

O microserviço e o pipeline que você constrói aqui são a base do **Projeto Integrador**:
- A Aula 14 adiciona uma camada de IA ao ecossistema, reutilizando o padrão de serviço independente e pipeline que você montou aqui
- A imagem publicada no Amazon ECR e a infra no Learner Lab seguem como referência para as entregas seguintes
- A Aula 15 encerra o curso consolidando tudo em uma entrega final

> **💡 Guarde seu pipeline funcionando** — ele será reutilizado e expandido nas próximas aulas.
