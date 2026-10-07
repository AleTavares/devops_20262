# Trabalho de Fixação (TF) — Aula 08: GitHub Actions e CI Pipelines

## Desafio

Consolidar o aprendizado sobre **GitHub Actions**, CI pipelines e secrets management criando um pipeline CI **completo e funcional** para a TechNova API. Publique via Pull Request no repositório da disciplina.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | 1 semana a partir da data da aula |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork** | `entregas/aula-08/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com link do repositório + evidências |
| **Arquivos do projeto** | No repositório `unifaat-devops-portfolio`, pasta `aula-08/` |

> **Avaliação automática:** o professor confere os workflows rodando no GitHub Actions do seu repositório. Garanta que o repositório esteja **público** e que as execuções estejam visíveis na aba **Actions**.

### Como Entregar via Pull Request

1. Faça um **fork** do repositório da disciplina (se ainda não fez)
2. Clone o seu fork localmente
3. Crie a pasta `entregas/aula-08/SEU-RA/`
4. Adicione **apenas** o arquivo `entrega.md` (modelo abaixo) — os arquivos do projeto ficam no `unifaat-devops-portfolio`
5. Faça commit e push para o seu fork
6. Abra um **Pull Request** para o repositório original

**Modelo do arquivo `entrega.md`:**

```markdown
# Entrega — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** [Seu nome completo]
**RA:** [Seu RA]
**Data:** [Data da entrega]

## Repositório

- URL: https://github.com/SEU-USUARIO/unifaat-devops-portfolio

## Evidências

- [ ] Workflow CI multi-stage funcional (lint → test → build)
- [ ] ESLint configurado e passando
- [ ] Mínimo 3 testes Jest passando com coverage
- [ ] Docker build no CI sem erros
- [ ] Secret referenciado no workflow
- [ ] Badge de status no README
- [ ] Screenshots do pipeline verde

## Evidência do Pipeline Rodando

