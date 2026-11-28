# Requirements Document

## Introduction

A TechNova precisa de uma API REST de Reserva de Salas de Reunião construída com Node.js e Express, com dados mantidos em memória durante a execução do servidor. A API permite que funcionários cadastrem salas, consultem disponibilidade, criem reservas em intervalos de tempo, cancelem reservas existentes e listem reservas por funcionário. A regra central de negócio é que uma mesma sala não pode ter duas reservas com intervalos de tempo sobrepostos; reservas encostadas (fim de uma igual ao início da outra) são permitidas.

## Glossary

- **API**: Aplicação Node.js + Express que expõe os endpoints de reserva de salas.
- **Sala**: Entidade que representa uma sala de reunião, identificada por `id` (inteiro sequencial) e `nome` (string).
- **Reserva**: Entidade que associa uma Sala a um Funcionário em um intervalo de tempo definido por `inicio` e `fim` em formato ISO 8601.
- **Funcionario**: Identificado apenas pelo nome (string) fornecido na criação da reserva.
- **Intervalo**: Par de instantes `inicio` e `fim` em ISO 8601, onde `inicio` deve ser estritamente anterior a `fim`.
- **Conflito**: Situação em que dois Intervalos da mesma Sala se sobrepõem. A condição de conflito é: `novoInicio < fimExistente AND inicioExistente < novoFim`. Reservas encostadas (`fim == inicio`) não configuram conflito.

---

## Requirements

### Requirement 1: Cadastrar Sala

**User Story:** As a funcionário da TechNova, I want to cadastrar uma nova sala de reunião, so that ela fique disponível para ser reservada.

#### Acceptance Criteria

1. WHEN uma requisição `POST /salas` é recebida com body contendo `nome` com 1 a 100 caracteres não brancos, THE API SHALL criar a sala com um `id` inteiro sequencial único, persistir em memória e retornar a sala criada (com os campos `id` e `nome`) com status HTTP 201.
2. IF a requisição `POST /salas` não contiver o campo `nome`, ou contiver `nome` vazio, somente com espaços brancos, ou com mais de 100 caracteres, THEN THE API SHALL retornar status HTTP 400 com mensagem de erro indicando o campo obrigatório, e a sala NÃO deve ser criada.
3. THE API SHALL iniciar o contador de `id` de salas a partir de 1 e incrementar em 1 a cada sala criada com sucesso.

---

### Requirement 2: Listar Salas

**User Story:** As a funcionário da TechNova, I want to listar todas as salas cadastradas, so that eu saiba quais salas existem no sistema.

#### Acceptance Criteria

1. WHEN uma requisição `GET /salas` é recebida sem parâmetros de query, THE API SHALL retornar a lista completa de salas cadastradas em memória com status HTTP 200, em formato JSON array onde cada objeto contém exatamente os campos `id` e `nome`, ordenada pela ordem de cadastro (crescente por `id`).
2. WHEN nenhuma sala foi cadastrada, THE API SHALL retornar uma lista vazia (`[]`) com status HTTP 200.

---

### Requirement 3: Listar Salas Disponíveis em um Período

**User Story:** As a funcionário da TechNova, I want to consultar quais salas estão livres em um determinado intervalo de tempo, so that eu possa escolher uma sala disponível para agendar minha reunião.

#### Acceptance Criteria

1. WHEN uma requisição `GET /salas` é recebida com os parâmetros de query `inicio` e `fim` em ISO 8601 válidos e `inicio` estritamente anterior a `fim`, THE API SHALL retornar com status HTTP 200 um JSON array contendo apenas as salas (campos `id` e `nome`) que não possuem nenhuma Reserva com Intervalo sobreposto ao período consultado.
2. IF a requisição `GET /salas` contiver apenas `inicio` (sem `fim`) ou apenas `fim` (sem `inicio`), THEN THE API SHALL retornar status HTTP 400 com mensagem de erro indicando que ambos os parâmetros são obrigatórios quando um deles está presente.
3. IF a requisição `GET /salas` contiver `inicio` ou `fim` com valor que não seja uma data ISO 8601 válida, ou com `inicio >= fim`, THEN THE API SHALL retornar status HTTP 400 com uma mensagem de erro especificando qual parâmetro é inválido e o motivo.
4. THE API SHALL considerar como ocupada toda sala que possua ao menos uma Reserva onde `inicio_consulta < fim_reserva AND inicio_reserva < fim_consulta`.
5. WHEN uma sala não possui reservas, THE API SHALL incluí-la no resultado de salas disponíveis para qualquer período consultado.
6. WHEN a consulta com `inicio` e `fim` válidos não encontrar nenhuma sala disponível, THE API SHALL retornar uma lista vazia (`[]`) com status HTTP 200.

---

### Requirement 4: Criar Reserva

**User Story:** As a funcionário da TechNova, I want to criar uma reserva para uma sala em um intervalo de tempo específico, so that eu possa garantir o uso da sala para minha reunião.

