# Laboratório Parte 1 | Aula 12 — Rollback Strategies

## Objetivo

Implementar um sistema completo de rollback para a TechNova API incluindo: feature flags para controle sem redeploy, migrações de banco de dados reversíveis (expand-contract), e políticas de rollback automático no pipeline CD.

## Pré-requisitos

- Repositório `technova-api` no GitHub com pipeline CD funcional (Aula 10/11)
- Docker instalado e funcionando
- Node.js ≥ 18 instalado
- Infraestrutura EC2 da TechNova (ou ambiente local com Docker Compose)
- Imagens versionadas no **Amazon ECR** (publicadas na Aula 09, `us-east-1`)
- Conhecimento de GitHub Actions (Aula 09/10)

---

## Roteiro

### Passo 1 — Implementar Feature Flags na Aplicação

Vamos adicionar um sistema de feature flags baseado em variáveis de ambiente à TechNova API.

**1.1 Criar o módulo de feature flags:**

Crie o arquivo `src/feature-flags.js`:

```javascript
// src/feature-flags.js
// Sistema de Feature Flags para a TechNova API

class FeatureFlags {
  constructor() {
    this.flags = {};
    this.loadFlags();
  }

  loadFlags() {
    // Carrega flags de variáveis de ambiente (prefixo FF_)
    Object.keys(process.env)
      .filter(key => key.startsWith('FF_'))
      .forEach(key => {
        const flagName = key.replace('FF_', '').toLowerCase();
        this.flags[flagName] = process.env[key] === 'true';
      });

    console.log('[FeatureFlags] Flags carregadas:', this.flags);
  }

  isEnabled(flagName) {
    const normalizedName = flagName.toLowerCase();
    return this.flags[normalizedName] === true;
  }

  getAllFlags() {
    return { ...this.flags };
  }

  // Permite reload dinâmico (útil para integração com AppConfig)
  reload() {
    this.loadFlags();
  }
}

// Singleton
const featureFlags = new FeatureFlags();
module.exports = featureFlags;
```

**1.2 Criar endpoint de status das flags:**

Crie `routes/flags.js`:

```javascript
// routes/flags.js
const express = require('express');
const router = express.Router();
const featureFlags = require('../src/feature-flags');

// GET /flags — retorna status das feature flags (apenas em ambientes não-prod)
router.get('/', (req, res) => {
  if (process.env.NODE_ENV === 'production') {
    return res.status(403).json({ error: 'Endpoint desabilitado em produção' });
  }
  res.json({ flags: featureFlags.getAllFlags() });
});

// POST /flags/reload — recarrega flags (útil com AppConfig)
router.post('/reload', (req, res) => {
  if (process.env.NODE_ENV === 'production') {
    return res.status(403).json({ error: 'Endpoint desabilitado em produção' });
  }
  featureFlags.reload();
  res.json({ message: 'Flags recarregadas', flags: featureFlags.getAllFlags() });
});

module.exports = router;
```

**1.3 Usar feature flag no código de pedidos:**

Modifique `routes/orders.js` para usar feature flags:

```javascript
const featureFlags = require('../src/feature-flags');

// Funções de cálculo de frete
function calculateShippingV1(items) {
  // Versão legada: R$10 fixo
  return 10.00;
}

function calculateShippingV2(items) {
  // Nova versão: baseado em peso e região
  const totalWeight = items.reduce((sum, item) => sum + (item.weight || 0.5), 0);
  return Math.max(5.00, totalWeight * 3.50);
}

function calculateBulkDiscount(items) {
  // Desconto para pedidos com 10+ itens
  const total = items.reduce((sum, item) => sum + item.price, 0);
  return total * 0.1; // 10% de desconto
}

// POST /orders — criar pedido
router.post('/', async (req, res) => {
  try {
    const { items, customer_id } = req.body;

    // Feature flag: novo sistema de cálculo de frete
    let shipping;
    if (featureFlags.isEnabled('new_shipping_calc')) {
      shipping = calculateShippingV2(items);
    } else {
      shipping = calculateShippingV1(items);
    }

    // Feature flag: desconto bulk orders
    let discount = 0;
    if (featureFlags.isEnabled('bulk_orders') && items.length >= 10) {
      discount = calculateBulkDiscount(items);
    }

    const total = items.reduce((sum, item) => sum + item.price, 0);

    const order = {
      id: Date.now(),
      customer_id,
      items,
      shipping,
      discount,
      total: total + shipping - discount,
      created_at: new Date().toISOString()
    };

    res.status(201).json(order);
  } catch (error) {
    console.error('[Orders] Erro ao criar pedido:', error.message);
    res.status(500).json({ error: 'Erro interno ao processar pedido' });
  }
});
```

