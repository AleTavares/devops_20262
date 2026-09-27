
# Entrega - Aula 05: RDS e Estado Remoto

**Aluno:** Pablo Augusto Ramos Sobral
**RA:** 6325076

## Repositorio do projeto

A implementacao completa da infraestrutura esta disponivel no repositorio pessoal:

`https://github.com/Pablao02/unifaat-devops-portfolio`

Diretorio da atividade:

`aula-05/`

## Infraestrutura implementada

Foi criada uma infraestrutura AWS utilizando Terraform contendo:

* VPC `10.0.0.0/16`
* 1 subnet publica para a EC2
* 2 subnets privadas em Availability Zones diferentes para o RDS
* Internet Gateway e Route Table publica
* EC2 `t2.micro` com Amazon Linux 2023
* RDS PostgreSQL 15 `db.t3.micro`
* 20 GB de armazenamento `gp2`
* RDS privado e criptografado
* Security Groups para EC2 e RDS
* Comunicacao EC2 -> RDS na porta `5432`

## Estado remoto

O Terraform State foi configurado utilizando:

* S3 para armazenamento do estado
* Versionamento do bucket S3
* Criptografia AES256
* Bloqueio de acesso publico
* DynamoDB para controle de lock
* Backend S3 com `encrypt = true`

Bucket:

`technova-terraform-state-468464606980`

Tabela DynamoDB:

`technova-terraform-lock`

## Validacao EC2 -> RDS

Foi realizado acesso SSH a EC2 e instalado o cliente PostgreSQL:

`psql (PostgreSQL) 15.19`

A conexao com o RDS foi realizada utilizando SSL:

`SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384)`

Banco utilizado:

`technova`

Foi criada a tabela `orders` e inseridos tres registros.

A consulta retornou:

* Pablo - Notebook - quantidade 1
* Joao - Mouse - quantidade 2
* Maria - Teclado - quantidade 1

## Validacao do Terraform

Apos a criacao e validacao da infraestrutura, foi executado:

```text
terraform plan
```

Resultado:

```text
No changes. Your infrastructure matches the configuration.
```

Isso confirma que a infraestrutura existente esta de acordo com a configuracao Terraform.

## Observacao

O parametro `dynamodb_table` do backend apresentou um aviso de depreciacao na versao atual do Terraform, porem foi mantido porque o trabalho solicita explicitamente o uso do DynamoDB para controle de lock.

## Status

Infraestrutura AWS criada e validada com Terraform, comunicacao EC2 -> RDS testada com sucesso e estado remoto configurado em S3 com lock no DynamoDB.





