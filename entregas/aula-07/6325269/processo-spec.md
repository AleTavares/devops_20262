# Processo Spec-Driven — Reserva de Salas | Sirlande Martins (6325269)

> **Ferramenta usada:** o TF sugere o Kiro, mas como o professor liberou o uso de outros agentes,
> usei o **Claude Code** seguindo as três etapas do modo Spec do Kiro — Requisitos → Design →
> Tarefas —, com os documentos gravados no mesmo formato e local que o Kiro usa
> ([`.kiro/specs/reserva-salas/`](.kiro/specs/reserva-salas/)). No resto deste documento, "a IA"
> se refere a ele.
>
> Regra que segui em todo o trabalho: **a IA só avançava uma etapa quando eu pedia**, e cada
> tarefa só era marcada como concluída depois de testada com `curl`.

## 1. Como eu dividi o problema

O enunciado pede cinco coisas (cadastrar salas, ver salas, reservar, cancelar e listar por
funcionário) e uma regra (não permitir duas reservas no mesmo horário na mesma sala). Dividi em
partes, na ordem em que uma depende da outra:

| Parte | O que é | Depende de |
|---|---|---|
| 1. Salas | cadastrar (nome obrigatório e sem repetição) e listar | — |
| 2. Reserva | ligar sala + funcionário + intervalo de horário, com validações | salas |
| 3. Conflito | recusar reservas que se sobrepõem na mesma sala | reserva |
| 4. Cancelamento | apagar a reserva e liberar o horário | conflito (para provar que liberou) |
| 5. Reservas do funcionário | listar só as reservas dele, em ordem | reserva |
| 6. Memória | guardar tudo em arrays, sem banco | — |

A parte **2 (reserva)** era grande demais para uma tarefa só, então virou quatro: campos
obrigatórios, formato das datas, reserva no passado e — isolado, como o TF recomenda — o
**conflito**. Assim, cada regra foi testada sozinha: se algo falhasse, eu saberia exatamente qual
regra quebrou.

## 2. Requisitos (o quê)

A IA gerou **7 requisitos** no formato história de usuário + critérios "QUANDO / SE … O sistema
DEVE …": cadastro de sala, listagem, criação de reserva, bloqueio de conflito, cancelamento,
reservas por funcionário e armazenamento em memória
([`requirements.md`](.kiro/specs/reserva-salas/requirements.md)).

Em vez de inventar o que o enunciado não diz, a IA listou **7 pontos em aberto**, e eu decidi
cada um:

| # | Dúvida deixada em aberto | Minha decisão | Por quê |
|---|---|---|---|
| 1 | "Horário" é um bloco fixo (ex.: 1 hora) ou um intervalo com início e fim? | **Intervalo** (`inicio` e `fim`) | Reuniões reais têm duração variável; bloco fixo obrigaria uma reunião de 30 min a ocupar 1 hora. |
| 2 | Conflito é só horário igual ou também sobreposição? | **Sobreposição** | Comparar só horários iguais deixaria passar 10:00–11:00 e 10:30–11:30 — duas reuniões na mesma sala ao mesmo tempo. O sistema cumpriria a letra do requisito e falharia no objetivo. |
| 3 | "Ver salas disponíveis": listar todas ou filtrar as livres? | **Listar todas** (`GET /salas`) | É a rota mínima pedida; filtrar por intervalo ficou fora do escopo para não aumentar o problema. |
| 4 | Recusar reservas no passado? | **Sim, inclusive reuniões que já começaram** | Perguntei antes por que recusar seria melhor: uma reserva no passado não tem uso e quase sempre é erro de digitação (ex.: ano errado). Sem a validação, o sistema confirmaria uma reserva que nunca vai acontecer. |
| 5 | Funcionário é só o nome? A busca diferencia maiúsculas? | **Só o nome; "Ana" = "ana" = "ANA"** | A rota `?funcionario=NOME` já indica isso; diferenças de digitação não podem separar a mesma pessoa. |
| 6 | Cancelar apaga ou guarda com status "cancelada"? | **Apagar** | Questionei se o status evitaria cancelamentos por engano. A conclusão foi que não: guardar o status só *registra*; *desfazer* ("reativar") ou *impedir* (confirmação) seriam outras funções. E o status obrigaria a regra de conflito a ignorar as canceladas — um filtro que, se esquecido, deixaria a sala bloqueada. Como ninguém pediu histórico, apagar é mais simples e seguro. |
| 7 | Pode haver duas salas com o mesmo nome? | **Não** (sem diferenciar maiúsculas) | Com nomes iguais, quem escolhe pela listagem não saberia qual sala está reservando. |

