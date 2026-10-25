# Laboratório Parte 2 | Aula 12 — AIOps (CloudWatch + Bedrock)

## Objetivo

Implementar um sistema de monitoramento inteligente usando AIOps: configurar detecção de anomalias no CloudWatch, criar uma Lambda que integra com Amazon Bedrock para análise inteligente de incidentes, e configurar alertas preditivos com sugestão de remediação automática.

## Pré-requisitos

- Ter concluído o Laboratório Parte 1
- **AWS Academy Learner Lab** com a sessão iniciada (CloudWatch, Lambda, EventBridge e SNS cobertos pelos créditos do Lab)
- AWS CLI configurado com as credenciais da sessão (`us-east-1`)
- A role pré-existente **`LabRole`** disponível (o Lab não permite criar roles IAM)
- Acesso ao Amazon Bedrock habilitado (ou usar alternativa local — veja Nota)

> **⚠️ NOTA SOBRE BEDROCK:** O Amazon Bedrock requer habilitação no console AWS (Request Access). Se não tiver acesso, o lab fornece uma versão simulada local + alternativa com Kiro AI para os conceitos de análise inteligente. Os conceitos aprendidos são os mesmos.

---

## Roteiro

### Passo 1 — Emitir Métricas Customizadas para o CloudWatch

Vamos configurar a TechNova API para emitir métricas de negócio ao CloudWatch.

**1.1 Instalar AWS SDK:**

```bash
npm install @aws-sdk/client-cloudwatch @aws-sdk/client-cloudwatch-logs
```

**1.2 Criar módulo de métricas:**

Crie `src/metrics.js`:

```javascript
// src/metrics.js
// Emite métricas customizadas para o CloudWatch

const { CloudWatchClient, PutMetricDataCommand } = require('@aws-sdk/client-cloudwatch');

const client = new CloudWatchClient({ region: process.env.AWS_REGION || 'us-east-1' });

const NAMESPACE = 'TechNova/API';

async function emitMetric(metricName, value, unit = 'Count', dimensions = []) {
  const params = {
    Namespace: NAMESPACE,
    MetricData: [{
      MetricName: metricName,
      Value: value,
      Unit: unit,
      Timestamp: new Date(),
      Dimensions: [
        { Name: 'Environment', Value: process.env.NODE_ENV || 'development' },
        ...dimensions
      ]
    }]
  };

  try {
    await client.send(new PutMetricDataCommand(params));
  } catch (error) {
    // Não derrubar a app se CloudWatch falhar
    console.warn(`[Metrics] Falha ao emitir ${metricName}:`, error.message);
  }
}

// Métricas de negócio
async function trackOrderCreated() {
  await emitMetric('OrdersCreated', 1);
}

async function trackOrderFailed(errorType) {
  await emitMetric('OrdersFailed', 1, 'Count', [
    { Name: 'ErrorType', Value: errorType }
  ]);
}

async function trackResponseTime(durationMs, endpoint) {
  await emitMetric('ResponseTime', durationMs, 'Milliseconds', [
    { Name: 'Endpoint', Value: endpoint }
  ]);
}

async function trackErrorRate(statusCode) {
  if (statusCode >= 500) {
    await emitMetric('Error5xx', 1);
  } else if (statusCode >= 400) {
    await emitMetric('Error4xx', 1);
  }
}

module.exports = {
  emitMetric,
  trackOrderCreated,
  trackOrderFailed,
  trackResponseTime,
  trackErrorRate
};
```

**1.3 Criar middleware de métricas:**

Crie `src/middleware/metrics-middleware.js`:

```javascript
// src/middleware/metrics-middleware.js
const { trackResponseTime, trackErrorRate } = require('../metrics');

function metricsMiddleware(req, res, next) {
  const start = Date.now();

  // Intercepta o fim da resposta
  res.on('finish', async () => {
    const duration = Date.now() - start;
    const endpoint = `${req.method} ${req.route?.path || req.path}`;

    // Emitir métricas (fire-and-forget)
    trackResponseTime(duration, endpoint).catch(() => {});
    trackErrorRate(res.statusCode).catch(() => {});
  });

  next();
}

module.exports = metricsMiddleware;
```

**1.4 Integrar no server.js:**

```javascript
// Adicionar ao server.js
const metricsMiddleware = require('./src/middleware/metrics-middleware');
app.use(metricsMiddleware);
```

**1.5 Verificar que métricas estão sendo emitidas:**

```bash
# Iniciar app e fazer requests
node server.js &
for i in $(seq 1 10); do curl -s http://localhost:3000/orders > /dev/null; done

# Verificar métricas no CloudWatch (após ~1 min)
aws cloudwatch list-metrics --namespace "TechNova/API"
```

