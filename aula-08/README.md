# Aula 08 — GitHub Actions: CI Completo com Secrets

## Objetivos de Aprendizagem

Ao final desta aula, o aluno será capaz de:

1. Compreender CI/CD e a arquitetura do GitHub Actions (workflows, jobs, steps, runners)
2. Criar workflows YAML com triggers (push, pull_request, workflow_dispatch)
3. Utilizar actions do marketplace (checkout, setup-node)
4. Configurar ESLint para análise estática e Jest para testes unitários
5. Estruturar pipeline multi-estágio com dependências (lint→test→build)
6. Gerenciar artifacts e adicionar status badges
7. Configurar GitHub Secrets e referenciar com `${{ secrets.NAME }}`
8. Implementar environments com protection rules para credenciais sensíveis

---

## Contexto Narrativo

> **O Resgate da TechNova — Episódio 8: "O Pipeline que Pega Tudo"**

Na última reunião de sprint, o time da TechNova celebrava a infraestrutura automatizada com Terraform. Mas Rafael tinha uma confissão a fazer:

> "Pessoal, o deploy ainda é manual. São 32 minutos. SSH no servidor, git pull, npm install, restart... e ontem eu esqueci de rodar os testes antes. Um bug foi para produção."

Marina, a consultora, verificou os logs e encontrou algo pior:

> "Rafael, olha esse commit de três semanas atrás. Alguém commitou as credenciais AWS no código. O `.env` com `AWS_ACCESS_KEY_ID` foi para o repositório público por 4 horas antes de alguém perceber."

O CTO Carlos Mendes empalideceu:

> "Então temos três problemas: deploy manual e demorado, nenhuma verificação automática de qualidade, e credenciais expostas no código. Preciso de uma solução completa. Já."

Marina sorriu — era exatamente para isso que existia CI/CD:

> "Vamos resolver tudo de uma vez. Primeiro, um pipeline que **automaticamente** verifica lint, roda testes e builda a aplicação em cada push. Segundo, um sistema de **secrets** que nunca permite credenciais no código. Terceiro, **environments** com aprovação para garantir que ninguém faça deploy direto em produção sem review. O GitHub Actions resolve os três."

Esse é o desafio desta aula: construir um pipeline CI completo que **pega tudo** — erros de lint, testes falhando, builds quebrados — antes que cheguem à produção, e proteger as credenciais com o sistema de secrets do GitHub.

---

## Cronograma da Aula

| Bloco | Atividade |
|:-----:|-----------|
| 1 | Revisão TA + Discussão |
| 2 | Conteúdo Teórico — GitHub Actions + CI |
| 3 | Laboratório Parte 1 — Workflow CI Completo |
| 4 | Conteúdo Teórico — Secrets e Environments |
| 5 | Laboratório Parte 2 — Secrets + Advanced CI |
| 6 | Encerramento + Orientação TF |

---

---

## Pré-requisitos

