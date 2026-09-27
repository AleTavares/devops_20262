const express = require("express");

const app = express();
const PORT = 3000;

app.use(express.json());

let salas = [];
let reservas = [];

let proximoIdSala = 1;
let proximoIdReserva = 1;

app.get("/", (req, res) => {
  res.json({
    projeto: "API de Reserva de Salas",
    status: "online"
  });
});

app.get("/health", (req, res) => {
  res.json({
    status: "ok"
  });
});

app.post("/salas", (req, res) => {
  const { nome } = req.body;

  if (!nome || !nome.trim()) {
    return res.status(400).json({
      erro: "O nome da sala é obrigatório"
    });
  }

  const sala = {
    id: proximoIdSala++,
    nome: nome.trim()
  };

  salas.push(sala);

  return res.status(201).json(sala);
});

app.get("/salas", (req, res) => {
  return res.json(salas);
});

app.post("/reservas", (req, res) => {
  const { salaId, funcionario, horario } = req.body;

  if (!salaId || !funcionario || !funcionario.trim() || !horario) {
    return res.status(400).json({
      erro: "salaId, funcionario e horario são obrigatórios"
    });
  }

  const sala = salas.find((item) => item.id === Number(salaId));

  if (!sala) {
    return res.status(404).json({
      erro: "Sala não encontrada"
    });
  }

  const conflito = reservas.find(
    (reserva) =>
      reserva.salaId === Number(salaId) &&
      reserva.horario === horario
  );

  if (conflito) {
    return res.status(409).json({
      erro: "A sala já possui uma reserva neste horário"
    });
  }

  const reserva = {
    id: proximoIdReserva++,
    salaId: Number(salaId),
    sala: sala.nome,
    funcionario: funcionario.trim(),
    horario
  };

  reservas.push(reserva);

  return res.status(201).json(reserva);
});

app.get("/reservas", (req, res) => {
  const { funcionario } = req.query;

  if (!funcionario) {
    return res.json(reservas);
  }

  const resultado = reservas.filter(
    (reserva) =>
      reserva.funcionario.toLowerCase() === funcionario.toLowerCase()
  );

  return res.json(resultado);
});

app.delete("/reservas/:id", (req, res) => {
  const id = Number(req.params.id);

  const indice = reservas.findIndex((reserva) => reserva.id === id);

  if (indice === -1) {
    return res.status(404).json({
      erro: "Reserva não encontrada"
    });
  }

  const [reservaRemovida] = reservas.splice(indice, 1);

  return res.json({
    mensagem: "Reserva cancelada com sucesso",
    reserva: reservaRemovida
  });
});

app.listen(PORT, () => {
  console.log(`API de Reserva de Salas rodando na porta ${PORT}`);
});
