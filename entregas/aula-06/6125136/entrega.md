# Entrega — Aula 06: Terraform Modules

**Aluno:** Hector Marcelo Pedroso dos Santos
**RA:** 6125136
**Data:** 22/09/2026

## Repositório

- URL: https://github.com/hectorbackfront/unifaat-devops-portfolio
- Pasta do projeto: `aula-06/` (módulos em `modules/`, ambientes em `environments/`)

## Evidências

- [x] Módulo VPC com `for_each` para subnets dinâmicas
- [x] Módulo Security Group genérico (regras como lista de objetos)
- [x] Módulo EC2 reutilizável
- [x] Módulo RDS reutilizável
- [x] Composição entre módulos (output de um alimenta input de outro)
- [x] Dois ambientes (dev + staging) usando os mesmos módulos
- [x] `terraform validate` e `terraform plan` sem erros nos dois ambientes
- [x] README documentando cada módulo (inputs, outputs, exemplo)

Documentação completa dos 4 módulos (inputs, outputs, exemplo de uso) e
diagrama de composição estão no README do projeto:
https://github.com/hectorbackfront/unifaat-devops-portfolio/blob/master/aula-06/README.md

> Conforme o enunciado, não foi executado `terraform apply` — apenas
> `validate`/`plan`, para não consumir dois ambientes simultâneos de
> recursos do AWS Academy Learner Lab.

## Evidência do terraform plan

### Ambiente dev

```text
Plan: 14 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + api_public_ip      = (known after apply)
  + db_endpoint        = (known after apply)
  + db_name            = "technova_dev"
  + private_subnet_ids = [ (known after apply), (known after apply) ]
  + public_subnet_ids  = [ (known after apply), (known after apply) ]
  + vpc_id             = (known after apply)
```

### Ambiente staging

```text
Plan: 14 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + api_public_ip      = (known after apply)
  + db_endpoint        = (known after apply)
  + db_name            = "technova_staging"
  + private_subnet_ids = [ (known after apply), (known after apply) ]
  + public_subnet_ids  = [ (known after apply), (known after apply) ]
  + vpc_id             = (known after apply)
```
