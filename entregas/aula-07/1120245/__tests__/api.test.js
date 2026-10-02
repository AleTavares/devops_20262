const request = require('supertest');
const { app, resetarEstado } = require('../server');

beforeEach(() => resetarEstado());

describe('POST /salas', () => {
  test('cria sala com nome válido → 201', async () => {
    const res = await request(app).post('/salas').send({ nome: 'Sala Alfa' });
    expect(res.status).toBe(201);
    expect(res.body).toMatchObject({ id: 1, nome: 'Sala Alfa' });
  });

  test('rejeita nome vazio → 400', async () => {
    const res = await request(app).post('/salas').send({ nome: '' });
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('erro');
  });

  test('rejeita nome duplicado (case-insensitive) → 409', async () => {
    await request(app).post('/salas').send({ nome: 'Sala Alfa' });
    const res = await request(app).post('/salas').send({ nome: 'sala alfa' });
    expect(res.status).toBe(409);
  });
});

describe('GET /salas', () => {
  test('retorna lista vazia inicialmente → 200', async () => {
    const res = await request(app).get('/salas');
    expect(res.status).toBe(200);
    expect(res.body).toEqual([]);
  });

  test('retorna salas criadas → 200', async () => {
    await request(app).post('/salas').send({ nome: 'Sala Beta' });
    const res = await request(app).get('/salas');
    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(1);
  });
});

describe('POST /reservas', () => {
  beforeEach(async () => {
    await request(app).post('/salas').send({ nome: 'Sala Alfa' });
  });

  test('cria reserva válida → 201', async () => {
    const res = await request(app).post('/reservas').send({
      salaId: 1, funcionario: 'Ana Lima', horario: '2026-10-15 14:00'
    });
    expect(res.status).toBe(201);
    expect(res.body).toMatchObject({ salaId: 1, funcionario: 'Ana Lima', horario: '2026-10-15 14:00' });
  });

  test('detecta conflito de horário → 409', async () => {
    await request(app).post('/reservas').send({
      salaId: 1, funcionario: 'Ana Lima', horario: '2026-10-15 14:00'
    });
    const res = await request(app).post('/reservas').send({
      salaId: 1, funcionario: 'Carlos Souza', horario: '2026-10-15 14:00'
    });
    expect(res.status).toBe(409);
  });

  test('sala não encontrada → 404', async () => {
    const res = await request(app).post('/reservas').send({
      salaId: 99, funcionario: 'Ana Lima', horario: '2026-10-15 14:00'
    });
    expect(res.status).toBe(404);
  });

  test('horário inválido → 400', async () => {
    const res = await request(app).post('/reservas').send({
      salaId: 1, funcionario: 'Ana Lima', horario: '15/10/2026 14h00'
    });
    expect(res.status).toBe(400);
  });
});

describe('DELETE /reservas/:id', () => {
  beforeEach(async () => {
    await request(app).post('/salas').send({ nome: 'Sala Alfa' });
    await request(app).post('/reservas').send({
      salaId: 1, funcionario: 'Ana Lima', horario: '2026-10-15 14:00'
    });
  });

  test('cancela reserva existente → 200', async () => {
    const res = await request(app).delete('/reservas/1');
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('mensagem');
  });

  test('reserva não encontrada → 404', async () => {
    const res = await request(app).delete('/reservas/999');
    expect(res.status).toBe(404);
  });

  test('horário liberado após cancelamento → pode criar nova reserva', async () => {
    await request(app).delete('/reservas/1');
    const res = await request(app).post('/reservas').send({
      salaId: 1, funcionario: 'Carlos Souza', horario: '2026-10-15 14:00'
    });
    expect(res.status).toBe(201);
  });
});

describe('GET /reservas', () => {
  beforeEach(async () => {
    await request(app).post('/salas').send({ nome: 'Sala Alfa' });
    await request(app).post('/reservas').send({
      salaId: 1, funcionario: 'Ana Lima', horario: '2026-10-15 14:00'
    });
    await request(app).post('/reservas').send({
      salaId: 1, funcionario: 'Carlos Souza', horario: '2026-10-15 15:00'
    });
  });

  test('lista todas as reservas → 200', async () => {
    const res = await request(app).get('/reservas');
    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(2);
  });

  test('filtra por funcionário → retorna apenas as do funcionário', async () => {
    const res = await request(app).get('/reservas?funcionario=Ana Lima');
    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(1);
    expect(res.body[0].funcionario).toBe('Ana Lima');
  });

  test('funcionário sem reservas → retorna lista vazia', async () => {
    const res = await request(app).get('/reservas?funcionario=Inexistente');
    expect(res.status).toBe(200);
    expect(res.body).toEqual([]);
  });
});
