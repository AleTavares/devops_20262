# Entrega — Aula 05: RDS e Remote State

**Aluno:** Sirlande Martins
**RA:** 6325269
**Data:** 10/09/2026

## Repositório

- URL: https://github.com/Sir-Jr/unifaat-devops-portfolio

## Evidências

- [x] VPC com subnets públicas e privadas em 2 AZs
- [x] RDS PostgreSQL (db.t3.micro) nas subnets privadas
- [x] EC2 t2.micro na subnet pública, conectando ao RDS
- [x] Security Groups corretos (porta 5432 restrita ao Security Group do EC2, mais restritivo que liberar toda a VPC)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] State armazenado no S3 (evidência abaixo)
- [x] Conexão EC2 → RDS via psql (evidência abaixo)
- [x] `terraform destroy` executado após evidências

## Evidência do State no S3

```
$ aws s3 ls s3://technova-terraform-state-d849bd92/aula-05/
2026-09-10 21:55:36      36262 terraform.tfstate

$ aws s3api get-bucket-versioning --bucket technova-terraform-state-d849bd92
{
    "Status": "Enabled"
}

$ aws s3api get-bucket-encryption --bucket technova-terraform-state-d849bd92
{
    "ServerSideEncryptionConfiguration": {
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "aws:kms"
                },
                "BucketKeyEnabled": true
            }
        ]
    }
}

$ aws s3api get-public-access-block --bucket technova-terraform-state-d849bd92
{
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }
}

$ aws dynamodb describe-table --table-name technova-terraform-locks --query 'Table.{Status:TableStatus,Key:KeySchema}'
{
    "Status": "ACTIVE",
    "Key": [
        {
            "AttributeName": "LockID",
            "KeyType": "HASH"
        }
    ]
}
```

## Evidência da Conexão EC2 → RDS

```
$ ssh -i ~/.ssh/technova-key ec2-user@100.26.185.177 "psql --version"
psql (PostgreSQL) 15.19

$ ssh -i ~/.ssh/technova-key ec2-user@100.26.185.177 \
    "psql -h technova-db.cdh757g9f6xp.us-east-1.rds.amazonaws.com -U technova_admin -d technova -p 5432 -c 'SELECT version();'"
                                              version
---------------------------------------------------------------------------------------------------
 PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC) 12.4.0, 64-bit
(1 row)

$ ssh -i ~/.ssh/technova-key ec2-user@100.26.185.177 \
    "psql -h technova-db.cdh757g9f6xp.us-east-1.rds.amazonaws.com -U technova_admin -d technova -p 5432 -c 'SELECT * FROM orders;'"
 id | customer_name |       product       | quantity |  total  |         created_at
----+---------------+---------------------+----------+---------+----------------------------
  1 | Maria Silva   | Laptop TechNova Pro |        1 | 4599.90 | 2026-09-11 00:56:28.619877
  2 | Joao Santos   | Monitor 27pol       |        2 | 2398.00 | 2026-09-11 00:56:28.619877
  3 | Ana Costa     | Teclado Mecanico    |        3 |  897.00 | 2026-09-11 00:56:28.619877
(3 rows)
```

**Nota sobre o ambiente:** testado com credenciais do AWS Academy Learner Lab. O provider AWS
(`~> 5.0`) faz uma chamada `s3:GetBucketObjectLockConfiguration` automaticamente ao ler o estado
do recurso `aws_s3_bucket`, e essa chamada é bloqueada por uma Service Control Policy da
organização do Learner Lab (mesma classe de restrição já documentada na entrega da
[aula 04](../../aula-04/6325269/entrega.md) para IAM). O bucket é criado normalmente; a leitura
imediatamente após a criação falha com `AccessDenied`, marcando o recurso como `tainted`. A
solução foi confirmar que o bucket existia (`aws s3api head-bucket`), rodar `terraform untaint` e
aplicar os demais recursos com `-refresh=false -target=...`, sem alterar o resultado final: bucket
versionado, criptografado e com Block Public Access total (confirmado via `aws s3api
get-bucket-versioning`/`get-bucket-encryption`/`get-public-access-block` acima). Detalhes completos
no [`README.md`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-05/README.md) do
projeto.

O arquivo completo do projeto (`backend/` com o remote state, e a raiz de `aula-05/` com
`providers.tf`, `variables.tf`, `vpc.tf`, `rds.tf`, `ec2.tf`, `outputs.tf`, `user_data.sh`,
`terraform-plan-output.txt`, `evidencia-s3-state.txt`, `evidencia-psql.txt`, `README.md`) está
versionado em
[`aula-05/`](https://github.com/Sir-Jr/unifaat-devops-portfolio/tree/main/aula-05).

`terraform destroy` foi executado tanto no projeto principal quanto no backend ao final — o bucket
S3 foi esvaziado (incluindo versões) antes de destruído. Nenhum recurso permanece rodando na AWS
(`aws s3 ls`, `aws dynamodb list-tables`, `aws ec2 describe-instances` e `aws rds
describe-db-instances` não retornam nenhum recurso da TechNova).