---

### Passo 2 — Configurar CloudWatch Anomaly Detection

**2.1 Criar anomaly detectors via AWS CLI:**

```bash
# Criar anomaly detector para ResponseTime
aws cloudwatch put-anomaly-detector \
  --namespace "TechNova/API" \
  --metric-name "ResponseTime" \
  --stat "Average" \
  --dimensions Name=Environment,Value=production

# Criar anomaly detector para Error5xx
aws cloudwatch put-anomaly-detector \
  --namespace "TechNova/API" \
  --metric-name "Error5xx" \
  --stat "Sum" \
  --dimensions Name=Environment,Value=production

# Verificar detectors criados
aws cloudwatch describe-anomaly-detectors \
  --namespace "TechNova/API"
```

> **💡 Nota:** O Anomaly Detection precisa de ~2 semanas de dados para aprender o baseline. Para o lab, usaremos alarmes com thresholds fixos como demonstração do fluxo, com a configuração de anomaly detection preparada para produção.

**2.2 Criar alarmes CloudWatch (até 10 alarmes cobertos pelos créditos do Lab):**

```bash
# Alarme de latência alta (threshold fixo para o lab)
aws cloudwatch put-metric-alarm \
  --alarm-name "TechNova-HighLatency" \
  --namespace "TechNova/API" \
  --metric-name "ResponseTime" \
  --statistic "Average" \
  --period 60 \
  --evaluation-periods 3 \
  --threshold 1000 \
  --comparison-operator "GreaterThanThreshold" \
  --dimensions Name=Environment,Value=production \
  --alarm-description "Latência média > 1s por 3 minutos consecutivos" \
  --alarm-actions "arn:aws:sns:us-east-1:ACCOUNT_ID:technova-alerts"

# Alarme de taxa de erros 5xx
aws cloudwatch put-metric-alarm \
  --alarm-name "TechNova-HighError5xx" \
  --namespace "TechNova/API" \
  --metric-name "Error5xx" \
  --statistic "Sum" \
  --period 60 \
  --evaluation-periods 2 \
  --threshold 10 \
  --comparison-operator "GreaterThanThreshold" \
  --dimensions Name=Environment,Value=production \
  --alarm-description "Mais de 10 erros 5xx em 2 minutos" \
  --alarm-actions "arn:aws:sns:us-east-1:ACCOUNT_ID:technova-alerts"

# Verificar alarmes
aws cloudwatch describe-alarms \
  --alarm-name-prefix "TechNova-"
```

**2.3 Criar alarme com Anomaly Detection (para produção):**

```bash
# Este alarme usa ML para definir o threshold dinamicamente
aws cloudwatch put-metric-alarm \
  --alarm-name "TechNova-ResponseTime-Anomaly" \
  --evaluation-periods 3 \
  --datapoints-to-alarm 2 \
  --comparison-operator "GreaterThanUpperThreshold" \
  --threshold-metric-id "ad1" \
  --metrics '[
    {
      "Id": "m1",
      "MetricStat": {
        "Metric": {
          "Namespace": "TechNova/API",
          "MetricName": "ResponseTime",
          "Dimensions": [{"Name": "Environment", "Value": "production"}]
        },
        "Period": 60,
        "Stat": "Average"
      }
    },
    {
      "Id": "ad1",
      "Expression": "ANOMALY_DETECTION_BAND(m1, 2)"
    }
  ]' \
  --alarm-description "Latência fora da banda de anomalia (2 desvios)" \
  --alarm-actions "arn:aws:sns:us-east-1:ACCOUNT_ID:technova-alerts"
```

---

### Passo 3 — Lambda de Análise Inteligente com Bedrock

Vamos criar a Lambda que recebe alertas de anomalia e usa Bedrock para análise.

**3.1 Criar a Lambda function:**

Crie `lambda-aiops/index.js`:

