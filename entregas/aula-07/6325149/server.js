const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Dados em memória (somem ao reiniciar o servidor)
const salas = [];
let proximoIdSala = 1;

const reservas = [];
let proximoIdReserva = 1;

// Dois intervalos colidem quando um começa antes de o outro terminar e
// termina depois de o outro começar. Horários que apenas se encostam
// (fim de um == início do outro) NÃO colidem.
function temConflito(salaId, inicio, fim) {
  return reservas.find(
    (r) => r.salaId === salaId && inicio < new Date(r.fim) && fim > new Date(r.inicio)
  );
}

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

  const conflito = temConflito(sala.id, dataInicio, dataFim);
  if (conflito) {
    return res.status(409).json({
      erro: `Conflito de horário: a sala "${sala.nome}" já está reservada por ${conflito.funcionario} de ${conflito.inicio} até ${conflito.fim} (reserva ${conflito.id}).`,
    });
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

app.delete('/reservas/:id', (req, res) => {
  const indice = reservas.findIndex((r) => r.id === Number(req.params.id));
  if (indice === -1) {
    return res.status(404).json({ erro: `Reserva ${req.params.id} não encontrada.` });
  }

  const [cancelada] = reservas.splice(indice, 1);
  res.json({ mensagem: 'Reserva cancelada.', reserva: cancelada });
});

app.listen(PORT, () => {
  console.log(`API de Reserva de Salas rodando na porta ${PORT}`);
});
