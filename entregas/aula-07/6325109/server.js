// server.js
// API de Reserva de Salas de Reuniao - TechNova
// Construida de forma incremental (Spec-Driven), uma tarefa de cada vez.
// Dados em memoria (sem banco de dados).

const express = require("express");
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// ============================================================
// Armazenamento em memoria
// ============================================================
let salas = [];      // { id, nome }
let reservas = [];   // { id, salaId, funcionario, horario }
let proximoIdSala = 1;
let proximoIdReserva = 1;

// ============================================================
// TAREFA 2 - Cadastro e listagem de salas
// ============================================================

// POST /salas - cadastrar uma sala (nome obrigatorio)
app.post("/salas", (req, res) => {
  const { nome } = req.body;

  if (!nome || nome.trim() === "") {
    return res.status(400).json({ erro: "O campo 'nome' e obrigatorio." });
  }

  const sala = { id: proximoIdSala++, nome: nome.trim() };
  salas.push(sala);
  return res.status(201).json(sala);
});

// GET /salas - listar as salas cadastradas
app.get("/salas", (req, res) => {
  return res.json(salas);
});

// ============================================================
// TAREFA 3 e 4 - Criar reserva + bloqueio de conflito de horario
// ============================================================

// POST /reservas - criar uma reserva (sala, funcionario, horario)
app.post("/reservas", (req, res) => {
  const { salaId, funcionario, horario } = req.body;

  // Validacao dos campos obrigatorios
  if (!salaId || !funcionario || !horario) {
    return res.status(400).json({
      erro: "Os campos 'salaId', 'funcionario' e 'horario' sao obrigatorios."
    });
  }

  // A sala precisa existir
  const sala = salas.find((s) => s.id === Number(salaId));
  if (!sala) {
    return res.status(404).json({ erro: "Sala nao encontrada." });
  }

  // TAREFA 4 (a parte dificil): impedir conflito de horario
  // Nao pode haver duas reservas na mesma sala e mesmo horario
  const conflito = reservas.find(
    (r) => r.salaId === Number(salaId) && r.horario === horario
  );
  if (conflito) {
    return res.status(409).json({
      erro: "Ja existe uma reserva para esta sala neste horario.",
      reservaExistente: conflito
    });
  }

  const reserva = {
    id: proximoIdReserva++,
    salaId: Number(salaId),
    funcionario,
    horario
  };
  reservas.push(reserva);
  return res.status(201).json(reserva);
});

// ============================================================
// TAREFA 5 - Cancelar reserva
// ============================================================

// DELETE /reservas/:id - cancelar uma reserva
app.delete("/reservas/:id", (req, res) => {
  const id = Number(req.params.id);
  const indice = reservas.findIndex((r) => r.id === id);

  if (indice === -1) {
    return res.status(404).json({ erro: "Reserva nao encontrada." });
  }

  const removida = reservas.splice(indice, 1)[0];
  return res.json({ mensagem: "Reserva cancelada com sucesso.", reserva: removida });
});

// ============================================================
// TAREFA 6 - Listar reservas de um funcionario
// ============================================================

// GET /reservas?funcionario=NOME - listar reservas de um funcionario
// (sem o filtro, retorna todas)
app.get("/reservas", (req, res) => {
  const { funcionario } = req.query;

  if (funcionario) {
    const doFuncionario = reservas.filter((r) => r.funcionario === funcionario);
    return res.json(doFuncionario);
  }

  return res.json(reservas);
});

// ============================================================
// Rota raiz (info)
// ============================================================
app.get("/", (req, res) => {
  res.json({
    api: "Reserva de Salas de Reuniao - TechNova",
    rotas: [
      "POST /salas",
      "GET /salas",
      "POST /reservas",
      "DELETE /reservas/:id",
      "GET /reservas?funcionario=NOME"
    ]
  });
});

app.listen(PORT, () => {
  console.log("API de Reserva de Salas rodando na porta " + PORT);
});