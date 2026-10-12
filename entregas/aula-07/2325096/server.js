const express = require('express');
const { randomUUID } = require('node:crypto');

/**
 * Valida e normaliza uma string de data/hora ISO 8601 com fuso explícito.
 *
 * Aceita: YYYY-MM-DDTHH:mm:ss seguido de Z, ±HH:MM (offset até ±13:59 ou +14:00).
 * Rejeita: strings sem fuso, datas impossíveis (ex.: fev/30), offset +14:30.
 *
 * @param {string} str
 * @returns {string|null} String UTC (toISOString) ou null se inválida.
 */
function parsearHorario(str) {
  if (typeof str !== 'string') return null;

  // Passo 1 — verificação estrutural: formato completo + offset válido.
  // Offset aceito: Z | ±00:xx–±13:xx | ±14:00 (±14:30 e superiores rejeitados).
  const RE = /^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])T([01]\d|2[0-3]):[0-5]\d:[0-5]\d(Z|[+-](0\d:[0-5]\d|1[0-3]:[0-5]\d|14:00))$/;
  if (!RE.test(str)) return null;

  // Passo 2 — verificação semântica dos componentes locais (independente do offset).
  // Usamos setUTC* em vez de Date.UTC() para evitar o remapeamento de anos 00–99
  // que Date.UTC aplica automaticamente (interpretando-os como 1900–1999).
  const ano = parseInt(str.slice(0, 4), 10);
  const mes = parseInt(str.slice(5, 7), 10);   // 1-based
  const dia = parseInt(str.slice(8, 10), 10);

  const d = new Date(0);
  d.setUTCFullYear(ano);
  d.setUTCMonth(mes - 1);   // 0-based
  d.setUTCDate(dia);

  if (
    d.getUTCFullYear() !== ano ||
    d.getUTCMonth()    !== mes - 1 ||
    d.getUTCDate()     !== dia
  ) {
    return null; // rollover indica data impossível (ex.: 2026-02-30)
  }

  // Passo 3 — normalização: converte a string completa (com offset) para UTC.
  return new Date(str).toISOString();
}

function createApp() {
  const app = express();
  const salas = [];
  const reservas = [];

  app.use(express.json());

  app.get('/health', (_req, res) => res.json({ status: 'ok' }));

  app.post('/salas', (req, res) => {
    const nome = typeof req.body?.nome === 'string' ? req.body.nome.trim() : '';
    if (!nome) return res.status(400).json({ erro: 'O campo nome é obrigatório.' });

    const sala = { id: randomUUID(), nome };
    salas.push(sala);
    return res.status(201).json(sala);
  });

  app.get('/salas', (_req, res) => res.json(salas));

  app.post('/reservas', (req, res) => {
    const { salaId, funcionario, horario } = req.body ?? {};

    // 1. salaId obrigatório
    if (typeof salaId !== 'string' || !salaId.trim()) {
      return res.status(400).json({ erro: 'O campo salaId é obrigatório.' });
    }

    // 2. funcionario obrigatório
    if (typeof funcionario !== 'string' || !funcionario.trim()) {
      return res.status(400).json({ erro: 'O campo funcionario é obrigatório.' });
    }

    // 3. horario obrigatório (presença)
    if (typeof horario !== 'string' || !horario.trim()) {
      return res.status(400).json({ erro: 'O campo horario é obrigatório.' });
    }

    // 4. horario: formato ISO 8601 com fuso explícito
    const horarioNormalizado = parsearHorario(horario);
    if (horarioNormalizado === null) {
      return res.status(400).json({ erro: 'O campo horario deve estar em ISO 8601 com fuso horário explícito (Z ou offset ±HH:MM).' });
    }

    // 5. sala deve existir
    const salaExiste = salas.some((sala) => sala.id === salaId);
    if (!salaExiste) return res.status(404).json({ erro: 'Sala não encontrada.' });

    // 6. conflito de instante UTC
    const conflito = reservas.some((reserva) => (
      reserva.salaId === salaId && reserva.horario === horarioNormalizado
    ));
    if (conflito) {
      return res.status(409).json({ erro: 'Sala já reservada para este horário.' });
    }

    // 7. criação da reserva
    const reserva = {
      id: randomUUID(),
      salaId,
      funcionario: funcionario.trim(),
      horario: horarioNormalizado,
    };
    reservas.push(reserva);
    return res.status(201).json(reserva);
  });

  app.get('/reservas', (req, res) => {
    const funcionario = typeof req.query.funcionario === 'string'
      ? req.query.funcionario.trim()
      : '';
    if (!funcionario) {
      return res.status(400).json({ erro: 'O parâmetro funcionario é obrigatório.' });
    }

    const resultado = reservas.filter((reserva) => (
      reserva.funcionario.toLocaleLowerCase('pt-BR') === funcionario.toLocaleLowerCase('pt-BR')
    ));
    return res.json(resultado);
  });

  app.delete('/reservas/:id', (req, res) => {
    const index = reservas.findIndex((reserva) => reserva.id === req.params.id);
    if (index === -1) return res.status(404).json({ erro: 'Reserva não encontrada.' });

    reservas.splice(index, 1);
    return res.status(204).end();
  });

  app.use((err, _req, res, _next) => {
    if (err instanceof SyntaxError && 'body' in err) {
      return res.status(400).json({ erro: 'O corpo da requisicao precisa ser JSON valido.' });
    }
    return res.status(500).json({ erro: 'Erro interno inesperado.' });
  });

  return app;
}

const app = createApp();
const port = Number(process.env.PORT) || 3000;
if (require.main === module) {
  app.listen(port, () => console.log(`API disponivel em http://localhost:${port}`));
}

module.exports = { app, createApp, parsearHorario };
