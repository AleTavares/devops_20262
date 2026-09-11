# Entrega — Aula 05: RDS e Remote State

**Aluno:** Carina Gonçalves dos Santos Dalpino
**RA:** 6325109
**Data:** 11/09/2026

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
- [x] Conexão EC2 → RDS via psql com dados persistentes (evidência abaixo)
- [x] `terraform destroy` executado após evidências

> **Nota sobre o backend (Learner Lab):** A Service Control Policy (SCP) do AWS Academy nega a ação `s3:GetBucketObjectLockConfiguration`, que o provider Terraform executa automaticamente ao gerenciar um bucket S3. Por isso, o bucket de state e a tabela DynamoDB foram criados via AWS CLI (comandos equivalentes ao código Terraform em `aula-05/backend/`, que fica versionado como referência). O resultado final é idêntico ao solicitado: state remoto no S3 com versionamento, encriptação, block public access e locking via DynamoDB.

---

## Recursos Provisionados (outputs reais)

```
vpc_id            = "vpc-00ba25d80afd30b63"
public_subnet_id  = "subnet-056f4049d230369cd"
private_subnet_ids = [
  "subnet-0f1af593c6ed24647",
  "subnet-0070f2c065edcd612",
]
ec2_public_ip     = "98.92.224.42"
rds_endpoint      = "technova-db.cbdvkyotiyum.us-east-1.rds.amazonaws.com:5432"
rds_database_name = "technova"
rds_port          = 5432
```

---

## Evidência do State no S3

```bash
$ aws s3 ls s3://technova-terraform-state-812c4d1b/aula-05/
2026-09-10 21:45:56      56307 terraform.tfstate

$ aws s3api get-bucket-versioning --bucket technova-terraform-state-812c4d1b
{
    "Status": "Enabled"
}

$ aws s3api get-bucket-encryption --bucket technova-terraform-state-812c4d1b
{
    "ServerSideEncryptionConfiguration": {
        "Rules": [{ "ApplyServerSideEncryptionByDefault": { "SSEAlgorithm": "AES256" } }]
    }
}

$ aws s3api get-public-access-block --bucket technova-terraform-state-812c4d1b
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

### Backend remoto funcional (terraform plan após migração)

```bash
$ terraform plan
...
No changes. Your infrastructure matches the configuration.
```

---

## Evidência da Conexão EC2 → RDS

```bash
$ ssh -i technova-key.pem ec2-user@98.92.224.42 "which psql && psql --version"
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
  1 | Maria Silva   | Laptop TechNova Pro |        1 | 4599.90 | 2026-09-11 00:35:10.869184
  2 | Joao Santos   | Monitor 27          |        2 | 2398.00 | 2026-09-11 00:35:10.869184
  3 | Ana Costa     | Teclado Mecanico    |        3 |  897.00 | 2026-09-11 00:35:10.869184
(3 rows)
```

---

## Evidência dos Dados Persistentes (após reboot do EC2)

```bash
# EC2 reiniciado via: aws ec2 reboot-instances --instance-ids i-0341551634a68e2df
# Reconectado ao RDS — os dados continuam intactos:

 total_pedidos
---------------
             3
(1 row)

 id | customer_name |       product       | quantity |  total  |         created_at
----+---------------+---------------------+----------+---------+----------------------------
  1 | Maria Silva   | Laptop TechNova Pro |        1 | 4599.90 | 2026-09-11 00:35:10.869184
  2 | Joao Santos   | Monitor 27          |        2 | 2398.00 | 2026-09-11 00:35:10.869184
  3 | Ana Costa     | Teclado Mecanico    |        3 |  897.00 | 2026-09-11 00:35:10.869184
(3 rows)
```

Isso comprova o ponto central do Lab 1: os dados vivem no RDS, independentes do ciclo de vida do EC2.

---

## Decisão Técnica — Bonus

O Security Group do RDS foi configurado para aceitar conexões **apenas do Security Group do EC2** (não do CIDR da VPC inteiro), aplicando o princípio do menor privilégio: somente instâncias com o SG `technova-ec2-sg` conseguem conectar na porta 5432.