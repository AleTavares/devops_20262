# Laboratório Parte 2 — Building the Bedrock DevOps Agent

## Aula 14 — Disaster Simulation, Code Review e Agente Bedrock

### Objetivo

Projetar e implementar um agente DevOps completo usando AWS Bedrock que analisa PRs, detecta drift de infraestrutura, sugere remediações e gera runbooks automaticamente. Este é o exercício capstone de IA, integrando todas as habilidades das Aulas 02, 07, 09 e 12.

**Pré-requisito:** Laboratório Parte 1 completo (Chaos + Governance)

---

### Contexto

O tech lead da TechNova propõe: *"Temos chaos experiments, temos governance, mas precisamos de algo que opere 24/7 — um agente inteligente que revise PRs automaticamente, detecte quando a infraestrutura driftou do estado declarado, e documente runbooks baseado nos nossos incidentes. Vamos construir com Bedrock."*

> **☁️ Learner Lab:** todo o trabalho roda no **AWS Academy Learner Lab** (`us-east-1`, credenciais temporárias da sessão com `aws_session_token`). O Lab **não permite criar usuários/grupos/roles IAM**, então o agente Bedrock e as Lambdas usam a role pré-existente **`LabRole`** (`arn:aws:iam::<ACCOUNT_ID>:role/LabRole`) e o **`LabInstanceProfile`** quando houver instance profile. O fluxo de produção com **OIDC** fica apenas como referência (está **indisponível** no Lab, pois exigiria criar role IAM). Para desenvolver sem custo, as Lambdas são testadas localmente com `test_local.py`. Rode `terraform destroy` ao final.

---

## Etapa 1 — Design do Agente

### 1.1 Arquitetura do Agente DevOps

O agente Bedrock atua como um "DevOps Engineer virtual" que:

1. **Recebe eventos** (PR criado, schedule diário, incidente reportado)
2. **Decide qual ação executar** baseado no contexto
3. **Executa action groups** via Lambda functions
4. **Consulta knowledge base** para contexto histórico
5. **Retorna resultados** (comentários em PRs, issues, runbooks)

```
┌─────────────────────────────────────────────────────────────┐
│                  Bedrock Agent: DevOps Guardian               │
│                                                               │
│  Instruction Prompt:                                          │
│  "Você é um engenheiro DevOps senior. Analise PRs,           │
│   detecte drift, sugira remediações e documente runbooks."    │
│                                                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ AG: PR      │  │ AG: Drift   │  │ AG: Runbook         │  │
│  │ Analyzer    │  │ Detector    │  │ Generator           │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
│         │                 │                     │             │
│  ┌──────▼──────┐  ┌──────▼──────┐  ┌──────────▼──────────┐  │
│  │ Lambda      │  │ Lambda      │  │ Lambda              │  │
│  │ analyze_pr  │  │ detect_drift│  │ generate_runbook    │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
│                                                               │
│  ┌───────────────────────────────────────────────────────┐   │
│  │              Knowledge Base                            │   │
│  │  S3: runbooks/, incidents/, architecture/              │   │
│  │  Embedding: Titan Text Embeddings v2                   │   │
│  │  Vector Store: OpenSearch Serverless                   │   │
│  └───────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Definir Schema OpenAPI dos Action Groups

Criar `bedrock-agent/schemas/devops-agent-api.yaml`:

```yaml
openapi: 3.0.0
info:
  title: TechNova DevOps Agent API
  version: 1.0.0
  description: Action groups para o agente DevOps da TechNova

paths:
  /analyze-pr:
    post:
      operationId: analyzePullRequest
      summary: Analisa um Pull Request e retorna feedback
      description: |
        Recebe o diff de um PR, analisa qualidade de código,
        riscos de segurança, aderência a padrões, e retorna
        comentários estruturados.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - prNumber
                - repoName
                - diff
              properties:
                prNumber:
                  type: integer
                  description: Número do Pull Request
                repoName:
                  type: string
                  description: Nome do repositório (owner/repo)
                diff:
                  type: string
                  description: Diff do PR em formato unified
                prTitle:
                  type: string
                  description: Título do PR
                prDescription:
                  type: string
                  description: Descrição do PR
      responses:
        '200':
          description: Análise completa do PR
          content:
            application/json:
              schema:
                type: object
                properties:
                  summary:
                    type: string
                    description: Resumo da análise
                  riskLevel:
                    type: string
                    enum: [low, medium, high, critical]
                  findings:
                    type: array
                    items:
                      type: object
                      properties:
                        type:
                          type: string
                          enum: [security, performance, style, bug, improvement]
                        severity:
                          type: string
                          enum: [info, warning, error]
                        file:
                          type: string
                        line:
                          type: integer
                        message:
                          type: string
                        suggestion:
                          type: string
                  recommendation:
                    type: string
                    enum: [approve, request_changes, comment]

  /detect-drift:
    post:
      operationId: detectInfrastructureDrift
      summary: Detecta drift entre estado declarado e real da infra
      description: |
        Compara o Terraform state com a configuração declarada
        e identifica recursos que driftaram.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - terraformDir
              properties:
                terraformDir:
                  type: string
                  description: Diretório do Terraform a verificar
                environment:
                  type: string
                  description: Ambiente (staging/production)
                  default: staging
      responses:
        '200':
          description: Resultado da detecção de drift
          content:
            application/json:
              schema:
                type: object
                properties:
                  hasDrift:
                    type: boolean
                  driftedResources:
                    type: array
                    items:
                      type: object
                      properties:
                        resourceType:
                          type: string
                        resourceName:
                          type: string
                        attribute:
                          type: string
                        expected:
                          type: string
                        actual:
                          type: string
                  remediationSteps:
                    type: array
                    items:
                      type: string

  /generate-runbook:
    post:
      operationId: generateRunbook
      summary: Gera um runbook baseado em um cenário de incidente
      description: |
        Recebe a descrição de um incidente ou cenário operacional
        e gera um runbook detalhado com passos de diagnóstico,
        remediação e prevenção.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - scenario
              properties:
                scenario:
                  type: string
                  description: Descrição do cenário ou incidente
                severity:
                  type: string
                  enum: [low, medium, high, critical]
                  default: medium
                affectedServices:
                  type: array
                  items:
                    type: string
                  description: Serviços afetados
      responses:
        '200':
          description: Runbook gerado
          content:
            application/json:
              schema:
                type: object
                properties:
                  title:
                    type: string
                  severity:
                    type: string
                  estimatedTime:
                    type: string
                  steps:
                    type: array
                    items:
                      type: object
                      properties:
                        order:
                          type: integer
                        action:
                          type: string
                        command:
                          type: string
                        expectedResult:
                          type: string
                        rollback:
                          type: string
                  prevention:
                    type: array
                    items:
                      type: string
