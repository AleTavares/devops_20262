# Documento de Design — API de Reserva de Salas de Reunião

## Visão Geral

A API de Reserva de Salas da TechNova é uma aplicação REST construída com **Node.js + Express**. Todos os dados são mantidos em memória (arrays JavaScript), sem dependência de banco de dados externo. A API expõe cinco endpoints que cobrem o ciclo completo de gerenciamento de reservas: cadastro de salas, listagem de salas, criação de reserva, cancelamento de reserva e listagem de reservas por funcionário.

A decisão mais importante de design é o **Verificador de Conflito**, que garante que nenhuma sala possa ter duas reservas ativas no mesmo horário exato.

---

## Arquitetura

A aplicação segue uma arquitetura em camadas simples, adequada ao escopo do projeto:

```
┌─────────────────────────────────────────┐
│              Cliente HTTP               │
└────────────────────┬────────────────────┘
                     │ HTTP (JSON)
┌────────────────────▼────────────────────┐
│           Roteador Express              │
│  (server.js — define as rotas)          │
└──────┬──────────────────────────┬───────┘
       │                          │
┌──────▼───────┐        ┌────────▼────────┐
│  Validador   │        │  Verificador    │
│  (validação  │        │  de Conflito    │
│  de campos)  │        │  (regra de      │
└──────┬───────┘        │  negócio)       │
       │                └────────┬────────┘
       └──────────────┬──────────┘
                      │
┌─────────────────────▼───────────────────┐
│       Repositório em Memória            │
│  salas[]   reservas[]   contadores      │
└─────────────────────────────────────────┘
```

**Decisões de arquitetura:**

- **Arquivo único (`server.js`)**: dado o escopo reduzido, toda a lógica fica em um arquivo único, com funções bem separadas por responsabilidade.
- **Arrays com contadores**: os IDs são gerados por contadores simples (`proximoIdSala`, `proximoIdReserva`) que incrementam a cada criação — simples, previsíveis e suficientes para dados em memória.
- **Funções puras para validação e conflito**: o Validador e o Verificador de Conflito são implementados como funções puras que recebem dados e retornam resultados, facilitando testes unitários.

---

## Componentes e Interfaces

### Repositório em Memória

Estrutura de estado global da aplicação:

```javascript
let salas = [];          // Array de objetos Sala
let reservas = [];       // Array de objetos Reserva
let proximoIdSala = 1;   // Contador de IDs de Sala
let proximoIdReserva = 1; // Contador de IDs de Reserva
```

### Validador

Responsável por verificar campos obrigatórios e formato do horário.

**Funções:**

```javascript
// Retorna true se a string não é nula, não é undefined e tem ao menos um
// caractere não-espaço
function ehStringNaoVazia(valor)

// Retorna true se o horario corresponde ao formato "YYYY-MM-DD HH:MM"
// usando a regex: /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/
function ehHorarioValido(horario)
```

### Verificador de Conflito

Responsável por detectar sobreposições de reserva.

**Função:**

```javascript
// Retorna true se já existe reserva ativa com o mesmo salaId e o mesmo horario
// Comparação é feita por igualdade estrita de strings
function existeConflito(salaId, horario)
```

### Handlers de Rota

Cada endpoint é implementado como uma função handler do Express:

| Rota                       | Handler               | Descrição                          |
|----------------------------|-----------------------|------------------------------------|
| `POST /salas`              | `criarSala`           | Valida e persiste nova sala         |
| `GET /salas`               | `listarSalas`         | Retorna array de salas              |
| `POST /reservas`           | `criarReserva`        | Valida, verifica conflito e persiste|
| `DELETE /reservas/:id`     | `cancelarReserva`     | Remove reserva por ID               |
| `GET /reservas`            | `listarReservas`      | Lista todas ou filtra por funcionário|

---

## Modelos de Dados

### Sala

