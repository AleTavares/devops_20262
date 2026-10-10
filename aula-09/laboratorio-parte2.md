# Aula 09 — Laboratório Parte 2: PR Review Automatizado com IA

## Missão

Implementar um sistema de code review automatizado por IA para a TechNova. A cada Pull Request aberto, um workflow analisará o código alterado e postará feedback automático — identificando problemas de segurança, qualidade e boas práticas antes que qualquer humano precise revisar.

**Tempo estimado:** ~120 minutos

**Resultado final:**
- Workflow disparado em PRs que coleta o diff dos arquivos alterados
- Script de análise que formata prompt e envia para IA
- Comentário automático postado no PR com achados categorizados
- Security scanning focado em vulnerabilidades comuns
- Quality gate que bloqueia PR em caso de achados críticos
- Teste completo com PR contendo problemas intencionais

---

## Pré-requisitos

- [ ] Repositório `unifaat-devops-portfolio` no GitHub (público)
- [ ] Pasta `aula-09/technova-api/` com o Dockerfile otimizado da Parte 1
- [ ] Pipeline CI da Aula 08 funcionando
- [ ] Build+push da Parte 1 desta aula funcionando
- [ ] Familiaridade com conceitos de IA (Aulas 02 e 07)

> **💡 Este lab oferece duas abordagens:**
> - **Opção A (Recomendada):** Usar GitHub Action de AI review (gratuita, funciona sem Bedrock)
> - **Opção B (Avançada):** Implementação conceitual com script que chamaria Bedrock
>
> Ambas ensinam os mesmos conceitos. Use a Opção A para resultado prático imediato.

---

## Parte 1 — Workflow de Review Disparado em PRs (20 min)

### 1.1 Entendendo o trigger

O workflow de AI review deve:
- Disparar quando um PR é **aberto** ou **atualizado** (novo push)
- Coletar os arquivos que foram alterados
- NÃO disparar em push direto para main (para isso temos o CI)

### 1.2 Criar o workflow base

Crie `.github/workflows/ai-review.yml`:

```yaml
name: AI Code Review

on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: read
  pull-requests: write

jobs:
  ai-review:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout do código
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Obter arquivos alterados
        id: changed-files
        run: |
          # Obter diff entre base e head do PR
          FILES=$(git diff --name-only origin/${{ github.base_ref }}...HEAD)
          echo "Arquivos alterados:"
          echo "$FILES"
          echo "files<<EOF" >> $GITHUB_OUTPUT
          echo "$FILES" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Obter diff do código
        id: diff
        run: |
          DIFF=$(git diff origin/${{ github.base_ref }}...HEAD -- '*.js' '*.ts' '*.json' '*.yml' '*.yaml' 'Dockerfile*')
          echo "diff<<EOF" >> $GITHUB_OUTPUT
          echo "$DIFF" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT
```

### 1.3 Entendendo o `fetch-depth: 0`

```yaml
uses: actions/checkout@v4
with:
  fetch-depth: 0    # Busca histórico completo (necessário para git diff)
```

Sem isso, o checkout traz apenas o último commit e `git diff` não funciona.

---

## Parte 2 — Implementando AI Review (30 min)

### Opção A — Usando GitHub Action de AI Review (Recomendada)

Existem actions gratuitas que integram IA ao review de PRs. Vamos usar uma abordagem com `actions/github-script` que analisa o diff com regras programáticas e pode ser estendida para chamar APIs de IA:

Atualize o `.github/workflows/ai-review.yml` adicionando o step de análise:

```yaml
name: AI Code Review

on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: read
  pull-requests: write

jobs:
  ai-review:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout do código
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Obter diff do PR
        id: diff
        run: |
          DIFF=$(git diff origin/${{ github.base_ref }}...HEAD)
          # Salvar diff em arquivo (pode ser grande demais para variável)
          echo "$DIFF" > /tmp/pr-diff.txt
          echo "diff_file=/tmp/pr-diff.txt" >> $GITHUB_OUTPUT

      - name: Executar análise de código
        id: analysis
        run: |
          node .github/scripts/ai-review.js
        env:
          DIFF_FILE: /tmp/pr-diff.txt
          GITHUB_BASE_REF: ${{ github.base_ref }}

      - name: Postar comentário no PR
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const fs = require('fs');
            const review = fs.readFileSync('/tmp/ai-review-result.md', 'utf8');

            await github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: review
            });
```

