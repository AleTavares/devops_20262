const { after, before, test } = require('node:test');
const assert = require('node:assert/strict');
const { createServer } = require('node:http');
const { createApp } = require('../server');

let server;
let baseUrl;

before(async () => {
  server = createServer(createApp());
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(async () => {
  await new Promise((resolve, reject) => {
    server.close((error) => (error ? reject(error) : resolve()));
  });
});

async function request(path, options) {
  return fetch(`${baseUrl}${path}`, options);
}

async function createRoom(nome = 'Sala A') {
  const response = await request('/salas', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ nome }),
  });
  return response.json();
}

async function createBooking(salaId, funcionario = 'Eloisa', horario = '2026-10-12T14:00:00-03:00') {
  return request('/reservas', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ salaId, funcionario, horario }),
  });
}

test('health check e cadastro/listagem de salas funcionam', async () => {
  const health = await request('/health');
  assert.equal(health.status, 200);
  assert.deepEqual(await health.json(), { status: 'ok' });

  const invalidRoom = await request('/salas', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ nome: '   ' }),
  });
  assert.equal(invalidRoom.status, 400);
  assert.equal((await invalidRoom.json()).erro, 'O campo nome é obrigatório.');

  const room = await createRoom();
  const rooms = await request('/salas');
  assert.equal(rooms.status, 200);
  assert.deepEqual(await rooms.json(), [room]);
});

test('cria reserva, normaliza fuso, filtra por funcionario e cancela', async () => {
  const room = await createRoom();
  const created = await createBooking(room.id);
  assert.equal(created.status, 201);
  const booking = await created.json();
  assert.equal(booking.horario, '2026-10-12T17:00:00.000Z');

  const listing = await request('/reservas?funcionario=eloisa');
  assert.equal(listing.status, 200);
  assert.deepEqual(await listing.json(), [booking]);

  const deleted = await request(`/reservas/${booking.id}`, { method: 'DELETE' });
  assert.equal(deleted.status, 204);
  const afterDelete = await request('/reservas?funcionario=Eloisa');
  assert.deepEqual(await afterDelete.json(), []);

  // DELETE com ID inexistente → 404 com mensagem correta
  const notFound = await request('/reservas/00000000-0000-0000-0000-000000000000', { method: 'DELETE' });
  assert.equal(notFound.status, 404);
  assert.equal((await notFound.json()).erro, 'Reserva não encontrada.');
});

test('impede conflito equivalente em fusos diferentes e valida entradas', async () => {
  const room = await createRoom();
  const first = await createBooking(room.id);
  assert.equal(first.status, 201);

  const conflict = await createBooking(room.id, 'Outra pessoa', '2026-10-12T17:00:00Z');
  assert.equal(conflict.status, 409);
  assert.match((await conflict.json()).erro, /Sala já reservada/);

  const invalidDate = await createBooking(room.id, 'Eloisa', 'nao-e-data');
  assert.equal(invalidDate.status, 400);
  const missingRoom = await createBooking('sala-inexistente');
  assert.equal(missingRoom.status, 404);
  const missingFilter = await request('/reservas');
  assert.equal(missingFilter.status, 400);
  assert.equal((await missingFilter.json()).erro, 'O parâmetro funcionario é obrigatório.');
});

test('parsearHorario rejeita entradas inválidas', async () => {
  const room = await createRoom('Sala Validação');

  const casos = [
    '2026-10-12T14:00:00',        // sem fuso
    '2026-10-12',                  // só data
    'nao-e-data',                  // texto inválido
    '2026-13-01T10:00:00Z',        // mês inválido
    '2026-10-12T25:00:00Z',        // hora inválida
    '2026-02-30T10:00:00Z',        // data impossível
    '2026-10-12T00:00:00+14:30',   // offset inválido
  ];

  for (const horario of casos) {
    const res = await createBooking(room.id, 'Eloisa', horario);
    assert.equal(res.status, 400, `esperava 400 para horario: ${horario}`);
  }
});

