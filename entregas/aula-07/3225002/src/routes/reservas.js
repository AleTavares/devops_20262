const { Router } = require("express");
const bd = require("../data/memoria");
const { encontrarConflito } = require("../services/conflito");

const router = Router();

// Aceita "2026-10-01T14:00:00" ou "2026-10-01 14:00".
const ehHorarioValido = (valor) =>
  typeof valor === "string" && !Number.isNaN(Date.parse(valor));

// POST /reservas — criar uma reserva.
router.post("/", (req, res) => {
  const { sala_id, funcionario, inicio, fim } = req.body || {};
  const erros = [];

  if (!Number.isInteger(sala_id)) {
    erros.push("sala_id e obrigatorio e deve ser um numero inteiro");
  }
  if (typeof funcionario !== "string" || funcionario.trim() === "") {
    erros.push("funcionario e obrigatorio");
  }
  if (!ehHorarioValido(inicio)) {
    erros.push("inicio e obrigatorio e deve ser uma data/hora valida");
  }
  if (!ehHorarioValido(fim)) {
    erros.push("fim e obrigatorio e deve ser uma data/hora valida");
  }
  if (erros.length === 0 && new Date(fim) <= new Date(inicio)) {
    erros.push("fim deve ser depois de inicio");
  }
  if (erros.length > 0) {
    return res.status(400).json({ erro: "dados invalidos", detalhes: erros });
  }

  const sala = bd.salas.find((s) => s.id === sala_id);
  if (!sala) {
    return res.status(404).json({ erro: `sala ${sala_id} nao encontrada` });
  }

  // Bloqueio de conflito — ver src/services/conflito.js para a regra.
  const conflito = encontrarConflito(bd.reservas, { sala_id, inicio, fim });
  if (conflito) {
    return res.status(409).json({
      erro: "conflito de horario",
      mensagem: `a sala "${sala.nome}" ja esta reservada por ${conflito.funcionario} das ${conflito.inicio} as ${conflito.fim}`,
      reserva_conflitante: conflito,
    });
  }

  const reserva = {
    id: bd.proximoIdReserva++,
    sala_id,
    sala_nome: sala.nome,
    funcionario: funcionario.trim(),
    inicio,
    fim,
  };
  bd.reservas.push(reserva);

  res.status(201).json(reserva);
});

// GET /reservas?funcionario=NOME — listar reservas. Sem o filtro, lista todas.
router.get("/", (req, res) => {
  const { funcionario } = req.query;

  if (funcionario === undefined) {
    return res.json(bd.reservas);
  }

  // Comparacao sem diferenciar maiusculas: "jose" acha "Jose".
  const alvo = String(funcionario).trim().toLowerCase();
  const encontradas = bd.reservas.filter(
    (r) => r.funcionario.toLowerCase() === alvo
  );

  res.json(encontradas);
});

// DELETE /reservas/:id — cancelar uma reserva.
router.delete("/:id", (req, res) => {
  if (!/^\d+$/.test(req.params.id)) {
    return res.status(400).json({ erro: "id deve ser um numero inteiro" });
  }

  const id = Number(req.params.id);
  const indice = bd.reservas.findIndex((r) => r.id === id);

  if (indice === -1) {
    return res.status(404).json({ erro: `reserva ${id} nao encontrada` });
  }

  bd.reservas.splice(indice, 1);
  res.status(204).send();
});

module.exports = router;