- **Conta GitHub** ativa
- **Node.js** instalado (≥ 18) — [Download](https://nodejs.org/)
- **npm** instalado (vem com Node.js)
- **Git** configurado com autenticação no GitHub (SSH ou HTTPS token)
- **Kiro** instalado e funcional
- **Repositório `unifaat-devops-portfolio`** no GitHub com aplicação Express básica (criada no Módulo 1)
- **Conhecimentos das Aulas 01-07:** Git, Docker, Docker Compose, Kiro, Terraform (modules, remote state), IAM, VPC, EC2, RDS, IA para IaC

> **GitHub Actions é gratuito para repositórios públicos** — minutos ilimitados. Todos os labs desta aula podem ser feitos em repositórios públicos sem custo algum.

---

## Entrega do Trabalho em Aula

O trabalho em aula vale **1 ponto na nota final** do semestre (contabilizado apenas ao final, com todos os trabalhos entregues).

### Onde entregar

No fork da disciplina: `entregas/aula-08/SEU-RA/trabalho-em-aula.md`

### Observações

- Entrega **individual**, mesmo que a atividade seja em grupo
- Pode ser adicionada no **mesmo PR** do TF ou em PR separado
- Entregas parciais **não garantem o ponto**

---

## Entrega do Trabalho de Fixação (TF)

O TF deve ser desenvolvido no **seu repositório pessoal** (`unifaat-devops-portfolio`, pasta `aula-08/`). No fork da disciplina entregue apenas o **`entrega.md`** com o link do repositório + evidências.

### Passo a Passo

1. Desenvolva o TF no seu repositório pessoal (`unifaat-devops-portfolio/aula-08/`)
2. Faça **fork** do repositório da disciplina (se ainda não fez)
3. Crie a branch `SEU-RA/tf-08` e a pasta `entregas/aula-08/SEU-RA/`
4. Adicione **apenas** o `entrega.md` — o código fica no portfólio
5. Faça commit, push e abra um **Pull Request** com título: `[Aula 08] RA: XXXXX - Nome Completo`

Para detalhes completos, consulte [`TF.md`](TF.md).

---

## Conteúdo Teórico — Parte 1: GitHub Actions e CI


### 1. O que é CI/CD?

CI/CD é um conjunto de práticas que automatizam o ciclo de vida do software:

![CI/CD](img/rdCICD.png)

**O problema da TechNova SEM CI:**

![Fluxo Manual](img/rdFluxoGitMAnual.png)

**Com CI (o que vamos construir):**

```
Developer faz commit → Push/PR → GitHub Actions executa automaticamente:
                                    │
                                    ├── ESLint verifica código ✅/❌
                                    ├── Jest roda testes ✅/❌
                                    ├── Docker build verifica ✅/❌
                                    └── Se TUDO passar → pronto para deploy
                                        Se ALGO falhar → PR bloqueado, dev notificado
```

### 2. GitHub Actions — Arquitetura

O GitHub Actions é a plataforma de CI/CD nativa do GitHub. A arquitetura se organiza em:

![WorkFlow Git Action](img/rdWorkLow.png)

**Glossário:**

| Componente | O que é | Analogia |
|-----------|---------|---------|
| **Workflow** | Arquivo YAML que define a automação | A "receita" completa |
| **Event/Trigger** | O que dispara o workflow | O "gatilho" (push, PR) |
| **Job** | Conjunto de steps que rodam no mesmo runner | Uma "etapa" do processo |
| **Step** | Uma ação individual dentro do job | Um "comando" específico |
| **Runner** | Máquina virtual que executa os jobs | O "servidor" temporário |
| **Action** | Componente reutilizável do marketplace | Uma "ferramenta" pronta |

### 3. Sintaxe YAML de Workflows

Um workflow GitHub Actions é um arquivo YAML em `.github/workflows/`:

```yaml
# .github/workflows/ci.yml
name: CI Pipeline                    # Nome exibido na UI do GitHub

on:                                   # Eventos que disparam o workflow
  push:
    branches: [main, develop]         # Dispara em push para main ou develop
  pull_request:
    branches: [main]                  # Dispara em PRs que targeteiam main
  workflow_dispatch:                   # Permite execução manual na UI

jobs:                                 # Define os jobs do workflow
  lint:                               # Nome do job
    runs-on: ubuntu-latest            # Sistema operacional do runner
    steps:                            # Lista de steps do job
      - name: Checkout do código      # Nome descritivo do step
        uses: actions/checkout@v4     # Action do marketplace

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:                         # Parâmetros para a action
          node-version: '20'

      - name: Instalar dependências
        run: npm ci                   # Comando shell

      - name: Executar ESLint
        run: npm run lint             # Se falhar, job falha
```

**Elementos-chave do YAML:**

| Elemento | Função | Exemplo |
|----------|--------|---------|
| `name` | Nome do workflow/step | `name: CI Pipeline` |
| `on` | Triggers (eventos) | `on: push, pull_request` |
| `jobs` | Container de jobs | `jobs: lint: ...` |
| `runs-on` | OS do runner | `runs-on: ubuntu-latest` |
| `steps` | Lista de ações | `steps: - name: ...` |
| `uses` | Action do marketplace | `uses: actions/checkout@v4` |
| `run` | Comando shell | `run: npm test` |
| `with` | Parâmetros da action | `with: node-version: '20'` |
| `needs` | Dependência entre jobs | `needs: [lint, test]` |
| `if` | Execução condicional | `if: github.event_name == 'push'` |

### 4. Triggers (Eventos)

Os eventos mais comuns que disparam workflows:

```yaml
on:
  # Push para branches específicas
  push:
    branches: [main, develop]
    paths:                          # Só dispara se esses arquivos mudarem
      - 'src/**'
      - 'package.json'

  # Pull Requests
  pull_request:
    branches: [main]
    types: [opened, synchronize, reopened]

  # Execução manual (botão na UI)
  workflow_dispatch:
    inputs:
      environment:
        description: 'Ambiente alvo'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

  # Agendamento (cron)
  schedule:
    - cron: '0 6 * * 1'            # Toda segunda às 06:00 UTC
```

### 5. Actions do Marketplace

Actions são componentes reutilizáveis criados pela comunidade. As mais usadas:

| Action | Função | Uso |
|--------|--------|-----|
| `actions/checkout@v4` | Clona o repositório | Primeiro step de quase todo job |
| `actions/setup-node@v4` | Instala Node.js | Projetos JavaScript/TypeScript |
| `actions/cache@v4` | Cache de dependências | Acelera builds (node_modules) |
| `actions/upload-artifact@v4` | Salva arquivos entre jobs | Coverage reports, builds |
| `actions/download-artifact@v4` | Recupera artifacts | Usar build de outro job |
| `docker/build-push-action@v5` | Build/push Docker | CI com containers |

### 6. Multi-Stage Pipeline com `needs`

A keyword `needs` cria dependências entre jobs:

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run lint

  test:
    needs: lint                      # Só roda SE lint passar
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm test

  build:
    needs: [lint, test]              # Só roda SE lint E test passarem
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: docker build -t technova-api .
```

**Visualização do pipeline:**

![GitAction](img/rdPipeLineAction.png)

### 7. ESLint — Análise Estática de Código

ESLint verifica qualidade e consistência do código JavaScript/Node.js:

```json
// .eslintrc.json
{
  "env": {
    "node": true,
    "es2021": true,
    "jest": true
  },
  "extends": "eslint:recommended",
  "parserOptions": {
    "ecmaVersion": "latest"
  },
  "rules": {
    "no-unused-vars": "warn",
    "no-console": "off",
    "semi": ["error", "always"],
    "quotes": ["error", "single"]
  }
}
```

**O que ESLint pega:**
- Variáveis não utilizadas
- Imports desnecessários
- Erros de sintaxe
- Padrões inconsistentes (aspas, ponto-e-vírgula)
- Possíveis bugs (comparações com ==)

### 8. Jest — Testes Unitários

Jest é o framework de testes padrão para Node.js:

```javascript
// __tests__/server.test.js
const request = require('supertest');
const app = require('../server');

describe('GET /health', () => {
  it('deve retornar status 200', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
  });

  it('deve retornar status ok', async () => {
    const res = await request(app).get('/health');
    expect(res.body.status).toBe('ok');
  });
});