[Cole aqui o link da execução ou screenshot da aba Actions]
```

---

## Descrição do Trabalho

Você deve criar um pipeline CI completo para o repositório `unifaat-devops-portfolio` que inclua:

1. **Workflow GitHub Actions** (`.github/workflows/ci-aula08.yml`)
2. **ESLint configurado** (`.eslintrc.json`)
3. **Testes com Jest** (mínimo 3 test cases)
4. **Docker build** no pipeline
5. **Secrets referenciados** no workflow
6. **Status badge** no README
7. **Evidências** (screenshots)

---

## Requisitos Obrigatórios

### R1 — Workflow CI Multi-Stage

Criar `.github/workflows/ci-aula08.yml` com:

- [ ] Trigger em `push` (main) e `pull_request`
- [ ] Job **lint** (ESLint)
- [ ] Job **test** (Jest com coverage)
- [ ] Job **build** (Docker build)
- [ ] Dependências corretas: lint → test → build (usando `needs`)
- [ ] Cada job com nome descritivo

### R2 — ESLint Configurado

- [ ] Arquivo `.eslintrc.json` na raiz do projeto
- [ ] Regras definidas (mínimo: `semi`, `quotes`, `no-unused-vars`)
- [ ] Script `lint` no `package.json`
- [ ] ESLint passando sem erros no código entregue

### R3 — Testes com Jest

- [ ] Mínimo **3 test cases** (podem ser mais)
- [ ] Cobrindo pelo menos 2 endpoints diferentes
- [ ] Script `test` no `package.json` com `--coverage`
- [ ] Todos os testes passando

### R4 — Docker Build no CI

- [ ] `Dockerfile` funcional na raiz do projeto
- [ ] Job `build` que executa `docker build` com sucesso
- [ ] Imagem taggeada (pode ser com `${{ github.sha }}`)

### R5 — Secrets Referenciados

- [ ] Pelo menos 1 secret configurado no repositório (ex: `AWS_REGION`)
- [ ] Secret referenciado no workflow com `${{ secrets.NAME }}`
- [ ] Evidência de que o secret funciona (screenshot do log mascarado)

### R6 — Status Badge

- [ ] Badge do CI no README.md do repositório
- [ ] Badge mostrando "passing" (pipeline verde)

### R7 — Screenshots

Incluir na pasta de entrega:
- [ ] `screenshot-pipeline-passing.png` — Pipeline completo verde
- [ ] `screenshot-pipeline-failing.png` — Pipeline falhando (erro intencional)
- [ ] `screenshot-secrets-configured.png` — Tela de secrets (nomes visíveis, valores ocultos)

---

## Requisitos Bônus

### B1 — Matrix Strategy (+1 ponto)
- [ ] Testes rodando em Node 18 e Node 20

### B2 — Cache de Dependências (+1 ponto)
- [ ] `actions/cache` ou `setup-node` com cache configurado
- [ ] Evidência de cache hit em execução subsequente

### B3 — PR Comment (+1 ponto)
- [ ] Workflow comenta resultado do CI em Pull Requests
- [ ] Screenshot do comentário automático no PR

### B4 — Concurrency Control (+0.5 ponto)
- [ ] `concurrency` configurado para cancelar runs em progresso

### B5 — Smoke Test no Docker (+0.5 ponto)
- [ ] Após `docker build`, container é iniciado e health check executado
- [ ] Container é parado e removido após teste

---

## Entrega

### 1 — Publicar no portfólio

Os arquivos do projeto ficam no seu `unifaat-devops-portfolio`, pasta `aula-08/`:

```bash
cd unifaat-devops-portfolio
git checkout -b feature/aula-08-ci-pipeline
mkdir -p aula-08/.github/workflows
mkdir -p aula-08/__tests__
mkdir -p aula-08/screenshots
# copie os arquivos do seu projeto para aula-08/
git add aula-08/
git commit -m "feat(aula-08): CI pipeline completo com GitHub Actions"
git checkout main
git merge feature/aula-08-ci-pipeline
git push origin main
git push origin feature/aula-08-ci-pipeline
```

### 2 — Registrar entrega no fork da disciplina

```bash
cd /caminho/para/seu-fork-da-disciplina
git checkout -b entregas/aula-08/SEU-RA
mkdir -p entregas/aula-08/SEU-RA
# Crie o arquivo entrega.md (modelo na seção Informações de Entrega)
git add entregas/aula-08/SEU-RA/entrega.md
git commit -m "feat(aula-08): entrega TF - SEU NOME (RA: SEU-RA)"
git push -u origin entregas/aula-08/SEU-RA
```

Abra o Pull Request no GitHub com:
- **Título:** `[Aula 08] RA: SEU-RA - SEU NOME`
- **Base:** `main`
- **Compare:** `entregas/aula-08/SEU-RA`

---

## Critérios de Avaliação

| Critério | Peso | Descrição |
|----------|:----:|-----------|
| R1 — Workflow CI multi-stage | 25% | Pipeline com 3 jobs e dependências corretas |
| R2 — ESLint configurado | 10% | Configuração funcional com regras definidas |
| R3 — Testes com Jest | 20% | Mínimo 3 testes passando com coverage |
| R4 — Docker build | 15% | Dockerfile funcional e build no CI |
| R5 — Secrets referenciados | 10% | Pelo menos 1 secret usado no workflow |
| R6 — Badge + README | 5% | Badge visível e README completo |
| R7 — Screenshots | 5% | 3 screenshots obrigatórios |
| RESPOSTAS.md | 10% | Respostas corretas e demonstrando compreensão |
| **Bônus** | **+3 pts** | Matrix, cache, PR comment, concurrency, smoke test |

---

## Dicas

1. **Comece pelo que funciona localmente:** antes de criar o workflow, garanta que `npm run lint`, `npm test` e `docker build` funcionam na sua máquina.
2. **Incremental:** não tente fazer tudo de uma vez. Comece com lint, depois test, depois build.
3. **Leia os logs:** 90% dos problemas são: package-lock.json faltando, path errado, ou dependência não instalada.
4. **Repositório público:** use repositório público para ter minutos ilimitados de GitHub Actions.
5. **Não commite o `.env`:** nunca, jamais. Use `.gitignore`.
6. **Screenshots do GitHub:** use a aba Actions. Mostre os jobs e seus status.
7. **Use valores fictícios nos secrets:** para este exercício, não precisa de credenciais reais.

> **Lembre-se:** o pipeline deve estar realmente **funcionando** no GitHub. O professor verificará o repositório ao avaliar o PR.