```javascript
// lambda-aiops/index.js
// Lambda que analisa anomalias usando Amazon Bedrock

const { BedrockRuntimeClient, InvokeModelCommand } = require('@aws-sdk/client-bedrock-runtime');
const { CloudWatchClient, GetMetricDataCommand } = require('@aws-sdk/client-cloudwatch');
const { CloudWatchLogsClient, FilterLogEventsCommand } = require('@aws-sdk/client-cloudwatch-logs');
const { SNSClient, PublishCommand } = require('@aws-sdk/client-sns');

const bedrock = new BedrockRuntimeClient({ region: 'us-east-1' });
const cloudwatch = new CloudWatchClient({ region: 'us-east-1' });
const logs = new CloudWatchLogsClient({ region: 'us-east-1' });
const sns = new SNSClient({ region: 'us-east-1' });

const SNS_TOPIC_ARN = process.env.SNS_TOPIC_ARN;
const LOG_GROUP = process.env.LOG_GROUP || '/technova/api';

exports.handler = async (event) => {
  console.log('📥 Evento recebido:', JSON.stringify(event, null, 2));

  try {
    // 1. Extrair informações do alarme
    const alarmInfo = parseAlarmEvent(event);
    console.log('🔔 Alarme:', alarmInfo);

    // 2. Coletar contexto (métricas + logs recentes)
    const context = await gatherContext(alarmInfo);
    console.log('📊 Contexto coletado:', {
      metricsCount: context.metrics.length,
      logsCount: context.errorLogs.length
    });

    // 3. Analisar com Bedrock
    const analysis = await analyzeWithBedrock(alarmInfo, context);
    console.log('🤖 Análise Bedrock:', analysis);

    // 4. Notificar equipe com análise inteligente
    await notifyTeam(alarmInfo, analysis);

    // 5. Log da decisão para auditoria
    console.log('📋 Decisão:', {
      severidade: analysis.severidade,
      rollback: analysis.rollback_necessario,
      confianca: analysis.confianca
    });

    return { statusCode: 200, body: JSON.stringify(analysis) };
  } catch (error) {
    console.error('❌ Erro no handler:', error);
    // Mesmo com erro na análise IA, notificar que há anomalia
    await notifyTeam(
      { alarmName: 'Unknown', metricName: 'Unknown', timestamp: new Date().toISOString() },
      { resumo: 'Anomalia detectada - análise IA falhou - verificar manualmente', severidade: 'P2' }
    );
    throw error;
  }
};

function parseAlarmEvent(event) {
  const detail = event.detail || {};
  return {
    alarmName: detail.alarmName || event.alarmName || 'Unknown',
    metricName: detail.configuration?.metrics?.[0]?.metricStat?.metric?.metricName || 'Unknown',
    currentValue: detail.state?.value || 'N/A',
    previousState: detail.previousState?.value || 'OK',
    timestamp: detail.state?.timestamp || new Date().toISOString(),
    reason: detail.state?.reason || 'Anomaly detected'
  };
}

async function gatherContext(alarmInfo) {
  const endTime = new Date();
  const startTime = new Date(endTime - 15 * 60 * 1000); // últimos 15 min

  // Coletar métricas relevantes
  const metricsResponse = await cloudwatch.send(new GetMetricDataCommand({
    StartTime: startTime,
    EndTime: endTime,
    MetricDataQueries: [
      {
        Id: 'response_time',
        MetricStat: {
          Metric: {
            Namespace: 'TechNova/API',
            MetricName: 'ResponseTime',
            Dimensions: [{ Name: 'Environment', Value: 'production' }]
          },
          Period: 60,
          Stat: 'Average'
        }
      },
      {
        Id: 'error_5xx',
        MetricStat: {
          Metric: {
            Namespace: 'TechNova/API',
            MetricName: 'Error5xx',
            Dimensions: [{ Name: 'Environment', Value: 'production' }]
          },
          Period: 60,
          Stat: 'Sum'
        }
      },
      {
        Id: 'orders_created',
        MetricStat: {
          Metric: {
            Namespace: 'TechNova/API',
            MetricName: 'OrdersCreated',
            Dimensions: [{ Name: 'Environment', Value: 'production' }]
          },
          Period: 60,
          Stat: 'Sum'
        }
      }
    ]
  }));

  // Coletar logs de erro recentes
  let errorLogs = [];
  try {
    const logsResponse = await logs.send(new FilterLogEventsCommand({
      logGroupName: LOG_GROUP,
      startTime: startTime.getTime(),
      endTime: endTime.getTime(),
      filterPattern: '?ERROR ?error ?FATAL ?Exception ?TypeError',
      limit: 20
    }));
    errorLogs = (logsResponse.events || []).map(e => e.message);
  } catch (e) {
    console.warn('⚠️ Não foi possível coletar logs:', e.message);
  }

  return {
    metrics: metricsResponse.MetricDataResults || [],
    errorLogs
  };
}
```

**3.2 Função de análise com Bedrock (continuação do index.js):**

