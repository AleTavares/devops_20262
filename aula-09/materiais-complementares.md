# Aula 09 — Materiais Complementares

## Docker Registry e Container Images

### Documentação Oficial

- [GitHub Container Registry (ghcr.io)](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) — Guia completo do registro de containers do GitHub
- [Docker Hub Documentation](https://docs.docker.com/docker-hub/) — Registry padrão do Docker
- [Amazon ECR User Guide](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html) — Registry da AWS

### GitHub Actions para Docker

- [docker/login-action](https://github.com/docker/login-action) — Autenticação em registries (ghcr.io, Docker Hub, ECR)
- [docker/metadata-action](https://github.com/docker/metadata-action) — Geração automática de tags e labels
- [docker/build-push-action](https://github.com/docker/build-push-action) — Build e push em um step
- [docker/setup-buildx-action](https://github.com/docker/setup-buildx-action) — Setup do BuildKit para builds avançados

### Estratégias de Tagging

- [Docker Tagging Best Practices](https://docs.docker.com/develop/dev-best-practices/) — Boas práticas oficiais do Docker
- [Semantic Versioning 2.0.0](https://semver.org/lang/pt-BR/) — Especificação semver em português
- [Container Image Tagging Strategies](https://stevelasker.blog/2018/03/01/docker-tagging-best-practices-for-tagging-and-versioning-docker-images/) — Comparativo de estratégias (latest vs semver vs SHA)

### Multi-Stage Builds

- [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/) — Documentação oficial
- [Node.js Docker Best Practices](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md) — Boas práticas para Node.js em Docker
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) — Guia de otimização de Dockerfiles

---

## IA no CI/CD

### Conceitos e Arquitetura

- [GitHub Actions Documentation](https://docs.github.com/en/actions) — Referência completa de GitHub Actions
- [AWS Bedrock Developer Guide](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html) — Guia do Amazon Bedrock
- [GitHub Actions: Using scripts](https://docs.github.com/en/actions/learn-github-actions/essential-features-of-github-actions) — Como usar scripts customizados em workflows

### Ferramentas de AI Review

- [actions/github-script](https://github.com/actions/github-script) — Executar JavaScript com acesso à API do GitHub
- [GitHub Copilot for Pull Requests](https://docs.github.com/en/copilot/using-github-copilot/using-github-copilot-for-pull-requests) — Funcionalidade nativa do GitHub para AI review
- [CodeRabbit](https://coderabbit.ai/) — Ferramenta de AI review para PRs (plano gratuito disponível)

### Security Scanning

- [Trivy](https://aquasecurity.github.io/trivy/) — Scanner de vulnerabilidades para containers, código e IaC
- [GitHub Dependabot](https://docs.github.com/en/code-security/dependabot) — Atualização automática de dependências vulneráveis
- [GitHub CodeQL](https://docs.github.com/en/code-security/code-scanning/introduction-to-code-scanning/about-code-scanning-with-codeql) — Análise estática profunda com data flow
- [Snyk](https://snyk.io/) — Plataforma de segurança para desenvolvedores

---

## Vídeos Recomendados

### Docker Registry
- [Docker Registry Explained](https://www.youtube.com/results?search_query=docker+registry+explained) — Conceitos fundamentais
- [GitHub Packages Container Registry](https://www.youtube.com/results?search_query=github+packages+container+registry+tutorial) — Tutorial prático ghcr.io
- [Docker Multi-Stage Builds](https://www.youtube.com/results?search_query=docker+multi+stage+build+tutorial) — Otimizando imagens

### CI/CD e Automação
- [GitHub Actions Full Course](https://www.youtube.com/results?search_query=github+actions+full+course+2024) — Curso completo
- [CI/CD Pipeline with Docker](https://www.youtube.com/results?search_query=cicd+pipeline+docker+github+actions) — Pipeline com containers
- [AI Code Review Tools](https://www.youtube.com/results?search_query=ai+code+review+github+actions) — Ferramentas de AI review

---

## Ferramentas Úteis

| Ferramenta | Propósito | Custo |
|-----------|----------|:-----:|
| **ghcr.io** | Container registry integrado ao GitHub | Gratuito (público) |
| **Docker Scout** | Análise de vulnerabilidades em imagens | Gratuito (3 repos) |
| **Trivy** | Security scanner (containers + código) | Open Source |
| **Dependabot** | Atualização automática de deps | Gratuito |
| **CodeQL** | Análise estática avançada | Gratuito (público) |
| **actions/github-script** | JavaScript na API do GitHub | Gratuito |
| **hadolint** | Linter para Dockerfiles | Open Source |
| **dive** | Analisar layers de imagens Docker | Open Source |

---

## Conexão com Outros Módulos

### Módulo 2 (Infraestrutura)
- **Aula 07 (IA para IaC):** Mesma IA (Bedrock) agora aplicada no pipeline, não na geração de infraestrutura
- **Aula 06 (EC2/RDS):** As imagens publicadas aqui serão deployadas nessas instâncias

### Módulo 3 (CI/CD) — Aulas Anteriores
- **Aula 08 (GitHub Actions):** Pipeline CI que agora é estendido com push para registry e AI review

### Módulo 4 (Deploy) — Próximas Aulas
- As imagens publicadas no ghcr.io serão usadas em estratégias de deploy (Blue-Green, Canary)
- O deploy server fará `docker pull ghcr.io/user/technova-api:tag` para atualizar a aplicação
- AI review será estendido para validar configurações de deploy

---

## Leitura Adicional

### Artigos Técnicos
- [The Twelve-Factor App: Build, Release, Run](https://12factor.net/build-release-run) — Princípios de apps modernas
- [Continuous Delivery with Docker](https://martinfowler.com/articles/continuousIntegration.html) — Martin Fowler sobre CI
- [OWASP Top 10](https://owasp.org/www-project-top-ten/) — Vulnerabilidades mais comuns (relevante para AI security review)

### Sobre IA em DevOps
- [AI-Assisted Code Review](https://github.blog/2023-05-17-how-github-copilot-is-getting-better-at-understanding-your-code/) — GitHub Blog sobre IA em review
- [Responsible AI in CI/CD](https://aws.amazon.com/machine-learning/responsible-ai/) — AWS sobre IA responsável
- [LLMs for Code Review](https://arxiv.org/search/?query=llm+code+review) — Pesquisas acadêmicas sobre IA em revisão de código

---

## Glossário Rápido

| Termo | Definição |
|-------|-----------|
| **Registry** | Servidor que armazena e distribui imagens Docker |
| **ghcr.io** | GitHub Container Registry |
| **Tag** | Identificador de versão de uma imagem |
| **Manifest** | Metadados de uma imagem (layers, plataforma, config) |
| **Layer** | Camada individual de um Dockerfile (cada instrução = 1 layer) |
| **Multi-stage** | Dockerfile com múltiplos FROM (build + runtime) |
| **AI Review** | Análise automatizada de código por inteligência artificial |
| **Quality Gate** | Regra que determina se um PR pode ou não ser mergeado |
| **Prompt** | Instrução que guia a IA sobre o que analisar |
| **False Positive** | IA reporta problema que não existe (erro do tipo I) |
| **False Negative** | IA não detecta problema real (erro do tipo II) |
