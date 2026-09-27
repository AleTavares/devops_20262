const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    servico: 'DevOps Portfolio API',
    aluno: 'SEU NOME AQUI',
    ra: 'SEU RA AQUI',
    aula: '01 - Fundamentos de Git e Docker',
    status: 'online',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    uptime: process.uptime(),
    version: '1.0.0'
  });
});

app.listen(PORT, () => {
  console.log(`Portfolio API rodando na porta ${PORT}`);
});