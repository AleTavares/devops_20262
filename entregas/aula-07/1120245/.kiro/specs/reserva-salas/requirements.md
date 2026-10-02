# Documento de Requisitos

## Introdução

A TechNova precisa de uma API REST para gerenciar reservas de salas de reunião. O sistema permite que funcionários cadastrem salas, consultem disponibilidade, façam reservas, cancelem reservas e listem as reservas vinculadas ao seu nome. A regra mais crítica é a **prevenção de conflito de horário**: nenhuma sala pode ter duas reservas ativas para o mesmo horário. Os dados são mantidos em memória (sem banco de dados), e todas as respostas são em formato JSON.

---

## Glossário

- **API**: A aplicação Express.js que expõe os endpoints REST.
- **Sala**: Espaço de reunião identificado por um ID numérico sequencial e um nome único.
- **Reserva**: Associação entre uma Sala, um Funcionário e um Horário, identificada por um ID numérico sequencial.
- **Funcionário**: Pessoa identificada pelo nome que realiza ou possui reservas.
- **Horário**: String no formato `"YYYY-MM-DD HH:MM"` que representa o início de uma reserva (ex.: `"2026-10-15 14:00"`).
- **Conflito**: Situação em que uma Sala já possui uma Reserva ativa para o mesmo Horário.
- **Repositório_Em_Memória**: Estrutura de dados em memória (arrays JavaScript) que armazena Salas e Reservas durante a execução da aplicação.
- **Validador**: Módulo responsável por verificar a presença e o formato correto dos campos obrigatórios de uma requisição.
- **Verificador_De_Conflito**: Módulo responsável por detectar conflitos de horário antes de criar uma nova Reserva.

---

## Requisitos

### Requisito 1: Cadastro de Salas

**User Story:** Como funcionário da TechNova, quero cadastrar uma sala de reunião, para que ela fique disponível para reservas futuras.

#### Critérios de Aceitação

1. QUANDO uma requisição `POST /salas` é recebida com um campo `nome` não vazio, A API SHALL criar uma nova Sala, atribuir um ID numérico sequencial único e retornar os dados da Sala criada com status HTTP 201.
2. QUANDO uma requisição `POST /salas` é recebida com o campo `nome` ausente ou composto exclusivamente de espaços em branco, A API SHALL rejeitar a requisição e retornar uma mensagem de erro descritiva com status HTTP 400.
3. THE Repositório_Em_Memória SHALL armazenar cada Sala criada e manter a coleção disponível durante toda a execução da aplicação.
4. QUANDO uma requisição `POST /salas` é recebida com um `nome` idêntico (sem distinção de maiúsculas/minúsculas) ao de uma Sala já cadastrada, A API SHALL rejeitar a requisição com mensagem de erro descritiva e status HTTP 409.

---

### Requisito 2: Listagem de Salas

**User Story:** Como funcionário da TechNova, quero listar todas as salas cadastradas, para que eu possa escolher qual sala reservar.

#### Critérios de Aceitação

1. QUANDO uma requisição `GET /salas` é recebida, A API SHALL retornar a lista completa de Salas cadastradas com status HTTP 200.
2. ENQUANTO nenhuma Sala estiver cadastrada, A API SHALL retornar uma lista vazia (`[]`) com status HTTP 200.
3. THE API SHALL retornar cada Sala com os campos `id` e `nome`.

---

### Requisito 3: Criação de Reservas

**User Story:** Como funcionário da TechNova, quero reservar uma sala para um determinado horário, para que eu possa garantir o espaço para a minha reunião.

#### Critérios de Aceitação

