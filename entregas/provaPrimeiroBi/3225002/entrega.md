# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** José Henrique Teixeira Luiz
**RA:** 3225002
**Data:** 01/10/2026
**Ferramenta de IA utilizada:** Claude (Claude Code)

## Repositório do Projeto

- URL: https://github.com/zzin742/prova-primeiro-bimestre-devops

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
- [x] registro da conversa com a IA (`ia/registro-conversa.md`)
- [x] terraform destroy executado após evidências

Executado no **AWS Academy Learner Lab**, conta `447916381827`, região
`us-east-1`, em 26/09/2026.

## Evidências

Todas em [`evidencias/`](https://github.com/zzin742/prova-primeiro-bimestre-devops/tree/main/evidencias):

| Arquivo | Conteúdo |
|---------|----------|
| `../ia/registro-conversa.md` | prompts, respostas da IA e erros dela |
| `docker-build.txt` | build multi-stage da imagem da API |
| `compose-ps.txt` | API + PostgreSQL no ar, ambos healthy |
| `crud-local.txt` | ciclo CRUD completo persistindo no PostgreSQL |
| `terraform-validate.txt` | validate da raiz e do backend |
| `terraform-plan.txt` | plan completo dos recursos AWS |
| `terraform-apply.txt` | apply real no Learner Lab |
| `crud-nuvem.txt` | CRUD contra a EC2, gravando no RDS |
| `rds-privado.txt` | prova de que a 5432 não responde de fora da VPC |
| `terraform-destroy.txt` | destroy e conta limpa |

### Resumo

**Ambiente local (Docker Compose)** — API + PostgreSQL, ambos `healthy`:

```
NAME           IMAGE                STATUS                    PORTS
reservas-api   api-reservas:prova   Up 41 seconds (healthy)   0.0.0.0:3000->3000/tcp
reservas-db    postgres:16-alpine   Up 47 seconds (healthy)   5432/tcp
```

O banco não publica porta no host: quem fala com ele é a API, pela rede interna.

**Terraform** — 5 recursos no backend do remote state, 21 na infraestrutura:

```
$ terraform apply tfplan
Apply complete! Resources: 21 added, 0 changed, 0 destroyed.

Outputs:
url_api      = "http://18.209.177.174:3000"
endpoint_rds = "reservas-3225002-postgres.cn8ygd1xyesf.us-east-1.rds.amazonaws.com:5432"
vpc_id       = "vpc-0cff49bae58fd4deb"
```

**API na nuvem gravando no RDS** — 9 verificações do CRUD, todas passando:

```
$ curl -s http://18.209.177.174:3000/health
{"status":"ok","banco":"conectado"}

OK   GET  /health -> 200          OK   GET  /reservas/999999 -> 404
OK   POST /reservas cria -> 201   OK   PUT  /reservas/1 -> 200
OK   POST invalido -> 400         OK   DELETE /reservas/1 -> 204
OK   GET  /reservas -> 200        OK   GET  /reservas/1 apos delete -> 404
OK   GET  /reservas/1 -> 200
```

**Prova de que os dados estão no RDS, não em memória** — o container da API foi
reiniciado e os registros continuaram lá; consulta direta ao banco, feita de
dentro da EC2:

```
 current_database |                     version
------------------+--------------------------------------------------
 reservas         | PostgreSQL 16.13 on x86_64-pc-linux-gnu ...

 id |      cliente      |    data    |   status
----+-------------------+------------+------------
  2 | Jose Henrique     | 2026-10-01 | confirmada
  3 | Prova 1o Bimestre | 2026-10-01 | pendente
```

**RDS fechado para fora da VPC** — o DNS resolve para um IP privado e a conexão
não completa:

```
$ dig +short ...rds.amazonaws.com
10.0.101.66                      <- subnet privada 10.0.101.0/24

$ nc -z -v -w 10 ...rds.amazonaws.com 5432
nc: connectx to ... port 5432 (tcp) failed: Operation timed out

PubliclyAccessible: false        StorageEncrypted: true
SubnetGroup AZs:    us-east-1a, us-east-1b
```

E a regra da porta 5432 não libera CIDR nenhum — a origem é o Security Group
da EC2:

```
|  CIDR      |  None                              |
|  Porta     |  5432                              |
|  SG_Origem |  sg-0e7d0b3b1cc76879b              |   <- SG da EC2
```

**Uso de `LabRole` / `LabInstanceProfile`** — zero recursos IAM no plan:

```
IAM a criar:  0   (o Learner Lab nega iam:CreateRole)
```

**`terraform destroy` e conta limpa** — 26 recursos removidos (21 da
infraestrutura + 5 do backend), e nenhum sobrou:

```
Destroy complete! Resources: 21 destroyed.
Destroy complete! Resources: 5 destroyed.

$ aws ec2 describe-instances   (nao terminadas)  -> (nenhuma)
$ aws rds describe-db-instances                  -> (nenhuma)
$ aws ec2 describe-vpcs        (nao-default)     -> (nenhuma)
$ aws s3 ls | grep tfstate                       -> (nenhum bucket)
$ aws dynamodb list-tables                       -> (nenhuma tabela)
```
