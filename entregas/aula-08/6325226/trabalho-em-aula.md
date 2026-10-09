# Trabalho em Aula — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 2026-10-08

## Parte 1 — Design de Pipeline CI

### Diagrama

```
[push / PR] → [1. install + cache] → [2. lint] → [3. testes] → [4. build Docker] → [5. scan] → [pronto p/ deploy]
                     │                   │            │                │                │
                 falha → para       falha → bloqueia PR (todos os obrigatórios)    falha → só avisa
                                         │
                              resultado comentado no PR + e-mail/notificação do GitHub
```

### Estágios do pipeline (em ordem)

| Estágio | O que verifica | Obrigatório? | Tempo estimado |
|---------|---------------|:------------:|:-------------:|
| 1. Install | `npm ci` com cache — lock file íntegro e dependências instaláveis | Sim | ~20 s (com cache) |
| 2. Lint | ESLint: sintaxe, variáveis não usadas, `==`, aspas e ponto-e-vírgula | Sim | ~10 s |
| 3. Testes | Jest + supertest nas rotas, com coverage mínimo (ex.: 70%) | Sim | ~30 s |
| 4. Build | `docker build` multi-stage + smoke test do `/health` no container | Sim | ~1–2 min |
| 5. Segurança | `npm audit` e scan de secrets no código (ex.: gitleaks) | Não (informativo no início) | ~20 s |

**Por que essa ordem:** do mais rápido e barato para o mais lento. Lint falhando em 10 s já evita gastar minutos com testes e build. O build só faz sentido com código que passou nos testes.

### Respostas

- **O pipeline deve rodar em:** ambos. Em **PRs**, para barrar o problema antes do merge. Em **push para main**, para garantir que a main continua verde depois do merge e para gerar a imagem que vai para o deploy.
- **Um PR deve ser bloqueado quando:** qualquer estágio obrigatório (install, lint, testes, build) falhar, ou o coverage cair abaixo do mínimo. Isso fica configurado com *branch protection* na main exigindo os status checks e pelo menos 1 review.
- **Como o time fica sabendo que quebrou:** check vermelho no PR, comentário automático do workflow com o resultado de cada job, notificação/e-mail do GitHub para o autor do commit e o badge do README ficando "failing".

## Parte 2 — Análise de Segurança de Credenciais

### Cenário 1 — O `.env` esquecido

- **O que aconteceu:** o `.env` não estava no `.gitignore` e o `git add .` incluiu o arquivo. Deletar num commit seguinte não resolve, porque o arquivo continua no histórico do Git (e em forks e clones feitos nessas 2 horas).
- **Impacto:** as credenciais **não** estão seguras. Bots varrem o GitHub em segundos. Com as access keys, um atacante usa a conta AWS com as permissões daquele usuário: sobe instâncias para minerar cripto, lê/apaga buckets S3, acessa bancos e cria novos usuários IAM para manter acesso — gerando fatura alta e vazamento de dados.
- **Como prevenir:** `.env` no `.gitignore` desde o primeiro commit e só um `.env.example` sem valores no repositório. A medida que impede de verdade é o **bloqueio antes do push**: hook de pre-commit com gitleaks/git-secrets e o **GitHub Push Protection** (secret scanning), que recusa o push com chave detectada. Em CI, as credenciais vão para GitHub Secrets. Melhor ainda: OIDC com role temporária, sem chave fixa.
- **Como detectar:** GitHub secret scanning / alertas, AWS avisando de chave exposta (quarentena automática), CloudTrail com chamadas estranhas e alertas de billing. **Resposta:** revogar/rotacionar a chave imediatamente, revisar o CloudTrail e, depois, limpar o histórico (git filter-repo).

### Cenário 2 — O workflow indiscreto

- **O que aconteceu:** um step de debug imprime os secrets no log. O GitHub mascara o valor exato como `***`, mas a máscara é só uma substituição de texto no log.
- **Impacto:** não é 100% seguro. Se o valor for transformado — base64, `rev`, imprimir caractere por caractere, substring, URL-encode — ele não bate com a máscara e aparece em claro. Também pode vazar ao ser enviado para serviços externos, gravado em arquivo e publicado como artifact, ou em logs de ferramentas de terceiros. Qualquer pessoa com acesso de leitura aos logs veria o valor.
- **Como prevenir:** **não** permitir `echo` de secrets, nem mascarados. Para debug, só verificar se existe (`[ -n "$VAR" ]`). Passar os secrets via `env:` apenas no step que precisa, revisar mudanças em `.github/workflows/` com CODEOWNERS e usar `::add-mask::` para valores derivados.
- **Como detectar:** revisão de PR em arquivos de workflow, busca nos logs por padrões de chave e alertas de secret scanning. Se aconteceu, rotacionar os secrets e apagar os logs da execução.

### Cenário 3 — O PR do fork

- **O que aconteceu:** um contribuidor externo modificou o workflow no PR para enviar os secrets para um servidor dele.
- **Impacto:** com o evento `pull_request`, o GitHub **não** passa secrets para workflows vindos de forks (chegam vazios) e o `GITHUB_TOKEN` fica só leitura — o ataque direto falha. O risco aparece se o repositório usar `pull_request_target` (roda com secrets) fazendo checkout do código do PR, ou em runners self-hosted, onde o código do atacante roda numa máquina da empresa.
- **Como prevenir:** não usar `pull_request_target` com checkout do código do PR. Exigir **aprovação para rodar workflows de contribuidores externos** (Settings → Actions). Usar `permissions:` mínimas no workflow e não usar runners self-hosted em repositório público. Proteger secrets de produção em **environments** com required reviewers e CODEOWNERS em `.github/workflows/`.
- **Como detectar:** revisão de PRs que alteram workflows, logs de execução e auditoria da organização. Também ajuda monitorar o tráfego de saída dos runners e o uso das credenciais (CloudTrail).
