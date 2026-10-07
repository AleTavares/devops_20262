# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Emar Cristian Silva Teruo Ito
**RA:** 6325192
**Data da entrega:** 28/09/2026
**Ferramenta de IA utilizada:** ChatGPT

## Repositório do Projeto

- Repositório: https://github.com/iHawlKz7/prova-primeiro-bimestre-devops
- Commit final validado do projeto: `67bd51c`

## Checklist da Entrega

- [x] Repositório público com README contendo nome e RA
- [x] `.gitignore` configurado para `node_modules`, `.env`, Terraform State e chaves
- [x] Mais de 6 commits utilizando Conventional Commits
- [x] Desenvolvimento utilizando feature branch e merge
- [x] API Node.js/Express com CRUD completo de reservas
- [x] `POST /reservas`
- [x] `GET /reservas`
- [x] `GET /reservas/:id`
- [x] `PUT /reservas/:id`
- [x] `DELETE /reservas/:id`
- [x] `GET /health`
- [x] Persistência das reservas em PostgreSQL
- [x] Dockerfile multi-stage com execução como usuário não-root
- [x] `.dockerignore`
- [x] Docker Compose com API e PostgreSQL
- [x] Volume nomeado para persistência
- [x] Rede bridge própria
- [x] Healthcheck do PostgreSQL
- [x] Healthcheck da API
- [x] `depends_on` aguardando banco saudável
- [x] Terraform modularizado em `vpc`, `security-group`, `ec2` e `rds`
- [x] VPC com subnets públicas e privadas em duas AZs
- [x] EC2 `t2.micro` em subnet pública
- [x] RDS PostgreSQL `db.t3.micro` em subnets privadas
- [x] `publicly_accessible = false`
- [x] `storage_encrypted = true`
- [x] Porta 5432 do RDS permitida somente a partir do Security Group da EC2
- [x] Uso de `LabInstanceProfile`
- [x] Nenhum IAM próprio criado
- [x] Remote State utilizando S3
- [x] Versionamento e criptografia do bucket
- [x] Bloqueio de acesso público do S3
- [x] DynamoDB para locking
- [x] `terraform validate` executado com sucesso
- [x] `terraform plan` final sem alterações
- [x] CRUD validado localmente
- [x] CRUD validado na AWS
- [x] Persistência validada após reiniciar somente a API
- [x] HTTP 404 validado após exclusão
- [x] Infraestrutura destruída após coleta das evidências
- [x] S3 e DynamoDB também removidos
- [x] `relatorio.md` com as quatro questões solicitadas
- [x] Uso de IA e validação das sugestões documentados

## Evidências Finais

### Validação em clone novo

Arquivo:

- [evidencias/docker-clone-final.txt](https://github.com/iHawlKz7/prova-primeiro-bimestre-devops/blob/67bd51c/evidencias/docker-clone-final.txt)

A validação em clone novo foi executada quando o repositório estava no commit `d7e7092`.

Nesse teste foram confirmados:

- scripts com permissão de execução;
- build Docker;
- Docker Compose;
- healthcheck do PostgreSQL;
- healthcheck da API;
- CRUD completo;
- persistência após reiniciar somente a API;
- DELETE;
- HTTP 404 após a exclusão.

Entre `d7e7092` e o commit final `67bd51c`, não houve alteração em:

- `app/`;
- `docker-compose.yml`;
- infraestrutura Terraform;
- `.env.example`.

As mudanças posteriores ficaram concentradas nos scripts de deploy/destroy, documentação e evidências.

### Docker

Arquivos:

- [evidencias/docker-build.txt](https://github.com/iHawlKz7/prova-primeiro-bimestre-devops/blob/67bd51c/evidencias/docker-build.txt)
- [evidencias/compose-ps.txt](https://github.com/iHawlKz7/prova-primeiro-bimestre-devops/blob/67bd51c/evidencias/compose-ps.txt)

`compose-ps.txt` registra uma validação inicial do ambiente Docker Compose.

A validação final dos dois serviços saudáveis está registrada em:

- [evidencias/docker-clone-final.txt](https://github.com/iHawlKz7/prova-primeiro-bimestre-devops/blob/67bd51c/evidencias/docker-clone-final.txt)

A API utiliza Dockerfile multi-stage e executa como usuário não-root.

O ambiente Docker Compose contém API e PostgreSQL, volume persistente, rede própria e healthchecks.

### Deploy AWS

Arquivo:

- [evidencias/aws-deploy-final.txt](https://github.com/iHawlKz7/prova-primeiro-bimestre-devops/blob/67bd51c/evidencias/aws-deploy-final.txt)

O deploy final criou a infraestrutura através do Terraform.

O script aguardou a aplicação ficar saudável antes de declarar o deploy concluído.

Resultado do healthcheck:

    HTTP/1.1 200 OK

    {"status":"ok","database":"connected"}

O plano de criação da infraestrutura também está registrado dentro dessa evidência.

### CRUD AWS e persistência

Arquivo:

- [evidencias/aws-api-final.txt](https://github.com/iHawlKz7/prova-primeiro-bimestre-devops/blob/67bd51c/evidencias/aws-api-final.txt)

Foram validadas na EC2 as operações:

    POST /reservas
    GET /reservas
    GET /reservas/:id
    PUT /reservas/:id
    DELETE /reservas/:id
    GET /health

Depois do UPDATE, somente o container da API foi reiniciado através do AWS Systems Manager.

A reserva permaneceu disponível após o restart, comprovando a persistência no RDS PostgreSQL.

Depois do DELETE, uma nova busca pelo ID retornou:

    HTTP_STATUS=404

Resultado registrado:

    CRUD AWS + RESTART + PERSISTENCIA: OK

### Terraform Plan final

Arquivo:

- [evidencias/terraform-plan-final.txt](https://github.com/iHawlKz7/prova-primeiro-bimestre-devops/blob/67bd51c/evidencias/terraform-plan-final.txt)

Depois do deploy e dos testes foi executado novamente `terraform plan` utilizando os mesmos parâmetros.

Resultado:

    No changes. Your infrastructure matches the configuration.

Isso confirmou que a infraestrutura implantada correspondia ao código Terraform versionado.

### Remote State

Arquivo:

- [evidencias/backend-final.txt](https://github.com/iHawlKz7/prova-primeiro-bimestre-devops/blob/67bd51c/evidencias/backend-final.txt)

Foram verificados:

- S3 Versioning habilitado;
- criptografia AES256;
- Public Access Block habilitado;
- tags do projeto;
- objeto `prova/terraform.tfstate`;
- DynamoDB em estado `ACTIVE`;
- chave de locking `LockID`.

Resultado registrado:

    BACKEND REMOTO: OK

### RDS PostgreSQL

O RDS foi provisionado com:

    engine = PostgreSQL
    instance_class = db.t3.micro
    publicly_accessible = false
    storage_encrypted = true

O banco foi criado nas subnets privadas.

A porta 5432 foi permitida somente a partir do Security Group da EC2.

A aplicação utilizou conexão SSL com o RDS durante a validação na AWS.

### EC2

A aplicação foi executada em:

    EC2 t2.micro

Foi utilizado:

    LabInstanceProfile

Nenhum usuário, grupo ou role IAM próprio foi criado.

### Destroy final

Arquivo:

- [evidencias/destroy-final.txt](https://github.com/iHawlKz7/prova-primeiro-bimestre-devops/blob/67bd51c/evidencias/destroy-final.txt)

A infraestrutura principal foi destruída pelo Terraform.

Resultado:

    Destroy complete! Resources: 14 destroyed.

Depois da destruição foi confirmado:

    State principal vazio.
    EC2 removida/terminada.
    RDS removido.
    VPC removida.
    DynamoDB removido.
    Bucket S3 removido.
    Destroy completo: todos os recursos removidos

Assim, nenhum recurso utilizado pela prova permaneceu ativo no Learner Lab.

## Relatório

Arquivo:

- [relatorio.md](https://github.com/iHawlKz7/prova-primeiro-bimestre-devops/blob/67bd51c/relatorio.md)

O relatório responde às quatro questões solicitadas e documenta:

- a jornada das Aulas 01 a 07;
- o uso do ChatGPT como copiloto;
- situações em que a IA ajudou;
- sugestões da IA que precisaram ser corrigidas;
- arquitetura e segurança;
- limitações do AWS Academy Learner Lab;
- processo de validação;
- responsabilidade pela conferência dos resultados.

## Observação Final

Todas as evidências citadas acima estão versionadas no repositório público do projeto.

A infraestrutura AWS foi destruída somente depois da coleta e validação das evidências finais.
