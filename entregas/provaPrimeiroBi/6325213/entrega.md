# Entrega - Prova do Primeiro Bimestre (DevOps)

**Aluno:** Daniel Alves Pinheiro
**RA:** 6325213
**Data:** 01/10/2026
**Ferramenta de IA utilizada:** Kiro e Claude

## Repositório do Projeto

- URL: https://github.com/dnneiil/prova-primeiro-bimestre-devops

## Checklist de Evidências

- [x] Repositório público com README (nome + RA) e .gitignore
- [x] Mínimo de 6 commits com Conventional Commits + feature branch
- [x] API com CRUD completo de reservas (POST, GET, GET/:id, PUT, DELETE) + /health
- [x] Rotas de CRUD gravando no banco PostgreSQL (não em memória)
- [x] Dockerfile funcional da API de Reservas
- [x] docker-compose.yml (API + PostgreSQL) subindo com um comando
- [x] Terraform modularizado (vpc, security-group, ec2, rds)
- [x] RDS PostgreSQL provisionado nas subnets privadas (banco da API na nuvem)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] Uso de LabRole/LabInstanceProfile (sem criar IAM próprio)
- [x] terraform validate e terraform plan sem erros
- [x] relatorio.md completo (4 questões)
- [x] Recursos da AWS destruídos após as evidências (ver observação abaixo)

## Observação sobre o destroy

Ao final, o terraform destroy não funcionou: o bucket S3 do state remoto não existia mais, então o Terraform não encontrou o state. Para não gastar créditos, apaguei os recursos pela AWS CLI (EC2, RDS, security groups, subnets, tabela de rotas, internet gateway, VPC e a tabela DynamoDB) e confirmei que não restou nada.

## Evidências

Os arquivos estão na pasta evidencias/ do repositório: docker-build.txt, compose-ps.txt, terraform-plan.txt, terraform-output.txt, api-aws.txt e api-aws-resumo.txt. Também estão no repositório o relatorio.md (4 questões) e o prompts.md (prompts usados no Kiro).

### docker compose ps

    NAME                                        SERVICE    STATUS
    prova-primeiro-bimestre-devops-api-1        api        Up 29 minutes
    prova-primeiro-bimestre-devops-postgres-1   postgres   Up 29 minutes (healthy)

### terraform plan

    Plan: 14 to add, 0 to change, 0 to destroy.

### API na AWS (RDS)

    GET /health         -> {"status":"ok"}
    POST /reservas      -> reserva criada (id 2)
    GET /reservas       -> lista com as reservas gravadas no RDS
    GET /reservas/2     -> HTTP 404 depois do DELETE# Entrega - Prova do Primeiro Bimestre (DevOps)

**Aluno:** Daniel Alves Pinheiro
**RA:** 6325213
**Data:** 01/10/2026
**Ferramenta de IA utilizada:** Kiro e Claude

## Repositório do Projeto

- URL: https://github.com/dnneiil/prova-primeiro-bimestre-devops

## Checklist de Evidências

- [x] Repositório público com README (nome + RA) e .gitignore
- [x] Mínimo de 6 commits com Conventional Commits + feature branch
- [x] API com CRUD completo de reservas (POST, GET, GET/:id, PUT, DELETE) + /health
- [x] Rotas de CRUD gravando no banco PostgreSQL (não em memória)
- [x] Dockerfile funcional da API de Reservas
- [x] docker-compose.yml (API + PostgreSQL) subindo com um comando
- [x] Terraform modularizado (vpc, security-group, ec2, rds)
- [x] RDS PostgreSQL provisionado nas subnets privadas (banco da API na nuvem)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] Uso de LabRole/LabInstanceProfile (sem criar IAM próprio)
- [x] terraform validate e terraform plan sem erros
- [x] relatorio.md completo (4 questões)
- [x] Recursos da AWS destruídos após as evidências (ver observação abaixo)

## Observação sobre o destroy

Ao final, o terraform destroy não funcionou: o bucket S3 do state remoto não existia mais, então o Terraform não encontrou o state. Para não gastar créditos, apaguei os recursos pela AWS CLI (EC2, RDS, security groups, subnets, tabela de rotas, internet gateway, VPC e a tabela DynamoDB) e confirmei que não restou nada.

## Evidências

Os arquivos estão na pasta evidencias/ do repositório: docker-build.txt, compose-ps.txt, terraform-plan.txt, terraform-output.txt, api-aws.txt e api-aws-resumo.txt. Também estão no repositório o relatorio.md (4 questões) e o prompts.md (prompts usados no Kiro).

### docker compose ps

    NAME                                        SERVICE    STATUS
    prova-primeiro-bimestre-devops-api-1        api        Up 29 minutes
    prova-primeiro-bimestre-devops-postgres-1   postgres   Up 29 minutes (healthy)

### terraform plan

    Plan: 14 to add, 0 to change, 0 to destroy.

### API na AWS (RDS)

    GET /health         -> {"status":"ok"}
    POST /reservas      -> reserva criada (id 2)
    GET /reservas       -> lista com as reservas gravadas no RDS
    GET /reservas/2     -> HTTP 404 depois do DELETE
