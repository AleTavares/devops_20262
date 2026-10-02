# Processo Spec-Driven — Reserva de Salas | Hector Marcelo Pedroso Dos Santos (6125136)

## 1. Como eu dividi o problema

Partes menores em que quebrei a API de reserva de salas:

1. Cadastrar sala (nome obrigatório)
2. Listar salas (e, como extra, listar só as salas livres em um período)
3. Criar reserva (sala, funcionário, horário)
4. **Bloquear conflito de horário** (a parte mais difícil, tratada isolada)
5. Cancelar reserva
6. Listar reservas de um funcionário

**Como o trabalho aconteceu, de forma honesta:** primeiro construí a base da API com o
Claude Code, uma parte por vez, testando cada uma com `curl` (rotas, conflito de horário e
README). Depois usei o **Kiro em modo Spec** (plano Free) para gerar requisitos, design e
tarefas sobre esse código, e para executar as tarefas uma a uma. Por isso o Kiro já leu um
`src/server.js` existente, e isso aparece nos relatos abaixo.

## 2. Requisitos (o quê)

O Kiro gerou o `requirements.md` com 6 requisitos (cadastrar sala, listar salas, salas
disponíveis em um período, criar reserva, cancelar reserva, listar reservas por funcionário),
com critérios de aceite testáveis e a fórmula de conflito.

Pontos importantes:
- O horário virou um **intervalo `inicio`/`fim`** (ISO 8601). Um instante só não permite
  detectar sobreposição. Reservas encostadas (fim de uma = início da outra) são permitidas.
- Conflito retorna **409** com mensagem clara e a reserva conflitante.

**O que corrigi:**
- O Kiro inventou um critério (1.4): rejeitar nome de sala duplicado com 409. **Removi.**
  O enunciado só exige "nome obrigatório" e a regra aumentava a complexidade.
- Mantive validações simples e baratas que ele acrescentou: limite de 100 caracteres, nome
  só com espaços tratado como vazio, id inválido no `DELETE` retorna 400.

## 3. Design (como)

A 1ª versão do design veio com arquitetura em camadas (`routes/`, `services/`, `data/`,
`app.js`) e 9 propriedades de correção para testes com `fast-check`. Para uma API de 6 rotas
com dados em memória isso era complexo demais.

**Simplifiquei:** pedi um único `src/server.js`, arrays em memória, sem camadas, sem
`fast-check`/Jest e validação manual com `curl`. O Kiro refez o design assim.

Decisão mantida: o algoritmo de conflito, `novoInicio < fimExistente && inicioExistente < novoFim`.

## 4. Tarefas (os passos pequenos)

Lista final do `tasks.md` (todas concluídas):

- [x] 1. Corrigir validação do `POST /salas`
  - [x] 1.1 Rejeitar `nome` só com espaços e com mais de 100 caracteres
- [x] 2. Corrigir validação do `GET /salas?inicio=&fim=`
  - [x] 2.1 Rejeitar quando só `inicio` ou só `fim` está presente
- [x] 3. Corrigir validação do `POST /reservas`
  - [x] 3.1 Rejeitar `funcionario` só com espaços e com mais de 100 caracteres
- [x] 4. Corrigir validação do `DELETE /reservas/:id`
  - [x] 4.1 Rejeitar `id` não numérico ou não inteiro positivo com 400
- [x] 5. Corrigir validação do `GET /reservas?funcionario=`
  - [x] 5.1 Rejeitar `funcionario` só com espaços com 400
- [x] 6. Validar bloqueio de conflito de horário (5 casos de `curl`)
- [x] 7. Checkpoint final

Ajustes que fiz na lista do Kiro: marquei a 2.1 como já feita, **pedi a tarefa 6 separada**
para o conflito de horário e removi as subtarefas de teste com Jest.
Executei **uma tarefa por vez** (sem "Run All Tasks").

## 5. Implementação e validação

Servidor de teste: `PORT=4100 node src/server.js`. Cada tarefa foi testada com `curl` no
servidor real.

### Tarefa 1 — `POST /salas` (nome só com espaços e > 100 caracteres)
```bash
curl -s -w ' [%{http_code}]\n' -XPOST localhost:4100/salas -H 'Content-Type: application/json' -d '{"nome":"   "}'
```
| Caso | Resultado |
|------|-----------|
| nome ausente, vazio, só espaços | 400 |
| 101 caracteres | 400 |
| 100 caracteres | 201 |
| `"Sala A"` | 201 |

### Tarefa 4 — `DELETE /reservas/:id` (id inválido)
```bash
curl -s -w ' [%{http_code}]\n' -XDELETE localhost:4100/reservas/abc
```
| Comando | Resultado |
|---------|-----------|
| `/reservas/abc`, `/1.5`, `/-3`, `/0` | 400 "O id deve ser um inteiro positivo" |
| `/reservas/999` | 404 "Reserva não encontrada" |
| `/reservas/1` (existente) | 200 "Reserva cancelada" |

