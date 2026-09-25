const assert = require('node:assert/strict');
const { after, before, describe, it } = require('node:test');
const { createApp } = require('../server');

describe('API de reserva de salas', () => {
  let server;
  let baseUrl;

  before(async () => {
    server = createApp().listen(0);
    await new Promise((resolve) => server.once('listening', resolve));
    baseUrl = `http://127.0.0.1:${server.address().port}`;
  });

  after(async () => {
    await new Promise((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
  });

  async function postJson(path, body) {
    return fetch(`${baseUrl}${path}`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify(body)
    });
  }

  async function createRoom(name) {
    const response = await postJson('/salas', { nome: name });
    assert.equal(response.status, 201);
    return response.json();
  }

  async function createBooking(salaId, funcionario, inicio, fim) {
    return postJson('/reservas', { salaId, funcionario, inicio, fim });
  }

  it('valida o nome e lista as salas cadastradas', async () => {
    const invalidResponse = await postJson('/salas', { nome: '  ' });
    assert.equal(invalidResponse.status, 400);

    const sala = await createRoom('Sala Azul');
    const listResponse = await fetch(`${baseUrl}/salas`);
    assert.deepEqual(await listResponse.json(), [sala]);
  });

  it('rejeita reserva com horário inválido ou sala inexistente', async () => {
    const invalidTime = await createBooking(1, 'Rafael', 'amanhã', 'depois');
    assert.equal(invalidTime.status, 400);

    const reversedTime = await createBooking(1, 'Rafael', '2026-09-25T11:00:00Z', '2026-09-25T10:00:00Z');
    assert.equal(reversedTime.status, 400);

    const missingRoom = await createBooking(999, 'Rafael', '2026-09-25T10:00:00Z', '2026-09-25T11:00:00Z');
    assert.equal(missingRoom.status, 404);
  });

  it('bloqueia sobreposição na mesma sala e permite intervalos adjacentes', async () => {
    const sala = await createRoom('Sala Verde');
    const first = await createBooking(sala.id, 'Rafael', '2026-09-25T10:00:00Z', '2026-09-25T11:00:00Z');
    assert.equal(first.status, 201);

    const overlap = await createBooking(sala.id, 'Ana', '2026-09-25T10:30:00Z', '2026-09-25T11:30:00Z');
    assert.equal(overlap.status, 409);

    const adjacent = await createBooking(sala.id, 'Ana', '2026-09-25T11:00:00Z', '2026-09-25T12:00:00Z');
    assert.equal(adjacent.status, 201);

    const otherRoom = await createRoom('Sala Amarela');
    const sameTimeDifferentRoom = await createBooking(otherRoom.id, 'Beatriz', '2026-09-25T10:00:00Z', '2026-09-25T11:00:00Z');
    assert.equal(sameTimeDifferentRoom.status, 201);
  });

  it('filtra reservas por funcionário sem diferenciar maiúsculas', async () => {
    const sala = await createRoom('Sala Roxa');
    await createBooking(sala.id, 'Marina Lopes', '2026-09-26T09:00:00Z', '2026-09-26T10:00:00Z');

    const response = await fetch(`${baseUrl}/reservas?funcionario=marina%20lopes`);
    const reservas = await response.json();
    assert.equal(response.status, 200);
    assert.equal(reservas.length, 1);
    assert.equal(reservas[0].funcionario, 'Marina Lopes');
  });

  it('cancela uma reserva e retorna 404 ao cancelá-la novamente', async () => {
    const sala = await createRoom('Sala Laranja');
    const createResponse = await createBooking(sala.id, 'João Silva', '2026-09-27T13:00:00Z', '2026-09-27T14:00:00Z');
    const reserva = await createResponse.json();

    const deleteResponse = await fetch(`${baseUrl}/reservas/${reserva.id}`, { method: 'DELETE' });
    assert.equal(deleteResponse.status, 204);

    const repeatedDelete = await fetch(`${baseUrl}/reservas/${reserva.id}`, { method: 'DELETE' });
    assert.equal(repeatedDelete.status, 404);
  });
});