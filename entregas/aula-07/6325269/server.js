// ===== Configuração =====
const express = require('express');

const app = express();
app.use(express.json());

const PORTA = 3000;

// ===== Dados em memória =====
let proximoIdSala = 1;
const salas = [];

let proximoIdReserva = 1;
const reservas = [];

// ===== Funções auxiliares =====

// Converte "AAAA-MM-DDTHH:mm" (horário local) em Date.
// Retorna null se o formato for outro ou se a data não existir (ex.: 30 de fevereiro).
function converterDataHora(texto) {
  const partes = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})$/.exec(texto);
  if (!partes) return null;

  const [ano, mes, dia, hora, minuto] = partes.slice(1).map(Number);
  const data = new Date(ano, mes - 1, dia, hora, minuto);

  // O Date "corrige" datas inválidas (30/02 vira 02/03); se mudou algum campo, a data não existe.
  const dataReal =
    data.getFullYear() === ano &&
    data.getMonth() === mes - 1 &&
    data.getDate() === dia &&
    data.getHours() === hora &&
    data.getMinutes() === minuto;

  return dataReal ? data : null;
}

// Diz se o intervalo novo se sobrepõe ao de uma reserva existente.
// Comparação estrita: reservas que só encostam (10:00–11:00 e 11:00–12:00) não conflitam.
function haSobreposicao(novoInicio, novoFim, existente) {
  const existenteInicio = converterDataHora(existente.inicio);
  const existenteFim = converterDataHora(existente.fim);
  return novoInicio < existenteFim && novoFim > existenteInicio;
}

// Formata um Date como "AAAA-MM-DDTHH:mm" (horário local), o mesmo formato aceito na entrada.
function formatarDataHora(data) {
  const doisDigitos = (n) => String(n).padStart(2, '0');
  return (
    `${data.getFullYear()}-${doisDigitos(data.getMonth() + 1)}-${doisDigitos(data.getDate())}` +
    `T${doisDigitos(data.getHours())}:${doisDigitos(data.getMinutes())}`
  );
}

// ===== Rota de teste =====
app.get('/', (req, res) => {
  res.json({ mensagem: 'API de Reserva de Salas TechNova funcionando!' });
});

// ===== Salas =====
app.post('/salas', (req, res) => {
  const { nome } = req.body || {};

  if (typeof nome !== 'string' || nome.trim() === '') {
    return res.status(400).json({ erro: 'O nome da sala é obrigatório' });
  }

  const nomeLimpo = nome.trim();
  if (salas.some((s) => s.nome.toLowerCase() === nomeLimpo.toLowerCase())) {
    return res.status(409).json({ erro: `Já existe uma sala com o nome ${nomeLimpo}` });
  }

  const sala = { id: proximoIdSala++, nome: nomeLimpo };
  salas.push(sala);

  res.status(201).json(sala);
});

app.get('/salas', (req, res) => {
  res.json(salas);
});

// ===== Reservas =====
app.post('/reservas', (req, res) => {
  const { salaId, funcionario, inicio, fim } = req.body || {};

  if (typeof funcionario !== 'string' || funcionario.trim() === '') {
    return res.status(400).json({ erro: 'O funcionário é obrigatório' });
  }
  if (typeof inicio !== 'string' || inicio.trim() === '') {
    return res.status(400).json({ erro: 'O campo inicio é obrigatório' });
  }
  if (typeof fim !== 'string' || fim.trim() === '') {
    return res.status(400).json({ erro: 'O campo fim é obrigatório' });
  }

  const dataInicio = converterDataHora(inicio);
  if (!dataInicio) {
    return res.status(400).json({
      erro: `O campo inicio deve estar no formato AAAA-MM-DDTHH:mm e ser uma data real (ex.: 2027-03-10T10:00). Recebido: ${inicio}`,
    });
  }
  const dataFim = converterDataHora(fim);
  if (!dataFim) {
    return res.status(400).json({
      erro: `O campo fim deve estar no formato AAAA-MM-DDTHH:mm e ser uma data real (ex.: 2027-03-10T11:00). Recebido: ${fim}`,
    });
  }
  if (dataFim <= dataInicio) {
    return res.status(400).json({
      erro: `O fim deve ser depois do início (inicio: ${inicio}, fim: ${fim})`,
    });
  }
  if (dataInicio < new Date()) {
    return res.status(400).json({
      erro: `Não é possível reservar no passado: o início ${inicio} já passou (agora são ${formatarDataHora(new Date())})`,
    });
  }

  if (!Number.isInteger(salaId) || salaId < 1) {
    return res.status(400).json({
      erro: 'O campo salaId é obrigatório e deve ser um número inteiro positivo (ex.: 1). Consulte os ids em GET /salas',
    });
  }

  const sala = salas.find((s) => s.id === salaId);
  if (!sala) {
    return res.status(404).json({
      erro: `Sala não encontrada: não existe sala com id ${salaId}. Consulte as salas em GET /salas`,
    });
  }

  const conflito = reservas.find(
    (r) => r.salaId === sala.id && haSobreposicao(dataInicio, dataFim, r)
  );
  if (conflito) {
    return res.status(409).json({
      erro: `Conflito: a sala ${sala.nome} já está reservada de ${conflito.inicio} até ${conflito.fim} (reserva ${conflito.id}). Escolha outro horário ou outra sala`,
    });
  }

  const reserva = {
    id: proximoIdReserva++,
    salaId: sala.id,
    funcionario: funcionario.trim(),
    inicio,
    fim,
  };
  reservas.push(reserva);

  res.status(201).json(reserva);
});

app.get('/reservas', (req, res) => {
  const { funcionario } = req.query;

  if (typeof funcionario !== 'string' || funcionario.trim() === '') {
    return res.status(400).json({
      erro: 'Informe o funcionário na consulta: /reservas?funcionario=NOME (ex.: /reservas?funcionario=Ana)',
    });
  }

  const nomeBuscado = funcionario.trim().toLowerCase();
  const doFuncionario = reservas
    .filter((r) => r.funcionario.toLowerCase() === nomeBuscado)
    .sort((a, b) => converterDataHora(a.inicio) - converterDataHora(b.inicio));

  res.json(doFuncionario);
});

app.delete('/reservas/:id', (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id < 1) {
    return res.status(400).json({
      erro: `O id da reserva deve ser um número inteiro positivo (ex.: /reservas/1). Recebido: ${req.params.id}. Consulte os ids em GET /reservas?funcionario=NOME`,
    });
  }

  const posicao = reservas.findIndex((r) => r.id === id);

  if (posicao === -1) {
    return res.status(404).json({
      erro: `Reserva não encontrada: não existe reserva com id ${req.params.id} (ela pode já ter sido cancelada)`,
    });
  }

  const [reserva] = reservas.splice(posicao, 1);
  const sala = salas.find((s) => s.id === reserva.salaId);

  res.json({
    mensagem: `Reserva ${reserva.id} cancelada. A sala ${sala.nome} está livre de ${reserva.inicio} até ${reserva.fim}`,
    reserva,
  });
});

// ===== Inicialização =====
app.listen(PORTA, () => {
  console.log(`Servidor rodando em http://localhost:${PORTA}`);
});
