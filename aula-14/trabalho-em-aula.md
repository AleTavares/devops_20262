# Aula 14 — Trabalho em Aula

## Objetivo

Consolidar, de forma prática, os três pilares da aula capstone de IA: executar experimentos de Chaos Engineering medindo RTO, estabelecer governance no repositório, e projetar/implementar o agente DevOps com AWS Bedrock (DevOps Guardian) rodando no Learner Lab.

**Formato:** Prática individual guiada (duas partes)

---

## Contexto Narrativo

O CTO reúne a equipe da TechNova para um desafio duplo: *"Primeiro, vamos provar que nosso sistema aguenta pancada — quebrem intencionalmente e meçam. Depois, vamos construir nosso próprio engenheiro DevOps virtual com Bedrock. Ele vai revisar PRs, detectar drift e gerar runbooks."*

Este é o trabalho que consolida Chaos Engineering, Code Governance, e IA aplicada a DevOps — o capstone de inteligência artificial do curso.

---

## Parte 1 — Disaster Simulation + Code Review

### Atividade 1.1 — Setup do Ambiente de Chaos

**Objetivo:** Preparar infraestrutura para experimentos controlados de falha.

**Tarefas:**

1. Criar diretório de trabalho:

```bash
mkdir -p chaos-experiments
cd chaos-experiments
```

2. Criar `docker-compose.chaos.yml` com ambos os serviços TechNova:

```yaml
version: '3.8'

services:
  technova-api:
    build:
      context: ../app-technova
    ports:
      - "3000:3000"
    environment:
      - PORT=3000
      - NOTIFICATIONS_URL=http://technova-notifications:3001
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--spider", "http://localhost:3000/health"]
      interval: 5s
      timeout: 3s
      start_period: 10s
      retries: 3
    networks:
      - chaos-net

  technova-notifications:
    build:
      context: ../technova-notifications
    ports:
      - "3001:3001"
    environment:
      - PORT=3001
      - NODE_ENV=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--spider", "http://localhost:3001/health"]
      interval: 5s
      timeout: 3s
      start_period: 10s
      retries: 3
    networks:
      - chaos-net

networks:
  chaos-net:
    driver: bridge
```

3. Subir e validar:

```bash
docker-compose -f docker-compose.chaos.yml up -d --build
sleep 10
curl http://localhost:3000/health | jq .
curl http://localhost:3001/health | jq .
```

---

### Atividade 1.2 — Chaos Experiments

**Objetivo:** Executar 3 experimentos de falha e documentar resultados.

#### Experimento 1 — Container Kill + Recovery

**Hipótese:** Container se recupera em < 30 segundos via restart policy.

```bash
# Terminal 1: Monitorar
watch -n 2 'curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/health'

# Terminal 2: Matar container
echo "Timestamp falha: $(date +%H:%M:%S)"
docker kill $(docker-compose -f docker-compose.chaos.yml ps -q technova-notifications)

# Observar monitor até retornar 200
echo "Timestamp recovery: $(date +%H:%M:%S)"
```

**Registrar:**

| Métrica | Valor |
|---------|-------|
| Hora da falha | ________ |
| Hora da recuperação | ________ |
| RTO medido | ________ segundos |
| Hipótese validada? | Sim / Não |

#### Experimento 2 — Degradação Graceful (Notifications Down)

**Hipótese:** API continua criando pedidos mesmo com notifications indisponível.

```bash
# Parar notifications
docker-compose -f docker-compose.chaos.yml stop technova-notifications

# Tentar criar pedido
curl -X POST http://localhost:3000/orders \
  -H "Content-Type: application/json" \
  -d '{"product":"Teste Resilience","quantity":1}' | jq .

# Esperado: pedido criado com notification.sent = false (não erro 500)

# Restaurar
docker-compose -f docker-compose.chaos.yml start technova-notifications
```

**Registrar:**

| Métrica | Valor |
|---------|-------|
| API respondeu durante falha? | Sim / Não |
| Status code retornado | ________ |
| Campo notification.sent | true / false |
| Pedido foi criado? | Sim / Não |

