# Relatório de Execução — Aula 05: RDS e Remote State

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 10/09/2026

Este relatório documenta a execução real do Lab 1 (`aula-05-rds/`) e do Lab 2 (`aula-05-backend/`) na conta do AWS Academy Learner Lab, incluindo um problema de permissão real encontrado e como foi contornado.

---

## Lab 1 — VPC + RDS + EC2

`terraform apply` rodado em `aula-05-rds/`. 13 recursos criados sem erro:

```
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:
connection_string = "psql -h technova-db.cm3yu4zllmdf.us-east-1.rds.amazonaws.com -U technova_admin -d technova -p 5432"
ec2_public_ip     = "52.73.9.241"
rds_address       = "technova-db.cm3yu4zllmdf.us-east-1.rds.amazonaws.com"
rds_endpoint      = "technova-db.cm3yu4zllmdf.us-east-1.rds.amazonaws.com:5432"
vpc_id            = "vpc-031fda6af98ba205e"
```

### Conexão EC2 → RDS (psql)

Conectado via SSH ao EC2 (`52.73.9.241`) e de lá ao RDS pela porta 5432, dentro da VPC:

```
$ psql -h technova-db.cm3yu4zllmdf.us-east-1.rds.amazonaws.com -U technova_admin -d technova -p 5432 -c "SELECT version();"
                                              version
---------------------------------------------------------------------------------------------------
 PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC) 12.4.0, 64-bit
(1 row)
```

### Dados persistentes (seed.sql)

```
$ psql ... -f seed.sql
CREATE TABLE
INSERT 0 3
 id | customer_name |       product       | quantity |  total  |         created_at
----+---------------+---------------------+----------+---------+----------------------------
  1 | Maria Silva   | Laptop TechNova Pro |        1 | 4599.90 | 2026-09-11 00:12:21.748275
  2 | João Santos   | Monitor 27"         |        2 | 2398.00 | 2026-09-11 00:12:21.748275
  3 | Ana Costa     | Teclado Mecânico    |        3 |  897.00 | 2026-09-11 00:12:21.748275
(3 rows)
```

---

## Lab 2 — Backend S3 + DynamoDB

> **Nota de transparência:** o laboratório pede o uso do Kiro em modo Spec para gerar este código. O código de `aula-05-backend/` foi gerado com o Claude Code, não com o Kiro (o lab permite alternativa equivalente quando o Kiro não está disponível). O Lab 1 foi tentado manualmente por mim seguindo o roteiro.

### Problema real encontrado: SCP bloqueia `aws_s3_bucket` no Terraform

Ao rodar `terraform apply` em `aula-05-backend/`, o DynamoDB e a chave KMS foram criados normalmente, mas a criação do bucket S3 falhou:

```
Error: reading S3 Bucket (...) object lock configuration: operation error S3:
GetObjectLockConfiguration, ... AccessDenied: ... is not authorized to perform:
s3:GetBucketObjectLockConfiguration ... with an explicit deny in a service
control policy: arn:aws:organizations::445917269142:policy/o-.../p-...
```

**Causa:** o AWS Provider do Terraform sempre chama `GetBucketObjectLockConfiguration` ao criar ou ler um `aws_s3_bucket` (para popular o atributo computado `object_lock_configuration`). A conta do AWS Academy Learner Lab tem uma **Service Control Policy** organizacional que nega essa chamada explicitamente para qualquer usuário — não é algo que dá pra contornar no nível do código Terraform ou da IAM role do aluno.

**O que tentei:**
1. Rodar de novo (`terraform apply`) → mesmo erro.
2. Rebaixar a versão do provider AWS para `~> 4.67` → mesmo erro (a chamada existe desde muito antes da v4, faz parte do schema do recurso desde que o AWS adicionou suporte a Object Lock).
3. `terraform import` do bucket já criado → mesmo erro (import também faz um `Read`).

**Solução aplicada:** o bucket em si (`aws s3api create-bucket`, implícito na primeira tentativa de apply que criou o bucket antes de falhar no read) já existia; apliquei versionamento, encriptação (com a mesma KMS key que o Terraform criou) e bloqueio de acesso público via `aws s3api` diretamente, fora do Terraform:

```bash
aws s3api put-bucket-versioning --bucket technova-terraform-state-de3dd3e7 \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption --bucket technova-terraform-state-de3dd3e7 \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":
  {"SSEAlgorithm":"aws:kms","KMSMasterKeyID":"672381f4-af01-4958-bd76-0762bab2a455"},
  "BucketKeyEnabled":true}]}'

aws s3api put-public-access-block --bucket technova-terraform-state-de3dd3e7 \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,
  BlockPublicPolicy=true,RestrictPublicBuckets=true
```

Verificação:

```
== versioning ==        {"Status": "Enabled"}
== encryption ==         SSEAlgorithm: aws:kms, KMSMasterKeyID: 672381f4-...
== public access block == todos os 4 campos = true
```

O `terraform state` de `aula-05-backend/` ficou apenas com `aws_kms_key.state`, `aws_dynamodb_table.locks` e `random_id.bucket_suffix` — o `aws_s3_bucket.state` **não pôde ser gerenciado pelo Terraform nesta conta**, apesar de o código em `s3.tf` estar correto e funcionar normalmente em uma conta AWS sem essa SCP.

### Backend remoto migrado com sucesso

Depois disso, migrei o state do Lab 1 para o S3:

```
$ terraform init -migrate-state   (em aula-05-rds/)
Successfully configured the backend "s3"!

$ aws s3 ls s3://technova-terraform-state-de3dd3e7/aula-05/
2026-09-10 21:30:14      34846 terraform.tfstate

$ terraform plan
No changes. Your infrastructure matches the configuration.
```

O locking via DynamoDB (`technova-terraform-locks`) está configurado no backend (`dynamodb_table` em `providers.tf`) e funcional — a tabela existe e é referenciada corretamente.

---

## Resumo de evidências (para `entrega.md`)

| Requisito | Status |
|---|---|
| VPC + subnets em 2 AZs | ✅ criado |
| RDS PostgreSQL (db.t3.micro) | ✅ criado, `SELECT version()` funcionando |
| EC2 conectando ao RDS | ✅ psql via VPC funcionando |
| Dados persistentes (tabela `orders`) | ✅ 3 registros inseridos e consultados |
| Remote State (S3 + DynamoDB) | ✅ funcional, mas bucket provisionado via AWS CLI (não via `terraform apply`) por causa da SCP do lab |
| `terraform plan` limpo | ✅ "No changes" |
| `terraform destroy` após evidências | ✅ VPC/RDS/EC2 e KMS/DynamoDB destruídos; bucket S3 pendente de remoção manual (ver Cleanup) |

## Cleanup

Após capturar todas as evidências acima, destruí a infraestrutura:

- Lab 1 (VPC, RDS, EC2, etc.): `terraform destroy` — 13 recursos removidos com sucesso.
- Lab 2 (KMS key, DynamoDB table): `terraform destroy` — 3 recursos removidos com sucesso.
- Bucket S3 (`technova-terraform-state-de3dd3e7`): **não foi possível apagar automaticamente** (o assistente de IA usado teve o comando de exclusão em lote bloqueado por segurança). O bucket ainda contém apenas o `terraform.tfstate` final (vazio, pós-destroy) e ficou pendente de remoção manual:
  ```bash
  aws s3 rm s3://technova-terraform-state-de3dd3e7 --recursive
  aws s3 rb s3://technova-terraform-state-de3dd3e7
  ```
  Custo residual é desprezível (poucos KB), mas o ideal é rodar esse comando antes do Learner Lab expirar.
