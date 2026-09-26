# Processo Spec-Driven — Reserva de Salas | Gabriel Reis Cunha (RA 6325149)

> **Ferramenta de IA:** Claude Code (modelo Sonnet 5), no lugar do Kiro. Usei o mesmo método do modo Spec (Requisitos → Design → Tarefas) pela skill `/spec` do Claude Code, e eu aprovava cada fase antes de ele seguir.

## 1. Como eu dividi o problema

Eu pedi para o Claude quebrar o problema seguindo a metodologia SDD e ele dividiu em 8 partes, que listei abaixo. Depois eu revisei se as partes faziam sentido juntas e se cobriam o que o enunciado pedia, e só então aprovei.

1. Estrutura do projeto e servidor no ar
2. Cadastrar sala (com validação)
3. Listar salas
4. Criar reserva (validações básicas, **sem** conflito)
5. **Impedir conflito de horário**
6. Cancelar reserva
7. Listar reservas de um funcionário
8. README e documentação

## 2. Requisitos (o quê)

O Claude propôs a SPEC a partir do enunciado. Coloquei aqui os requisitos da parte Specify:

- Rotas mínimas do enunciado: `POST/GET /salas`, `POST /reservas`, `DELETE /reservas/:id`, `GET /reservas?funcionario=NOME`.
- Códigos HTTP explícitos: 201 criado, 400 dado inválido, 404 não encontrado, **409 conflito**.
- Fora do escopo: banco de dados, AWS, Docker e autenticação (o enunciado manda usar memória).
- **Decisão minha (questão em aberto que o Claude levantou):** o horário é um **intervalo `inicio`/`fim`**, e não um horário fixo. O Claude recomendou porque é mais realista (dá para ter conflito por sobreposição) e eu aprovei.
- **Decisão minha:** usar o Claude Code em vez do Kiro e declarar isso aqui.

Na SPEC o Claude também escreveu os critérios de aceitação (por exemplo: "uma segunda reserva no mesmo horário dá 409, e depois de cancelar a primeira ela é aceita"). Eles viraram os testes da seção 5.

## 3. Design (como)

- **Um único `server.js`** com Express e dois arrays em memória (`salas`, `reservas`). Deixei simples de propósito para diminuir a chance de erro do agente, mas atendendo tudo o que foi pedido.
- **Modelo:** sala `{id, nome}`; reserva `{id, salaId, funcionario, inicio, fim}` (datas em ISO 8601).
- **Regra de conflito isolada** na função `temConflito(salaId, inicio, fim)`: colide quando `novo.inicio < existente.fim && novo.fim > existente.inicio` na mesma sala. Horários que só se encostam (14–16 e 16–17) **não** colidem.
- **Ordem das validações no `POST /reservas`:** dados (400), depois se a sala existe (404), depois conflito (409).
- **Testes:** `curl` de verdade contra a API rodando, sem framework de teste, como pede o TF.

## 4. Tarefas (os passos pequenos)

| # | Tarefa | Commit |
|---|--------|--------|
| T0 | Estrutura inicial: `.gitignore`, `package.json`, `npm install` | `chore(aula-07): estrutura inicial...` |
| T1 | Servidor Express base com `GET /saude` | `feat(aula-07): servidor express base...` |
| T2 | `POST /salas` com nome obrigatório | `feat(aula-07): cadastro de salas...` |
| T3 | `GET /salas` | `feat(aula-07): listagem de salas` |
| T4 | `POST /reservas` sem conflito (funcionário, datas, sala existente) | `feat(aula-07): criação de reservas...` |
| T5 | Bloqueio de conflito de horário (`temConflito` + 409) | `feat(aula-07): bloqueio de conflito...` |
| T6 | `DELETE /reservas/:id` | `feat(aula-07): cancelamento de reservas` |
| T7 | `GET /reservas?funcionario=NOME` | `feat(aula-07): listagem de reservas por funcionário` |
| T8 | `README.md` (como rodar, rotas, exemplos) | `docs(aula-07): README...` |
| T9 | Este `processo-spec.md` | `docs(aula-07): processo-spec...` |

Fiz um commit por tarefa, sempre **depois** de testar aquela tarefa com `curl`.

## 5. Implementação e validação

Colei abaixo a saída de algumas tarefas. Essas saídas foram geradas pelo Claude quando ele rodou os testes da API (servidor na porta 3100), e eu revisei o resultado no final.

### T2: `POST /salas`

```
# válida
{"id":1,"nome":"Sala Alfa"} [201]
# sem nome
{"erro":"O campo \"nome\" é obrigatório."} [400]
# nome em branco ("   ")
{"erro":"O campo \"nome\" é obrigatório."} [400]
# sem body
{"erro":"O campo \"nome\" é obrigatório."} [400]
```
**Como confirmei:** o caso válido deu 201 e os três inválidos deram 400 com mensagem clara.

