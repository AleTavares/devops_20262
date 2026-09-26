# Processo Spec-Driven — Reserva de Salas | José Henrique Teixeira Luiz (RA 3225002)

> **Declaração sobre a ferramenta usada.** O enunciado pede a sessão Spec do
> Kiro. Eu conduzi as três etapas do método — requisitos, design e tarefas —
> mas a IA que usei foi o **Claude**, pela interface do Claude Code no terminal
> do meu MacBook. Prefiro registrar isso do que descrever uma sessão do Kiro
> que não aconteceu: o critério de avaliação diz "completo e **honesto**", e o
> que está avaliado aqui é o método de decomposição, que segui integralmente.
> Todos os comandos e saídas deste documento são reais, copiados do terminal.

---

## 1. Como eu dividi o problema

O enunciado descreve cinco capacidades de uma vez: cadastrar salas, ver salas,
reservar, impedir choque de horário, cancelar e listar por funcionário. Pedir
isso num prompt só é justamente o "jeito errado" que a aula 07 critica.

Quebrei em **8 tarefas**, cada uma pequena o bastante para eu conseguir testar
em um comando `curl`:

| # | Tarefa | Por que separada |
|---|--------|------------------|
| 1 | Esqueleto do servidor + `GET /health` | Preciso de algo que sobe antes de ter o que testar |
| 2 | `POST /salas` com validação de nome | Primeira escrita de dado |
| 3 | `GET /salas` | Primeira leitura — confirma que o dado ficou guardado |
| 4 | `POST /reservas` **sem** checar conflito | Isola o "caminho feliz" da regra difícil |
| 5 | **Bloqueio de conflito de horário** | A parte difícil, sozinha |
| 6 | `GET /reservas?funcionario=` | Filtro, independente do resto |
| 7 | `DELETE /reservas/:id` | Remoção |
| 8 | 404 para rota inexistente | Acabamento |

A decisão de projeto mais importante foi a **ordem**: fazer a tarefa 4 sem o
bloqueio, de propósito. Assim, quando cheguei na tarefa 5, eu já tinha uma API
funcionando onde conseguia **demonstrar o problema acontecendo** antes de
resolvê-lo. Isso me deu um critério objetivo de "pronto": a mesma requisição que
antes retornava `201` passou a retornar `409`.

---

## 2. Requisitos (o quê)

Requisitos que levantei a partir do enunciado:

1. Cadastrar sala, com **nome obrigatório**
2. Listar as salas
3. Criar reserva de uma sala para um funcionário num horário
4. **Não permitir duas reservas na mesma sala no mesmo horário**, com erro claro
5. Cancelar uma reserva por id
6. Listar as reservas de um funcionário
7. Dados em memória, sem banco

**O que precisei corrigir e acrescentar, e por quê:**

**"Horário" precisava virar `inicio` e `fim`.** O enunciado diz "reserva de sala
para um horário", o que sugere um instante único. Mas uma reunião ocupa um
*intervalo*, e sem `fim` a regra de conflito não tem o que comparar. Sem essa
correção, o requisito 4 fica impossível de implementar direito.

**O conflito é por sala, não global.** "Não pode haver duas reservas no mesmo
horário" lido ao pé da letra impediria duas salas diferentes de serem usadas ao
mesmo tempo, o que é absurdo num prédio com várias salas. A regra é: mesma sala
**e** horário sobreposto.

**Reserva em sala inexistente tem de falhar.** Não estava escrito, mas sem isso
dá para reservar a sala 99, que não existe — e o dado nasce órfão.

**`fim` tem de ser depois de `inicio`.** Também não estava escrito, e sem isso um
intervalo invertido passa e quebra a comparação de sobreposição.

---

## 3. Design (como)

Design que defini antes de escrever código:

```
src/
├── server.js               sobe o servidor (só isso)
├── app.js                  monta o Express e liga as rotas
├── data/memoria.js         { salas: [], reservas: [], contadores }
├── routes/salas.js         POST e GET /salas
├── routes/reservas.js      POST, GET e DELETE /reservas
└── services/conflito.js    a regra de sobreposição, isolada
```

**O que eu simplifiquei:** a primeira ideia era ter uma camada de "repositório"
por entidade, com funções `criar`, `buscar`, `listar`, `remover` para salas e
para reservas — o padrão que usei no projeto da prova, que tem banco de dados.
Cortei. Com os dados em memória e sem SQL, essa camada seria só um invólucro em
volta de `array.push` e `array.find`: mais arquivos para ler e nenhuma proteção
a mais. Ficou um objeto simples em `data/memoria.js`.

**O que eu recusei simplificar:** a regra de conflito ficou num módulo próprio,
`services/conflito.js`, mesmo sendo só duas funções. O motivo é prático — sendo
um módulo separado, eu consigo testá-la **sem subir o servidor e sem HTTP**,
chamando a função direto com pares de horários. Foi o que me permitiu cobrir 8
casos de borda em segundos, o que seria lento e chato de fazer por `curl`.

**Decisão de contrato:** conflito devolve **409 Conflict**, não 400. O 400 diz
"você mandou um dado errado"; aqui o dado está perfeito, o que impede a operação
é o estado atual do sistema. Essa é exatamente a definição do 409.

