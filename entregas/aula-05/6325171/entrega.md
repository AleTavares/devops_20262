# Entrega - Aula 05: RDS e Remote State

**Aluno:** Nicolas Jesus e Silva  
**RA:** 6325171  
**Data:** 17/09/2026

## Repositorio

- URL: https://github.com/NxcolasDev/unifaat-devops-portfolio
- Pasta: `aula-05/`

## Evidencias

- [x] VPC `10.0.0.0/16` com uma subnet publica e duas subnets privadas em duas AZs
- [x] Internet Gateway e Route Table publica
- [x] RDS PostgreSQL 15 `db.t3.micro` nas subnets privadas
- [x] RDS com `publicly_accessible = false`, encriptacao e `multi_az = false`
- [x] EC2 `t2.micro` na subnet publica
- [x] Security Group do RDS permitindo porta 5432 somente do EC2
- [x] Security Group do EC2 com SSH e API conforme necessidade
- [x] Bucket S3 de remote state com versionamento, encriptacao e bloqueio de acesso publico
- [x] Tabela DynamoDB com chave `LockID` do tipo String e `PAY_PER_REQUEST`
- [x] Backend S3 configurado e state armazenado remotamente
- [x] Conexao EC2 -> RDS validada com `psql`
- [x] Dados de teste persistentes consultados no RDS
- [x] `terraform plan` sem mudancas apos a aplicacao
- [x] `terraform destroy` executado e recursos temporarios removidos

## Arquivos no portfolio

Os arquivos tecnicos estao no repositorio pessoal, em `aula-05/`:

- `providers.tf`, `variables.tf`, `vpc.tf`, `security.tf`, `rds.tf`, `ec2.tf` e `outputs.tf`
- `terraform-plan-output.txt` com o plano de criacao
- `terraform-plan-no-changes.txt` com o plano apos a aplicacao
- `README.md` com arquitetura, seguranca e comandos
- `.gitignore` sem state, variaveis, credenciais ou chaves privadas

Nao foram incluidos `terraform.tfvars`, `aws-creds.sh`, `.tfstate`, `.terraform/`, `*.pem` ou senhas.

## Evidencia do State no S3

Bucket: `nxcolasdev-technova-state-f105195a`  
Caminho: `aula-05/terraform.tfstate`

```text
2026-09-17 14:17:50      36811 terraform.tfstate
```

Configuracoes verificadas:

```json
{
    "Status": "Enabled"
}
```

```json
{
    "ServerSideEncryptionConfiguration": {
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }
}
```

```json
{
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }
}
```

Tabela DynamoDB de locking:

```text
Name: nxcolasdev-technova-locks
Status: ACTIVE
BillingMode: PAY_PER_REQUEST
KeySchema: LockID (HASH)
```

## Evidencia da Conexao EC2 -> RDS

Instancia EC2: `i-03aff7c0fecb9a402`  
IP publico: `3.84.44.19`  
Endpoint RDS: `nxcolasdev-technova-db.cotyxuvtwdcw.us-east-1.rds.amazonaws.com:5432`

```text
PostgreSQL 15.17 on x86_64-pc-linux-gnu
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384)
```

## Evidencia dos Dados Persistentes

Tabela `orders` criada no RDS e consultada a partir da EC2:

```text
 id | customer_name |       product       | quantity |  total
----+---------------+---------------------+----------+---------
  1 | Maria Silva   | Laptop TechNova Pro |        1 | 4599.90
  2 | Joao Santos   | Monitor 27          |        2 | 2398.00
  3 | Ana Costa     | Teclado Mecanico    |        3 |  897.00
```

Após o reboot da EC2, os mesmos três registros foram consultados novamente com sucesso, comprovando que os dados permanecem no RDS.

## Evidencia do Terraform Plan

Após a aplicação, o Terraform confirmou que a infraestrutura está sincronizada:

```text
No changes. Your infrastructure matches the configuration.
```

Recursos registrados no state remoto:

```text
aws_db_instance.main
aws_db_subnet_group.main
aws_instance.api
aws_internet_gateway.main
aws_key_pair.main
aws_route_table.public
aws_route_table_association.public
aws_security_group.ec2
aws_security_group.rds
aws_subnet.private_a
aws_subnet.private_b
aws_subnet.public
aws_vpc.main
```

## Evidencia do Reboot da EC2

O primeiro acesso SSH logo após o reboot retornou temporariamente `Connection refused`, enquanto a instancia ainda inicializava. Após aguardar e repetir a conexao, o acesso SSH funcionou e a consulta dos três pedidos retornou os mesmos dados. Isso comprova a persistencia independente no RDS.

## Observacao de Execucao

As evidencias acima foram obtidas apos executar `terraform validate`, `terraform plan`, `terraform apply`, a conexao SSH/`psql`, a consulta dos dados apos reboot e a verificacao do state remoto. O cleanup ainda esta pendente: executar `terraform destroy` na infraestrutura principal, esvaziar as versoes do bucket S3 e destruir o projeto `backend/`. Nenhuma credencial AWS ou senha foi incluida neste arquivo.
