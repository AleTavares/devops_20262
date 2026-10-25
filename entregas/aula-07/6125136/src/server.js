const express = require('express');

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 4000;

let nextSalaId = 1;
const salas = [];

// Tarefa 1: cadastrar sala
app.post('/salas', (req, res) => {
  const { nome } = req.body;
  if (!nome || nome.trim() === '' || nome.trim().length > 100) {
    return res.status(400).json({ error: 'Campo obrigatório: nome deve ter entre 1 e 100 caracteres não brancos' });
  }
  const sala = { id: nextSalaId++, nome };
  salas.push(sala);
  res.status(201).json(sala);
});

// Tarefa 2: listar salas
// Tarefa 7: com ?inicio=&fim= lista só as salas livres nesse período
app.get('/salas', (req, res) => {
  const { inicio, fim } = req.query;
  if (!inicio && !fim) {
    return res.json(salas);
  }
  const ini = new Date(inicio);
  const end = new Date(fim);
  if (!inicio || !fim || isNaN(ini) || isNaN(end) || ini >= end) {
    return res.status(400).json({ error: 'Informe inicio e fim válidos (ISO 8601), com inicio < fim' });
  }
  const ocupadas = new Set(
    reservas
      .filter((r) => ini < new Date(r.fim) && new Date(r.inicio) < end)
      .map((r) => r.salaId)
  );
  res.json(salas.filter((s) => !ocupadas.has(s.id)));
});

// Tarefa 3: criar reserva (horário = inicio/fim em ISO 8601)
let nextReservaId = 1;
const reservas = [];

app.post('/reservas', (req, res) => {
  const { salaId, funcionario, inicio, fim } = req.body;
  if (!salaId || !funcionario || !inicio || !fim) {
    return res
      .status(400)
      .json({ error: 'Campos obrigatórios: salaId, funcionario, inicio, fim' });
  }
  if (funcionario.trim() === '') {
    return res.status(400).json({ error: 'Campo funcionario não pode ser vazio ou conter apenas espaços' });
  }
  if (funcionario.trim().length > 100) {
    return res.status(400).json({ error: 'Campo funcionario deve ter no máximo 100 caracteres não brancos' });
  }
  const ini = new Date(inicio);
  const end = new Date(fim);
  if (isNaN(ini) || isNaN(end)) {
    return res.status(400).json({ error: 'inicio e fim devem ser datas válidas (ISO 8601)' });
  }
  if (ini >= end) {
    return res.status(400).json({ error: 'inicio deve ser anterior a fim' });
  }
  const sala = salas.find((s) => s.id === Number(salaId));
  if (!sala) {
    return res.status(404).json({ error: 'Sala não encontrada' });
  }
  // Tarefa 4: dois intervalos [a,b) e [c,d) conflitam se a < d && c < b.
  // Reservas encostadas (fim == inicio da outra) NÃO conflitam.
  const conflito = reservas.find(
    (r) => r.salaId === sala.id && ini < new Date(r.fim) && new Date(r.inicio) < end
  );
  if (conflito) {
    return res.status(409).json({
      error: 'Conflito de horário: a sala já está reservada nesse período',
      reservaConflitante: conflito,
    });
  }
  const reserva = {
    id: nextReservaId++,
    salaId: sala.id,
    funcionario,
    inicio: ini.toISOString(),
    fim: end.toISOString(),
  };
  reservas.push(reserva);
  res.status(201).json(reserva);
});

// Tarefa 5: cancelar reserva
app.delete('/reservas/:id', (req, res) => {
  const idNum = Number(req.params.id);
  if (!Number.isInteger(idNum) || idNum <= 0) {
    return res.status(400).json({ error: 'O id deve ser um inteiro positivo' });
  }
  const idx = reservas.findIndex((r) => r.id === idNum);
  if (idx === -1) {
    return res.status(404).json({ error: 'Reserva não encontrada' });
  }
  const [removida] = reservas.splice(idx, 1);
  res.json({ mensagem: 'Reserva cancelada', reserva: removida });
});

// Tarefa 6: listar reservas de um funcionário
app.get('/reservas', (req, res) => {
  const { funcionario } = req.query;
  if (!funcionario || funcionario.trim() === '') {
    return res.status(400).json({ error: 'Parâmetro obrigatório: funcionario não pode ser vazio' });
  }
  const nome = funcionario.toLowerCase();
  res.json(reservas.filter((r) => r.funcionario.toLowerCase() === nome));
});

app.listen(PORT, () => {
  console.log(`API rodando na porta ${PORT}`);
});
