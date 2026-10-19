# Materiais Complementares — Aula 14: Disaster Simulation, Code Review e Agente Bedrock

## Chaos Engineering

### Fundamentos

| Recurso | Descrição | Link |
|---------|-----------|------|
| Principles of Chaos Engineering | Manifesto oficial do Chaos Engineering | https://principlesofchaos.org/ |
| Netflix — Chaos Monkey | Ferramenta pioneira de chaos | https://netflix.github.io/chaosmonkey/ |
| Gremlin — Chaos Engineering Guide | Guia completo com exemplos práticos | https://www.gremlin.com/chaos-engineering/ |
| AWS Fault Injection Simulator | Serviço gerenciado de chaos na AWS | https://aws.amazon.com/fis/ |

### Métricas de Resiliência

| Métrica | Definição |
|---------|-----------|
| **RTO** (Recovery Time Objective) | Tempo máximo aceitável de indisponibilidade |
| **RPO** (Recovery Point Objective) | Perda de dados máxima aceitável |
| **MTTR** (Mean Time To Recovery) | Tempo médio de recuperação real |
| **MTBF** (Mean Time Between Failures) | Tempo médio entre falhas |

### Ferramentas de Chaos

| Ferramenta | Escopo | Link |
|------------|--------|------|
| Chaos Monkey | Netflix — kill de instâncias | https://netflix.github.io/chaosmonkey/ |
| Litmus | Kubernetes — chaos experiments | https://litmuschaos.io/ |
| Chaos Toolkit | Framework extensível (Python) | https://chaostoolkit.org/ |
| Pumba | Docker — chaos para containers | https://github.com/alexei-led/pumba |
| Toxiproxy | Simulação de falhas de rede | https://github.com/Shopify/toxiproxy |

### Vídeos

| Recurso | Link |
|---------|------|
| Chaos Engineering at Netflix | https://www.youtube.com/watch?v=CZ3wIuvmHeM |
| Game Day Best Practices (AWS) | https://www.youtube.com/watch?v=ztiPjey2rfY |
| Principles of Chaos Engineering (Adrian Cockcroft) | https://www.youtube.com/watch?v=Q4nniyAarbs |

---

## Code Review e Governance

### Documentação GitHub

| Recurso | Descrição | Link |
|---------|-----------|------|
| Branch Protection Rules | Configurar proteção de branches | https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-a-branch-protection-rule |
| CODEOWNERS | Definir responsáveis por código | https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners |
| PR Templates | Padronizar Pull Requests | https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository |
| Required Status Checks | Exigir CI passando | https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-a-branch-protection-rule/about-protected-branches#require-status-checks-before-merging |

### Conventional Commits

| Recurso | Descrição | Link |
|---------|-----------|------|
| Conventional Commits (PT-BR) | Especificação em português | https://www.conventionalcommits.org/pt-br/v1.0.0/ |
| commitlint | Lint para mensagens de commit | https://commitlint.js.org/ |
| semantic-release | Release automático baseado em commits | https://semantic-release.gitbook.io/ |
| Commitizen | CLI para commits padronizados | https://commitizen-tools.github.io/commitizen/ |

### Boas Práticas de Code Review

| Recurso | Descrição | Link |
|---------|-----------|------|
| Google — Code Review Guidelines | Guia do Google para reviewers | https://google.github.io/eng-practices/review/ |
| Conventional Comments | Padronizar comentários de review | https://conventionalcomments.org/ |
| How to Review Code Effectively | Artigo sobre review eficiente | https://github.blog/developer-skills/github/how-to-review-code-effectively-a-github-staff-engineers-philosophy/ |

### Tech Debt Management

```markdown
# Template de Issue — Tech Debt

## Título: [TECH-DEBT] Descrição breve

## Descrição
<!-- O que é o débito técnico? -->

## Impacto
<!-- Qual o custo de não resolver? -->
- Performance: 
- Manutenibilidade: 
- Segurança: 

## Proposta de Solução
<!-- Como resolver? -->

## Estimativa de Esforço
- [ ] Pequeno
- [ ] Médio
- [ ] Grande

## Labels
tech-debt, priority:medium
```

---

## AWS Bedrock Agents

### Documentação Oficial

| Recurso | Descrição | Link |
|---------|-----------|------|
| Bedrock Agents — Overview | Conceitos e arquitetura | https://docs.aws.amazon.com/bedrock/latest/userguide/agents.html |
| Create an Agent | Guia passo-a-passo | https://docs.aws.amazon.com/bedrock/latest/userguide/agents-create.html |
| Action Groups | Definir ações do agente | https://docs.aws.amazon.com/bedrock/latest/userguide/agents-action-create.html |
| Knowledge Bases | Configurar RAG | https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html |
| Agent API Reference | API para invocação | https://docs.aws.amazon.com/bedrock/latest/APIReference/API_agent-runtime_InvokeAgent.html |
| Bedrock Pricing | Preços dos modelos | https://aws.amazon.com/bedrock/pricing/ |