```

### 1.3 Definir o Agent Instruction Prompt

Criar `bedrock-agent/agent-instruction.md`:

```markdown
Você é o DevOps Guardian, um engenheiro DevOps senior virtual da TechNova.

## Suas Responsabilidades

1. **Análise de Pull Requests**: Revise código buscando problemas de segurança,
   performance, aderência a padrões (ESLint, conventional commits), e boas práticas
   de Docker/Terraform/GitHub Actions.

2. **Detecção de Drift**: Identifique quando a infraestrutura real divergiu do
   estado declarado no Terraform. Sugira passos de remediação específicos.

3. **Geração de Runbooks**: Crie documentação operacional detalhada baseada em
   cenários de incidente, incluindo passos de diagnóstico, remediação e prevenção.

## Diretrizes

- Seja específico: cite arquivos, linhas e comandos exatos
- Priorize segurança: vulnerabilidades são sempre severidade alta
- Contextualize: use o histórico de incidentes da knowledge base
- Seja acionável: cada finding deve ter uma sugestão de correção
- Use português brasileiro nas respostas

## Padrões TechNova

- Commits: conventional commits (feat, fix, docs, chore, ci)
- Docker: multi-stage, non-root, healthcheck obrigatório
- Terraform: tags obrigatórias (Name, Project, Environment, ManagedBy)
- Testes: cobertura mínima 80%
- Deploy: health check pós-deploy obrigatório
```

**Checkpoint:** Design do agente completo com schema OpenAPI e instruction prompt.

---

## Etapa 2 — Implementação dos Action Groups

### 2.1 Lambda: Analyze PR

Criar `bedrock-agent/lambdas/analyze_pr/handler.py`:

```python
"""
Lambda Function: Analyze Pull Request
Action Group do Bedrock Agent para análise de código em PRs.
"""
import json
import re
from typing import Any


def lambda_handler(event: dict, context: Any) -> dict:
    """Handler principal invocado pelo Bedrock Agent."""

    # Extrair parâmetros do evento do Bedrock Agent
    action_group = event.get('actionGroup', '')
    api_path = event.get('apiPath', '')
    parameters = extract_parameters(event)

    pr_number = parameters.get('prNumber', 0)
    repo_name = parameters.get('repoName', '')
    diff = parameters.get('diff', '')
    pr_title = parameters.get('prTitle', '')

    print(f"[PR Analyzer] Analisando PR #{pr_number} em {repo_name}")

    # Executar análises
    findings = []

    # 1. Análise de segurança
    security_findings = analyze_security(diff)
    findings.extend(security_findings)

    # 2. Análise de padrões Docker
    docker_findings = analyze_docker(diff)
    findings.extend(docker_findings)

    # 3. Análise de Terraform
    terraform_findings = analyze_terraform(diff)
    findings.extend(terraform_findings)

    # 4. Análise de CI/CD
    cicd_findings = analyze_cicd(diff)
    findings.extend(cicd_findings)

    # 5. Análise de conventional commits no título
    commit_findings = analyze_commit_message(pr_title)
    findings.extend(commit_findings)

    # Determinar nível de risco e recomendação
    risk_level = calculate_risk_level(findings)
    recommendation = determine_recommendation(findings)

    # Gerar resumo
    summary = generate_summary(pr_number, findings, risk_level)

    result = {
        'summary': summary,
        'riskLevel': risk_level,
        'findings': findings,
        'recommendation': recommendation
    }

    # Formato de resposta do Bedrock Agent
    return format_agent_response(event, result)


def extract_parameters(event: dict) -> dict:
    """Extrai parâmetros do request body do Bedrock Agent."""
    request_body = event.get('requestBody', {})
    content = request_body.get('content', {})
    app_json = content.get('application/json', {})
    properties = app_json.get('properties', [])

    params = {}
    for prop in properties:
        params[prop['name']] = prop['value']
    return params


def analyze_security(diff: str) -> list:
    """Busca problemas de segurança no diff."""
    findings = []

    # Padrões de segurança a verificar
    security_patterns = [
        (r'password\s*=\s*["\'][^"\']+["\']', 'Possível senha hardcoded'),
        (r'(api_key|apikey|secret)\s*=\s*["\'][^"\']+["\']', 'Possível chave/secret hardcoded'),
        (r'eval\s*\(', 'Uso de eval() — risco de injeção de código'),
        (r'exec\s*\(', 'Uso de exec() — risco de command injection'),
        (r'0\.0\.0\.0/0', 'CIDR 0.0.0.0/0 — acesso irrestrito'),
        (r'disable.*ssl|verify.*false', 'SSL/TLS verification desabilitada'),
        (r'chmod\s+777', 'Permissão 777 — acesso irrestrito ao arquivo'),
    ]

    for pattern, message in security_patterns:
        matches = re.finditer(pattern, diff, re.IGNORECASE)
        for match in matches:
            line_num = diff[:match.start()].count('\n') + 1
            findings.append({
                'type': 'security',
                'severity': 'error',
                'file': 'detected-in-diff',
                'line': line_num,
                'message': message,
                'suggestion': f'Remover ou externalizar: use variáveis de ambiente ou secrets manager'
            })

    return findings


def analyze_docker(diff: str) -> list:
    """Verifica boas práticas de Docker."""
    findings = []

    # Verifica se Dockerfile está no diff
    if 'Dockerfile' not in diff and 'dockerfile' not in diff:
        return findings

    # Verificar USER non-root
    if 'FROM' in diff and 'USER' not in diff:
        findings.append({
            'type': 'security',
            'severity': 'warning',
            'file': 'Dockerfile',
            'line': 0,
            'message': 'Dockerfile sem USER — container rodará como root',
            'suggestion': 'Adicionar: RUN adduser -S appuser && USER appuser'
        })

    # Verificar HEALTHCHECK
    if 'FROM' in diff and 'HEALTHCHECK' not in diff:
        findings.append({
            'type': 'improvement',
            'severity': 'warning',
            'file': 'Dockerfile',
            'line': 0,
            'message': 'Dockerfile sem HEALTHCHECK',
            'suggestion': 'Adicionar: HEALTHCHECK --interval=30s CMD wget --spider http://localhost:PORT/health'
        })

    # Verificar latest tag
    if re.search(r'FROM\s+\w+:latest', diff):
        findings.append({
            'type': 'improvement',
            'severity': 'warning',
            'file': 'Dockerfile',
            'line': 0,
            'message': 'Usando tag :latest — não é reprodutível',
            'suggestion': 'Usar tag específica (ex: node:18-alpine)'
        })

    return findings