```javascript
// Continuação de lambda-aiops/index.js

async function analyzeWithBedrock(alarmInfo, context) {
  const prompt = buildAnalysisPrompt(alarmInfo, context);

  const input = {
    modelId: 'anthropic.claude-3-haiku-20240307-v1:0',
    contentType: 'application/json',
    accept: 'application/json',
    body: JSON.stringify({
      anthropic_version: 'bedrock-2023-05-31',
      max_tokens: 1024,
      messages: [{
        role: 'user',
        content: prompt
      }]
    })
  };

  try {
    const response = await bedrock.send(new InvokeModelCommand(input));
    const responseBody = JSON.parse(new TextDecoder().decode(response.body));
    const analysisText = responseBody.content[0].text;

    // Extrair JSON da resposta
    const jsonMatch = analysisText.match(/\{[\s\S]*\}/);
    return jsonMatch ? JSON.parse(jsonMatch[0]) : { 
      resumo: analysisText, 
      severidade: 'P3',
      confianca: 'baixa' 
    };
  } catch (error) {
    console.error('⚠️ Bedrock falhou, usando análise baseada em regras:', error.message);
    return ruleBasedAnalysis(alarmInfo, context);
  }
}

// Fallback: análise baseada em regras (se Bedrock não disponível)
function ruleBasedAnalysis(alarmInfo, context) {
  const errorCount = context.errorLogs.length;
  const hasTypeError = context.errorLogs.some(l => l.includes('TypeError'));
  const hasTimeout = context.errorLogs.some(l => l.includes('timeout') || l.includes('Timeout'));

  if (hasTypeError && errorCount > 5) {
    return {
      severidade: 'P1',
      causa_raiz_provavel: 'Bug no código: TypeError detectado nos logs. Provavelmente introduzido no último deploy.',
      confianca: 'alta',
      acao_recomendada: 'Rollback imediato para versão anterior',
      rollback_necessario: true,
      resumo: 'TypeError em produção - provável bug no último deploy'
    };
  }

  if (hasTimeout) {
    return {
      severidade: 'P1',
      causa_raiz_provavel: 'Timeouts detectados. Possível problema de conexão com banco de dados ou serviço externo.',
      confianca: 'media',
      acao_recomendada: 'Verificar conexões de banco e serviços externos. Considerar restart.',
      rollback_necessario: false,
      resumo: 'Timeouts detectados - possível problema de infraestrutura'
    };
  }

  return {
    severidade: 'P2',
    causa_raiz_provavel: `Anomalia na métrica ${alarmInfo.metricName}. Análise manual necessária.`,
    confianca: 'baixa',
    acao_recomendada: 'Verificar logs e métricas manualmente',
    rollback_necessario: false,
    resumo: `Anomalia em ${alarmInfo.metricName} - investigação necessária`
  };
}

function buildAnalysisPrompt(alarmInfo, context) {
  const metricsStr = context.metrics.map(m => 
    `${m.Label}: valores=[${m.Values?.slice(0, 10).join(', ')}]`
  ).join('\n');

  const logsStr = context.errorLogs.slice(0, 10).join('\n');

  return `Você é um engenheiro SRE da TechNova analisando um incidente em produção.

ANOMALIA DETECTADA:
- Alarme: ${alarmInfo.alarmName}
- Métrica: ${alarmInfo.metricName}
- Valor atual: ${alarmInfo.currentValue}
- Estado anterior: ${alarmInfo.previousState}
- Timestamp: ${alarmInfo.timestamp}
- Razão: ${alarmInfo.reason}

MÉTRICAS DOS ÚLTIMOS 15 MINUTOS:
${metricsStr || 'Sem dados disponíveis'}

LOGS DE ERRO RECENTES:
${logsStr || 'Sem erros nos logs'}

CONTEXTO DO SISTEMA:
- Aplicação: TechNova API (Node.js/Express)
- Infraestrutura: EC2 + Docker
- Banco: PostgreSQL

Analise e responda APENAS em JSON válido:
{
  "severidade": "P1|P2|P3|P4",
  "causa_raiz_provavel": "descrição concisa",
  "confianca": "alta|media|baixa",
  "evidencias": ["evidência 1", "evidência 2"],
  "acao_recomendada": "ação específica",
  "rollback_necessario": true/false,
  "resumo": "descrição em uma frase para notificação"
}`;
}

async function notifyTeam(alarmInfo, analysis) {
  const emoji = { 'P1': '🚨', 'P2': '⚠️', 'P3': '📋', 'P4': 'ℹ️' };

  const message = `${emoji[analysis.severidade] || '📋'} *AIOps Alert - TechNova*
