# Aula 05 - RDS e Estado Remoto

**Aluno:** Carollini Godoy

**RA:** 3925000

**Disciplina:** DevOps

**Aula:** 05 - RDS e Estado Remoto

## 1. Repositório do projeto

**Repositório de portfólio:**  
https://github.com/caroll143/unifaat-devops-portfolio

**Branch utilizada no projeto:**  
`feature/aula-05-rds-remote-state`

**Commit principal:**  
`d8f3645 - feat(aula-05): implementa RDS e estado remoto`

## 2. Infraestrutura criada

Foi criada uma infraestrutura AWS utilizando Terraform com:

- VPC `10.0.0.0/16`
- 1 subnet pública para a EC2
- 2 subnets privadas em Availability Zones diferentes para o RDS
- Internet Gateway
- Tabela de rotas pública
- EC2 `t2.micro`
- Amazon RDS PostgreSQL 15
- RDS `db.t3.micro`
- 20 GB de armazenamento `gp2`
- Criptografia do RDS habilitada
- RDS sem acesso público
- Security Group da EC2 permitindo SSH na porta 22 e API na porta 3000
- Security Group do RDS permitindo PostgreSQL na porta 5432 somente a partir do Security Group da EC2

## 3. Estado remoto

O Terraform State foi configurado no Amazon S3:

- Bucket: `technova-terraform-state-3925000`
- Chave: `aula-05/terraform.tfstate`
- Criptografia do backend: habilitada
- Versionamento: habilitado
- DynamoDB para locking: `technova-terraform-lock`
- Chave de partição: `LockID`

### Evidência

Comando executado:

```text
aws s3 ls s3://technova-terraform-state-3925000/aula-05/