**1.4 Configurar variáveis de ambiente:**

Adicione ao `.env`:

```env
# Feature Flags
FF_NEW_SHIPPING_CALC=true
FF_BULK_ORDERS=false
FF_AI_RECOMMENDATIONS=false
FF_NEW_CHECKOUT=true
```

**1.5 Testar as flags:**

```bash
# Iniciar com flags ativas
FF_NEW_SHIPPING_CALC=true FF_BULK_ORDERS=false node server.js

# Testar endpoint de flags
curl http://localhost:3000/flags

# Testar criação de pedido (usa nova shipping)
curl -X POST http://localhost:3000/orders \
  -H "Content-Type: application/json" \
  -d '{"customer_id": "123", "items": [{"name": "Widget", "price": 29.90, "weight": 0.3}]}'

# Simular "rollback" da feature de shipping (restart com flag desligada)
FF_NEW_SHIPPING_CALC=false node server.js

# Testar novamente — agora usa cálculo legado
curl -X POST http://localhost:3000/orders \
  -H "Content-Type: application/json" \
  -d '{"customer_id": "123", "items": [{"name": "Widget", "price": 29.90, "weight": 0.3}]}'
```

---

### Passo 2 — Migrações de Banco de Dados Reversíveis

Vamos implementar o padrão expand-contract para uma migração segura.

**2.1 Criar estrutura de migrações:**

```bash
mkdir -p migrations
```

Crie `migrations/001_expand_add_customer_email.js`:

```javascript
// migrations/001_expand_add_customer_email.js
// FASE EXPAND: adiciona nova coluna sem remover a antiga

module.exports = {
  version: '001',
  description: 'Expand: adiciona customer_email em orders (mantém customer_name)',
  
  up: async (db) => {
    // Adiciona nova coluna (não remove nada)
    await db.query(`
      ALTER TABLE orders 
      ADD COLUMN IF NOT EXISTS customer_email VARCHAR(255);
    `);
    
    // Popula com dados existentes (se houver tabela de customers)
    await db.query(`
      UPDATE orders o
      SET customer_email = c.email
      FROM customers c
      WHERE o.customer_id = c.id
      AND o.customer_email IS NULL;
    `);
    
    console.log('[Migration 001] UP: coluna customer_email adicionada');
  },

  down: async (db) => {
    // Rollback: remove a coluna nova (volta ao estado anterior)
    await db.query(`
      ALTER TABLE orders DROP COLUMN IF EXISTS customer_email;
    `);
    
    console.log('[Migration 001] DOWN: coluna customer_email removida');
  },

  // Validação: verifica se a migração foi aplicada corretamente
  verify: async (db) => {
    const result = await db.query(`
      SELECT column_name FROM information_schema.columns
      WHERE table_name = 'orders' AND column_name = 'customer_email';
    `);
    return result.rows.length === 1;
  }
};
```

**2.2 Criar segunda migração (expand-contract completo):**

Crie `migrations/002_expand_order_status_enum.js`:

```javascript
// migrations/002_expand_order_status_enum.js
// FASE EXPAND: adiciona novo campo status_v2 com mais opções

module.exports = {
  version: '002',
  description: 'Expand: adiciona status_v2 (enum expandido) mantendo status original',
  
  up: async (db) => {
    // Cria enum expandido
    await db.query(`
      DO $$ BEGIN
        CREATE TYPE order_status_v2 AS ENUM (
          'pending', 'confirmed', 'processing', 
          'shipped', 'delivered', 'cancelled', 'refunded'
        );
      EXCEPTION WHEN duplicate_object THEN NULL;
      END $$;
    `);

    // Adiciona nova coluna com enum expandido
    await db.query(`
      ALTER TABLE orders 
      ADD COLUMN IF NOT EXISTS status_v2 order_status_v2 DEFAULT 'pending';
    `);

    // Copia dados do campo antigo para o novo
    await db.query(`
      UPDATE orders SET status_v2 = status::text::order_status_v2
      WHERE status_v2 IS NULL OR status_v2 = 'pending';
    `);
    
    console.log('[Migration 002] UP: status_v2 adicionado');
  },

  down: async (db) => {
    await db.query(`ALTER TABLE orders DROP COLUMN IF EXISTS status_v2;`);
    await db.query(`DROP TYPE IF EXISTS order_status_v2;`);
    console.log('[Migration 002] DOWN: status_v2 e tipo removidos');
  },

  verify: async (db) => {
    const result = await db.query(`
      SELECT column_name FROM information_schema.columns
      WHERE table_name = 'orders' AND column_name = 'status_v2';
    `);
    return result.rows.length === 1;
  }
};
```

