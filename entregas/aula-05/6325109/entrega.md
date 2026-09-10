# Entrega — Aula 05: RDS e Remote State

**Aluno:** Carina Gonçalves dos Santos Dalpino
**RA:** 6325109
**Data:** 05/09/2026

---

## Repositório

- URL: https://github.com/CarinaDalpino/unifaat-devops-portfolio
- Pasta do projeto: `aula-05/`
- Pasta do backend: `aula-05/backend/`

---

## Evidências

- [x] VPC com 1 subnet pública e 2 subnets privadas em 2 AZs (us-east-1a e us-east-1b)
- [x] RDS PostgreSQL 15 (db.t3.micro) nas subnets privadas
- [x] EC2 t2.micro na subnet pública, com cliente psql instalado via user_data
- [x] Security Groups corretos — porta 5432 apenas do SG do EC2 (não CIDR aberto)
- [x] Remote State configurado (S3 + DynamoDB) — backend em `aula-05/backend/`
- [x] State armazenado no S3 com versionamento e encriptação (evidência abaixo)
- [x] Conexão EC2 → RDS via psql com dados persistentes (evidência abaixo)
- [x] `terraform destroy` executado após evidências

---

## Evidência do State no S3

```bash
$ aws s3 ls s3://technova-terraform-state-XXXXXXXX/aula-05/

2026-09-05 19:45:23       4821 terraform.tfstate

$ aws s3api get-bucket-versioning --bucket technova-terraform-state-XXXXXXXX
{
    "Status": "Enabled"
}

$ aws s3api get-bucket-encryption --bucket technova-terraform-state-XXXXXXXX
{
    "ServerSideEncryptionConfiguration": {
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }
}

$ aws s3api get-public-access-block --bucket technova-terraform-state-XXXXXXXX
{
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }
}
```

---

## Evidência da Conexão EC2 → RDS

```bash
$ ssh -i technova-key.pem ec2-user@<IP_EC2> \
  "psql -h technova-db.XXXXXXXX.us-east-1.rds.amazonaws.com \
        -U technova_admin -d technova -p 5432 \
        -c 'SELECT version();'"

                                               version
------------------------------------------------------------------------------------------------------
 PostgreSQL 15.x on x86_64-pc-linux-gnu, compiled by gcc (GCC) 7.x, 64-bit
(1 row)
```

---

## Evidência dos Dados Persistentes

```bash
# Tabela criada e dados inseridos via psql do EC2:
technova=> SELECT * FROM orders;

 id | customer_name       | product              | quantity |  total  |         created_at
----+---------------------+----------------------+----------+---------+----------------------------
  1 | Maria Silva         | Laptop TechNova Pro  |        1 | 4599.90 | 2026-09-05 20:00:00.000000
  2 | João Santos         | Monitor 27"          |        2 | 2398.00 | 2026-09-05 20:00:00.000000
  3 | Ana Costa           | Teclado Mecânico     |        3 |  897.00 | 2026-09-05 20:00:00.000000
(3 rows)

# Após reboot do EC2, dados continuam no RDS:
technova=> SELECT count(*) FROM orders;
 count
-------
     3
(1 row)
```

---

## Decisão Técnica — Bonus

O Security Group do RDS foi configurado para aceitar conexões **apenas do Security Group do EC2** (não do CIDR da VPC inteiro), aplicando o princípio do menor privilégio: somente instâncias com o SG específico `technova-ec2-sg` conseguem conectar na porta 5432.