*Alarme:* ${alarmInfo.alarmName || alarmInfo.metricName}
*Severidade:* ${analysis.severidade}
*Resumo:* ${analysis.resumo}
*Causa raiz provável:* ${analysis.causa_raiz_provavel || 'Análise em andamento'}
*Confiança:* ${analysis.confianca || 'N/A'}
*Ação recomendada:* ${analysis.acao_recomendada || 'Investigar manualmente'}
*Rollback necessário:* ${analysis.rollback_necessario ? 'SIM' : 'Não'}
_Timestamp: ${alarmInfo.timestamp}_`;

  if (SNS_TOPIC_ARN) {
    await sns.send(new PublishCommand({
      TopicArn: SNS_TOPIC_ARN,
      Subject: `[${analysis.severidade}] TechNova AIOps: ${analysis.resumo?.substring(0, 80)}`,
      Message: message
    }));
  }

  console.log('📨 Notificação:', message);
}
```

---

### Passo 4 — Deploy da Lambda e Configuração EventBridge

**4.1 Package.json da Lambda:**

Crie `lambda-aiops/package.json`:

```json
{
  "name": "technova-aiops-analyzer",
  "version": "1.0.0",
  "description": "Lambda AIOps - Análise inteligente de anomalias com Bedrock",
  "main": "index.js",
  "dependencies": {
    "@aws-sdk/client-bedrock-runtime": "^3.400.0",
    "@aws-sdk/client-cloudwatch": "^3.400.0",
    "@aws-sdk/client-cloudwatch-logs": "^3.400.0",
    "@aws-sdk/client-sns": "^3.400.0"
  }
}
```

**4.2 Deploy da Lambda (com a role pré-existente `LabRole`):**

> **☁️ Learner Lab:** o Lab **não permite criar roles IAM** (a criação de role falha com `AccessDenied`). Em vez disso, a Lambda usa a role pré-existente **`LabRole`**, que já tem as permissões necessárias para CloudWatch, Logs, SNS e Bedrock. Descubra o ARN da `LabRole` com o comando abaixo.

```bash
# Instalar dependências e criar zip
cd lambda-aiops
npm install --production
zip -r ../lambda-aiops.zip .
cd ..

# Descobrir o ARN da role pré-existente LabRole (o Lab não cria roles novas)
LAB_ROLE_ARN=$(aws iam get-role --role-name LabRole --query 'Role.Arn' --output text)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Usando role: $LAB_ROLE_ARN"

# Criar a Lambda usando a LabRole
aws lambda create-function \
  --function-name TechNovaAIOpsAnalyzer \
  --runtime nodejs18.x \
  --role "$LAB_ROLE_ARN" \
  --handler index.handler \
  --zip-file fileb://lambda-aiops.zip \
  --timeout 60 \
  --memory-size 256 \
  --region us-east-1 \
  --environment "Variables={SNS_TOPIC_ARN=arn:aws:sns:us-east-1:${ACCOUNT_ID}:technova-alerts,LOG_GROUP=/technova/api}"
```

> **💡 Permissões:** a `LabRole` já abrange CloudWatch (GetMetricData), CloudWatch Logs (FilterLogEvents), SNS (Publish) e Bedrock (InvokeModel) dentro do Lab. Não é preciso (nem permitido) criar policies ou roles novas — se algum `InvokeModel` falhar por acesso ao modelo, confirme o Request Access do Bedrock no console.

**4.3 Configurar EventBridge para disparar Lambda:**

```bash
# Criar regra EventBridge
aws events put-rule \
  --name "TechNova-Anomaly-Trigger" \
  --event-pattern '{
    "source": ["aws.cloudwatch"],
    "detail-type": ["CloudWatch Alarm State Change"],
    "detail": {
      "alarmName": [{"prefix": "TechNova-"}],
      "state": {"value": ["ALARM"]}
    }
  }' \
  --description "Dispara análise AIOps quando alarme da TechNova ativa"

# Permissão para EventBridge invocar Lambda
aws lambda add-permission \
  --function-name TechNovaAIOpsAnalyzer \
  --statement-id EventBridgeInvoke \
  --action lambda:InvokeFunction \
  --principal events.amazonaws.com \
  --source-arn arn:aws:events:us-east-1:ACCOUNT_ID:rule/TechNova-Anomaly-Trigger

# Adicionar Lambda como target
aws events put-targets \
  --rule "TechNova-Anomaly-Trigger" \
  --targets '[{
    "Id": "AIOpsAnalyzer",
    "Arn": "arn:aws:lambda:us-east-1:ACCOUNT_ID:function:TechNovaAIOpsAnalyzer"
  }]'

# Verificar configuração
aws events describe-rule --name "TechNova-Anomaly-Trigger"
aws events list-targets-by-rule --rule "TechNova-Anomaly-Trigger"
```

---

### Passo 5 — Alternativa Local (Sem Bedrock): Simulação Interativa

Para quem não tem acesso ao Bedrock, aqui está uma simulação local completa.

