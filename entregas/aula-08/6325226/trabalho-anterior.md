# Trabalho Anterior (TA) — Aula 08: GitHub Actions e Secrets

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 2026-10-08

## Questões de Múltipla Escolha

| Questão | Resposta |
|:-------:|:--------:|
| 1 | **b** |
| 2 | **c** |
| 3 | **c** |
| 4 | **b** |

### Questão 1 — O que dispara um workflow?

**b) Eventos configurados no campo `on:` do YAML, como push, pull_request ou workflow_dispatch.**

O workflow é orientado a eventos: só roda quando acontece um evento listado em `on:`. A (a) seria um evento `schedule` (cron), que só existe se for configurado. A (c) é o `workflow_dispatch`, que é apenas um dos eventos possíveis. A (d) não existe.

### Questão 2 — Função do `needs`

**c) Cria dependência entre jobs: o job só executa se os jobs listados em `needs` passarem.**

Sem `needs`, os jobs rodam em paralelo. Com `needs: [lint, test]`, o `build` espera os dois e é pulado se algum falhar. É o que permite o pipeline lint → test → build parar no primeiro erro. Secrets vêm de `secrets.*`, o runner vem de `runs-on` e retry não é nativo do `needs`.

### Questão 3 — Onde guardar credenciais AWS

**c) Em GitHub Secrets (Settings → Secrets), referenciadas com `${{ secrets.NAME }}`.**

Os secrets ficam criptografados, não aparecem no código e são mascarados nos logs. Um `.env` commitado (a) fica no histórico do Git para sempre, mesmo se for apagado depois. Não existe campo `credentials:` (d), e `runs-on` (b) só escolhe o runner. Melhor ainda que access keys fixas é usar OIDC com role temporária, quando a conta permite.

### Questão 4 — Environments com approval gates

**b) Garantir que deploys para ambientes sensíveis (como produção) exijam aprovação humana antes de executar.**

Um job com `environment: production` fica pausado até um *required reviewer* aprovar. Os secrets desse environment só ficam disponíveis depois da aprovação. Isso não acelera nada (a), não expõe secrets (c) e não replica o repositório (d).

## Preparação para a Aula

- [x] Li toda a Parte 1 (GitHub Actions e CI)
- [x] Li toda a Parte 2 (Secrets Management)
- [x] Respondi as 4 questões de múltipla escolha
- [x] Anotei dúvidas para discutir em aula
- [x] Tenho conta GitHub ativa com um repositório `unifaat-devops-portfolio`
- [x] Tenho Node.js (≥18) e npm instalados
- [x] Entendo que GitHub Actions é gratuito para repos públicos
- [x] Refleti: já commitei credenciais no código alguma vez? Como prevenir?

### Dúvidas anotadas

- Se o `GITHUB_TOKEN` já vem pronto em todo workflow, quando faz sentido criar um PAT?
- Como o GitHub mascara um secret que foi transformado (base64, substring)? Ele consegue pegar o valor nesses casos?

### Reflexão: credenciais no código

O risco existe no meu ambiente: as credenciais da AWS (`~/.aws/credentials`, chaves do Learner Lab) ficam na mesma máquina dos repositórios, e um `git add .` na pasta errada pode levá-las para um commit. Como prevenção: `.env` e arquivos de credenciais no `.gitignore` desde o primeiro commit, um `.env.example` sem valores, `git status` revisado antes de cada commit, hook de pre-commit com gitleaks e o Push Protection do GitHub ligado. No CI, só GitHub Secrets.
