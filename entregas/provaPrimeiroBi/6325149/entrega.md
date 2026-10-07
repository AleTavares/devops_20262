# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Gabriel Reis Cunha  
**RA:** 6325149  
**Data:** 01/10/2026
**Ferramenta de IA utilizada:** Claude Code

## Repositório do Projeto

- URL: https://github.com/gabrielreis354/prova-primeiro-bimestre-devops

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

### Git: feature branch + merge --no-ff (git log --graph)

```
*   95a675f (HEAD -> main) merge: integra feature/api-reservas na main
|\  
| * 6ecbfde (feature/api-reservas) docs: aprova revisão do plan (T27) e registra prompt P20
| * 0c0f8bf docs: atualiza README, cria rascunho do relatório e corrige datas
| * 28357d1 docs: marca tarefas do dia 5 e registra prompts P17-P18
| * 526a4fd docs: adiciona evidências de validate, plan e pré-checagem AWS
```

### docker compose ps (API + PostgreSQL saudáveis)

```
NAME                                   IMAGE                                COMMAND                  SERVICE   CREATED          STATUS                    PORTS
prova-primeiro-bimestre-devops-api-1   prova-primeiro-bimestre-devops-api   "docker-entrypoint.s…"   api       45 seconds ago   Up 20 seconds (healthy)   0.0.0.0:3100->3000/tcp, [::]:3100->3000/tcp
prova-primeiro-bimestre-devops-db-1    postgres:16-alpine                   "docker-entrypoint.s…"   db        45 seconds ago   Up 20 seconds (healthy)   5432/tcp
```

### Persistência do volume (containers recriados, dados mantidos)

```
$ docker compose up -d && cria reserva "Volume pgdata"
 Container prova-primeiro-bimestre-devops-db-1  Healthy
 Container prova-primeiro-bimestre-devops-api-1  Started
{"id":4,"cliente":"Volume pgdata","data":"2026-10-01T11:00:00.000Z","status":"pendente"}
$ docker compose down   (remove containers e rede; volume preservado)
 Container prova-primeiro-bimestre-devops-api-1  Removed
 Container prova-primeiro-bimestre-devops-db-1  Removed
 Network prova-primeiro-bimestre-devops_reservas-net  Removed
$ docker ps -a --filter name=prova-primeiro  -> (containers removidos)
0
$ docker volume ls --filter name=pgdata
DRIVER    VOLUME NAME
local     prova-primeiro-bimestre-devops_pgdata
$ docker compose up -d   (containers NOVOS, mesmo volume)
 Container prova-primeiro-bimestre-devops-db-1  Started
 Container prova-primeiro-bimestre-devops-db-1  Healthy
 Container prova-primeiro-bimestre-devops-api-1  Started
$ curl /reservas
[{"id":3,"cliente":"Persistente","data":"2026-10-01T09:00:00.000Z","status":"pendente"},{"id":4,"cliente":"Volume pgdata","data":"2026-10-01T11:00:00.000Z","status":"pendente"}]
```

### terraform validate e terraform plan

```
Success! The configuration is valid.
Plan: 19 to add, 0 to change, 0 to destroy.

module.ec2.aws_instance.this
module.rds.aws_db_instance.this
module.rds.aws_db_subnet_group.this
module.sg_ec2.aws_security_group.this
module.sg_ec2.aws_vpc_security_group_egress_rule.all
module.sg_ec2.aws_vpc_security_group_ingress_rule.this["api"]
module.sg_ec2.aws_vpc_security_group_ingress_rule.this["ssh"]
module.sg_rds.aws_security_group.this
module.sg_rds.aws_vpc_security_group_egress_rule.all
module.sg_rds.aws_vpc_security_group_ingress_rule.this["postgres"]
module.vpc.aws_internet_gateway.this
module.vpc.aws_route_table.public
module.vpc.aws_route_table_association.public[0]
module.vpc.aws_route_table_association.public[1]
module.vpc.aws_subnet.private[0]
module.vpc.aws_subnet.private[1]
module.vpc.aws_subnet.public[0]
module.vpc.aws_subnet.public[1]
module.vpc.aws_vpc.this
```

### terraform apply e outputs

```
Apply complete! Resources: 19 added, 0 changed, 0 destroyed.

Outputs:

api_url = "http://184.73.36.174:3000"
ec2_public_ip = "184.73.36.174"
rds_endpoint = "technova-reservas-db.cimmjpk2vbqt.us-east-1.rds.amazonaws.com:5432"
APPLY_EXIT=0
```

### CRUD contra a API na EC2 (grava no RDS)

```
OK    GET /health (HTTP 200)
OK    POST /reservas (status padrão) (HTTP 201)
OK    GET /reservas lista (HTTP 200)
OK    GET /reservas/:id (HTTP 200)
OK    PUT /reservas/:id (HTTP 200)
OK    GET após PUT reflete a alteração (HTTP 200)
...
OK    GET id acima do limite (HTTP 400)
OK    POST JSON malformado (HTTP 400)
SMOKE OK: todos os testes passaram.

# Persistência no RDS: cria uma reserva e lê de volta
{"id":2,"cliente":"Prova RDS","data":"2026-10-01T10:00:00.000Z","status":"confirmada"}
[{"id":2,"cliente":"Prova RDS","data":"2026-10-01T10:00:00.000Z","status":"confirmada"}]
```

### RDS privado e criptografado

