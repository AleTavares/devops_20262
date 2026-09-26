# Documento de Requisitos — API de Reserva de Salas TechNova

## Introdução

API em Node.js com Express para os funcionários da TechNova reservarem salas de reunião. É
possível cadastrar salas, ver as salas, reservar uma sala para um horário, cancelar uma reserva e
listar as reservas de um funcionário. O sistema não pode permitir duas reservas da mesma sala no
mesmo horário. Os dados ficam em memória (sem banco de dados).

## Requisitos

### Requisito 1 — Cadastro de sala

**História de usuário:** Como funcionário da TechNova, quero cadastrar uma sala de reunião, para
que ela possa ser reservada.

#### Critérios de aceitação

1. QUANDO uma sala for enviada com nome válido, O sistema DEVE cadastrá-la e retornar os dados da
   sala com um identificador único.
2. SE o nome da sala estiver ausente ou vazio, ENTÃO o sistema DEVE recusar o cadastro e retornar
   uma mensagem de erro indicando que o nome é obrigatório.
3. SE já existir uma sala com o mesmo nome (sem diferenciar maiúsculas de minúsculas), ENTÃO o
   sistema DEVE recusar o cadastro e retornar uma mensagem de erro indicando que a sala já existe.

### Requisito 2 — Listagem de salas

**História de usuário:** Como funcionário, quero ver as salas cadastradas, para escolher qual
reservar.

#### Critérios de aceitação

1. QUANDO a listagem de salas for solicitada, O sistema DEVE retornar todas as salas cadastradas,
   sem filtrar por disponibilidade de horário.
2. SE não houver salas cadastradas, ENTÃO o sistema DEVE retornar uma lista vazia.

### Requisito 3 — Criação de reserva

**História de usuário:** Como funcionário, quero reservar uma sala para um horário, para garantir
o espaço da minha reunião.

#### Critérios de aceitação

1. O horário da reserva DEVE ser um **intervalo**, informado por data/hora de **início** e data/hora
   de **fim**.
2. QUANDO uma reserva for enviada com sala, funcionário, início e fim válidos, O sistema DEVE criar
   a reserva e retornar seus dados com um identificador único.
3. SE a sala informada não existir, ENTÃO o sistema DEVE recusar a reserva e retornar uma mensagem
   de erro de sala não encontrada.
4. SE o funcionário estiver ausente ou vazio, ENTÃO o sistema DEVE recusar a reserva e retornar uma
   mensagem de erro indicando que o funcionário é obrigatório.
5. SE o início ou o fim estiverem ausentes ou não forem uma data/hora válida, ENTÃO o sistema DEVE
   recusar a reserva e retornar uma mensagem de erro indicando o campo com problema.
6. SE o fim não for posterior ao início, ENTÃO o sistema DEVE recusar a reserva e retornar uma
   mensagem de erro indicando que o fim deve ser depois do início.
7. SE o início da reserva já tiver passado (anterior ao momento da solicitação), ENTÃO o sistema
   DEVE recusar a reserva e retornar uma mensagem de erro indicando que não é possível reservar
   no passado.
8. SE a sala não for informada ou não for um identificador numérico válido, ENTÃO o sistema DEVE
   recusar a reserva e retornar uma mensagem de erro indicando que o `salaId` é obrigatório e
   onde consultar os ids das salas. _(Critério incluído durante a implementação — ver Tarefa 5.)_

### Requisito 4 — Bloqueio de conflito de horário

**História de usuário:** Como funcionário, quero que o sistema impeça reservas conflitantes, para
que duas reuniões nunca sejam marcadas na mesma sala ao mesmo tempo.

#### Critérios de aceitação

1. Há **conflito** quando o intervalo da nova reserva se **sobrepõe**, total ou parcialmente, ao
   intervalo de uma reserva ativa da mesma sala — ou seja, quando o início da nova é anterior ao
   fim da existente **e** o fim da nova é posterior ao início da existente.
2. SE houver conflito, ENTÃO o sistema DEVE recusar a nova reserva e retornar um **erro claro**
   informando o conflito e o intervalo já reservado.
3. QUANDO a nova reserva apenas **encostar** em outra da mesma sala (ex.: 10:00–11:00 e
   11:00–12:00), O sistema DEVE aceitá-la, pois não há sobreposição.
