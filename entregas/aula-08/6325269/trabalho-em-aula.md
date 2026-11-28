# Trabalho em Aula — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** Sirlande Martins  
**RA:** 6325269  
**Data:** 14/10/2026

## Parte 1 — Design de Pipeline CI

```
[push main / PR] → [1: install] → [2: lint] → [3: test + coverage] → [4: docker build] → [5: scan da imagem] → [verde: merge liberado]
                        │              │                │                     │                    │
                  falha → para    falha → bloqueia   falha → bloqueia     falha → bloqueia    CRITICAL → bloqueia
                                  o merge            o merge              o merge             demais → só avisa
```

### Estágios do pipeline (em ordem)
| Estágio | O que verifica | Obrigatório? | Tempo estimado |
|---------|---------------|:------------:|:-------------:|
| 1. Install | `npm ci` a partir do `package-lock.json`, com cache do npm; garante que as dependências (express, pg, dotenv) instalam iguais em qualquer máquina | Sim | ~30 s |
| 2. Lint | ESLint nos 8 arquivos JS (sintaxe, variáveis não usadas, padrão de aspas e ponto e vírgula) | Sim | ~15 s |
| 3. Test | Jest com `--coverage` nos testes que já existem; quebra se algum teste falhar | Sim | ~1 min |
| 4. Build | `docker build` do Dockerfile multi-stage, com a imagem marcada pelo SHA do commit | Sim | ~1–2 min |
| 5. Scan | `npm audit` e scan da imagem (Trivy) atrás de vulnerabilidades conhecidas | Só CRITICAL bloqueia | ~1 min |
| 6. Relatório | Comentário no PR com o resultado e o percentual de cobertura | Não (informativo) | ~10 s |

A ordem vai do mais barato para o mais caro. O lint leva segundos e pega o erro mais bobo, então não faz sentido gastar dois minutos montando imagem para descobrir uma vírgula faltando. O teste vem antes do build porque uma imagem de código quebrado não serve para nada, e o scan fica por último porque precisa da imagem pronta. No total o pipeline fica em torno de 4 a 5 minutos, contra os 32 minutos do deploy manual por SSH, e sem ninguém precisar lembrar de rodar os testes.

### Respostas
- **O pipeline deve rodar em:** nos dois. Em PR, para barrar o problema antes de chegar na `main`, e em push para `main`, para confirmar que o resultado do merge (que pode juntar duas mudanças que passavam sozinhas) continua verde. Coloquei também `concurrency` com `cancel-in-progress` para não acumular execução quando a pessoa faz vários pushes seguidos no mesmo PR.
- **Um PR deve ser bloqueado quando:** qualquer estágio obrigatório falhar (lint, teste, build ou vulnerabilidade CRITICAL), configurando esses jobs como *required status checks* na branch protection da `main`, junto com pelo menos uma aprovação. O comentário de cobertura e os avisos de severidade menor não bloqueiam, só informam.
- **Como o time fica sabendo que quebrou:** o próprio GitHub mostra o X vermelho no PR e manda e-mail para quem fez o push, o comentário automático no PR resume o que falhou, e o badge de status no README deixa visível quando a `main` está quebrada. Num time maior, eu ligaria uma notificação no canal do time (Slack ou Teams) só para falha na `main`, porque ali o problema já afeta todo mundo.

## Parte 2 — Análise de Segurança de Credenciais

