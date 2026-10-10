# Aula 09 — Trabalho Anterior (TA)

## Objetivo

Preparar-se para a Aula 09 através de leitura prévia sobre **Docker Registry** e **IA no CI/CD**. Você vai aprender a publicar imagens Docker automaticamente e como integrar inteligência artificial em pipelines para review automatizado de código.

---

## Parte 1 — Docker Registry (~35 min)

### 1.1 O Problema: Imagens Presas no Laptop

Até agora, nossas imagens Docker existem apenas localmente — no laptop do desenvolvedor ou no runner do CI. Isso gera problemas sérios:

- **Não reproduzível:** cada `docker build` pode gerar imagem diferente (deps atualizaram)
- **Não versionável:** qual imagem está rodando em produção agora?
- **Não compartilhável:** outro dev não consegue a mesma imagem
- **Sem rollback:** se o deploy falhar, como voltar para a versão anterior?

A solução é um **Docker Registry** — um repositório centralizado que armazena imagens versionadas, prontas para pull em qualquer servidor.

### 1.2 O que é um Docker Registry?

Um Docker Registry funciona como o npm para pacotes Node.js, mas para imagens Docker:

- **Push:** envia uma imagem buildada para o registry
- **Pull:** baixa uma imagem do registry para executar
- **Tag:** identifica versões da mesma imagem

O fluxo completo é: `docker build` → `docker tag` → `docker push` → (registry armazena) → `docker pull` → `docker run`

### 1.3 Opções de Registry

**Docker Hub:**
- Registry padrão e mais conhecido
- Gratuito para imagens públicas
- Limitado para repositórios privados no plano gratuito
- URL: `docker.io/usuario/imagem:tag`

**GitHub Container Registry (ghcr.io):**
- Integrado ao GitHub (mesmo ecossistema do código e CI)
- Gratuito e ilimitado para repositórios públicos
- Autenticação via GITHUB_TOKEN (já disponível nos workflows)
- Imagens visíveis na aba Packages do repositório
- URL: `ghcr.io/usuario/imagem:tag`

**Amazon ECR (Elastic Container Registry):**
- Registry da AWS, integrado ao ECS/EKS
- Custo: ~$0.10/GB/mês de armazenamento
- Ideal quando infraestrutura já está na AWS
- URL: `123456789012.dkr.ecr.us-east-1.amazonaws.com/imagem:tag`

**Por que ghcr.io neste curso?**
- Custo zero (tudo público)
- Já estamos no GitHub (código + Actions + Registry = mesmo lugar)
- GITHUB_TOKEN funciona automaticamente (sem criar tokens extras)
- Fácil de visualizar (aba Packages no repositório)

### 1.4 Estratégias de Tagging

Tags são como "nomes" para versões de uma imagem. Existem três abordagens:

**1. Tag `latest`:**
- Sempre aponta para o build mais recente
- Problema: não sabe qual commit gerou a imagem
- Problema: `docker pull :latest` pode trazer versão diferente a cada vez
- Uso: apenas para desenvolvimento rápido, **nunca em produção**

**2. Semantic Versioning (semver):**
- Formato: `major.minor.patch` (ex: `1.2.3`)
- `major` = breaking changes, `minor` = novas features, `patch` = bugfixes
- Vinculado a git tags (`git tag v1.2.3` → imagem `:1.2.3`)
- Uso: releases oficiais, comunicação com equipe

**3. Git SHA (hash do commit):**
- Formato: primeiros 7 caracteres do SHA (ex: `sha-a1b2c3d`)
- Único por commit — rastreabilidade total
- Sempre sabe exatamente qual código gerou qual imagem
- Uso: pipelines CI/CD automatizados, rollback preciso

**Melhor prática:** combine SHA + latest (para conveniência) + semver (para releases):
```
ghcr.io/user/app:sha-a1b2c3d    ← todo commit
ghcr.io/user/app:latest          ← branch main
ghcr.io/user/app:1.2.3           ← git tags
```

### 1.5 Multi-Stage Builds para CI

Multi-stage builds separam o estágio de construção do estágio de execução:

- **Estágio builder:** instala todas as dependências (inclusive devDependencies)
- **Estágio runtime:** copia apenas o necessário (production deps + código)
- **Resultado:** imagem final 3-5x menor, mais segura, builds mais rápidos

Benefícios no CI:
- Menos dados para transferir no push (imagem menor)
- Menos superfície de ataque (sem ferramentas de build na imagem final)
- Cache de layers (steps que não mudaram não são re-executados)

### 1.6 Build e Push em GitHub Actions

O workflow usa três actions oficiais do Docker:

1. **`docker/login-action`** — autentica no registry usando GITHUB_TOKEN
2. **`docker/metadata-action`** — gera tags automaticamente baseado no contexto (branch, tag, SHA)
3. **`docker/build-push-action`** — builda a imagem e pusha para o registry em um step

O `GITHUB_TOKEN` precisa da permissão `packages: write` no workflow:
```yaml
permissions:
  contents: read
  packages: write
```

### 1.7 Visualizando no GitHub Packages

Após o push bem-sucedido, a imagem aparece em:
- Aba **Packages** do repositório
- URL: `https://github.com/USER/REPO/pkgs/container/REPO`
- Mostra: todas as tags disponíveis, tamanho da imagem, data de criação
- Qualquer pessoa pode fazer pull: `docker pull ghcr.io/user/repo:tag`

---

## Parte 2 — IA no CI/CD (~25 min)

### 2.1 A Evolução da IA no Curso

Esta é a terceira vez que aplicamos IA no curso, com complexidade crescente:

- **Aula 02 — Kiro (Interativo):** IA como assistente de desenvolvimento. Você pergunta, ela responde. Controle total do desenvolvedor.
- **Aula 07 — IA para IaC (Semi-automático):** IA gera infraestrutura Terraform. Você descreve o que quer, IA produz código que você valida.
- **Aula 09 — IA no CI/CD (Automático):** IA executa dentro do pipeline **sem interação humana**. A cada PR, IA analisa e posta feedback automaticamente.

A progressão é: humano no controle → humano supervisiona → humano define regras e IA executa.

### 2.2 Por que IA no CI/CD?

Code reviews tradicionais têm limitações:
- Reviewers ficam cansados e perdem detalhes em PRs grandes
- Horários limitados — PR aberto na sexta espera até segunda
- Inconsistência — cada reviewer tem critérios diferentes
- Conhecimento desigual — nem todos conhecem padrões de segurança

IA complementa o review humano:
- Responde em segundos (não em dias)
- Mantém mesmos critérios 24/7
- Verifica checklists extensos sem cansar
- Escalável para qualquer volume de PRs

### 2.3 Casos de Uso

**Automated PR Review:**
- IA recebe o diff (código alterado) do PR
- Analisa contra um conjunto de critérios (segurança, performance, padrões)
- Posta comentário no PR com achados e sugestões

**Security Scanning com IA:**
- Detecta padrões perigosos: secrets hardcoded, SQL injection, XSS
- Complementa ferramentas tradicionais (Dependabot verifica deps, CodeQL verifica código)
- IA entende contexto: "essa variável veio de input do usuário e está sendo usada em query SQL"

**Quality Gates Inteligentes:**
- IA classifica cada achado: CRITICAL (bloqueia), WARNING (informa), INFO (sugestão)
- Pipeline decide: se CRITICAL → PR não pode ser mergeado
- Se só warnings → PR pode prosseguir com ciência do dev

**Documentação Automática:**
- Verifica se PR tem descrição adequada
- Sugere atualização de README quando API muda
- Gera changelog entries automaticamente

### 2.4 Como Funciona na Prática

O fluxo técnico é:

1. Developer abre PR no GitHub
2. Trigger `pull_request` dispara workflow `ai-review.yml`
3. Workflow coleta os arquivos alterados (diff)
4. Script formata um prompt: "Analise este código procurando por..."
5. Script envia prompt + diff para API de IA (Bedrock, OpenAI, ou action de terceiros)
6. IA retorna análise estruturada
7. Workflow posta a análise como comentário no PR usando GITHUB_TOKEN
8. Se severidade CRITICAL → `exit 1` → PR bloqueado

### 2.5 AWS Bedrock no CI/CD

Bedrock (visto na Aula 07) pode ser chamado de dentro do pipeline:
- GitHub Actions → assume role AWS via OIDC → invoca Bedrock API
- Ou: GitHub Actions → chama Lambda que tem permissão Bedrock → retorna análise

Para quem não tem acesso Bedrock:
- Actions de terceiros que integram com IA (gratuitas para repos públicos)
- Abordagem conceitual (entender o fluxo, usar Kiro para gerar os scripts)

### 2.6 Limitações Importantes

- **Custo:** APIs de IA cobram por token. PRs grandes geram mais custo.
- **Latência:** IA leva 10-60 segundos para responder (aceitável em CI, mas não instantâneo).
- **Falsos positivos:** IA pode apontar problemas que não existem — dev precisa avaliar.
- **Falsos negativos:** IA pode perder bugs sutis de lógica de negócio.
- **Contexto limitado:** IA vê apenas o diff, não entende o sistema inteiro.
- **Complementar, não substitui:** Review humano continua obrigatório para decisões de arquitetura.

