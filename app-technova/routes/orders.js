const express = require('express');
const router = express.Router();

// Armazenamento em memória (fragilidade intencional - dados perdidos ao reiniciar)
let orders = [];
let nextId = 1;

// GET /orders - Listar todos os pedidos
router.get('/', (req, res) => {
  res.json(orders);
});

// GET /orders/:id - Buscar pedido por ID
router.get('/:id', (req, res) => {
  const order = orders.find(o => o.id === parseInt(req.params.id));
  if (!order) {
    return res.status(404).json({ erro: 'Pedido não encontrado' });
  }
  res.json(order);
});

// POST /orders - Criar novo pedido
// Sem validação de entrada (fragilidade intencional)
router.post('/', (req, res) => {
  const order = {
    id: nextId++,
    cliente: req.body.cliente,
    item: req.body.item,
    quantidade: req.body.quantidade,
    status: req.body.status || 'pendente'
  };
  orders.push(order);
  res.status(201).json(order);
});

// PUT /orders/:id - Atualizar pedido existente
// Sem validação de entrada (fragilidade intencional)
router.put('/:id', (req, res) => {
  const index = orders.findIndex(o => o.id === parseInt(req.params.id));
  if (index === -1) {
    return res.status(404).json({ erro: 'Pedido não encontrado' });
  }
  orders[index] = {
    id: orders[index].id,
    cliente: req.body.cliente,
    item: req.body.item,
    quantidade: req.body.quantidade,
    status: req.body.status
  };
  res.json(orders[index]);
});

// DELETE /orders/:id - Remover pedido
router.delete('/:id', (req, res) => {
  const index = orders.findIndex(o => o.id === parseInt(req.params.id));
  if (index === -1) {
    return res.status(404).json({ erro: 'Pedido não encontrado' });
  }
  const deleted = orders.splice(index, 1);
  res.json(deleted[0]);
});

module.exports = router;
