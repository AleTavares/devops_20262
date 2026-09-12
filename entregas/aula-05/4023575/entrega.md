# Entrega — Aula 05: RDS e Remote State

**Aluno:** Emilly Santos de Oliveira
**RA:** 4023575
**Data:** 12/09/2026

## Repositório

- URL: https://github.com/leonidas-alt/unifaat-devops-portfolio.git

## Requisitos atendidos

- [x] VPC `10.0.0.0/16`
- [x] Uma subnet pública para a EC2, com Internet Gateway e route table
- [x] Duas subnets privadas em `us-east-1a` e `us-east-1b`
- [x] DB Subnet Group usando as duas subnets privadas
- [x] RDS PostgreSQL 15, classe `db.t3.micro`, 20 GB `gp2`
- [x] RDS com `multi_az = false`, `publicly_accessible = false` e `storage_encrypted = true`
- [x] EC2 `t2.micro` na subnet pública
- [x] Security Group da EC2 com SSH na porta 22 e API na porta 3000
- [x] Security Group do RDS permitindo a porta 5432 somente pelo SG da EC2
- [x] Remote state em S3 com versionamento, criptografia e bloqueio de acesso público
- [x] DynamoDB com chave de partição `LockID`
- [x] Backend S3 configurado com `encrypt = true`
- [x] Variáveis sensíveis protegidas com `sensitive = true`
- [x] `terraform plan` sem alterações pendentes
- [x] Dados persistentes criados e consultados no RDS

## Bônus

- [x] Referência de Security Group entre EC2 e RDS.
- [x] `user_data` instala o cliente PostgreSQL e testa a conexão automaticamente.
- [ ] IAM Role para EC2: configuração preparada em `iam.tf.disabled`, mas desabilitada no ambiente AWS Academy.

## Evidência do State no S3

Bucket utilizado:

```text
technova-tfstate-4023575-05ebccce
```

Comando executado após o apply:

```bash
aws s3 ls s3://technova-tfstate-4023575-05ebccce/aula-05/
```

Saída registrada:

```text
2026-09-12 15:20:02   56.2 KiB terraform.tfstate
```

O versionamento também foi confirmado, com cinco versões do state registradas. O código do backend configura criptografia SSE-S3, versionamento e Block Public Access.

## Evidência da Infraestrutura AWS

```text
VPC: 10.0.0.0/16
VPC ID: vpc-0d46b611690f611c1
Subnet pública: 10.0.1.0/24, us-east-1a
Subnet privada: 10.0.2.0/24, us-east-1a
Subnet privada: 10.0.3.0/24, us-east-1b

EC2: i-0248be3a78f7637ce
Tipo: t2.micro
Estado registrado: running
IP público: 54.224.24.51

RDS: technova-postgres
Engine: postgres
Versão: 15.17
Classe: db.t3.micro
Porta: 5432
Público: False
Criptografado: True
Estado registrado: available

DynamoDB: technova-terraform-lock
Chave de partição: LockID
Estado registrado: ACTIVE
```

## Evidência da Conexão EC2 → RDS

Comando executado a partir da EC2:

```bash
PGPASSWORD='***' psql \
  -h technova-postgres.cliz20r6oiwx.us-east-1.rds.amazonaws.com \
  -p 5432 \
  -U technova_admin \
  -d technova_db \
  -c "SELECT version();"
```

Saída registrada:

```text
PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC 12.4.0), 64-bit
(1 row)
```

O `pg_isready` também retornou:

```text
technova-postgres.cliz20r6oiwx.us-east-1.rds.amazonaws.com:5432 - accepting connections
```

## Evidência dos Dados Persistentes

Tabela `orders` criada e consultada no RDS:

```text
 id |        product        | quantity | unit_price |         created_at
----+-----------------------+----------+------------+----------------------------
  1 | Notebook TechNova Pro |        2 |    3499.90 | 2026-09-12 18:20:29.613054
  2 | Mouse Ergonômico      |       10 |      89.90 | 2026-09-12 18:20:29.613054
  3 | Teclado Mecânico      |        5 |     299.90 | 2026-09-12 18:20:29.613054
  4 | Monitor 24" Full HD   |        3 |     899.90 | 2026-09-12 18:20:29.613054
  5 | Headset USB           |        8 |      149.90 | 2026-09-12 18:20:29.613054
(5 rows)
```

## Evidência do Terraform Plan

```text
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.
```

O aviso sobre `dynamodb_table` é apenas uma depreciação do parâmetro do backend; o plan foi concluído com sucesso.

## Evidência do Terraform Destroy

Na execução final da infraestrutura principal, o Terraform informou que não havia objetos restantes:

```text
No changes. No objects need to be destroyed.
Destroy complete! Resources: 0 destroyed.
```

Isso confirma que a infraestrutura principal já estava removida. Em seguida, o backend foi destruído com sucesso:

```text
Destroy complete! Resources: 7 destroyed.
```

Os recursos destruídos no backend foram o bucket S3, suas configurações, a tabela DynamoDB e o identificador aleatório do bucket.