const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Dados em memória (somem ao reiniciar o servidor)
const salas = [];
let proximoIdSala = 1;

const reservas = [];
let proximoIdReserva = 1;

app.get('/saude', (req, res) => {
  res.json({ status: 'ok' });
});

app.get('/salas', (req, res) => {
  res.json(salas);
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

app.post('/reservas', (req, res) => {
  const { salaId, funcionario, inicio, fim } = req.body || {};

  if (typeof funcionario !== 'string' || funcionario.trim() === '') {
    return res.status(400).json({ erro: 'O campo "funcionario" é obrigatório.' });
  }

  const dataInicio = new Date(inicio);
  const dataFim = new Date(fim);
  if (!inicio || !fim || isNaN(dataInicio) || isNaN(dataFim)) {
    return res.status(400).json({ erro: 'Os campos "inicio" e "fim" devem ser datas válidas (ex.: 2026-10-01T14:00:00Z).' });
  }
  if (dataFim <= dataInicio) {
    return res.status(400).json({ erro: 'O "fim" deve ser posterior ao "inicio".' });
  }

  const sala = salas.find((s) => s.id === Number(salaId));
  if (!sala) {
    return res.status(404).json({ erro: `Sala ${salaId} não encontrada.` });
  }

  const reserva = {
    id: proximoIdReserva++,
    salaId: sala.id,
    funcionario: funcionario.trim(),
    inicio: dataInicio.toISOString(),
    fim: dataFim.toISOString(),
  };
  reservas.push(reserva);
  res.status(201).json(reserva);
});

app.listen(PORT, () => {
  console.log(`API de Reserva de Salas rodando na porta ${PORT}`);
});
