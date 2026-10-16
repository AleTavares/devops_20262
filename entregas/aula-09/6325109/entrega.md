# Entrega — Aula 09: Docker Registry e IA no CI/CD

**Aluno:** Carina Dal Pino
**RA:** 6325109
**Data:** 15/10/2026

## Repositório

- URL: https://github.com/CarinaDalpino/unifaat-devops-portfolio

## Evidências

- [ ] Pipeline CI (lint → test → build+push) funcional
- [ ] Imagem publicada no ghcr.io com tags (sha, latest, semver)
- [ ] Push condicional (só em push para main/tags, não em PRs)
- [ ] Workflow de AI Review disparando em PRs
- [ ] Quality gate (CRITICAL bloqueia o PR)
- [ ] `ia-cicd-analise.md` preenchido
- [ ] Screenshots (Packages, AI review, pipeline verde, gate bloqueando)

> Marque cada item com `[x]` após confirmar no GitHub.

## Estrutura entregue no portfólio

```
unifaat-devops-portfolio/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml              # lint → test → build+push (push condicional)
│   │   ├── ai-review.yml       # AI review em PRs + quality gate
│   │   └── security-scan.yml   # scan de secrets e Dockerfile
│   └── scripts/
│       └── ai-review.js        # análise do diff (9 padrões) + exit 1 em CRITICAL
└── aula-09/
    ├── Dockerfile              # multi-stage, usuário não-root, HEALTHCHECK
    ├── .dockerignore
    ├── ia-cicd-analise.md
    ├── README.md
    └── (server.js, package.json, __tests__/ ...)
```

## Validação local realizada

- `npm run lint` → sem erros
- `npm test` → 9 testes passando (coverage ~89%)
- `docker build` → imagem multi-stage gerada (~200MB)
- Smoke test `/health` → `{"status":"ok", ...}`
- `ai-review.js` com diff problemático → achados CRITICAL/WARNING/INFO detectados, exit 1 (quality gate bloqueia)
- `ai-review.js` com diff limpo → "Nenhum problema encontrado", exit 0 (não bloqueia)
- Container roda como usuário não-root (`technova`)

## Evidência do Pipeline Rodando

[Cole aqui o link da execução do GitHub Actions ou os screenshots após o push]
