# Entrega — Aula 05: RDS e Remote State

Aluno: Matheus Gabriel Correa Braga Viana
RA: 6325053
Data: 18/09/2026

## Repositorio

URL: https://github.com/Matiasdocs/unifaat-devops-portfolio

## Evidencias

[x] VPC com subnets publicas e privadas em 2 AZs
[x] RDS PostgreSQL (db.t3.micro) nas subnets privadas
[x] EC2 t2.micro na subnet publica, conectando ao RDS
[x] Security Groups corretos (porta 5432 apenas da VPC)
[x] Remote State configurado (S3 + DynamoDB)
[x] State armazenado no S3 (evidencia abaixo)
[x] Conexao EC2 -> RDS via psql (evidencia abaixo)
[x] terraform destroy executado apos evidencias

## Evidencia do State no S3

2026-09-18 18:24:37      37185 terraform.tfstate

## Evidencia da Conexao EC2 -> RDS

psql (PostgreSQL) 15.19
PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC) 12.4.0, 64-bit
(1 row)

## Observacoes

O bucket S3 do backend foi criado via AWS CLI (nao via aws_s3_bucket do Terraform), pois a politica do AWS Academy Learner Lab bloqueia a chamada s3:GetBucketObjectLockConfiguration ao gerenciar esse recurso diretamente (mesmo problema ja documentado na Aula 06). O Terraform gerencia a configuracao do bucket (versionamento, criptografia, bloqueio de acesso publico) e a tabela DynamoDB. Todos os 19 recursos (4 do backend + 15 do projeto principal) foram destruidos ao final.