Essas decisões mudaram os requisitos: o Requisito 3 ganhou o intervalo e as validações de data,
o Requisito 4 passou a definir conflito como sobreposição (aceitando reservas que só
"encostam"), e todas estão registradas, com o porquê, na seção **"Decisões tomadas na revisão"**
do `requirements.md`.

**Correções feitas depois, durante a implementação** (os testes revelaram lacunas da spec):

- **Critério 3.8 — `salaId` ausente ou inválido:** a spec só previa "sala não existe → 404". No
  teste da Tarefa 5, uma reserva *sem* `salaId` respondia "Sala não encontrada", o que confunde
  quem usa a API. Decidi corrigir para **400** com uma mensagem que explica o campo e onde
  consultar os ids.
- **Critério 5.4 — id de reserva inválido no cancelamento:** no teste da Tarefa 9,
  `DELETE /reservas/abc` respondia "não encontrada (pode já ter sido cancelada)", uma mensagem
  que não faz sentido para um id que nunca existiu. Decidi tratar do mesmo jeito que o `salaId`:
  **400** explicando o formato esperado.
- **Mensagens de erro mais informativas:** pedi que as mensagens ajudassem quem está com
  dificuldade — mostrando o valor recebido, um exemplo correto e onde consultar dados (ex.:
  `"... Recebido: 10/03/2027"`, `"... Consulte as salas em GET /salas"`).

Também mantive, depois de discutir, uma regra estrita: uma reserva para o minuto atual (ex.:
22:44 pedida às 22:44 e alguns segundos) é recusada, porque o início já passou.

## 3. Design (como)

O Design ([`design.md`](.kiro/specs/reserva-salas/design.md)) propôs:

| # | Decisão | Motivo |
|---|---|---|
| A | Tudo em um único `server.js`, com seções comentadas | Simples, como no laboratório |
| B | Data/hora **somente** no formato `AAAA-MM-DDTHH:mm`, conferindo se a data existe | O JavaScript aceita formatos ambíguos (`"10/03/2027"`) e "corrige" datas inválidas (30/02 vira 02/03) |
| C | Horário local do servidor | Evita lidar com fuso horário numa API local |
| D | Validações em ordem fixa, com o **conflito por último** | Cada erro é pego pela checagem mais simples; o conflito só roda com dados válidos |
| E | Conflito responde **409** com a sala e o intervalo já ocupado | É o "erro claro" que o TF pede |
| F | `DELETE` responde 200 com a reserva removida (e não 204 vazio) | O teste com `curl` mostra o que foi cancelado |
| G | A reserva guarda o `salaId`, não uma cópia da sala | Referência simples e estável |

A regra de conflito ficou definida em uma linha — `nova.inicio < existente.fim E nova.fim >
existente.inicio` — com uma **tabela de 8 casos** (igual, parcial no fim, parcial no início,
dentro, envolvendo, encostando depois, encostando antes e outra sala), que virou o roteiro de
teste da Tarefa 8.

Aprovei o Design **sem mudanças** na revisão. As mudanças vieram depois, pelos testes:

- **Ordem das validações:** entrou um passo novo — `salaId` informado e numérico → 400 — antes
  de "sala existe → 404" (correção do critério 3.8).
- **Tabela de mensagens:** atualizada com as mensagens mais informativas e com a validação do id
  no cancelamento (critério 5.4).

## 4. Tarefas (os passos pequenos)

Lista completa em [`tasks.md`](.kiro/specs/reserva-salas/tasks.md). Cada tarefa tem o que
implementar, uma linha **Validar** com os casos de `curl` e os requisitos que atende.

```
[x] 1.  Criar o servidor Express básico (GET /)
[x] 2.  Cadastrar sala com validação de nome
[x] 3.  Impedir nome de sala duplicado
[x] 4.  Listar salas
[x] 5.  Criar reserva com validação de funcionário e sala   (+ correção do salaId após o teste)
[x] 6.  Validar formato das datas e fim depois do início
[x] 7.  Recusar reserva no passado
[x] 8.  Bloquear conflito de horário (sobreposição) — tarefa isolada
[x] 9.  Cancelar reserva                                     (+ ajuste do id inválido após o teste)
[x] 10. Listar reservas de um funcionário
```

Por que nessa ordem: a criação de reserva virou as tarefas 5 a 8, uma regra por tarefa; o
**cancelamento (9) vem depois do conflito (8)** porque o teste "cancelar libera o horário" só
prova algo se a regra de conflito já existir.

## 5. Implementação e validação

