# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Carina Gonçalves dos Santos Dalpino
**RA:** 6325109
**Data:** 01/10/2026
**Ferramenta de IA utilizada:** Kiro

## Repositório do Projeto

- URL: https://github.com/CarinaDalpino/prova-primeiro-bimestre-devops

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
- [x] Uso de LabInstanceProfile (sem criar IAM próprio)
- [x] terraform validate e terraform plan sem erros
- [x] relatorio.md completo (4 questões)
- [x] terraform destroy executado após evidências

## Evidências

As evidências completas (outputs em texto + prints) estão na pasta `evidencias/` do
repositório do projeto: https://github.com/CarinaDalpino/prova-primeiro-bimestre-devops/tree/main/evidencias

### docker compose ps (ambiente local)
```
NAME           IMAGE                                SERVICE   STATUS
reservas-api   prova-primeiro-bimestre-devops-api   api       Up  0.0.0.0:3000->3000/tcp
reservas-db    postgres:15-alpine                   db        Up (healthy)  5432/tcp
```

### CRUD gravando no PostgreSQL (local)
```
HEALTH:  {"status":"healthy","db":"connected"}
CREATE:  {"id":1,"cliente":"Maria Silva","data":"2026-10-15","status":"confirmada"}
VALIDACAO (sem cliente): {"erro":"Os campos 'cliente' e 'data' sao obrigatorios."}  (400)
READ inexistente: {"erro":"Reserva nao encontrada."}  (404)
UPDATE: {"id":2,...,"status":"cancelada"}
DELETE: {"mensagem":"Reserva removida com sucesso.",...}
```

### terraform plan (infra na AWS Academy)
```
Plan: 19 to add, 0 to change, 0 to destroy.
(VPC, 4 subnets em 2 AZs, IGW, route table, 2 SGs, EC2 t2.micro, RDS db.t3.micro, DB subnet group)
```

### terraform apply + API no EC2 conectada ao RDS
```
Apply complete! Resources: 19 added, 0 changed, 0 destroyed.
ec2_public_ip = "98.88.77.85"
rds_endpoint  = "reservas-prod-db...us-east-1.rds.amazonaws.com:5432"

# API rodando no EC2 e conectada ao RDS na nuvem:
HEALTH: {"status":"healthy","db":"connected"}
CRUD completo (POST/GET/GET:id/PUT/DELETE) testado gravando no RDS.
```

### RDS seguro
```
db.t3.micro | postgres | PubliclyAccessible=False | StorageEncrypted=True | available
```

### Remote State (S3 + DynamoDB)
```
S3: reservas-tfstate-XXXXXXXX (versionamento Enabled, encriptacao AES256, block public access)
DynamoDB: reservas-terraform-locks (LockID, PAY_PER_REQUEST)
```

### terraform destroy
```
Destroy complete! Resources: 19 destroyed.
(bucket S3, tabela DynamoDB e key pair tambem removidos - conta limpa)
```

> Observação: no AWS Academy Learner Lab, a SCP bloqueia a criação do bucket S3 via
> Terraform (leitura de object lock). O bucket foi criado via AWS CLI com versionamento,
> encriptação e block public access; a tabela DynamoDB foi criada via Terraform.
> Foi usado o LabInstanceProfile (sem criar IAM próprio) e a região us-east-1.