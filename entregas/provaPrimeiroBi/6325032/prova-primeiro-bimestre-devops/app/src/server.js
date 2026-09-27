require('dotenv').config();
const express = require('express');
const { pool, initSchema } = require('./db/pool');
const reservasRouter = require('./routes/reservas');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// GET /health - usado pelo healthcheck do Compose e por load balancers
app.get('/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', db: 'connected' });
  } catch (err) {
    res.status(503).json({ status: 'error', db: 'disconnected', detalhe: err.message });
  }
});

app.use('/reservas', reservasRouter);

// Middleware de erro central - evita repetir tratamento em cada rota
app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ erro: 'erro interno', detalhe: err.message });
});

async function start() {
  // Tenta algumas vezes: no Compose, o Postgres pode ainda estar subindo
  // mesmo com o healthcheck (depends_on: condition service_healthy reduz isso,
  // mas mantemos o retry por robustez, inclusive contra o RDS na nuvem).
  const MAX_TENTATIVAS = 10;
  for (let tentativa = 1; tentativa <= MAX_TENTATIVAS; tentativa++) {
    try {
      await initSchema();
      break;
    } catch (err) {
      if (tentativa === MAX_TENTATIVAS) throw err;
      console.log(`Banco indisponível (tentativa ${tentativa}/${MAX_TENTATIVAS}), tentando novamente em 3s...`);
      await new Promise((r) => setTimeout(r, 3000));
    }
  }

  app.listen(PORT, () => {
    console.log(`API de Reservas ouvindo na porta ${PORT}`);
  });
}

start();

module.exports = app;
