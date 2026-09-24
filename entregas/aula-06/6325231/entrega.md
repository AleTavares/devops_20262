# Entrega — Aula 06: Terraform Modules

**Aluno:** Andreyh Rodrigues de Souza
**RA:** 6325231
**Data:** 24/09/2026

## Repositório

- URL: https://github.com/Andreyh117/unifaat-devops-portfolio
- Projeto: https://github.com/Andreyh117/unifaat-devops-portfolio/tree/main/aula-06
- Documentação: https://github.com/Andreyh117/unifaat-devops-portfolio/blob/main/aula-06/README.md

## Evidências

- [x] Módulo VPC com `for_each` para subnets públicas e privadas, IGW e rotas públicas
- [x] Módulo Security Group genérico, ingress como lista de objetos e egress padrão
- [x] Módulo EC2 reutilizável, `t2.micro`, AMI/subnet/SG configuráveis e `user_data` opcional
- [x] Módulo RDS PostgreSQL, `db.t3.micro`, DB Subnet Group privado e senha sensível
- [x] Composição VPC → SG/EC2/RDS e SG → EC2/RDS
- [x] Dois ambientes (dev + staging) usando os mesmos módulos e CIDRs distintos
- [x] `terraform fmt -check -recursive`, `terraform validate` e `terraform plan` sem erros
- [x] README com arquitetura, inputs, outputs, exemplos por módulo e pré-requisitos
- [x] Tags Name, Environment, Project e ManagedBy nos recursos que suportam tags
- [x] `.gitignore` exclui states, planos binários, `.terraform/` e segredos

## Validação real no Learner Lab

Comandos executados em 24/09/2026, com credenciais temporárias válidas do AWS
Academy, região `us-east-1`, Terraform 1.16.2 e provider AWS 5.100.0.
O Key Pair `vockey` e PostgreSQL 15.17 foram consultados na AWS.
A AMI foi consultada por data source Amazon Linux 2023 x86_64 em cada plano.
A senha foi fornecida por `TF_VAR_db_password`, sem publicação do valor.

| Ambiente | VPC | Públicas | Privadas | Database |
|---|---|---|---|---|
| dev | 10.0.0.0/16 | 10.0.1.0/24, 10.0.2.0/24 | 10.0.3.0/24, 10.0.4.0/24 | technova_dev |
| staging | 10.1.0.0/16 | 10.1.1.0/24, 10.1.2.0/24 | 10.1.3.0/24, 10.1.4.0/24 | technova_staging |

## Evidência do terraform validate e plan

Em cada diretório `aula-06/environments/<ambiente>/`:

```bash
terraform init -input=false -no-color
terraform validate -no-color
terraform plan -input=false -no-color -detailed-exitcode -out=/tmp/andreyh-<ambiente>.tfplan
```

Os planos binários foram usados apenas para revisão local e não foram versionados.
`init` e `validate` retornaram 0; `plan -detailed-exitcode` retornou 2, indicando
alterações planejadas sem erro.

### dev

```text
Success! The configuration is valid.

data.aws_ami.amazon_linux: Read complete after 2s [id=ami-0b2c9d1f3edcfd709]
  # module.api_server.aws_instance.this will be created
  # module.api_sg.aws_security_group.this will be created
  # module.database.aws_db_instance.this will be created
  # module.database.aws_db_subnet_group.this will be created
  # module.rds_sg.aws_security_group.this will be created
  # module.vpc.aws_internet_gateway.this will be created
  # module.vpc.aws_route_table.public will be created
  # module.vpc.aws_route_table_association.public["public-1"] will be created
  # module.vpc.aws_route_table_association.public["public-2"] will be created
  # module.vpc.aws_subnet.this["private-1"] will be created
  # module.vpc.aws_subnet.this["private-2"] will be created
  # module.vpc.aws_subnet.this["public-1"] will be created
  # module.vpc.aws_subnet.this["public-2"] will be created
  # module.vpc.aws_vpc.this will be created
Plan: 14 to add, 0 to change, 0 to destroy.
```

### staging

```text
Success! The configuration is valid.

data.aws_ami.amazon_linux: Read complete after 1s [id=ami-0b2c9d1f3edcfd709]
  # module.api_server.aws_instance.this will be created
  # module.api_sg.aws_security_group.this will be created
  # module.database.aws_db_instance.this will be created
  # module.database.aws_db_subnet_group.this will be created
  # module.rds_sg.aws_security_group.this will be created
  # module.vpc.aws_internet_gateway.this will be created
  # module.vpc.aws_route_table.public will be created
  # module.vpc.aws_route_table_association.public["public-1"] will be created
  # module.vpc.aws_route_table_association.public["public-2"] will be created
  # module.vpc.aws_subnet.this["private-1"] will be created
  # module.vpc.aws_subnet.this["private-2"] will be created
  # module.vpc.aws_subnet.this["public-1"] will be created
  # module.vpc.aws_subnet.this["public-2"] will be created
  # module.vpc.aws_vpc.this will be created
Plan: 14 to add, 0 to change, 0 to destroy.
```

## Revisão dos planos

Cada plano contém 14 criações: 1 VPC, 4 subnets, 1 Internet Gateway,
1 route table pública, 2 associações, 2 Security Groups, 1 EC2,
1 DB Subnet Group e 1 RDS. CIDRs, tags, tipos de instância e databases conferidos.
O RDS é privado; ingress 5432 tem como origem o SG da EC2. A senha aparece como
sensível na saída textual. Não há NAT Gateway nem criação de IAM.

## Limite da evidência

Não foi executado `terraform apply`: o TF permite explicitamente validar somente
com `terraform validate` e `terraform plan` nos dois ambientes. Nenhum recurso AWS
foi criado ou alterado nesta execução, portanto não houve infraestrutura para destruir.
Os planos não comprovam instâncias em execução. A nota e o percentual exibidos
na plataforma AWS Academy não foram consultados; esta entrega não afirma sua aprovação.
