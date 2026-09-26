// A parte dificil do problema, isolada num modulo proprio.
//
// A armadilha: "nao pode ter duas reservas no mesmo horario" NAO significa
// comparar os horarios por igualdade. Se a checagem fosse
//
//     nova.inicio === existente.inicio
//
// entao uma reserva das 14h as 15h e outra das 14h30 as 15h30 passariam as
// duas, e a sala estaria ocupada em dobro das 14h30 as 15h.
//
// O certo e testar SOBREPOSICAO DE INTERVALOS. Dois intervalos [a1,a2) e
// [b1,b2) se sobrepoem quando:
//
//     a1 < b2  E  a2 > b1
//
// Os sinais sao estritos (< e >, nao <= e >=) de proposito: isso faz reservas
// encostadas — uma termina 15h, a outra comeca 15h — serem permitidas, que e o
// comportamento esperado de uma sala de reuniao.
//
//   existente:        |==========|        14:00 -------- 15:00
//   encostada:                   |=====|  15:00 -- 16:00   -> PERMITIDA
//   sobreposta:            |=========|    14:30 -- 15:30   -> BLOQUEADA
//   contida:            |====|            14:15 -- 14:45   -> BLOQUEADA
//   contem:        |==================|   13:00 -- 16:00   -> BLOQUEADA

function haSobreposicao(inicioA, fimA, inicioB, fimB) {
  const a1 = new Date(inicioA).getTime();
  const a2 = new Date(fimA).getTime();
  const b1 = new Date(inicioB).getTime();
  const b2 = new Date(fimB).getTime();

  return a1 < b2 && a2 > b1;
}

// Devolve a reserva conflitante, ou null se o horario esta livre.
// Ignora a reserva de id igual a ignorarId (util em atualizacao).
function encontrarConflito(reservas, { sala_id, inicio, fim }, ignorarId = null) {
  return (
    reservas.find(
      (r) =>
        r.sala_id === sala_id &&
        r.id !== ignorarId &&
        haSobreposicao(inicio, fim, r.inicio, r.fim)
    ) || null
  );
}

module.exports = { haSobreposicao, encontrarConflito };