def analyze_terraform(diff: str) -> list:
    """Verifica padrões Terraform."""
    findings = []

    if '.tf' not in diff:
        return findings

    # Verificar tags obrigatórias
    required_tags = ['Name', 'Project', 'Environment', 'ManagedBy']
    if 'resource' in diff and 'tags' not in diff:
        findings.append({
            'type': 'style',
            'severity': 'warning',
            'file': '*.tf',
            'line': 0,
            'message': f'Recurso Terraform sem tags. Tags obrigatórias: {", ".join(required_tags)}',
            'suggestion': 'Adicionar bloco tags com: Name, Project, Environment, ManagedBy'
        })

    # Verificar hardcoded values
    if re.search(r'ami-[a-f0-9]+', diff):
        findings.append({
            'type': 'improvement',
            'severity': 'info',
            'file': '*.tf',
            'line': 0,
            'message': 'AMI ID hardcoded — considere usar data source ou variável',
            'suggestion': 'Usar: data "aws_ami" ou var.ami_id'
        })

    return findings


def analyze_cicd(diff: str) -> list:
    """Verifica padrões de CI/CD."""
    findings = []

    if '.yml' not in diff and '.yaml' not in diff:
        return findings

    # Verificar actions sem version pinning
    unpinned = re.findall(r'uses:\s+[\w-]+/[\w-]+@(main|master)', diff)
    for match in unpinned:
        findings.append({
            'type': 'security',
            'severity': 'warning',
            'file': '.github/workflows/*.yml',
            'line': 0,
            'message': 'GitHub Action usando branch (main/master) ao invés de versão fixa',
            'suggestion': 'Usar versão fixa: uses: action/name@v4 ou SHA completo'
        })

    return findings


def analyze_commit_message(title: str) -> list:
    """Verifica se o título do PR segue conventional commits."""
    findings = []

    if not title:
        return findings

    valid_prefixes = ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore', 'ci', 'perf', 'build']
    pattern = rf'^({"|".join(valid_prefixes)})(\(.+\))?: .+'

    if not re.match(pattern, title):
        findings.append({
            'type': 'style',
            'severity': 'info',
            'file': 'PR title',
            'line': 0,
            'message': f'Título do PR não segue conventional commits: "{title}"',
            'suggestion': f'Formato: tipo(escopo): descrição. Tipos: {", ".join(valid_prefixes)}'
        })

    return findings


def calculate_risk_level(findings: list) -> str:
    """Calcula nível de risco baseado nos findings."""
    errors = sum(1 for f in findings if f['severity'] == 'error')
    warnings = sum(1 for f in findings if f['severity'] == 'warning')

    if errors >= 2:
        return 'critical'
    elif errors >= 1:
        return 'high'
    elif warnings >= 3:
        return 'medium'
    return 'low'


def determine_recommendation(findings: list) -> str:
    """Determina recomendação de ação para o PR."""
    errors = sum(1 for f in findings if f['severity'] == 'error')
    if errors > 0:
        return 'request_changes'
    warnings = sum(1 for f in findings if f['severity'] == 'warning')
    if warnings > 2:
        return 'request_changes'
    elif warnings > 0:
        return 'comment'
    return 'approve'


def generate_summary(pr_number: int, findings: list, risk_level: str) -> str:
    """Gera resumo textual da análise."""
    total = len(findings)
    errors = sum(1 for f in findings if f['severity'] == 'error')
    warnings = sum(1 for f in findings if f['severity'] == 'warning')
    infos = sum(1 for f in findings if f['severity'] == 'info')

    return (
        f"Análise do PR #{pr_number}: {total} finding(s) encontrado(s). "
        f"Risco: {risk_level}. "
        f"Detalhes: {errors} erro(s), {warnings} aviso(s), {infos} info(s)."
    )


def format_agent_response(event: dict, result: dict) -> dict:
    """Formata resposta no padrão esperado pelo Bedrock Agent."""
    return {
        'messageVersion': '1.0',
        'response': {
            'actionGroup': event.get('actionGroup', ''),
            'apiPath': event.get('apiPath', ''),
            'httpMethod': event.get('httpMethod', 'POST'),
            'httpStatusCode': 200,
            'responseBody': {
                'application/json': {
                    'body': json.dumps(result, ensure_ascii=False)
                }
            }
        }
    }
```

### 2.2 Lambda: Detect Drift

Criar `bedrock-agent/lambdas/detect_drift/handler.py`:

```python
"""
Lambda Function: Detect Infrastructure Drift
Compara estado declarado vs real da infraestrutura.
"""
import json
import subprocess
import os
from typing import Any


def lambda_handler(event: dict, context: Any) -> dict:
    """Handler para detecção de drift de infraestrutura."""

    parameters = extract_parameters(event)
    terraform_dir = parameters.get('terraformDir', 'terraform/notifications')
    environment = parameters.get('environment', 'staging')

    print(f"[Drift Detector] Verificando drift em {terraform_dir} ({environment})")

    # Simular detecção de drift (em produção, executaria terraform plan)
    drift_result = simulate_drift_detection(terraform_dir, environment)

    # Gerar passos de remediação
    if drift_result['hasDrift']:
        drift_result['remediationSteps'] = generate_remediation(
            drift_result['driftedResources']
        )

    return format_agent_response(event, drift_result)


def extract_parameters(event: dict) -> dict:
    """Extrai parâmetros do evento."""
    request_body = event.get('requestBody', {})
    content = request_body.get('content', {})
    app_json = content.get('application/json', {})
    properties = app_json.get('properties', [])

    params = {}
    for prop in properties:
        params[prop['name']] = prop['value']
    return params


def simulate_drift_detection(terraform_dir: str, environment: str) -> dict:
    """
    Simula detecção de drift.
    Em produção real, executaria:
    - terraform plan -detailed-exitcode
    - Compararia state com recursos reais via AWS API
    """
    # Em cenário real, usar boto3 para comparar
    # Aqui simulamos baseado em padrões comuns de drift
    common_drifts = [
        {
            'resourceType': 'aws_security_group',
            'resourceName': 'technova-notifications-sg',
            'attribute': 'ingress.0.cidr_blocks',
            'expected': '["10.0.0.0/16"]',
            'actual': '["0.0.0.0/0"]'
        },
        {
            'resourceType': 'aws_instance',
            'resourceName': 'technova-notifications',
            'attribute': 'instance_type',
            'expected': 't2.micro',
            'actual': 't2.small'
        }
    ]

    # Simular: 60% chance de drift
    import hashlib
    hash_val = int(hashlib.md5(f"{terraform_dir}{environment}".encode()).hexdigest(), 16)

    if hash_val % 10 < 6:
        return {
            'hasDrift': True,
            'driftedResources': common_drifts,
            'remediationSteps': []
        }
    else:
        return {
            'hasDrift': False,
            'driftedResources': [],
            'remediationSteps': []
        }