```javascript
{
  id: Number,    // ID numérico sequencial, gerado pela API
  nome: String   // Nome da sala (único, case-insensitive para deduplicação)
}
```

**Exemplo:**
```json
{ "id": 1, "nome": "Sala Alfa" }
```

### Reserva

```javascript
{
  id: Number,          // ID numérico sequencial, gerado pela API
  salaId: Number,      // ID da sala reservada (deve existir em salas[])
  funcionario: String, // Nome do funcionário que fez a reserva
  horario: String      // Formato "YYYY-MM-DD HH:MM", ex: "2026-10-15 14:00"
}
```

**Exemplo:**
```json
{
  "id": 1,
  "salaId": 2,
  "funcionario": "Ana Lima",
  "horario": "2026-10-15 14:00"
}
```

---

## Propriedades de Corretude

*Uma propriedade é uma característica ou comportamento que deve ser verdadeiro em todas as execuções válidas do sistema — essencialmente, uma afirmação formal sobre o que o sistema deve fazer. Propriedades servem como ponte entre especificações legíveis por humanos e garantias de corretude verificáveis automaticamente.*

### Propriedade 1: Criação de sala preserva o nome

*Para qualquer* string não vazia usada como nome de sala, a sala criada via `POST /salas` deve aparecer em `GET /salas` com exatamente o mesmo nome e com um ID válido.

**Valida: Requisitos 1.1, 2.1, 2.3**

---

### Propriedade 2: Nomes de sala em branco são rejeitados

*Para qualquer* string composta exclusivamente de caracteres de espaço em branco (incluindo a string vazia), a tentativa de criar uma sala deve ser rejeitada com status 400 e a lista de salas não deve ser alterada.

**Valida: Requisitos 1.2**

---

### Propriedade 3: Nomes de sala são únicos (case-insensitive)

*Para qualquer* nome de sala válido, criar uma segunda sala com o mesmo nome (independentemente de maiúsculas/minúsculas) deve retornar status 409 e não adicionar nova sala ao repositório.

**Valida: Requisitos 1.4**

---

### Propriedade 4: Listagem reflete exatamente as salas criadas

*Para qualquer* sequência de N criações de salas com nomes distintos e válidos, `GET /salas` deve retornar exatamente N salas, cada uma contendo os campos `id` e `nome` com os valores originais.

**Valida: Requisitos 2.1, 2.2, 2.3**

---

### Propriedade 5: Criação de reserva válida é persistida

*Para qualquer* combinação válida de (salaId existente, funcionario não vazio, horario no formato correto) sem conflito com reservas existentes, `POST /reservas` deve retornar status 201 e a reserva deve aparecer na listagem com todos os campos corretos.

**Valida: Requisitos 3.1, 3.6, 5.3, 5.4**

---

### Propriedade 6: Detecção de conflito de horário

*Para qualquer* reserva existente com um determinado par (salaId, horario), uma nova tentativa de reserva com o mesmo par deve ser rejeitada com status 409, independentemente do nome do funcionário solicitante.

**Valida: Requisitos 3.4, 6.1, 6.2**

---

### Propriedade 7: Horários distintos não geram conflito

*Para qualquer* sala e dois horários distintos no formato correto, é possível criar duas reservas na mesma sala sem conflito — os dois `POST /reservas` devem retornar status 201.

**Valida: Requisitos 6.4**

---

### Propriedade 8: Cancelamento libera horário para nova reserva (round-trip)

*Para qualquer* reserva criada com um par (salaId, horario), após cancelar essa reserva via `DELETE /reservas/:id`, deve ser possível criar uma nova reserva com o mesmo par (salaId, horario) com sucesso (status 201).

**Valida: Requisitos 4.1, 4.3, 6.3**

---

### Propriedade 9: Filtragem por funcionário retorna apenas as reservas corretas

