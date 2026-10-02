# Processo Spec-Driven — Reserva de Salas | Matheus Mantovani (1120245)

## 1. Como eu dividi o problema

O problema da TechNova envolve várias responsabilidades distintas. Em vez de tentar implementar tudo de uma vez, quebrei o sistema em seis partes independentes, cada uma com entrada, saída e critério de validação próprios:

1. **Cadastro de salas** — criar uma sala com nome único (validação de campo vazio e deduplicação case-insensitive)
2. **Listagem de salas** — retornar o array completo de salas cadastradas
3. **Criação de reserva** — validar campos, verificar existência da sala e detectar conflito de horário antes de persistir
4. **Cancelamento de reserva** — remover pelo ID e liberar o horário para novas reservas
5. **Listagem de reservas com filtro** — retornar todas as reservas ou filtrar pelo nome do funcionário via query string
6. **Regra de negócio central: prevenção de conflito de horário** — nenhuma sala pode ter duas reservas ativas no mesmo horário exato (comparação por igualdade estrita de strings)

Essa divisão deixou claro que o item 6 não é um endpoint separado, mas uma regra que atravessa os itens 3, 4 e 5 — o que precisava aparecer explicitamente no design para não ser esquecido.

---

## 2. Requisitos (o quê)

O Kiro gerou seis requisitos no formato EARS/INCOSE (Event-Action-Response Statements), cada um com uma User Story e critérios de aceitação verificáveis:

| # | Requisito | Critérios principais |
|---|-----------|----------------------|
| 1 | Cadastro de Salas | Nome obrigatório (400), unicidade case-insensitive (409), ID sequencial (201) |
| 2 | Listagem de Salas | Retorna array completo (200), lista vazia quando não há salas |
| 3 | Criação de Reservas | Campos obrigatórios (400), sala existente (404), conflito de horário (409), formato YYYY-MM-DD HH:MM (400), persistência (201) |
| 4 | Cancelamento de Reservas | Remove por ID (200), ID inexistente (404), libera horário após remoção |
| 5 | Listagem de Reservas | Retorna todas ou filtra por funcionário (200), lista vazia quando não há resultados |
| 6 | Prevenção de Conflito | Verificação obrigatória antes de cada criação, comparação por igualdade estrita de strings, horário liberado após cancelamento |

Os requisitos gerados estavam bem alinhados com o enunciado do TF — não precisei corrigir nenhuma regra de negócio. O único ajuste foi de estilo: padronizei as mensagens de erro em português antes de começar a implementação, para garantir consistência nas respostas da API.

---

## 3. Design (como)

O design optou por um **arquivo único (`server.js`)**, o que é adequado ao escopo do projeto. A separação de responsabilidades é feita por funções, não por arquivos:

**Estrutura de dados em memória:**
```javascript
let salas = [];
let reservas = [];
let proximoIdSala = 1;
let proximoIdReserva = 1;
```
Arrays simples com contadores sequenciais — suficientes para dados em memória, previsíveis e fáceis de reiniciar nos testes.

**Três funções puras (sem efeitos colaterais):**
- `ehStringNaoVazia(valor)` — verifica se o valor é uma string com ao menos um caractere não-espaço
- `ehHorarioValido(horario)` — valida o formato via regex `/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/`
- `existeConflito(salaId, horario)` — busca reserva ativa com o mesmo par `(salaId, horario)`

Funções puras facilitam testes unitários diretos, sem depender de HTTP.

**Padrão de erros consistente:** todos os erros retornam `{ "erro": "mensagem descritiva em português" }` com o status HTTP correspondente.

**Decisão de não usar banco de dados:** mantida conforme o enunciado. Os dados sobrevivem apenas enquanto o processo Node.js está rodando — reiniciar o servidor limpa o estado, o que é aceitável para o escopo do TF.

---

## 4. Tarefas (os passos pequenos)

O Kiro decompôs a implementação em 7 tarefas top-level, cada uma com subtarefas verificáveis:

1. **Configurar projeto e estrutura base** — `package.json`, `.gitignore`, `server.js` com Express mínimo, scripts `start` e `test`
2. **Repositório em memória e utilitários** — arrays, contadores e as três funções puras (`ehStringNaoVazia`, `ehHorarioValido`, `existeConflito`)
3. **Endpoints de Salas** — `POST /salas` (com validação e deduplicação) e `GET /salas`
4. **Checkpoint — Salas funcionando** — validação manual com `curl` antes de avançar para reservas
5. **Endpoints de Reservas** — `POST /reservas` (validação + conflito), `DELETE /reservas/:id`, `GET /reservas` (com filtro)
6. **Checkpoint final** — todos os endpoints de reservas testados manualmente com `curl`
7. **README e processo-spec.md** — documentação de instalação, endpoints e processo

Essa ordem garantiu que cada tarefa dependia apenas de código já funcionando: as salas precisavam existir antes das reservas, e o verificador de conflito precisava existir antes do endpoint de criação de reserva.

---

## 5. Implementação e validação

### Tarefa 3 — POST /salas: criar sala válida

Após implementar o handler `criarSala` com validação de campo e verificação de duplicidade:

```bash
curl -s -X POST http://localhost:3001/salas \
  -H "Content-Type: application/json" \
  -d '{"nome":"Sala Alfa"}'
```

Resposta (HTTP 201):
```json
{"id":1,"nome":"Sala Alfa"}
```

**Confirmação:** sala criada com `id=1` e nome preservado. Em seguida, validei a rejeição de nome vazio:

```bash
curl -s -X POST http://localhost:3001/salas \
  -H "Content-Type: application/json" \
  -d '{"nome":""}'
```

