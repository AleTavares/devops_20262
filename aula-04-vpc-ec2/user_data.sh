#!/bin/bash
# user_data.sh - Script de bootstrap da instância EC2 TechNova
# Executa no primeiro boot como root. Logs em /var/log/technova-setup.log

LOG="/var/log/technova-setup.log"
exec > >(tee -a "$LOG") 2>&1

echo "=========================================="
echo "TechNova API - Setup iniciado: $(date)"
echo "=========================================="

# Atualizar o sistema
echo "[1/6] Atualizando pacotes do sistema..."
yum update -y

# Instalar Node.js 18 via nodesource
echo "[2/6] Instalando Node.js 18..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

echo "Node.js instalado: $(node --version)"
echo "npm instalado: $(npm --version)"

# Instalar Git
echo "[3/6] Instalando Git..."
yum install -y git

# Criar diretório da aplicação
echo "[4/6] Criando estrutura da aplicação..."
mkdir -p /opt/technova-api
cd /opt/technova-api

# Inicializar projeto Node.js e instalar Express
npm init -y
npm install express

# Criar a API Express com 3 endpoints
echo "[5/6] Criando API TechNova..."
cat > /opt/technova-api/server.js << 'EOF'
const express = require('express');
const os = require('os');

const app = express();
const PORT = 3000;

// GET / - Informações gerais da API
app.get('/', (req, res) => {
  res.json({
    message: 'TechNova API - Rodando na AWS!',
    hostname: os.hostname(),
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    environment: 'development'
  });
});

// GET /health - Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'technova-api',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// GET /orders - Lista de pedidos (dados mock)
app.get('/orders', (req, res) => {
  res.json({
    orders: [
      { id: 1, product: 'Widget A', quantity: 10, status: 'shipped',    total: 150.00 },
      { id: 2, product: 'Widget B', quantity: 5,  status: 'processing', total: 75.00  },
      { id: 3, product: 'Gadget X', quantity: 2,  status: 'pending',    total: 200.00 }
    ]
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`TechNova API rodando na porta ${PORT}`);
});
EOF

# Iniciar a API com nohup (persiste após o script terminar)
echo "[6/6] Iniciando a API TechNova na porta 3000..."
nohup node /opt/technova-api/server.js >> "$LOG" 2>&1 &

echo "PID da API: $!"
echo "=========================================="
echo "TechNova API - Setup concluído: $(date)"
echo "Acesse: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000"
echo "=========================================="