def generate_remediation(drifted_resources: list) -> list:
    """Gera passos de remediação para cada recurso driftado."""
    steps = []

    for resource in drifted_resources:
        resource_type = resource['resourceType']
        resource_name = resource['resourceName']
        attribute = resource['attribute']

        if 'security_group' in resource_type and 'cidr' in attribute:
            steps.append(
                f"1. Revisar Security Group '{resource_name}': "
                f"CIDR mudou de {resource['expected']} para {resource['actual']}. "
                f"Executar: terraform apply para restaurar, ou atualizar .tf se a mudança é intencional."
            )
            steps.append(
                f"2. URGENTE: Se {resource['actual']} contém 0.0.0.0/0, "
                f"avaliar exposição de segurança imediatamente."
            )

        elif 'instance' in resource_type and 'instance_type' in attribute:
            steps.append(
                f"3. Instance type de '{resource_name}' mudou de "
                f"{resource['expected']} para {resource['actual']}. "
                f"Se intencional, atualizar variable no .tfvars. "
                f"Se não, executar: terraform apply -target={resource_type}.{resource_name}"
            )

    steps.append(
        "4. Após correção, executar terraform plan para confirmar que drift foi resolvido."
    )
    steps.append(
        "5. Documentar a causa do drift e adicionar proteção "
        "(ex: deny policy no AWS Organizations) para prevenir recorrência."
    )

    return steps


def format_agent_response(event: dict, result: dict) -> dict:
    """Formata resposta para o Bedrock Agent."""
    return {
        'messageVersion': '1.0',
        'response': {
            'actionGroup': event.get('actionGroup', ''),
            'apiPath': event.get('apiPath', ''),
            'httpMethod': event.get('httpMethod', 'POST'),
            'httpStatusCode': 200,
            'responseBody': {
                'application/json': {
                    'body': json.dumps(result, ensure_ascii=False)
                }
            }
        }
    }
```

### 2.3 Lambda: Generate Runbook

Criar `bedrock-agent/lambdas/generate_runbook/handler.py`:

```python
"""
Lambda Function: Generate Runbook
Gera documentação operacional baseada em cenários de incidente.
"""
import json
from datetime import datetime
from typing import Any


def lambda_handler(event: dict, context: Any) -> dict:
    """Handler para geração de runbooks."""

    parameters = extract_parameters(event)
    scenario = parameters.get('scenario', '')
    severity = parameters.get('severity', 'medium')
    affected_services = parameters.get('affectedServices', [])

    if isinstance(affected_services, str):
        affected_services = [s.strip() for s in affected_services.split(',')]

    print(f"[Runbook Generator] Gerando runbook para: {scenario}")
    print(f"  Severidade: {severity}")
    print(f"  Serviços: {affected_services}")

    # Gerar runbook baseado no cenário
    runbook = generate_runbook(scenario, severity, affected_services)

    return format_agent_response(event, runbook)


def extract_parameters(event: dict) -> dict:
    """Extrai parâmetros do evento."""
    request_body = event.get('requestBody', {})
    content = request_body.get('content', {})
    app_json = content.get('application/json', {})
    properties = app_json.get('properties', [])

    params = {}
    for prop in properties:
        params[prop['name']] = prop['value']
    return params