### Modelos Disponíveis (para agentes)

| Modelo | Uso Recomendado | Custo Relativo |
|--------|-----------------|----------------|
| Claude 3 Haiku | Code review rápido, tasks simples | $ (mais barato) |
| Claude 3 Sonnet | Análise complexa, design docs | $$ |
| Claude 3.5 Sonnet | Tasks avançadas, reasoning | $$$ |

### Arquitetura de Agentes Bedrock

```
┌─────────────────────────────────────────────────────────┐
│                    Bedrock Agent                          │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │           Orchestration (Foundation Model)        │   │
│  │  - Interpreta input do usuário                    │   │
│  │  - Decide qual action group executar              │   │
│  │  - Consolida resultados                           │   │
│  └──────────────────────────────────────────────────┘   │
│                          │                               │
│         ┌────────────────┼────────────────┐             │
│         ▼                ▼                ▼             │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐       │
│  │Action Group│  │Action Group│  │Action Group│       │
│  │ (Lambda)   │  │ (Lambda)   │  │ (Lambda)   │       │
│  └────────────┘  └────────────┘  └────────────┘       │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │        Knowledge Base (RAG)                       │   │
│  │  S3 → Embeddings → Vector Store → Context        │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

> **☁️ No Learner Lab:** informe a `LabRole` (`arn:aws:iam::<ACCOUNT_ID>:role/LabRole`) como *resource role* do agente — o Lab não permite criar roles IAM nem configurar OIDC (indisponível no Lab). A invocação usa as credenciais temporárias da sessão (`us-east-1`).

### Formato de Evento Lambda (Bedrock Agent)

```python
# Evento recebido pela Lambda quando invocada pelo Bedrock Agent
event = {
    "messageVersion": "1.0",
    "agent": {
        "name": "DevOpsGuardian",
        "id": "AGENT_ID",
        "alias": "ALIAS_ID",
        "version": "1"
    },
    "inputText": "Texto original do usuário",
    "sessionId": "session-uuid",
    "actionGroup": "pr-analyzer",
    "apiPath": "/analyze-pr",
    "httpMethod": "POST",
    "requestBody": {
        "content": {
            "application/json": {
                "properties": [
                    {"name": "prNumber", "type": "integer", "value": "42"},
                    {"name": "diff", "type": "string", "value": "...diff..."}
                ]
            }
        }
    }
}

# Resposta esperada pela Lambda
response = {
    "messageVersion": "1.0",
    "response": {
        "actionGroup": "pr-analyzer",
        "apiPath": "/analyze-pr",
        "httpMethod": "POST",
        "httpStatusCode": 200,
        "responseBody": {
            "application/json": {
                "body": "{\"summary\": \"...\", \"findings\": [...]}"
            }
        }
    }
}
```

---

## Python / Boto3 para Bedrock

### Instalação e Setup

```bash
pip install boto3
aws configure  # Configurar credenciais da sessão do Lab
```

### Invocação de Agente

```python
import boto3
import uuid

client = boto3.client('bedrock-agent-runtime', region_name='us-east-1')

response = client.invoke_agent(
    agentId='YOUR_AGENT_ID',
    agentAliasId='YOUR_ALIAS_ID',
    sessionId=str(uuid.uuid4()),
    inputText='Analise o PR #42 do repositório technova/api'
)

# Processar resposta (streaming)
full_response = ""
for event in response['completion']:
    if 'chunk' in event:
        chunk_text = event['chunk']['bytes'].decode('utf-8')
        full_response += chunk_text

print(full_response)
```

### Invocação Direta de Modelo (sem agente)

```python
import boto3
import json

client = boto3.client('bedrock-runtime', region_name='us-east-1')

response = client.invoke_model(
    modelId='anthropic.claude-3-haiku-20240307-v1:0',
    body=json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 4096,
        "messages": [
            {
                "role": "user",
                "content": "Analise este Dockerfile para problemas de segurança: ..."
            }
        ]
    })
)

result = json.loads(response['body'].read())
print(result['content'][0]['text'])
```

---

## GitHub Actions — Integração com IA

### Padrão: Invocar Bedrock em PR

```yaml
# Padrão reutilizável para invocar Bedrock em qualquer evento
- name: Invoke Bedrock
  env:
    AWS_REGION: us-east-1
  run: |
    python << 'EOF'
    import boto3, json, uuid, os

    client = boto3.client('bedrock-agent-runtime')
    response = client.invoke_agent(
        agentId=os.environ['AGENT_ID'],
        agentAliasId=os.environ['AGENT_ALIAS'],
        sessionId=str(uuid.uuid4()),
        inputText=os.environ['INPUT_TEXT']
    )
    # ... processar response
    EOF
