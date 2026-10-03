# Entrega — Prova do Primeiro Bimestre

**Aluno:** Carollini Godoy dos Santos Roque  
**RA:** 3925000

## Repositório do projeto

https://github.com/caroll143/prova-primeiro-bimestre-devops

## Checklist de evidências

- [x] Repositório público com README, nome, RA e descrição do projeto
- [x] Commits seguindo o padrão Conventional Commits
- [x] Branch de feature criada e integrada por merge
- [x] Dockerfile e `.dockerignore`
- [x] Docker Compose com API e PostgreSQL
- [x] Volume nomeado para persistência do PostgreSQL
- [x] Rede bridge customizada
- [x] Healthcheck do PostgreSQL
- [x] `depends_on` com `service_healthy`
- [x] `.env.example` versionado e `.env` protegido pelo `.gitignore`
- [x] Infraestrutura Terraform modular
- [x] VPC com subnets públicas e privadas em duas AZs
- [x] Security Groups para EC2 e RDS
- [x] EC2 `t2.micro`
- [x] RDS PostgreSQL `db.t3.micro` privado e criptografado
- [x] Backend remoto Terraform com S3 e lock com DynamoDB
- [x] Uso de `LabRole` / `LabInstanceProfile`
- [x] `terraform validate` executado com sucesso
- [x] `terraform plan` executado com sucesso
- [x] API e banco validados localmente
- [x] API e RDS validados na AWS
- [x] Operações CRUD de reservas testadas
- [x] Relatório do processo e uso de IA incluídos no repositório
- [x] Infraestrutura AWS destruída após as validações
