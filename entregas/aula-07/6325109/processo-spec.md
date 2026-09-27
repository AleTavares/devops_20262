# Processo Spec-Driven - Reserva de Salas | Carina Goncalves dos Santos Dalpino (RA: 6325109)

## 1. Como eu dividi o problema

O pedido "uma API de reserva de salas" parece uma coisa so, mas na verdade sao
varias funcionalidades juntas. Em vez de pedir tudo de uma vez, quebrei em 6 partes
pequenas, da mais simples para a mais dificil:

1. **Setup do projeto** - package.json, Express e um servidor que sobe na porta 3000
2. **Cadastrar e listar salas** - POST /salas e GET /salas
3. **Criar reserva** - POST /reservas (sala, funcionario, horario)
4. **Impedir conflito de horario** - a regra dificil, tratada como tarefa isolada
5. **Cancelar reserva** - DELETE /reservas/:id
6. **Listar reservas de um funcionario** - GET /reservas?funcionario=NOME

A ideia foi: cada parte funcionando e testada antes de partir para a proxima.

## 2. Requisitos (o que)

Os requisitos que levantei a partir do enunciado:

- Cadastrar sala (nome obrigatorio)
- Listar salas
- Criar reserva vinculada a uma sala existente
- Bloquear duas reservas na mesma sala e mesmo horario
- Cancelar reserva por id
- Listar reservas filtrando por funcionario
- Dados em memoria (sem banco)

O que precisei **adicionar/corrigir** em relacao ao pedido original: validacoes que
o enunciado nao detalha mas sao necessarias - verificar se a sala existe antes de
reservar (senao daria para reservar uma sala inexistente) e retornar codigos HTTP
corretos (400 para dados faltando, 404 para nao encontrado, 409 para conflito).

## 3. Design (como)

Decisoes de design, mantendo simples:

- **Node.js + Express** com `express.json()` para ler o corpo das requisicoes.
- **Armazenamento em memoria** com dois arrays (`salas` e `reservas`) e dois
  contadores de id (`proximoIdSala`, `proximoIdReserva`). Nao usei banco porque o
  enunciado permite memoria e isso mantem o foco no problema.
- **Um unico arquivo `server.js`** - o projeto e pequeno, separar em varios arquivos
  seria complexidade desnecessaria.
- **Codigos HTTP semanticos**: 201 (criado), 400 (dados invalidos), 404 (nao achado),
  409 (conflito). Simplifiquei mantendo a resposta de erro sempre como `{ "erro": "..." }`.

## 4. Tarefas (os passos pequenos)

- [x] Tarefa 1: Setup (package.json + express + servidor na porta 3000)
- [x] Tarefa 2: POST /salas (com validacao de nome) + GET /salas
- [x] Tarefa 3: POST /reservas (com validacao de campos e checagem de sala existente)
- [x] Tarefa 4: Bloqueio de conflito de horario (mesma sala + mesmo horario = 409)
- [x] Tarefa 5: DELETE /reservas/:id (com 404 se nao existir)
- [x] Tarefa 6: GET /reservas?funcionario=NOME (com filtro)

## 5. Implementacao e validacao

Testei cada rota com curl antes de seguir. Exemplos reais:

**Tarefa 2 - cadastro e listagem de salas:**
```
$ curl -X POST http://localhost:3000/salas -H "Content-Type: application/json" -d "{\"nome\":\"Sala Azul\"}"
{"id":1,"nome":"Sala Azul"}

$ curl -X POST http://localhost:3000/salas -H "Content-Type: application/json" -d "{}"
{"erro":"O campo 'nome' e obrigatorio."}        <- validacao funcionou

$ curl http://localhost:3000/salas
[{"id":1,"nome":"Sala Azul"},{"id":2,"nome":"Sala Verde"}]
```