```

### Actions Úteis

| Action | Uso | Link |
|--------|-----|------|
| actions/github-script@v7 | Comentar em PRs/Issues via API | https://github.com/actions/github-script |
| aws-actions/configure-aws-credentials@v4 | Autenticar na AWS (com aws-session-token no Lab) | https://github.com/aws-actions/configure-aws-credentials |
| actions/setup-python@v5 | Configurar Python | https://github.com/actions/setup-python |

---

## OpenAPI / Swagger

### Documentação

| Recurso | Descrição | Link |
|---------|-----------|------|
| OpenAPI Specification | Spec completa v3.0 | https://swagger.io/specification/ |
| Swagger Editor | Editor online de schemas | https://editor.swagger.io/ |
| Bedrock Agent — OpenAPI Schema | Formato esperado pelo Bedrock | https://docs.aws.amazon.com/bedrock/latest/userguide/agents-api-schema.html |

### Exemplo Mínimo para Bedrock

```yaml
openapi: 3.0.0
info:
  title: Agent API
  version: 1.0.0
paths:
  /my-action:
    post:
      operationId: myAction
      summary: Descrição da ação
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                param1:
                  type: string
                  description: Descrição do parâmetro
      responses:
        '200':
          description: Sucesso
          content:
            application/json:
              schema:
                type: object
                properties:
                  result:
                    type: string
```

---

## Docker — Chaos Engineering

### Comandos Úteis para Chaos

```bash
# Matar container abruptamente (SIGKILL)
docker kill CONTAINER_NAME

# Pausar container (simula freeze)
docker pause CONTAINER_NAME
docker unpause CONTAINER_NAME

# Limitar recursos em runtime
docker update --memory=64m CONTAINER_NAME

# Verificar restart count
docker inspect --format='{{.RestartCount}}' CONTAINER_NAME

# Health check status
docker inspect --format='{{.State.Health.Status}}' CONTAINER_NAME

# Simular rede lenta (requer tc dentro do container)
docker exec CONTAINER_NAME tc qdisc add dev eth0 root netem delay 500ms

# Desconectar da rede
docker network disconnect NETWORK CONTAINER_NAME
```

### Docker Compose — Restart Policies

```yaml
services:
  app:
    restart: "no"             # Nunca reinicia
    restart: always           # Sempre reinicia
    restart: on-failure       # Só reinicia se exit code != 0
    restart: unless-stopped   # Reinicia exceto se parado manualmente
```

---

## Referência Rápida — Comandos da Aula

```bash
# === Chaos Engineering ===
docker kill CONTAINER                    # Simular crash
docker pause CONTAINER                   # Simular freeze
docker-compose -f file.yml kill          # Kill all
docker inspect --format='...' CONTAINER  # Verificar estado
curl -w "time: %{time_total}" URL        # Medir latência

# === Governance ===
# Branch protection: via GitHub UI (Settings → Branches)
# CODEOWNERS: .github/CODEOWNERS
# PR template: .github/pull_request_template.md

# === Bedrock Agent ===
pip install boto3                        # Instalar SDK
python test_local.py                     # Testar lambdas localmente
terraform init && terraform validate     # Validar infra do agente

# === GitHub Actions ===
gh workflow run WORKFLOW                  # Disparar workflow manualmente
gh pr create --title "..."               # Criar PR via CLI
gh pr view                               # Ver PR atual
```

---

## Leitura Recomendada para Aprofundamento

1. **"Chaos Engineering"** — Casey Rosenthal, Nora Jones (O'Reilly)
2. **"Site Reliability Engineering"** — Google (SRE Book) — https://sre.google/sre-book/
3. **"Building Intelligent Cloud Applications"** — AWS (Bedrock focused)
4. **"Software Engineering at Google"** — Titus Winters et al. (Code Review chapter)
5. **"Accelerate"** — Nicole Forsgren, Jez Humble (DevOps metrics)

---

## Conexão com AI Track do Curso

| Aula | Skill Aprendida | Como usa na Aula 14 |
|------|-----------------|---------------------|
| 02 | Invocar Bedrock, prompt engineering | Agent instruction prompt |
| 07 | Análise de Dockerfile com IA | Lambda analyze_pr (Docker checks) |
| 09 | Pipeline data como input de IA | Métricas de chaos como contexto |
| 12 | Agentes Bedrock, deploy inteligente | Arquitetura completa do agente |
| **14** | **Capstone: tudo junto** | **Agente DevOps completo** |