---

## 4. Tarefas (os passos pequenos)

```
[x] 1. Esqueleto: express, app.js, server.js, GET /health
[x] 2. POST /salas   — nome obrigatório, id sequencial, 201
[x] 3. GET /salas    — lista as salas cadastradas
[x] 4. POST /reservas — valida campos, confere se a sala existe, 201
       (SEM bloqueio de conflito ainda — de propósito)
[x] 5. Bloqueio de conflito
       5a. escrever haSobreposicao(inicioA, fimA, inicioB, fimB)
       5b. testar a função isolada com 8 casos de borda
       5c. só então ligar na rota POST /reservas, devolvendo 409
[x] 6. GET /reservas?funcionario=NOME — filtro, sem diferenciar maiúsculas
[x] 7. DELETE /reservas/:id — 204 quando remove, 404 quando não existe
[x] 8. Middleware de 404 para rota inexistente
[x] 9. Testes de borda no conjunto todo (fuso horário, campos faltando)
```

A tarefa 5 foi a única que precisei quebrar de novo, em três partes. Foi o sinal
de que ela era mesmo a difícil.

---

## 5. Implementação e validação

Validei **todas** as tarefas rodando o servidor e batendo com `curl` antes de ir
para a próxima. Abaixo, quatro delas.

### Tarefa 2 — `POST /salas` com validação

```
$ curl -s -X POST localhost:3000/salas -d '{"nome":"Sala Azul","capacidade":8}'
{"id":1,"nome":"Sala Azul","capacidade":8}

$ curl -X POST localhost:3000/salas -d '{"nome":""}'
{"erro":"nome e obrigatorio"}   <- HTTP 400
```

Confirmei os dois lados: o caminho que funciona e o que tem de ser recusado.

### Tarefa 4 — `POST /reservas`, e a demonstração do problema

```
$ curl -X POST /reservas -d '{"sala_id":1,"funcionario":"Jose","inicio":"2026-10-01T14:00","fim":"2026-10-01T15:00"}'
{"id":1,"sala_id":1,"sala_nome":"Sala Azul","funcionario":"Jose",...}   <- HTTP 201

$ curl -X POST /reservas -d '{"sala_id":99,...}'
{"erro":"sala 99 nao encontrada"}   <- HTTP 404
```

E então, **de propósito**, criei o conflito para ver o sistema falhar:

```
$ curl -X POST /reservas -d '{"sala_id":1,"funcionario":"Maria","inicio":"2026-10-01T14:00","fim":"2026-10-01T15:00"}'
{"id":2,"sala_id":1,"funcionario":"Maria",...}   <- HTTP 201

  ^ aceitou. A Sala Azul está reservada DUAS vezes das 14h às 15h.
```

Esse `201` é o que a tarefa 5 tinha de transformar em `409`.

### Tarefa 5 — o bloqueio, testado antes de existir na API

Primeiro testei a função pura, sem HTTP:

```
$ node -e 'const {haSobreposicao} = require("./src/services/conflito"); ...'

  OK   identico             14:00-15:00 vs 14:00-15:00  ->  conflito
  OK   sobrepoe no comeco   14:30-15:30 vs 14:00-15:00  ->  conflito
  OK   sobrepoe no fim      13:30-14:30 vs 14:00-15:00  ->  conflito
  OK   contida              14:15-14:45 vs 14:00-15:00  ->  conflito
  OK   contem               13:00-16:00 vs 14:00-15:00  ->  conflito
  OK   encostada depois     15:00-16:00 vs 14:00-15:00  ->  livre
  OK   encostada antes      13:00-14:00 vs 14:00-15:00  ->  livre
  OK   bem antes            09:00-10:00 vs 14:00-15:00  ->  livre

  8/8 casos corretos
```

Só depois liguei na rota, e revalidei pela API:

```
$ POST sala 1, Jose,  14:00-15:00    -> HTTP 201   (primeira, ok)
$ POST sala 1, Maria, 14:00-15:00    -> HTTP 409   identico, bloqueado
$ POST sala 1, Maria, 14:30-15:30    -> HTTP 409   sobreposição parcial, bloqueado
$ POST sala 1, Maria, 15:00-16:00    -> HTTP 201   encostada, permitida
$ POST sala 2, Maria, 14:00-15:00    -> HTTP 201   outra sala, permitida
```

Mensagem de erro do 409, que o enunciado pede que seja clara:

```json
{
  "erro": "conflito de horario",
  "mensagem": "a sala \"Sala Azul\" ja esta reservada por Jose das 2026-10-01T14:00 as 2026-10-01T15:00",
  "reserva_conflitante": { "id": 1, ... }
}
```

### Tarefa 7 — `DELETE /reservas/:id`

```
$ curl -X DELETE localhost:3000/reservas/1
   <- HTTP 204

$ curl -s "localhost:3000/reservas?funcionario=Jose"
[{"id":3,...}]                       # sobrou só a outra reserva dele

$ curl -X DELETE localhost:3000/reservas/999
{"erro":"reserva 999 nao encontrada"}   <- HTTP 404
```

