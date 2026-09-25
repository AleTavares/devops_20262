# Processo Spec-Driven — Reserva de Salas | Gabriel Reis Cunha (RA 6325149)

> **Ferramenta de IA:** Claude Code (modelo Sonnet 5), **não o Kiro**. O método foi o mesmo do modo Spec do Kiro (Requisitos → Design → Tarefas, com aprovação humana entre as fases), conduzido na skill `/spec` do Claude Code. Eu (Gabriel) aprovei cada fase antes de a IA seguir; a IA escreveu o código e rodou os testes.

## 1. Como eu dividi o problema

O enunciado é um problema "grande" (salas, reservas, conflito, cancelamento, consulta). Em vez de pedir tudo de uma vez, quebrei em **8 partes**, da mais simples para a mais arriscada, cada uma dependendo só das anteriores:

1. Estrutura do projeto e servidor no ar
2. Cadastrar sala (com validação)
3. Listar salas
4. Criar reserva (validações básicas, **sem** conflito)
5. **Impedir conflito de horário** (isolada porque é a parte mais difícil)
6. Cancelar reserva
7. Listar reservas de um funcionário
8. README e documentação

O ponto principal da divisão foi **separar a criação da reserva (4) do bloqueio de conflito (5)**. Se as duas viessem juntas, um erro de teste não diria se a falha estava na validação dos dados ou na regra de sobreposição.

## 2. Requisitos (o quê)

A IA propôs a SPEC a partir do enunciado. O que ela definiu, e o que **eu decidi/aprovei**:

- Rotas mínimas do enunciado: `POST/GET /salas`, `POST /reservas`, `DELETE /reservas/:id`, `GET /reservas?funcionario=NOME`.
- Códigos HTTP explícitos: 201 criado, 400 dado inválido, 404 não encontrado, **409 conflito**.
- Fora do escopo: banco de dados, AWS, Docker, autenticação (o enunciado manda usar memória).
- **Decisão minha (questão em aberto que a IA levantou):** o horário será um **intervalo `inicio`/`fim`**, e não um "slot" fixo. A IA recomendou por ser mais realista (conflito por sobreposição) e eu aprovei.
- **Decisão minha:** usar o Claude Code em vez do Kiro e declarar isso aqui.

Na SPEC a IA também listou critérios de aceitação verificáveis (ex.: "uma segunda reserva no mesmo horário devolve 409; depois do DELETE da primeira, é aceita"). Eles viraram os testes da seção 5.

## 3. Design (como)

- **Um único `server.js`** com Express e dois arrays em memória (`salas`, `reservas`). Simplifiquei de propósito: separar em rotas/serviços/repositórios seria over-engineering para 5 rotas em memória.
- **Modelo:** sala `{id, nome}`; reserva `{id, salaId, funcionario, inicio, fim}` (datas em ISO 8601).
- **Regra de conflito isolada** na função `temConflito(salaId, inicio, fim)`:
  colide quando `novo.inicio < existente.fim && novo.fim > existente.inicio` na mesma sala. Horários que só **se encostam** (14–16 e 16–17) **não** colidem.
- **Ordem das validações no `POST /reservas`:** dados (400) → sala existe (404) → conflito (409).
- **Testes:** `curl` real contra a API rodando (sem framework de teste), como pede o TF.

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
| T9 | Este `processo-spec.md` | `docs(aula-07): processo-spec` |

Um commit por tarefa, cada um só **depois** da validação por `curl` daquela tarefa.

## 5. Implementação e validação

As saídas abaixo são reais (servidor rodando na porta 3100).

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
Confirmei os dois lados: o caso válido devolve 201 e os três inválidos (ausente, só espaços, sem corpo) devolvem 400 com mensagem clara.

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
Nesta tarefa apareceu um problema real (ver seção 6, item 2).

### T5: bloqueio de conflito (tarefa isolada)

Base: sala Alfa reservada por Ana das 14h às 16h.

| Cenário | Resultado esperado | Obtido |
|---------|--------------------|--------|
| idêntica (14–16) | 409 | **409** |
| sobreposição no início (13–15) | 409 | **409** |
| sobreposição no fim (15–17) | 409 | **409** |
| contida (14:30–15:30) | 409 | **409** |
| engloba (13–17) | 409 | **409** |
| encosta no fim (16–17) | 201 | **201** |
| encosta no início (12–14) | 201 | **201** |
| **outra sala**, mesmo horário | 201 | **201** |