**2.3 Criar o runner de migrações:**

Crie `migrations/runner.js`:

```javascript
// migrations/runner.js
const fs = require('fs');
const path = require('path');

class MigrationRunner {
  constructor(db) {
    this.db = db;
    this.migrationsDir = __dirname;
  }

  async ensureMigrationsTable() {
    await this.db.query(`
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version VARCHAR(10) PRIMARY KEY,
        description TEXT,
        applied_at TIMESTAMP DEFAULT NOW(),
        rolled_back_at TIMESTAMP
      );
    `);
  }

  async getAppliedMigrations() {
    const result = await this.db.query(`
      SELECT version FROM schema_migrations 
      WHERE rolled_back_at IS NULL
      ORDER BY version;
    `);
    return result.rows.map(r => r.version);
  }

  async migrate() {
    await this.ensureMigrationsTable();
    const applied = await this.getAppliedMigrations();
    
    const files = fs.readdirSync(this.migrationsDir)
      .filter(f => f.match(/^\d{3}_.*\.js$/))
      .sort();

    for (const file of files) {
      const migration = require(path.join(this.migrationsDir, file));
      
      if (!applied.includes(migration.version)) {
        console.log(`[Migrate] Aplicando ${migration.version}: ${migration.description}`);
        
        await this.db.query('BEGIN');
        try {
          await migration.up(this.db);
          await this.db.query(`
            INSERT INTO schema_migrations (version, description)
            VALUES ($1, $2);
          `, [migration.version, migration.description]);
          await this.db.query('COMMIT');
          
          // Verificar
          if (migration.verify) {
            const valid = await migration.verify(this.db);
            console.log(`[Migrate] Verificação: ${valid ? '✅' : '❌'}`);
          }
        } catch (error) {
          await this.db.query('ROLLBACK');
          throw new Error(`Migration ${migration.version} falhou: ${error.message}`);
        }
      }
    }
  }

  async rollback(targetVersion) {
    await this.ensureMigrationsTable();
    const applied = await this.getAppliedMigrations();
    
    // Rollback em ordem reversa até o targetVersion
    const toRollback = applied
      .filter(v => v > targetVersion)
      .reverse();

    for (const version of toRollback) {
      const file = fs.readdirSync(this.migrationsDir)
        .find(f => f.startsWith(version));
      
      if (!file) throw new Error(`Migration file not found for ${version}`);
      
      const migration = require(path.join(this.migrationsDir, file));
      
      console.log(`[Rollback] Revertendo ${version}: ${migration.description}`);
      
      await this.db.query('BEGIN');
      try {
        await migration.down(this.db);
        await this.db.query(`
          UPDATE schema_migrations 
          SET rolled_back_at = NOW()
          WHERE version = $1;
        `, [version]);
        await this.db.query('COMMIT');
      } catch (error) {
        await this.db.query('ROLLBACK');
        throw new Error(`Rollback ${version} falhou: ${error.message}`);
      }
    }
  }
}

module.exports = MigrationRunner;
```

**2.4 Script CLI para migrações:**

Crie `migrations/cli.js`:

```javascript
// migrations/cli.js
const { Pool } = require('pg');
const MigrationRunner = require('./runner');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/technova'
});

const runner = new MigrationRunner(pool);
const command = process.argv[2];
const arg = process.argv[3];

(async () => {
  try {
    switch (command) {
      case 'up':
        await runner.migrate();
        console.log('✅ Migrações aplicadas com sucesso');
        break;
      case 'down':
        if (!arg) {
          console.error('Uso: node cli.js down <version>');
          console.error('Ex: node cli.js down 000 (reverte todas)');
          console.error('Ex: node cli.js down 001 (reverte até manter 001)');
          process.exit(1);
        }
        await runner.rollback(arg);
        console.log(`✅ Rollback até versão ${arg} concluído`);
        break;
      case 'status':
        const applied = await runner.getAppliedMigrations();
        console.log('Migrações aplicadas:', applied.length > 0 ? applied : '(nenhuma)');
        break;
      default:
        console.log('Uso: node cli.js [up|down|status]');
        console.log('  up       — aplica todas as migrações pendentes');
        console.log('  down VER — reverte migrações até a versão VER');
        console.log('  status   — mostra migrações aplicadas');
    }
  } catch (error) {
    console.error('❌ Erro:', error.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
})();
```

