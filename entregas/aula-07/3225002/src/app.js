const express = require("express");
const salasRouter = require("./routes/salas");
const reservasRouter = require("./routes/reservas");

const app = express();
app.use(express.json());

app.use("/salas", salasRouter);
app.use("/reservas", reservasRouter);

app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

app.use((_req, res) => {
  res.status(404).json({ erro: "rota nao encontrada" });
});

module.exports = app;