### T4: `POST /reservas` (antes do conflito)

```
# válida
{"id":1,"salaId":1,"funcionario":"Ana","inicio":"2026-10-01T17:00:00.000Z","fim":"2026-10-01T18:00:00.000Z"} [201]
# sala inexistente
{"erro":"Sala 99 não encontrada."} [404]
# sem funcionário
{"erro":"O campo \"funcionario\" é obrigatório."} [400]
# data inválida ("abc")
{"erro":"Os campos \"inicio\" e \"fim\" devem ser datas válidas (...)."} [400]
# fim antes do início
{"erro":"O \"fim\" deve ser posterior ao \"inicio\"."} [400]
```
**Como confirmei:** cada tipo de dado errado caiu no código certo (400 ou 404). Nesta tarefa apareceu um erro real com as datas, explicado na seção 6.

### T5: bloqueio de conflito

Base: sala Alfa reservada por Ana das 14h às 16h.

| Cenário | Esperado | Obtido |
|---------|----------|--------|
| idêntica (14–16) | 409 | **409** |
| sobreposição no início (13–15) | 409 | **409** |
| sobreposição no fim (15–17) | 409 | **409** |
| contida (14:30–15:30) | 409 | **409** |
| engloba (13–17) | 409 | **409** |
| encosta no fim (16–17) | 201 | **201** |
| encosta no início (12–14) | 201 | **201** |
| **outra sala**, mesmo horário | 201 | **201** |

```
{"erro":"Conflito de horário: a sala \"Sala Alfa\" já está reservada por Ana de 2026-10-01T14:00:00.000Z até 2026-10-01T16:00:00.000Z (reserva 1)."} [409]
```
**Como confirmei:** testei os casos de borda (encostar, conter, englobar e outra sala), que são onde essa regra costuma errar.

### T6: `DELETE /reservas/:id`

```
# criar reserva 1              -> [201]
# repetir o mesmo horário      -> [409]
# DELETE /reservas/1           -> {"mensagem":"Reserva cancelada.",...} [200]
# DELETE de novo               -> {"erro":"Reserva 1 não encontrada."} [404]
# repetir o horário de novo    -> {"id":2,...} [201]
```
**Como confirmei:** depois de cancelar, o mesmo horário que dava 409 voltou a ser aceito. Esse era o requisito principal do cancelamento.

## 6. O Claude errou em algum momento?

Errou em coisas pequenas, principalmente de interpretação, nada grave no código final. Os casos que aconteceram:

1. **T1: teste que não mostrou nada.** O primeiro `curl` voltou vazio. Não era erro do código: o `express` demorou para carregar na primeira vez e o `curl -s` escondeu o erro de conexão. Ajustei o script para esperar a porta abrir.
2. **T4: as datas.** O Claude supôs que a resposta devolveria o horário igual ao enviado. Mandei `14:00:00` sem fuso horário e voltou `17:00:00.000Z`, porque o JavaScript usa o fuso do servidor (UTC−3) quando não tem fuso na data. A regra de conflito continua certa, mas o resultado mudaria de máquina para máquina. Deixei simples: a mensagem de erro e o README pedem para enviar o fuso (`...Z`).
3. **T5: erro no meu teste, não no código.** Testei o caso "contida" com `fim` igual a `inicio` (15–15), e a API respondeu 400 em vez de 409. Se eu só olhasse "deu erro, então ok", teria dado o caso por testado sem ter testado a regra. Refiz com 14:30–15:30 e deu 409.
4. **T8: porta ocupada.** Ao testar o README, a porta 3000 já estava ocupada por outro programa (um `kubectl port-forward` do minikube) e as respostas eram 404 de outro servidor. Percebi porque o `/saude` retornou "Cannot GET". Rodei com `PORT=3100`, que o README já documenta.

Nenhum desses erros chegou no código final, porque cada tarefa era pequena e foi testada antes do commit. A metodologia SDD ajudou bastante. Mesmo sem passar muitos detalhes, quando ela entra no harness o agente já trabalha nesse formato (spec, plano, tarefas).

## 7. Reflexão

Não testei o "jeito errado" de verdade, então isto é o que eu espero que aconteceria. Se eu pedisse tudo de uma vez, sem o passo a passo e sem revisão, o Claude poderia assumir o que não sabe e implementar o que ele acha certo. No final eu teria um código que ninguém revisou, com comportamento difícil de prever, e erros que só apareceriam depois.

O que eu aprendi:
Dividir uma tarefa ggande em partes gerenciaveis ajuda muito o claude a programar.
E que se você não souber o que está fazendo não adianta esperar que ele saiba
