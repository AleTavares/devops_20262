# Entrega — Aula 05: RDS e Remote State

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 11/09/2026

## Repositório

- URL: https://github.com/gabrielreis354/unifaat-devops-portfolio
- Infra principal: [`aula-05-rds/`](https://github.com/gabrielreis354/unifaat-devops-portfolio/tree/main/aula-05-rds)
- Backend do state: [`aula-05-backend/`](https://github.com/gabrielreis354/unifaat-devops-portfolio/tree/main/aula-05-backend)
- Spec (SDD) e evidências completas: [`specs/001-aula05-rds-remote-state/`](https://github.com/gabrielreis354/unifaat-devops-portfolio/tree/main/specs/001-aula05-rds-remote-state)

## Evidências

- [x] VPC com subnets públicas e privadas em 2 AZs
- [x] RDS PostgreSQL (db.t3.micro) nas subnets privadas
- [x] EC2 t2.micro na subnet pública, conectando ao RDS
- [x] Security Groups corretos (porta 5432 apenas da VPC)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] State armazenado no S3 (evidência abaixo)
- [x] Conexão EC2 → RDS via psql (evidência abaixo)
- [x] `terraform destroy` executado após evidências

## Nota sobre o bucket S3 do Remote State

O SCP do AWS Academy Learner Lab nega explicitamente
`s3:GetBucketObjectLockConfiguration`, chamada que o recurso `aws_s3_bucket` do
provider `hashicorp/aws` executa em toda leitura/criação (testado em `5.100.0` e
`5.42.0` — falha nas duas). As demais chamadas necessárias (create-bucket,
versioning, encryption, public-access-block) funcionam normalmente. Por isso o
bucket é criado por [`aula-05-backend/bootstrap.sh`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/aula-05-backend/bootstrap.sh)
(AWS CLI puro, idempotente) enquanto a tabela DynamoDB permanece 100% gerenciada
pelo Terraform (`aula-05-backend/dynamodb.tf`). Detalhes em
[`specs/001-aula05-rds-remote-state/plan.md`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/specs/001-aula05-rds-remote-state/plan.md#8-addendum--execução-real-2026-09-1011).

## Evidência do State no S3

```
$ aws s3 ls s3://technova-terraform-state-54600b3e83155696/aula-05/ --recursive
2026-09-10 22:26:35      34843 aula-05/terraform.tfstate
```

Bucket com versionamento habilitado, criptografia SSE-KMS e Block Public Access
(4/4). Tabela DynamoDB `technova-terraform-locks` (`LockID`, String) usada como
lock do state.

## Evidência da Conexão EC2 → RDS

```
$ ssh -i ~/.ssh/technova-key ec2-user@54.227.232.230
$ psql -h technova-db.cxhwj2zlyovj.us-east-1.rds.amazonaws.com -U technova_admin -d technova -c "SELECT version();"

                                              version
---------------------------------------------------------------------------------------------------
 PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC) 12.4.0, 64-bit
(1 row)
```

## Evidência de Dados Persistentes

```
CREATE TABLE
INSERT 0 3

technova=> SELECT * FROM orders;
 id | customer_name |       product       | quantity |  total  |         created_at
----+---------------+---------------------+----------+---------+----------------------------
  1 | Maria Silva   | Laptop TechNova Pro |        1 | 4599.90 | 2026-09-11 01:28:18.231431
  2 | Joao Santos   | Monitor 27"         |        2 | 2398.00 | 2026-09-11 01:28:18.231431
  3 | Ana Costa     | Teclado Mecanico    |        3 |  897.00 | 2026-09-11 01:28:18.231431
(3 rows)
```

## Evidência de `terraform plan` limpo (pós-apply)

```
$ terraform plan
...
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.
```

## Evidência: RDS não exposto à internet

```
$ timeout 8 bash -c "echo > /dev/tcp/technova-db.cxhwj2zlyovj.us-east-1.rds.amazonaws.com/5432"
(timeout — conexão recusada/não roteada a partir de fora da VPC)
```

## Teardown

Toda a infraestrutura foi destruída na mesma sessão, imediatamente após a captura
das evidências:

```
$ terraform destroy   # aula-05-rds       -> Destroy complete! Resources: 13 destroyed.
$ ./teardown.sh        # aula-05-backend  -> bucket esvaziado e removido
$ terraform destroy   # aula-05-backend  -> Destroy complete! Resources: 1 destroyed.
```

Verificação pós-teardown: nenhuma instância RDS, bucket S3, tabela DynamoDB, EC2
ou VPC com tag `Project=technova` restante na conta.
