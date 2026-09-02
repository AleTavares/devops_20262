# Avaliador automático de PRs de TF

Automação que avalia os Pull Requests de Trabalho de Fixação (TF) assim que são
abertos e comenta o parecer no próprio PR.

## Como funciona

1. O workflow `.github/workflows/avaliar-pr-tf.yml` dispara em `pull_request_target`
   (abertura, reabertura e novos commits do PR).
2. O script `avaliar_pr.py`:
   - identifica a aula pelo título do PR (`[Aula 0X] RA: NNN - Nome`);
   - lê os critérios em `aula-XX/TF.md` (do próprio repositório da disciplina);
   - extrai o link do portfólio no `entrega.md` do PR;
   - roda um **pré-check determinístico** no portfólio (arquivos obrigatórios,
     `Condition`/`Deny` nas policies, `.tfstate` versionado, plan vazio, branch);
   - opcionalmente chama o **Amazon Bedrock** para gerar o parecer + nota (0 a 1,5);
   - comenta no PR (e atualiza o mesmo comentário a cada novo push).

> O componente **AWS Academy** não é verificável pelo PR. O bot sempre o marca
> como pendente de conferência do professor e não o inclui na nota automática.

## Segurança

Usamos `pull_request_target` porque PRs vindos de fork não recebem secrets com o
trigger `pull_request` comum. O workflow **faz checkout apenas do repositório base**
(a disciplina) e o script **somente lê dados** (APIs do GitHub e da AWS) — nunca
executa código do fork. Não altere isso para rodar código do PR.

Permissões do workflow: `pull-requests: write` e `contents: read` (mínimo necessário).

## Configuração (uma vez)

No repositório `AleTavares/devops_20262`, em **Settings → Secrets and variables → Actions**:

### Secrets (aba "Secrets")
| Secret | Descrição |
|--------|-----------|
| `AWS_ACCESS_KEY_ID` | Chave de acesso da AWS com permissão para Bedrock |
| `AWS_SECRET_ACCESS_KEY` | Segredo correspondente |
| `AWS_SESSION_TOKEN` | (opcional) só se usar credenciais temporárias/STS |

`GITHUB_TOKEN` é fornecido automaticamente pelo Actions — não precisa criar.

### Variables (aba "Variables") — opcionais
| Variable | Padrão | Descrição |
|----------|--------|-----------|
| `AWS_REGION` | `us-east-2` | Região onde o modelo Bedrock está habilitado |
| `BEDROCK_MODEL_ID` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` | Inference profile do modelo |
| `USE_BEDROCK` | `true` | `false` roda só o pré-check determinístico (sem custo) |

> **Ambiente já validado nesta conta:** região `us-east-2`, usuário IAM
> `automacaotf` com a policy `ci_bedrock` anexada, e o inference profile
> `us.anthropic.claude-haiku-4-5-20251001-v1:0` testado com sucesso. Se quiser um
> parecer mais elaborado (custo maior), troque a variable para
> `us.anthropic.claude-sonnet-4-5-20250929-v1:0`.

### Permissões IAM mínimas para o Bedrock
Nesta região os modelos **só são invocáveis via inference profile** (ID com
prefixo `us.`); o ID direto do foundation model retorna `ValidationException`.
A policy `ci_bedrock` já aplicada ao usuário `automacaotf` cobre o necessário:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream"
      ],
      "Resource": "*"
    }
  ]
}
```

> `Resource: "*"` é aceitável no contexto de aula (cobre foundation models e
> inference profiles). Habilite os modelos em **Amazon Bedrock → Model access**
> na região usada.

## Proteção: só o professor altera a automação

Alunos entregam por **fork** e não têm escrita no repositório da disciplina, então
não conseguem alterar o workflow que roda na `main`. O risco real é um PR malicioso
que edite `.github/` e seja mergeado sem revisão — como o workflow usa
`pull_request_target` (acesso a secrets AWS), isso poderia vazar credenciais.

Camadas de proteção (configurar no GitHub, uma vez):

1. **Fork PR workflows exigem aprovação** — Settings → Actions → General →
   "Fork pull request workflows from outside collaborators" →
   **Require approval for all external contributors**. Nenhum PR de aluno dispara
   o workflow (nem acessa secrets) sem você aprovar a execução.

2. **Branch protection na `main`** — Settings → Branches (ou Rules → Rulesets):
   - Require a pull request before merging
   - **Require review from Code Owners**
   - Restrict who can push → só `@AleTavares`

3. **CODEOWNERS** (`.github/CODEOWNERS`, já incluído) — qualquer PR que toque
   `.github/` ou os `TF.md` exige a sua aprovação antes do merge.

4. **Environment protegido para os secrets** (opcional, camada extra) —
   Settings → Environments → crie `bedrock` com **Required reviewers = você** e
   mova os secrets AWS para esse environment.

5. **Guarda no próprio workflow** (já incluído) — o job aborta antes de usar
   secrets se o PR alterar arquivos sob `.github/` ou qualquer `TF.md`.

## Título do PR

O bot depende do padrão do enunciado para identificar a aula e o RA:

```
[Aula 03] RA: 6325149 - Nome do Aluno
```

Se o título não bater com `Aula 0X`, o bot comenta pedindo para ajustar.

## Rodar sem IA (só pré-check)

Defina a variable `USE_BEDROCK=false`. O bot ainda comenta com os fatos objetivos
(arquivos presentes/faltando, `.tfstate`, plan vazio, branch, Condition/Deny),
sem custo de API. Útil para validar o fluxo antes de ligar o Bedrock.

## Ajustar critérios por aula

Os arquivos obrigatórios por aula ficam em `REQUIRED_BY_AULA`, dentro de
`avaliar_pr.py`. Os critérios de nota vêm de `aula-XX/TF.md`, então basta manter
esses arquivos atualizados no repositório.
```

Teste rápido: abra um PR de teste (ou reabra um existente) e confira o comentário do bot.
```

## Teste local (opcional)

```bash
pip install -r .github/scripts/requirements.txt
export GITHUB_TOKEN=seu_token
export GITHUB_REPOSITORY=AleTavares/devops_20262
export PR_NUMBER=65
export USE_BEDROCK=false   # ou true, com credenciais AWS exportadas
python .github/scripts/avaliar_pr.py
```