### Cenário 1 — O `.env` esquecido
- **O que aconteceu:** o `.env` não estava no `.gitignore` e o `git add .` adicionou tudo sem a pessoa revisar o que estava indo. Apagar o arquivo em outro commit não resolve, porque o commit anterior continua no histórico e qualquer um com acesso ao repositório recupera o arquivo com `git log` e `git show`. Em repositório público existem robôs varrendo o GitHub atrás de chaves AWS em minutos, então duas horas é tempo de sobra para a chave ter sido copiada.
- **Impacto:** com as access keys, o atacante age na conta AWS com as permissões daquele usuário: subir instâncias para minerar criptomoeda (a conta vem depois), ler ou apagar buckets S3, acessar banco e até criar novos usuários IAM para manter o acesso mesmo depois que a chave original for desativada.
- **Como prevenir:** o que impede de verdade é a credencial não existir em arquivo. No CI a autenticação na AWS deve ser via OIDC com role temporária, sem access key guardada em lugar nenhum; localmente, usar `aws configure`/SSO fora do repositório. Como camadas extras: `.env` no `.gitignore` desde o primeiro commit, um `.env.example` sem valores, hook de pre-commit com gitleaks ou git-secrets e o *push protection* do GitHub, que recusa o push quando reconhece um padrão de chave. A resposta ao incidente é revogar e rotacionar a chave imediatamente, e só depois limpar o histórico (git filter-repo ou BFG).
- **Como detectar:** secret scanning do GitHub (que avisa o dono e, no caso da AWS, a própria AWS), gitleaks rodando no CI, CloudTrail mostrando chamadas de API de IP ou região estranha e alerta de billing/Budgets para gasto fora do normal.

### Cenário 2 — O workflow indiscreto
- **O que aconteceu:** alguém colocou um step de debug que imprime os secrets no log, achando que a máscara do GitHub resolve. A máscara só troca por `***` o valor exato do secret como ele está cadastrado, então ela não é 100% segura.
- **Impacto:** basta uma transformação qualquer para o valor sair em claro: `echo $SECRET | base64`, imprimir caractere por caractere, inverter a string, cortar uma substring, ou um secret de várias linhas (como JSON ou chave privada) em que só parte dele é reconhecida. Além disso, logs ficam disponíveis para qualquer pessoa com acesso de leitura ao repositório (em repo público, para qualquer um) e podem ser exportados para ferramentas de terceiros que não fazem máscara nenhuma.
- **Como prevenir:** não permitir echo de secret, nem mascarado. Para debug, imprimir só se a variável existe (`[ -n "$DB_HOST" ] && echo "DB_HOST definido"`) ou o tamanho dela. Usar o secret só por variável de ambiente no step que realmente precisa, com escopo de *environment* quando possível, exigir revisão de quem mexe em `.github/workflows/` (CODEOWNERS) e dar o mínimo de permissão ao `GITHUB_TOKEN`. Se o step já rodou, tratar como vazamento: rotacionar os três valores e apagar os logs da execução.
- **Como detectar:** revisão de código em qualquer mudança de workflow, um check que procura `echo` com `secrets.` nos YAMLs e o próprio aviso de secret scanning se o valor aparecer em algum lugar.

### Cenário 3 — O PR do fork
- **O que aconteceu:** um contribuidor externo tentou usar o PR para rodar código dele com os secrets do repositório. No evento `pull_request` vindo de fork, o GitHub **não** passa secrets (a variável vem vazia) e o `GITHUB_TOKEN` é só de leitura, então esse step específico mandaria campos vazios para o `evil.com`.
- **Impacto:** o risco aparece quando o repositório abre essa porta por conta própria. O caminho mais comum é usar `pull_request_target`, que roda com os secrets e permissões do repositório base, e dentro dele fazer checkout do código do PR e executar (`npm install`, `npm test`), o que roda os scripts do atacante com tudo liberado. Outros caminhos: um workflow `workflow_run` que confia no artefato gerado pelo PR, injeção de comando usando título ou branch do PR dentro de `run:`, ou um runner self-hosted em repo público, que pode ficar comprometido para as próximas execuções.
- **Como prevenir:** manter os PRs de fork em `pull_request` sem secrets; se precisar de `pull_request_target`, nunca fazer checkout do código do PR nesse workflow. Ligar a opção de exigir aprovação de um mantenedor antes de rodar workflow de contribuidor externo, deixar o `GITHUB_TOKEN` como somente leitura por padrão, guardar os secrets de deploy em *environments* com revisor obrigatório, proteger `.github/workflows/` com CODEOWNERS e não usar runner self-hosted em repositório público.
- **Como detectar:** revisar o diff de workflow em todo PR externo antes de aprovar a execução, olhar a aba Actions atrás de execuções inesperadas e acompanhar o CloudTrail; se o repositório tiver saída de rede controlada, chamadas para domínios estranhos durante o job são um sinal claro.