Exemplo da mensagem de erro:
```
{"erro":"Conflito de horário: a sala \"Sala Alfa\" já está reservada por Ana de 2026-10-01T14:00:00.000Z até 2026-10-01T16:00:00.000Z (reserva 1)."} [409]
```

### T6: `DELETE /reservas/:id` (o horário volta a ficar livre)

```
# cria reserva 1              -> [201]
# repetir o mesmo horário     -> [409]
# DELETE /reservas/1          -> {"mensagem":"Reserva cancelada.",...} [200]
# DELETE de novo              -> {"erro":"Reserva 1 não encontrada."} [404]
# DELETE id 999               -> [404]
# horário liberado: repetir   -> {"id":2,...} [201]
```
O último passo prova o requisito principal: depois de cancelar, o mesmo horário que dava 409 volta a ser aceito.

### T7: `GET /reservas?funcionario=NOME`

Com reservas de Ana (2) e Bia (1): `?funcionario=Ana` devolve as 2 de Ana; `?funcionario=bia` (minúsculo) devolve a de Bia; `?funcionario=Carlos` devolve `[]`; sem parâmetro lista as 3. Depois de cancelar uma reserva de Ana, o filtro passa a mostrar só a restante.

### T8: o README funciona do zero

Copiei o projeto (sem `node_modules`) para uma pasta limpa, rodei `npm install` e executei os 6 exemplos `curl` do README exatamente como escritos. Todos responderam como documentado (201, 200, 201, 409, 200, 200).

## 6. A IA errou em algum momento?

Sim, em pequenos pontos. Nenhum foi uma "alucinação" grande, e acho que foi por causa da divisão em tarefas pequenas, mas os deslizes aconteceram:

1. **T1: validação vazia enganosa.** O primeiro `curl` não mostrou nada. Não era bug do código: o `require('express')` levou cerca de 8 s na primeira execução (pasta em `/mnt/c` no WSL) e o script de teste só esperava 1 s. O `curl -s` escondeu o erro de conexão. Corrigi o script para esperar a porta abrir. **Lição: teste que não mostra nada não prova nada.**
2. **T4: suposição errada sobre datas.** A IA assumiu que a resposta devolveria o horário igual ao enviado. Enviei `14:00:00` (sem fuso) e voltou `17:00:00.000Z`, porque o JavaScript interpreta data sem fuso no fuso do servidor (UTC−3). A regra de conflito continua consistente, mas o resultado dependeria da máquina. Decisão simples (KISS): sem parser próprio; a mensagem de erro e o README orientam a enviar o fuso explícito (`...Z`).
3. **T5: erro no teste, não no código.** O caso "contida" foi escrito com `fim` igual a `inicio` (15–15), e a API respondeu 400 em vez de 409. Se eu só olhasse "deu erro, ok" teria dado o caso por validado sem testar a regra. Refiz com 14:30–15:30 e deu 409. **Lição: conferir se o erro é o erro esperado, não qualquer erro.**
4. **T8: porta ocupada.** Ao validar o README, a porta 3000 já estava ocupada por um `kubectl port-forward` de outra atividade e as respostas eram 404 de outro servidor. Percebi porque `/saude` retornou "Cannot GET". Rodei com `PORT=3100`, que o README já documentava.

Em nenhum caso o erro chegou ao código final: cada um foi pego porque a tarefa era pequena e a validação foi feita antes do commit.

## 7. Reflexão

**O "jeito errado" (pedir tudo de uma vez):** não cheguei a testar, então o que segue é uma expectativa, não um experimento. Acredito que o pedido "faça a API de reservas completa" traria as cinco rotas de uma vez, e um defeito na regra de sobreposição ficaria misturado com validação, ids e filtro. Com tudo pronto, um `409` errado ou ausente seria difícil de isolar. Nas tarefas pequenas, os quatro tropeços acima ficaram cada um no seu lugar.

**O que aprendi:**
- Isolar a parte difícil (conflito de horário) em uma tarefa própria, com casos de borda (encostar, conter, englobar, outra sala), deu confiança real na regra.
- A validação por tarefa só vale se eu conferir **qual** resposta veio, não apenas se "funcionou".
- A SPEC aprovada antes do código deixou as decisões (intervalo início/fim, códigos HTTP) explícitas e curtas de revisar.
- Usar a IA como copiloto significa que eu decido e aprovo cada fase; ela executa e testa, e eu leio a saída real antes de aceitar.