**5.1 Criar simulador local:**

Crie `lambda-aiops/local-simulator.js`:

```javascript
// lambda-aiops/local-simulator.js
// Simulador local para testar o fluxo AIOps sem AWS

const readline = require('readline');

// Cenários simulados de anomalia
const mockScenarios = {
  'high-latency': {
    alarm: {
      alarmName: 'TechNova-ResponseTime-Anomaly',
      metricName: 'ResponseTime',
      currentValue: '850ms (banda esperada: 100-300ms)',
      previousState: 'OK',
      timestamp: new Date().toISOString(),
      reason: 'Latência 3x acima do normal para este horário'
    },
    context: {
      metrics: [
        { Label: 'ResponseTime', Values: [120, 145, 200, 380, 520, 650, 800, 850] },
        { Label: 'Error5xx', Values: [0, 0, 0, 2, 5, 8, 12, 15] },
        { Label: 'OrdersCreated', Values: [45, 42, 38, 30, 22, 15, 8, 5] }
      ],
      errorLogs: [
        'ERROR [14:32:01] Connection timeout to database after 5000ms',
        'ERROR [14:32:15] Query execution exceeded 3s limit',
        'ERROR [14:33:02] Pool exhausted - all connections busy',
        'FATAL [14:33:45] Unable to acquire connection from pool'
      ]
    },
    expectedAnalysis: {
      severidade: 'P1',
      causa_raiz_provavel: 'Pool de conexões DB esgotado. Logs mostram timeouts e "pool exhausted". Provável query lenta bloqueando conexões.',
      confianca: 'alta',
      evidencias: [
        'Logs: "Connection timeout" e "Pool exhausted"',
        'Latência crescente correlaciona com erros de DB',
        'Throughput caindo (OrdersCreated diminuindo)'
      ],
      acao_recomendada: 'Restart container para liberar conexões. Investigar query lenta. Considerar aumentar pool size.',
      rollback_necessario: false,
      resumo: 'Pool de conexões DB esgotado - timeouts generalizados'
    }
  },
  'error-spike': {
    alarm: {
      alarmName: 'TechNova-Error5xx-Anomaly',
      metricName: 'Error5xx',
      currentValue: '45 erros/min (normal: 0-2/min)',
      previousState: 'OK',
      timestamp: new Date().toISOString(),
      reason: 'Taxa de erros 5xx 20x acima do baseline'
    },
    context: {
      metrics: [
        { Label: 'ResponseTime', Values: [150, 155, 160, 145, 155, 150] },
        { Label: 'Error5xx', Values: [1, 0, 2, 15, 28, 45] },
        { Label: 'OrdersCreated', Values: [40, 42, 38, 25, 10, 3] }
      ],
      errorLogs: [
        'ERROR [15:10:01] TypeError: Cannot read property "id" of undefined',
        'ERROR [15:10:02] at processOrder (/app/routes/orders.js:47:23)',
        'ERROR [15:10:03] TypeError: Cannot read property "id" of undefined',
        'ERROR [15:10:15] Unhandled rejection in order processing pipeline'
      ]
    },
    expectedAnalysis: {
      severidade: 'P1',
      causa_raiz_provavel: 'Bug no código: TypeError consistente em processOrder. Campo "id" indefinido - provavelmente payload mudou no último deploy.',
      confianca: 'alta',
      evidencias: [
        'TypeError em orders.js:47 (consistente)',
        'Erros iniciaram abruptamente (deploy recente)',
        'Latência normal mas throughput caiu (requests falhando rápido)'
      ],
      acao_recomendada: 'ROLLBACK IMEDIATO para versão anterior. Bug introduzido no último deploy.',
      rollback_necessario: true,
      resumo: 'Bug no último deploy - TypeError em 100% dos pedidos - ROLLBACK'
    }
  },
  'memory-leak': {
    alarm: {
      alarmName: 'TechNova-Memory-Trend',
      metricName: 'MemoryUsage',
      currentValue: '92% (crescendo +5%/hora há 8h)',
      previousState: 'OK',
      timestamp: new Date().toISOString(),
      reason: 'Memória crescendo linearmente, OOM previsto em ~2h'
    },
    context: {
      metrics: [
        { Label: 'MemoryUsage', Values: [55, 60, 65, 70, 75, 80, 85, 92] },
        { Label: 'ResponseTime', Values: [120, 125, 130, 140, 160, 190, 250, 380] },
        { Label: 'GCPauses', Values: [10, 15, 20, 35, 50, 80, 120, 200] }
      ],
      errorLogs: [
        'WARN [08:00:00] Heap usage at 55% - monitoring',
        'WARN [12:00:00] Heap usage at 75% - elevated',
        'WARN [14:00:00] GC pause exceeded 100ms threshold',
        'ERROR [15:30:00] Heap usage critical: 92% - near OOM'
      ]
    },
    expectedAnalysis: {
      severidade: 'P2',
      causa_raiz_provavel: 'Memory leak na aplicação. Crescimento linear constante (~5%/hora) por 8 horas. GC pauses correlacionam.',
      confianca: 'media',
      evidencias: [
        'Memória crescendo linearmente (não spike)',
        'GC pauses aumentando proporcionalmente',
        'Latência degradando gradualmente (GC back-pressure)'
      ],
      acao_recomendada: 'Restart preventivo AGORA (antes do OOM). Na próxima ocorrência, capturar heap dump para investigação.',
      rollback_necessario: false,
      resumo: 'Memory leak - OOM em ~2h - restart preventivo recomendado'
    }
  }
};

// CLI interativa
async function runSimulation() {
  console.log('\n🤖 ═══════════════════════════════════════════════════');
  console.log('   TechNova AIOps Simulator (sem Bedrock)');
  console.log('═══════════════════════════════════════════════════════\n');
  console.log('Cenários disponíveis:');
  console.log('  1. high-latency  — Pool de DB esgotado');
  console.log('  2. error-spike   — Bug no último deploy');
  console.log('  3. memory-leak   — Vazamento de memória progressivo\n');

  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  
  rl.question('Escolha o cenário (1/2/3): ', (answer) => {
    const scenarios = ['high-latency', 'error-spike', 'memory-leak'];
    const scenarioKey = scenarios[parseInt(answer) - 1] || 'high-latency';
    const scenario = mockScenarios[scenarioKey];
    
    console.log('\n─── FASE 1: Anomalia Detectada (CloudWatch → EventBridge) ───\n');
    console.log('📥 Alarme disparado:');
    console.log(`   Nome: ${scenario.alarm.alarmName}`);
    console.log(`   Métrica: ${scenario.alarm.metricName}`);
    console.log(`   Valor: ${scenario.alarm.currentValue}`);
    console.log(`   Razão: ${scenario.alarm.reason}`);
    
    console.log('\n─── FASE 2: Coleta de Contexto (Lambda → CloudWatch) ────────\n');
    console.log('📊 Métricas coletadas (últimos 15 min):');
    scenario.context.metrics.forEach(m => {
      console.log(`   ${m.Label}: [${m.Values.join(', ')}]`);
    });
    console.log('\n📋 Logs de erro recentes:');
    scenario.context.errorLogs.forEach(l => console.log(`   ${l}`));
    
    console.log('\n─── FASE 3: Análise Inteligente (Lambda → Bedrock) ──────────\n');
    console.log('🤖 Análise AIOps:');
    const a = scenario.expectedAnalysis;
    console.log(JSON.stringify(a, null, 2));
    
    console.log('\n─── FASE 4: Notificação (Lambda → SNS/Slack) ─────────────────\n');
    const emoji = { 'P1': '🚨', 'P2': '⚠️', 'P3': '📋' };
    console.log(`${emoji[a.severidade]} [${a.severidade}] ${a.resumo}`);
    console.log(`   Causa: ${a.causa_raiz_provavel}`);
    console.log(`   Ação: ${a.acao_recomendada}`);
    console.log(`   Rollback: ${a.rollback_necessario ? '⚡ SIM - EXECUTAR' : '❌ Não necessário'}`);
    
    console.log('\n═══════════════════════════════════════════════════════════════');
    console.log('💡 Em produção: Bedrock analisa com contexto real e sugere ações');
    console.log('   Use Kiro AI para simular: cole métricas + logs e peça análise');
    console.log('═══════════════════════════════════════════════════════════════\n');
    
    rl.close();
  });
}

// Modo não-interativo (para testes automatizados)
if (process.argv[2]) {
  const scenarios = ['high-latency', 'error-spike', 'memory-leak'];
  const scenario = mockScenarios[scenarios[parseInt(process.argv[2]) - 1] || 'high-latency'];
  console.log(JSON.stringify(scenario.expectedAnalysis, null, 2));
} else {
  runSimulation();
}
```