#### Experimento 3 — Full System Kill + Recovery

**Hipótese:** Sistema completo se recupera em < 60 segundos.

```bash
# Matar tudo
echo "Kill: $(date +%H:%M:%S)"
docker-compose -f docker-compose.chaos.yml kill

# Reiniciar
docker-compose -f docker-compose.chaos.yml up -d

# Monitorar até ambos estarem UP
while true; do
  API=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health 2>/dev/null)
  NOTIF=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/health 2>/dev/null)
  echo "$(date +%H:%M:%S) | API: $API | Notifications: $NOTIF"
  if [ "$API" = "200" ] && [ "$NOTIF" = "200" ]; then
    echo "RECOVERED: $(date +%H:%M:%S)"
    break
  fi
  sleep 2
done
```

**Registrar:**

| Métrica | Valor |
|---------|-------|
| Hora do kill | ________ |
| Hora recovery completo | ________ |
| RTO total | ________ segundos |
| Qual serviço voltou primeiro? | ________ |

---

### Atividade 1.3 — Governance Setup

**Objetivo:** Configurar branch protection, CODEOWNERS, PR template e conventional commits.

#### Passo 1: Branch Protection (GitHub UI)

Acessar **Settings → Branches → Add branch protection rule** para `main`:

- [x] Require pull request reviews before merging (1 review)
- [x] Dismiss stale pull request approvals
- [x] Require status checks to pass before merging
- [x] Require conversation resolution before merging

**Evidência:** Screenshot da configuração salva.

#### Passo 2: CODEOWNERS

Criar `.github/CODEOWNERS`:

```
# Infraestrutura
/terraform/              @SEU-USUARIO
/.github/workflows/      @SEU-USUARIO
/docker-compose*.yml     @SEU-USUARIO

# Backend
/app-technova/           @SEU-USUARIO
/technova-notifications/ @SEU-USUARIO

# Agente DevOps
/bedrock-agent/          @SEU-USUARIO

# Docs
*.md                     @SEU-USUARIO
```

#### Passo 3: PR Template

Criar `.github/pull_request_template.md`:

```markdown
## Descrição

<!-- O que este PR faz? -->

## Tipo de Mudança

- [ ] Bug fix
- [ ] Nova feature
- [ ] Breaking change
- [ ] Infraestrutura
- [ ] Documentação

## Checklist

- [ ] Lint passa (`npm run lint`)
- [ ] Testes passam (`npm test`)
- [ ] Container builda (`docker build`)
- [ ] Revisei meu próprio código

## Como Testar

```bash
# Instruções para o reviewer
```

## Screenshots / Evidências

<!-- Adicionar se aplicável -->
```

#### Passo 4: Conventional Commits

Instalar e configurar localmente:

```bash
# Instalar commitlint (opcional — para validar local)
npm install --save-dev @commitlint/cli @commitlint/config-conventional

# Criar commitlint.config.js
echo "module.exports = { extends: ['@commitlint/config-conventional'] };" > commitlint.config.js
```

Exemplos de commits válidos:

```bash
git commit -m "feat(chaos): adicionar script de game day"
git commit -m "docs(governance): criar CODEOWNERS e PR template"
git commit -m "ci(agent): workflow de review automático com Bedrock"
```

---

### Atividade 1.4 — Game Day Report

**Objetivo:** Compilar resultados dos experimentos em um relatório formal.

Criar `chaos-experiments/game-day-report.md`:

```markdown
# Game Day Report — TechNova

## Informações Gerais
- **Data:** [DATA]
- **Participante:** [NOME — RA]
- **Ambiente:** Docker local (docker-compose)
- **Serviços testados:** technova-api, technova-notifications

## Resumo Executivo

| Hipótese | Resultado | RTO Medido | Meta |
|----------|-----------|------------|------|
| H1: Container Recovery | ✅/❌ | ___s | < 30s |
| H2: Degradação Graceful | ✅/❌ | N/A | API não falha |
| H3: Full System Recovery | ✅/❌ | ___s | < 60s |

## Detalhes dos Experimentos

### H1 — Container Kill Recovery
- Restart policy: unless-stopped
- Docker health check interval: 5s
- RTO medido: ___s
- Comportamento observado: ...

### H2 — Degradação Graceful
- Comportamento do API quando notifications está down: ...
- Resiliência implementada: try/catch na chamada HTTP
- Pattern: Circuit breaker simplificado

### H3 — Full System Recovery
- Ordem de recuperação: ...
- Dependência entre serviços: ...
- RTO total: ___s

## Melhorias Identificadas

1. [ ] ...
2. [ ] ...
3. [ ] ...

## Lições Aprendidas

- ...
- ...
```

**Checklist Parte 1:**

- [ ] 3 experimentos de chaos executados
- [ ] RTO medido em cada experimento
- [ ] Branch protection configurada
- [ ] CODEOWNERS criado
- [ ] PR template criado
- [ ] Game Day report completo
- [ ] Screenshots/evidências capturadas

---

## Parte 2 — Building the Bedrock DevOps Agent

> **☁️ Learner Lab:** o agente e as Lambdas usam a role pré-existente `LabRole` (`arn:aws:iam::<ACCOUNT_ID>:role/LabRole`) — o Lab **não permite criar roles IAM**. A autenticação usa as credenciais temporárias da sessão (`us-east-1`); o OIDC fica apenas como referência de produção **indisponível** no Lab.

### Atividade 2.1 — Design do Agente

**Objetivo:** Projetar a arquitetura do agente DevOps com Bedrock.

**Tarefas:**

1. Criar estrutura do projeto:

```bash
mkdir -p bedrock-agent/{schemas,lambdas/{analyze_pr,detect_drift,generate_runbook},terraform,knowledge-base}
```

2. Escrever o Agent Instruction Prompt em `bedrock-agent/agent-instruction.md`:

```markdown
Você é o DevOps Guardian da TechNova — um engenheiro DevOps senior virtual.

## Suas Capacidades
1. Analisar Pull Requests: segurança, padrões Docker/Terraform, conventional commits
2. Detectar Drift: comparar infraestrutura real vs declarada
3. Gerar Runbooks: documentar procedimentos operacionais

## Regras
- Sempre cite arquivo e linha específicos nos findings
- Priorize segurança (credentials, permissões abertas)
- Use português brasileiro
- Seja acionável: cada problema precisa de uma sugestão de correção
- Consulte a knowledge base para contexto histórico

## Padrões TechNova
- Docker: multi-stage, non-root, HEALTHCHECK
- Terraform: tags Name, Project, Environment, ManagedBy
- Commits: conventional commits (feat, fix, docs, chore)
- Testes: cobertura mínima 80%
```

3. Criar o schema OpenAPI (`bedrock-agent/schemas/api-schema.yaml`) definindo os 3 endpoints:
   - `POST /analyze-pr` — recebe diff, retorna findings
   - `POST /detect-drift` — recebe dir terraform, retorna drift
   - `POST /generate-runbook` — recebe cenário, retorna runbook

4. Criar o design document (`bedrock-agent/DESIGN.md`):

```markdown
# DevOps Agent — Design Document

## Visão Geral
Agente autônomo que governa o ciclo DevOps da TechNova via AWS Bedrock.

## Arquitetura

```
GitHub Event → GitHub Actions → Bedrock Agent → Action Groups (Lambda) → Response
                                      ↕
                              Knowledge Base (S3 + Embeddings)
