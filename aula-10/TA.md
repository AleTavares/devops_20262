# Aula 10 — Trabalho Anterior (TA)

## Objetivo

Preparar-se para a Aula 10 através de leitura prévia sobre **Terraform Automatizado com GitOps** e **CD Pipelines**. Você vai aprender como infraestrutura pode ser gerenciada via Pull Requests e como construir um pipeline que deploya automaticamente.

---

## Parte 1 — Terraform Automatizado com GitOps

### 1.1 O Problema: Terraform Executado Manualmente

Nas aulas anteriores, aprendemos a usar Terraform para provisionar infraestrutura AWS. Mas até agora, o fluxo é manual:

1. Editar arquivos `.tf` no laptop
2. Rodar `terraform plan` localmente
3. Copiar output e mandar no chat do time
4. Esperar alguém dizer "ok"
5. Rodar `terraform apply` localmente
6. Torcer para não ter errado nada

Esse fluxo tem problemas graves:
- **Sem auditoria:** quem executou o apply? Quando? Com qual versão do código?
- **Sem review formal:** "ok" no chat não é revisão de infraestrutura
- **Credenciais no laptop:** credenciais AWS locais são risco de segurança
- **State divergente:** se dois devs executam ao mesmo tempo, state pode corromper
- **Sem rollback claro:** se algo quebrar, como voltar?

### 1.2 O que é GitOps?

GitOps é um princípio operacional onde o **repositório Git é a única fonte de verdade** para o estado desejado da infraestrutura e da aplicação.

Regras do GitOps:
- **Toda mudança passa por PR:** nenhuma alteração é feita diretamente
- **PR = change request:** o plan mostra exatamente o que vai mudar
- **Merge = apply:** ao aprovar e mergear, a mudança é aplicada automaticamente
- **Git = auditoria:** todo histórico fica registrado (quem, quando, o quê)
- **Nenhum humano executa comandos:** apenas o pipeline tem permissão para apply

### 1.3 O Fluxo GitOps para Terraform

O fluxo completo funciona assim:

**Ao abrir um PR que modifica arquivos `.tf`:**
1. GitHub Actions dispara o workflow `terraform-plan`
2. Workflow executa `terraform init` + `terraform plan`
3. O output do plan é formatado e postado como **comentário no PR**
4. Reviewer vê exatamente o que vai ser criado/modificado/destruído
5. Se o plan está correto → aprova o PR

**Ao fazer merge na main:**
1. GitHub Actions dispara o workflow `terraform-apply`
2. Workflow executa `terraform init` + `terraform apply -auto-approve`
3. Infraestrutura é atualizada automaticamente
4. Output do apply fica registrado nos logs do workflow

### 1.4 Autenticação GitHub → AWS: Produção vs Learner Lab

O problema de usar access keys permanentes (de longa duração):
- Se vazarem, atacante tem acesso até serem revogadas
- Precisam ser rotacionadas manualmente (e ninguém lembra)
- Armazenadas como secrets no GitHub — um ponto de falha

**O padrão ideal em produção é OIDC (OpenID Connect)**, recomendado pela AWS:
- GitHub Actions pede um **token temporário** à AWS
- AWS verifica que o pedido veio de um repositório/branch autorizado via uma **role IAM**
- Credenciais duram apenas o tempo do job
- **Nenhuma chave permanente** é armazenada em lugar nenhum

Porém, configurar OIDC exige criar dois recursos na AWS:
- **IAM OIDC Identity Provider:** diz à AWS que confie em tokens do GitHub
- **IAM Role:** role que o GitHub Actions assume, com policies para Terraform

**O AWS Academy Learner Lab não permite criar OIDC provider nem roles IAM.** Por isso, no laboratório, o fluxo real usa as **credenciais temporárias da sessão do Lab** como GitHub Secrets:
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` e `AWS_SESSION_TOKEN`
- São temporárias (expiram quando a sessão do Lab encerra) e precisam ser atualizadas a cada nova sessão

No workflow, usa-se a action `aws-actions/configure-aws-credentials` com:
```yaml
# No Learner Lab: credenciais temporárias de sessão como secrets
- uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}   # Learner Lab exige
    aws-region: us-east-1