**5.2 Executar simulação:**

```bash
cd lambda-aiops

# Modo interativo
node local-simulator.js

# Modo direto (para scripts)
node local-simulator.js 1  # high-latency
node local-simulator.js 2  # error-spike
node local-simulator.js 3  # memory-leak
```

> **💡 Alternativa com Kiro AI:** Abra o Kiro e peça: *"Analise este cenário de incidente como um SRE. Aqui estão as métricas e logs..."* — cole os dados do simulador. Compare a resposta do Kiro com a análise esperada. Isso demonstra o mesmo conceito que o Bedrock faria via API.

---

### Passo 6 — Testar o Fluxo Completo

**6.1 Testar Lambda localmente (mock de evento):**

Crie `lambda-aiops/test-event.json`:

```json
{
  "source": "aws.cloudwatch",
  "detail-type": "CloudWatch Alarm State Change",
  "detail": {
    "alarmName": "TechNova-HighLatency",
    "state": {
      "value": "ALARM",
      "reason": "Threshold crossed: Average ResponseTime > 1000 for 3 periods",
      "timestamp": "2024-01-15T14:30:00Z"
    },
    "previousState": {
      "value": "OK"
    },
    "configuration": {
      "metrics": [{
        "metricStat": {
          "metric": {
            "namespace": "TechNova/API",
            "metricName": "ResponseTime"
          }
        }
      }]
    }
  }
}
```

