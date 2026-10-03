# Documento de Design — API de Reserva de Salas TechNova

## Visão geral

API REST em Node.js com Express, mantida simples nesta primeira versão:

- **Um único arquivo `server.js`**, com as rotas separadas por comentários (seções).
- Dados **em memória** (arrays JavaScript), perdidos ao reiniciar o servidor.
- Requisições e respostas em **JSON**.
- Servidor na porta **3000** (`npm start` ou `node server.js`).

## Estrutura do projeto

```
entregas/aula-07/6325269/
├── .kiro/specs/reserva-salas/   # requirements.md, design.md, tasks.md
├── .gitignore                   # node_modules/
├── package.json
├── package-lock.json
├── server.js                    # servidor, dados em memória e todas as rotas
├── README.md                    # como rodar e testar
└── processo-spec.md             # documento do processo
```

### Organização interna do `server.js`

```
// ===== Configuração =====          express, express.json(), porta
// ===== Dados em memória =====      salas, reservas, próximos ids
// ===== Funções auxiliares =====    validar data/hora, verificar sobreposição
// ===== Rota de teste =====         GET /
// ===== Salas =====                 POST /salas, GET /salas
// ===== Reservas =====              POST /reservas, DELETE /reservas/:id, GET /reservas
// ===== Inicialização =====         app.listen
```

## Modelo de dados (em memória)

```js
let proximoIdSala = 1;
let proximoIdReserva = 1;
const salas = [];
const reservas = [];

// Sala
{ id: 1, nome: "Sala Aurora" }

// Reserva
{
  id: 1,
  salaId: 1,
  funcionario: "Ana",
  inicio: "2027-03-10T10:00",
  fim: "2027-03-10T11:00"
}
```

- IDs **sequenciais** (1, 2, 3...), fáceis de usar nos testes com `curl`.
- A reserva guarda o `salaId` (referência à sala), e não uma cópia da sala.
- Cancelar = remover o item do array `reservas` (decisão dos requisitos).

## Formato de data/hora

- `inicio` e `fim` são textos no formato **`AAAA-MM-DDTHH:mm`** (ex.: `"2027-03-10T10:00"`),
  interpretados no **horário local** do servidor.
- A validação exige **exatamente esse formato** (expressão regular) **e** uma data real
  (ex.: `2027-02-30T10:00` é recusado). Isso evita que o JavaScript aceite formatos ambíguos como
  `"10/03/2027"` ou `"March 10"`, interpretando-os de um jeito que o usuário não esperava.
- Para comparar, os textos são convertidos para `Date` (milissegundos).

## Regra de conflito (sobreposição)

Uma nova reserva `N` conflita com uma reserva existente `E` **da mesma sala** quando:

```
N.inicio < E.fim  E  N.fim > E.inicio
```

| Existente | Nova | Resultado |
|---|---|---|
| 10:00–11:00 | 10:00–11:00 (igual) | conflito |
| 10:00–11:00 | 10:30–11:30 (parcial no fim) | conflito |
| 10:00–11:00 | 09:30–10:30 (parcial no início) | conflito |
| 10:00–11:00 | 10:15–10:45 (dentro) | conflito |
| 10:00–11:00 | 09:00–12:00 (envolve) | conflito |
| 10:00–11:00 | 11:00–12:00 (encosta depois) | **aceita** |
| 10:00–11:00 | 09:00–10:00 (encosta antes) | **aceita** |
| 10:00–11:00 em outra sala | 10:00–11:00 | **aceita** |

A comparação usa `<` e `>` estritos, por isso reservas que apenas encostam são aceitas.

## Rotas da API

| Método | Rota | Corpo / parâmetros | Sucesso | Erros |
|---|---|---|---|---|
| GET | `/` | — | 200 `{ mensagem }` | — |
| POST | `/salas` | `{ nome }` | 201 sala criada | 400 nome obrigatório · 409 sala já existe |
| GET | `/salas` | — | 200 lista de salas | — |
| POST | `/reservas` | `{ salaId, funcionario, inicio, fim }` | 201 reserva criada | 400 validação · 404 sala · 409 conflito |
| DELETE | `/reservas/:id` | — | 200 `{ mensagem, reserva }` | 404 reserva |
| GET | `/reservas?funcionario=NOME` | query `funcionario` | 200 lista de reservas | 400 funcionário não informado |

- `GET /reservas?funcionario=` retorna as reservas **ordenadas pelo início** (agenda cronológica).
- `DELETE` retorna 200 com a reserva removida (em vez de 204 sem corpo), para o teste com `curl`
  mostrar claramente o que foi cancelado.

