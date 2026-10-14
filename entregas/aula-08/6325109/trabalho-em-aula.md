# Trabalho em Aula — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** Carina Gonçalves dos Santos Dalpino
**RA:** 6325109
**Data:** 13/10/2026

## Parte 1 — Design de Pipeline CI

### Estágios do pipeline (em ordem)

| Estágio | O que verifica | Obrigatório? | Tempo estimado |
|---------|----------------|:------------:|:--------------:|
| 1. Lint (ESLint) | Padrão de código: aspas, ponto e vírgula, variáveis não usadas | Sim (bloqueia merge) | ~20s |
| 2. Test (Jest + coverage) | Testes unitários dos endpoints e cobertura mínima | Sim (bloqueia merge) | ~40s |
| 3. Build (Docker) | Se a imagem Docker compila sem erro (multi-stage) | Sim (bloqueia merge) | ~1-2 min |
| 4. Smoke test | Sobe o container e checa o /health | Sim (bloqueia merge) | ~15s |

Ordem lógica: lint primeiro (mais rápido e barato, pega erro cedo), depois testes
(falha mais provável), e só então o build Docker (mais custoso). Não faz sentido
gastar tempo no build se o lint ou os testes já falharam — por isso usamos `needs`
encadeando lint -> test -> build.

### Respostas

- **O pipeline deve rodar em:** ambos — `push` para a branch `main` e em `pull_request`.
  Em PR para garantir que código quebrado não entre na main; em push para main como
  verificação final após o merge.
- **Um PR deve ser bloqueado quando:** qualquer job obrigatório falha (lint com erro,
  teste quebrado, build Docker falhando ou smoke test sem resposta no /health).
  Configura-se com *branch protection rules* exigindo os checks verdes.
- **Como o time fica sabendo que quebrou:** pelo status do check no próprio PR (vermelho),
  notificação por e-mail do GitHub, badge de status no README e, opcionalmente, um
  comentário automático do workflow no PR.

### Diagrama

```
[push main / PR] -> [1. lint] -> [2. test] -> [3. build Docker] -> [4. smoke /health] -> [verde/merge liberado]
                        |             |              |                      |
                   falha -> bloqueia  falha -> bloqueia  falha -> bloqueia   falha -> bloqueia
```

## Parte 2 — Análise de Segurança de Credenciais

### Cenário 1 — O `.env` esquecido

- **O que aconteceu:** o `.env` com credenciais AWS reais foi commitado e enviado para a
  main. Deletar em um commit posterior NÃO remove do histórico — `git log` e os objetos
  do git mantêm a versão antiga, acessível a qualquer um com acesso ao repo.
- **Impacto:** com AWS access keys válidas um atacante pode criar recursos (ex: instâncias
  caras para mineração), acessar/exfiltrar dados em S3/RDS, escalar privilégios e gerar
  custos altíssimos na conta.
- **Como prevenir:** a medida que impede 100% é **nunca commitar o segredo** — colocar
  `.env` no `.gitignore` desde o início e usar secrets do GitHub / variáveis de ambiente.
  Complementos: pre-commit hooks com scanner de segredos (git-secrets, gitleaks) e
  push protection do GitHub.
- **Como detectar:** GitHub Secret Scanning, ferramentas como gitleaks/trufflehog varrendo
  o histórico, e alertas de billing/CloudTrail mostrando uso anômalo. Após o vazamento,
  o segredo precisa ser **revogado/rotacionado**, não apenas apagado do código.

### Cenário 2 — O workflow indiscreto

- **O que aconteceu:** um step de debug deu `echo` em secrets nos logs do CI. O GitHub
  mascara valores conhecidos de secrets, mas a máscara não é infalível.
- **Impacto:** se a máscara for contornada, o segredo fica exposto em texto claro nos logs,
  que podem ser vistos por qualquer pessoa com acesso aos Actions (em repo público, todos).
- **Como prevenir:** **nunca** dar echo em secrets, mesmo mascarados. Usar os secrets só
  como variáveis de ambiente passadas direto para o comando que precisa deles; revisar PRs
  que mexem em workflow; aplicar princípio do menor privilégio nas credenciais.
- **Como detectar:** code review do workflow, varredura dos logs em busca de padrões de
  segredo e auditoria dos steps. Lembrar que a máscara é **burlável** por base64, por
  partir a string em substrings, ou via logs de ferramentas de terceiros.

### Cenário 3 — O PR do fork

- **O que aconteceu:** um contribuidor externo abriu um PR de um fork com um step malicioso
  tentando enviar os secrets para um servidor externo (`evil.com`).
- **Impacto:** se os secrets fossem expostos, o atacante roubaria as credenciais AWS do
  repositório. Por isso é um risco crítico em projetos open source.
- **Como prevenir / proteção do GitHub:** o GitHub Actions **NÃO** passa secrets para
  workflows disparados por `pull_request` vindos de forks — é uma proteção de design.
  O `GITHUB_TOKEN` nesses casos fica read-only. Adicionalmente: exigir aprovação para rodar
  workflows de novos contribuidores ("Require approval for all outside collaborators"),
  usar o trigger `pull_request` (não `pull_request_target`) e environments com approval gate.
- **Como detectar:** revisar mudanças em arquivos de workflow em PRs externos, monitorar
  execuções do Actions e alertar sobre steps que fazem requisições de rede para domínios
  desconhecidos.