def generate_runbook(scenario: str, severity: str, affected_services: list) -> dict:
    """Gera um runbook estruturado baseado no cenário."""

    # Templates de runbook por tipo de cenário
    runbook_templates = {
        'container_crash': {
            'title': 'Runbook: Recuperação de Container Crash',
            'estimatedTime': '5-15 minutos',
            'steps': [
                {
                    'order': 1,
                    'action': 'Verificar status do container',
                    'command': 'docker ps -a --filter "name=SERVICE_NAME"',
                    'expectedResult': 'Container em estado Exited ou Restarting',
                    'rollback': 'N/A — etapa de diagnóstico'
                },
                {
                    'order': 2,
                    'action': 'Verificar logs do container',
                    'command': 'docker logs --tail 50 SERVICE_NAME',
                    'expectedResult': 'Identificar causa do crash (OOM, erro de aplicação, etc)',
                    'rollback': 'N/A — etapa de diagnóstico'
                },
                {
                    'order': 3,
                    'action': 'Verificar se restart policy está funcionando',
                    'command': 'docker inspect --format="{{.HostConfig.RestartPolicy.Name}}" SERVICE_NAME',
                    'expectedResult': 'unless-stopped ou always',
                    'rollback': 'docker update --restart unless-stopped SERVICE_NAME'
                },
                {
                    'order': 4,
                    'action': 'Reiniciar container manualmente se necessário',
                    'command': 'docker restart SERVICE_NAME',
                    'expectedResult': 'Container em estado Running',
                    'rollback': 'docker stop SERVICE_NAME && docker run [config original]'
                },
                {
                    'order': 5,
                    'action': 'Verificar health check',
                    'command': 'curl -f http://HOST:PORT/health',
                    'expectedResult': 'HTTP 200 com status: healthy',
                    'rollback': 'Escalar para equipe de desenvolvimento'
                }
            ],
            'prevention': [
                'Configurar alertas de memória no container (limite 80%)',
                'Implementar graceful shutdown na aplicação',
                'Adicionar readiness/liveness probes mais frequentes',
                'Revisar limites de recursos no docker-compose'
            ]
        },
        'high_latency': {
            'title': 'Runbook: Alta Latência em Serviço',
            'estimatedTime': '10-30 minutos',
            'steps': [
                {
                    'order': 1,
                    'action': 'Verificar métricas de latência atuais',
                    'command': 'curl -w "time_total: %{time_total}s\\n" -o /dev/null -s http://HOST:PORT/health',
                    'expectedResult': 'Latência > threshold definido',
                    'rollback': 'N/A'
                },
                {
                    'order': 2,
                    'action': 'Verificar uso de CPU e memória do container',
                    'command': 'docker stats --no-stream SERVICE_NAME',
                    'expectedResult': 'Identificar se recurso está saturado',
                    'rollback': 'N/A'
                },
                {
                    'order': 3,
                    'action': 'Verificar conexões ativas',
                    'command': 'docker exec SERVICE_NAME netstat -an | grep ESTABLISHED | wc -l',
                    'expectedResult': 'Número dentro do esperado',
                    'rollback': 'N/A'
                },
                {
                    'order': 4,
                    'action': 'Scale up se necessário',
                    'command': 'docker-compose up --scale SERVICE_NAME=2 -d',
                    'expectedResult': 'Nova instância rodando e saudável',
                    'rollback': 'docker-compose up --scale SERVICE_NAME=1 -d'
                }
            ],
            'prevention': [
                'Implementar auto-scaling baseado em latência',
                'Adicionar cache para endpoints frequentes',
                'Otimizar queries e operações de I/O',
                'Configurar rate limiting para proteger contra burst'
            ]
        },
        'deployment_failure': {
            'title': 'Runbook: Falha no Deploy',
            'estimatedTime': '10-20 minutos',
            'steps': [
                {
                    'order': 1,
                    'action': 'Identificar a versão com problema',
                    'command': 'docker inspect --format="{{.Config.Image}}" SERVICE_NAME',
                    'expectedResult': 'Tag da imagem que causou o problema',
                    'rollback': 'N/A'
                },
                {
                    'order': 2,
                    'action': 'Verificar health check da nova versão',
                    'command': 'curl -f http://HOST:PORT/health',
                    'expectedResult': 'HTTP 200 ou identificar erro',
                    'rollback': 'N/A'
                },
                {
                    'order': 3,
                    'action': 'Rollback para versão anterior',
                    'command': 'docker stop SERVICE_NAME && docker run -d --name SERVICE_NAME PREVIOUS_IMAGE',
                    'expectedResult': 'Serviço restaurado com versão anterior',
                    'rollback': 'Usar backup de configuração'
                },
                {
                    'order': 4,
                    'action': 'Verificar que rollback foi bem-sucedido',
                    'command': 'curl -f http://HOST:PORT/health',
                    'expectedResult': 'HTTP 200 — serviço saudável',
                    'rollback': 'Escalar para equipe de infraestrutura'
                }
            ],
            'prevention': [
                'Implementar deploy canary antes de 100% do tráfego',
                'Adicionar smoke tests automáticos pós-deploy',
                'Manter 2 versões anteriores disponíveis para rollback',
                'Testar em staging antes de produção (obrigatório)'
            ]
        }
    }

    # Identificar template mais adequado
    scenario_lower = scenario.lower()
    if 'crash' in scenario_lower or 'kill' in scenario_lower or 'restart' in scenario_lower:
        template_key = 'container_crash'
    elif 'latency' in scenario_lower or 'slow' in scenario_lower or 'lento' in scenario_lower:
        template_key = 'high_latency'
    elif 'deploy' in scenario_lower or 'rollback' in scenario_lower:
        template_key = 'deployment_failure'
    else:
        template_key = 'container_crash'  # default

    runbook = runbook_templates[template_key].copy()
    runbook['severity'] = severity
    runbook['generatedAt'] = datetime.utcnow().isoformat()
    runbook['scenario'] = scenario
    runbook['affectedServices'] = affected_services

    # Substituir placeholders
    for step in runbook['steps']:
        service_name = affected_services[0] if affected_services else 'technova-notifications'
        step['command'] = step['command'].replace('SERVICE_NAME', service_name)
        step['command'] = step['command'].replace('HOST', 'localhost')
        step['command'] = step['command'].replace('PORT', '3001')
        if step.get('rollback'):
            step['rollback'] = step['rollback'].replace('SERVICE_NAME', service_name)

    return runbook


def format_agent_response(event: dict, result: dict) -> dict:
    """Formata resposta para o Bedrock Agent."""
    return {
        'messageVersion': '1.0',
        'response': {
            'actionGroup': event.get('actionGroup', ''),
            'apiPath': event.get('apiPath', ''),
            'httpMethod': event.get('httpMethod', 'POST'),
            'httpStatusCode': 200,
            'responseBody': {
                'application/json': {
                    'body': json.dumps(result, ensure_ascii=False)
                }
            }
        }
    }
```

**Checkpoint:** Três Lambda functions implementadas para os action groups.

---

## Etapa 3 — Infraestrutura do Agente com Terraform

> **☁️ Conversão Learner Lab (importante):** em um ambiente de produção, o Terraform criaria uma role IAM dedicada para o Bedrock Agent e outra para as Lambdas, com suas policies. **No AWS Academy Learner Lab isso é indisponível** — a conta **não permite criar/alterar roles ou policies IAM**. A solução é **reutilizar a role pré-existente `LabRole`** (`arn:aws:iam::<ACCOUNT_ID>:role/LabRole`), que já vem com as permissões necessárias para Bedrock, Lambda e S3, e o `LabInstanceProfile` quando houver instance profile. Por isso o `main.tf` abaixo **não cria role nem policy IAM**: ele apenas referencia a `LabRole` via um `local` com o ARN. A invocação do Bedrock usa as **credenciais temporárias da sessão** (`aws_session_token`), nunca OIDC (padrão de produção indisponível no Lab).

### 3.1 Terraform para o Bedrock Agent

Criar `bedrock-agent/terraform/main.tf`:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# === Learner Lab: usar a role pré-existente LabRole ===
# O Lab NÃO permite criar role nem policy IAM (sem recursos de role aqui).
# Descobrir o Account ID da sessão atual (sem criar nada):
data "aws_caller_identity" "current" {}

locals {
  # Role pré-provisionada do Learner Lab usada por Bedrock e pelas Lambdas.
  lab_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
}

# === Lambda Functions (usando LabRole) ===
resource "aws_lambda_function" "analyze_pr" {
  filename         = "${path.module}/../lambdas/analyze_pr/package.zip"
  function_name    = "technova-agent-analyze-pr"
  role             = local.lab_role_arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 30
  memory_size      = 256
  source_code_hash = filebase64sha256("${path.module}/../lambdas/analyze_pr/package.zip")

  environment {
    variables = {
      ENVIRONMENT = var.environment
      LOG_LEVEL   = "INFO"
    }
  }

  tags = {
    Name        = "technova-agent-analyze-pr"
    Project     = "technova"
    Component   = "bedrock-agent"
    ActionGroup = "pr-analyzer"
    ManagedBy   = "terraform"
  }
}

resource "aws_lambda_function" "detect_drift" {
  filename         = "${path.module}/../lambdas/detect_drift/package.zip"
  function_name    = "technova-agent-detect-drift"
  role             = local.lab_role_arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  memory_size      = 512
  source_code_hash = filebase64sha256("${path.module}/../lambdas/detect_drift/package.zip")

  environment {
    variables = {
      ENVIRONMENT     = var.environment
      LOG_LEVEL       = "INFO"
      TF_STATE_BUCKET = var.tf_state_bucket
    }
  }

  tags = {
    Name        = "technova-agent-detect-drift"
    Project     = "technova"
    Component   = "bedrock-agent"
    ActionGroup = "drift-detector"
    ManagedBy   = "terraform"
  }
}

resource "aws_lambda_function" "generate_runbook" {
  filename         = "${path.module}/../lambdas/generate_runbook/package.zip"
  function_name    = "technova-agent-generate-runbook"
  role             = local.lab_role_arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 30
  memory_size      = 256
  source_code_hash = filebase64sha256("${path.module}/../lambdas/generate_runbook/package.zip")

  environment {
    variables = {
      ENVIRONMENT = var.environment
      LOG_LEVEL   = "INFO"
    }
  }

  tags = {
    Name        = "technova-agent-generate-runbook"
    Project     = "technova"
    Component   = "bedrock-agent"
    ActionGroup = "runbook-generator"
    ManagedBy   = "terraform"
  }
}

# === S3 Bucket para Knowledge Base ===
resource "aws_s3_bucket" "knowledge_base" {
  bucket = "technova-devops-agent-kb-${var.environment}"

  tags = {
    Name      = "technova-devops-agent-kb"
    Project   = "technova"
    Component = "bedrock-agent"
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "knowledge_base" {
  bucket = aws_s3_bucket.knowledge_base.id
  versioning_configuration {
    status = "Enabled"
  }
}

# === Permission: Bedrock pode invocar Lambdas ===
resource "aws_lambda_permission" "bedrock_analyze_pr" {
  statement_id  = "AllowBedrockInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.analyze_pr.function_name
  principal     = "bedrock.amazonaws.com"
}

resource "aws_lambda_permission" "bedrock_detect_drift" {
  statement_id  = "AllowBedrockInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.detect_drift.function_name
  principal     = "bedrock.amazonaws.com"
}

resource "aws_lambda_permission" "bedrock_generate_runbook" {
  statement_id  = "AllowBedrockInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.generate_runbook.function_name
  principal     = "bedrock.amazonaws.com"
}
```