**2.5 Testar migração e rollback:**

```bash
# Subir banco de dados (se usando Docker Compose)
docker compose up -d postgres

# Aplicar migrações
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/technova node migrations/cli.js up

# Verificar status
node migrations/cli.js status

# Simular rollback (volta para antes da 002, mantém 001)
node migrations/cli.js down 001

# Rollback total (volta para antes de tudo)
node migrations/cli.js down 000

# Verificar que voltou
node migrations/cli.js status
```

---

### Passo 3 — Política de Rollback Automático no Pipeline

Vamos adicionar rollback automático ao pipeline CD com base em health checks.

**3.1 Criar script de health check com retry:**

Crie `scripts/health-check.sh`:

```bash
#!/bin/bash
# scripts/health-check.sh
# Verifica saúde da aplicação após deploy com retries

HOST=${1:-"localhost"}
PORT=${2:-3000}
MAX_RETRIES=${3:-10}
RETRY_INTERVAL=${4:-5}

echo "🏥 Iniciando health check em http://${HOST}:${PORT}/health"
echo "   Max retries: ${MAX_RETRIES}, Intervalo: ${RETRY_INTERVAL}s"

for i in $(seq 1 $MAX_RETRIES); do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://${HOST}:${PORT}/health" 2>/dev/null)
  
  if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Health check PASSED (tentativa $i/$MAX_RETRIES)"
    
    # Verificar métricas adicionais
    RESPONSE=$(curl -s "http://${HOST}:${PORT}/health")
    echo "   Response: $RESPONSE"
    exit 0
  fi
  
  echo "⏳ Tentativa $i/$MAX_RETRIES - HTTP $HTTP_CODE (esperando ${RETRY_INTERVAL}s...)"
  sleep $RETRY_INTERVAL
done

echo "❌ Health check FAILED após $MAX_RETRIES tentativas"
exit 1
```

**3.2 Criar script de rollback:**

Crie `scripts/rollback.sh`:

```bash
#!/bin/bash
# scripts/rollback.sh
# Executa rollback para a versão anterior (imagem no Amazon ECR)

CONTAINER_NAME=${1:-"technova-api"}
# ECR_URI no formato <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/technova-api
REGISTRY=${2:-"${ECR_URI:-"$(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/technova-api"}"}
PREVIOUS_TAG=${3:-""}
REGION=${AWS_REGION:-us-east-1}

echo "🔄 Iniciando ROLLBACK do container: $CONTAINER_NAME"

# Se tag anterior não foi fornecida, buscar do histórico
if [ -z "$PREVIOUS_TAG" ]; then
  echo "   Buscando última versão estável..."
  PREVIOUS_TAG=$(docker inspect --format='{{index .Config.Labels "previous.version"}}' $CONTAINER_NAME 2>/dev/null)
  
  if [ -z "$PREVIOUS_TAG" ]; then
    echo "❌ Não foi possível identificar versão anterior"
    echo "   Forneça a tag manualmente: ./rollback.sh container registry tag"
    exit 1
  fi
fi

echo "   Versão anterior identificada: $PREVIOUS_TAG"

# Login no ECR (token temporário do Learner Lab) antes do pull
REGISTRY_HOST="${REGISTRY%%/*}"
echo "   Login no ECR ($REGISTRY_HOST)..."
aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "$REGISTRY_HOST"

# Parar container atual
echo "   Parando container atual..."
docker stop $CONTAINER_NAME 2>/dev/null
docker rm $CONTAINER_NAME 2>/dev/null

# Fazer pull e subir versão anterior
echo "   Fazendo pull e iniciando versão anterior..."
docker pull "$REGISTRY:$PREVIOUS_TAG"
docker run -d \
  --name $CONTAINER_NAME \
  -p 3000:3000 \
  --restart unless-stopped \
  --env-file .env \
  "$REGISTRY:$PREVIOUS_TAG"

# Verificar se subiu
sleep 5
if docker ps | grep -q $CONTAINER_NAME; then
  echo "✅ ROLLBACK concluído! Container rodando com tag: $PREVIOUS_TAG"
  echo "   Verificando health..."
  sleep 3
  curl -s "http://localhost:3000/health" && echo ""
else
  echo "❌ ROLLBACK FALHOU! Container não iniciou"
  docker logs $CONTAINER_NAME --tail 20
  exit 1
fi
```