*Para qualquer* conjunto de reservas criadas para múltiplos funcionários, `GET /reservas?funcionario=X` deve retornar exatamente e somente as reservas cujo campo `funcionario` seja igual a X — sem incluir reservas de outros funcionários e sem omitir nenhuma reserva de X.

**Valida: Requisitos 5.1, 5.2**

---

### Propriedade 10: Formato de horário inválido é rejeitado

*Para qualquer* string que não corresponda ao padrão `YYYY-MM-DD HH:MM` (ex.: `"15/10/2026 14h00"`, `"amanhã"`, `"2026-10-15"`, `""`), a tentativa de criar uma reserva deve ser rejeitada com status 400.

**Valida: Requisitos 3.5**

---

## Tratamento de Erros

Todos os erros retornam um objeto JSON com o campo `erro` contendo uma mensagem descritiva em português:

```json
{ "erro": "Descrição do erro." }
```

| Situação                                      | Status HTTP |
|----------------------------------------------|:-----------:|
| Campo obrigatório ausente ou vazio            | 400         |
| Formato de horário inválido                   | 400         |
| Sala não encontrada (na criação de reserva)   | 404         |
| Reserva não encontrada (no cancelamento)      | 404         |
| Nome de sala duplicado                        | 409         |
| Conflito de horário na criação de reserva     | 409         |
| Erro interno inesperado                       | 500         |

**Princípios de tratamento de erros:**

- Erros de validação são detectados antes de qualquer acesso ao repositório.
- Erros de negócio (conflito, não encontrado) são detectados após validação, mas antes de persistir.
- Nunca há persistência parcial: ou a operação completa com sucesso, ou nada é escrito no repositório.

---

## Estratégia de Testes

### Abordagem Dual: Testes Unitários + Testes de Propriedade

**Testes unitários** cobrem exemplos concretos, casos de borda e condições de erro. **Testes de propriedade** verificam que invariantes universais se mantêm para qualquer entrada gerada aleatoriamente.

### Biblioteca de Testes de Propriedade

Para Node.js, será utilizado o **[fast-check](https://fast-check.dev/)** como biblioteca de property-based testing. Cada teste de propriedade deve ser configurado para executar no mínimo **100 iterações**.

**Anotação de cada teste de propriedade:**
```javascript
// Feature: reserva-salas, Propriedade N: <texto da propriedade>
```

### Testes Unitários (Exemplos Concretos)

Focam em:
- Cenários específicos de sucesso (happy path) para cada endpoint
- Condições de borda: lista vazia, ID inexistente, campo `funcionario` com espaços
- Mensagens de erro descritivas em português
- Verificação de campos de retorno (estrutura do JSON)

Serão escritos com **[Jest](https://jestjs.io/)** e **[supertest](https://github.com/ladjs/supertest)** para testar a API HTTP diretamente.

### Testes de Propriedade

Cada propriedade da seção "Propriedades de Corretude" deve ser implementada como um teste de propriedade usando fast-check:

| Propriedade | O que varia                                     |
|:-----------:|-------------------------------------------------|
| 1           | Nome da sala (string não vazia aleatória)       |
| 2           | String de espaços em branco (tamanho variável)  |
| 3           | Nome de sala duplicado com variações de case    |
| 4           | Sequência de N criações de salas (N variável)   |
| 5           | Combinação (sala, funcionário, horário) válida  |
| 6           | Par (salaId, horario) para teste de conflito    |
| 7           | Dois horários distintos para a mesma sala       |
| 8           | Round-trip: criar → cancelar → recriar          |
| 9           | Reservas para múltiplos funcionários            |
| 10          | Strings de horário em formatos inválidos        |

### Cobertura Esperada

- Todos os 6 requisitos devem ter cobertura de teste
- O Verificador de Conflito deve ser testado tanto positivamente (conflito detectado) quanto negativamente (horários distintos liberados)
- O Validador deve ser testado com inputs extremos: strings vazias, nulas, undefined, só espaços
