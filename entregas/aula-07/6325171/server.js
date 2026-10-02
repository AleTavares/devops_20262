const express = require('express');

const app = express();
app.use(express.json());

let nextSalaId = 1;
let nextReservaId = 1;

const salas = [];
const reservas = [];

app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'API de reservas de salas em execução.' });
});

app.get('/salas', (req, res) => {
  res.json(salas);
});

app.post('/salas', (req, res) => {
  const { nome, capacidade } = req.body || {};

  if (!nome || String(nome).trim() === '') {
    return res.status(400).json({ message: 'O nome da sala é obrigatório.' });
  }

  const novaSala = {
    id: nextSalaId++,
    nome: String(nome).trim(),
    capacidade: capacidade ? Number(capacidade) : 0
  };

  salas.push(novaSala);
  return res.status(201).json(novaSala);
});

app.get('/reservas', (req, res) => {
  const { funcionario } = req.query;

  if (!funcionario) {
    return res.json(reservas);
  }

  const funcionarioFiltrado = String(funcionario).trim().toLowerCase();
  const resultado = reservas.filter((reserva) =>
    String(reserva.funcionario).trim().toLowerCase() === funcionarioFiltrado
  );

  return res.json(resultado);
});

app.post('/reservas', (req, res) => {
  const { salaId, funcionario, data, horario } = req.body || {};

  if (!salaId || !funcionario || !data || !horario) {
    return res.status(400).json({
      message: 'São obrigatórios: salaId, funcionario, data e horario.'
    });
  }

  const salaSelecionada = salas.find((sala) => sala.id === Number(salaId));

  if (!salaSelecionada) {
    return res.status(404).json({ message: 'Sala não encontrada.' });
  }

  const conflito = reservas.some((reserva) => {
    return (
      Number(reserva.salaId) === Number(salaId) &&
      reserva.data === String(data) &&
      reserva.horario === String(horario)
    );
  });

  if (conflito) {
    return res.status(409).json({
      message: 'A sala selecionada já está reservada para este horário.'
    });
  }

  const novaReserva = {
    id: nextReservaId++,
    salaId: Number(salaId),
    sala: salaSelecionada.nome,
    funcionario: String(funcionario).trim(),
    data: String(data),
    horario: String(horario)
  };

  reservas.push(novaReserva);
  return res.status(201).json(novaReserva);
});

app.delete('/reservas/:id', (req, res) => {
  const reservaIndex = reservas.findIndex(
    (reserva) => reserva.id === Number(req.params.id)
  );

  if (reservaIndex === -1) {
    return res.status(404).json({ message: 'Reserva não encontrada.' });
  }

  const [removida] = reservas.splice(reservaIndex, 1);
  return res.json({ message: 'Reserva cancelada com sucesso.', reserva: removida });
});

if (require.main === module) {
  const port = process.env.PORT || 3000;
  app.listen(port, () => {
    console.log(`API de reservas rodando em http://localhost:${port}`);
  });
}

module.exports = app;
