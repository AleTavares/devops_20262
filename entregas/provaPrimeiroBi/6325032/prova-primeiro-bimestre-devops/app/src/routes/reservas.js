const express = require('express');
const { pool } = require('../db/pool');

const router = express.Router();

const STATUS_VALIDOS = ['pendente', 'confirmada', 'cancelada'];

function validarPayload(body, { parcial = false } = {}) {
  const erros = [];
  const { cliente, data, status } = body;

  if (!parcial || cliente !== undefined) {
    if (!cliente || typeof cliente !== 'string' || !cliente.trim()) {
      erros.push('campo "cliente" é obrigatório e deve ser texto não vazio');
    }
  }
  if (!parcial || data !== undefined) {
    if (!data || Number.isNaN(Date.parse(data))) {
      erros.push('campo "data" é obrigatório e deve ser uma data válida (YYYY-MM-DD)');
    }
  }
  if (status !== undefined && !STATUS_VALIDOS.includes(status)) {
    erros.push(`campo "status" deve ser um de: ${STATUS_VALIDOS.join(', ')}`);
  }
  return erros;
}

// POST /reservas - cria uma reserva
router.post('/', async (req, res, next) => {
  try {
    const erros = validarPayload(req.body);
    if (erros.length) return res.status(400).json({ erros });

    const { cliente, data, status = 'pendente' } = req.body;
    const { rows } = await pool.query(
      `INSERT INTO reservas (cliente, data, status) VALUES ($1, $2, $3) RETURNING *`,
      [cliente.trim(), data, status]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
});

// GET /reservas - lista todas
router.get('/', async (_req, res, next) => {
  try {
    const { rows } = await pool.query(`SELECT * FROM reservas ORDER BY id`);
    res.json(rows);
  } catch (err) {
    next(err);
  }
});

// GET /reservas/:id - busca uma
router.get('/:id', async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) return res.status(400).json({ erro: 'id inválido' });

    const { rows } = await pool.query(`SELECT * FROM reservas WHERE id = $1`, [id]);
    if (!rows.length) return res.status(404).json({ erro: 'reserva não encontrada' });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

// PUT /reservas/:id - atualiza (parcial: só altera os campos enviados)
router.put('/:id', async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) return res.status(400).json({ erro: 'id inválido' });

    const erros = validarPayload(req.body, { parcial: true });
    if (erros.length) return res.status(400).json({ erros });

    const atual = await pool.query(`SELECT * FROM reservas WHERE id = $1`, [id]);
    if (!atual.rows.length) return res.status(404).json({ erro: 'reserva não encontrada' });

    const existente = atual.rows[0];
    const cliente = req.body.cliente?.trim() ?? existente.cliente;
    const data = req.body.data ?? existente.data;
    const status = req.body.status ?? existente.status;

    const { rows } = await pool.query(
      `UPDATE reservas SET cliente = $1, data = $2, status = $3 WHERE id = $4 RETURNING *`,
      [cliente, data, status, id]
    );
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
});

// DELETE /reservas/:id - remove
router.delete('/:id', async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id)) return res.status(400).json({ erro: 'id inválido' });

    const { rowCount } = await pool.query(`DELETE FROM reservas WHERE id = $1`, [id]);
    if (!rowCount) return res.status(404).json({ erro: 'reserva não encontrada' });
    res.status(204).send();
  } catch (err) {
    next(err);
  }
});

module.exports = router;
