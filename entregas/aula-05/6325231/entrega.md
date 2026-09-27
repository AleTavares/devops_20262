# Entrega — Aula 05: RDS e Remote State

**Aluno:** Andreyh Rodrigues de Souza  
**RA:** 6325231  
**Data:** 17/09/2026

## Repositório

- URL: https://github.com/Andreyh117/unifaat-devops-portfolio
- Projeto: https://github.com/Andreyh117/unifaat-devops-portfolio/tree/main/aula-05

## Evidências

- [x] VPC: 1 subnet pública e 2 privadas em AZs diferentes
- [x] RDS PostgreSQL 15.17, db.t3.micro, 20 GB gp2, cifrado, privado e Single-AZ
- [x] EC2 t2.micro na subnet pública com cliente psql
- [x] Security Groups: 22/3000 no EC2 e 5432 apenas da VPC no RDS
- [x] S3 com cifragem AES256, versionamento e bloqueio público + DynamoDB com LockID
- [x] Backend s3 em providers.tf com encrypt e dynamodb_table
- [x] Variável de senha sensível, outputs, tags e .gitignore
- [x] Migração de state local para S3 executada
- [x] State armazenado no S3
- [x] Conexão EC2 → RDS via psql
- [x] Dados persistentes: criação e consulta de orders em nova conexão
- [x] Plano após apply com `No changes`
- [x] Infraestrutura principal destruída após evidências
- [x] Versões do bucket removidas e backend destruído

## Compatibilidade com o AWS Academy

O Academy negou `s3:GetBucketObjectLockConfiguration`, consulta feita por `aws_s3_bucket` mesmo sem usar Object Lock. O bucket foi criado na tentativa inicial e preservado; sua criação/remoção reproduzível está documentada com AWS CLI no README. O Terraform gerencia versionamento, cifragem, bloqueio público e DynamoDB. O backend principal S3 e seu locking funcionaram. Nenhuma permissão do laboratório foi alterada.

## Validação local

`terraform fmt -check -recursive`, `terraform validate` (principal e backend) e `bash -n user_data.sh` passaram. Os resultados abaixo vêm da execução real no AWS Academy.

## Evidência do State no S3

Comando: `aws s3 ls s3://technova-state-6325231-20260917225656960600000001/aula-05/`

```text
2026-09-17 20:03:34      36682 terraform.tfstate
```

A migração foi executada com `terraform init -migrate-state -force-copy -input=false -backend-config=...`, após aplicar a infraestrutura com state local. O backend DynamoDB foi mantido conforme o TF, apesar do aviso de depreciação emitido pelo Terraform.

## Evidência da Conexão EC2 → RDS

Executado no EC2 `54.172.239.112`, após o término do user data:

```bash
psql -v ON_ERROR_STOP=1 -h technova-db-6325231.czowxwnrobnw.us-east-1.rds.amazonaws.com -U technova_admin -d technova -c 'SELECT version();'
```

```text
status: done
                                              version                                              
---------------------------------------------------------------------------------------------------
 PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC) 12.4.0, 64-bit
(1 row)
```

A senha foi fornecida ao processo sem constar nos comandos publicados nem nas evidências.

## Evidência de Dados Persistentes

Tabela `orders` criada com `id`, `product` e `quantity`; inserido o pedido de ID 1. Uma nova sessão SSH e uma nova conexão psql executaram `SELECT * FROM orders;`:

```text
id |     product     | quantity 
----+-----------------+----------
  1 | Pedido TechNova |        2
(1 row)
```

## Evidência de Plano Limpo

`terraform plan -input=false -no-color -detailed-exitcode` retornou código 0:

```text
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.
```

## Limpeza

```text
Infraestrutura principal: Destroy complete! Resources: 14 destroyed.
State principal sem recursos.
Backend: Destroy complete! Resources: 4 destroyed.
aws s3api delete-bucket: concluído (exit code 0).
```

Todas as versões e marcadores do state foram removidos antes da exclusão do bucket. O endpoint e o IP registrados acima eram temporários e já não estão ativos.

## Arquivos completos de evidência

- [evidencia-plan-inicial.txt](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-05/evidencia-plan-inicial.txt)
- [evidencia-apply.txt](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-05/evidencia-apply.txt)
- [evidencia-backend.json](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-05/evidencia-backend.json)
- [evidencia-migracao.txt](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-05/evidencia-migracao.txt)
- [evidencia-state-s3.txt](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-05/evidencia-state-s3.txt)
- [evidencia-conexao.txt](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-05/evidencia-conexao.txt)
- [evidencia-criacao-dados.txt](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-05/evidencia-criacao-dados.txt)
- [evidencia-dados.txt](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-05/evidencia-dados.txt)
- [evidencia-plan.txt](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-05/evidencia-plan.txt)
- [evidencia-destroy.txt](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-05/evidencia-destroy.txt)
- [evidencia-destroy-backend.txt](https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-05/evidencia-destroy-backend.txt)
