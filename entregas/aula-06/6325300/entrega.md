# Entrega - Aula 06: Terraform Modules

**Aluno:** Gabriel Carneiro da Silva  
**RA:** 6325300  
**Data:** 24/09/2026

## Repositorio

- URL: https://github.com/gcdsofc/unifaat-devops-portfolio
- Pasta da Aula 06: https://github.com/gcdsofc/unifaat-devops-portfolio/tree/main/aula-06
- README da biblioteca: https://github.com/gcdsofc/unifaat-devops-portfolio/blob/main/aula-06/README.md

## Evidencias

- [x] Modulo VPC com `for_each` para subnets dinamicas
- [x] Modulo Security Group generico com regras como lista de objetos
- [x] Modulo EC2 reutilizavel
- [x] Modulo RDS reutilizavel
- [x] Composicao entre modulos: output de um modulo alimenta input de outro
- [x] Dois ambientes (`dev` + `staging`) usando os mesmos modulos
- [x] `terraform validate` sem erros nos dois ambientes
- [x] `terraform plan` sem erros nos dois ambientes
- [x] README documentando modulos, inputs, outputs, dependencias e exemplo

## Evidencias do Terraform

### Ambiente dev

- Validate: https://github.com/gcdsofc/unifaat-devops-portfolio/blob/main/aula-06/environments/dev/terraform-validate-output.txt
- Plan: https://github.com/gcdsofc/unifaat-devops-portfolio/blob/main/aula-06/environments/dev/terraform-plan-output.txt

Resumo do plan:

```text
Plan: 14 to add, 0 to change, 0 to destroy.
```

### Ambiente staging

- Validate: https://github.com/gcdsofc/unifaat-devops-portfolio/blob/main/aula-06/environments/staging/terraform-validate-output.txt
- Plan: https://github.com/gcdsofc/unifaat-devops-portfolio/blob/main/aula-06/environments/staging/terraform-plan-output.txt

Resumo do plan:

```text
Plan: 14 to add, 0 to change, 0 to destroy.
```

## Estrutura entregue

```text
aula-06/
|-- environments/
|   |-- dev/
|   `-- staging/
`-- modules/
    |-- vpc/
    |-- security-group/
    |-- ec2/
    `-- rds/
```

## Observacao

O TF da Aula 06 nao exige `terraform apply`; o enunciado pede `terraform validate` e `terraform plan` sem erros nos dois ambientes. As evidencias estao registradas no repositorio pessoal.
