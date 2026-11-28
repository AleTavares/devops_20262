# Trabalho em Aula — Aula 08: GitHub Actions e CI Pipelines

**Aluno:** Felipe Damasceno  
**RA:** 6325128  
**Data:** 08/10/2026

---

## Parte 1 — Design de Pipeline CI

### Diagrama do Pipeline

```
[push para main / abertura de PR]
        │
        ▼
[1. Lint & Format Check]  ──── falha ──→ bloqueia (problema de qualidade de código)
        │
        ▼
[2. Instalação de Dependências]  ──── falha ──→ bloqueia (dependências inválidas/ausentes)
        │
        ▼
[3. Auditoria de Segurança (npm audit)]  ──── falha ──→ bloqueia se crítico, avisa se moderado
        │
        ▼
[4. Testes Automatizados]  ──── falha ──→ bloqueia (regressão funcional)
        │
        ▼
[5. Build da Imagem Docker]  ──── falha ──→ bloqueia (imagem não pode ser gerada)
        │
        ▼
[6. Análise de Cobertura de Testes]  ──── falha ──→ apenas avisa (informativo)
        │
        ▼
[✅ Pipeline aprovado — PR liberado para merge]
```

### Estágios do Pipeline (em ordem)

| # | Estágio | O que verifica | Obrigatório? | Tempo estimado | O que acontece se falhar? |
|---|---------|---------------|:------------:|:--------------:|--------------------------|
| 1 | **Lint & Format Check** | Padrão de código (ESLint + Prettier), erros de sintaxe | ✅ Sim | ~1 min | Bloqueia o pipeline — código fora do padrão não avança |
| 2 | **Instalação de dependências** | `npm ci` executa sem erros, `package-lock.json` consistente | ✅ Sim | ~1–2 min | Bloqueia — sem dependências instaladas, nada mais roda |
| 3 | **Auditoria de segurança** | `npm audit` verifica vulnerabilidades conhecidas nas deps | ✅ Sim (nível crítico) | ~30 seg | Bloqueia se houver vulnerabilidade crítica/alta; avisa para moderadas |
| 4 | **Testes automatizados** | Execução da suite de testes existente (unitários + integração) | ✅ Sim | ~3–5 min | Bloqueia — falha de teste indica regressão funcional |
| 5 | **Build da imagem Docker** | `docker build` do Dockerfile multi-stage conclui sem erro | ✅ Sim | ~3–5 min | Bloqueia — imagem quebrada não pode ir para deploy |
| 6 | **Cobertura de testes** | Percentual de cobertura (ex: meta mínima de 70%) | ⚠️ Opcional | ~30 seg (relatório) | Apenas avisa — útil para visibilidade mas não bloqueia merge |

### Respostas às Perguntas

**O pipeline deve rodar em push para main, em PRs, ou ambos?**  
Em **ambos**. O pipeline deve rodar em toda abertura/atualização de PR, garantindo que o código seja validado antes do merge. Deve também rodar em push direto para `main` (ex: hotfixes ou merges) para garantir que o estado da branch principal é sempre válido. Dessa forma, nenhum código não testado chega à branch principal.

**Quando um PR deveria ser bloqueado de merge?**  
Um PR deve ser bloqueado quando qualquer estágio obrigatório falhar: lint com erro, falha na instalação de dependências, vulnerabilidade crítica de segurança, qualquer teste falhando ou falha no build da imagem Docker. O merge só deve ser liberado quando todos os checks obrigatórios passarem com sucesso (status verde no GitHub).

**Como o time fica sabendo que algo quebrou?**  
O GitHub Actions sinaliza o status diretamente no PR (✅/❌ nos checks). Além disso, o time deve configurar **notificações por e-mail ou Slack** para falhas no pipeline (via GitHub Actions integrations ou webhooks). Para a branch `main`, uma falha deve gerar alerta imediato no canal de DevOps da equipe.

---

## Parte 2 — Análise de Segurança de Credenciais

---

### Cenário 1 — O `.env` esquecido

**O que aconteceu (causa raiz):**  
O desenvolvedor usou `git add .` sem ter um `.gitignore` que excluísse arquivos `.env`. O arquivo com credenciais AWS reais foi comitado e enviado ao repositório remoto. Um commit posterior apagou o arquivo, mas o histórico do Git permanece imutável.

**Impacto (o que um atacante pode fazer):**  
As credenciais AWS permanecem visíveis para qualquer pessoa que clonar o repositório ou acessar o histórico via `git log` / `git show`. Com as access keys AWS, um atacante pode: provisionar infraestrutura (EC2, RDS, Lambda), exfiltrar dados do S3, elevar privilégios via IAM, gerar custos massivos e causar interrupção de serviços. O dano é proporcional às permissões da conta AWS comprometida.

**As credenciais estão seguras após o commit de deleção?**  
**Não.** O commit de deleção remove o arquivo do estado atual da branch, mas o Git mantém todo o histórico. O arquivo ainda existe no objeto de commit anterior e pode ser acessado com `git checkout <hash_do_commit_antigo> -- .env` ou simplesmente com `git log -p`. Qualquer pessoa com acesso ao repositório (ou um fork já feito antes da deleção) pode recuperar as credenciais.

**Como prevenir:**
- Adicionar `.env` (e variações como `.env.local`, `.env.*`) ao `.gitignore` **antes** do primeiro commit.
- Usar ferramentas como **git-secrets** ou **gitleaks** em hooks de pre-commit para detectar padrões de credenciais antes do push.
- Nunca usar credenciais pessoais/reais em ambientes de desenvolvimento local — usar variáveis de ambiente do sistema ou um vault (ex: AWS SSM, HashiCorp Vault).