# Em produção (fora do Lab), o ideal seria OIDC + role IAM, sem chaves:
# - uses: aws-actions/configure-aws-credentials@v4
#   with:
#     role-to-assume: arn:aws:iam::123456789012:role/github-actions-terraform
#     aws-region: us-east-1
```

### 1.5 Plan como Comentário no PR

O plan é postado no PR usando a action `actions/github-script` ou similares. O resultado mostra:
- Quantos recursos serão criados, modificados e destruídos
- Detalhes de cada alteração (qual atributo muda, de qual valor para qual)
- Formatação clara com cores/emojis para fácil leitura

Isso permite que o reviewer avalie:
- "Faz sentido criar esse security group?"
- "O instance_type mudou — isso vai aumentar custo?"
- "Vai destruir um recurso? É intencional?"

### 1.6 Segurança do Workflow de Apply

O `terraform apply` é executado com `-auto-approve` porque:
- O plan já foi revisado e aprovado no PR
- O merge na main é o "botão de aprovação"
- Não há como ter interação interativa no CI

Proteções adicionais:
- **Branch protection:** main requer PR com aprovação
- **CODEOWNERS:** mudanças em `.tf` exigem aprovação de devops
- **terraform plan output:** salvo como artefato para auditoria
- **State lock:** S3 + DynamoDB previne execuções concorrentes

---

## Parte 2 — CD Pipelines

### 2.1 O que é CD?

CD tem dois significados frequentemente confundidos:

**Continuous Delivery:**
- O pipeline prepara tudo para deploy (build, test, package)
- O deploy em produção requer uma **ação manual** (aprovação, botão)
- Garante que o software **pode** ser deployado a qualquer momento
- Usado quando há compliance, regulamentação ou releases planejados

**Continuous Deployment:**
- O pipeline faz deploy **automático** após todos os checks passarem
- Nenhuma intervenção humana entre commit e produção
- Todo commit que passa nos testes vai para produção
- Usado em SaaS, startups, iteração rápida

A diferença é sutil mas importante: Delivery = "pronto para deploy", Deployment = "deployado automaticamente".

### 2.2 Pipeline Unificado

Um pipeline CD completo integra todas as etapas em sequência:

1. **Lint** — verifica formatação e estilo do código
2. **Test** — roda testes unitários e de integração
3. **Build** — constrói a imagem Docker
4. **Push** — publica a imagem no registry (**Amazon ECR**)
5. **Deploy** — atualiza a aplicação no servidor de produção

Se qualquer etapa falhar, as seguintes não executam. Isso garante que apenas código verificado e testado chega à produção.

### 2.3 Estratégia Recreate

Existem várias estratégias de deploy. A mais simples é **Recreate**:

- **Passo 1:** Para o container atual (`docker stop`)
- **Passo 2:** Remove o container (`docker rm`)
- **Passo 3:** Faz pull da nova imagem (`docker pull`)
- **Passo 4:** Inicia novo container (`docker run`)

**Vantagens:**
- Simplicidade total — poucos comandos
- Sem conflito de portas (só um container por vez)
- Estado limpo (sem versão antiga coexistindo com nova)
- Não requer load balancer

**Desvantagens:**
- **Downtime inevitável** — entre stop e start, app fica fora
- Não adequado para apps com SLA de alta disponibilidade
- Sem rollback automático se nova versão falhar

**Quando usar Recreate:**
- Aplicações internas (dashboard, admin)
- Ambientes de staging/dev
- MVPs e startups (aceitam segundos de downtime)
- Apps com janela de manutenção

### 2.4 Deploy via SSH em GitHub Actions

Para deployar na EC2, o pipeline usa SSH:
- A **chave privada SSH** é armazenada como secret no GitHub
- A action `appleboy/ssh-action` conecta na EC2 e executa comandos
- O servidor precisa ter Docker instalado e acesso ao **Amazon ECR**

O fluxo no servidor é (fazendo login no ECR antes do pull):
```bash
REGISTRY=<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin "$REGISTRY"  # login no ECR
docker pull "$REGISTRY/technova-api:latest"   # Baixa nova imagem
docker stop technova-api || true               # Para container atual (|| true para não falhar se não existir)
docker rm technova-api || true                 # Remove container parado
docker run -d --name technova-api ...          # Inicia novo container
```

### 2.5 Health Check Pós-Deploy

Após o deploy, o pipeline verifica se a aplicação está funcionando:
- Faz requisições HTTP para o endpoint `/health`
- Tenta várias vezes com intervalo (a app pode levar segundos para iniciar)
- Se receber resposta "ok" → deploy bem-sucedido
- Se após N tentativas não responder → deploy falhou → pipeline reporta erro

Health check é fundamental porque:
- Garante que o deploy não apenas "rodou" mas está **funcional**
- Detecta problemas de configuração (variáveis de ambiente erradas, porta errada)
- Permite alertar o time imediatamente se algo deu errado

### 2.6 Rollback: Conceito e Prática

Rollback é voltar para a versão anterior quando um deploy falha.

**Nesta aula, rollback é manual:**
- Identificar o SHA/tag da versão anterior (via console do Amazon ECR)
- Conectar na EC2 via SSH
- Fazer login no ECR, parar container atual e iniciar com a imagem anterior

**Por que manual por enquanto:**
- Simplicidade — menos código, menos pontos de falha
- Aprendizado — entender o conceito antes de automatizar
- Nas próximas aulas (Blue-Green, Canary), rollback será automático

**Pré-requisito para rollback funcionar:** ter imagens versionadas no registry. Por isso usamos tags com Git SHA — sempre sabemos qual imagem corresponde a qual commit.

### 2.7 Secrets Necessários para CD

| Secret | Descrição | Onde criar |
|--------|-----------|-----------|
| `EC2_HOST` | IP público ou DNS da EC2 | GitHub Settings → Secrets |
| `EC2_SSH_KEY` | Chave privada SSH para acessar EC2 | GitHub Settings → Secrets |
| `EC2_USERNAME` | Usuário SSH (geralmente `ubuntu`) | GitHub Settings → Secrets |
| `AWS_ACCESS_KEY_ID` | Credencial temporária de sessão do Lab | GitHub Settings → Secrets |
| `AWS_SECRET_ACCESS_KEY` | Credencial temporária de sessão do Lab | GitHub Settings → Secrets |
| `AWS_SESSION_TOKEN` | Token de sessão do Lab (expira por sessão) | GitHub Settings → Secrets |

> **⚠️ Nunca commite chaves SSH, credenciais ou IPs no código.** Sempre use GitHub Secrets. As credenciais do Lab são temporárias e precisam ser atualizadas a cada nova sessão.

---

## Questões de Verificação

Responda as questões abaixo para verificar sua compreensão. Traga suas respostas para a discussão em aula.

### Questão 1

No fluxo GitOps para Terraform, qual evento dispara o `terraform apply`?

- a) Abertura de um Pull Request com modificações em arquivos `.tf`
- b) Comentário de aprovação ("LGTM") no Pull Request
- c) Merge do Pull Request na branch `main`
- d) Push direto na branch `main` sem Pull Request

### Questão 2

Por que o padrão OIDC é preferível a access keys permanentes em produção para autenticar GitHub Actions na AWS?

- a) Porque OIDC é mais rápido para autenticar
- b) Porque OIDC gera credenciais temporárias, eliminando chaves permanentes que podem vazar
- c) Porque OIDC funciona sem internet
- d) Porque OIDC permite acesso a todos os serviços AWS sem restrição

### Questão 3

Qual é a principal desvantagem da estratégia de deploy Recreate em comparação com Blue-Green?

- a) Recreate é mais complexa de implementar
- b) Recreate não permite usar Docker
- c) Recreate causa downtime inevitável entre parar o container antigo e iniciar o novo
- d) Recreate não funciona com GitHub Actions

### Questão 4

Em um pipeline CD unificado (CI→Build→Push→Deploy), o que acontece se o job de testes falhar?

- a) O deploy acontece mesmo assim, mas com um aviso
- b) Apenas o push para o registry é pulado, mas o deploy ocorre
- c) Todos os jobs seguintes (build, push, deploy) são cancelados — nada é deployado
- d) O pipeline reinicia automaticamente até os testes passarem

---

## Referências

- [Terraform CLI - Plan Command](https://developer.hashicorp.com/terraform/cli/commands/plan)
- [Terraform CLI - Apply Command](https://developer.hashicorp.com/terraform/cli/commands/apply)
- [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials)
- [aws-actions/amazon-ecr-login](https://github.com/aws-actions/amazon-ecr-login)
- [appleboy/ssh-action](https://github.com/appleboy/ssh-action)
- [Continuous Delivery vs Continuous Deployment (Atlassian)](https://www.atlassian.com/continuous-delivery/principles/continuous-integration-vs-delivery-vs-deployment)
