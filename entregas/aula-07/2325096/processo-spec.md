# Processo Spec-Driven — Reserva de Salas | Eloísa Brandão (2325096)

## 1. Como dividi o problema

Trabalhei em etapas para revisar primeiro o comportamento esperado e depois implementar e validar partes pequenas da API:

1. Definir os requisitos observáveis das salas e reservas.
2. Revisar o design da API e as regras para validar e normalizar horários.
3. Implementar o parser de horário com fuso explícito.
4. Corrigir mensagens e validações das rotas de cadastro de salas e reservas.
5. Acrescentar testes para horários inválidos, normalização, conflitos entre fusos e campos obrigatórios.
6. Validar as mensagens restantes, executar a suíte e fazer uma verificação manual do fluxo de reserva e cancelamento.

Essa ordem permitiu tratar o horário e o conflito como regras próprias, sem pedir a implementação inteira de uma só vez.

## 2. Requisitos — o que

Parti do enunciado do TF e revisei com o Kiro os requisitos da API. A versão aprovada define:

- `POST /salas` cria uma sala com `nome` obrigatório; nomes repetidos são permitidos.
- `GET /salas` lista salas na ordem de criação.
- `POST /reservas` recebe `salaId`, `funcionario` e `horario`; sala, funcionário e horário são obrigatórios, e a sala precisa existir.
- `horario` deve seguir `YYYY-MM-DDTHH:mm:ss` com fuso explícito `Z` ou offset válido. A API devolve o horário em UTC.
- Duas reservas ativas da mesma sala não podem representar o mesmo instante, inclusive quando os fusos enviados são diferentes.
- `GET /reservas?funcionario=NOME` lista reservas ativas com comparação de nome sem diferenciar maiúsculas e minúsculas.
- `DELETE /reservas/:id` cancela reserva ativa; reserva inexistente ou já cancelada retorna `404`.
- IDs são UUIDs gerados pelo servidor; os dados ficam somente em memória.
- Respostas de erro usam JSON no formato `{ "erro": "..." }`; cancelamento bem-sucedido retorna `204` sem corpo.

Durante a revisão, ajustei as convenções para usar nomes de rota e campos em português, explicitei o fuso obrigatório, defini a normalização para UTC e esclareci o comportamento de nomes repetidos, comparação do funcionário e cancelamento.

## 3. Design — como

O design revisado manteve a implementação pequena: uma aplicação Express em `server.js`, duas coleções em memória (`salas` e `reservas`) e UUIDs gerados com `node:crypto`. A função auxiliar `parsearHorario` valida o formato e o calendário antes de normalizar o instante para UTC. Os testes usam `node:test`, `fetch` e um servidor local com porta efêmera.

Uma revisão importante foi necessária para a data. `Date.parse` sozinho pode aceitar horários sem fuso, então não bastava para atender ao requisito. Também corrigimos a validação semântica para comparar os componentes locais da data antes da conversão para UTC; assim, um horário válido perto da meia-noite não é rejeitado só porque a conversão muda o dia. A validação limita o offset a `±14:00` e rejeita datas impossíveis, como 30 de fevereiro.

## 4. Tarefas — passos pequenos

As tarefas executadas foram:

1. Implementar e exportar `parsearHorario`; validar entradas no REPL.
2. Corrigir a mensagem de campo obrigatório em `POST /salas`.
3. Separar as validações de `POST /reservas`, aplicar o parser e corrigir mensagens de sala inexistente e conflito.
4. Corrigir as mensagens de `GET /reservas` sem funcionário e `DELETE /reservas/:id` inexistente.
5. Testar horários inválidos: sem fuso, sem hora, texto inválido, mês e hora fora da faixa, data impossível e offset `+14:30`.
6. Testar horários válidos e a normalização para UTC, incluindo virada de dia e offset máximo.
7. Testar conflito entre representações equivalentes em fusos distintos e disponibilidade depois do cancelamento.
8. Testar individualmente os campos obrigatórios de `POST /reservas` e sala inexistente.
9. Verificar as mensagens de erro de `POST /salas`, `GET /reservas` e `DELETE /reservas/:id`.

## 5. Implementação e validação

As alterações foram feitas tarefa por tarefa. Os resultados abaixo distinguem os testes executados dos exemplos manuais observados.

| Etapa | Verificação | Resultado observado |
|---|---|---|
| Parser (`parsearHorario`) | REPL com 9 casos: horários UTC e com offsets, virada de dia, offset máximo, data impossível, offset proibido, ausência de fuso, mês inválido e texto aleatório | Os 9 resultados corresponderam ao esperado; a suíte existente passou com 3/3. |
| Mensagem de `POST /salas` | Envio de nome composto por espaços com `Invoke-RestMethod` e corpo JSON gerado por `ConvertTo-Json` | Resposta de erro JSON: `{"erro":"O campo nome é obrigatório."}`. |
| Validações e mensagens de reserva | Suíte executada após as alterações de `POST /reservas`, `GET /reservas` e `DELETE /reservas/:id` | 3/3 testes passaram nas etapas iniciais. |
| Horários inválidos | 7 entradas inválidas enviadas pela rota de criação | Suíte passou com 4/4 testes. |
| Normalização UTC | 5 horários válidos, incluindo offsets positivos/negativos e virada de dia | Suíte passou com 5/5 testes; os valores UTC esperados foram conferidos. |
| Conflitos e cancelamento | Dois pares de horários equivalentes em fusos diferentes; cancelamento e nova reserva do mesmo instante | Suíte passou com 6/6 testes. |
| Campos e mensagens | Campos obrigatórios validados individualmente, sala inexistente e mensagens exatas das rotas | Suíte passou com 7/7 testes. |
| Verificação final local | `node --test`, executado na pasta desta entrega | 7 testes passaram, 0 falharam. |

