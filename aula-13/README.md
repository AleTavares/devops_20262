# Aula 13 — Novo Microserviço com Pipeline End-to-End

## O Resgate da TechNova — Episódio 13: "Um Novo Serviço Nasce Certo"

### Contextualização Narrativa

A TechNova evoluiu. O monolito foi domado, a infraestrutura automatizada, o CI/CD consolidado, e a equipe ganhou maturidade. Agora chega o momento decisivo: **criar um serviço completamente novo, do zero, aplicando todas as práticas aprendidas desde o primeiro dia**.

O CTO Carlos Mendes reúne a equipe: *"Precisamos de um serviço de notificações. Mas dessa vez, não quero gambiarras. Quero que nasça certo — com testes, container, pipeline, infraestrutura como código, deploy automatizado e comunicação com o serviço principal. Vocês têm autonomia total."*

Rafael e Marina trocam um olhar: é o episódio onde a equipe deixa de ser guiada e passa a **demonstrar domínio**. Tudo que foi construído nos módulos anteriores será aplicado de forma independente para criar o `technova-notifications` — um microserviço completo com pipeline end-to-end, publicando a imagem no **Amazon ECR** e rodando no **AWS Academy Learner Lab**.

---

### Informações da Aula

| Item | Detalhe |
|------|---------|
| **Aula** | 13 |
| **Tipo** | Aula-Projeto (autonomia do aluno) |
| **Pré-requisitos** | Aulas anteriores (Git, Docker, CI/CD, Terraform, ECR) |
| **Ferramentas** | Git, Node.js, Docker, GitHub Actions, Terraform, AWS (Learner Lab) |

---

### Objetivos de Aprendizagem

Ao final desta aula, o aluno será capaz de:

1. **Aplicar princípios de microserviços** para decompor responsabilidades e criar serviços independentes com escopo bem definido
2. **Criar um microserviço do zero** com Express.js, incluindo estrutura de projeto, rotas, testes unitários e linting
3. **Containerizar o serviço** com Dockerfile otimizado seguindo boas práticas (multi-stage, non-root, health check)
4. **Implementar pipeline CI completa** no GitHub Actions com etapas de lint, teste, build e push de imagem para o **Amazon ECR**
5. **Provisionar infraestrutura** com Terraform para o novo serviço (EC2, Security Groups, outputs) no Learner Lab
6. **Automatizar o deploy** com pipeline CD incluindo health check e rollback
7. **Integrar microserviços** via HTTP com comunicação síncrona entre technova-api e technova-notifications
8. **Validar o fluxo end-to-end** com testes que verificam a cadeia completa: criar pedido → disparar notificação → confirmar entrega

---

### Estrutura da Aula

#### Parte 1 — Microserviço + CI

| Atividade | Descrição |
|-----------|-----------|
| Abertura e Contexto | Narrativa, princípios de microserviços, escopo do technova-notifications |
| Arquitetura | Separação de responsabilidades, contrato de API, comunicação inter-serviços |
| Lab Parte 1A | Criar o microserviço: projeto, rotas, testes, lint |
| Lab Parte 1B | Containerização: Dockerfile, docker-compose, teste local |
| Lab Parte 1C | Pipeline CI: GitHub Actions lint→test→build→push para o Amazon ECR |

#### Parte 2 — CD + Integração E2E

| Atividade | Descrição |
|-----------|-----------|
| Contexto CD | Pipeline unificada, promoção de ambientes, estratégia de deploy |
| Lab Parte 2A | Terraform: infraestrutura para notifications (EC2, SG, outputs) |
| Lab Parte 2B | Deploy automatizado + comunicação inter-serviço |
| Lab Parte 2C | Testes E2E: fluxo completo order→notification→validate |
| Encerramento | Revisão, próximos passos, checklist de entrega |

---

### Conceitos-Chave

#### Princípios de Microserviços

- **Responsabilidade única**: cada serviço faz uma coisa bem feita
- **Independência de deploy**: serviços podem ser atualizados sem afetar outros
- **Comunicação via contrato**: APIs bem definidas entre serviços
- **Banco de dados próprio**: cada serviço gerencia seus dados (nesta aula, simplificado com in-memory)
- **Observabilidade**: cada serviço expõe health check e logs estruturados

#### technova-notifications — Escopo

O serviço de notificações:
- Recebe requisições HTTP POST com dados de pedido
- Registra a notificação (simula envio de email/SMS)
- Expõe endpoint GET para consultar notificações enviadas
- Possui health check próprio
- É independente do technova-api mas se comunica com ele

