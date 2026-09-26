const { Router } = require("express");
const bd = require("../data/memoria");

const router = Router();

// POST /salas — cadastrar uma sala. Nome e obrigatorio.
router.post("/", (req, res) => {
  const { nome, capacidade } = req.body || {};

  if (typeof nome !== "string" || nome.trim() === "") {
    return res.status(400).json({ erro: "nome e obrigatorio" });
  }

  // capacidade e opcional, mas se vier tem de ser um inteiro positivo.
  // Sem esta checagem, {"capacidade":"muitas"} era aceito — encontrado
  // testando a tarefa, nao previsto no design.
  if (
    capacidade !== undefined &&
    capacidade !== null &&
    (!Number.isInteger(capacidade) || capacidade <= 0)
  ) {
    return res
      .status(400)
      .json({ erro: "capacidade, se informada, deve ser um inteiro positivo" });
  }

  const sala = {
    id: bd.proximoIdSala++,
    nome: nome.trim(),
    capacidade: capacidade ?? null,
  };
  bd.salas.push(sala);

  res.status(201).json(sala);
});

// GET /salas — listar as salas cadastradas.
router.get("/", (_req, res) => {
  res.json(bd.salas);
});

module.exports = router;