```
RDS (banco da API na nuvem)
--------------------------------------------------------
|                  DescribeDBInstances                 |
+---------------------+--------------------------------+
|  Class              |  db.t3.micro                   |
|  Engine             |  postgres                      |
|  Id                 |  technova-reservas-db          |
|  MultiAZ            |  False                         |
|  PubliclyAccessible |  False                         |
|  Status             |  available                     |
|  Storage            |  20                            |
|  StorageEncrypted   |  True                          |
|  SubnetGroup        |  technova-reservas-db-subnets  |
|  Version            |  16.13                         |
+---------------------+--------------------------------+
Subnets do subnet group (privadas):
subnet-00c56bf5249f619f3	us-east-1a	False	private
subnet-0812f236656f4211c	us-east-1b	False	private
```

### Security Groups (5432 só a partir do SG da EC2)

```
Security Groups (regras de entrada)
[
    {
        "Nome": "technova-reservas-rds-sg",
        "Entrada": [
            {
                "Porta": 5432,
                "CIDR": [],
                "DeSG": [
                    "sg-0a9fbd694ca257fd7"
                ]
            }
        ]
    },
    {
        "Nome": "technova-reservas-ec2-sg",
        "Entrada": [
            {
                "Porta": 22,
                "CIDR": [
                    "<SEU-IP>/32"
                ],
                "DeSG": []
            },
            {
                "Porta": 3000,
                "CIDR": [
                    "0.0.0.0/0"
                ],
                "DeSG": []
            }
        ]
    }
]
```

### LabInstanceProfile e nenhum recurso IAM criado

```
EC2: id | tipo | instance profile | IP | key pair
i-00e427484dd4f3867	t2.micro	arn:aws:iam::<account-id>:instance-profile/LabInstanceProfile	184.73.36.174	vockey

terraform state list (nenhum recurso IAM)
module.ec2.data.aws_ssm_parameter.al2023
module.ec2.aws_instance.this
module.rds.aws_db_instance.this
module.rds.aws_db_subnet_group.this
module.sg_ec2.aws_security_group.this
module.sg_ec2.aws_vpc_security_group_egress_rule.all
module.sg_ec2.aws_vpc_security_group_ingress_rule.this["api"]
module.sg_ec2.aws_vpc_security_group_ingress_rule.this["ssh"]
module.sg_rds.aws_security_group.this
module.sg_rds.aws_vpc_security_group_egress_rule.all
module.sg_rds.aws_vpc_security_group_ingress_rule.this["postgres"]
module.vpc.aws_internet_gateway.this
module.vpc.aws_route_table.public
module.vpc.aws_route_table_association.public[0]
module.vpc.aws_route_table_association.public[1]
module.vpc.aws_subnet.private[0]
module.vpc.aws_subnet.private[1]
module.vpc.aws_subnet.public[0]
module.vpc.aws_subnet.public[1]
module.vpc.aws_vpc.this
0   <- linhas "aws_iam" em terraform state list (grep -c)
```

### Remote state: S3 (versionado e criptografado) + DynamoDB (lock)

```
State remoto no S3
2026-09-26 10:37:54      43106 prova/terraform.tfstate

Bucket do state: versionamento, criptografia, block public access
{
    "Status": "Enabled"
}
{
    "SSEAlgorithm": "AES256"
}
{
    "BlockPublicAcls": true,
    "IgnorePublicAcls": true,
    "BlockPublicPolicy": true,
    "RestrictPublicBuckets": true
}

DynamoDB de lock
-------------------------------------------------------
|                    DescribeTable                    |
+--------+-------------------+------+---------+-------+
|  Chave |       Nome        | RCU  | Status  |  WCU  |
+--------+-------------------+------+---------+-------+
|  LockID|  technova-tflock  |  1   |  ACTIVE |  1    |
+--------+-------------------+------+---------+-------+
Itens da tabela durante um 'terraform plan -refresh-only' (lock/digest do state):
technova-tfstate-6325149-<account-id>/prova/terraform.tfstate-md5

Lock capturado (recaptura em 26/09/2026, com o backend recriado por bootstrap.sh)
Na primeira captura só apareceu o digest "-md5": o meu loop parava no primeiro item da tabela, antes de o lock ser gravado.
Recapturado esperando o item cujo LockID NÃO termina em "-md5", durante um `terraform plan -refresh-only` em segundo plano:
  LockID    = <bucket>/prova/terraform.tfstate
  Info      = {"Operation":"OperationTypePlan","Path":"<bucket>/prova/terraform.tfstate","Version":"1.15.9", ...}
Comprova o locking via DynamoDB (o lock existe só enquanto a operação roda; o item "-md5" é o digest do state).
```

### terraform destroy

```
$ terraform plan -destroy -out=tfplan  →  Plan: 0 to add, 0 to change, 19 to destroy.
Apply complete! Resources: 0 added, 0 changed, 19 destroyed.
```

### Verificação pós-destroy (nada restou na AWS)

```
$ aws ec2 describe-instances --filters Name=instance-state-name,Values=pending,running,stopping,stopped,shutting-down --query Reservations[].Instances[].InstanceId --output json
[]
$ aws rds describe-db-instances --query DBInstances[].DBInstanceIdentifier --output json
[]
$ aws ec2 describe-vpcs --filters Name=is-default,Values=false --query Vpcs[].VpcId --output json
[]
$ aws ec2 describe-volumes --query Volumes[].VolumeId --output json
[]
$ aws ec2 describe-addresses --query Addresses[].AllocationId --output json
[]
$ aws ec2 describe-network-interfaces --query NetworkInterfaces[].NetworkInterfaceId --output json
[]
$ aws ec2 describe-nat-gateways --filter Name=state,Values=pending,available --query NatGateways[].NatGatewayId --output json
[]
$ aws s3api list-buckets --query Buckets[].Name --output json
[]
$ aws dynamodb list-tables --query TableNames --output json
[]
```

Evidências completas no repositório, pasta `evidencias/`.