### Evidência 1 — parser de horário (Task 1)

Executei o parser exportado diretamente, sem iniciar o servidor:

```powershell
node -e "const { parsearHorario } = require('./server'); const casos = ['2026-10-12T14:00:00Z', '2026-10-12T00:30:00+01:00', '2026-10-12T14:00:00-03:00', '2026-10-12T00:00:00+14:00', '2026-02-30T10:00:00Z', '2026-10-12T00:00:00+14:30', '2026-10-12T14:00:00', '2026-13-01T10:00:00Z', 'nao-e-data']; for (const horario of casos) console.log(horario + ' => ' + parsearHorario(horario));"
```

Saída observada:

```text
2026-10-12T14:00:00Z => 2026-10-12T14:00:00.000Z
2026-10-12T00:30:00+01:00 => 2026-10-11T23:30:00.000Z
2026-10-12T14:00:00-03:00 => 2026-10-12T17:00:00.000Z
2026-10-12T00:00:00+14:00 => 2026-10-11T10:00:00.000Z
2026-02-30T10:00:00Z => null
2026-10-12T00:00:00+14:30 => null
2026-10-12T14:00:00 => null
2026-13-01T10:00:00Z => null
nao-e-data => null
```

Os horários válidos foram normalizados para UTC e as entradas sem fuso, impossíveis ou fora do offset aceito retornaram `null`.

### Evidência 2 — nome obrigatório em `POST /salas` (Task 2)

Com o servidor da entrega ativo, enviei um nome composto apenas por espaços:

```powershell
$body = @{ nome = '   ' } | ConvertTo-Json -Compress
try {
  Invoke-RestMethod -Uri 'http://localhost:3100/salas' -Method Post -ContentType 'application/json' -Body $body
} catch {
  $_.ErrorDetails.Message
}
```

A chamada retornou HTTP `400` e a saída observada foi:

```json
{"erro":"O campo nome é obrigatório."}
```

### Evidência 3 — criar, consultar e cancelar reserva (Tasks 3 e 7)

Com a versão atual da API ativa na porta `3101`, executei o fluxo abaixo no PowerShell:

```powershell
$sala = Invoke-RestMethod -Uri 'http://localhost:3101/salas' -Method Post -ContentType 'application/json' -Body (@{ nome = 'Sala Reunião' } | ConvertTo-Json -Compress)
$reserva = Invoke-RestMethod -Uri 'http://localhost:3101/reservas' -Method Post -ContentType 'application/json' -Body (@{ salaId = $sala.id; funcionario = 'Carlos'; horario = '2026-11-15T09:00:00Z' } | ConvertTo-Json -Compress)
$antes = @(Invoke-RestMethod -Uri 'http://localhost:3101/reservas?funcionario=carlos')
"Reservas antes: $($antes.Count)"
$delete = Invoke-WebRequest -Uri "http://localhost:3101/reservas/$($reserva.id)" -Method Delete
"Status do DELETE: $([int]$delete.StatusCode)"
$depois = Invoke-RestMethod -Uri 'http://localhost:3101/reservas?funcionario=carlos'
if ($null -eq $depois) { $quantidade = 0 } else { $quantidade = @($depois).Count }
"Reservas depois: $quantidade"
```

Saída observada:

```text
Reservas antes: 1
Status do DELETE: 204
Reservas depois: 0
```

No Windows PowerShell, a resposta JSON vazia `[]` é convertida em `$null`; por isso, a contagem posterior trata `$null` como zero. A consulta confirmou que a reserva cancelada não continuou ativa.

### Evidência 4 — suíte de testes

Executei `node --test` na pasta do projeto depois das alterações. O resumo real da execução foi:

```text
ℹ tests 7
ℹ pass 7
ℹ fail 0
```

A suíte inclui casos para cadastro/listagem, filtros, cancelamento, validação de horários, normalização UTC, conflitos equivalentes entre fusos, campos obrigatórios e mensagens de erro.

Para repetir os testes automatizados:

```bash
npm test
```

Para iniciar a API:

```bash
npm start
```

No PowerShell, se a política de execução bloquear `npm.ps1`, use `npm.cmd start`. O processo mantém os dados em memória; reiniciá-lo apaga as salas e reservas.

## 6. A IA errou em algum momento?

Na revisão do design, identificamos uma lacuna na primeira abordagem para o horário: usar somente `Date.parse` não garante a rejeição de entradas sem fuso explícito. Também corrigimos uma validação que compararia o dia em UTC com o dia local informado e poderia rejeitar horários válidos perto da meia-noite. A solução foi validar o calendário usando os componentes locais e só depois normalizar o instante.

Na validação manual, a primeira chamada com `curl.exe` não enviou um corpo JSON que a API conseguisse interpretar. Troquei o envio por `Invoke-RestMethod` com `ConvertTo-Json`, e então confirmei a mensagem esperada. Também encontrei um servidor antigo ocupando a porta 3100; iniciei o código atualizado na porta 3101. Essas situações reforçaram a importância de verificar a resposta real e confirmar qual processo está atendendo a requisição.

## 7. Reflexão

Dividir o trabalho ajudou a localizar ambiguidades antes de elas se espalharem pelo código. A regra de horário, por exemplo, precisou de decisões explícitas sobre fuso, datas impossíveis e equivalência em UTC. Os testes pequenos mostraram se cada alteração preservava o que já funcionava, e a validação manual revelou detalhes do ambiente PowerShell e do servidor que os testes automatizados não mostram. Se eu tivesse pedido a API inteira de uma vez, seria mais difícil perceber qual decisão causou um comportamento errado. Aprendi a revisar as propostas da IA, transformar requisitos em verificações concretas e conferir as respostas antes de considerar uma tarefa concluída.