### Tarefa 5 — `GET /reservas?funcionario=`
```bash
curl -s -w ' [%{http_code}]\n' -G localhost:4100/reservas --data-urlencode "funcionario=   "
```
| Caso | Resultado |
|------|-----------|
| sem parâmetro, vazio, só espaços | 400 |
| `funcionario=ana` (minúsculo) | 200, devolve as reservas da "Ana" |
| funcionário sem reservas | 200 `[]` |

### Tarefa 6 — Conflito de horário (a mais importante)
Reserva-base na sala 1, das 10:00 às 11:00.
```bash
curl -s -w ' [%{http_code}]\n' -XPOST localhost:4100/reservas -H 'Content-Type: application/json' \
  -d '{"salaId":1,"funcionario":"Ana","inicio":"2026-10-01T10:00:00Z","fim":"2026-10-01T11:00:00Z"}'
```
| Caso | Horário pedido | Resultado |
|------|----------------|-----------|
| idêntico | 10:00–11:00 | 409 |
| sobrepõe o início | 09:30–10:30 | 409 |
| sobrepõe o fim | 10:30–11:30 | 409 |
| contido | 10:15–10:45 | 409 |
| engloba | 09:00–12:00 | 409 |
| encostada depois | 11:00–12:00 | 201 |
| encostada antes | 09:00–10:00 | 201 |
| outra sala, mesmo horário | 10:00–11:00 | 201 |
| cancelar a base e refazer o horário | `DELETE` e depois `POST` | 200 e 201 |

Também confirmei as tarefas 2 e 3 (`GET /salas` com só um parâmetro e `POST /reservas` com
funcionário inválido). Na tarefa 7 o Kiro rodou um checkpoint de ponta a ponta com todos os
casos acima.

## 6. A IA errou em algum momento?

Sim, várias vezes. Os principais casos:

1. **Over-engineering no design:** o Kiro propôs 4 camadas e testes de propriedade com
   `fast-check` para um problema pequeno. Percebi pelo tamanho e pedi para simplificar.
2. **Requisito inventado:** nome de sala duplicado retornando 409. O enunciado não pedia. Removi.
3. **Tarefa para algo que já funcionava (2.1):** o `GET /salas` já retornava 400 com só um
   parâmetro. Pedi para conferir; o Kiro confirmou e marcou como feita. Isso se repetiu nas
   tarefas 1, 4 e 5: o código já estava pronto e ele só confirmou.
4. **Faltava a tarefa isolada do conflito de horário**, que o enunciado recomenda. Pedi e ele criou a tarefa 6.
5. **Jest apareceu de novo** nas tarefas mesmo eu pedindo para evitar. Pedi para remover.
6. **Declarou sucesso com teste quebrado (tarefa 1):** um script `node -e` imprimiu `undefined`
   e ✗ em todos os casos, e o resumo dizia "Todos os casos passaram". Percebi lendo a saída. O
   teste seguinte, com `curl` no servidor real, foi o confiável.
7. **Validação fraca (tarefa 5):** o Kiro só rodou `node --check` (sintaxe) e deu a tarefa por
   concluída. Testei a rota com `curl` e passou.
8. **Contagem errada no checkpoint:** ele disse "22 casos passaram", mas os grupos que ele
   mesmo listou somam 30 (5+5+5+6+4+5). Os resultados individuais estavam corretos.
9. **Falha de autenticação do Kiro** ao salvar o design; ele tentou de novo sozinho.

O padrão que percebi: a IA tende a declarar sucesso com validação fraca. Por isso não aceitei
"passou" sem ver a saída do `curl` e refiz os testes importantes por conta própria.

## 7. Reflexão

Se eu tivesse pedido tudo de uma vez, o Kiro teria entregue o design em camadas com testes
automatizados e o nome duplicado implementado, e o bloqueio de conflito ficaria misturado no
resto, sem teste isolado de cada caso de borda (encostada antes e depois, contido, engloba).
Eu só teria percebido os excessos depois, com muito código para desfazer.

Dividir em requisitos, design e tarefas deixou eu **cortar o excesso em cada etapa, antes de
virar código**. A tarefa isolada do conflito me obrigou a pensar nas bordas (o que é
"encostada") e a testar cada uma. Aprendi que a IA é boa copiloto, mas quem decide o escopo
sou eu, e que "tarefa concluída" dita pela IA não vale sem uma evidência que eu mesmo vi
(o `curl`). Também aprendi que o plano de tarefas precisa ser conferido contra o código real:
três tarefas eram sobre algo que já funcionava.