## Ordem das validações em `POST /reservas`

As validações seguem uma ordem fixa, do mais simples para o mais caro — a checagem de conflito
só roda quando todo o resto já está correto:

1. `funcionario` presente e não vazio → senão **400**
2. `inicio` e `fim` no formato `AAAA-MM-DDTHH:mm` e datas reais → senão **400**
3. `fim` depois de `inicio` → senão **400**
4. `inicio` não está no passado → senão **400**
5. `salaId` informado e número inteiro positivo → senão **400**
6. `salaId` corresponde a uma sala cadastrada → senão **404**
7. nenhuma reserva da mesma sala se sobrepõe → senão **409**

> **Correção feita durante a implementação (Tarefa 5):** a versão aprovada do Design só previa
> "sala não existe → 404". O teste da Tarefa 5 mostrou que uma reserva **sem** `salaId` também
> caía no 404 "Sala não encontrada", o que confunde quem usa a API: o problema é um dado
> faltando, não uma sala inexistente. Foi incluído o passo 5 (400), e as mensagens da sala
> passaram a indicar o id recebido e onde consultar os ids válidos.

## Validações e mensagens

| Dado | Regra | Status | Mensagem de erro |
|---|---|---|---|
| `nome` (sala) | obrigatório, texto não vazio | 400 | `"O nome da sala é obrigatório"` |
| `nome` (sala) | não repetir (sem diferenciar maiúsculas) | 409 | `"Já existe uma sala com o nome X"` |
| `funcionario` | obrigatório, texto não vazio | 400 | `"O funcionário é obrigatório"` |
| `inicio` / `fim` | formato `AAAA-MM-DDTHH:mm` e data real | 400 | `"O campo inicio deve estar no formato AAAA-MM-DDTHH:mm e ser uma data real (ex.: 2027-03-10T10:00). Recebido: X"` (idem `fim`) |
| `fim` | posterior ao início | 400 | `"O fim deve ser depois do início (inicio: A, fim: B)"` |
| `inicio` | não pode estar no passado | 400 | `"Não é possível reservar no passado: o início X já passou (agora são Y)"` |
| `salaId` | obrigatório, número inteiro positivo | 400 | `"O campo salaId é obrigatório e deve ser um número inteiro positivo (ex.: 1). Consulte os ids em GET /salas"` |
| `salaId` | sala cadastrada | 404 | `"Sala não encontrada: não existe sala com id X. Consulte as salas em GET /salas"` |
| intervalo | sem sobreposição na mesma sala | 409 | `"Conflito: a sala X já está reservada de A até B (reserva N). Escolha outro horário ou outra sala"` |
| `:id` | número inteiro positivo | 400 | `"O id da reserva deve ser um número inteiro positivo (ex.: /reservas/1). Recebido: X. Consulte os ids em GET /reservas?funcionario=NOME"` |
| `:id` | reserva existente | 404 | `"Reserva não encontrada: não existe reserva com id X (ela pode já ter sido cancelada)"` |
| `?funcionario` | obrigatório na consulta | 400 | `"Informe o funcionário na consulta: /reservas?funcionario=NOME (ex.: /reservas?funcionario=Ana)"` |

Textos (`nome`, `funcionario`) são salvos sem espaços nas pontas (`trim`). As comparações de nome
de sala e de funcionário são feitas em minúsculas.

## Tratamento de erros

Todos os erros seguem o mesmo formato, com o status HTTP da tabela acima:

```json
{ "erro": "mensagem clara do problema" }
```

## Rastreabilidade (requisito → onde é atendido)

| Requisito | Onde é atendido |
|---|---|
| 1 — Cadastro de sala | `POST /salas` |
| 2 — Listagem de salas | `GET /salas` |
| 3 — Criação de reserva | `POST /reservas` (passos 1 a 6 da ordem de validação) |
| 4 — Conflito | função de sobreposição + passo 7 de `POST /reservas` |
| 5 — Cancelamento | `DELETE /reservas/:id` (remove do array) |
| 6 — Reservas do funcionário | `GET /reservas?funcionario=NOME` |
| 7 — Memória | arrays `salas` e `reservas` |

## Fora do escopo desta versão

- Banco de dados / persistência
- Autenticação e cadastro de funcionários
- Filtro de salas livres em um intervalo
- Editar ou remover salas; editar reservas
- Guardar histórico de reservas canceladas
- Testes automatizados (a validação será manual, com `curl`, tarefa por tarefa)
