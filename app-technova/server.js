const express = require('express');
const ordersRouter = require('./routes/orders');

const app = express();

// Porta hardcoded — sem uso de variáveis de ambiente (fragilidade intencional)
const PORT = 3000;

app.use(express.json());

app.use('/orders', ordersRouter);

app.listen(PORT, () => {
  console.log(`Servidor TechNova rodando na porta ${PORT}`);
});