Todas as 10 tarefas foram implementadas **uma de cada vez**: a IA fazia só a tarefa pedida, subia
o servidor, rodava os `curl` da linha "Validar" (mais alguns casos extras), desligava o servidor e
só então marcava `[x]`. Ao final, rodei de novo as rotas das tarefas 1 a 4 para confirmar que as
mudanças posteriores não quebraram nada. Quatro exemplos:

### Tarefa 5 — Criar reserva (e a lacuna que o teste revelou)

```bash
$ curl -X POST http://localhost:3000/reservas -H "Content-Type: application/json" \
  -d '{"salaId": 1, "funcionario": "Ana", "inicio": "2027-03-10T10:00", "fim": "2027-03-10T11:00"}'
{"id":1,"salaId":1,"funcionario":"Ana","inicio":"2027-03-10T10:00","fim":"2027-03-10T11:00"}  [HTTP 201]

$ curl -X POST http://localhost:3000/reservas -H "Content-Type: application/json" \
  -d '{"salaId": 1, "inicio": "2027-03-10T10:00", "fim": "2027-03-10T11:00"}'
{"erro":"O funcionário é obrigatório"}  [HTTP 400]

# sem salaId — ANTES da correção
{"erro":"Sala não encontrada"}  [HTTP 404]
```

O último caso seguia o Design, mas estava errado do ponto de vista de quem usa: faltava um dado,
não era uma sala inexistente. Depois da correção:

```bash
# sem salaId — DEPOIS
{"erro":"O campo salaId é obrigatório e deve ser um número inteiro positivo (ex.: 1). Consulte os ids em GET /salas"}  [HTTP 400]
# salaId 99
{"erro":"Sala não encontrada: não existe sala com id 99. Consulte as salas em GET /salas"}  [HTTP 404]
```

Revalidado com 7 casos (sem `salaId`, `"1"` como texto, `0`, `1.5`, sala 99, reserva válida e
sem funcionário), todos com o resultado esperado.

### Tarefa 6 — Formato das datas

| Entrada | Resposta |
|---|---|
| `"inicio": "10/03/2027"` | 400 `O campo inicio deve estar no formato AAAA-MM-DDTHH:mm e ser uma data real (ex.: 2027-03-10T10:00). Recebido: 10/03/2027` |
| `"inicio": "2027-02-30T10:00"` (30 de fevereiro) | 400 |
| fim igual ao início | 400 `O fim deve ser depois do início (inicio: 2027-03-10T10:00, fim: 2027-03-10T10:00)` |
| fim antes do início | 400 |
| reserva válida | 201 |
| *extra:* `2028-02-29T10:00` (ano bissexto) | 201 — data real |
| *extra:* `2027-02-29T10:00` (ano comum) | 400 |

Confirmei que a data "corrigida" pelo JavaScript (30/02 → 02/03) é recusada, e que o 29/02 só
passa em ano bissexto.

### Tarefa 8 — Conflito de horário (a parte mais difícil)

Reserva existente: **10:00–11:00** na Sala Aurora. Cada caso em um dia diferente, para um não
interferir no outro:

| # | Nova reserva | Esperado | Resultado |
|---|---|---|---|
| 1 | 10:00–11:00 (igual) | 409 | 409 |
| 2 | 10:30–11:30 (parcial no fim) | 409 | 409 |
| 3 | 09:30–10:30 (parcial no início) | 409 | 409 |
| 4 | 10:15–10:45 (dentro) | 409 | 409 |
| 5 | 09:00–12:00 (envolve) | 409 | 409 |
| 6 | 11:00–12:00 (encosta depois) | 201 | 201 |
| 7 | 09:00–10:00 (encosta antes) | 201 | 201 |
| 8 | 10:00–11:00 em outra sala | 201 | 201 |
| 9 | *extra:* 10:30–11:30 pegando duas reservas | 409 | 409 |
| 10 | *extra:* a mesma pessoa repete o próprio horário | 409 | 409 |
| 11 | *extra:* os 409 não criaram reservas "fantasma" | próximo id = 12 | 12 |

```bash
$ curl -X POST http://localhost:3000/reservas -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Bruno","inicio":"2027-03-02T10:30","fim":"2027-03-02T11:30"}'
{"erro":"Conflito: a sala Sala Aurora já está reservada de 2027-03-02T10:00 até 2027-03-02T11:00 (reserva 2). Escolha outro horário ou outra sala"}  [HTTP 409]
```

### Tarefa 9 — Cancelar libera o horário

