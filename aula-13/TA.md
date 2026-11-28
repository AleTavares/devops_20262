# Aula 13 — Trabalho Anterior (TA)

## Objetivo

Preparar-se para a Aula 13 através de leitura prévia sobre **microserviços**, **contrato de API** e **pipeline end-to-end**. Nesta aula você vai criar um serviço completamente novo — o `technova-notifications` — aplicando de forma autônoma tudo que foi construído até aqui: código com testes, container, CI publicando no **Amazon ECR**, infraestrutura com Terraform e deploy automatizado no **AWS Academy Learner Lab**. Ao final da leitura, você deve entender *por que* decompor um sistema em microserviços, *como* dois serviços conversam por um contrato bem definido e *o que* significa um pipeline que vai do commit até a validação em produção.

> **Como estudar este material:** leia as três partes, observe os diagramas (eles resumem a arquitetura e o fluxo que você vai implementar no laboratório) e responda as questões de verificação ao final. Traga suas respostas e dúvidas para a discussão no início da aula.

---

## Parte 1 — Princípios de Microserviços

### 1.1 Do Monolito aos Serviços Independentes

Até agora a TechNova tratou o `technova-api` como um único serviço. Mas conforme um sistema cresce, concentrar tudo em uma só aplicação traz problemas: um deploy arriscado afeta o sistema inteiro, times pisam no código uns dos outros, e uma falha em uma funcionalidade pode derrubar todas as outras.

A arquitetura de **microserviços** responde a isso dividindo o sistema em serviços pequenos e independentes. Cada um tem uma responsabilidade clara e pode ser desenvolvido, testado, deployado e escalado por conta própria.

Os princípios que guiam essa divisão:

| Princípio | O que significa na prática |
|-----------|----------------------------|
| **Responsabilidade única** | Cada serviço faz uma coisa bem feita (notificar, cobrar, autenticar...) |
| **Independência de deploy** | Atualizar um serviço não exige redeployar os outros |
| **Comunicação via contrato** | Serviços conversam por APIs bem definidas, não por acesso direto ao código/banco um do outro |
| **Dados próprios** | Cada serviço gerencia seus dados (nesta aula, simplificado com armazenamento in-memory) |
| **Observabilidade** | Cada serviço expõe health check e logs estruturados |

> **Trade-off honesto:** microserviços resolvem problemas de escala e autonomia, mas adicionam complexidade (rede, latência, falhas parciais). A regra é: só divida quando o ganho de independência compensar o custo da comunicação distribuída.

### 1.2 O technova-notifications — Escopo

O novo serviço que você vai criar tem um escopo deliberadamente enxuto:

- Recebe requisições HTTP `POST` com dados de pedido
- Registra a notificação (simula o envio de email/SMS)
- Expõe um `GET` para consultar as notificações enviadas
- Tem health check próprio
- É **independente** do `technova-api`, mas **se comunica** com ele

```
┌─────────────────┐         HTTP POST          ┌──────────────────────┐
│  technova-api   │ ───────────────────────────▶│ technova-notifications│
│  (Port 3000)    │    /notifications/send      │   (Port 3001)        │
└─────────────────┘                             └──────────────────────┘
```

---

## Parte 2 — Contrato de API e Comunicação Inter-Serviço

### 2.1 O Contrato é a Fronteira

Quando dois serviços se comunicam, o que importa não é *como* cada um foi implementado por dentro, mas o **contrato** entre eles: quais rotas existem, quais dados entram e quais dados saem. O contrato é a fronteira estável que permite a cada time evoluir seu serviço livremente, desde que não quebre o acordo.

Contrato do `technova-notifications`:

| Método | Rota | Descrição |
|--------|------|-----------|
| POST | `/notifications/send` | Recebe pedido e registra notificação |
| GET | `/notifications` | Lista notificações enviadas |
| GET | `/notifications/:orderId` | Lista notificações de um pedido específico |
| GET | `/health` | Health check do serviço |

Payload do `POST /notifications/send`:

```json
{
  "orderId": "abc-123",
  "customerEmail": "cliente@email.com",
  "type": "order_created",
  "message": "Seu pedido abc-123 foi criado com sucesso"
}
```

### 2.2 Comunicação Síncrona via HTTP

Existem várias formas de serviços conversarem (HTTP/REST, mensageria, gRPC, eventos). Nesta aula usamos a mais simples e direta: **HTTP/REST síncrono**. O `technova-api`, ao criar um pedido, faz um `POST` para o `technova-notifications`.

### 2.3 Resiliência: a Falha de um não Derruba o Outro

Um ponto central da comunicação inter-serviço é **não deixar a falha de um serviço secundário quebrar o principal**. Se o serviço de notificações estiver fora do ar, o pedido ainda deve ser criado. Isso se resolve com timeout + tratamento de erro (um "circuit breaker" simplificado):

```javascript
async function sendNotification(orderData) {
  try {
    const response = await axios.post(`${NOTIFICATIONS_URL}/notifications/send`, {
      orderId: orderData.id,
      customerEmail: orderData.customerEmail,
      type: 'order_created',
      message: `Pedido ${orderData.id} criado`
    }, { timeout: 5000 });
    return { sent: true, notificationId: response.data.notification.id };
  } catch (error) {
    // Fallback: loga e segue sem falhar o pedido
    console.error(`[NOTIFICATION ERROR] ${error.message}`);
    return { sent: false, error: error.message };
  }
}
```

> **A regra de ouro:** o pedido é o fluxo crítico; a notificação é desejável, não obrigatória. O código reflete essa prioridade.

---

## Parte 3 — Pipeline End-to-End com Amazon ECR e Learner Lab

### 3.1 Do Commit à Produção em Uma Esteira