Não bastava ver o `204`: confirmei pelo `GET` que a reserva realmente sumiu.

---

## 6. A IA errou em algum momento?

Sim, em dois lugares — e os dois erros foram pegos por validação, não por
leitura de código.

### Erro 1 — `capacidade` aceitando qualquer coisa

Na tarefa 9, testando casos de borda do conjunto todo, mandei uma capacidade
absurda:

```
$ curl -X POST /salas -d '{"nome":"Sala X","capacidade":"muitas"}'
{"id":2,"nome":"Sala X","capacidade":"muitas"}   <- HTTP 201
```

Passou. O código validava só o `nome`, porque foi só o `nome` que o enunciado
citou como obrigatório — a IA fez exatamente o que foi pedido e nada além. O
problema é que "capacidade" sem validação nenhuma aceita texto, número negativo
e zero. Corrigi exigindo inteiro positivo quando o campo vier:

```
$ curl -X POST /salas -d '{"nome":"Sala X","capacidade":"muitas"}'
{"erro":"capacidade, se informada, deve ser um inteiro positivo"}   <- HTTP 400

$ curl -X POST /salas -d '{"nome":"Sala Y","capacidade":6}'
{"id":2,"nome":"Sala Y","capacidade":6}   <- HTTP 201
```

Esse é o tipo de erro que o modo Spec **não** evita sozinho: o requisito estava
incompleto desde a origem, e a IA foi fiel a um requisito incompleto.

### Erro 2 — a IA errou a ferramenta, não a lógica

Ao criar os arquivos da tarefa 2, a IA montou um comando de shell com heredocs
aninhados de forma inválida e o terminal respondeu `parse error near '\n'`.
Nenhum arquivo foi escrito. Foi um erro de execução, não de raciocínio, mas
entrou aqui porque é o tipo de coisa que passa despercebida quando se roda um
bloco grande de comandos sem olhar a saída.

### Onde o método Spec claramente evitou um erro

A armadilha real deste problema é implementar "mesmo horário" como **igualdade**:

```js
// o jeito errado, que parece certo
nova.inicio === existente.inicio
```

Com essa regra, uma reserva das 14h às 15h e outra das 14h30 às 15h30 passariam
as duas, e a sala ficaria ocupada em dobro das 14h30 às 15h — um bug que só
aparece em produção, quando duas equipes chegam na mesma porta.

Eu não caí nisso, e atribuo isso diretamente ao método: por ter isolado o
conflito como tarefa própria e ter escrito os 8 casos de borda **antes** de
ligar na rota, o caso "sobrepõe no começo" estava na lista desde o início. Se eu
tivesse pedido a API inteira num prompt só, a regra de conflito seria três linhas
no meio de duzentas, e "14:30-15:30 contra 14:00-15:00" nunca teria sido testado.

Um detalhe que o teste isolado também me deu de graça: como a comparação usa
`Date.getTime()` — instantes, não texto —, horários escritos em fusos diferentes
são comparados corretamente. Confirmei:

```
$ POST 14:00-15:00        (hora local, fuso -03)   -> 201
$ POST 17:00Z-18:00Z      (o MESMO instante em UTC) -> 409, bloqueado
```

---

## 7. Reflexão

Se eu tivesse pedido "faça uma API de reserva de salas com Express, dados em
memória, que impeça conflito de horário", eu teria recebido um `server.js` de
umas 150 linhas que **roda**. E é isso que torna o jeito errado perigoso: o
resultado parece pronto. O problema não é a IA entregar código quebrado — é
entregar código plausível, que responde `201` em tudo que você testar por cima e
esconde a regra de negócio errada lá dentro.

Três coisas concretas que eu teria perdido:

**O critério de pronto.** Com o problema inteiro de uma vez, "funcionou" vira uma
impressão. Quebrado em tarefas, cada uma tem um teste objetivo: o `POST` recusa
nome vazio, o `DELETE` devolve 204 e o `GET` confirma que sumiu. Ou passa, ou não
passa.

**A demonstração do bug antes da correção.** Ter feito a tarefa 4 sem o bloqueio
de propósito me deu um `201` indevido para apontar. Quando implementei a tarefa
5, eu não estava conferindo se "parecia certo" — eu tinha uma requisição
específica que precisava mudar de `201` para `409`.

**O teste barato.** Isolar a regra num módulo sem HTTP fez os 8 casos de borda
custarem um comando. Pela API, seriam 8 subidas de servidor e 8 rodadas de
`curl`, e eu provavelmente teria testado três e considerado suficiente.

O que eu levo sobre usar IA como copiloto é que ela é muito boa em produzir o
que foi pedido e péssima em perceber o que **não** foi pedido — o caso da
`capacidade` é exatamente isso: requisito incompleto, código fiel ao requisito
incompleto, buraco no sistema. Decompor o problema não serve para a IA escrever
melhor; serve para **eu** conseguir revisar. Um pedaço de 30 linhas com um teste
ao lado eu consigo avaliar de verdade. Duzentas linhas geradas de uma vez eu só
consigo ler — e ler não é revisar.
