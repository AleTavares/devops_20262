const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Dados em memória (somem ao reiniciar o servidor)
const salas = [];
let proximoIdSala = 1;

app.get('/saude', (req, res) => {
  res.json({ status: 'ok' });
});

app.post('/salas', (req, res) => {
  const { nome } = req.body || {};

  if (typeof nome !== 'string' || nome.trim() === '') {
    return res.status(400).json({ erro: 'O campo "nome" é obrigatório.' });
  }

  const sala = { id: proximoIdSala++, nome: nome.trim() };
  salas.push(sala);
  res.status(201).json(sala);
});

app.listen(PORT, () => {
  console.log(`API de Reserva de Salas rodando na porta ${PORT}`);
});
