# Entrega — Aula 06: Terraform Modules

**Aluno:** [Seu nome completo]  
**RA:** [Seu RA]  
**Data:** [Data da entrega]

## Repositório

- URL: https://github.com/SEU-USUARIO/unifaat-devops-portfolio

## Evidências

- [x] Módulo VPC com for_each para subnets dinâmicas
- [x] Módulo Security Group genérico (regras como lista de objetos)
- [x] Módulo EC2 reutilizável
- [x] Módulo RDS reutilizável
- [x] Composição entre módulos (output de um alimenta input de outro)
- [x] Dois ambientes (dev + staging) usando os mesmos módulos
- [x] `terraform validate` e `terraform plan` sem erros nos dois ambientes
- [x] README documentando cada módulo (inputs, outputs, exemplo)

## Evidência do terraform plan

Dev
Plan: 19 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + api_security_group_id = (known after apply)
  + db_endpoint           = (known after apply)
  + db_name               = "technova_dev"
  + db_port               = 5432
  + instance_id           = (known after apply)
  + public_ip             = (known after apply)
  + rds_security_group_id = (known after apply)
  + vpc_id                = (known after apply)

Staging
Plan: 19 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + api_security_group_id = (known after apply)
  + db_endpoint           = (known after apply)
  + db_name               = "technova_staging"
  + db_port               = 5432
  + instance_id           = (known after apply)
  + public_ip             = (known after apply)
  + rds_security_group_id = (known after apply)
  + vpc_id                = (known after apply)

## Evidência do terraform validate

  $ terraform -chdir=environments/dev validate
terraform -chdir=environments/staging validate
Success! The configuration is valid.

Success! The configuration is valid.