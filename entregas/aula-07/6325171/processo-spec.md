# Processo Spec-Driven — Reserva de Salas | Nicolas de Jesus Silva (RA 6325171)

## 1. Como eu dividi o problema

O problema foi quebrado em partes menores para reduzir risco de erro e facilitar a validação por etapas:

1. Criar a base da API com Express e endpoints mínimos
2. Implementar o cadastro de salas
3. Implementar a listagem de salas
4. Implementar a criação de reservas
5. Validar a regra de conflito de horário por sala
6. Implementar a listagem de reservas por funcionário
7. Implementar o cancelamento de reserva
8. Validar os endpoints com testes e comandos curl

Essa divisão foi importante porque o sistema completo poderia facilmente gerar inconsistências se tudo fosse pedido de uma vez.

## 2. Requisitos (o quê)

Os requisitos principais que o sistema precisava atender foram:

- cadastrar uma sala com nome obrigatório
- listar salas disponíveis
- registrar uma reserva vinculada a uma sala e a um funcionário
- impedir conflitos em mesmo horário e sala
- cancelar reservas existentes
- consultar reservas por funcionário

Foi necessário ajustar a ideia inicial para manter a solução simples e funcional, sem banco de dados e sem excesso de complexidade.

## 3. Design (como)

O design foi pensado em memória, usando duas estruturas principais:

- `salas`: guarda as salas cadastradas
- `reservas`: guarda as reservas criadas

A lógica de negócio foi centralizada na rota `POST /reservas`, onde é verificado se a sala existe e se já existe um conflito para o mesmo horário na mesma sala. Essa abordagem mantém o código simples e fácil de testar.

## 4. Tarefas (os passos pequenos)

1. Criar o projeto Node.js com Express
2. Configurar os scripts de execução e teste
3. Implementar `GET /health`
4. Implementar `POST /salas`
5. Implementar `GET /salas`
6. Implementar `POST /reservas`
7. Implementar regra de conflito de horário
8. Implementar `GET /reservas?funcionario=NOME`
9. Implementar `DELETE /reservas/:id`
10. Verificar testes e validá-los com curl

## 5. Implementação e validação

### Tarefa: cadastrar sala

Validação: envio de um POST para `/salas` com JSON válido.

Exemplo:

```bash
curl -X POST http://localhost:3000/salas \
  -H "Content-Type: application/json" \
  -d '{"nome":"Sala Verde","capacidade":8}'
```

Resultado esperando: status `201` e corpo com a sala criada.

### Tarefa: impedir conflito de horário

Validação: envio de duas reservas para a mesma sala no mesmo horário.

Exemplo:

```bash
curl -X POST http://localhost:3000/reservas \
  -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Ana","data":"2026-10-01","horario":"09:00"}'

curl -X POST http://localhost:3000/reservas \
  -H "Content-Type: application/json" \
  -d '{"salaId":1,"funcionario":"Bruno","data":"2026-10-01","horario":"09:00"}'
```

Resultado esperado: segunda resposta com status `409` e mensagem indicando conflito.

### Tarefa: listar reservas por funcionário

Validação: uso do filtro `?funcionario=Ana`.

Exemplo:

```bash
curl "http://localhost:3000/reservas?funcionario=Ana"
```

Resultado esperado: array com apenas as reservas do funcionário informado.

## 6. A IA errou em algum momento?

A IA pode ser muito eficiente, mas quando o problema é grande e genérico, ela tende a misturar regras ou implementar tudo ao mesmo tempo. Nesse processo, o principal ganho do método Spec foi forçar a divisão do problema em blocos pequenos, com validação após cada etapa.

Isso reduziu o risco de alucinação e deixou a implementação mais controlada. Em vez de pedir para "fazer a API inteira", pedi etapas pequenas e validei cada passo antes de seguir.

## 7. Reflexão

O método errado seria solicitar a criação completa da API em um único prompt. O resultado provavelmente seria uma implementação incompleta, com regras inconsistentes e pouca rastreabilidade.

Ao dividir em requisitos, design e tarefas, consegui criar uma solução mais organizada, com melhor controle e testes claros. O aprendizado principal foi: problemas complexos deixam de ser assustadores quando são quebrados em partes pequenas e validados uma por uma.

A IA se torna uma aliada poderosa quando a gente a guia com contexto, escopo e validações, em vez de pedir que ela resolva tudo de uma vez.
