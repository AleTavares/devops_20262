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

- [ ] Pipeline CI (lint → test → build+push) funcional
- [ ] Imagem publicada no ghcr.io com tags (sha, latest, semver)
- [ ] Push condicional (só em push para main/tags, não em PRs)
- [ ] Workflow de AI Review disparando em PRs
- [ ] Quality gate (CRITICAL bloqueia o PR)
- [ ] `ia-cicd-analise.md` preenchido
- [ ] Screenshots (Packages, AI review, pipeline verde, gate bloqueando)

## Evidência do Pipeline Rodando

[Cole aqui o link da execução ou screenshots]
```

---

## Exercício: Pipeline Completo com Registry + AI Review

### Contexto

O CTO da TechNova quer o pipeline definitivo: código é verificado (lint, test), imagem é publicada (ghcr.io), e cada PR é revisado por IA antes de qualquer humano olhar. Implemente esse pipeline completo.

### Requisitos

#### 1. Pipeline CI com Docker Registry (40%)

Crie/atualize `.github/workflows/ci.yml` com:

- **Job lint:** ESLint verifica o código
- **Job test:** Jest roda testes com coverage
- **Job build-and-push:** (depende de lint e test)
  - Login no ghcr.io com GITHUB_TOKEN
  - Build da imagem Docker (multi-stage)
  - Push com tags:
    - `sha-XXXXXXX` em todo push para main
    - `latest` em push para main
    - Semver (`1.2.3`, `1.2`, `1`) quando há git tag `v*.*.*`
  - Push **apenas** em push para main/tags (não em PRs)

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

- Explicação da estratégia de tagging escolhida (e por quê)
- Descrição dos padrões que o AI review verifica
- Prompt/lógica utilizada para a análise
- Quando confiar na IA vs quando exige review humano
- Limitações identificadas (falsos positivos, contexto limitado)

**Screenshots obrigatórios:**
- Imagem publicada na aba Packages do GitHub (mostrando tags)
- Comentário do AI review em um PR (com achados detectados)
- Pipeline CI completo passando (lint → test → build+push)
- Quality gate bloqueando um PR com problema CRITICAL

---

## Estrutura de Entrega

```
entregas/aula-09/RA/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml              # Pipeline CI: lint → test → build+push
│   │   └── ai-review.yml      # AI review em PRs
│   └── scripts/
│       └── ai-review.js        # Script de análise
├── Dockerfile                   # Multi-stage otimizado
├── .dockerignore               # Exclusões para build
├── ia-cicd-analise.md          # Documentação da estratégia
├── screenshots/
│   ├── packages-tab.png        # Imagem no GitHub Packages
│   ├── ai-review-comment.png  # Comentário de AI review no PR
│   ├── pipeline-passing.png   # CI completo verde
│   └── quality-gate-block.png # PR bloqueado por CRITICAL
└── README.md                   # Instruções de como executar/testar
```

---

## Critérios de Avaliação

| Critério | Peso | Descrição |
|----------|:----:|-----------|
| Pipeline CI funcional | 20% | lint → test → build+push funciona em push para main |
| Tagging correto | 10% | SHA + latest em push, semver em git tags |
| Push condicional | 10% | Imagem só é publicada em push (não em PRs) |
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

- [ ] Cache de layers Docker no workflow (docker/build-push-action + cache-from/cache-to)
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
git checkout -b feature/aula-09-registry-ai-review
mkdir -p aula-09/.github/workflows
mkdir -p aula-09/.github/scripts
mkdir -p aula-09/screenshots
# copie os arquivos do seu projeto para aula-09/
git add aula-09/
git commit -m "feat(aula-09): pipeline com Docker Registry e AI review"
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

- Comece pelo pipeline CI com build+push — é a base para tudo
- Use o workflow da Parte 1 do lab como referência direta
- Para o AI review, o script do lab já funciona — adapte para seu projeto
- Faça commits pequenos e frequentes (facilita debug se algo falhar)
- Se o push falhar com permissão, verifique: `permissions: packages: write`
- Screenshots: use a extensão de captura do browser ou `Cmd/Ctrl+Shift+S`

---

## Conexão com Próximas Aulas

O pipeline que você constrói aqui será **expandido no Módulo 4**:
- Aula 10+: Estratégias de deploy (Blue-Green, Canary) vão fazer **pull** das imagens que você publicou aqui
- A imagem no ghcr.io será deployada em EC2/ECS
- O AI review será refinado com mais padrões e integração com Bedrock

> **💡 Guarde seu pipeline funcionando** — ele será pré-requisito para as próximas aulas.