```bash
$ curl -X DELETE http://localhost:3000/reservas/1
{"mensagem":"Reserva 1 cancelada. A sala Sala Aurora está livre de 2027-03-10T10:00 até 2027-03-10T11:00","reserva":{...}}  [HTTP 200]

$ curl -X DELETE http://localhost:3000/reservas/1          # de novo
{"erro":"Reserva não encontrada: não existe reserva com id 1 (ela pode já ter sido cancelada)"}  [HTTP 404]

# mesmo intervalo, mesma sala, depois do cancelamento
$ curl -X POST http://localhost:3000/reservas -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Carla","inicio":"2027-03-10T10:00","fim":"2027-03-10T11:00"}'
{"id":3,"salaId":1,"funcionario":"Carla",...}  [HTTP 201]   ← horário liberado

# a outra reserva da sala (14:00–15:00) continua bloqueando
{"erro":"Conflito: a sala Sala Aurora já está reservada de 2027-03-10T14:00 até 2027-03-10T15:00 (reserva 2). ..."}  [HTTP 409]
```

## 6. A IA errou em algum momento?

Sim — **7 vezes**. Nenhum erro foi uma regra de negócio inventada (as lacunas do enunciado
viraram as 7 dúvidas da seção 2, decididas por mim), mas houve erros na spec, na ferramenta de
teste e em uma conclusão sobre o ambiente. A partir da Tarefa 2 pedi que todo erro fosse
registrado; os erros nº 1 e nº 4 só entraram no registro depois, ao revisar o histórico do
trabalho.

| # | Quando | O que aconteceu | Como foi percebido | Como foi corrigido | Afetou o código? |
|---|---|---|---|---|---|
| 1 | Requisitos | Dois critérios de aceite com o mesmo número ("2") no mesmo requisito | Na rodada de ajustes do Requisito 6 | Renumerou os critérios | Não — mas numeração errada quebra a ligação tarefa → requisito |
| 2 | Tarefa 1 | Para desligar o servidor, a IA usou `pkill -f 'node server.js'`, que também "casou" com o terminal do próprio teste e o encerrou; a tarefa não chegou a ser marcada | O comando terminou com erro e a tarefa continuava `[ ]` | Criou um script que liga/desliga o servidor pelo número do processo (PID), e não pelo nome | Não — só o teste |
| 3 | Tarefa 2 | O script do erro 2 guardava o PID errado (de um subshell), e o servidor continuava rodando depois do "desligar" | A própria checagem do script avisou "porta 3000 ainda ocupada" | Corrigiu o script e testou de novo que ele liberava a porta | Não — só o teste |
| 4 | Design (revelado na Tarefa 5) | O Design não previa o `salaId` ausente, que caía no 404 "Sala não encontrada" | No teste "sem salaId" da Tarefa 5 | Eu decidi corrigir: 400 com mensagem explicativa, e a spec foi atualizada (critério 3.8, Design e Tarefa 5) | **Sim** — resposta com código HTTP inadequado |
| 5 | Retomada do trabalho | Ao retomar em uma nova sessão, a IA procurou os registros de teste com um comando que não olha a pasta `/tmp` e **afirmou que os registros tinham se perdido**, sem verificar | Ao investigar a interrupção, o histórico mostrou o caminho exato, e os arquivos estavam lá | Corrigiu a informação e registrou o erro | Não |
| 6 | Correção do critério 3.8 | Montou a edição colocando o critério 8 **antes** do 7 — o mesmo tipo de erro do nº 1 | Revisando a edição antes de gravar | Refez com a ordem certa | Não (não chegou a ser gravado) |
| 7 | Início da Tarefa 8 | Ao incluir o passo novo do `salaId` na ordem de validações, não atualizou a tabela do fim do Design, que continuou dizendo "passos 1 a 5" e "passo 6" | Relendo o Design para implementar o conflito | Atualizou para "passos 1 a 6" e "passo 7" | Não — só a spec |

O erro de maior peso foi o **nº 4**: uma lacuna de especificação que só apareceu quando a tarefa
foi testada isoladamente, e que foi corrigida na spec, e não só no código. Os erros 1, 6 e 7 são
do mesmo tipo — numeração e referências internas da spec —, e foram percebidos relendo os
documentos antes de seguir.

## 7. Reflexão

Notei uma diferença enorme na compreensão do que a IA estava executando quando comparo o modelo
Spec com o simples ato de pedir para ela fazer tudo de forma genérica. No processo Spec, eu me
senti parte do trabalho: tive mais dúvidas e precisei pesquisar e questionar pontos que estavam
fora do alcance do meu conhecimento ou que estavam confusos.

De forma geral, foi uma experiência importante. Trabalhar por etapas poupou tempo, tanto para
encontrar um erro específico quanto por não precisar refazer todo o TF. Quebrar as decisões em
partes foi melhor para o meu aprendizado e resultou em respostas mais otimizadas da IA.
