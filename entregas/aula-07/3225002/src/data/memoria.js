// Armazenamento em memoria, como o enunciado permite. Uma lista por colecao,
// com o proprio contador de id — nada de banco de dados.
const bancoDeDados = {
  salas: [],
  reservas: [],
  proximoIdSala: 1,
  proximoIdReserva: 1,
};

module.exports = bancoDeDados;