**6.2 Invocar Lambda com evento de teste:**

```bash
# Via AWS CLI (se Lambda já deployada)
aws lambda invoke \
  --function-name TechNovaAIOpsAnalyzer \
  --payload file://lambda-aiops/test-event.json \
  --cli-binary-format raw-in-base64-out \
  response.json

cat response.json | jq .

# Ver logs da execução
aws logs tail /aws/lambda/TechNovaAIOpsAnalyzer --since 5m
```

**6.3 Forçar alarme para testar fluxo end-to-end:**

```bash
# Emitir métrica alta para disparar o alarme
aws cloudwatch put-metric-data \
  --namespace "TechNova/API" \
  --metric-name "ResponseTime" \
  --value 2000 \
  --unit Milliseconds \
  --dimensions Name=Environment,Value=production

# Repetir 3x (para atingir 3 evaluation periods)
for i in $(seq 1 3); do
  aws cloudwatch put-metric-data \
    --namespace "TechNova/API" \
    --metric-name "ResponseTime" \
    --value 2000 \
    --unit Milliseconds \
    --dimensions Name=Environment,Value=production
  sleep 60
done

# Verificar estado do alarme
aws cloudwatch describe-alarms \
  --alarm-names "TechNova-HighLatency" \
  --query 'MetricAlarms[0].StateValue'
```

---

## Validação

Ao final desta parte, você deve ter:

- [ ] Módulo de métricas implementado (`src/metrics.js`)
- [ ] Middleware emitindo métricas em cada request
- [ ] Pelo menos 2 alarmes CloudWatch configurados (latência e erros)
- [ ] Anomaly detector configurado (mesmo sem dados suficientes para ML)
- [ ] Lambda AIOps criada com a `LabRole` e deployada (ou testada localmente)
- [ ] EventBridge conectando alarme → Lambda
- [ ] Simulador local funcional para testes sem Bedrock
- [ ] Teste end-to-end executado (forçar alarme → Lambda executou)

> **⚠️ Limpeza:** Após o lab, remova recursos para evitar consumo dos créditos do Lab (e rode `terraform destroy` se provisionou infra via Terraform):
> ```bash
> aws lambda delete-function --function-name TechNovaAIOpsAnalyzer
> aws events remove-targets --rule TechNova-Anomaly-Trigger --ids AIOpsAnalyzer
> aws events delete-rule --name TechNova-Anomaly-Trigger
> aws cloudwatch delete-alarms --alarm-names TechNova-HighLatency TechNova-HighError5xx
> ```

---

## Diagrama Final da Arquitetura

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ARQUITETURA AIOPS - TECHNOVA                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────┐     ┌──────────────┐     ┌─────────────────────┐   │
│  │ TechNova API│────►│  CloudWatch  │────►│    EventBridge      │   │
│  │  (métricas) │     │  (anomaly    │     │  (alarme → evento)  │   │
│  └─────────────┘     │   detection) │     └──────────┬──────────┘   │
│                       └──────────────┘                │              │
│                                                       ▼              │
│  ┌─────────────┐     ┌──────────────┐     ┌─────────────────────┐   │
│  │    SNS      │◄────│   Lambda     │────►│   Amazon Bedrock    │   │
│  │ (notifica)  │     │ (LabRole)    │     │   (análise IA)      │   │
│  └──────┬──────┘     └──────┬───────┘     └─────────────────────┘   │
│         │                    │                                        │
│         ▼                    ▼                                        │
│  ┌─────────────┐     ┌──────────────┐                                │
│  │ Slack/Email │     │  Rollback    │                                │
│  │  (equipe)   │     │ (automático) │                                │
│  └─────────────┘     └──────────────┘                                │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```