Resposta (HTTP 400):
```json
{"erro":"O campo 'nome' é obrigatório e não pode ser vazio."}
```

E a rejeição de nome duplicado (tentativa de criar "Sala Alfa" novamente):

Resposta (HTTP 409):
```json
{"erro":"Já existe uma sala com esse nome."}
```

---

### Tarefa 5 — POST /reservas: detecção de conflito de horário

Com a Sala Alfa criada (`id=1`), criei a primeira reserva:

```bash
curl -s -X POST http://localhost:3001/reservas \
  -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Ana Lima","horario":"2026-10-15 14:00"}'
```

Resposta (HTTP 201):
```json
{"id":1,"salaId":1,"funcionario":"Ana Lima","horario":"2026-10-15 14:00"}
```

Em seguida, tentei criar uma segunda reserva para o mesmo par `(salaId=1, horario="2026-10-15 14:00")`:

```bash
curl -s -X POST http://localhost:3001/reservas \
  -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Carlos Souza","horario":"2026-10-15 14:00"}'
```

Resposta (HTTP 409):
```json
{"erro":"Já existe uma reserva para essa sala nesse horário."}
```

**Confirmação:** o `existeConflito` detectou corretamente o conflito. A reserva de Carlos Souza não foi persistida — verificado logo depois com `GET /reservas`, que retornou apenas a reserva de Ana Lima.

---

### Tarefa 5 — DELETE /reservas/1 e verificação de liberação do horário

Cancelei a reserva de Ana Lima:

```bash
curl -s -X DELETE http://localhost:3001/reservas/1
```

Resposta (HTTP 200):
```json
{"mensagem":"Reserva cancelada com sucesso."}
```

Imediatamente verifiquei que o repositório ficou vazio:

```bash
curl -s http://localhost:3001/reservas
```

Resposta (HTTP 200):
```json
[]
```

**Confirmação:** reserva removida e horário liberado. O `existeConflito` passaria a retornar `false` para o mesmo par `(salaId=1, horario="2026-10-15 14:00")`, permitindo uma nova reserva — o que valida o Requisito 4.3 e 6.3.

---

### Tarefa 5 — GET /reservas?funcionario=: filtragem por funcionário

Com múltiplas reservas no sistema, confirmei que o filtro retorna apenas as reservas do funcionário correto:

```bash
curl -s "http://localhost:3001/reservas?funcionario=Ana%20Lima"
```

Resposta (HTTP 200):
```json
[{"id":1,"salaId":1,"funcionario":"Ana Lima","horario":"2026-10-15 14:00"}]
```

**Confirmação:** somente as reservas de "Ana Lima" foram retornadas. Reservas de outros funcionários não apareceram na lista.

---

## 6. A IA errou em algum momento?

Não houve alucinação técnica — o código gerado funcionou sem erros de sintaxe e as rotas foram implementadas com a lógica correta desde o início.

Houve, porém, um comportamento que exigiu atenção: o Kiro antecipou parte da implementação já na **Tarefa 1** (configuração base), incluindo mais do que o mínimo necessário para aquele passo. Isso foi positivo em termos de resultado final, mas poderia ter gerado confusão se eu não tivesse validado cada etapa individualmente — a lógica de uma tarefa posterior poderia ter aparecido incompleta ou sem o contexto correto.

O método Spec-Driven ajudou justamente aqui: como cada tarefa tinha critérios de aceitação definidos (ex.: "retornar 409 com mensagem X"), foi possível verificar se o que foi gerado realmente satisfazia aquele critério específico, sem assumir que "parece certo" era suficiente. Quando a Tarefa 2.1 pediu as funções puras, eu pude confirmar no `server.js` que `ehStringNaoVazia`, `ehHorarioValido` e `existeConflito` estavam presentes e com a implementação correta, independentemente do que mais tivesse sido gerado junto.

---

## 7. Reflexão

Se eu tivesse pedido à IA "crie uma API de reserva de salas com todas essas funcionalidades", dois problemas quase certamente teriam ocorrido:

**Alucinação por janela de contexto**: com tudo sendo gerado de uma vez, a IA precisaria manter em mente a validação de salas, o conflito de reservas, o cancelamento e o filtro por funcionário simultaneamente. É nesse cenário que detalhes somem — a verificação de duplicidade de sala (case-insensitive), por exemplo, é o tipo de requisito que desaparece quando há muita coisa para gerar ao mesmo tempo.

**Ausência de validação incremental**: sem checkpoints, eu só descobriria que o conflito de horário estava errado (ou ausente) quando tentasse testar o sistema completo — muito mais difícil de depurar do que descobrir no passo específico da Tarefa 5.

O fluxo Spec-Driven forçou uma separação entre **o quê** (Requisitos) e **como** (Design) antes de qualquer linha de código. Esse intervalo de planejamento é o que diferencia usar IA como copiloto de usar IA como atalho. No copiloto, você define o destino e valida cada trecho do caminho; no atalho, você cruza os dedos e descobre os problemas no final.

A decomposição em tarefas pequenas também serviu como **harness de contexto**: cada tarefa era pequena o suficiente para caber bem na janela de atenção da IA, sem concorrer com os detalhes de outras partes do sistema. O resultado foi código mais preciso, mensagens de erro mais consistentes e zero necessidade de voltar e corrigir lógica de negócio já implementada.

O aprendizado principal: a dificuldade de dividir um problema não está na técnica — está em resistir à tentação de começar a implementar antes de entender o que precisa ser implementado. O modo Spec do Kiro cria um atrito produtivo que força essa parada.