```

## Action Groups

| Nome | Lambda | Trigger | Output |
|------|--------|---------|--------|
| PR Analyzer | analyze_pr | PR opened/updated | Comentário no PR |
| Drift Detector | detect_drift | Schedule/PR com label infra | Report no PR |
| Runbook Generator | generate_runbook | Issue com label runbook-needed | Commit no repo |

## Knowledge Base
- **Fonte:** S3 bucket com documentos
- **Conteúdo:** Runbooks existentes, padrões de arquitetura, histórico de incidentes
- **Embedding:** Amazon Titan Text Embeddings v2
- **Vector Store:** OpenSearch Serverless

## Modelo
- **Foundation Model:** Claude 3 Haiku (rápido e econômico para code review)
- **Fallback:** Análise regex local se Bedrock indisponível

## Permissões (Learner Lab)
- **Resource role:** LabRole (arn:aws:iam::<ACCOUNT_ID>:role/LabRole) — sem criar IAM

## Decisões de Design
1. Lambdas separadas por action group (responsabilidade única)
2. Fallback local para não bloquear pipelines se AWS falhar
3. Truncar diffs > 50KB para respeitar limites de contexto
4. Conventional commits verificados no título do PR
```

---

### Atividade 2.2 — Implementação das Lambdas

**Objetivo:** Implementar as 3 Lambda functions que servem como action groups.

#### Lambda 1: analyze_pr

Criar `bedrock-agent/lambdas/analyze_pr/handler.py`:

```python
"""Análise automatizada de Pull Requests."""
import json
import re


def lambda_handler(event, context):
    """Analisa diff de PR buscando problemas."""
    parameters = extract_parameters(event)
    diff = parameters.get('diff', '')
    pr_title = parameters.get('prTitle', '')

    findings = []

    # Segurança: credentials hardcoded
    security_patterns = [
        (r'password\s*=\s*["\'].+["\']', 'Possível senha hardcoded'),
        (r'(api_key|secret|token)\s*=\s*["\'].+["\']', 'Possível secret hardcoded'),
        (r'0\.0\.0\.0/0', 'CIDR aberto — acesso irrestrito'),
    ]

    for pattern, message in security_patterns:
        if re.search(pattern, diff, re.IGNORECASE):
            findings.append({
                'type': 'security',
                'severity': 'error',
                'message': message,
                'suggestion': 'Use variáveis de ambiente ou AWS Secrets Manager'
            })

    # Docker: boas práticas
    if 'Dockerfile' in diff:
        if 'USER' not in diff:
            findings.append({
                'type': 'security',
                'severity': 'warning',
                'message': 'Dockerfile sem USER — rodará como root',
                'suggestion': 'Adicionar USER non-root'
            })
        if 'HEALTHCHECK' not in diff:
            findings.append({
                'type': 'improvement',
                'severity': 'warning',
                'message': 'Dockerfile sem HEALTHCHECK',
                'suggestion': 'Adicionar HEALTHCHECK instruction'
            })

    # Conventional commits no título
    valid_prefixes = 'feat|fix|docs|style|refactor|test|chore|ci'
    if pr_title and not re.match(rf'^({valid_prefixes})(\(.+\))?: .+', pr_title):
        findings.append({
            'type': 'style',
            'severity': 'info',
            'message': f'Título não segue conventional commits: "{pr_title}"',
            'suggestion': 'Formato: tipo(escopo): descrição'
        })

    # Resultado
    risk_level = 'high' if any(f['severity'] == 'error' for f in findings) else 'low'
    recommendation = 'request_changes' if risk_level == 'high' else 'approve'

    result = {
        'summary': f'{len(findings)} finding(s). Risco: {risk_level}',
        'riskLevel': risk_level,
        'findings': findings,
        'recommendation': recommendation
    }

    return format_response(event, result)


def extract_parameters(event):
    props = event.get('requestBody', {}).get('content', {}).get(
        'application/json', {}).get('properties', [])
    return {p['name']: p['value'] for p in props}


def format_response(event, result):
    return {
        'messageVersion': '1.0',
        'response': {
            'actionGroup': event.get('actionGroup', ''),
            'apiPath': event.get('apiPath', ''),
            'httpMethod': 'POST',
            'httpStatusCode': 200,
            'responseBody': {
                'application/json': {
                    'body': json.dumps(result, ensure_ascii=False)
                }
            }
        }
    }
```

#### Lambda 2: detect_drift

Criar `bedrock-agent/lambdas/detect_drift/handler.py`:

```python
"""Detecção de drift de infraestrutura."""
import json


def lambda_handler(event, context):
    """Detecta drift entre estado declarado e real."""
    parameters = extract_parameters(event)
    terraform_dir = parameters.get('terraformDir', '')
    environment = parameters.get('environment', 'staging')

    # Em produção: executar terraform plan -detailed-exitcode
    # Aqui: simulamos padrões comuns de drift
    drifted_resources = [
        {
            'resourceType': 'aws_security_group',
            'resourceName': 'technova-notifications-sg',
            'attribute': 'ingress.cidr_blocks',
            'expected': '["10.0.0.0/16"]',
            'actual': '["0.0.0.0/0"]'
        }
    ]

    remediation = [
        'Executar: terraform apply -target=aws_security_group.notifications',
        'Verificar quem alterou o SG manualmente (CloudTrail)',
        'Adicionar SCP para impedir alterações manuais'
    ]

    result = {
        'hasDrift': True,
        'driftedResources': drifted_resources,
        'remediationSteps': remediation
    }

    return format_response(event, result)


def extract_parameters(event):
    props = event.get('requestBody', {}).get('content', {}).get(
        'application/json', {}).get('properties', [])
    return {p['name']: p['value'] for p in props}


def format_response(event, result):
    return {
        'messageVersion': '1.0',
        'response': {
            'actionGroup': event.get('actionGroup', ''),
            'apiPath': event.get('apiPath', ''),
            'httpMethod': 'POST',
            'httpStatusCode': 200,
            'responseBody': {
                'application/json': {
                    'body': json.dumps(result, ensure_ascii=False)
                }
            }
        }
    }
```

#### Lambda 3: generate_runbook

Criar `bedrock-agent/lambdas/generate_runbook/handler.py`:

```python
"""Geração automática de runbooks."""
import json
from datetime import datetime


def lambda_handler(event, context):
    """Gera runbook baseado em cenário de incidente."""
    parameters = extract_parameters(event)
    scenario = parameters.get('scenario', '')
    severity = parameters.get('severity', 'medium')
    services = parameters.get('affectedServices', 'technova-notifications')

    if isinstance(services, str):
        services = [s.strip() for s in services.split(',')]

    service = services[0] if services else 'technova-notifications'

    runbook = {
        'title': f'Runbook: {scenario}',
        'severity': severity,
        'estimatedTime': '5-15 minutos',
        'generatedAt': datetime.utcnow().isoformat(),
        'steps': [
            {
                'order': 1,
                'action': 'Verificar status do serviço',
                'command': f'docker ps -a --filter name={service}',
                'expectedResult': 'Identificar estado atual do container',
                'rollback': 'N/A'
            },
            {
                'order': 2,
                'action': 'Verificar logs recentes',
                'command': f'docker logs --tail 50 {service}',
                'expectedResult': 'Identificar causa raiz',
                'rollback': 'N/A'
            },
            {
                'order': 3,
                'action': 'Reiniciar serviço',
                'command': f'docker restart {service}',
                'expectedResult': 'Container em estado Running',
                'rollback': f'docker stop {service}'
            },
            {
                'order': 4,
                'action': 'Validar health check',
                'command': 'curl -f http://localhost:3001/health',
                'expectedResult': 'HTTP 200 — status: healthy',
                'rollback': 'Escalar para equipe de infra'
            }
        ],
        'prevention': [
            'Configurar alertas de memória (threshold 80%)',
            'Implementar graceful shutdown',
            'Adicionar health check com interval mais curto',
            'Documentar no postmortem'
        ]
    }

    return format_response(event, runbook)


def extract_parameters(event):
    props = event.get('requestBody', {}).get('content', {}).get(
        'application/json', {}).get('properties', [])
    return {p['name']: p['value'] for p in props}


def format_response(event, result):
    return {
        'messageVersion': '1.0',
        'response': {
            'actionGroup': event.get('actionGroup', ''),
            'apiPath': event.get('apiPath', ''),
            'httpMethod': 'POST',
            'httpStatusCode': 200,
            'responseBody': {
                'application/json': {
                    'body': json.dumps(result, ensure_ascii=False)
                }
            }
        }
    }
```