**Tarefa 4 - bloqueio de conflito (a parte dificil):**
```
$ curl -X POST http://localhost:3000/reservas -H "Content-Type: application/json" \
   -d "{\"salaId\":1,\"funcionario\":\"Ana\",\"horario\":\"2026-10-01 14:00\"}"
{"id":1,"salaId":1,"funcionario":"Ana","horario":"2026-10-01 14:00"}

$ curl -X POST http://localhost:3000/reservas -H "Content-Type: application/json" \
   -d "{\"salaId\":1,\"funcionario\":\"Bruno\",\"horario\":\"2026-10-01 14:00\"}"
{"erro":"Ja existe uma reserva para esta sala neste horario.", ...}   <- 409, bloqueou!

$ curl -X POST http://localhost:3000/reservas -H "Content-Type: application/json" \
   -d "{\"salaId\":1,\"funcionario\":\"Bruno\",\"horario\":\"2026-10-01 15:00\"}"
{"id":2,"salaId":1,"funcionario":"Bruno","horario":"2026-10-01 15:00"}  <- horario diferente, ok
```

**Tarefa 5 - cancelar (e liberar o horario):**
```
$ curl -X DELETE http://localhost:3000/reservas/1
{"mensagem":"Reserva cancelada com sucesso.", ...}

$ curl -X DELETE http://localhost:3000/reservas/999
{"erro":"Reserva nao encontrada."}              <- 404 correto

# apos cancelar a reserva das 14h, o mesmo horario ficou livre:
$ curl -X POST http://localhost:3000/reservas -H "Content-Type: application/json" \
   -d "{\"salaId\":1,\"funcionario\":\"Carla\",\"horario\":\"2026-10-01 14:00\"}"
{"id":3,"salaId":1,"funcionario":"Carla","horario":"2026-10-01 14:00"}  <- funcionou!
```

## 6. A IA errou em algum momento?

Durante o desenvolvimento, percebi que nao era suficiente apenas pedir para a IA criar o codigo. Foi necessario acompanhar cada etapa, testar e conferir se o resultado realmente atendia ao que havia sido solicitado.

Um dos pontos que exigiu mais atencao foi a regra de conflito de horario. A reserva nao poderia ser bloqueada somente porque o horario era igual. Era necessario verificar tambem se a reserva era para a mesma sala. Dessa forma, duas salas diferentes poderiam ser reservadas no mesmo horario sem gerar um conflito.

Tambem foi importante validar se a sala informada realmente existia antes de criar uma reserva. Esse tipo de detalhe mostrou para mim que, mesmo utilizando a IA como apoio, e necessario entender o que esta sendo desenvolvido e testar o resultado.

Por isso, percebi que a IA pode ajudar bastante na construcao da solucao, mas nao substitui a conferencia e a validacao de quem esta desenvolvendo.

## 7. Reflexao

Ao realizar essa atividade, percebi que dividir o problema em partes menores tornou o desenvolvimento mais facil de entender e acompanhar.

Se eu tivesse pedido para a IA criar toda a API de uma vez, provavelmente teria recebido uma quantidade maior de codigo e seria mais dificil identificar onde estava cada problema. Trabalhando por etapas, consegui testar cada funcionalidade antes de passar para a proxima.

Tambem entendi melhor a importancia de validar o que a IA apresenta. Mesmo quando o codigo parece estar correto, e necessario executar, testar e verificar se o comportamento realmente esta de acordo com o que foi solicitado.

Para mim, o principal aprendizado foi entender que a IA pode ser utilizada como uma ferramenta de apoio durante o desenvolvimento, mas eu preciso continuar acompanhando o processo e tomando as decisoes. Em vez de simplesmente pedir uma solucao pronta, e mais importante saber explicar o problema, dividir as tarefas, testar os resultados e fazer os ajustes necessarios.

Essa atividade me ajudou a perceber que utilizar a IA como copiloto nao significa deixar a IA fazer todo o trabalho. Significa utilizar a tecnologia para agilizar algumas etapas, enquanto eu continuo entendendo e acompanhando o que esta sendo feito.