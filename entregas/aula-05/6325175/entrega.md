# Entrega — Aula 05: RDS e Remote State

**Aluno:** João Pedro Paulino Ferreira
**RA:** 6325175
**Data:** 15/09/2026

## Repositório

* URL: https://github.com/Joaoz007/unifaat-devops-portfolio

## Evidências

* [x] VPC com subnets públicas e privadas em 2 AZs
* [x] RDS PostgreSQL (`db.t3.micro`) nas subnets privadas
* [ ] EC2 `t2.micro` conectando ao RDS
* [x] Security Groups configurados para o acesso ao PostgreSQL
* [x] Remote State configurado com S3 + DynamoDB
* [x] State armazenado no S3
* [ ] Conexão EC2 → RDS via `psql`
* [x] `terraform destroy` executado após as evidências

## Infraestrutura Provisionada

A infraestrutura foi provisionada utilizando Terraform na região `us-east-1`.

Foram configurados:

* VPC `10.0.0.0/16`;
* duas subnets públicas, distribuídas em duas Availability Zones;
* duas subnets privadas, distribuídas em duas Availability Zones;
* Internet Gateway;
* tabela de rotas para as subnets públicas;
* EC2 `t2.micro` em subnet pública;
* RDS PostgreSQL 15 `db.t3.micro` em subnets privadas;
* DB Subnet Group;
* Security Groups para EC2 e RDS;
* banco de dados PostgreSQL `technova`;
* bucket S3 para armazenamento do Terraform State;
* DynamoDB para locking do Terraform State.

O RDS foi configurado como privado, com:

* `publicly_accessible = false`;
* `multi_az = false`;
* armazenamento de 20 GB;
* tipo `gp2`;
* armazenamento criptografado;
* porta `5432`.

## Evidência do State no S3

O Remote State foi configurado utilizando o bucket:

`technova-terraform-state-6325175`

O arquivo de estado foi armazenado em:

`aula-05/terraform.tfstate`

A existência do State no S3 foi validada com:

```bash
aws s3 ls s3://technova-terraform-state-6325175/aula-05/
```

Resultado observado:

```text
2026-09-15 01:31:21 42105 terraform.tfstate
```

O versionamento do bucket também foi habilitado e validado:

```json
{
    "Status": "Enabled"
}
```

O bloqueio de acesso público foi validado com os quatro controles habilitados:

```json
{
    "BlockPublicAcls": true,
    "IgnorePublicAcls": true,
    "BlockPublicPolicy": true,
    "RestrictPublicBuckets": true
}
```

**Evidência:** screenshot contendo os comandos de validação do bucket S3, versionamento e bloqueio de acesso público.![alt text](<S3 state.png>)

## Evidência do Terraform Plan

Após a configuração do Remote State, foi executado:

```bash
terraform plan
```

O Terraform atualizou o estado dos recursos e apresentou:

```text
No changes. Your infrastructure matches the configuration.
```

Isso confirma que a infraestrutura existente estava de acordo com a configuração Terraform no momento da validação.

**Evidência:** screenshot do `terraform plan` com o resultado `No changes. Your infrastructure matches the configuration.`![alt text](<Terra Plan.png>)

## Evidência da Conexão EC2 → RDS

A EC2 foi provisionada em subnet pública e o RDS em subnet privada.

O Security Group do RDS foi configurado para permitir PostgreSQL na porta `5432` a partir da VPC:

```text
10.0.0.0/16
```

Entretanto, a conexão SSH com a EC2 não foi concluída devido a problemas de autenticação da chave pública. Por consequência, não foi possível executar a conexão utilizando `psql` a partir da EC2.

Portanto, a conexão EC2 → RDS **não foi marcada como concluída**, pois não houve evidência prática da conexão.

## Persistência de Dados

A validação de persistência de dados também não foi realizada, pois dependia da conexão EC2 → RDS e da execução de operações no PostgreSQL.

Por esse motivo, não foi apresentada uma evidência de persistência que não tenha sido efetivamente executada.

## Terraform Destroy

Após a coleta das evidências, foi executado:

```bash
terraform destroy
```

O Terraform identificou:



```text
Plan: 0 to add, 0 to change, 19 to destroy.
```

A infraestrutura foi destruída, incluindo:

* EC2;
* RDS PostgreSQL;
* DB Subnet Group;
* Security Groups;
* subnets;
* tabela de rotas;
* Internet Gateway;
* VPC;
* Key Pair;
* tabela DynamoDB de locking.

O bucket S3 do Remote State permaneceu existente, pois havia sido retirado do gerenciamento direto do Terraform devido à limitação de permissões encontrada no ambiente AWS Academy.

Ao final do `terraform destroy`, ocorreu uma mensagem de erro relacionada à liberação do state lock:

```text
Error: Error releasing the state lock
ResourceNotFoundException:
Requested resource not found
```

A tabela DynamoDB utilizada para o locking já havia sido destruída durante o próprio `terraform destroy`. Dessa forma, o Terraform não conseguiu realizar a etapa final de liberação do lock porque o recurso de locking já não existia.

Apesar dessa mensagem final, os recursos de infraestrutura foram efetivamente destruídos, conforme indicado pelas mensagens de conclusão, incluindo:

```text
aws_instance.api: Destruction complete
aws_db_instance.postgres: Destruction complete
aws_vpc.main: Destruction complete
```

**Evidência:** screenshot/log da execução do `terraform destroy`.![alt text](destroy.png)

## Ajustes e Limitações

Durante a atividade, foi encontrada uma limitação de permissões do ambiente AWS Academy relacionada ao gerenciamento de uma configuração de Object Lock do bucket S3.

Como workaround, o bucket utilizado para o Remote State foi mantido fora do gerenciamento direto pelo Terraform, enquanto suas configurações necessárias foram aplicadas e validadas separadamente.

O versionamento do bucket foi habilitado utilizando AWS CLI.

Também foi mantido o uso do DynamoDB para locking conforme solicitado no exercício. O Terraform apresentou um aviso informando que o parâmetro `dynamodb_table` está depreciado em versões futuras, recomendando `use_lockfile`. A configuração foi mantida porque o uso do DynamoDB fazia parte dos requisitos desta atividade.

A conexão SSH com a EC2 não foi concluída devido a problemas de autenticação da chave pública. Consequentemente, não foi possível realizar a validação prática da conexão EC2 → RDS e da persistência de dados.

Todas as limitações encontradas foram registradas nesta entrega.
