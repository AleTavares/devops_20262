# Entrega — TF Aula 06: Terraform Modules

**Aluno:** Eloísa Brandão
**RA:** 2325096

## Projeto

Projeto desenvolvido no repositório `unifaat-devops-portfolio`, contendo a biblioteca de módulos Terraform e os ambientes `dev` e `staging`.

**Repositório do projeto:**
https://github.com/brandelas/unifaat-devops-portfolio

**Branch do desenvolvimento:**
`feature/aula-06-modules`

## Implementação

Foram implementados os seguintes módulos Terraform:

* VPC;
* Security Group;
* EC2;
* RDS PostgreSQL.

Os módulos são reutilizados nos ambientes `dev` e `staging`, com configurações específicas de rede, EC2 e banco de dados para cada ambiente.

## Validação

Foram executados os comandos:

```text
terraform init
terraform validate
terraform plan
```

nos ambientes `dev` e `staging`.

Os dois ambientes foram validados com sucesso e apresentaram:

```text
Plan: 17 to add, 0 to change, 0 to destroy.
```

Não foi executado `terraform apply`.

## Entregáveis

* Código Terraform: repositório `unifaat-devops-portfolio`;
* Documentação: `aula-06/README.md`;
* Entrega da atividade: `entregas/aula-06/2325096/entrega.md`.