> **Nota sobre o agente Bedrock:** ao criar o agente no console (ou via `aws bedrock-agent create-agent`), informe a `LabRole` como *Agent resource role* em vez de uma role nova. O Learner Lab já autorizou a `LabRole` a assumir o serviço Bedrock e invocar as Lambdas acima.

### 3.2 Variables e Outputs

Criar `bedrock-agent/terraform/variables.tf`:

```hcl
variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de deploy"
  type        = string
  default     = "staging"
}

variable "model_id" {
  description = "ID do modelo Bedrock a utilizar"
  type        = string
  default     = "anthropic.claude-3-haiku-20240307-v1:0"
}

variable "tf_state_bucket" {
  description = "Bucket S3 com o Terraform state (para drift detection)"
  type        = string
  default     = ""
}
```

Criar `bedrock-agent/terraform/outputs.tf`:

```hcl
output "lab_role_arn" {
  description = "ARN da LabRole usada pelo agente e pelas Lambdas (Learner Lab)"
  value       = local.lab_role_arn
}

output "analyze_pr_lambda_arn" {
  description = "ARN da Lambda de análise de PR"
  value       = aws_lambda_function.analyze_pr.arn
}

output "detect_drift_lambda_arn" {
  description = "ARN da Lambda de detecção de drift"
  value       = aws_lambda_function.detect_drift.arn
}

output "generate_runbook_lambda_arn" {
  description = "ARN da Lambda de geração de runbook"
  value       = aws_lambda_function.generate_runbook.arn
}

output "knowledge_base_bucket" {
  description = "Bucket S3 da knowledge base"
  value       = aws_s3_bucket.knowledge_base.bucket
}
```

**Checkpoint:** Infraestrutura Terraform definida para o agente Bedrock, reutilizando a `LabRole` do Learner Lab (sem criar IAM).

---

## Etapa 4 — Integração com GitHub Actions

### 4.1 Workflow: Invocar Agente em PRs

Criar `.github/workflows/devops-agent-review.yml`:

