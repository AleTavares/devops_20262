# Trabalho em Aula - Aula 06: Modulos Terraform

**Aluno:** Gabriel Carneiro da Silva  
**RA:** 6325300  
**Data:** 24/09/2026

## Parte 1 - Identificacao de Duplicacao

1. Blocos de recursos duplicados entre `dev` e `staging`:
   - `aws_vpc`
   - `aws_subnet` publica 1
   - `aws_subnet` publica 2
   - `aws_internet_gateway`
   - `aws_security_group` da API
   - `aws_security_group` do RDS
   - `aws_instance` da API

   No codigo apresentado sao 7 tipos/blocos por ambiente, totalizando 14 blocos muito parecidos.

2. O que muda entre `dev` e `staging`:
   - CIDR da VPC: `10.0.0.0/16` no dev e `10.1.0.0/16` no staging
   - CIDRs das subnets
   - nomes dos recursos e tags `Environment`
   - referencias internas aos recursos do proprio ambiente
   - eventualmente nome do banco, prefixos e variaveis especificas de ambiente

3. Modulos que eu criaria:
   - `modules/vpc`
   - `modules/security-group`
   - `modules/ec2`
   - `modules/rds`

4. Variaveis de cada modulo:

   `vpc`:
   - `vpc_cidr`
   - `project_name`
   - `environment`
   - `subnets`
   - `tags`

   `security-group`:
   - `name`
   - `description`
   - `vpc_id`
   - `ingress_rules`
   - `project_name`
   - `environment`
   - `tags`

   `ec2`:
   - `instance_name`
   - `ami_id`
   - `instance_type`
   - `subnet_id`
   - `security_group_ids`
   - `key_name`
   - `user_data`
   - `project_name`
   - `environment`

   `rds`:
   - `db_name`
   - `db_username`
   - `db_password`
   - `subnet_ids`
   - `security_group_ids`
   - `instance_class`
   - `allocated_storage`
   - `project_name`
   - `environment`

5. Outputs de cada modulo:

   `vpc`:
   - `vpc_id`
   - `public_subnet_ids`
   - `private_subnet_ids`
   - `subnet_id_map`

   `security-group`:
   - `sg_id`

   `ec2`:
   - `instance_id`
   - `public_ip`
   - `private_ip`

   `rds`:
   - `db_endpoint`
   - `db_name`
   - `db_port`

6. Linhas para ambiente de producao:
   - Com o codigo atual, seria necessario copiar quase o mesmo bloco de ambiente de novo, aproximadamente mais 90 linhas no exemplo da atividade.
   - Com modulos, bastaria criar uma nova pasta ou novo bloco de ambiente chamando os modulos com variaveis de producao. O codigo novo ficaria bem menor, perto de 30 a 50 linhas de composicao, sem duplicar a implementacao dos recursos.

## Parte 2 - Design de Modulos

Diagrama de dependencias:

```text
modules/vpc
  outputs:
    - vpc_id
    - public_subnet_ids
    - private_subnet_ids
        |
        | vpc_id
        v
modules/security-group
  cria api_sg e rds_sg
  output:
    - sg_id
        |
        +--> modules/ec2
        |       inputs:
        |       - subnet_id = public_subnet_ids[0]
        |       - security_group_ids = [api_sg.sg_id]
        |
        +--> modules/rds
                inputs:
                - subnet_ids = private_subnet_ids
                - security_group_ids = [rds_sg.sg_id]
```

- Modulo criado primeiro: `vpc`, porque todos os outros precisam de `vpc_id` ou das subnets criadas por ele.
- Output da VPC usado pelos Security Groups: `vpc_id`.
- O modulo EC2 depende de 2 outros modulos: `vpc` para a subnet publica e `security-group` para o SG da API.
- Se destruir a VPC, os recursos dependentes tambem precisam ser destruidos ou recriados, porque EC2, Security Groups e RDS pertencem aquela rede.
- A vantagem de um modulo generico de Security Group e reutilizar a mesma estrutura para API, RDS, bastion ou outro servico. O que muda sao as regras de entrada, nao a implementacao do recurso.