#### Pipeline End-to-End

```
[Push] → [Lint] → [Test] → [Build Docker] → [Push Amazon ECR] → [Terraform Apply] → [Deploy] → [Health Check] → [E2E Test]
```

A pipeline completa cobre desde o commit até a validação em produção, demonstrando a maturidade DevOps da equipe. A imagem é publicada no **Amazon ECR** (o registry oficial do curso) e consumida pela infraestrutura provisionada no **Learner Lab**.

---

### Arquitetura da Solução

```
┌─────────────────┐         HTTP POST          ┌──────────────────────┐
│  technova-api   │ ───────────────────────────▶│ technova-notifications│
│  (Port 3000)    │    /notifications/send      │   (Port 3001)        │
└─────────────────┘                             └──────────────────────┘
        │                                                │
        │ GET /orders                                    │ GET /notifications
        ▼                                                ▼
   [Clientes]                                    [Health: /health]
```

#### Contrato de API — technova-notifications

| Método | Rota | Descrição |
|--------|------|-----------|
| POST | `/notifications/send` | Recebe pedido e registra notificação |
| GET | `/notifications` | Lista notificações enviadas |
| GET | `/notifications/:orderId` | Lista notificações de um pedido específico |
| GET | `/health` | Health check do serviço |

#### Payload — POST /notifications/send

```json
{
  "orderId": "abc-123",
  "customerEmail": "cliente@email.com",
  "type": "order_created",
  "message": "Seu pedido abc-123 foi criado com sucesso"
}
```

---

### Registry e Nuvem desta Aula

Todo o fluxo de imagens usa o **Amazon ECR** e roda no **AWS Academy Learner Lab**:

- A imagem do `technova-notifications` é buildada no CI e publicada em `<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/technova-notifications`
- O deploy (EC2 provisionada por Terraform) faz `docker pull` dessa mesma imagem versionada
- A autenticação usa as credenciais temporárias da sessão do Lab (`aws ecr get-login-password`)

> **☁️ AWS Academy Learner Lab:** as credenciais da sessão incluem `aws_session_token` e **expiram quando o Lab encerra** — recarregue-as ao reabrir. Trabalhe sempre em `us-east-1`. O Lab **não permite criar usuários/grupos/roles IAM**, mas **permite criar repositórios ECR** e usar as roles pré-existentes `LabRole`/`LabInstanceProfile`. Ao final de cada sessão, rode `terraform destroy` para liberar os recursos.

---

### Conexão com Aulas Anteriores

| Tema | Conceito Aplicado |
|------|-------------------|
| Git | Branching, PRs, commits semânticos |
| Docker | Dockerfile multi-stage, compose, registry (Amazon ECR) |
| CI/CD | GitHub Actions, pipelines, automação |
| IaC / Deploy | Terraform, EC2, deploy automatizado no Learner Lab |
| Registry (Aula 09) | Push/pull de imagens versionadas no Amazon ECR |
| Observabilidade | Health checks e logs estruturados |

---

### Entregáveis da Aula

1. **Repositório/pasta** `technova-notifications/` com código completo
2. **Dockerfile** funcional e otimizado
3. **Pipeline CI** (`.github/workflows/notifications-ci.yml`) com push para o Amazon ECR
4. **Terraform** para infraestrutura do serviço (com `LabInstanceProfile`)
5. **Pipeline CD** com deploy e health check
6. **Integração** technova-api → technova-notifications funcionando
7. **Teste E2E** documentado e funcional

> **📁 Onde entregar:** todos esses artefatos ficam no seu repositório de portfólio (`unifaat-devops-portfolio/aula-13/`). Na pasta de entrega do fork da disciplina (`entregas/aula-13/RA/`) vai _somente_ o `entrega.md` com o link e as evidências. Ver detalhes em [`TF.md`](TF.md).

---

### Critérios de Avaliação

| Critério | Peso |
|----------|------|
| Microserviço funcional com testes | 20% |
| Dockerfile seguindo boas práticas | 15% |
| Pipeline CI completa e funcional (push ECR) | 20% |
| Infraestrutura Terraform | 15% |
| Deploy automatizado com health check | 15% |
| Integração inter-serviço + E2E | 15% |

---

### Referências

- [12-Factor App](https://12factor.net/pt_br/)
- [Microservices Patterns — Chris Richardson](https://microservices.io/patterns/)
- [GitHub Actions — Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Amazon ECR — User Guide](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
