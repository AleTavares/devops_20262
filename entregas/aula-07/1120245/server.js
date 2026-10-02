const express = require('express');

const app = express();
app.use(express.json());

// ── Repositório em Memória ────────────────────────────────────────────────────
let salas = [];
let reservas = [];
let proximoIdSala = 1;
let proximoIdReserva = 1;

// ── Utilitários de reset (usado pelos testes) ─────────────────────────────────
function resetarEstado() {
  salas = [];
  reservas = [];
  proximoIdSala = 1;
  proximoIdReserva = 1;
}

// ── Validador ─────────────────────────────────────────────────────────────────

/**
 * Retorna true se o valor é uma string não vazia (sem considerar só espaços).
 */
function ehStringNaoVazia(valor) {
  return typeof valor === 'string' && valor.trim().length > 0;
}

/**
 * Retorna true se o horario corresponde ao formato "YYYY-MM-DD HH:MM".
 */
function ehHorarioValido(horario) {
  return /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/.test(horario);
}

// ── Verificador de Conflito ───────────────────────────────────────────────────

/**
 * Retorna true se já existe reserva ativa com o mesmo salaId e horario.
 */
function existeConflito(salaId, horario) {
  return reservas.some(r => r.salaId === salaId && r.horario === horario);
}

// ── Handlers de Rota ──────────────────────────────────────────────────────────

// POST /salas — criar sala
function criarSala(req, res) {
  const { nome } = req.body;

  if (!ehStringNaoVazia(nome)) {
    return res.status(400).json({ erro: "O campo 'nome' é obrigatório e não pode ser vazio." });
  }

  const nomeTrimmed = nome.trim();
  const duplicada = salas.find(s => s.nome.toLowerCase() === nomeTrimmed.toLowerCase());
  if (duplicada) {
    return res.status(409).json({ erro: 'Já existe uma sala com esse nome.' });
  }

  const sala = { id: proximoIdSala++, nome: nomeTrimmed };
  salas.push(sala);
  return res.status(201).json(sala);
}

// GET /salas — listar salas
function listarSalas(req, res) {
  return res.status(200).json(salas);
}

// POST /reservas — criar reserva
function criarReserva(req, res) {
  const { salaId, funcionario, horario } = req.body;

  if (salaId === undefined || salaId === null) {
    return res.status(400).json({ erro: "O campo 'salaId' é obrigatório." });
  }
  if (!ehStringNaoVazia(funcionario)) {
    return res.status(400).json({ erro: "O campo 'funcionario' é obrigatório e não pode ser vazio." });
  }
  if (!ehStringNaoVazia(horario)) {
    return res.status(400).json({ erro: "O campo 'horario' é obrigatório e não pode ser vazio." });
  }
  if (!ehHorarioValido(horario)) {
    return res.status(400).json({ erro: "O campo 'horario' deve estar no formato 'YYYY-MM-DD HH:MM'." });
  }

  const salaIdNum = Number(salaId);
  const sala = salas.find(s => s.id === salaIdNum);
  if (!sala) {
    return res.status(404).json({ erro: 'Sala não encontrada.' });
  }

  if (existeConflito(salaIdNum, horario)) {
    return res.status(409).json({ erro: 'Já existe uma reserva para essa sala nesse horário.' });
  }

  const reserva = {
    id: proximoIdReserva++,
    salaId: salaIdNum,
    funcionario: funcionario.trim(),
    horario,
  };
  reservas.push(reserva);
  return res.status(201).json(reserva);
}

// DELETE /reservas/:id — cancelar reserva
function cancelarReserva(req, res) {
  const id = Number(req.params.id);
  const index = reservas.findIndex(r => r.id === id);

  if (index === -1) {
    return res.status(404).json({ erro: 'Reserva não encontrada.' });
  }

  reservas.splice(index, 1);
  return res.status(200).json({ mensagem: 'Reserva cancelada com sucesso.' });
}

// GET /reservas — listar reservas (com filtro opcional por funcionário)
function listarReservas(req, res) {
  const { funcionario } = req.query;

  if (funcionario && funcionario.trim().length > 0) {
    return res.status(200).json(reservas.filter(r => r.funcionario === funcionario));
  }

  return res.status(200).json(reservas);
}

// ── Rotas ─────────────────────────────────────────────────────────────────────
app.post('/salas', criarSala);
app.get('/salas', listarSalas);
app.post('/reservas', criarReserva);
app.delete('/reservas/:id', cancelarReserva);
app.get('/reservas', listarReservas);

// ── Exportações ───────────────────────────────────────────────────────────────
module.exports = { app, resetarEstado };

// ── Inicialização (somente quando executado diretamente) ──────────────────────
if (require.main === module) {
  app.listen(3000, () => {
    console.log('Servidor rodando em http://localhost:3000');
  });
}