---

### Atividade 2.3 — Teste Local do Agente

**Objetivo:** Validar que as Lambdas funcionam corretamente sem AWS.

Criar `bedrock-agent/test_local.py`:

```python
"""Teste local das Lambda functions."""
import json
import sys
sys.path.insert(0, 'lambdas/analyze_pr')


def make_event(action_group, api_path, params):
    return {
        'actionGroup': action_group,
        'apiPath': api_path,
        'httpMethod': 'POST',
        'requestBody': {
            'content': {
                'application/json': {
                    'properties': [{'name': k, 'value': v} for k, v in params.items()]
                }
            }
        }
    }


# Teste 1: Analyze PR
print("=== Teste: Analyze PR ===")
event = make_event('pr-analyzer', '/analyze-pr', {
    'prNumber': '1',
    'repoName': 'test/repo',
    'diff': 'password = "admin123"\nFROM node:latest',
    'prTitle': 'update stuff'
})

import importlib
handler = importlib.import_module('handler')
result = handler.lambda_handler(event, None)
body = json.loads(result['response']['responseBody']['application/json']['body'])
print(f"  Findings: {len(body['findings'])}")
print(f"  Risco: {body['riskLevel']}")
print(f"  Recomendação: {body['recommendation']}")
for f in body['findings']:
    print(f"    [{f['severity']}] {f['message']}")
print()

print("✅ Testes locais OK!")
```

Executar:

```bash
cd bedrock-agent
python test_local.py
```

---

### Atividade 2.4 — GitHub Actions Integration

**Objetivo:** Criar workflow que invoca o agente automaticamente em PRs.

Criar `.github/workflows/devops-agent-review.yml`:

```yaml
name: DevOps Agent — PR Review

on:
  pull_request:
    branches: [main]
    types: [opened, synchronize]

permissions:
  contents: read
  pull-requests: write

jobs:
  agent-review:
    name: "AI Code Review"
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Instalar dependências
        run: pip install boto3

      - name: Configurar AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
          aws-region: us-east-1

      - name: Obter diff
        run: |
          git diff origin/main...HEAD > /tmp/pr_diff.txt
          echo "Diff size: $(wc -c < /tmp/pr_diff.txt) bytes"

      - name: Invocar Bedrock Agent
        env:
          AGENT_ID: ${{ secrets.BEDROCK_AGENT_ID }}
          AGENT_ALIAS: ${{ secrets.BEDROCK_AGENT_ALIAS_ID }}
          PR_TITLE: ${{ github.event.pull_request.title }}
        run: |
          python << 'EOF'
          import boto3, json, os, uuid

          diff = open('/tmp/pr_diff.txt').read()[:50000]
          pr_title = os.environ.get('PR_TITLE', '')

          try:
              client = boto3.client('bedrock-agent-runtime')
              response = client.invoke_agent(
                  agentId=os.environ['AGENT_ID'],
                  agentAliasId=os.environ['AGENT_ALIAS'],
                  sessionId=str(uuid.uuid4()),
                  inputText=f"Analise este PR '{pr_title}':\n{diff}"
              )
              result = ""
              for event in response['completion']:
                  if 'chunk' in event:
                      result += event['chunk']['bytes'].decode()
              open('/tmp/review.md', 'w').write(result)
          except Exception as e:
              open('/tmp/review.md', 'w').write(f"⚠️ Agent indisponível: {e}")
          EOF

      - name: Comentar no PR
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const review = fs.readFileSync('/tmp/review.md', 'utf8');
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: `## 🤖 DevOps Agent Review\n\n${review}`
            });
```

> **☁️ Learner Lab:** os secrets `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` e `AWS_SESSION_TOKEN` vêm da sessão do Lab e expiram ao encerrá-la — atualize-os a cada sessão.

---

### Atividade 2.5 — Knowledge Base Setup

**Objetivo:** Preparar documentos para a knowledge base do agente.

Criar conteúdo em `bedrock-agent/knowledge-base/`:

**`architecture-patterns.md`:**

```markdown
# Padrões de Arquitetura — TechNova

