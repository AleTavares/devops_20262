# Entrega - Aula 05: RDS e Remote State

**Aluno:** Gabriel Carneiro da Silva  
**RA:** 6325300  
**Data:** 24/09/2026

## Repositorio

- URL: https://github.com/gcdsofc/unifaat-devops-portfolio
- Pasta da Aula 05: https://github.com/gcdsofc/unifaat-devops-portfolio/tree/main/aula-05
- Branch de desenvolvimento: https://github.com/gcdsofc/unifaat-devops-portfolio/tree/feature/aula-05-rds-remote-state

## Evidencias

- [x] VPC com subnets publicas e privadas em 2 AZs
- [x] RDS PostgreSQL `db.t3.micro` nas subnets privadas
- [x] EC2 `t2.micro` na subnet publica, com cliente PostgreSQL instalado via `user_data`
- [x] Security Groups corretos: EC2 com portas 22/3000 e RDS 5432 liberado apenas para o SG da EC2
- [x] Remote State configurado com S3 + DynamoDB
- [x] Bucket S3 com versionamento, criptografia e bloqueio de acesso publico definido em Terraform
- [x] Tabela DynamoDB com partition key `LockID`
- [ ] State armazenado no S3 depois do `terraform apply` no AWS Academy
- [ ] Conexao EC2 -> RDS via `psql` depois do `terraform apply`
- [ ] `terraform destroy` executado apos capturar as evidencias reais no AWS Academy

## Evidencias no repositorio pessoal

- Backend S3 + DynamoDB: https://github.com/gcdsofc/unifaat-devops-portfolio/tree/main/aula-05/backend
- Plan do backend: https://github.com/gcdsofc/unifaat-devops-portfolio/blob/main/aula-05/backend/terraform-plan-output.txt
- Infra principal VPC + EC2 + RDS: https://github.com/gcdsofc/unifaat-devops-portfolio/tree/main/aula-05/main
- Validate da infra principal: https://github.com/gcdsofc/unifaat-devops-portfolio/blob/main/aula-05/main/terraform-validate-output.txt

## Evidencia do State no S3

Pendente de execucao no AWS Academy Learner Lab:

```bash
aws s3 ls s3://technova-tfstate-6325300-aula05/aula-05/main/
```

## Evidencia da Conexao EC2 -> RDS

Pendente de execucao no AWS Academy Learner Lab, apos aplicar a infraestrutura:

```bash
psql -h <RDS_ENDPOINT> -U technova_admin -d technova -c "SELECT version();"
```

## Observacao

O codigo Terraform e os arquivos de validacao/plan estao publicados no repositorio pessoal. As evidencias que dependem de recursos reais da AWS devem ser geradas durante a execucao do laboratorio no AWS Academy, antes do `terraform destroy`.