"End-to-end" significa que uma única esteira automatizada cobre todo o caminho — do código verificado até o serviço validado rodando em produção:

```
[Push] → [Lint] → [Test] → [Build Docker] → [Push Amazon ECR] → [Terraform Apply] → [Deploy] → [Health Check] → [E2E Test]
```

Cada etapa só roda se a anterior passou. Isso é o que diferencia um projeto maduro: nada vai para produção sem passar por lint, testes, build reproduzível e validação de saúde.

### 3.2 Registry: por que Amazon ECR

A imagem buildada no CI **não pode morrer no runner** (vimos isso na aula de registry). Ela precisa ser publicada versionada num registry, para que o deploy apenas faça `pull` da mesma imagem testada. O registry oficial do curso é o **Amazon ECR**, porque fica no mesmo ecossistema AWS onde a infra roda e é privado por padrão.

O login no ECR usa um token temporário (o usuário é sempre literalmente `AWS`):

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$REGISTRY"
```

No CI, o mesmo login é feito com `aws-actions/configure-aws-credentials@v4` (passando as 3 credenciais temporárias, inclusive o `aws-session-token`) seguido de `aws-actions/amazon-ecr-login@v2`.

### 3.3 Infraestrutura e Deploy no Learner Lab

A EC2 que roda o serviço é provisionada por Terraform. Para que a instância consiga fazer `docker pull` do ECR sem precisar de credenciais fixas no disco, ela recebe o **`LabInstanceProfile`** (perfil pré-existente do Lab). O `userdata` da instância faz o login no ECR e sobe o container.

> **☁️ AWS Academy Learner Lab — regras que valem para toda a aula:**
> 1. **Credenciais temporárias** (`aws_access_key_id`, `aws_secret_access_key` **e** `aws_session_token`) que **expiram por sessão** — recarregue ao reabrir o Lab.
> 2. Região fixa **`us-east-1`**.
> 3. **Sem IAM** — o Lab não permite criar user/group/role. Use as roles pré-existentes `LabRole` e `LabInstanceProfile`. **Pode criar repositórios ECR**.
> 4. Ao final de cada sessão, rode `terraform destroy` para liberar os recursos.

### 3.4 Health Check e Validação E2E

Depois do deploy, a esteira verifica o `/health` do serviço antes de considerar o deploy bem-sucedido. E um teste **end-to-end** valida a cadeia inteira: criar um pedido no `technova-api` → confirmar que a notificação apareceu no `technova-notifications`. É a prova de que os serviços, juntos, entregam o valor esperado.

---

## Questões de Verificação

Responda as questões abaixo para verificar sua compreensão. Traga suas respostas para a discussão em aula.

### Questão 1

Qual é a característica que **melhor** define a arquitetura de microserviços em relação a um monolito?

- a) Usar sempre bancos de dados NoSQL
- b) Dividir o sistema em serviços pequenos e independentes, cada um com responsabilidade única e deploy próprio
- c) Rodar todo o código em um único container maior
- d) Eliminar a necessidade de testes automatizados

### Questão 2

No `technova-notifications`, qual rota recebe os dados de um pedido para registrar a notificação?

- a) `GET /notifications`
- b) `GET /health`
- c) `POST /notifications/send`
- d) `GET /notifications/:orderId`

### Questão 3

Por que o `technova-api` deve usar `try/catch` com timeout ao chamar o `technova-notifications`?

- a) Para acelerar a criação do pedido
- b) Para que a falha ou indisponibilidade do serviço de notificações não impeça a criação do pedido (resiliência)
- c) Porque o HTTP não funciona sem try/catch
- d) Para evitar a necessidade de health check

### Questão 4

No **AWS Academy Learner Lab**, como a EC2 provisionada por Terraform consegue fazer `docker pull` de uma imagem no Amazon ECR, já que o Lab não permite criar roles IAM?

- a) Deixando a imagem pública no Docker Hub
- b) Colando as credenciais permanentes de um usuário IAM no userdata
- c) Associando o perfil pré-existente `LabInstanceProfile` à instância e fazendo login no ECR no userdata
- d) Não é possível — o Learner Lab não suporta ECR

### Questão 5

O que significa dizer que a pipeline é "end-to-end"?

- a) Que ela só roda os testes unitários
- b) Que ela cobre toda a esteira — do commit (lint/test/build/push) até o deploy, health check e validação E2E em produção
- c) Que ela faz deploy sem passar por testes
- d) Que ela publica a imagem apenas localmente, sem registry

---

> As respostas das questões serão discutidas no início da aula.

---

## Referências

### Microserviços e Arquitetura

- Richardson, Chris. **Microservices Patterns**. Disponível em: [https://microservices.io/patterns/](https://microservices.io/patterns/)
- Fowler, Martin. **Microservices**. Disponível em: [https://martinfowler.com/articles/microservices.html](https://martinfowler.com/articles/microservices.html)
- **The Twelve-Factor App (PT-BR)**. Disponível em: [https://12factor.net/pt_br/](https://12factor.net/pt_br/)

### Pipeline, Container e Registry

- Docker. **Multi-stage Builds**. Disponível em: [https://docs.docker.com/build/building/multi-stage/](https://docs.docker.com/build/building/multi-stage/)
- Amazon Web Services. **What is Amazon Elastic Container Registry?**. Disponível em: [https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
- GitHub. **About continuous integration with GitHub Actions**. Disponível em: [https://docs.github.com/en/actions/automating-builds-and-tests/about-continuous-integration](https://docs.github.com/en/actions/automating-builds-and-tests/about-continuous-integration)

### Infraestrutura como Código

- HashiCorp. **Terraform AWS Provider**. Disponível em: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
