# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Emar Cristian Silva Teruo Ito  
**RA:** 6325192  
**Data:** 01/10/2026
**Ferramenta de IA utilizada:** ChatGPT

## Repositório do Projeto

- URL: https://github.com/iHawlKz7/prova-primeiro-bimestre-devops

## Checklist de Evidências

- [x] Repositório público com README (nome + RA) e .gitignore
- [x] Mínimo de 6 commits com Conventional Commits + feature branch
- [x] API com **CRUD completo** de reservas (POST, GET, GET/:id, PUT, DELETE) + /health
- [x] Rotas de CRUD gravando no **banco PostgreSQL** (não em memória)
- [x] Dockerfile funcional da API de Reservas
- [x] docker-compose.yml (API + PostgreSQL) subindo com um comando
- [x] Terraform modularizado (vpc, security-group, ec2, rds)
- [x] **RDS PostgreSQL provisionado** nas subnets privadas (banco da API na nuvem)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] Uso de LabRole/LabInstanceProfile (sem criar IAM próprio)
- [x] terraform validate e terraform plan sem erros
- [x] relatorio.md completo (4 questões)
- [x] terraform destroy executado após evidências

## Evidências

### Docker Build

Arquivo:

    evidencias/docker-build.txt

O build da imagem da API foi executado com sucesso.

### Docker Compose

Arquivo:

    evidencias/compose-ps.txt

Resultado validado:

    reservas-api   Up
    reservas-db    Up (healthy)

A API e o PostgreSQL foram executados utilizando Docker Compose, rede própria, volume persistente e healthcheck do banco.

### API Local e AWS

Arquivo:

    evidencias/aws-api.txt

Health check validado na AWS:

    {"status":"ok","database":"connected"}

O CRUD completo também foi testado na EC2 utilizando o RDS PostgreSQL.

Foram validadas as operações:

    POST /reservas
    GET /reservas
    GET /reservas/:id
    PUT /reservas/:id
    DELETE /reservas/:id
    GET /health

Após a exclusão de uma reserva, uma nova busca pelo mesmo ID retornou HTTP 404, conforme esperado.

### Terraform Validate

Resultado:

    Success! The configuration is valid.

### Terraform Plan

Arquivos:

    evidencias/terraform-plan.txt
    evidencias/terraform-plan-final.txt

A infraestrutura foi planejada utilizando Terraform e módulos separados para:

    vpc
    security-group
    ec2
    rds

No provisionamento inicial foram planejados os recursos necessários para VPC, subnets públicas e privadas, Internet Gateway, Route Table, Security Groups, EC2 e RDS PostgreSQL.

### Terraform Outputs

Arquivo:

    evidencias/terraform-output.txt

Foram gerados outputs para:

    api_url
    ec2_public_ip
    rds_endpoint

### RDS PostgreSQL

O RDS foi provisionado com:

    engine PostgreSQL
    instance class db.t3.micro
    publicly_accessible = false
    storage_encrypted = true

O banco foi colocado nas subnets privadas.

A porta 5432 do RDS foi liberada apenas para o Security Group utilizado pela EC2.

A conexão entre a API e o RDS foi validada utilizando SSL.

### EC2

A aplicação foi executada em uma EC2 t2.micro.

Foi utilizado:

    LabInstanceProfile

Nenhum usuário, grupo ou role IAM próprio foi criado.

A API ficou acessível externamente pela porta 3000 durante a validação.

### Remote State

O Terraform State foi armazenado remotamente utilizando:

    Amazon S3
    DynamoDB

O bucket S3 foi validado com:

    Versionamento habilitado
    Criptografia AES256
    Bloqueio de acesso público
    Tags do projeto

O DynamoDB foi utilizado para locking do Terraform State.

### Histórico Git

Arquivo:

    evidencias/git-history.txt

O projeto possui feature branch, merge e commits seguindo Conventional Commits, incluindo tipos como:

    feat
    fix
    docs
    chore

### Relatório de IA

Arquivo:

    relatorio.md

O relatório contém as quatro questões solicitadas, cada uma com no mínimo 10 linhas de conteúdo.

Ferramenta de IA utilizada:

    ChatGPT

O relatório também documenta situações em que a IA ajudou e situações em que sugestões precisaram ser corrigidas durante a execução real no AWS Academy.

### Destroy

Arquivo:

    evidencias/destroy.txt

Resultado da infraestrutura principal:

    Destroy complete! Resources: 14 destroyed.

Resultado do backend:

    DynamoDB backend: destruído
    Bucket S3 backend: destruído
    Terraform state principal: vazio

Após a coleta das evidências, todos os recursos utilizados na AWS foram removidos.

Todas as evidências também estão anexadas dentro da pasta "evidencias" na raíz do projeto.