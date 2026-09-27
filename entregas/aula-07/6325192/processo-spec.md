# Processo Spec-Driven — Reserva de Salas | Emar Cristian Silva Teruo Ito (6325192)

## 1. Como eu dividi o problema

Antes de implementar a API, dividi o problema em partes menores para evitar tentar resolver tudo de uma vez:

1. Criar a estrutura inicial da API com Node.js e Express.
2. Criar a rota para cadastrar uma sala.
3. Criar a rota para listar as salas cadastradas.
4. Criar a rota para cadastrar uma reserva.
5. Verificar se a sala informada realmente existe.
6. Criar separadamente a regra que impede duas reservas para a mesma sala e horário.
7. Criar a rota para listar reservas.
8. Adicionar o filtro das reservas por funcionário.
9. Criar a rota para cancelar uma reserva pelo ID.
10. Testar cada funcionalidade da API individualmente.

Essa divisão tornou o problema mais simples porque cada comportamento pôde ser implementado e verificado separadamente.

## 2. Requisitos (o quê)

Os requisitos identificados foram:

- O sistema deve permitir cadastrar salas.
- O nome da sala é obrigatório.
- O sistema deve permitir listar todas as salas.
- O sistema deve permitir criar uma reserva informando sala, funcionário e horário.
- Uma reserva só pode ser criada para uma sala existente.
- O sistema não pode aceitar duas reservas para a mesma sala no mesmo horário.
- O sistema deve permitir cancelar uma reserva pelo ID.
- O sistema deve permitir listar todas as reservas.
- O sistema deve permitir filtrar as reservas pelo nome do funcionário.
- Os dados podem permanecer em memória.
- A aplicação deve ser desenvolvida com Node.js e Express.

Durante a revisão, também considerei importante retornar códigos HTTP adequados e mensagens claras quando uma operação for inválida.

## 3. Design (como)

O design foi mantido simples porque o trabalho não exige banco de dados.

Foi utilizado um único arquivo `server.js` com Express.

Os dados são armazenados em dois arrays:

- `salas`
- `reservas`

Também são utilizados contadores para gerar IDs numéricos.

A validação de conflito foi mantida separada dentro da criação de reserva. Antes de adicionar uma reserva, a aplicação pesquisa se já existe outra com o mesmo `salaId` e `horario`.

Não foi criada uma arquitetura com muitas camadas porque isso aumentaria a complexidade sem trazer benefício para o escopo deste TF.

## 4. Tarefas (os passos pequenos)

1. Inicializar o projeto Node.js.
2. Instalar Express.
3. Configurar `express.json()`.
4. Criar armazenamento em memória para salas.
5. Implementar `POST /salas`.
6. Validar nome obrigatório.
7. Implementar `GET /salas`.
8. Criar armazenamento em memória para reservas.
9. Implementar `POST /reservas`.
10. Validar sala, funcionário e horário.
11. Validar existência da sala.
12. Implementar isoladamente a detecção de conflito de horário.
13. Retornar HTTP 409 quando existir conflito.
14. Implementar `GET /reservas`.
15. Implementar filtro `?funcionario=NOME`.
16. Implementar `DELETE /reservas/:id`.
17. Testar cadastro de sala.
18. Testar criação de reserva.
19. Testar bloqueio de conflito.
20. Testar consulta por funcionário.
21. Testar cancelamento da reserva.

## 5. Implementação e validação

### Tarefa 1 — cadastrar sala

Teste utilizado:

    curl -X POST http://localhost:3000/salas \
      -H "Content-Type: application/json" \
      -d '{"nome":"Sala Azul"}'

Resultado esperado:

A API retorna HTTP 201 com o ID e o nome da sala criada.

Depois a listagem pode ser validada com:

    curl http://localhost:3000/salas

### Tarefa 2 — criar uma reserva

Teste utilizado:

    curl -X POST http://localhost:3000/reservas \
      -H "Content-Type: application/json" \
      -d '{"salaId":1,"funcionario":"Emar","horario":"2026-09-28T10:00"}'

Resultado esperado:

A reserva é criada com HTTP 201 e recebe um ID.

### Tarefa 3 — validar conflito de horário

Depois de criar a primeira reserva, tentei criar outra para a mesma sala e o mesmo horário:

    curl -X POST http://localhost:3000/reservas \
      -H "Content-Type: application/json" \
      -d '{"salaId":1,"funcionario":"Outro Funcionario","horario":"2026-09-28T10:00"}'

Resultado esperado:

A API retorna HTTP 409 e informa que a sala já possui uma reserva naquele horário.

Esse teste é importante porque valida isoladamente a regra mais crítica do projeto.

### Tarefa 4 — listar reservas de um funcionário

Teste utilizado:

    curl "http://localhost:3000/reservas?funcionario=Emar"

Resultado esperado:

Somente as reservas do funcionário Emar são retornadas.

### Tarefa 5 — cancelar reserva

Teste utilizado:

    curl -X DELETE http://localhost:3000/reservas/1

Resultado esperado:

A API informa que a reserva foi cancelada com sucesso.

## 6. A IA errou em algum momento?

O principal risco ao utilizar IA nesta atividade foi tentar gerar a solução inteira sem validar as partes separadamente.

Para evitar isso, o problema foi dividido primeiro em requisitos, design e tarefas menores.

Durante o processo, revisei as decisões propostas e mantive a implementação simples, sem adicionar banco de dados, autenticação ou outras funcionalidades que não faziam parte do enunciado.

A regra de conflito foi tratada como uma tarefa separada porque era a parte mais suscetível a erro. O comportamento foi validado tentando criar intencionalmente duas reservas para a mesma sala e horário.

A IA utilizada como apoio foi o ChatGPT. A saída foi revisada e validada por meio da execução da aplicação e de testes das rotas.

## 7. Reflexão

Se eu tivesse pedido apenas "faça um sistema completo de reserva de salas", seria mais difícil verificar onde um eventual erro estava acontecendo.

Dividir o problema transformou uma tarefa maior em várias tarefas pequenas e verificáveis.

O processo de requisitos, design e tarefas ajudou a definir primeiro o que precisava ser feito, depois como seria feito e somente então partir para a implementação.

Também ficou mais simples testar cada regra separadamente.

A principal conclusão foi que a IA funciona melhor como copiloto quando recebe problemas menores e objetivos claros. Mesmo quando o código parece correto, é necessário executar e testar o comportamento antes de considerar uma etapa concluída.