### 2.1 Criar o script de análise

Crie o diretório e arquivo `.github/scripts/ai-review.js`:

```javascript
const fs = require('fs');
const path = require('path');

// ============================================
// Script de AI Review para TechNova
// ============================================
// Este script analisa o diff do PR e identifica problemas.
// Em produção, a seção "analyzeWithAI" chamaria Bedrock/OpenAI.
// Para o lab, usamos análise baseada em regras (pattern matching).

const SEVERITY = {
  CRITICAL: '🔴 CRITICAL',
  WARNING: '🟡 WARNING',
  INFO: '🔵 INFO'
};

// Padrões de problemas a detectar
const SECURITY_PATTERNS = [
  {
    pattern: /(password|secret|key|token)\s*[:=]\s*['"][^'"]+['"]/gi,
    message: 'Possível secret/credencial hardcoded detectada',
    severity: SEVERITY.CRITICAL
  },
  {
    pattern: /eval\s*\(/g,
    message: 'Uso de eval() - risco de code injection',
    severity: SEVERITY.CRITICAL
  },
  {
    pattern: /\bexec\s*\(\s*['"`].*\$\{/g,
    message: 'Possível command injection via template literal',
    severity: SEVERITY.CRITICAL
  },
  {
    pattern: /query\s*\(\s*['"`].*\+/g,
    message: 'Possível SQL injection - use queries parametrizadas',
    severity: SEVERITY.CRITICAL
  },
  {
    pattern: /console\.(log|debug|info)\(/g,
    message: 'Console.log em código de produção (remover ou usar logger)',
    severity: SEVERITY.WARNING
  },
  {
    pattern: /TODO|FIXME|HACK|XXX/g,
    message: 'Comentário TODO/FIXME encontrado - resolver antes de merge',
    severity: SEVERITY.INFO
  },
  {
    pattern: /catch\s*\(\s*\w*\s*\)\s*\{\s*\}/g,
    message: 'Catch vazio - erros silenciados podem esconder bugs',
    severity: SEVERITY.WARNING
  },
  {
    pattern: /0\.0\.0\.0|INADDR_ANY/g,
    message: 'Binding em 0.0.0.0 - verificar se intencional em produção',
    severity: SEVERITY.WARNING
  }
];

function analyzeDiff(diffContent) {
  const findings = [];
  const lines = diffContent.split('\n');
  let currentFile = '';

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Detectar arquivo atual
    if (line.startsWith('+++ b/')) {
      currentFile = line.replace('+++ b/', '');
      continue;
    }

    // Analisar apenas linhas adicionadas
    if (line.startsWith('+') && !line.startsWith('+++')) {
      const addedCode = line.substring(1);

      for (const rule of SECURITY_PATTERNS) {
        if (rule.pattern.test(addedCode)) {
          findings.push({
            file: currentFile,
            line: i,
            code: addedCode.trim().substring(0, 80),
            message: rule.message,
            severity: rule.severity
          });
          // Reset regex lastIndex
          rule.pattern.lastIndex = 0;
        }
      }
    }
  }

  return findings;
}

```javascript
function generateReport(findings) {
  if (findings.length === 0) {
    return `## 🤖 AI Code Review - TechNova

✅ **Nenhum problema encontrado!**

O código alterado neste PR passou pela análise automatizada sem achados.
Lembre-se: este review automático complementa, mas não substitui, o review humano.

---
*Review automatizado por AI Pipeline - TechNova DevOps*`;
  }

  const criticals = findings.filter(f => f.severity === SEVERITY.CRITICAL);
  const warnings = findings.filter(f => f.severity === SEVERITY.WARNING);
  const infos = findings.filter(f => f.severity === SEVERITY.INFO);

  let report = `## 🤖 AI Code Review - TechNova\n\n`;
  report += `**Resumo:** ${findings.length} achado(s) encontrado(s)\n`;
  report += `- ${SEVERITY.CRITICAL}: ${criticals.length}\n`;
  report += `- ${SEVERITY.WARNING}: ${warnings.length}\n`;
  report += `- ${SEVERITY.INFO}: ${infos.length}\n\n`;

  if (criticals.length > 0) {
    report += `> ⛔ **Este PR tem achados CRITICAL que devem ser corrigidos antes do merge.**\n\n`;
  }

  report += `### Achados Detalhados\n\n`;
  report += `| Severidade | Arquivo | Problema | Código |\n`;
  report += `|:----------:|---------|----------|--------|\n`;

  for (const finding of findings) {
    const shortFile = finding.file.length > 30
      ? '...' + finding.file.slice(-27)
      : finding.file;
    const shortCode = finding.code.length > 40
      ? finding.code.substring(0, 37) + '...'
      : finding.code;
    report += `| ${finding.severity} | \`${shortFile}\` | ${finding.message} | \`${shortCode}\` |\n`;
  }

  report += `\n---\n`;
  report += `*Review automatizado por AI Pipeline - TechNova DevOps*\n`;
  report += `*⚠️ Falsos positivos são possíveis. Avalie cada achado criticamente.*`;

  return report;
}

