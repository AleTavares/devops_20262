# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Weslley Lucas Souza Alves  
**RA:** 6325226  
**Data:** 01/10/2026
**Ferramenta de IA utilizada:** Claude (Claude Code, modelo Claude Opus 5.5)

## Repositório do Projeto

- URL: https://github.com/lucaskenway/prova-primeiro-bimestre-devops

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

Todos os arquivos completos estão na pasta [`evidencias/`](https://github.com/lucaskenway/prova-primeiro-bimestre-devops/tree/main/evidencias) do repositório do projeto.
O relatório está em [`relatorio.md`](https://github.com/lucaskenway/prova-primeiro-bimestre-devops/blob/main/relatorio.md).

### docker build — [`docker-build.txt`](https://github.com/lucaskenway/prova-primeiro-bimestre-devops/blob/main/evidencias/docker-build.txt)

```
 ---> Removed intermediate container fb51869f6dd5
 ---> 2b3fba083d15
Successfully built 2b3fba083d15
Successfully tagged api-reservas:latest
```

### docker compose ps — [`testes-locais.txt`](https://github.com/lucaskenway/prova-primeiro-bimestre-devops/blob/main/evidencias/testes-locais.txt)

A porta 3001 no host é porque a 3000 do meu computador estava ocupada por outro projeto (`PORT=3001`).

```
NAME           IMAGE                 STATUS                    PORTS
reservas-api   api-reservas:latest   Up 5 seconds (healthy)    0.0.0.0:3001->3000/tcp, [::]:3001->3000/tcp
reservas-db    postgres:16-alpine    Up 11 seconds (healthy)   5432/tcp
```

### Testes locais (CRUD, validações e /health) — [`testes-locais.txt`](https://github.com/lucaskenway/prova-primeiro-bimestre-devops/blob/main/evidencias/testes-locais.txt)

```
$ curl -s -w ' [HTTP %{http_code}]' localhost:3001/health
{"status":"ok","db":"ok"} [HTTP 200]

$ curl -s -w ' [HTTP %{http_code}]' -X PUT localhost:3001/reservas/24 -H 'Content-Type: application/json' -d '{"cliente":"Joao Souza Jr","data":"2026-10-03T20:00:00Z"}'  # sem status: mantém confirmada
{"id":24,"cliente":"Joao Souza Jr","data":"2026-10-03T20:00:00.000Z","status":"confirmada"} [HTTP 200]

$ curl -s -w ' [HTTP %{http_code}]' -X POST localhost:3001/reservas -H 'Content-Type: application/json' -d '{"cliente":"Ana","data":"01/10/2026"}'  # não ISO 8601
{"erro":"data inválida (use ISO 8601, ex: 2026-10-01T14:00:00Z)"} [HTTP 400]

$ docker compose stop db 2>&1
$ curl -s -m 10 -w ' [HTTP %{http_code}]' localhost:3001/health
{"status":"erro","db":"indisponivel"} [HTTP 503]
```

### terraform validate — [`terraform-validate.txt`](https://github.com/lucaskenway/prova-primeiro-bimestre-devops/blob/main/evidencias/terraform-validate.txt)

```
$ cd infra && terraform validate
Success! The configuration is valid.

$ cd infra/backend && terraform validate
Success! The configuration is valid.
```

### Infraestrutura na AWS (Learner Lab, us-east-1)

Ciclo completo feito em 01/10: plan → apply → testes → destroy.
O bucket do state se chama `prova-devops-tfstate-6325226-b` (nomes de bucket S3 são globais e o nome original já estava em uso)
e foi passado com `terraform init -backend-config="bucket=..."`, sem alterar o código.

### Remote State (S3 + DynamoDB) — [`remote-state.txt`](https://github.com/lucaskenway/prova-primeiro-bimestre-devops/blob/main/evidencias/remote-state.txt)

```
$ aws s3api get-bucket-versioning --bucket prova-devops-tfstate-6325226-b
{
    "Status": "Enabled"
}

$ aws s3api get-bucket-encryption --bucket prova-devops-tfstate-6325226-b
                    "SSEAlgorithm": "AES256"

$ aws dynamodb describe-table --table-name terraform-state-lock ...
    "Nome": "terraform-state-lock",
    "Status": "ACTIVE",
    "Chave": "LockID"
```

### terraform plan — [`terraform-plan.txt`](https://github.com/lucaskenway/prova-primeiro-bimestre-devops/blob/main/evidencias/terraform-plan.txt)

```
# module.ec2.aws_instance.this will be created
# module.rds.aws_db_instance.this will be created
# module.rds.aws_db_subnet_group.this will be created
# module.security_group.aws_security_group.ec2 will be created
# module.security_group.aws_security_group.rds will be created
# module.vpc.aws_internet_gateway.this will be created
# module.vpc.aws_route_table.private will be created
# module.vpc.aws_route_table.public will be created
# module.vpc.aws_route_table_association.private[0] will be created
# module.vpc.aws_route_table_association.private[1] will be created
# module.vpc.aws_route_table_association.public[0] will be created
# module.vpc.aws_route_table_association.public[1] will be created
# module.vpc.aws_subnet.private[0] will be created
# module.vpc.aws_subnet.private[1] will be created
# module.vpc.aws_subnet.public[0] will be created
# module.vpc.aws_subnet.public[1] will be created
# module.vpc.aws_vpc.this will be created
Plan: 17 to add, 0 to change, 0 to destroy.
```

### terraform apply — [`terraform-apply.txt`](https://github.com/lucaskenway/prova-primeiro-bimestre-devops/blob/main/evidencias/terraform-apply.txt)

O primeiro apply criou 15 recursos; o computador entrou em suspensão durante a criação do RDS e o Terraform
ficou esperando mesmo com o RDS já `available`. Interrompi com Ctrl+C (o state foi salvo e o lock liberado),
removi o `tainted` do RDS com `terraform untaint` e o segundo apply criou só a EC2:

```
Resource instance module.rds.aws_db_instance.this has been successfully untainted.
Plan: 1 to add, 0 to change, 0 to destroy.
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

### terraform output — [`terraform-output.txt`](https://github.com/lucaskenway/prova-primeiro-bimestre-devops/blob/main/evidencias/terraform-output.txt)

```
api_url = "http://ec2-3-86-96-150.compute-1.amazonaws.com:3000"
ec2_public_ip = "3.86.96.150"
rds_endpoint = "prova-devops-postgres.cwaqxueqmojr.us-east-1.rds.amazonaws.com:5432"
vpc_id = "vpc-0a9ca6bee9ccb8368"
```

### Recursos na AWS — [`aws-recursos.txt`](https://github.com/lucaskenway/prova-primeiro-bimestre-devops/blob/main/evidencias/aws-recursos.txt)

```
$ aws resourcegroupstaggingapi get-resources --tag-filters Key=Projeto,Values=prova-devops --query 'ResourceTagMappingList[].ResourceARN' --output table
-------------------------------------------------------------------------------
|                                GetResources                                 |
+-----------------------------------------------------------------------------+
|  arn:aws:ec2:us-east-1:377871695195:subnet/subnet-020260fcf9bcaa3f2         |
|  arn:aws:ec2:us-east-1:377871695195:subnet/subnet-09bf1c82776270b46         |
|  arn:aws:ec2:us-east-1:377871695195:security-group/sg-0d6a4b3a7ecdd7ac3     |
|  arn:aws:ec2:us-east-1:377871695195:subnet/subnet-00a6ee8a233743d6e         |
|  arn:aws:ec2:us-east-1:377871695195:volume/vol-0637b4fb6ce9d9c70            |
|  arn:aws:ec2:us-east-1:377871695195:internet-gateway/igw-0e7642495af94f777  |
|  arn:aws:ec2:us-east-1:377871695195:security-group/sg-0da2843a49d982abd     |
|  arn:aws:ec2:us-east-1:377871695195:instance/i-042035045c988d699            |
|  arn:aws:rds:us-east-1:377871695195:subgrp:prova-devops-db-subnet-group     |
|  arn:aws:ec2:us-east-1:377871695195:subnet/subnet-0a0383250485ae675         |
|  arn:aws:rds:us-east-1:377871695195:db:prova-devops-postgres                |
|  arn:aws:dynamodb:us-east-1:377871695195:table/terraform-state-lock         |
|  arn:aws:ec2:us-east-1:377871695195:subnet/subnet-0d3e21cb9d5f9c28c         |
|  arn:aws:ec2:us-east-1:377871695195:vpc/vpc-0a9ca6bee9ccb8368               |
|  arn:aws:ec2:us-east-1:377871695195:route-table/rtb-00a32ee6c11909edb       |
|  arn:aws:ec2:us-east-1:377871695195:route-table/rtb-0a28dad270350c568       |
+-----------------------------------------------------------------------------+
```

### RDS (privado e criptografado) — [`rds.txt`](https://github.com/lucaskenway/prova-primeiro-bimestre-devops/blob/main/evidencias/rds.txt)

```
Classe: db.t3.micro
Criptografado: true
Engine: postgres
Publico: false
Status: available
SubnetGroup: prova-devops-db-subnet-group
Versao: '16.13'

# DNS público: o endpoint do RDS resolve para um IP privado da subnet privada
Respostas: ['10.0.12.126']
```

### Security Groups — [`security-groups.txt`](https://github.com/lucaskenway/prova-primeiro-bimestre-devops/blob/main/evidencias/security-groups.txt)

```
- Entrada:
  - CIDR: []
    DeSG:
    - sg-0d6a4b3a7ecdd7ac3
    Porta: 5432
  Id: sg-0da2843a49d982abd
  SG: prova-devops-rds-sg
- Entrada:
  - CIDR:
    - 45.175.114.197/32
    DeSG: []
    Porta: 22
  - CIDR:
    - 0.0.0.0/0
    DeSG: []
    Porta: 3000
  Id: sg-0d6a4b3a7ecdd7ac3
  SG: prova-devops-ec2-sg
```

### CRUD na nuvem (EC2 → RDS) — [`crud-nuvem.txt`](https://github.com/lucaskenway/prova-primeiro-bimestre-devops/blob/main/evidencias/crud-nuvem.txt)

```
$ curl http://ec2-3-86-96-150.compute-1.amazonaws.com:3000/health
{"status":"ok","db":"ok"} [HTTP 200]

$ curl -X POST .../reservas -d '{"cliente":"Maria Silva","data":"2026-10-01T14:00:00Z"}'
{"id":1,"cliente":"Maria Silva","data":"2026-10-01T14:00:00.000Z","status":"pendente"} [HTTP 201]

$ curl -X POST .../reservas -d '{"cliente":"Joao Souza","data":"2026-10-02T19:30:00Z","status":"confirmada"}'
{"id":2,"cliente":"Joao Souza","data":"2026-10-02T19:30:00.000Z","status":"confirmada"} [HTTP 201]

$ curl .../reservas/1
{"id":1,"cliente":"Maria Silva","data":"2026-10-01T14:00:00.000Z","status":"pendente"} [HTTP 200]

$ curl -X PUT .../reservas/2 -d '{"cliente":"Joao Souza Jr","data":"2026-10-03T20:00:00Z"}'   # sem status: mantém confirmada
{"id":2,"cliente":"Joao Souza Jr","data":"2026-10-03T20:00:00.000Z","status":"confirmada"} [HTTP 200]

$ curl -X DELETE .../reservas/1
 [HTTP 204]

$ curl .../reservas/1
{"erro":"Reserva não encontrada"} [HTTP 404]

$ curl -X POST .../reservas -d '{"cliente":"Ana","data":"01/10/2026"}'   # não ISO 8601
{"erro":"data inválida (use ISO 8601, ex: 2026-10-01T14:00:00Z)"} [HTTP 400]
```

### terraform destroy — [`terraform-destroy.txt`](https://github.com/lucaskenway/prova-primeiro-bimestre-devops/blob/main/evidencias/terraform-destroy.txt)

```
Destroy complete! Resources: 17 destroyed.
```
