# Aula 08 — Materiais Complementares

## Documentação Oficial

### GitHub Actions

| Recurso | Link | Descrição |
|---------|------|-----------|
| Quickstart | [docs.github.com/actions/quickstart](https://docs.github.com/en/actions/quickstart) | Início rápido com primeiro workflow |
| Workflow syntax | [docs.github.com/actions/workflow-syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions) | Referência completa da sintaxe YAML |
| Events that trigger | [docs.github.com/actions/events](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows) | Lista completa de triggers |
| Expressions | [docs.github.com/actions/expressions](https://docs.github.com/en/actions/learn-github-actions/expressions) | Sintaxe `${{ }}` e funções |
| Contexts | [docs.github.com/actions/contexts](https://docs.github.com/en/actions/learn-github-actions/contexts) | github, env, secrets, runner, etc. |

### GitHub Secrets e Environments

| Recurso | Link | Descrição |
|---------|------|-----------|
| Encrypted Secrets | [docs.github.com/actions/secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) | Como criar e usar secrets |
| GITHUB_TOKEN | [docs.github.com/actions/automatic-token](https://docs.github.com/en/actions/security-guides/automatic-token-authentication) | Permissões do token automático |
| Environments | [docs.github.com/actions/environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) | Configurar environments e protection rules |
| Security hardening | [docs.github.com/actions/security-hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions) | Boas práticas de segurança |

### Marketplace Actions (mais usadas)

| Action | Link | Uso |
|--------|------|-----|
| actions/checkout | [github.com/actions/checkout](https://github.com/actions/checkout) | Clonar repositório |
| actions/setup-node | [github.com/actions/setup-node](https://github.com/actions/setup-node) | Configurar Node.js |
| actions/cache | [github.com/actions/cache](https://github.com/actions/cache) | Cache de dependências |
| actions/upload-artifact | [github.com/actions/upload-artifact](https://github.com/actions/upload-artifact) | Salvar artifacts |
| actions/github-script | [github.com/actions/github-script](https://github.com/actions/github-script) | Executar scripts com API do GitHub |
| docker/build-push-action | [github.com/docker/build-push-action](https://github.com/docker/build-push-action) | Build e push de imagens Docker |

---

## ESLint

| Recurso | Link | Descrição |
|---------|------|-----------|
| Getting Started | [eslint.org/docs/user-guide/getting-started](https://eslint.org/docs/latest/use/getting-started) | Início rápido |
| Rules Reference | [eslint.org/docs/rules](https://eslint.org/docs/latest/rules/) | Lista completa de regras |
| Configuration | [eslint.org/docs/user-guide/configuring](https://eslint.org/docs/latest/use/configure/) | Como configurar ESLint |
| Integração com GitHub Actions | [eslint.org CI setup](https://eslint.org/docs/latest/use/command-line-interface) | ESLint no CI |

---

## Jest

| Recurso | Link | Descrição |
|---------|------|-----------|
| Getting Started | [jestjs.io/docs/getting-started](https://jestjs.io/docs/getting-started) | Primeiro teste |
| Expect API | [jestjs.io/docs/expect](https://jestjs.io/docs/expect) | Matchers disponíveis |
| Testing Express | [jestjs.io + supertest](https://jestjs.io/docs/testing-frameworks) | Testando APIs HTTP |
| Code Coverage | [jestjs.io/docs/configuration#collectcoverage](https://jestjs.io/docs/configuration) | Configurar coverage |
| supertest | [github.com/ladjs/supertest](https://github.com/ladjs/supertest) | HTTP assertions para testes |

---

## Vídeos Recomendados

### Em Português

| Vídeo | Canal | Duração | Tópico |
|-------|-------|---------|--------|
| GitHub Actions — Introdução Completa | Código Fonte TV | ~20 min | Conceitos básicos e primeiro workflow |
| CI/CD com GitHub Actions na prática | Fabio Akita | ~45 min | Pipeline completo com exemplos reais |
| GitHub Actions: do zero ao deploy | LINUXtips | ~30 min | Workflow com Docker e deploy |
| Testes automatizados com Jest | Rocketseat | ~25 min | Jest para Node.js com exemplos |
| ESLint — Configuração completa | Dev Soutinho | ~15 min | Setup ESLint do zero |

### Em Inglês

| Vídeo | Canal | Duração | Tópico |
|-------|-------|---------|--------|
| GitHub Actions Tutorial | TechWorld with Nana | ~60 min | Tutorial completo de Actions |
| CI/CD Pipeline Full Course | freeCodeCamp | ~90 min | Conceitos e prática de CI/CD |
| GitHub Actions Secrets | GitHub Official | ~15 min | Como gerenciar secrets |
| Jest Testing for Beginners | Traversy Media | ~40 min | Jest do básico ao avançado |
| GitHub Actions Security Best Practices | GitHub Universe | ~30 min | Segurança em pipelines |

---

## Artigos e Tutoriais

### CI/CD e GitHub Actions

| Artigo | Fonte | Tópico |
|--------|-------|--------|
| Understanding GitHub Actions | GitHub Docs | Arquitetura e conceitos fundamentais |
| CI/CD Best Practices | GitLab Blog | Práticas recomendadas (aplicáveis a qualquer CI) |
| GitHub Actions: The Full Guide | DevOps Journey | Guia passo a passo completo |
| Automating CI/CD with GitHub Actions | DigitalOcean | Tutorial prático com Node.js |

### Secrets e Segurança

| Artigo | Fonte | Tópico |
|--------|-------|--------|
| Git Secrets: What to do when you commit a secret | GitGuardian Blog | O que fazer após commitar um secret |
| Security Best Practices for GitHub Actions | GitHub Blog | Hardening de workflows |
| Managing secrets in CI/CD | HashiCorp Blog | Patterns para gerenciamento de secrets |
| OWASP Secrets Management Cheat Sheet | OWASP | Referência de boas práticas |

### Testes e Qualidade

| Artigo | Fonte | Tópico |
|--------|-------|--------|
| Testing Express.js APIs with Jest | LogRocket Blog | Tutorial completo Jest + Express |
| ESLint Configuration Guide | DigitalOcean | Configuração detalhada do ESLint |
| Code Coverage Best Practices | Martin Fowler | Quando e como usar coverage |

---

## Ferramentas Complementares

### act — Rodar GitHub Actions Localmente

[github.com/nektos/act](https://github.com/nektos/act)

O `act` permite executar workflows do GitHub Actions na sua máquina local, sem precisar fazer push:

```bash
# Instalar (Linux)
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Executar o workflow padrão
act

# Executar um evento específico
act push

# Executar um job específico
act -j lint

# Listar workflows disponíveis
act -l
```

**Vantagens:**
- Feedback mais rápido (não precisa push + esperar runner)
- Debug local de workflows
- Não consome minutos do GitHub

**Limitações:**
- Nem todas as actions funcionam localmente
- Secrets precisam ser configurados em `.secrets` (local)
- Docker-in-Docker pode ter problemas

### Outras Ferramentas Úteis

| Ferramenta | Link | Função |
|-----------|------|--------|
| act | [nektos/act](https://github.com/nektos/act) | GitHub Actions localmente |
| actionlint | [rhysd/actionlint](https://github.com/rhysd/actionlint) | Linter para workflow YAML |
| gitleaks | [gitleaks/gitleaks](https://github.com/gitleaks/gitleaks) | Detectar secrets no código |
| truffleHog | [trufflesecurity/trufflehog](https://github.com/trufflesecurity/trufflehog) | Scanner de credenciais em repos |
| husky | [typicode/husky](https://github.com/typicode/husky) | Git hooks (lint antes do commit) |
| lint-staged | [lint-staged](https://github.com/lint-staged/lint-staged) | Lint apenas em arquivos staged |

---

## Conexão com Próximas Aulas

| Aula | Tópico | Como se conecta |
|:----:|--------|----------------|
| **Aula 08** (esta) | CI: Lint + Test + Build + Secrets | Fundação do pipeline |
| Aula 09 | CD: Deploy Automatizado | Usar o pipeline desta aula para deploy |
| Aula 10 | Terraform no CI/CD | `terraform plan/apply` no pipeline |
| Aula 11 | Monitoramento | Alertas quando pipeline falha |
| Aula 12 | Projeto Final | Pipeline completo end-to-end |

**O que construímos nesta aula é a BASE de tudo que vem depois:**

```
Aula 08 (CI)
    │
    ├── Aula 09: Adicionar CD (deploy automático após CI passar)
    │
    ├── Aula 10: Adicionar Terraform (infra no pipeline)
    │
    └── Aula 12: Pipeline completo (CI + CD + IaC + Monitoring)
```

---

## Resumo de Comandos

### GitHub Actions (no workflow YAML)

```yaml
# Triggers
on: [push, pull_request, workflow_dispatch]

# Jobs com dependências
needs: [lint, test]

# Secrets
${{ secrets.NAME }}

# Variáveis do GitHub
${{ github.sha }}
${{ github.ref }}
${{ github.event_name }}

# Condicionais
if: github.event_name == 'pull_request'
if: always()    # executa mesmo se job anterior falhar
if: success()   # executa só se anterior passou
if: failure()   # executa só se anterior falhou

# Matrix
strategy:
  matrix:
    node-version: ['18', '20']

# Concurrency
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
```

### ESLint

```bash
# Instalar
npm install --save-dev eslint

# Executar
npx eslint .

# Corrigir automaticamente
npx eslint . --fix

# Verificar arquivo específico
npx eslint server.js
```

### Jest

```bash
# Instalar
npm install --save-dev jest supertest

# Executar testes
npx jest

# Com coverage
npx jest --coverage

# Watch mode (desenvolvimento)
npx jest --watch

# Arquivo específico
npx jest __tests__/server.test.js
```

### Git (fluxo de PR)

```bash
# Criar branch
git checkout -b feature/nome-da-feature

# Commitar
git add .
git commit -m "feat: descrição da mudança"

# Push
git push -u origin feature/nome-da-feature

# Após merge, voltar para main
git checkout main
git pull
git branch -d feature/nome-da-feature
```

---

## Glossário Rápido

| Termo | Definição |
|-------|-----------|
| CI | Continuous Integration — integrar e verificar código automaticamente |
| CD | Continuous Delivery/Deployment — entregar software automaticamente |
| Pipeline | Sequência de etapas automatizadas (lint→test→build→deploy) |
| Workflow | Arquivo YAML que define automação no GitHub Actions |
| Runner | VM que executa os jobs do workflow |
| Artifact | Arquivo salvo entre jobs ou após execução |
| Secret | Variável criptografada armazenada no GitHub |
| Environment | Contexto com secrets e protection rules (staging, production) |
| Approval Gate | Aprovação humana obrigatória antes de executar um job |
| Matrix | Estratégia para rodar mesmo job com múltiplas configurações |
| Badge | Indicador visual do estado do pipeline no README |
| Lint | Análise estática de código (verifica sem executar) |
| Coverage | Porcentagem de código coberta por testes |
| Smoke Test | Teste básico de funcionamento (responde? retorna 200?) |

---

*Bons estudos! Qualquer dúvida, abra uma issue no repositório da disciplina ou pergunte no Discord.*
