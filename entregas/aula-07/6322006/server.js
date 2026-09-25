const express = require('express');

function createStore() {
  return {
    salas: [],
    reservas: [],
    nextSalaId: 1,
    nextReservaId: 1
  };
}

function isIsoDateWithTimezone(value) {
  return typeof value === 'string'
    && /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,3})?(?:Z|[+-]\d{2}:\d{2})$/.test(value)
    && Number.isFinite(Date.parse(value));
}

function createApp({ store = createStore() } = {}) {
  const app = express();
  app.use(express.json({ limit: '32kb' }));

  app.get('/salas', (_request, response) => {
    response.json(store.salas);
  });

  app.post('/salas', (request, response) => {
    const name = typeof request.body?.nome === 'string' ? request.body.nome.trim() : '';
    if (!name) {
      return response.status(400).json({ erro: 'O campo nome da sala é obrigatório.' });
    }

    const sala = { id: store.nextSalaId++, nome: name };
    store.salas.push(sala);
    return response.status(201).json(sala);
  });

  app.post('/reservas', (request, response) => {
    const { salaId, funcionario, inicio, fim } = request.body ?? {};
    const parsedSalaId = Number(salaId);
    const employeeName = typeof funcionario === 'string' ? funcionario.trim() : '';

    if (!Number.isInteger(parsedSalaId) || parsedSalaId < 1 || !employeeName
      || !isIsoDateWithTimezone(inicio) || !isIsoDateWithTimezone(fim)) {
      return response.status(400).json({
        erro: 'Informe salaId, funcionario e inicio/fim ISO 8601 com fuso horário.'
      });
    }

    if (Date.parse(fim) <= Date.parse(inicio)) {
      return response.status(400).json({ erro: 'O horário fim deve ser posterior ao início.' });
    }

    if (!store.salas.some((sala) => sala.id === parsedSalaId)) {
      return response.status(404).json({ erro: 'Sala não encontrada.' });
    }

    const overlaps = store.reservas.some((reserva) => reserva.salaId === parsedSalaId
      && Date.parse(inicio) < Date.parse(reserva.fim)
      && Date.parse(fim) > Date.parse(reserva.inicio));

    if (overlaps) {
      return response.status(409).json({ erro: 'A sala já está reservada nesse intervalo.' });
    }

    const reserva = {
      id: store.nextReservaId++,
      salaId: parsedSalaId,
      funcionario: employeeName,
      inicio: new Date(inicio).toISOString(),
      fim: new Date(fim).toISOString()
    };
    store.reservas.push(reserva);
    return response.status(201).json(reserva);
  });

  app.delete('/reservas/:id', (request, response) => {
    const reservaId = Number(request.params.id);
    const reservaIndex = store.reservas.findIndex((reserva) => reserva.id === reservaId);

    if (!Number.isInteger(reservaId) || reservaIndex === -1) {
      return response.status(404).json({ erro: 'Reserva não encontrada.' });
    }

    store.reservas.splice(reservaIndex, 1);
    return response.status(204).end();
  });

  app.get('/reservas', (request, response) => {
    const employeeName = request.query.funcionario;
    if (employeeName === undefined) {
      return response.json(store.reservas);
    }

    if (typeof employeeName !== 'string' || !employeeName.trim()) {
      return response.status(400).json({ erro: 'O parâmetro funcionario não pode ser vazio.' });
    }

    const normalizedName = employeeName.trim().toLocaleLowerCase('pt-BR');
    return response.json(store.reservas.filter((reserva) =>
      reserva.funcionario.toLocaleLowerCase('pt-BR') === normalizedName));
  });

  app.use((error, _request, response, _next) => {
    if (error instanceof SyntaxError && error.status === 400 && 'body' in error) {
      return response.status(400).json({ erro: 'O corpo da requisição deve ser um JSON válido.' });
    }
    return response.status(500).json({ erro: 'Erro interno do servidor.' });
  });

  return app;
}

function startServer(port = Number(process.env.PORT) || 3000) {
  const app = createApp();
  return app.listen(port, () => {
    console.log(`API de reservas disponível em http://localhost:${port}`);
  });
}

if (require.main === module) {
  startServer();
}

module.exports = { createApp, createStore, startServer };