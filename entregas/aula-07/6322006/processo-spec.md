# Processo Spec-Driven — Reserva de Salas | Rafael Nogueira Maruca (RA 6322006)

## 1. Como eu dividi o problema

Separei a API em etapas pequenas e verificáveis:

1. Definir o contrato dos dados de sala, funcionário e intervalo de tempo.
2. Cadastrar e listar salas, incluindo a validação do nome.
3. Validar os campos de uma reserva e confirmar que a sala existe.
4. Implementar a regra de sobreposição de horários como tarefa isolada.
5. Listar reservas por funcionário.
6. Cancelar reserva por ID e verificar a resposta para IDs inexistentes.
7. Documentar execução e validar o conjunto com testes automatizados.

## 2. Requisitos (o quê)

O enunciado exige Node.js + Express, armazenamento em memória, cadastro/listagem de salas, criação/cancelamento/listagem de reservas e bloqueio de conflito na mesma sala e horário.

Explicitei três decisões que o enunciado não detalha: cada sala recebe ID numérico; os horários são timestamps ISO 8601 com fuso horário; e os intervalos seguem a convenção `[início, fim)`, permitindo uma reserva começar exatamente quando outra termina. Também tratei sobreposição parcial como conflito, uma interpretação mais segura do requisito do que comparar apenas horários de início iguais.

## 3. Design (como)

A aplicação usa um servidor Express pequeno (`server.js`) e arrays mantidos em um store criado por instância da aplicação. Isso mantém os dados em memória e permite que os testes criem uma instância isolada. O código valida entrada na borda HTTP, normaliza os timestamps para UTC e responde com JSON e códigos HTTP específicos. Não adicionei banco de dados, autenticação ou dependências de teste externas, pois não são requisitos deste exercício.

**Limite da ferramenta:** não tenho acesso a uma sessão da interface Kiro neste ambiente; portanto, não afirmo que executei o modo Spec do Kiro. Estruturei este trabalho pelas etapas de requisitos, design e tarefas do método Spec, usando o assistente disponível no editor. Para cumprir literalmente a etapa de uso do Kiro, ainda é necessário abrir/registrar essas etapas em uma sessão Spec do Kiro e complementar este relato com o histórico real dessa sessão.

## 4. Tarefas (os passos pequenos)

1. Criar o projeto Node.js com Express e um comando de inicialização.
2. Implementar `POST /salas` com validação de nome e `GET /salas`.
3. Definir o contrato da reserva e validar sala, funcionário e timestamps.
4. Implementar detecção de sobreposição para a mesma sala e permitir intervalos adjacentes.
5. Implementar `GET /reservas?funcionario=...`.
6. Implementar `DELETE /reservas/:id` com respostas para reserva ausente.
7. Escrever testes de API para os casos de sucesso e erro.
8. Documentar comandos, contratos e limitações.

## 5. Implementação e validação

Validação executada com `npm test` (Node.js test runner, sem AWS):

| Tarefa | Como validei | Resultado |
|---|---|---|
| Cadastro/listagem de sala | `POST /salas` com nome vazio e depois válido; `GET /salas` | Nome vazio retorna 400; sala válida retorna 201 e aparece na lista |
| Regras de horário | Reserva 10:00–11:00; tentativa 10:30–11:30 e depois 11:00–12:00 na mesma sala | Sobreposição retorna 409; intervalo adjacente retorna 201 |
| Listar/cancelar reserva | Criar reserva, filtrar por `funcionario` e executar `DELETE` pelo ID | Filtro retorna a reserva; cancelamento retorna 204; repetição retorna 404 |

Os testes também cobrem formato de horário inválido, fim anterior ao início, sala inexistente e mesma faixa horária em outra sala. A evidência reproduzível é a saída do `npm test`; não foi necessário provisionar AWS.

## 6. A IA errou em algum momento?

Não atribuo a implementação a uma sessão Kiro nem invento um erro observado nessa ferramenta. Durante a decomposição, explicitei os casos de borda que uma comparação ingênua apenas por horário inicial deixaria passar: sobreposição parcial, intervalos adjacentes e a mesma faixa em salas diferentes. Transformei esses casos em testes antes de considerar a regra pronta. Os testes automatizados são a checagem, não uma afirmação de que a IA sempre acerta.

## 7. Reflexão

Pedir o sistema inteiro de uma vez tenderia a misturar contrato HTTP, validações e regra temporal, tornando difícil localizar uma falha. Dividir o trabalho permitiu validar primeiro os dados e depois isolar a regra de conflito com casos concretos. Aprendi que a IA pode acelerar a implementação, mas decisões ambíguas precisam ser explicitadas e transformadas em testes. O modo Spec do Kiro ainda precisa ser executado e registrado para que essa parte da atividade seja comprovada literalmente.