### 2.7 Quando IA Agrega Mais Valor

- **PRs grandes** (>500 linhas): humanos perdem atenção, IA mantém foco
- **Código de segurança:** checklist extenso (auth, crypto, input validation)
- **Infraestrutura:** Terraform e Docker têm padrões bem definidos
- **Horários fora do expediente:** feedback imediato mesmo de madrugada
- **Onboarding:** novos devs recebem orientação automática sobre padrões do projeto

---

## Questões de Verificação

Responda as questões abaixo para verificar sua compreensão. Traga suas respostas para a discussão em aula.

### Questão 1

Qual estratégia de tagging é mais adequada para um pipeline CI/CD automatizado que precisa de rastreabilidade total entre imagem e código-fonte?

- a) Tag `latest` porque é sempre atualizada automaticamente
- b) Tag com data/hora (ex: `2024-01-15-1430`) porque mostra quando foi buildada
- c) Tag com Git SHA (ex: `sha-a1b2c3d`) porque vincula a imagem ao commit exato
- d) Tag com nome do branch (ex: `main`) porque identifica a origem

### Questão 2

Por que o GITHUB_TOKEN é preferível a um Personal Access Token (PAT) para autenticar no ghcr.io em workflows de CI?

- a) Porque é mais rápido de configurar inicialmente
- b) Porque tem permissões ilimitadas em todo o GitHub
- c) Porque é gerado automaticamente, tem escopo limitado ao repositório e expira após o workflow
- d) Porque funciona em repositórios privados e o PAT não

### Questão 3

Em um sistema de AI PR Review com quality gates, qual é a ação correta quando a IA encontra um achado classificado como CRITICAL?

- a) Ignorar e permitir o merge, pois IA comete erros
- b) Bloquear o PR (exit 1) e exigir correção antes do merge
- c) Apenas postar um comentário informativo sem bloquear
- d) Desabilitar o workflow de IA para aquele PR específico

### Questão 4

Qual é a principal limitação de um AI code review em comparação com o review humano?

- a) IA não consegue ler código JavaScript
- b) IA é mais lenta que humanos para analisar código
- c) IA vê apenas o diff do PR, sem entender o contexto completo do sistema e decisões de negócio
- d) IA não pode postar comentários no GitHub

---

## Gabarito

| Questão | Resposta | Justificativa |
|:-------:|:--------:|--------------|
| 1 | **c** | Git SHA cria vínculo direto commit↔imagem, permitindo saber exatamente qual código gerou cada imagem e fazer rollback preciso |
| 2 | **c** | GITHUB_TOKEN é automático (sem gestão manual), limitado ao repositório (menor privilégio) e temporário (expira com o workflow) |
| 3 | **b** | Quality gates existem para impedir que problemas críticos cheguem à produção. CRITICAL deve bloquear; se for falso positivo, o dev corrige ou justifica |
| 4 | **c** | A IA analisa apenas o diff fornecido — ela não entende decisões de arquitetura, regras de negócio, ou o contexto mais amplo do sistema |

---

## Referências

### Docker Registry e GitHub Packages

- Docker. **Docker Registry**. Docker Documentation. Disponível em: [https://docs.docker.com/registry/](https://docs.docker.com/registry/)
- GitHub. **Working with the Container registry (ghcr.io)**. GitHub Docs. Disponível em: [https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- Docker. **docker/build-push-action**. GitHub Marketplace. Disponível em: [https://github.com/docker/build-push-action](https://github.com/docker/build-push-action)
- Docker. **Best practices for tagging and versioning Docker images**. Disponível em: [https://docs.docker.com/build/building/best-practices/](https://docs.docker.com/build/building/best-practices/)

### GitHub Actions — Permissões e Token

- GitHub. **Automatic token authentication (GITHUB_TOKEN)**. GitHub Docs. Disponível em: [https://docs.github.com/en/actions/security-for-github-actions/security-guides/automatic-token-authentication](https://docs.github.com/en/actions/security-for-github-actions/security-guides/automatic-token-authentication)
- GitHub. **Assigning permissions to jobs**. GitHub Docs. Disponível em: [https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/controlling-permissions-for-github_token](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/controlling-permissions-for-github_token)

### IA no CI/CD e Code Review

- GitHub. **About pull request reviews**. GitHub Docs. Disponível em: [https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/about-pull-request-reviews](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/about-pull-request-reviews)
- Amazon Web Services. **Amazon Bedrock — Foundation Models**. AWS Documentation. Disponível em: [https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html)

### Versionamento Semântico

- **Semantic Versioning 2.0.0 (SemVer)**. Disponível em: [https://semver.org/lang/pt-BR/](https://semver.org/lang/pt-BR/)
