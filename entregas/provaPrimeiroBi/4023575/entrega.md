# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Emilly Santos de Oliveira  
**RA:** 4023575  
**Data:** 01/10/2026
**Ferramenta de IA utilizada:** [Kiro / ChatGPT]

## Repositório do Projeto

- URL: https://github.com/leonidas-alt/prova-primeiro-bimestre-devops.git

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

  ### docker compose ps (ambiente local)

  NAME           IMAGE                                COMMAND                  SERVICE    CREATED          STATUS                   PORTS
  technova-api   prova-primeiro-bimestre-devops-api   "docker-entrypoint.s…"   api        14 seconds ago   Up 9 seconds (healthy)   0.0.0.0:3000->3000/tcp,
  [::]:3000->3000/tcp
  technova-db    postgres:15-alpine                   "docker-entrypoint.s…"   postgres   2 minutes ago    Up 2 minutes (healthy)   0.0.0.0:5432->5432/tcp,
  [::]:5432->5432/tcp

  ### curl /health (local)
  ```json
  {
    "status": "healthy",
    "db": "connected",
    "uptime": 362.149549949
  }

  curl /health (AWS EC2)

  {"status":"healthy","db":"connected","uptime":409.14045657}

  terraform plan

  Plan: 15 to add, 0 to change, 0 to destroy.

  Changes to Outputs:
    + api_url       = (known after apply)
    + ec2_public_ip = (known after apply)
    + rds_endpoint  = (sensitive value)
    + sg_ec2_id     = (known after apply)
    + sg_rds_id     = (known after apply)
    + vpc_id        = (known after apply)

  terraform apply outputs

  api_url       = "http://98.80.197.60:3000"
  ec2_public_ip = "98.80.197.60"
  sg_ec2_id     = "sg-018a21afa46e0a76e"
  sg_rds_id     = "sg-0a7385fa7bfd22b91"
  vpc_id        = "vpc-013325c1652480997"

  Recursos AWS provisionados

  - VPC: vpc-013325c1652480997
  - SG EC2: sg-018a21afa46e0a76e (portas 22 e 3000)
  - SG RDS: sg-0a7385fa7bfd22b91 (porta 5432 apenas do SG EC2)
  - EC2: i-0fa5a65b911b4ee2f (t2.micro, AL2023, IP: 98.80.197.60)
  - RDS: db-6C2AAA2GC4GPSH6VAYTXYEJ3SI (PostgreSQL 15, db.t3.micro, privado, criptografado)
  - S3: technova-tfstate-4023575 (remote state, versionado, AES256)
  - DynamoDB: technova-tf-lock (state locking)