// ============================================
// Execução Principal
// ============================================
const diffFile = process.env.DIFF_FILE || '/tmp/pr-diff.txt';

try {
  const diffContent = fs.readFileSync(diffFile, 'utf8');
  const findings = analyzeDiff(diffContent);
  const report = generateReport(findings);

  // Salvar resultado para o próximo step
  fs.writeFileSync('/tmp/ai-review-result.md', report);

  console.log(`\nAnálise completa: ${findings.length} achado(s)`);
  console.log(report);

  // Se há achados CRITICAL, sinalizar (mas não falhar ainda - Parte 5 implementa isso)
  const hasCritical = findings.some(f => f.severity === SEVERITY.CRITICAL);
  if (hasCritical) {
    console.log('\n⚠️ Achados CRITICAL encontrados!');
    // process.exit(1); // Descomente na Parte 5 para bloquear PR
  }
} catch (error) {
  console.error('Erro na análise:', error.message);
  const errorReport = `## 🤖 AI Code Review - TechNova\n\n⚠️ Erro durante a análise: ${error.message}`;
  fs.writeFileSync('/tmp/ai-review-result.md', errorReport);
}
```

### Opção B — Implementação Conceitual com Bedrock (Avançada)

Para quem tem acesso ao AWS Bedrock, o script chamaria a API diretamente:

```javascript
// .github/scripts/ai-review-bedrock.js (CONCEITUAL)
// Este script requer: AWS credentials configuradas no workflow
// e acesso ao modelo Claude via Bedrock

const { BedrockRuntimeClient, InvokeModelCommand } = require('@aws-sdk/client-bedrock-runtime');

async function reviewWithBedrock(diffContent) {
  const client = new BedrockRuntimeClient({ region: 'us-east-1' });

  const prompt = `Você é um revisor de código experiente. Analise o seguinte diff de um Pull Request e identifique:
1. Problemas de SEGURANÇA (CRITICAL): secrets, injection, vulnerabilidades
2. Problemas de QUALIDADE (WARNING): code smells, padrões ruins, performance
3. SUGESTÕES (INFO): melhorias opcionais, boas práticas

Para cada achado, forneça:
- Arquivo e linha aproximada
- Severidade (CRITICAL/WARNING/INFO)
- Descrição do problema
- Sugestão de correção

Diff do PR:
\`\`\`diff
${diffContent.substring(0, 10000)}
\`\`\`

Responda em formato Markdown com tabela.`;

  const command = new InvokeModelCommand({
    modelId: 'anthropic.claude-3-haiku-20240307-v1:0',
    body: JSON.stringify({
      anthropic_version: 'bedrock-2023-05-31',
      max_tokens: 2048,
      messages: [{ role: 'user', content: prompt }]
    }),
    contentType: 'application/json'
  });

  const response = await client.send(command);
  const result = JSON.parse(new TextDecoder().decode(response.body));
  return result.content[0].text;
}
```

> **💡 Para o lab, use a Opção A.** A Opção B é referência para implementação futura com Bedrock.

---

## Parte 3 — Postar AI Review como Comentário no PR (25 min)

### 3.1 Entendendo o mecanismo de comentários

O workflow usa `actions/github-script` para interagir com a API do GitHub:

```yaml
- name: Postar comentário no PR
  uses: actions/github-script@v7
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    script: |
      const fs = require('fs');
      const review = fs.readFileSync('/tmp/ai-review-result.md', 'utf8');

      await github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: review
      });
