#!/bin/bash
# user_data.sh — Script de inicialização da instância EC2 TechNova
# Executa como root no PRIMEIRO boot. Logs em: /var/log/technova-setup.log
# Aula 04 — DevOps UNIFAAT

LOG="/var/log/technova-setup.log"
exec > "$LOG" 2>&1

echo "========================================"
echo "  TechNova API — Setup iniciado"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"

# ─── 1. Atualizar o sistema ──────────────────────────────────────────────────
echo "[1/6] Atualizando pacotes do sistema..."
yum update -y
echo "  OK — sistema atualizado"

# ─── 2. Instalar Node.js 18 via NodeSource ───────────────────────────────────
echo "[2/6] Instalando Node.js 18..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs
NODE_VERSION=$(node --version)
echo "  OK — Node.js instalado: $NODE_VERSION"

# ─── 3. Instalar Git ─────────────────────────────────────────────────────────
echo "[3/6] Instalando Git..."
yum install -y git
GIT_VERSION=$(git --version)
echo "  OK — $GIT_VERSION"

# ─── 4. Criar estrutura da API Express ──────────────────────────────────────
echo "[4/6] Criando API TechNova..."

APP_DIR="/home/ec2-user/technova-api"
mkdir -p "$APP_DIR"
cd "$APP_DIR"

# package.json
cat > package.json <<'PKGJSON'
{
  "name": "technova-api",
  "version": "1.0.0",
  "description": "TechNova API - Aula 04 DevOps UNIFAAT",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
PKGJSON

# server.js — API com 3 endpoints obrigatórios
cat > server.js <<'SERVERJS'
const express = require('express');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// GET / — informações da instância
app.get('/', (req, res) => {
  res.json({
    message: 'TechNova API - Rodando na AWS!',
    hostname: os.hostname(),
    platform: os.platform(),
    uptime_seconds: Math.floor(process.uptime()),
    node_version: process.version,
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// GET /health — health check para monitoramento
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'technova-api',
    version: '1.0.0',
    uptime_seconds: Math.floor(process.uptime()),
    timestamp: new Date().toISOString()
  });
});

// GET /orders — dados de pedidos simulados
app.get('/orders', (req, res) => {
  res.json({
    orders: [
      { id: 1, product: 'Widget A', quantity: 5,  status: 'shipped',    total: 149.90 },
      { id: 2, product: 'Widget B', quantity: 2,  status: 'processing', total: 89.90  },
      { id: 3, product: 'Gadget X', quantity: 1,  status: 'delivered',  total: 299.00 },
      { id: 4, product: 'Gadget Y', quantity: 10, status: 'pending',    total: 450.00 }
    ],
    total_orders: 4,
    timestamp: new Date().toISOString()
  });
});

// Inicia o servidor em todas as interfaces (0.0.0.0) para aceitar tráfego externo
app.listen(PORT, '0.0.0.0', () => {
  console.log(`TechNova API rodando na porta ${PORT}`);
  console.log(`Hostname: ${os.hostname()}`);
  console.log(`Timestamp: ${new Date().toISOString()}`);
});
SERVERJS

echo "  OK — arquivos da API criados"

# ─── 5. Instalar dependências npm ────────────────────────────────────────────
echo "[5/6] Instalando dependências npm (express)..."
npm install --production
echo "  OK — dependências instaladas"

# Ajustar ownership para ec2-user
chown -R ec2-user:ec2-user "$APP_DIR"

# ─── 6. Iniciar API como serviço systemd ─────────────────────────────────────
echo "[6/6] Configurando serviço systemd para a API..."

cat > /etc/systemd/system/technova-api.service <<'SYSTEMD'
[Unit]
Description=TechNova API Node.js
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/technova-api
ExecStart=/usr/bin/node /home/ec2-user/technova-api/server.js
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
Environment=NODE_ENV=production
Environment=PORT=3000

[Install]
WantedBy=multi-user.target
SYSTEMD

systemctl daemon-reload
systemctl enable technova-api
systemctl start technova-api

echo "  OK — serviço technova-api iniciado"

# ─── Verificação final ───────────────────────────────────────────────────────
echo ""
echo "========================================"
echo "  Setup concluído com sucesso!"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"
echo ""
echo "Verificando serviço..."
sleep 3
systemctl status technova-api --no-pager || true

echo ""
echo "Testando API localmente..."
sleep 2
curl -s http://localhost:3000/health || echo "API ainda iniciando, aguarde..."

echo ""
echo "Logs da API disponíveis em:"
echo "  journalctl -u technova-api -f"
echo "  /var/log/technova-setup.log"