**Como detectar:**
- Habilitar o **GitHub Secret Scanning** (disponível em repos públicos automaticamente e em privados com GitHub Advanced Security) — o GitHub notifica quando padrões de secrets conhecidos são detectados em commits.
- Monitorar logs do **AWS CloudTrail** para acessos inesperados ou de IPs desconhecidos usando as credenciais comprometidas.
- Configurar alertas no **AWS GuardDuty** para atividade anômala.

**Ação imediata após exposição:**  
Revogar as credenciais imediatamente no console AWS (IAM → Access Keys → Delete). A deleção do commit não é suficiente — o secret deve ser tratado como comprometido e substituído.

---

### Cenário 2 — O workflow indiscreto

**O que aconteceu (causa raiz):**  
Um desenvolvedor adicionou um step de debug no workflow de CI que usa `echo` para imprimir valores de secrets do repositório. Embora o GitHub substitua os valores exatos de secrets por `***` nos logs, o dado em si é passado ao processo e pode vazar de formas indiretas.

**Impacto:**  
Os secrets são expostos no ambiente de execução do runner. Mesmo que o log mostre `***`, o valor real está na memória do processo `echo` e pode ser capturado por outras formas.

**O GitHub mascara secrets nos logs. Isso é 100% seguro?**  
**Não.** A máscara do GitHub é uma proteção superficial baseada em correspondência de string simples. Ela pode ser contornada em diversas situações:

- **Encoding alternativo:** `echo ${{ secrets.DB_PASS }} | base64` produz uma string diferente que não é reconhecida como secret e aparece nos logs em claro.
- **Substrings:** Se o secret for longo, exibir apenas parte dele (ex: via `cut`, `head`, substring em script) pode expor fragmentos úteis.
- **Logs de terceiros:** Steps que enviam saída para sistemas externos (Datadog, Splunk, Sentry) podem capturar o valor antes da máscara ser aplicada.
- **Artefatos:** Se o valor for gravado em um arquivo e esse arquivo for publicado como artefato do workflow, a máscara não se aplica.

**Como prevenir:**
- **Nunca usar `echo` com secrets**, independente da máscara. É uma regra absoluta.
- Fazer code review obrigatório de workflows (arquivos `.github/workflows/`) com pelo menos um aprovador.
- Usar **branch protection rules** para exigir revisão antes de qualquer merge, incluindo mudanças em workflows.
- Considerar o uso de **OpenID Connect (OIDC)** para autenticação com cloud providers (AWS, GCP, Azure) eliminando a necessidade de secrets estáticos.

**Como detectar:**
- Auditar periodicamente os arquivos de workflow em busca de uso de `echo`, `print`, `cat` com referências a `secrets.*`.
- Habilitar alertas do **GitHub Advanced Security** para padrões de uso inseguro de secrets.
- Monitorar o histórico de execuções do Actions para identificar steps suspeitos de debug adicionados recentemente.

---

### Cenário 3 — O PR do fork

**O que aconteceu (causa raiz):**  
Um contribuidor externo, com intenção maliciosa, fez fork do repositório open source, modificou o arquivo de workflow para incluir um step que tenta exfiltrar secrets do repositório original via `curl`, e abriu um PR. O atacante esperava que o GitHub passasse os secrets ao workflow durante a execução do CI no contexto do repositório original.

**O GitHub passa secrets para workflows de PRs de forks?**  
**Não.** Por design de segurança, o GitHub Actions **não passa secrets do repositório para workflows disparados por `pull_request` originados de forks**. Esse é um comportamento intencional e documentado. O step malicioso receberia strings vazias para `${{ secrets.AWS_ACCESS_KEY_ID }}` e `${{ secrets.AWS_SECRET_ACCESS_KEY }}`.

**Como o atacante poderia tentar contornar isso:**
- **`pull_request_target`:** Se o repositório usar o evento `pull_request_target` em vez de `pull_request`, o workflow roda no contexto do repositório original (não do fork) e **tem acesso aos secrets**. Isso é um vetor real de ataque — o atacante poderia abrir um PR esperando que o workflow use `pull_request_target` sem as devidas proteções.
- **Engenharia social / comprometimento de mantenedor:** Convencer um mantenedor a rodar o workflow manualmente (`workflow_dispatch`) com o código malicioso presente.
- **Cache poisoning:** Manipular o cache de dependências do CI para injetar código malicioso que executa em workflows futuros do repositório original.

**Como prevenir:**
- **Nunca usar `pull_request_target` para executar código do PR de forks** sem revisão explícita prévia.
- Usar **ambientes protegidos** (Environments no GitHub com `required reviewers`) para qualquer job que acesse secrets.
- Separar workflows: manter um workflow sem secrets para PRs de forks (build/test apenas) e um workflow separado, protegido, para deploys — disparado apenas por push para `main` após merge aprovado.
- Habilitar a opção **"Require approval for first-time contributors"** nas configurações do Actions do repositório.
- Revisar manualmente qualquer mudança em arquivos `.github/workflows/` em PRs de forks antes de aprovar/executar o CI.

**Como detectar:**
- Monitorar PRs que modificam arquivos em `.github/workflows/` — isso deve acionar revisão obrigatória de segurança.
- Usar o **GitHub Dependabot** e o Code Scanning para identificar padrões suspeitos.
- Revisar logs de execução do Actions para requests de rede inesperados (ex: `curl` para domínios externos desconhecidos).
- Configurar alertas no AWS CloudTrail/GuardDuty para tentativas de uso de credenciais inválidas (mesmo com strings vazias, tentativas de chamada à API com credenciais malformadas podem ser logadas).