```yaml
name: DevOps Agent — PR Review

on:
  pull_request:
    branches: [main, develop]
    types: [opened, synchronize]

permissions:
  contents: read
  pull-requests: write

env:
  AWS_REGION: us-east-1
  AGENT_ID: ${{ secrets.BEDROCK_AGENT_ID }}
  AGENT_ALIAS_ID: ${{ secrets.BEDROCK_AGENT_ALIAS_ID }}

jobs:
  agent-review:
    name: "AI Agent — Code Review"
    runs-on: ubuntu-latest
    steps:
      - name: Checkout código
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Configurar credenciais AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Instalar dependências
        run: pip install boto3 PyGithub

      - name: Obter diff do PR
        id: get-diff
        run: |
          DIFF=$(git diff origin/main...HEAD)
          # Salvar diff em arquivo (pode ser grande)
          echo "$DIFF" > /tmp/pr_diff.txt
          DIFF_SIZE=$(wc -c < /tmp/pr_diff.txt)
          echo "diff_size=$DIFF_SIZE" >> $GITHUB_OUTPUT
          echo "Tamanho do diff: $DIFF_SIZE bytes"

      - name: Invocar Bedrock Agent
        id: agent-review
        env:
          PR_NUMBER: ${{ github.event.pull_request.number }}
          PR_TITLE: ${{ github.event.pull_request.title }}
          PR_BODY: ${{ github.event.pull_request.body }}
          REPO_NAME: ${{ github.repository }}
        run: |
          python << 'EOF'
          import boto3
          import json
          import os
          import uuid

          # Configuração
          agent_id = os.environ.get('AGENT_ID', 'demo-agent')
          agent_alias_id = os.environ.get('AGENT_ALIAS_ID', 'demo-alias')
          pr_number = os.environ['PR_NUMBER']
          pr_title = os.environ.get('PR_TITLE', '')
          repo_name = os.environ['REPO_NAME']

          # Ler diff
          with open('/tmp/pr_diff.txt', 'r') as f:
              diff = f.read()

          # Truncar diff se muito grande (limite do agente)
          MAX_DIFF_SIZE = 50000
          if len(diff) > MAX_DIFF_SIZE:
              diff = diff[:MAX_DIFF_SIZE] + "\n\n[... diff truncado por tamanho ...]"

          print(f"Invocando agente para PR #{pr_number} em {repo_name}")
          print(f"Título: {pr_title}")
          print(f"Diff size: {len(diff)} chars")

          # Invocar Bedrock Agent
          try:
              client = boto3.client('bedrock-agent-runtime', region_name=os.environ['AWS_REGION'])

              input_text = (
                  f"Analise o seguinte Pull Request:\n"
                  f"- Repositório: {repo_name}\n"
                  f"- PR #{pr_number}: {pr_title}\n\n"
                  f"Diff:\n```\n{diff}\n```\n\n"
                  f"Forneça: resumo, nível de risco, findings específicos, e recomendação."
              )

              response = client.invoke_agent(
                  agentId=agent_id,
                  agentAliasId=agent_alias_id,
                  sessionId=str(uuid.uuid4()),
                  inputText=input_text
              )

              # Processar resposta streaming
              result_text = ""
              for event in response['completion']:
                  if 'chunk' in event:
                      chunk = event['chunk']
                      if 'bytes' in chunk:
                          result_text += chunk['bytes'].decode('utf-8')

              print(f"\nResposta do agente:\n{result_text}")

              # Salvar resultado
              with open('/tmp/agent_review.md', 'w') as f:
                  f.write(result_text)

          except Exception as e:
              print(f"Erro ao invocar agente: {e}")
              # Fallback: usar análise local simples
              fallback_review = generate_fallback_review(diff, pr_title)
              with open('/tmp/agent_review.md', 'w') as f:
                  f.write(fallback_review)


          def generate_fallback_review(diff, title):
              """Review simplificado quando o agente não está disponível."""
              issues = []
              if 'password' in diff.lower() or 'secret' in diff.lower():
                  issues.append("⚠️ Possível credencial no código")
              if 'TODO' in diff:
                  issues.append("📝 TODOs encontrados no diff")
              if '0.0.0.0/0' in diff:
                  issues.append("🔒 CIDR aberto detectado")

              review = "## 🤖 DevOps Agent Review (Fallback Mode)\n\n"
              if issues:
                  review += "### Findings:\n"
                  for issue in issues:
                      review += f"- {issue}\n"
              else:
                  review += "✅ Nenhum problema crítico detectado na análise básica.\n"
              review += "\n> *Nota: Análise completa via Bedrock Agent indisponível. Review básico executado.*"
              return review

          EOF

      - name: Postar review como comentário no PR
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const review = fs.readFileSync('/tmp/agent_review.md', 'utf8');

            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: `## 🤖 DevOps Agent — Automated Review\n\n${review}\n\n---\n*Powered by AWS Bedrock Agent — TechNova DevOps Guardian*`
            });

  drift-check:
    name: "AI Agent — Drift Detection"
    runs-on: ubuntu-latest
    if: contains(github.event.pull_request.labels.*.name, 'infra')
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configurar AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Verificar drift de infraestrutura
        run: |
          python << 'EOF'
          import boto3
          import json
          import os
          import uuid

          agent_id = os.environ.get('AGENT_ID', 'demo-agent')
          agent_alias_id = os.environ.get('AGENT_ALIAS_ID', 'demo-alias')

          try:
              client = boto3.client('bedrock-agent-runtime')

              response = client.invoke_agent(
                  agentId=agent_id,
                  agentAliasId=agent_alias_id,
                  sessionId=str(uuid.uuid4()),
                  inputText="Detectar drift de infraestrutura no diretório terraform/notifications para o ambiente staging. Reportar recursos driftados e sugerir remediação."
              )

              result_text = ""
              for event in response['completion']:
                  if 'chunk' in event:
                      result_text += event['chunk']['bytes'].decode('utf-8')

              print("Resultado da verificação de drift:")
              print(result_text)

              with open('/tmp/drift_report.md', 'w') as f:
                  f.write(result_text)

          except Exception as e:
              print(f"Drift check falhou: {e}")
              with open('/tmp/drift_report.md', 'w') as f:
                  f.write(f"⚠️ Drift check indisponível: {e}")
          EOF

      - name: Reportar drift no PR
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('/tmp/drift_report.md', 'utf8');

            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: `## 🔍 Infrastructure Drift Report\n\n${report}`
            });
```

> **☁️ Learner Lab:** os três secrets `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` e `AWS_SESSION_TOKEN` vêm da sessão atual do Lab e **expiram quando o Lab encerra** — atualize-os a cada sessão. Esse é o fluxo real no Lab; o OIDC do padrão de produção fica **indisponível** por exigir role IAM.

### 4.2 Workflow: Geração Automática de Runbooks

Criar `.github/workflows/generate-runbook.yml`:

```yaml
name: DevOps Agent — Generate Runbook

on:
  issues:
    types: [labeled]

permissions:
  contents: write
  issues: write

env:
  AWS_REGION: us-east-1

jobs:
  generate-runbook:
    name: "AI Agent — Runbook Generation"
    runs-on: ubuntu-latest
    if: github.event.label.name == 'runbook-needed'
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configurar AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Gerar runbook via agente
        env:
          ISSUE_TITLE: ${{ github.event.issue.title }}
          ISSUE_BODY: ${{ github.event.issue.body }}
        run: |
          python << 'EOF'
          import boto3
          import json
          import os
          import uuid

          issue_title = os.environ.get('ISSUE_TITLE', '')
          issue_body = os.environ.get('ISSUE_BODY', '')

          agent_id = os.environ.get('BEDROCK_AGENT_ID', 'demo-agent')
          agent_alias_id = os.environ.get('BEDROCK_AGENT_ALIAS_ID', 'demo-alias')

          input_text = (
              f"Gere um runbook detalhado para o seguinte cenário:\n"
              f"Título: {issue_title}\n"
              f"Descrição: {issue_body}\n\n"
              f"O runbook deve incluir: passos de diagnóstico, comandos de remediação, "
              f"resultados esperados, procedimento de rollback, e medidas de prevenção."
          )

          try:
              client = boto3.client('bedrock-agent-runtime')
              response = client.invoke_agent(
                  agentId=agent_id,
                  agentAliasId=agent_alias_id,
                  sessionId=str(uuid.uuid4()),
                  inputText=input_text
              )

              result_text = ""
              for event in response['completion']:
                  if 'chunk' in event:
                      result_text += event['chunk']['bytes'].decode('utf-8')

              # Salvar como arquivo Markdown
              runbook_filename = f"runbooks/{issue_title.lower().replace(' ', '-')[:50]}.md"
              os.makedirs('runbooks', exist_ok=True)
              with open(runbook_filename, 'w') as f:
                  f.write(f"# {issue_title}\n\n")
                  f.write(f"*Gerado automaticamente pelo DevOps Agent em {os.popen('date').read().strip()}*\n\n")
                  f.write(result_text)

              print(f"Runbook salvo em: {runbook_filename}")

          except Exception as e:
              print(f"Erro: {e}")
          EOF

      - name: Commit runbook
        run: |
          git config user.name "DevOps Agent"
          git config user.email "devops-agent@technova.dev"
          git add runbooks/
          git commit -m "docs(runbook): gerar runbook para issue #${{ github.event.issue.number }}" || true
          git push || true

      - name: Comentar na issue
        uses: actions/github-script@v7
        with:
          script: |
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: '📖 Runbook gerado automaticamente pelo DevOps Agent e commitado no repositório em `runbooks/`.\n\nRevise e ajuste conforme necessário.'
            });