#### Acceptance Criteria

1. WHEN uma requisição `POST /reservas` é recebida com `salaId` de sala existente, `funcionario` não vazio (1–100 caracteres), `inicio` e `fim` em ISO 8601 válidos com `inicio` estritamente anterior a `fim`, e sem nenhuma Reserva conflitante para a sala, THE API SHALL criar a reserva com `id` inteiro sequencial único, persistir em memória e retornar status HTTP 201 com os campos `id`, `salaId`, `funcionario`, `inicio` e `fim`.
2. IF a requisição `POST /reservas` não contiver qualquer um dos campos `salaId`, `funcionario`, `inicio` ou `fim`, THEN THE API SHALL retornar status HTTP 400 com mensagem identificando os campos ausentes, e a reserva NÃO deve ser criada.
3. IF a requisição `POST /reservas` contiver `funcionario` vazio, somente com espaços brancos, ou com mais de 100 caracteres, THEN THE API SHALL retornar status HTTP 400 com mensagem de erro descritiva, e a reserva NÃO deve ser criada.
4. IF a requisição `POST /reservas` contiver `inicio` ou `fim` que não seja data ISO 8601 válida, THEN THE API SHALL retornar status HTTP 400 com mensagem especificando o campo inválido.
5. IF a requisição `POST /reservas` contiver `inicio >= fim`, THEN THE API SHALL retornar status HTTP 400 com mensagem indicando que `inicio` deve ser estritamente anterior a `fim`.
6. IF a requisição `POST /reservas` contiver `salaId` que não corresponda a nenhuma sala cadastrada, THEN THE API SHALL retornar status HTTP 404 com mensagem de erro indicando que a sala não foi encontrada.
7. IF a requisição `POST /reservas` for para uma sala que já possui Reserva com Intervalo conflitante (condição: `novoInicio < fimExistente AND inicioExistente < novoFim`), THEN THE API SHALL retornar status HTTP 409 com mensagem de erro e os dados da reserva conflitante contendo os campos `id`, `salaId`, `funcionario`, `inicio` e `fim`.
8. WHEN dois Intervalos da mesma Sala são encostados (`fim` de uma Reserva existente igual ao `inicio` da nova), THE API SHALL criar a nova Reserva com sucesso e retornar status HTTP 201.
9. THE API SHALL iniciar o contador de `id` de reservas a partir de 1 e incrementar em 1 a cada reserva criada com sucesso.
10. THE API SHALL armazenar `inicio` e `fim` da reserva em formato ISO 8601 UTC com sufixo `Z` (ex.: `"2025-06-10T14:00:00.000Z"`).

---

### Requirement 5: Cancelar Reserva

**User Story:** As a funcionário da TechNova, I want to cancelar uma reserva existente, so that a sala fique disponível para outros funcionários no horário liberado.

#### Acceptance Criteria

1. WHEN uma requisição `DELETE /reservas/:id` é recebida com `id` de uma Reserva existente, THE API SHALL remover a reserva da memória e retornar status HTTP 200 com os dados da reserva removida, incluindo os campos `id`, `salaId`, `funcionario`, `inicio` e `fim`.
2. WHEN uma requisição `DELETE /reservas/:id` é recebida com `id` numérico que não corresponde a nenhuma Reserva, THE API SHALL retornar status HTTP 404 com mensagem de erro indicando que a reserva não foi encontrada.
3. IF o `id` fornecido na requisição `DELETE /reservas/:id` não for um identificador numérico inteiro positivo, THEN THE API SHALL retornar status HTTP 400 com mensagem de erro indicando que o `id` é inválido.
4. WHEN uma Reserva é cancelada com sucesso, THE API SHALL aceitar uma nova requisição `POST /reservas` para a mesma `salaId` com um intervalo de tempo que coincida total ou parcialmente com o intervalo liberado, retornando status HTTP 201.

---

### Requirement 6: Listar Reservas de um Funcionário

**User Story:** As a funcionário da TechNova, I want to listar todas as minhas reservas, so that eu possa visualizar meus agendamentos de reunião.

#### Acceptance Criteria

1. WHEN uma requisição `GET /reservas` é recebida com o parâmetro `funcionario` preenchido (não vazio e não somente espaços brancos), THE API SHALL retornar com status HTTP 200 um JSON array com todas as Reservas cujo campo `funcionario` corresponda ao valor informado (comparação case-insensitive), onde cada objeto contém os campos `id`, `salaId`, `funcionario`, `inicio` e `fim`.
2. IF a requisição `GET /reservas` não contiver o parâmetro `funcionario`, ou contiver `funcionario` vazio ou somente com espaços brancos, THEN THE API SHALL retornar status HTTP 400 com mensagem indicando que o parâmetro é obrigatório e não pode ser vazio.
3. WHEN nenhuma Reserva existe para o funcionário informado, THE API SHALL retornar uma lista vazia (`[]`) com status HTTP 200.
