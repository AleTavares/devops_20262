const test = require('node:test');
const assert = require('node:assert');
const request = require('supertest');
const app = require('../server');

test('POST /salas deve cadastrar uma sala', async () => {
  const response = await request(app)
    .post('/salas')
    .send({ nome: 'Sala Verde', capacidade: 8 });

  assert.equal(response.status, 201);
  assert.equal(response.body.nome, 'Sala Verde');
});

test('POST /reservas deve impedir conflito de horário na mesma sala', async () => {
  await request(app)
    .post('/salas')
    .send({ nome: 'Sala Azul', capacidade: 6 });

  await request(app)
    .post('/reservas')
    .send({
      salaId: 2,
      funcionario: 'Ana',
      data: '2026-10-01',
      horario: '09:00'
    });

  const response = await request(app)
    .post('/reservas')
    .send({
      salaId: 2,
      funcionario: 'Bruno',
      data: '2026-10-01',
      horario: '09:00'
    });

  assert.equal(response.status, 409);
  assert.match(response.body.message, /já está reservada/i);
});

test('GET /reservas deve listar reservas por funcionário', async () => {
  const response = await request(app)
    .get('/reservas?funcionario=Ana');

  assert.equal(response.status, 200);
  assert.ok(Array.isArray(response.body));
  assert.equal(response.body[0].funcionario, 'Ana');
});
