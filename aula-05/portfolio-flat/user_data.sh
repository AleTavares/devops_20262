#!/bin/bash
# user_data.sh — Inicialização do EC2 TechNova Aula 05
# Instala Node.js 18, PostgreSQL client e API Express com conexão ao RDS

LOG="/var/log/technova-setup.log"
exec > "$LOG" 2>&1

echo "=== TechNova Setup Aula 05 — $(date) ==="

# 1. Atualizar sistema
echo "[1/5] Atualizando sistema..."
yum update -y

# 2. Instalar Node.js 18
echo "[2/5] Instalando Node.js 18..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs
echo "  Node.js: $(node --version)"

# 3. Instalar cliente PostgreSQL (para testar conexão ao RDS)
echo "[3/5] Instalando PostgreSQL client..."
yum install -y postgresql15
echo "  psql: $(psql --version)"

# 4. Criar API Express com suporte a PostgreSQL
echo "[4/5] Criando API TechNova com conexão RDS..."
APP_DIR="/home/ec2-user/technova-api"
mkdir -p "$APP_DIR"
cd "$APP_DIR"

cat > package.json <<'PKGJSON'
{
  "name": "technova-api",
  "version": "1.0.0",
  "description": "TechNova API com RDS PostgreSQL — Aula 05",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.11.0"
  }
}
PKGJSON

cat > server.js <<'SERVERJS'
const express = require('express');
const { Pool } = require('pg');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Conexão com o RDS via variáveis de ambiente
const pool = process.env.DB_HOST ? new Pool({
  host:     process.env.DB_HOST,
  port:     parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'technova',
  user:     process.env.DB_USER || 'technova_admin',
  password: process.env.DB_PASSWORD,
  ssl:      { rejectUnauthorized: false }
}) : null;

// GET / — status da API
app.get('/', (req, res) => {
  res.json({
    message: 'TechNova API — Aula 05 com RDS!',
    hostname: os.hostname(),
    node_version: process.version,
    db_connected: pool !== null,
    timestamp: new Date().toISOString()
  });
});

// GET /health — health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'technova-api', version: '2.0.0' });
});

// GET /orders — busca pedidos do RDS (ou retorna mock se sem DB)
app.get('/orders', async (req, res) => {
  if (!pool) {
    return res.json({
      source: 'mock',
      note: 'DB_HOST não configurado — retornando dados de exemplo',
      orders: [
        { id: 1, customer_name: 'Maria Silva', product: 'Laptop TechNova Pro', total: 4599.90 },
        { id: 2, customer_name: 'João Santos', product: 'Monitor 27"', total: 2398.00 }
      ]
    });
  }
  try {
    const result = await pool.query('SELECT * FROM orders ORDER BY id');
    res.json({ source: 'rds', orders: result.rows, count: result.rowCount });
  } catch (err) {
    res.status(500).json({ error: err.message, hint: 'Execute o script SQL de setup primeiro' });
  }
});

// POST /orders — cria pedido no RDS
app.post('/orders', async (req, res) => {
  if (!pool) return res.status(503).json({ error: 'Banco não configurado' });
  const { customer_name, product, quantity, total } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO orders (customer_name, product, quantity, total) VALUES ($1,$2,$3,$4) RETURNING *',
      [customer_name, product, quantity, total]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`TechNova API rodando na porta ${PORT}`);
  console.log(`DB Host: ${process.env.DB_HOST || 'não configurado (modo mock)'}`);
});
SERVERJS

npm install --production
chown -R ec2-user:ec2-user "$APP_DIR"

# 5. Criar serviço systemd
echo "[5/5] Configurando serviço systemd..."
cat > /etc/systemd/system/technova-api.service <<'SYSTEMD'
[Unit]
Description=TechNova API Node.js com RDS
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
# Variáveis do RDS — preencher com os outputs do terraform apply
# Environment=DB_HOST=<RDS_ENDPOINT>
# Environment=DB_NAME=technova
# Environment=DB_USER=technova_admin
# Environment=DB_PASSWORD=<SENHA>

[Install]
WantedBy=multi-user.target
SYSTEMD

systemctl daemon-reload
systemctl enable technova-api
systemctl start technova-api

echo "=== Setup concluído — $(date) ==="
echo "Para conectar ao RDS: psql -h <RDS_ENDPOINT> -U technova_admin -d technova -p 5432"
echo "Logs da API: journalctl -u technova-api -f"