1. QUANDO uma requisição `POST /reservas` é recebida com os campos `salaId`, `funcionario` e `horario` válidos e sem conflito, A API SHALL criar uma nova Reserva com ID numérico sequencial único e retornar os dados da Reserva criada com status HTTP 201.
2. QUANDO uma requisição `POST /reservas` é recebida com qualquer campo obrigatório (`salaId`, `funcionario` ou `horario`) ausente ou vazio, O Validador SHALL rejeitar a requisição com mensagem de erro descritiva e status HTTP 400.
3. QUANDO uma requisição `POST /reservas` é recebida com um `salaId` que não corresponde a nenhuma Sala cadastrada, A API SHALL retornar uma mensagem de erro descritiva com status HTTP 404.
4. QUANDO uma requisição `POST /reservas` é recebida e o Verificador_De_Conflito detecta que a Sala indicada já possui uma Reserva ativa para o mesmo Horário, A API SHALL rejeitar a reserva com mensagem de erro descritiva e status HTTP 409.
5. QUANDO uma requisição `POST /reservas` é recebida com um `horario` em formato diferente de `"YYYY-MM-DD HH:MM"`, O Validador SHALL rejeitar a requisição com mensagem de erro descritiva e status HTTP 400.
6. THE Repositório_Em_Memória SHALL armazenar cada Reserva criada e manter a coleção disponível durante toda a execução da aplicação.

---

### Requisito 4: Cancelamento de Reservas

**User Story:** Como funcionário da TechNova, quero cancelar uma reserva existente, para que a sala fique disponível para outras pessoas.

#### Critérios de Aceitação

1. QUANDO uma requisição `DELETE /reservas/:id` é recebida com um `id` que corresponde a uma Reserva existente, A API SHALL remover a Reserva do Repositório_Em_Memória e retornar status HTTP 200 com uma mensagem de confirmação.
2. QUANDO uma requisição `DELETE /reservas/:id` é recebida com um `id` que não corresponde a nenhuma Reserva, A API SHALL retornar uma mensagem de erro descritiva com status HTTP 404.
3. APÓS o cancelamento de uma Reserva, O Verificador_De_Conflito SHALL considerar o Horário da sala como disponível para novas reservas.

---

### Requisito 5: Listagem de Reservas por Funcionário

**User Story:** Como funcionário da TechNova, quero listar todas as minhas reservas, para que eu possa visualizar minha agenda de salas.

#### Critérios de Aceitação

1. QUANDO uma requisição `GET /reservas?funcionario=NOME` é recebida com um parâmetro `funcionario` não vazio, A API SHALL retornar todas as Reservas cujo campo `funcionario` corresponda exatamente ao valor informado, com status HTTP 200.
2. QUANDO uma requisição `GET /reservas?funcionario=NOME` não encontra nenhuma Reserva para o Funcionário informado, A API SHALL retornar uma lista vazia (`[]`) com status HTTP 200.
3. QUANDO uma requisição `GET /reservas` é recebida sem o parâmetro `funcionario`, A API SHALL retornar todas as Reservas cadastradas com status HTTP 200.
4. THE API SHALL retornar cada Reserva com os campos `id`, `salaId`, `funcionario` e `horario`.

---

### Requisito 6: Prevenção de Conflito de Horário

**User Story:** Como administrador do sistema, quero garantir que não existam duas reservas na mesma sala e no mesmo horário, para que o calendário de salas seja sempre consistente.

#### Critérios de Aceitação

1. PARA TODA tentativa de criação de Reserva, O Verificador_De_Conflito SHALL verificar se existe Reserva ativa com o mesmo `salaId` e o mesmo `horario` antes de persistir a nova Reserva.
2. SE uma Reserva ativa com o mesmo `salaId` e o mesmo `horario` for encontrada, ENTÃO A API SHALL recusar a criação e retornar status HTTP 409 com mensagem indicando o conflito.
3. APÓS o cancelamento de uma Reserva, O Verificador_De_Conflito SHALL permitir que o `salaId` e o `horario` liberados sejam utilizados em uma nova Reserva.
4. THE Verificador_De_Conflito SHALL tratar a comparação de horários como correspondência exata de strings no formato `"YYYY-MM-DD HH:MM"`.