```

### 4.3 Teste Local do Agente (sem AWS)

Para testar localmente sem conta AWS, criar `bedrock-agent/test_local.py`:

```python
"""
Teste local das Lambda functions do agente (sem AWS).
Simula o comportamento do Bedrock Agent invocando as Lambdas diretamente.
"""
import sys
import json
sys.path.insert(0, 'lambdas/analyze_pr')
sys.path.insert(0, 'lambdas/detect_drift')
sys.path.insert(0, 'lambdas/generate_runbook')

from lambdas.analyze_pr.handler import lambda_handler as analyze_pr
from lambdas.detect_drift.handler import lambda_handler as detect_drift
from lambdas.generate_runbook.handler import lambda_handler as generate_runbook


def create_agent_event(action_group, api_path, parameters):
    """Cria evento no formato do Bedrock Agent."""
    properties = [{'name': k, 'value': v} for k, v in parameters.items()]
    return {
        'actionGroup': action_group,
        'apiPath': api_path,
        'httpMethod': 'POST',
        'requestBody': {
            'content': {
                'application/json': {
                    'properties': properties
                }
            }
        }
    }


def test_analyze_pr():
    """Testa análise de PR com um diff de exemplo."""
    print("=" * 60)
    print("TESTE: Analyze PR")
    print("=" * 60)

    sample_diff = """
--- a/Dockerfile
+++ b/Dockerfile
@@ -1,5 +1,8 @@
-FROM node:latest
+FROM node:18-alpine
 WORKDIR /app
 COPY . .
-RUN npm install
+RUN npm ci --only=production
+password = "admin123"
+EXPOSE 3000
 CMD ["node", "server.js"]
"""

    event = create_agent_event(
        'pr-analyzer',
        '/analyze-pr',
        {
            'prNumber': '42',
            'repoName': 'technova/api',
            'diff': sample_diff,
            'prTitle': 'update dockerfile'
        }
    )

    result = analyze_pr(event, None)
    body = json.loads(result['response']['responseBody']['application/json']['body'])

    print(f"\nResumo: {body['summary']}")
    print(f"Risco: {body['riskLevel']}")
    print(f"Recomendação: {body['recommendation']}")
    print(f"\nFindings ({len(body['findings'])}):")
    for f in body['findings']:
        print(f"  [{f['severity']}] {f['type']}: {f['message']}")
    print()


def test_detect_drift():
    """Testa detecção de drift."""
    print("=" * 60)
    print("TESTE: Detect Drift")
    print("=" * 60)

    event = create_agent_event(
        'drift-detector',
        '/detect-drift',
        {
            'terraformDir': 'terraform/notifications',
            'environment': 'staging'
        }
    )

    result = detect_drift(event, None)
    body = json.loads(result['response']['responseBody']['application/json']['body'])

    print(f"\nDrift detectado: {body['hasDrift']}")
    if body['hasDrift']:
        print(f"Recursos driftados: {len(body['driftedResources'])}")
        for r in body['driftedResources']:
            print(f"  - {r['resourceType']}.{r['resourceName']}: "
                  f"{r['attribute']} ({r['expected']} → {r['actual']})")
        print(f"\nRemediação:")
        for step in body['remediationSteps']:
            print(f"  {step}")
    print()


def test_generate_runbook():
    """Testa geração de runbook."""
    print("=" * 60)
    print("TESTE: Generate Runbook")
    print("=" * 60)

    event = create_agent_event(
        'runbook-generator',
        '/generate-runbook',
        {
            'scenario': 'Container crash do technova-notifications após OOM kill',
            'severity': 'high',
            'affectedServices': 'technova-notifications,technova-api'
        }
    )

    result = generate_runbook(event, None)
    body = json.loads(result['response']['responseBody']['application/json']['body'])

    print(f"\nTítulo: {body['title']}")
    print(f"Severidade: {body['severity']}")
    print(f"Tempo estimado: {body['estimatedTime']}")
    print(f"\nPassos ({len(body['steps'])}):")
    for step in body['steps']:
        print(f"  {step['order']}. {step['action']}")
        print(f"     Comando: {step['command']}")
        print(f"     Esperado: {step['expectedResult']}")
    print(f"\nPrevenção:")
    for p in body['prevention']:
        print(f"  • {p}")
    print()


if __name__ == '__main__':
    test_analyze_pr()
    test_detect_drift()
    test_generate_runbook()
    print("\n✅ Todos os testes locais passaram!")
```

```bash
cd bedrock-agent
python test_local.py
```

**Checkpoint:** Integração GitHub Actions configurada e teste local funcionando.

---

## Validação Final — Parte 2

### Critérios de sucesso

| Critério | Status |
|----------|--------|
| Schema OpenAPI definido com 3 action groups | ⬜ |
| Agent instruction prompt escrito | ⬜ |
| Lambda analyze_pr implementada e testada | ⬜ |
| Lambda detect_drift implementada e testada | ⬜ |
| Lambda generate_runbook implementada e testada | ⬜ |
| Terraform usando `LabRole`/`LabInstanceProfile` (sem criar IAM) | ⬜ |
| Workflow GitHub Actions para PR review | ⬜ |
| Workflow GitHub Actions para runbook generation | ⬜ |
| Teste local (test_local.py) passando | ⬜ |

---

## Problemas Comuns

| Problema | Solução |
|----------|---------|
| `boto3` não encontrado | `pip install boto3` no ambiente de teste |
| Agent não responde | Verificar AGENT_ID e ALIAS_ID nos secrets |
| Lambda timeout | Aumentar timeout para 60s (drift pode ser lento) |
| Diff muito grande para o agente | Truncar em 50000 chars (já implementado) |
| Permission denied no Bedrock | Confirmar que o agente usa a `LabRole` como resource role |
| Credencial expirada / token inválido | Reabrir o Learner Lab e recarregar os 3 secrets da sessão |
| test_local.py falha com import | Verificar que está rodando de `bedrock-agent/` |

---

## Entrega

Após completar ambas as partes, criar PR com todos os artefatos para `entregas/aula-14/SEU-RA/`.
