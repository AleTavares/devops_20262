# Entrega — Aula 06: Terraform Modules

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 17/09/2026

## Repositório

- URL: https://github.com/gabrielreis354/unifaat-devops-portfolio
- Pasta do projeto: [`aula-06/`](https://github.com/gabrielreis354/unifaat-devops-portfolio/tree/main/aula-06)
- Spec (SDD): [`specs/002-aula06-terraform-modules/`](https://github.com/gabrielreis354/unifaat-devops-portfolio/tree/main/specs/002-aula06-terraform-modules)

## Evidências

- [x] Módulo VPC com `for_each` para subnets dinâmicas
- [x] Módulo Security Group genérico (regras como lista de objetos)
- [x] Módulo EC2 reutilizável
- [x] Módulo RDS reutilizável
- [x] Composição entre módulos (output de um alimenta input de outro)
- [x] Dois ambientes (dev + staging) usando os mesmos módulos
- [x] `terraform validate` e `terraform plan` sem erros nos dois ambientes
- [x] README documentando cada módulo (inputs, outputs, exemplo)

## Evidência do `terraform plan` (ambiente dev)

```
$ terraform plan

  # module.api_server.aws_instance.this will be created
  # module.api_sg.aws_security_group.this will be created
  # module.api_sg.aws_security_group_rule.egress[0] will be created
  # module.api_sg.aws_security_group_rule.ingress[0] will be created
  # module.api_sg.aws_security_group_rule.ingress[1] will be created
  # module.database.aws_db_instance.main will be created
  # module.database.aws_db_subnet_group.main will be created
  # module.rds_sg.aws_security_group.this will be created
  # module.rds_sg.aws_security_group_rule.egress[0] will be created
  # module.rds_sg.aws_security_group_rule.ingress[0] will be created
  # module.vpc.aws_internet_gateway.main will be created
  # module.vpc.aws_route_table.public will be created
  # module.vpc.aws_route_table_association.public["public-1"] will be created
  # module.vpc.aws_route_table_association.public["public-2"] will be created
  # module.vpc.aws_subnet.this["private-1"] will be created
  # module.vpc.aws_subnet.this["private-2"] will be created
  # module.vpc.aws_subnet.this["public-1"] will be created
  # module.vpc.aws_subnet.this["public-2"] will be created
  # module.vpc.aws_vpc.main will be created

Plan: 19 to add, 0 to change, 0 to destroy.
```

O ambiente `staging` produz o mesmo conjunto de 19 recursos, com CIDRs e
nomes próprios (`10.1.0.0/16`, `technova-staging-*`), sem colisão com `dev`.

## Evidência do comportamento seletivo do `for_each`

Removendo `"private-2"` do mapa `subnets` (ambiente dev) e rodando `plan`
novamente, **apenas aquela subnet** deixa de aparecer no plano — as demais
(`public-1`, `public-2`, `private-1`) mantêm as mesmas chaves nomeadas, sem
qualquer reindexação:

```
$ terraform plan   # com "private-2" removida
Plan: 18 to add, 0 to change, 0 to destroy.
```

(mudança revertida antes do commit final — as 4 subnets voltaram ao mapa.)

## Evidência de `apply` real (smoke test do ambiente dev)

Apesar de não ser exigido pelo TF.md, rodei `terraform apply` real no
ambiente `dev` para confirmar que os módulos funcionam de ponta a ponta, com
`destroy` imediato após a evidência:

```
$ terraform apply
...
Apply complete! Resources: 19 added, 0 changed, 0 destroyed.

Outputs:
api_sg_id      = "sg-0d496fab03c893eb7"
db_endpoint    = "technova-dev-db.ch0dmfn54vrt.us-east-1.rds.amazonaws.com:5432"
ec2_public_ip  = "52.90.99.133"
rds_sg_id      = "sg-05fb0c5a18823aea3"
vpc_id         = "vpc-000ba4578e0f3b85e"

$ terraform plan
No changes. Your infrastructure matches the configuration.

$ aws rds describe-db-instances --db-instance-identifier technova-dev-db \
    --query "DBInstances[0].{PubliclyAccessible:PubliclyAccessible,MultiAZ:MultiAZ,Encrypted:StorageEncrypted}"
Encrypted=true  MultiAZ=false  PubliclyAccessible=false

$ terraform destroy
Destroy complete! Resources: 19 destroyed.
```

**Achado real:** a conta do AWS Academy Learner Lab rotacionou entre a
aula-05 e hoje — a key pair `technova-key` não existia na conta nova
(`InvalidKeyPair.NotFound` na criação do EC2). Resolvido com `aws ec2
import-key-pair` reaproveitando a chave pública já gerada. Confirma que o
módulo `ec2` trata a key pair como pré-requisito externo (não a cria), como
documentado no `README.md` — e vira nota prática: **se a conta do lab
rotacionar, reimportar a chave antes do apply.**

`environments/staging` permanece validado só por `terraform validate` +
`plan` (mesmos módulos que `dev`; o TF.md desaconselha aplicar os dois
ambientes ao mesmo tempo, para não dobrar o consumo do Learner Lab).

## Nota sobre o módulo RDS

Nenhum dos dois laboratórios desta aula cobre um módulo RDS. Ele foi
desenhado a partir do `aula-05-rds/rds.tf`, já validado com `terraform
apply` real na aula-05 (RDS PostgreSQL criado, testado via `psql` e
destruído). Detalhes da decisão em
[`specs/002-aula06-terraform-modules/plan.md`](https://github.com/gabrielreis354/unifaat-devops-portfolio/blob/main/specs/002-aula06-terraform-modules/plan.md).

## Sobre `terraform apply`

Conforme o `TF.md` desta aula, `terraform apply` **não é obrigatório** — a
avaliação usa `terraform validate` e `terraform plan` limpos nos dois
ambientes (o que `staging` cumpre). Ainda assim, apliquei de verdade o
ambiente `dev` como smoke test (seção acima) para confirmar que os módulos
funcionam de ponta a ponta, e destruí tudo imediatamente após capturar a
evidência — nenhum recurso ficou ativo na AWS.