describe('GET /api/orders', () => {
  it('deve retornar array de orders', async () => {
    const res = await request(app).get('/api/orders');
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });
});
```

### 9. Artifacts e Status Badges

**Artifacts** permitem salvar arquivos entre jobs ou após a execução:

```yaml
- name: Upload coverage report
  uses: actions/upload-artifact@v4
  with:
    name: coverage-report
    path: coverage/
    retention-days: 30
```

**Status Badges** mostram o estado do pipeline no README:

```markdown
![CI](https://github.com/SEU-USUARIO/unifaat-devops-portfolio/actions/workflows/ci.yml/badge.svg)
```

---

## Conteúdo Teórico — Parte 2: Secrets e Environments


### 1. O Problema: Credenciais no Código

O cenário da TechNova é mais comum do que parece:

![Problema Chave](img/rdErroSecret.png)

### 2. GitHub Secrets — A Solução

GitHub Secrets são variáveis criptografadas armazenadas no GitHub:

![Secrets](img/rdSecrets.png)
### 3. Referenciando Secrets no Workflow

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Configurar AWS CLI
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_DEFAULT_REGION: ${{ secrets.AWS_REGION }}
        run: |
          aws sts get-caller-identity
```

**Regras de segurança dos secrets:**
- Secrets são **mascarados** nos logs (aparecem como `***`)
- Secrets **não são passados** para workflows de forks (segurança em PRs de terceiros)
- Secrets podem ter até **48 KB** de tamanho
- Secrets **não são visíveis** após criados (apenas atualizáveis ou deletáveis)

### 4. GITHUB_TOKEN — Token Automático

Todo workflow recebe automaticamente um `GITHUB_TOKEN` para interagir com a API do GitHub:

```yaml
steps:
  - name: Comentar no PR
    uses: actions/github-script@v7
    with:
      github-token: ${{ secrets.GITHUB_TOKEN }}
      script: |
        github.rest.issues.createComment({
          issue_number: context.issue.number,
          owner: context.repo.owner,
          repo: context.repo.repo,
          body: '✅ CI passou! Pipeline verde.'
        })
```

**Permissões do GITHUB_TOKEN:**
- Ler/escrever issues e PRs
- Ler conteúdo do repositório
- Publicar packages
- Criar releases
- NÃO pode: acessar outros repositórios, criar novos repos

### 5. Environments com Protection Rules

Environments permitem separar configurações por estágio (staging, production):

```yaml
jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging              # Usa secrets e config de staging
    steps:
      - run: echo "Deploying to staging..."

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production           # Requer aprovação antes de executar
    steps:
      - run: echo "Deploying to production..."
```

**Protection Rules disponíveis:**
- **Required reviewers:** Alguém precisa aprovar antes do job executar
- **Wait timer:** Delay obrigatório antes da execução (ex: 30 minutos)
- **Deployment branches:** Só branches específicas podem fazer deploy
- **Environment secrets:** Secrets visíveis apenas naquele environment

![Fluxo com Approval Gate](img/rdFluxoAproval.png) 

### 6. Boas Práticas para Credenciais

| Prática | Por quê |
|---------|---------|
| Nunca commitar secrets no Git | Bots escaneiam repos em segundos |
| Usar `.gitignore` para `.env` | Previne commits acidentais |
| Rotacionar secrets regularmente | Minimiza impacto de vazamento |
| Princípio de menor privilégio | Secret só tem acesso ao necessário |
| Nunca logar secrets (echo, print) | Mesmo mascarados, evite imprimir |
| Usar environment secrets para prod | Adiciona camada de aprovação |
| Auditar uso de secrets | Saber quem/quando usou |

---

## Resumo dos Conceitos

| Conceito | Descrição |
|----------|-----------|
| CI (Continuous Integration) | Integrar e verificar código automaticamente em cada push |
| GitHub Actions | Plataforma de CI/CD nativa do GitHub |
| Workflow | Arquivo YAML que define automação (.github/workflows/) |
| Job | Conjunto de steps executados no mesmo runner |
| Step | Ação individual (uses action ou run comando) |
| Runner | VM que executa os jobs (ubuntu-latest) |
| Trigger | Evento que dispara o workflow (push, PR, manual) |
| Action | Componente reutilizável do marketplace |
| `needs` | Dependência entre jobs (lint→test→build) |
| ESLint | Ferramenta de análise estática para JavaScript |
| Jest | Framework de testes unitários para Node.js |
| Artifact | Arquivo salvo entre jobs/execuções |
| Status Badge | Indicador visual do estado do pipeline |
| GitHub Secrets | Variáveis criptografadas no repositório |
| `${{ secrets.NAME }}` | Sintaxe para referenciar secrets |
| GITHUB_TOKEN | Token automático para API do GitHub |
| Environment | Contexto com secrets e protection rules |
| Approval Gate | Aprovação obrigatória antes de executar |

---

## Custo — GitHub Actions

| Tipo de Repositório | Minutos/Mês |
|:-------------------:|:-----------:|
| **Público** | **Ilimitado (gratuito)** |
| Privado (Free plan) | 2.000/mês |

> Todos os labs desta aula usam repositórios públicos — sem custo algum.

---

*Próximas etapas: Laboratório Parte 1 (CI Pipeline Completo) → Laboratório Parte 2 (Secrets + Advanced CI) → TF (Trabalho de Fixação)*