```

### 3.2 Tratando caso sem problemas

Quando a IA não encontra problemas, é importante dar feedback positivo:

```markdown
## 🤖 AI Code Review - TechNova

✅ **Nenhum problema encontrado!**

O código alterado neste PR passou pela análise automatizada sem achados.
Lembre-se: este review automático complementa, mas não substitui, o review humano.
```

### 3.3 Formato do comentário com problemas

Quando problemas são encontrados:

```markdown
## 🤖 AI Code Review - TechNova

**Resumo:** 3 achado(s) encontrado(s)
- 🔴 CRITICAL: 1
- 🟡 WARNING: 1
- 🔵 INFO: 1

> ⛔ **Este PR tem achados CRITICAL que devem ser corrigidos antes do merge.**

### Achados Detalhados

| Severidade | Arquivo | Problema | Código |
|:----------:|---------|----------|--------|
| 🔴 CRITICAL | `server.js` | Possível secret hardcoded | `const apiKey = 'sk-123...'` |
| 🟡 WARNING | `routes/orders.js` | Console.log em produção | `console.log('debug:', da...` |
| 🔵 INFO | `server.js` | TODO encontrado | `// TODO: implementar cache` |
```

### 3.4 Evitar comentários duplicados

Para evitar múltiplos comentários em pushes seguidos ao mesmo PR, adicione lógica para atualizar o comentário existente:

```yaml
      - name: Postar ou atualizar comentário
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const fs = require('fs');
            const review = fs.readFileSync('/tmp/ai-review-result.md', 'utf8');
            const marker = '## 🤖 AI Code Review - TechNova';

            // Buscar comentário existente do bot
            const comments = await github.rest.issues.listComments({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number
            });

            const existingComment = comments.data.find(
              c => c.body.includes(marker) && c.user.type === 'Bot'
            );

            if (existingComment) {
              // Atualizar comentário existente
              await github.rest.issues.updateComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                comment_id: existingComment.id,
                body: review
              });
              console.log('Comentário atualizado:', existingComment.id);
            } else {
              // Criar novo comentário
              await github.rest.issues.createComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: context.issue.number,
                body: review
              });
              console.log('Novo comentário criado');
            }

---

## Parte 4 — Security Scanning Focado com IA (20 min)

### 4.1 Criar workflow dedicado de segurança

Além do review geral, crie um workflow focado exclusivamente em segurança.

Crie `.github/workflows/security-scan.yml`:

```yaml
name: Security Scan

on:
  pull_request:
    types: [opened, synchronize]
    paths:
      - '**.js'
      - '**.ts'
      - 'Dockerfile*'
      - 'docker-compose*'
      - '.env*'
      - 'package*.json'

permissions:
  contents: read
  pull-requests: write

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Verificar secrets no código
        id: secrets-check
        run: |
          echo "## 🔒 Security Scan Results" > /tmp/security-report.md
          echo "" >> /tmp/security-report.md
          FOUND=0

          # Verificar padrões de secrets
          echo "### Verificação de Secrets Hardcoded" >> /tmp/security-report.md
          echo "" >> /tmp/security-report.md

          # AWS Keys
          if git diff origin/${{ github.base_ref }}...HEAD | grep -iE "AKIA[0-9A-Z]{16}"; then
            echo "- 🔴 **CRITICAL:** Possível AWS Access Key detectada!" >> /tmp/security-report.md
            FOUND=1
          fi

          # Passwords em strings
          if git diff origin/${{ github.base_ref }}...HEAD | grep -iE "password\s*[:=]\s*['\"][^'\"]{4,}"; then
            echo "- 🔴 **CRITICAL:** Possível password hardcoded!" >> /tmp/security-report.md
            FOUND=1
          fi

          # Private keys
          if git diff origin/${{ github.base_ref }}...HEAD | grep -E "BEGIN (RSA |EC |DSA )?PRIVATE KEY"; then
            echo "- 🔴 **CRITICAL:** Chave privada encontrada no código!" >> /tmp/security-report.md
            FOUND=1
          fi

          # JWT secrets
          if git diff origin/${{ github.base_ref }}...HEAD | grep -iE "jwt[_-]?secret\s*[:=]"; then
            echo "- 🔴 **CRITICAL:** JWT secret hardcoded!" >> /tmp/security-report.md
            FOUND=1
          fi

          if [ $FOUND -eq 0 ]; then
            echo "✅ Nenhum secret hardcoded detectado." >> /tmp/security-report.md
          fi

          echo "found=$FOUND" >> $GITHUB_OUTPUT

      - name: Verificar Dockerfile security
        env:
          DOCKERFILE: aula-09/technova-api/Dockerfile
        run: |
          echo "" >> /tmp/security-report.md
          echo "### Verificação de Dockerfile" >> /tmp/security-report.md
          echo "" >> /tmp/security-report.md

          if [ -f "$DOCKERFILE" ]; then
            # Verificar se roda como root
            if ! grep -q "^USER" "$DOCKERFILE"; then
              echo "- 🟡 **WARNING:** Dockerfile não define USER (roda como root)" >> /tmp/security-report.md
            else
              echo "- ✅ Dockerfile define usuário não-root" >> /tmp/security-report.md
            fi

            # Verificar tag latest em FROM
            if grep -E "^FROM.*:latest" "$DOCKERFILE"; then
              echo "- 🟡 **WARNING:** FROM usa tag :latest (não reproduzível)" >> /tmp/security-report.md
            fi

            # Verificar HEALTHCHECK
            if grep -q "HEALTHCHECK" "$DOCKERFILE"; then
              echo "- ✅ HEALTHCHECK configurado" >> /tmp/security-report.md
            else
              echo "- 🔵 **INFO:** Considere adicionar HEALTHCHECK" >> /tmp/security-report.md
            fi
          fi

      - name: Postar resultado
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('/tmp/security-report.md', 'utf8');

            await github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: report
            });
```

### 4.2 Comparação: IA vs Ferramentas Tradicionais

| Ferramenta | O que faz | Complementa IA? |
|-----------|----------|:----------------:|
| **Dependabot** | Verifica vulnerabilidades em dependências (package.json) | Sim — IA analisa código, Dependabot analisa deps |
| **CodeQL** | Análise estática profunda (data flow, taint analysis) | Sim — CodeQL é mais preciso para fluxos complexos |
| **Trivy** | Scan de vulnerabilidades em imagens Docker | Sim — Trivy foca no container, IA foca no código |
| **AI Review** | Análise contextual do diff com entendimento semântico | Sim — IA entende intenção, ferramentas seguem regras |

**A melhor estratégia combina todas:** cada uma pega coisas diferentes.

---

## Parte 5 — Quality Gates com IA (15 min)

### 5.1 Implementar bloqueio de PR em achados críticos

Modifique o script `ai-review.js` para falhar o workflow quando encontrar achados CRITICAL:

No final do arquivo `.github/scripts/ai-review.js`, descomente a linha:

```javascript
  // Bloquear PR se há achados CRITICAL
  const hasCritical = findings.some(f => f.severity === SEVERITY.CRITICAL);
  if (hasCritical) {
    console.log('\n⛔ PR BLOQUEADO: achados CRITICAL encontrados.');
    console.log('Corrija os problemas e faça push novamente.');
    process.exit(1);  // ← DESCOMENTE ESTA LINHA
  }
```

### 5.2 Configurar como required status check

Para que o PR seja realmente bloqueado (não apenas mostre ❌):

1. Vá para **Settings → Branches → Branch protection rules**
2. Selecione (ou crie regra para) `main`
3. Ative **Require status checks to pass before merging**
4. Adicione `ai-review` como required check

### 5.3 Níveis de severidade e ações

| Severidade | Ação no Pipeline | Ação do Developer |
|:----------:|:----------------:|:-----------------:|
| 🔴 CRITICAL | `exit 1` — bloqueia PR | Obrigatório corrigir |
| 🟡 WARNING | Posta comentário, permite merge | Recomendado corrigir |
| 🔵 INFO | Posta comentário, permite merge | Opcional, sugestão |

### 5.4 Discussão: Quando bloquear vs informar?

Nem tudo que a IA encontra deve bloquear. Considere:

- **BLOQUEAR (CRITICAL):** secrets no código, vulnerabilidades de injection, eval()
- **INFORMAR (WARNING):** console.log, catch vazio, TODO em código novo
- **SUGERIR (INFO):** naming conventions, oportunidades de refactor

> **⚠️ Falsos positivos:** Se a IA bloquear erroneamente, o dev pode justificar e pedir override. O bloqueio é uma trava de segurança, não uma ditadura.

---

## Parte 6 — Testando o Review com PR Problemático (10 min)

### 6.1 Criar branch com problemas intencionais

```bash
# Criar branch de teste
git checkout -b feature/test-ai-review
```

### 6.2 Adicionar código com problemas

Crie um arquivo `test-problems.js` com problemas intencionais:

```javascript
// test-problems.js - Arquivo para testar AI Review
// TODO: remover este arquivo após teste

const express = require('express');

// 🔴 CRITICAL: Secret hardcoded
const apiKey = 'sk-1234567890abcdef';
const dbPassword = 'super_secret_123';

// 🔴 CRITICAL: SQL Injection
function getUser(userId) {
  const query = 'SELECT * FROM users WHERE id = ' + userId;
  return db.query(query);
}

// 🟡 WARNING: Console.log em produção
function processOrder(order) {
  console.log('Processing order:', order);
  return order;
}

// 🟡 WARNING: Catch vazio
try {
  dangerousOperation();
} catch (e) {}

// 🔴 CRITICAL: eval com input
function evaluate(userInput) {
  return eval(userInput);
}

module.exports = { getUser, processOrder, evaluate };
```

### 6.3 Abrir PR

```bash
git add test-problems.js
git commit -m "feat: add new utility functions"
git push origin feature/test-ai-review
```

Abra um PR no GitHub: `feature/test-ai-review` → `main`

### 6.4 Observar o AI Review

1. Vá para a aba **Actions** — veja o workflow `AI Code Review` executando
2. Após conclusão, vá para o **PR** — veja o comentário do bot
3. Verifique que os achados CRITICAL, WARNING e INFO foram detectados
4. Se quality gate está ativo: PR deve estar com status ❌

### 6.5 Corrigir e re-testar

```bash
# Remover o arquivo de teste
git rm test-problems.js
git commit -m "fix: remove test file with security issues"
git push origin feature/test-ai-review
```

O workflow roda novamente. Agora deve postar: "✅ Nenhum problema encontrado!"

> **✅ Checkpoint:** AI review funciona — detecta problemas, posta comentário, e atualiza ao corrigir

---

## Troubleshooting

| Problema | Causa Provável | Solução |
|----------|---------------|---------|
| Workflow não dispara | Trigger incorreto ou arquivo no path errado | Verificar `on: pull_request` e path do YAML |
| `git diff` vazio | `fetch-depth: 0` ausente no checkout | Adicionar `with: fetch-depth: 0` |
| Comentário não aparece | Permissão `pull-requests: write` ausente | Adicionar bloco `permissions` |
| Script falha com "file not found" | Path do diff file incorreto | Verificar `DIFF_FILE` env var |
| `Resource not accessible by integration` | Token sem permissão | Verificar Settings → Actions → Workflow permissions |
| Muitos falsos positivos | Regras muito agressivas | Ajustar patterns no `ai-review.js` |
| Comentários duplicados | Falta lógica de update | Implementar busca+update (Parte 3.4) |

---

## Checklist de Validação

Antes de finalizar, confirme:

- [ ] Workflow `ai-review.yml` criado e disparando em PRs
- [ ] Script `.github/scripts/ai-review.js` analisa diff corretamente
- [ ] Comentário automático postado no PR com achados categorizados
- [ ] Caso sem problemas: comentário positivo (✅)
- [ ] Caso com problemas: tabela com severidade, arquivo e descrição
- [ ] Security scan detecta secrets, eval, SQL injection
- [ ] Quality gate: CRITICAL bloqueia PR (exit 1)
- [ ] WARNING e INFO: informam mas não bloqueiam
- [ ] Comentário é atualizado (não duplicado) em novos pushes
- [ ] PR de teste: problemas detectados → corrigidos → review atualizado

> **🎯 Se todos os itens estão ✅, você implementou AI Review completo!** Agora cada PR da TechNova tem um revisor que nunca dorme.
