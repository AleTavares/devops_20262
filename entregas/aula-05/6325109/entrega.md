# Entrega — Aula 05: RDS e Remote State

**Aluno:** Carina Gonçalves dos Santos Dalpino
**RA:** 6325109
**Data:** 13/09/2026

---

## Repositório

- URL: https://github.com/CarinaDalpino/unifaat-devops-portfolio
- Pasta do projeto: `aula-05/`
- Pasta do backend: `aula-05/backend/`
- Evidências completas: `aula-05/evidencias/`

---

## Evidências

- [x] VPC com 1 subnet pública e 2 subnets privadas em 2 AZs
- [x] RDS PostgreSQL 15 (db.t3.micro) nas subnets privadas
- [x] EC2 t2.micro na subnet pública, com cliente psql instalado via user_data
- [x] Security Groups corretos — porta 5432 apenas do SG do EC2 (não CIDR aberto)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] State armazenado no S3 com versionamento e encriptação (evidência abaixo)
- [x] Backend S3 ativo no `providers.tf` (`encrypt = true` + `dynamodb_table`)
- [x] Conexão EC2 → RDS via psql com dados persistentes (evidência abaixo)
- [x] `terraform destroy` executado após evidências

> **Nota sobre o backend (Learner Lab):** A Service Control Policy (SCP) do AWS Academy nega a ação `s3:GetBucketObjectLockConfiguration`, que o provider Terraform executa automaticamente ao criar/atualizar (refresh) um bucket S3 — retornando `403 AccessDenied`. Por isso, o bucket de state foi criado/configurado via AWS CLI (versionamento, encriptação AES256 e block public access), enquanto a tabela DynamoDB de locking é gerenciada por Terraform em `aula-05/backend/`. O bloco `backend "s3"` fica ativo no `providers.tf` do projeto principal e o state é gravado e lido diretamente do S3 (comprovado com `aws s3 ls` + `terraform plan` = No changes). O código Terraform do bucket permanece versionado em `aula-05/backend/s3.tf` como referência do resultado desejado.

---

## Recursos Provisionados (outputs reais)

```
vpc_id            = "vpc-017dff347f97b38af"
public_subnet_id  = "subnet-0c46e8ab78943b1fe"
private_subnet_ids = [
  "subnet-09cfe5d4cc1305971",
  "subnet-0d2aaa73786acf9ed",
]
ec2_public_ip     = "3.82.3.212"
rds_endpoint      = "technova-db.cyzppgadpjvi.us-east-1.rds.amazonaws.com:5432"
rds_database_name = "technova"
rds_port          = 5432
```

---

## Evidência do State no S3

```bash
$ aws s3 ls s3://technova-terraform-state-f6c1c8ee/aula-05/
2026-09-13 18:21:27      56301 terraform.tfstate

$ aws s3api get-bucket-versioning --bucket technova-terraform-state-f6c1c8ee
{
    "Status": "Enabled"
}

$ aws s3api get-bucket-encryption --bucket technova-terraform-state-f6c1c8ee
{
    "ServerSideEncryptionConfiguration": {
        "Rules": [{ "ApplyServerSideEncryptionByDefault": { "SSEAlgorithm": "AES256" } }]
    }
}

$ aws s3api get-public-access-block --bucket technova-terraform-state-f6c1c8ee
{
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }
}
```

### DynamoDB (locking)

```bash
$ aws dynamodb describe-table --table-name technova-terraform-locks \
    --query "Table.{Name:TableName,Status:TableStatus,Key:KeySchema,Billing:BillingModeSummary.BillingMode}"
{
    "Name": "technova-terraform-locks",
    "Status": "ACTIVE",
    "Key": [ { "AttributeName": "LockID", "KeyType": "HASH" } ],
    "Billing": "PAY_PER_REQUEST"
}
```

### Backend remoto funcional (state no S3, sem cópia local)

```bash
$ ls terraform.tfstate
ls: cannot access 'terraform.tfstate': No such file or directory   # state vive no S3

$ terraform state list
aws_db_instance.main
aws_db_subnet_group.main
aws_instance.api
aws_internet_gateway.main
aws_key_pair.technova
aws_route_table.public
aws_route_table_association.public
aws_security_group.ec2
aws_security_group.rds
aws_subnet.private_1
aws_subnet.private_2
aws_subnet.public
aws_vpc.main
local_file.private_key
tls_private_key.technova

$ terraform plan
...
No changes. Your infrastructure matches the configuration.
```

---

## Evidência da Conexão EC2 → RDS

```bash
$ ssh -i technova-key.pem ec2-user@3.82.3.212 "which psql && psql --version"
/usr/bin/psql
psql (PostgreSQL) 15.19

# Conexão do EC2 ao RDS + criação de tabela e inserção:
CREATE TABLE
INSERT 0 3
                                              version
---------------------------------------------------------------------------------------------------
 PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC) 12.4.0, 64-bit
(1 row)

 id | customer_name |       product       | quantity |  total  |         created_at
----+---------------+---------------------+----------+---------+----------------------------
  1 | Maria Silva   | Laptop TechNova Pro |        1 | 4599.90 | 2026-09-13 21:22:13.239572
  2 | Joao Santos   | Monitor 27          |        2 | 2398.00 | 2026-09-13 21:22:13.239572
  3 | Ana Costa     | Teclado Mecanico    |        3 |  897.00 | 2026-09-13 21:22:13.239572
(3 rows)
```

---

## Evidência dos Dados Persistentes (após reboot do EC2)

```bash
# EC2 reiniciado via: aws ec2 reboot-instances --instance-ids i-01d17f51b80e62fed
# Reconectado ao RDS — os dados continuam intactos:

 total_pedidos
---------------
             3
(1 row)

 id | customer_name |       product       | quantity |  total  |         created_at
----+---------------+---------------------+----------+---------+----------------------------
  1 | Maria Silva   | Laptop TechNova Pro |        1 | 4599.90 | 2026-09-13 21:22:13.239572
  2 | Joao Santos   | Monitor 27          |        2 | 2398.00 | 2026-09-13 21:22:13.239572
  3 | Ana Costa     | Teclado Mecanico    |        3 |  897.00 | 2026-09-13 21:22:13.239572
(3 rows)
```

Isso comprova o ponto central do Lab 1: os dados vivem no RDS, independentes do ciclo de vida do EC2.

---

## Decisão Técnica — Bonus

O Security Group do RDS foi configurado para aceitar conexões **apenas do Security Group do EC2** (não do CIDR da VPC inteiro), aplicando o princípio do menor privilégio: somente instâncias com o SG `technova-ec2-sg` conseguem conectar na porta 5432.
