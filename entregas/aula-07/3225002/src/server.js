const app = require("./app");

const PORTA = Number(process.env.PORT) || 3000;

app.listen(PORTA, () => {
  console.log(`[api] reserva de salas ouvindo na porta ${PORTA}`);
});
