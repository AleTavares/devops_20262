# Trabalho em Aula — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 10/10/2026

## Parte 1 — Design de Pipeline CI

### Estágios do pipeline (em ordem)

| Estágio | O que verifica | Obrigatório? | Tempo estimado |
|---------|---------------|:------------:|:-------------:|
| 1. Lint (ESLint) | Sintaxe, variáveis não usadas, aspas e ponto e vírgula | Sim (bloqueia o merge) | ~20 s |
| 2. Test (Jest + coverage) | Testes unitários dos endpoints (`/health`, `/api/orders`); em Node 18 e 20 | Sim (bloqueia o merge) | ~30 s |
| 3. Build (Docker) | A imagem compila e o container sobe respondendo em `/health` (smoke test) | Sim (bloqueia o merge) | ~1 min |
| 4. Comentário no PR | Publica o resultado do CI no Pull Request | Não (informativo) | ~5 s |

Se um estágio falha, os seguintes não executam (`needs`): lint falhou → não gasta tempo com testes e build; test falhou → não builda uma imagem com código quebrado. O lint vem primeiro por ser o mais barato e dar feedback mais rápido.

### Diagrama

```
[push main / PR] → [1: lint] → [2: test (Node 18 | 20)] → [3: build Docker + smoke test] → [4: comentário no PR]
                       │                  │                          │
                  falha → para        falha → para               falha → para
                  (PR bloqueado,      (build não roda)           (imagem não é aprovada)
                   dev notificado)
```

### Respostas

- O pipeline deve rodar em: **ambos** — em `pull_request` (para barrar o código antes do merge) e em `push` para a `main` (para garantir que a branch principal continua verde após o merge).
- Um PR deve ser bloqueado quando: qualquer estágio obrigatório (lint, test ou build) falhar, usando branch protection com os checks como "required".
- Como o time fica sabendo que quebrou: pelo ✅/❌ no PR, pelo e-mail/notificação do GitHub para quem fez o commit, pelo badge no README e pelo comentário automático do workflow no PR.

## Parte 2 — Análise de Segurança de Credenciais

### Cenário 1 — O `.env` esquecido

- **O que aconteceu:** o `.env` com credenciais AWS foi commitado com `git add .` e enviado para a `main`. Apagar o arquivo em outro commit só remove da versão atual: o conteúdo continua no histórico (`git log`/`git show`).
- **Impacto:** as credenciais **não** estão seguras após o commit de deleção. Com as access keys, um atacante pode usar a AWS CLI/SDK com as permissões daquele usuário: listar e baixar dados de S3, criar EC2 (ex.: mineração de cripto, gerando custo), ler bancos, criar novos usuários IAM para manter acesso. Bots varrem repositórios públicos em segundos.
- **Como prevenir:** `.env` no `.gitignore` desde o início e `.env.example` versionado só com nomes; pre-commit hook com scanner de segredos (ex.: gitleaks); push protection / secret scanning do GitHub; uso de GitHub Secrets no CI. A medida que impede o cenário 100% é **nunca ter o segredo no repositório** (`.gitignore` + hook que bloqueia o commit). Depois do vazamento, o essencial é **revogar/rotacionar a chave** imediatamente (limpar o histórico com `git filter-repo` é complementar, não substitui a revogação).
- **Como detectar:** alerta do GitHub Secret Scanning (e e-mail da AWS sobre chave exposta), gitleaks no CI, CloudTrail/GuardDuty mostrando uso da chave fora do padrão, Cost Explorer/alertas de billing com custo inesperado.

### Cenário 2 — O workflow indiscreto

- **O que aconteceu:** um step de debug imprime secrets com `echo` no log do workflow.
- **Impacto:** o GitHub mascara o valor exato do secret como `***`, mas isso **não é 100% seguro**: a máscara é por correspondência de texto, então o valor pode vazar se for transformado (base64, hex, invertido, dividido em partes/substrings, com caracteres inseridos) ou se for enviado a serviços de terceiros. Quem tem acesso de leitura aos logs (ou ao repositório público) pode reconstruir o segredo e usar as credenciais.
- **Como prevenir:** não permitir `echo`/`print` de secrets, mesmo mascarados; passar secrets via `env:` apenas ao step que precisa; revisar PRs que alterem `.github/workflows/`; usar `permissions:` mínimas e environments com required reviewers para segredos de produção; rotacionar o secret se houver suspeita de exposição.
- **Como detectar:** revisão de código dos workflows (CODEOWNERS no diretório `.github/`), busca por `secrets.` seguido de `echo` nos workflows, auditoria dos logs e do audit log do GitHub, e rotação periódica das credenciais.

### Cenário 3 — O PR do fork

- **O que aconteceu:** um contribuidor externo alterou o workflow no fork para enviar `secrets.AWS_ACCESS_KEY_ID` e `secrets.AWS_SECRET_ACCESS_KEY` para um servidor externo (`evil.com`).
- **Impacto:** se o secret chegasse ao workflow, o atacante exfiltraria as credenciais AWS e teria acesso à conta. Mas, **por design, o GitHub Actions não passa secrets (exceto o `GITHUB_TOKEN`, somente leitura) para workflows disparados por `pull_request` vindo de forks**, então os valores chegam vazios. O atacante pode tentar contornar isso com gatilhos mais privilegiados, como `pull_request_target` (roda no contexto do repositório base, com secrets) combinado com checkout do código do PR, ou injeção de comandos via título/branch do PR usada em `run:`.
- **Como prevenir:** não usar `pull_request_target` com checkout de código não confiável; exigir aprovação para rodar workflows de contribuidores externos (Settings → Actions → "Require approval for all outside collaborators"); `permissions:` mínimas; nunca interpolar `${{ github.event.* }}` direto em `run:` (usar variáveis de ambiente); manter segredos sensíveis em environments com required reviewers e branches restritas; usar credenciais de menor privilégio (OIDC com role limitada em vez de chaves de longa duração).
- **Como detectar:** revisar o diff de `.github/workflows/` em todo PR externo, alertas de saída de rede suspeita (ex.: ferramentas como StepSecurity Harden-Runner), e o audit log/histórico de execuções do Actions.