**3.3 Workflow GitHub Actions com rollback automático:**

Crie `.github/workflows/cd-with-rollback.yml`:

```yaml
name: CD with Automated Rollback

on:
  push:
    branches: [main]

env:
  AWS_REGION: us-east-1
  IMAGE_NAME: technova-api

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Credenciais temporárias do Learner Lab (secrets atualizados por sessão)
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
          aws-region: ${{ env.AWS_REGION }}

      - id: ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Get previous version
        id: previous
        run: |
          # Busca a tag da versão atualmente em produção
          PREV_SHA=$(curl -s -f http://${{ secrets.EC2_HOST }}:3000/health | jq -r '.version // empty' || echo "latest")
          echo "previous_version=${PREV_SHA}" >> $GITHUB_OUTPUT
          echo "📋 Versão anterior em produção: ${PREV_SHA}"

      - name: Build and Push Docker Image (Amazon ECR)
        env:
          REGISTRY: ${{ steps.ecr.outputs.registry }}
        run: |
          docker build -t ${REGISTRY}/${{ env.IMAGE_NAME }}:sha-${{ github.sha }} .
          docker push ${REGISTRY}/${{ env.IMAGE_NAME }}:sha-${{ github.sha }}

      - name: Deploy to EC2
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ubuntu
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            # No servidor, login no ECR antes do pull (token temporário)
            aws ecr get-login-password --region ${{ env.AWS_REGION }} \
              | docker login --username AWS --password-stdin ${{ steps.ecr.outputs.registry }}
            docker pull ${{ steps.ecr.outputs.registry }}/${{ env.IMAGE_NAME }}:sha-${{ github.sha }}
            docker stop technova-api || true
            docker rm technova-api || true
            docker run -d --name technova-api \
              -p 3000:3000 \
              --restart unless-stopped \
              --label "previous.version=${{ steps.previous.outputs.previous_version }}" \
              --env-file /home/ubuntu/.env \
              ${{ steps.ecr.outputs.registry }}/${{ env.IMAGE_NAME }}:sha-${{ github.sha }}

      - name: Health Check (janela de observação - 60s)
        id: healthcheck
        continue-on-error: true
        run: |
          echo "⏳ Aguardando 30s para estabilização..."
          sleep 30
          
          FAILURES=0
          for i in $(seq 1 6); do
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
              "http://${{ secrets.EC2_HOST }}:3000/health" 2>/dev/null)
            
            if [ "$HTTP_CODE" != "200" ]; then
              FAILURES=$((FAILURES + 1))
              echo "❌ Check $i/6: HTTP $HTTP_CODE"
            else
              echo "✅ Check $i/6: HTTP 200"
            fi
            sleep 10
          done
          
          echo "Resultado: $FAILURES/6 falhas"
          if [ $FAILURES -gt 2 ]; then
            echo "❌ Health check FAILED ($FAILURES/6 falhas)"
            exit 1
          fi
          echo "✅ Health check PASSED"

      - name: Automated Rollback (se health check falhou)
        if: steps.healthcheck.outcome == 'failure'
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ubuntu
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            echo "🚨 ROLLBACK AUTOMÁTICO INICIADO"
            echo "   Motivo: Health check falhou após deploy"
            echo "   Revertendo para: ${{ steps.previous.outputs.previous_version }}"
            aws ecr get-login-password --region ${{ env.AWS_REGION }} \
              | docker login --username AWS --password-stdin ${{ steps.ecr.outputs.registry }}
            docker stop technova-api || true
            docker rm technova-api || true
            docker pull ${{ steps.ecr.outputs.registry }}/${{ env.IMAGE_NAME }}:${{ steps.previous.outputs.previous_version }}
            docker run -d --name technova-api \
              -p 3000:3000 \
              --restart unless-stopped \
              --env-file /home/ubuntu/.env \
              ${{ steps.ecr.outputs.registry }}/${{ env.IMAGE_NAME }}:${{ steps.previous.outputs.previous_version }}
            echo "✅ Rollback concluído"

      - name: Notify on Rollback
        if: steps.healthcheck.outcome == 'failure'
        run: |
          echo "::error::🚨 Deploy ${{ github.sha }} foi REVERTIDO automaticamente!"
          echo "Versão restaurada: ${{ steps.previous.outputs.previous_version }}"
          echo "Investigar causa antes de novo deploy."
          # Integração com Slack/Teams (adicionar step com webhook)
          exit 1  # Marca o workflow como falho

      - name: Deploy Success
        if: steps.healthcheck.outcome == 'success'
        run: |
          echo "🎉 Deploy concluído com sucesso!"
          echo "   Versão: sha-${{ github.sha }}"
          echo "   Health check: PASSED"
```