test('parsearHorario normaliza horários válidos para UTC', async () => {
  const casos = [
    { horario: '2026-11-01T14:00:00Z',        esperado: '2026-11-01T14:00:00.000Z' },
    { horario: '2026-11-01T14:00:00-03:00',   esperado: '2026-11-01T17:00:00.000Z' },
    { horario: '2026-11-01T15:00:00+01:00',   esperado: '2026-11-01T14:00:00.000Z' },
    { horario: '2026-11-01T00:30:00+01:00',   esperado: '2026-10-31T23:30:00.000Z' },
    { horario: '2026-11-01T00:00:00+14:00',   esperado: '2026-10-31T10:00:00.000Z' },
  ];

  for (const { horario, esperado } of casos) {
    // sala própria por caso para evitar conflito de instante
    const room = await createRoom(`Sala Normalização ${horario}`);
    const res = await createBooking(room.id, 'Eloisa', horario);
    assert.equal(res.status, 201, `esperava 201 para horario: ${horario}`);
    const booking = await res.json();
    assert.equal(booking.horario, esperado, `normalização incorreta para: ${horario}`);
  }
});

test('conflito detecta instantes equivalentes em fusos diferentes', async () => {
  // Par 1: offset negativo vs Z — sala própria
  const sala1 = await createRoom('Sala Conflito Offset Negativo');
  const par1first = await createBooking(sala1.id, 'Ana', '2026-11-10T14:00:00-03:00');
  assert.equal(par1first.status, 201);
  const par1conflict = await createBooking(sala1.id, 'Bruno', '2026-11-10T17:00:00Z');
  assert.equal(par1conflict.status, 409);

  // Par 2: cruza meia-noite — sala própria; após confirmar conflito, cancela e reagenda
  const sala2 = await createRoom('Sala Conflito Meia-Noite');
  const par2first = await createBooking(sala2.id, 'Carla', '2026-11-10T00:30:00+01:00');
  assert.equal(par2first.status, 201);
  const par2conflict = await createBooking(sala2.id, 'Davi', '2026-11-09T23:30:00Z');
  assert.equal(par2conflict.status, 409);

  // Cancela a primeira reserva do par 2 e confirma que o instante fica disponível (CA-04.3)
  const { id: reservaId } = await par2first.json();
  const deleted = await request(`/reservas/${reservaId}`, { method: 'DELETE' });
  assert.equal(deleted.status, 204);
  const reagendado = await createBooking(sala2.id, 'Davi', '2026-11-09T23:30:00Z');
  assert.equal(reagendado.status, 201);
});

test('POST /reservas valida campos obrigatórios individualmente', async () => {
  const horarioValido = '2026-12-01T10:00:00Z';
  const uuidInexistente = '00000000-0000-0000-0000-000000000000';

  async function postReserva(body) {
    return request('/reservas', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify(body),
    });
  }

  // salaId ausente
  const semSalaId = await postReserva({ funcionario: 'Ana', horario: horarioValido });
  assert.equal(semSalaId.status, 400);
  assert.match((await semSalaId.json()).erro, /salaId/);

  // salaId vazio
  const salaIdVazio = await postReserva({ salaId: '', funcionario: 'Ana', horario: horarioValido });
  assert.equal(salaIdVazio.status, 400);
  assert.match((await salaIdVazio.json()).erro, /salaId/);

  // funcionario ausente
  const semFuncionario = await postReserva({ salaId: uuidInexistente, horario: horarioValido });
  assert.equal(semFuncionario.status, 400);
  assert.match((await semFuncionario.json()).erro, /funcionario/);

  // funcionario só com espaços
  const funcionarioEspacos = await postReserva({ salaId: uuidInexistente, funcionario: '   ', horario: horarioValido });
  assert.equal(funcionarioEspacos.status, 400);
  assert.match((await funcionarioEspacos.json()).erro, /funcionario/);

  // horario ausente
  const semHorario = await postReserva({ salaId: uuidInexistente, funcionario: 'Ana' });
  assert.equal(semHorario.status, 400);
  assert.match((await semHorario.json()).erro, /horario/);

  // UUID válido mas sala não cadastrada
  const salaInexistente = await postReserva({ salaId: uuidInexistente, funcionario: 'Ana', horario: horarioValido });
  assert.equal(salaInexistente.status, 404);
  assert.match((await salaInexistente.json()).erro, /Sala/);
});
