# Aula 06 — Módulos Terraform

**Aluno:** Carollini Godoy
**RA:** 3925000

## Descrição

Implementação de uma biblioteca de módulos Terraform reutilizáveis para provisionamento de infraestrutura na AWS.

## Módulos implementados

* **VPC:** criação da VPC, subnets públicas e privadas, Internet Gateway e tabela de rotas.
* **Security Group:** configuração de regras de entrada e saída.
* **EC2:** criação de instância EC2 com parâmetros configuráveis.
* **RDS:** criação de banco PostgreSQL em subnets privadas.

## Ambientes

Foram configurados dois ambientes utilizando os mesmos módulos:

* **Dev**
* **Staging**

Cada ambiente possui sua própria configuração de rede, EC2 e RDS.

## Validações

Foram executados:

* `terraform validate` — Dev
* `terraform plan` — Dev
* `terraform validate` — Staging
* `terraform plan` — Staging

Os dois ambientes apresentaram planos válidos, com **14 recursos para adicionar, 0 alterações e 0 recursos para destruir**.

## Repositório

A implementação completa da Aula 06 está disponível no portfólio:

https://github.com/caroll143/unifaat-devops-portfolio/tree/main/aula-06

**Entrega:** Carollini Godoy — RA 3925000