> **☁️ Learner Lab:** as 3 credenciais (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`) são temporárias e precisam ser atualizadas como secrets a cada sessão. Em produção real (fora do Lab), o correto é OIDC + role IAM, sem secrets de longa duração.

---

### Passo 4 — Criar Runbook Operacional

**4.1 Criar runbook para o cenário de deploy falho:**

Crie `docs/runbooks/deploy-failed.md`:

```markdown
# Runbook: Deploy Falhou em Produção

## Trigger
- Health check retorna HTTP != 200 após deploy
- Pipeline CD reporta falha no step "Health Check"
- Alerta do CloudWatch: 5xx rate > 5%

## Severidade: P1 (Impacto em Produção)

## Diagnóstico Rápido (< 2 minutos)

1. Verificar qual versão está rodando:
   ```bash
   ssh ubuntu@EC2_HOST "docker ps --format '{{.Image}} {{.Status}}'"
   ```

2. Verificar logs recentes:
   ```bash
   ssh ubuntu@EC2_HOST "docker logs technova-api --tail 30 --since 5m"
   ```

3. Verificar se rollback automático executou:
   - Checar último workflow no GitHub Actions
   - Se executou: problema resolvido, investigar causa raiz

## Ação: Rollback Manual (se automático não executou)

```bash
# 1. Identificar versão anterior
PREV_VERSION=$(ssh ubuntu@EC2_HOST \
  "docker inspect technova-api --format '{{index .Config.Labels \"previous.version\"}}'")

# 2. Executar rollback (login no ECR antes do pull)
ssh ubuntu@EC2_HOST << EOF
  ECR_URI=\$(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/technova-api
  aws ecr get-login-password --region us-east-1 \
    | docker login --username AWS --password-stdin \${ECR_URI%%/*}
  docker stop technova-api
  docker rm technova-api
  docker pull \${ECR_URI}:${PREV_VERSION}
  docker run -d --name technova-api \
    -p 3000:3000 --restart unless-stopped \
    --env-file ~/.env \
    \${ECR_URI}:${PREV_VERSION}
EOF

# 3. Verificar recuperação
curl -f http://EC2_HOST:3000/health
```

## Ação: Feature Flag (se problema é em feature específica)

```bash
# Desligar feature problemática sem rollback completo
ssh ubuntu@EC2_HOST << 'EOF'
  # Editar .env para desligar flag
  sed -i 's/FF_NEW_SHIPPING_CALC=true/FF_NEW_SHIPPING_CALC=false/' ~/.env
  # Restart container com nova config
  docker restart technova-api
EOF
```

## Verificação
- [ ] Health endpoint retorna 200
- [ ] Logs sem erros críticos
- [ ] Pedidos sendo processados normalmente
- [ ] Métricas de latência voltaram ao normal

## Escalação
- Se não resolver em 15 min → chamar Tech Lead (@rafael)
- Se envolver banco de dados → chamar DBA (@marina)
- Se impacto financeiro significativo → notificar CTO (@carlos)

## Post-Mortem (após resolução)
- Documentar timeline do incidente
- Identificar causa raiz
- Propor ação preventiva
- Atualizar este runbook se necessário
```

---

## Validação

Ao final desta parte, você deve ter:

- [ ] Módulo de feature flags implementado e testado (`src/feature-flags.js`)
- [ ] Endpoint `/flags` funcional em ambiente de desenvolvimento
- [ ] Feature flag integrada em pelo menos uma rota (orders com shipping calc)
- [ ] Sistema de migrações com up/down funcional (`migrations/runner.js`)
- [ ] Pelo menos 2 migrações expand-contract criadas e testáveis
- [ ] Script de health check (`scripts/health-check.sh`) — executável
- [ ] Script de rollback (`scripts/rollback.sh`) — executável, com login no ECR
- [ ] Workflow CD com rollback automático (`.github/workflows/cd-with-rollback.yml`)
- [ ] Runbook documentado (`docs/runbooks/deploy-failed.md`)

> **💡 Dica:** Teste o fluxo completo localmente com Docker antes de commitar. Use `docker build . && docker run` para simular o deploy e testar os scripts de health check e rollback.
