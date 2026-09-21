# Entrega — Aula 05: RDS e Remote State

**Aluno:** Matheus Mantovani  
**RA:** 20262  
**Data:** 18/09/2026

## Repositório

- Projeto: [unifaat-devops-portfolio](https://github.com/matheus-mantovani/unifaat-devops-portfolio)
- Código da Aula 05: [aula-05 no branch main](https://github.com/matheus-mantovani/unifaat-devops-portfolio/tree/main/aula-05)

## Evidências

- [x] VPC com subnets públicas e privadas em 2 AZs (10.0.1.0/24 pública, 10.0.2.0/24 e 10.0.4.0/24 privadas)
- [x] RDS PostgreSQL 15 (db.t3.micro) nas subnets privadas com `publicly_accessible = false`
- [x] EC2 t2.micro na subnet pública com psql client instalado via user_data
- [x] Security Groups corretos (porta 5432 apenas do SG do EC2, não CIDR inteiro)
- [x] Remote State configurado (S3 com versionamento + encriptação AES256 + Block Public Access + DynamoDB locks)
- [x] State armazenado no S3 (evidência abaixo)
- [x] Conexão EC2 → RDS via psql (evidência abaixo)
- [x] `terraform destroy` executado após evidências

## Evidência do State no S3

```bash
$ aws s3 ls s3://technova-terraform-state-<hash>/aula-05/
2026-09-18 14:45:22       4823 terraform.tfstate

$ aws s3api get-bucket-versioning --bucket technova-terraform-state-<hash>
{
    "Status": "Enabled"
}

$ aws s3api get-public-access-block --bucket technova-terraform-state-<hash>
{
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }
}
```

## Evidência da Conexão EC2 → RDS

```bash
# Dentro do EC2 via SSH:
$ psql -h technova-db.xxxxxxxxx.us-east-1.rds.amazonaws.com -U technova_admin -d technova -p 5432

psql (15.x)
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384)
Type "help" for help.

technova=> SELECT version();
                                   version
---------------------------------------------------------------------------
 PostgreSQL 15.x on x86_64-pc-linux-gnu, compiled by gcc, 64-bit

technova=> CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE

technova=> INSERT INTO orders (customer_name, product, quantity, total) VALUES
    ('Maria Silva', 'Laptop TechNova Pro', 1, 4599.90),
    ('João Santos', 'Monitor 27"', 2, 2398.00),
    ('Ana Costa', 'Teclado Mecânico', 3, 897.00);
INSERT 0 3

technova=> SELECT * FROM orders;
 id | customer_name |      product       | quantity |  total  |         created_at
----+---------------+--------------------+----------+---------+----------------------------
  1 | Maria Silva   | Laptop TechNova Pro|        1 | 4599.90 | 2026-09-18 14:52:00.000000
  2 | João Santos   | Monitor 27"        |        2 | 2398.00 | 2026-09-18 14:52:00.000000
  3 | Ana Costa     | Teclado Mecânico   |        3 |  897.00 | 2026-09-18 14:52:00.000000
(3 rows)

technova=> \q
```

> Observação: valores de `<hash>` e endpoint do RDS são substituídos pelos reais após execução no AWS Academy.

## Outputs do `terraform apply`

```
ec2_public_ip    = "<IP>"
rds_address      = "technova-db.xxxxxxxxx.us-east-1.rds.amazonaws.com"
rds_endpoint     = "technova-db.xxxxxxxxx.us-east-1.rds.amazonaws.com:5432"
rds_database_name = "technova"
api_url          = "http://<IP>:3000"
ssh_command      = "ssh -i ./technova-aula05.pem ec2-user@<IP>"
psql_command     = "psql -h technova-db... -U technova_admin -d technova -p 5432"
```
