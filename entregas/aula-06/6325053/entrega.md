# Entrega — Aula 06: Terraform Modules

**Aluno:** Matheus Gabriel Correa Braga Viana
**RA:** 6325053
**Data:** 17/09/2026

## Repositório

- URL: https://github.com/Matiasdocs/unifaat-devops-portfolio

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

### Ambiente dev

```text
data.aws_ami.amazon_linux: Read complete after 1s [id=ami-043c6475a52c9e11c]

Plan: 20 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + api_server_public_ip = (known after apply)
  + db_endpoint          = (known after apply)
  + private_subnet_ids   = [(known after apply), (known after apply)]
  + public_subnet_ids    = [(known after apply), (known after apply)]
  + vpc_id               = (known after apply)
```

### Ambiente staging

```text
data.aws_ami.amazon_linux: Read complete after 1s [id=ami-043c6475a52c9e11c]

Plan: 20 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + api_server_public_ip = (known after apply)
  + db_endpoint          = (known after apply)
  + private_subnet_ids   = [(known after apply), (known after apply)]
  + public_subnet_ids    = [(known after apply), (known after apply)]
  + vpc_id               = (known after apply)
```

## Observações

Ambos os ambientes usam exatamente os mesmos 4 módulos (`vpc`, `security-group`, `ec2`, `rds`), com apenas o `terraform.tfvars` diferindo entre `dev` (CIDR `10.0.0.0/16`) e `staging` (CIDR `10.1.0.0/16`).
A composição entre módulos foi validada: `module.vpc.vpc_id` alimenta os dois Security Groups, `module.vpc.public_subnet_ids`/`private_subnet_ids` alimentam EC2 e RDS respectivamente, e `module.api_sg.sg_id`/`module.rds_sg.sg_id` alimentam suas respectivas instâncias.
 A AMI é obtida dinamicamente via `data "aws_ami"` (Amazon Linux 2023 mais recente), evitando fixar um ID que ficaria desatualizado.