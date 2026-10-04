# Processo Spec-Driven — Aula 07 | Nicolas de Jesus Silva (RA 6325171)

## 1. Problema

O objetivo era construir uma API simples para gerenciar reservas de salas usando Node.js + Express. O desafio principal não era apenas codificar endpoints, mas organizar a solução em etapas claras, evitando que a implementação ficasse confusa ou incompleta.

## 2. Requisitos

Os requisitos mínimos definidos foram:

- cadastrar salas com nome obrigatório
- listar salas
- criar reservas vinculando sala, funcionário, data e horário
- impedir reservas duplicadas na mesma sala no mesmo horário
- listar reservas por funcionário
- cancelar reservas existentes
- validar o funcionamento da API com testes e cURL

## 3. Design

A solução foi pensada em memória, com duas estruturas principais:

- `salas`: armazena as salas cadastradas
- `reservas`: armazena as reservas criadas

A regra de negócio está centralizada na rota `POST /reservas`, que:

1. valida se a sala informada existe
2. verifica se já existe uma reserva na mesma sala para a mesma data e horário
3. rejeita a operação com status `409` em caso de conflito

Esse desenho mantém a API simples, fácil de testar e adequado ao objetivo da aula.

## 4. Divisão em etapas (Spec-Driven)

1. Criar a estrutura base do projeto Node.js
2. Configurar o `package.json` e scripts
3. Implementar `GET /health`
4. Implementar `POST /salas`
5. Implementar `GET /salas`
6. Implementar `POST /reservas`
7. Validar conflito de horário por sala
8. Implementar `GET /reservas?funcionario=...`
9. Implementar `DELETE /reservas/:id`
10. Executar testes automatizados e validações por cURL

## 5. Validação com cURL

### 5.1 Verificar a saúde da API

```bash
curl -s http://localhost:3000/health
```

Resposta esperada:

```json
{"status":"ok","message":"API de reservas de salas em execução."}
```

### 5.2 Cadastrar uma sala

```bash
curl -s -X POST http://localhost:3000/salas \
  -H 'Content-Type: application/json' \
  -d '{"nome":"Sala A","capacidade":10}'
```

Resposta esperada:

```json
{"id":1,"nome":"Sala A","capacidade":10}
```

### 5.3 Criar uma reserva válida

```bash
curl -s -X POST http://localhost:3000/reservas \
  -H 'Content-Type: application/json' \
  -d '{"salaId":1,"funcionario":"Nicolas","data":"2026-10-01","horario":"09:00"}'
```

Resposta esperada:

```json
{"id":1,"salaId":1,"sala":"Sala A","funcionario":"Nicolas","data":"2026-10-01","horario":"09:00"}
```

### 5.4 Validar conflito de horário na mesma sala

```bash
curl -s -X POST http://localhost:3000/reservas \
  -H 'Content-Type: application/json' \
  -d '{"salaId":1,"funcionario":"Maria","data":"2026-10-01","horario":"09:00"}'
```

Resposta esperada: status `409` com mensagem:

```json
{"message":"A sala selecionada já está reservada para este horário."}
```

### 5.5 Listar reservas por funcionário

```bash
curl -s 'http://localhost:3000/reservas?funcionario=Nicolas'
```

Resposta esperada:

```json
[{"id":1,"salaId":1,"sala":"Sala A","funcionario":"Nicolas","data":"2026-10-01","horario":"09:00"}]
```

### 5.6 Cancelar reserva

```bash
curl -s -X DELETE http://localhost:3000/reservas/1
```

Resposta esperada:

```json
{"message":"Reserva cancelada com sucesso.","reserva":{"id":1,...}}
```

## 6. Testes executados

O projeto foi validado com testes automatizados em Node.js usando `node:test`.

Comando executado:

```bash
npm test
```

Resultado verificado:

- 3 testes passaram
- 0 falharam

## 7. Conclusão

A implementação foi bem-sucedida porque a solução foi construída por etapas, com foco na regra mais sensível do sistema: conflito de horário em uma mesma sala. Esse processo ajudou a reduzir erros, diminuir retrabalho e deixar a API mais fácil de entender, manter e validar.

A abordagem Spec-Driven mostrou-se eficaz para transformar um problema aparentemente grande em blocos menores, objetivos e verificáveis.
