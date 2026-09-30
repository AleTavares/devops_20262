# Entrega — Aula 05: RDS e Remote State

**Aluno:** Emar Cristian
**RA:** 6325192
**Data:** 12/09/2026

## Repositório

- URL: https://github.com/iHawlKz7/unifaat-devops-portfolio.git

## Evidências

- [x] VPC com subnet pública e 2 subnets privadas em 2 AZs
- [x] RDS PostgreSQL 15 db.t3.micro nas subnets privadas
- [x] EC2 t2.micro na subnet pública conectando ao RDS
- [x] Security Group do RDS permitindo PostgreSQL somente a partir do Security Group da EC2
- [x] Remote State configurado com S3 + DynamoDB
- [x] S3 com versionamento habilitado
- [x] S3 com criptografia SSE-KMS
- [x] Block Public Access habilitado
- [x] DynamoDB utilizando LockID
- [x] State armazenado no S3
- [x] Conexão EC2 → RDS utilizando psql
- [x] Dados inseridos e consultados no PostgreSQL
- [x] Terraform plan sem mudanças após o apply
- [x] Infraestrutura principal destruída após as evidências
- [x] Backend S3 + DynamoDB destruído após as evidências

## Evidência do State no S3

```text
2026-09-12 18:33:38      36438 terraform.tfstate
```

## Evidência da Conexão EC2 → RDS

```text
                                              version
---------------------------------------------------------------------------------------------------
 PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC) 12.4.0, 64-bit
(1 row)
```

## Evidência dos Dados

```text
CREATE TABLE
TRUNCATE TABLE
INSERT 0 3
 id | customer_name |       product       | quantity |  total  |         created_at
----+---------------+---------------------+----------+---------+----------------------------
  1 | Maria Silva   | Laptop TechNova Pro |        1 | 4599.90 | 2026-09-12 21:54:07.267699
  2 | Joao Santos   | Monitor 27          |        2 | 2398.00 | 2026-09-12 21:54:07.267699
  3 | Ana Costa     | Teclado Mecanico    |        3 |  897.00 | 2026-09-12 21:54:07.267699
(3 rows)
```

## Evidência do Terraform Plan

```text

The parameter "dynamodb_table" is deprecated. Use parameter "use_lockfile" instead.
Acquiring state lock. This may take a few moments...
data.aws_availability_zones.available: Reading...
aws_key_pair.main: Refreshing state... [id=technova-aula05-key]
aws_vpc.main: Refreshing state... [id=vpc-023966c0a5d4eff0c]
data.aws_ami.amazon_linux: Reading...
data.aws_availability_zones.available: Read complete after 1s [id=us-east-1]
data.aws_ami.amazon_linux: Read complete after 1s [id=ami-0b5358cc8c5df0b02]
aws_security_group.ec2: Refreshing state... [id=sg-094d2068aec1af65e]
aws_subnet.public: Refreshing state... [id=subnet-031c406a68e93b72d]
aws_internet_gateway.main: Refreshing state... [id=igw-08e5294270e33aa7f]
aws_subnet.private_2: Refreshing state... [id=subnet-011bd89b31aa8b2a8]
aws_subnet.private_1: Refreshing state... [id=subnet-02cacc9b21afc32a3]
aws_route_table.public: Refreshing state... [id=rtb-0c12065841b5e3374]
aws_security_group.rds: Refreshing state... [id=sg-0ad86ae98fd761c14]
aws_route_table_association.public: Refreshing state... [id=rtbassoc-099bc335625a87d18]
aws_db_subnet_group.main: Refreshing state... [id=technova-db-subnet-group]
aws_instance.api: Refreshing state... [id=i-08ea51bde1c45ab00]
aws_db_instance.main: Refreshing state... [id=db-M7H3GO6MWKG4LDCNA5ABETX2TM]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.
```

## Segurança do Remote State

O backend remoto utilizou:

- Amazon S3 para armazenamento do Terraform State
- Versionamento habilitado
- Criptografia SSE-KMS
- Block Public Access habilitado
- DynamoDB para locking
- Chave de partição `LockID`
- Billing Mode `PAY_PER_REQUEST`