4. QUANDO a reserva for para a mesma sala em um intervalo sem sobreposição, O sistema DEVE aceitá-la.
5. QUANDO a reserva for para outra sala no mesmo intervalo, O sistema DEVE aceitá-la.

### Requisito 5 — Cancelamento de reserva

**História de usuário:** Como funcionário, quero cancelar uma reserva, para liberar a sala quando
a reunião não for mais acontecer.

#### Critérios de aceitação

1. QUANDO o cancelamento de uma reserva existente for solicitado, O sistema DEVE **remover** a
   reserva e confirmar a operação.
2. SE a reserva não existir, ENTÃO o sistema DEVE retornar um erro de reserva não encontrada.
3. QUANDO uma reserva for cancelada, O sistema DEVE liberar o horário, permitindo uma nova reserva
   da mesma sala no mesmo horário.
4. SE o identificador da reserva não for um número válido, ENTÃO o sistema DEVE recusar o
   cancelamento e retornar uma mensagem de erro indicando o formato esperado e onde consultar os
   ids das reservas. _(Critério incluído durante a implementação — ver Tarefa 9.)_

### Requisito 6 — Reservas de um funcionário

**História de usuário:** Como funcionário, quero listar as minhas reservas, para acompanhar minha
agenda de reuniões.

#### Critérios de aceitação

1. O funcionário DEVE ser identificado apenas pelo **nome** (texto livre), informado na consulta.
2. QUANDO as reservas de um funcionário forem solicitadas, O sistema DEVE retornar apenas as
   reservas daquele funcionário, comparando o nome **sem diferenciar maiúsculas de minúsculas**
   (ex.: "Ana", "ana" e "ANA" são o mesmo funcionário).
3. SE o funcionário não tiver reservas, ENTÃO o sistema DEVE retornar uma lista vazia.
4. SE o funcionário não for informado na consulta, ENTÃO o sistema DEVE retornar uma mensagem de
   erro.

### Requisito 7 — Armazenamento em memória

**História de usuário:** Como desenvolvedor, quero guardar os dados em memória, para começar
simples, sem depender de um banco de dados.

#### Critérios de aceitação

1. O sistema DEVE manter salas e reservas em estruturas em memória.
2. QUANDO o servidor for reiniciado, os dados PODEM ser perdidos (comportamento aceito nesta
   versão).

## Decisões tomadas na revisão

- **Formato do "horário":** intervalo com início e fim (e não blocos fixos), porque reuniões reais
  têm duração variável.
- **Definição de conflito:** sobreposição de intervalos (e não apenas horário igual). Comparar só
  horários iguais deixaria passar reservas que se chocam parcialmente, como 10:00–11:00 e
  10:30–11:30, permitindo duas reuniões na mesma sala ao mesmo tempo.
- **"Ver as salas disponíveis":** `GET /salas` lista todas as salas cadastradas, que é a rota
  mínima pedida. Filtrar as salas livres em um intervalo fica fora do escopo desta versão, para
  não aumentar o problema além do necessário.
- **Horários no passado:** reservas cujo início já passou são recusadas, inclusive reuniões que já
  começaram. Uma reserva no passado não tem utilidade e quase sempre indica erro de digitação
  (ex.: ano errado); sem a validação, o sistema confirmaria uma reserva que nunca vai acontecer.
- **Funcionário:** identificado apenas pelo nome, como indica a rota
  `GET /reservas?funcionario=NOME` — não há cadastro de funcionários. A busca não diferencia
  maiúsculas de minúsculas, para que "Ana" e "ana" não virem pessoas diferentes por causa da
  digitação.
- **Cancelamento:** a reserva cancelada é **apagada**, e não guardada com status "cancelada". Guardar
  o status não impediria cancelamentos por engano (isso exigiria outra função, como confirmação ou
  "reativar reserva") e obrigaria a regra de conflito a ignorar as canceladas — um filtro que, se
  esquecido, manteria a sala bloqueada. Como não foi pedido histórico nem "desfazer", apagar
  mantém a regra de conflito simples e garante que cancelar libera o horário.
- **Nome da sala:** não pode repetir (sem diferenciar maiúsculas de minúsculas). Como a reserva é
  feita escolhendo a sala na listagem, duas salas com o mesmo nome deixariam o funcionário sem saber
  qual está reservando.
