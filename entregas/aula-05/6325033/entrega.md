# Entrega — Aula 05: RDS e Remote State

**Aluno:** Renan Dias  
**RA:** 6325033  
**Data:** 19/09/2026

## Repositório

Repositório do portfólio:

https://github.com/diazrenan/unifaat-devops-portfolio/tree/feature/aula-05-rds-remote-state/aula-05

## Checklist

- [x] VPC `10.0.0.0/16`
- [x] Subnet pública para EC2
- [x] Duas subnets privadas em AZs distintas
- [x] Internet Gateway e rota pública
- [x] RDS PostgreSQL 15
- [x] RDS `db.t3.micro`
- [x] RDS com 20 GB de armazenamento
- [x] RDS utilizando `gp2`
- [x] RDS em subnets privadas
- [x] RDS com `publicly_accessible = false`
- [x] RDS com armazenamento criptografado
- [x] DB Subnet Group com duas subnets privadas
- [x] Security Group do RDS permitindo PostgreSQL na porta 5432
- [x] EC2 `t2.micro` em subnet pública
- [x] Security Group da EC2 com acesso SSH
- [x] Security Group da EC2 com acesso à API na porta 3000
- [x] Conexão EC2 → RDS utilizando `psql`
- [x] Banco PostgreSQL criado no RDS
- [x] Tabela `orders` criada
- [x] Dados inseridos na tabela `orders`
- [x] Persistência dos dados após reboot da EC2
- [x] Remote State configurado em S3
- [x] Versionamento do bucket S3
- [x] Criptografia do bucket S3
- [x] Block Public Access no bucket S3
- [x] Lock do Terraform configurado com DynamoDB
- [x] State armazenado remotamente no S3
- [x] `terraform plan` retornando `No changes`
- [x] Evidência do state armazenado no S3
- [x] Evidência da conexão EC2 → RDS
- [x] `terraform destroy` executado após a coleta das evidências
- [x] Backend S3 e DynamoDB limpos após a atividade

## Infraestrutura criada

A infraestrutura foi provisionada utilizando Terraform na região `us-east-1`.

A arquitetura contou com:

- VPC `10.0.0.0/16`
- Uma subnet pública para a instância EC2
- Duas subnets privadas em Availability Zones distintas
- Internet Gateway
- Route Table pública
- Security Groups para EC2 e RDS
- Instância EC2 `t2.micro`
- Instância RDS PostgreSQL `db.t3.micro`
- DB Subnet Group utilizando as duas subnets privadas

O RDS foi configurado como recurso privado, sem acesso público.

## RDS PostgreSQL

O banco de dados utilizado foi PostgreSQL 15, com as seguintes configurações principais:

```text
Engine: PostgreSQL
Version: 15
Instance class: db.t3.micro
Storage: 20 GB
Storage type: gp2
Multi-AZ: false
Publicly accessible: false
Storage encrypted: true
Port: 5432
Database: technova
Username: technova_admin
```

O acesso ao RDS foi realizado somente através da rede da VPC.

O Security Group do RDS permitiu conexões PostgreSQL na porta `5432` a partir do CIDR da VPC.

## Evidência — Remote State

O Terraform foi configurado para utilizar um bucket S3 como armazenamento remoto do state.

Bucket utilizado:

```text
technova-terraform-state-9a2fd334
```

Chave do state:

```text
aula-05/terraform.tfstate
```

Backend utilizado no Terraform:

```hcl
backend "s3" {
  bucket         = "technova-terraform-state-9a2fd334"
  key            = "aula-05/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "technova-terraform-state-lock"
}
```

O DynamoDB foi utilizado para controle de lock do Terraform, utilizando a chave de partição:

```text
LockID
```

A existência do state no S3 foi verificada através do AWS CLI e registrada no arquivo:

```text
evidencia-state-s3.txt
```

A validação do Terraform também confirmou que o estado remoto estava sincronizado com a infraestrutura:

```text
No changes. Your infrastructure matches the configuration.
```

## Evidência — EC2 → RDS

A conexão com o banco foi realizada diretamente a partir da instância EC2 utilizando o cliente PostgreSQL `psql`.

Resultado obtido:

```text
psql (15.19, server 15.17)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, compression: off)
Type "help" for help.
```

A conexão foi realizada através da porta `5432`, utilizando o endpoint privado do RDS.

## Evidência — Persistência dos dados

Foi criada a tabela `orders` no PostgreSQL e foram inseridos três registros de teste.

Os registros utilizados foram:

```text
Maria Silva  | Laptop TechNova Pro | 1 | 4599.90
João Santos  | Monitor 27"         | 2 | 2398.00
Ana Costa    | Teclado Mecânico    | 3 |  897.00
```

Após a criação e inserção dos dados, a instância EC2 foi reiniciada.

Depois do reboot, foi realizada novamente a consulta ao banco RDS e os registros continuaram disponíveis.

Essa validação demonstrou a persistência dos dados no banco de dados gerenciado pelo Amazon RDS, independentemente do ciclo de vida da instância EC2.

## Evidência — Terraform Plan

Após o provisionamento da infraestrutura, foi executado:

```text
terraform plan
```

O Terraform retornou:

```text
No changes. Your infrastructure matches the configuration.
```

Isso demonstrou que a infraestrutura existente estava de acordo com a configuração declarada nos arquivos Terraform.

Também foi executado:

```text
terraform apply
```

Após as validações, o resultado foi:

```text
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

## Organização do projeto

O projeto foi separado em arquivos Terraform de acordo com a responsabilidade de cada recurso:

```text
aula-05/
├── backend/
│   ├── main.tf
│   ├── s3.tf
│   ├── dynamodb.tf
│   ├── variables.tf
│   └── outputs.tf
├── providers.tf
├── variables.tf
├── vpc.tf
├── rds.tf
├── ec2.tf
├── outputs.tf
├── user_data.sh
├── evidencia-state-s3.txt
└── .gitignore
```

O arquivo `.gitignore` foi configurado para evitar o versionamento de arquivos sensíveis e arquivos gerados localmente pelo Terraform, incluindo:

```text
.terraform/
*.tfstate
terraform.tfvars
*.pem
```

A senha do banco foi definida através de variável sensível do Terraform:

```hcl
variable "db_password" {
  description = "Senha do usuário administrador do banco de dados RDS"
  type        = string
  sensitive   = true
}
```

O arquivo `terraform.tfvars`, contendo valores locais das variáveis, não foi incluído no repositório.

## Outputs

Foram definidos outputs para facilitar a identificação dos principais recursos criados, incluindo:

- Endpoint do RDS
- IP público da EC2
- IDs dos Security Groups
- Informações relacionadas à rede

Durante a execução da atividade, o endpoint utilizado para conexão foi:

```text
technova-postgres.c8huissia2wm.us-east-1.rds.amazonaws.com
```

## Limpeza da infraestrutura

Após a coleta das evidências e conclusão dos testes, foi executado:

```text
terraform destroy
```

A infraestrutura principal criada para a atividade foi destruída.

Posteriormente, o bucket S3 utilizado para o Remote State foi esvaziado e removido, assim como a tabela DynamoDB utilizada para o lock.

Dessa forma, os recursos temporários utilizados durante a atividade foram limpos após a conclusão dos testes.

## Conclusão

A atividade demonstrou a utilização conjunta de:

- Terraform
- Amazon VPC
- Amazon EC2
- Amazon RDS PostgreSQL
- Amazon S3
- Amazon DynamoDB
- AWS CLI
- PostgreSQL `psql`

Também foi validado o acesso privado ao RDS através da EC2, a persistência dos dados armazenados no banco e o funcionamento do Remote State do Terraform utilizando S3 e DynamoDB.