## Microserviços
- Comunicação HTTP síncrona entre serviços
- Timeout: 5s para chamadas inter-serviço
- Resiliência: try/catch com fallback (não falhar por dependência)
- Health check em /health obrigatório

## Docker
- Multi-stage build obrigatório
- Imagem base: node:18-alpine
- Usuário non-root obrigatório
- HEALTHCHECK instruction obrigatório
- .dockerignore: excluir node_modules, tests, .git

## Terraform
- Tags obrigatórias: Name, Project, Environment, ManagedBy
- Variáveis tipadas com validation blocks
- Outputs para IP, URL, health check URL
- Security Groups: nunca 0.0.0.0/0 em produção
- Learner Lab: usar LabRole/LabInstanceProfile (sem criar IAM)
```

**`incident-history.md`:**

```markdown
# Histórico de Incidentes — TechNova

## INC-001: OOM Kill no technova-notifications
- **Data:** 2025-01-15
- **Causa:** Memory leak no serviço de notificações
- **Impacto:** Serviço indisponível por 45 segundos
- **Resolução:** Restart automático via Docker restart policy
- **Prevenção:** Adicionar limite de memória (256MB) e alertas

## INC-002: Drift no Security Group
- **Data:** 2025-02-03
- **Causa:** Desenvolvedor alterou SG manualmente via console
- **Impacto:** Porta exposta para 0.0.0.0/0 por 2 horas
- **Resolução:** terraform apply para restaurar
- **Prevenção:** Deny policy no AWS Organizations + drift check diário
```

**`deploy-policies.md`:**

```markdown
# Políticas de Deploy — TechNova

## Pipeline Obrigatória
1. Lint → Test → Build → Push → Deploy Staging → Health Check → Deploy Prod

## Regras
- Nunca deploy direto para produção (staging primeiro)
- Health check obrigatório pós-deploy (máx 10 retries)
- Rollback automático se health check falhar
- Conventional commits obrigatórios
- PR com review obrigatório para main
```

---

## Critérios de Avaliação

| Critério | Peso |
|----------|:----:|
| Chaos experiments executados com RTO medido | 30% |
| Game Day report completo | 20% |
| Governance configurada (branch protection, CODEOWNERS, PR template) | 20% |
| Agente Bedrock (design + lambdas + teste local) | 30% |

---

## Entrega

### Onde entregar

No fork do repositório da disciplina, na pasta de entrega da aula:

```
entregas/aula-14/SEU-RA/trabalho-em-aula.md
```

### O que entregar

Um arquivo `trabalho-em-aula.md` consolidando o que foi feito em sala:

- Resultados dos 3 chaos experiments com RTO medido
- Link/trecho do Game Day report
- Evidência da governance configurada (branch protection, CODEOWNERS, PR template)
- Design do agente (DESIGN.md) e saída do `python test_local.py`

### Como entregar

- O arquivo pode ser adicionado no **mesmo PR** do TF ou em PR separado
- A entrega é **individual**
- O trabalho em aula vale **1 ponto na nota final** do semestre (contabilizado apenas ao final, com **todos** os trabalhos entregues)

### Checklist Final de Entrega

#### Parte 1 — Chaos + Governance
- [ ] Chaos experiments (3 experimentos executados)
- [ ] Game Day report com métricas de RTO
- [ ] Branch protection configurada (screenshot)
- [ ] CODEOWNERS criado
- [ ] PR template criado
- [ ] CONTRIBUTING.md criado
- [ ] Conventional commits workflow

#### Parte 2 — Bedrock Agent
- [ ] Agent instruction prompt
- [ ] Design document (DESIGN.md)
- [ ] Schema OpenAPI dos action groups
- [ ] Lambda analyze_pr implementada
- [ ] Lambda detect_drift implementada
- [ ] Lambda generate_runbook implementada
- [ ] Teste local passando
- [ ] GitHub Actions workflow para PR review
- [ ] Knowledge base documentos criados
- [ ] PR criado para `entregas/aula-14/SEU-RA/`
