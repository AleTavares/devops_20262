# Trabalho em Aula — Aula 06: Módulos Terraform

**Aluno:** [Nicolas de Jesus Silva]  
**RA:** [6325171]  
**Data:** [26/09/26]

## Parte 1 — Identificação de Duplicação

1. **Blocos duplicados (7 blocos por ambiente, total de 14 blocos):**
   - `aws_vpc`
   - `aws_subnet` (public 1 e public 2)
   - `aws_internet_gateway`
   - `aws_security_group` (API e RDS)
   - `aws_instance` (API)

2. **O que muda entre dev e staging:**
   - Apenas valores de parâmetros: CIDR blocks das VPCs e Subnets (`10.0.x.x` vs `10.1.x.x`), tag `Environment` (`dev` vs `staging`) e os nomes dos recursos (`technova-dev-*` vs `technova-staging-*`).

3. **Módulos que seriam criados:**
   - `modules/vpc` (VPC, Subnets, IGW, Route Table)
   - `modules/security-group` (SG genérico com regras configuráveis)
   - `modules/ec2` (Instância de aplicação)
   - `modules/rds` (Banco de dados relacional)

4. **Variáveis (inputs) principais:**
   - `vpc`: `vpc_cidr`, `subnets`, `environment`, `project_name`
   - `security-group`: `name`, `vpc_id`, `ingress_rules`, `environment`, `project_name`
   - `ec2`: `instance_name`, `instance_type`, `ami_id`, `subnet_id`, `security_group_ids`, `key_name`
   - `rds`: `db_name`, `db_username`, `db_password`, `subnet_ids`, `security_group_ids`

5. **Outputs principais:**
   - `vpc`: `vpc_id`, `public_subnet_ids`, `private_subnet_ids`
   - `security-group`: `sg_id`
   - `ec2`: `instance_id`, `public_ip`
   - `rds`: `db_endpoint`, `db_port`

6. **Comparativo para criar um 3º ambiente (produção):**
   - **Sem módulos:** ~90 linhas de código duplicadas.
   - **Com módulos:** ~35 linhas chamando os módulos e passando os novos parâmetros no `terraform.tfvars`.

## Parte 2 — Design de Módulos (Diagrama de Dependências)