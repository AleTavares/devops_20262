# Entrega - Aula 05: RDS e Remote State

**Aluno:** Emilly Santos de Oliveira  
**RA:** 4023575  
**Data das evidências:** 13/09/2026

## Repositório
- URL: https://github.com/leonidas-alt/unifaat-devops-portfolio.git

## Requisitos atendidos

- [x] VPC, subnets, EC2 e Security Groups provisionados
- [x] RDS PostgreSQL 15 em subnets privadas
- [x] Remote State no S3 com versionamento e lock no DynamoDB
- [x] Conexão EC2 -> RDS comprovada
- [x] Tabela `orders` criada e consultada
- [x] `terraform plan` sem alterações pendentes
- [x] Infraestrutura destruída após a coleta das evidências

## Evidência dos recursos AWS

Arquivo completo: [evidencias/aws-recursos.txt](entregas/aula-05/4023575/Evidências/aws-recursos.txt)

Resumo: EC2 `t2.micro` em execução, RDS PostgreSQL `15.17` disponível, VPC
`10.0.0.0/16`, duas subnets privadas em AZs diferentes, uma subnet pública,
SG do RDS referenciando o SG da EC2 e tabela DynamoDB `LockID` ativa.

## Evidência do State no S3

Arquivo completo: [evidencias/s3-state.txt](entregas/aula-05/4023575/Evidências/s3-state.txt)

```text
aws s3 ls s3://technova-tfstate-4023575-05ebccce/aula-05/
2026-09-12 15:20:02   56.2 KiB terraform.tfstate

Versoes registradas do state: 5
Prefixo: aula-05/terraform.tfstate
```

## Evidência da conexão EC2 -> RDS

Arquivo completo: [evidencias/rds-conexao.txt](entregas/aula-05/4023575/Evidências/rds-conexao.txt)

```text
EC2: 54.224.24.51 -> RDS: technova-postgres...rds.amazonaws.com:5432
PostgreSQL 15.17 ... 64-bit
technova-postgres...rds.amazonaws.com:5432 - accepting connections
```

## Evidência de dados persistentes

Arquivo completo: [evidencias/psql-teste.txt](entregas/aula-05/4023575/Evidências/psql-teste.txt)

```text
SELECT * FROM orders;
5 registros retornados:
Notebook TechNova Pro, Mouse Ergonômico, Teclado Mecânico,
Monitor 24" Full HD e Headset USB.
```

O arquivo [evidencias/rds-conexao.txt](entregas/aula-05/4023575/Evidências/rds-conexao.txt) também
registra `CREATE TABLE`, `INSERT 0 5` e o `SELECT * FROM orders` executado na
EC2 contra o RDS.

## Evidência do Terraform plan

Arquivo completo: [evidencias/terraform-plan.txt](entregas/aula-05/4023575/Evidências/terraform-plan.txt)

```text
No changes. Your infrastructure matches the configuration.
```

Foi emitido apenas um aviso de depreciação sobre `dynamodb_table`; ele não
impediu a execução e o plan terminou sem alterações.

## Evidência do terraform destroy

Arquivos completos:

- [evidencias/terraform-destroy.txt](entregas/aula-05/4023575/Evidências/terraform-destroy-backend.txt)
- [evidencias/terraform-destroy-backend.txt](entregas/aula-05/4023575/Evidências/terraform-destroy-backend.txt)

```text
Destroy complete! Resources: 7 destroyed.
```

O backend foi esvaziado antes da remoção do bucket S3 e do DynamoDB. No
destroy da infraestrutura principal, o Terraform registrou `No changes` e
`Resources: 0 destroyed`, pois os recursos já haviam sido removidos antes da
execução registrada; a evidência correspondente está no primeiro arquivo.

## Observação sobre AWS Academy

O arquivo `iam.tf.disabled` permanece desabilitado por causa das restrições da
AWS Academy. A conferência de IAM/Instance Profile depende de validação manual
do professor.