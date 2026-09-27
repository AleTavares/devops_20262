# Trabalho em Aula — Aula 06: Módulos Terraform

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 17/09/2026

## Parte 1 — Identificação de Duplicação

1. **Blocos de recursos duplicados entre dev e staging (7 pares, 14 recursos):**
   - `aws_vpc` (`dev` / `staging`)
   - `aws_subnet` público 1 (`dev_public_1` / `staging_public_1`)
   - `aws_subnet` público 2 (`dev_public_2` / `staging_public_2`)
   - `aws_internet_gateway` (`dev` / `staging`)
   - `aws_security_group` da API (`dev_api` / `staging_api`)
   - `aws_security_group` do RDS (`dev_rds` / `staging_rds`)
   - `aws_instance` da API (`dev_api` / `staging_api`)

2. **O que muda entre dev e staging:** só um punhado de valores —
   o CIDR da VPC (`10.0.0.0/16` → `10.1.0.0/16`), os CIDRs das duas subnets
   (`10.0.1.0/24`/`10.0.2.0/24` → `10.1.1.0/24`/`10.1.2.0/24`), a tag
   `Environment` (`dev` → `staging`) e o prefixo usado em todos os nomes/tags
   (`technova-dev-*` → `technova-staging-*`). Toda a **estrutura** — quantidade
   de subnets, regras de ingress/egress dos Security Groups, AMI, tipo de
   instância, referência ao key pair — é idêntica byte a byte.

3. **Módulos que eu criaria (mínimo 3, uso 4):**
   - `modules/vpc` — VPC + subnets + Internet Gateway + route table
   - `modules/security-group` — SG genérico, reutilizável tanto para a API
     quanto para o RDS (e qualquer SG futuro)
   - `modules/ec2` — instância EC2 parametrizável
   - `modules/rds` — RDS PostgreSQL parametrizável (não aparece no trecho
     de código analisado, mas é parte natural da arquitetura da TechNova das
     aulas anteriores e está no diagrama de referência do exercício)

4. **Variáveis (inputs) de cada módulo:**
   - **vpc:** `vpc_cidr`, `project_name`, `environment`, `subnets`
     (`map(object)` com `cidr`, `az`, `type`)
   - **security-group:** `name`, `vpc_id`, `ingress_rules` (`list(object)`),
     `environment`, `project_name`
   - **ec2:** `instance_name`, `instance_type`, `ami_id`, `subnet_id`,
     `security_group_ids`, `key_name`
   - **rds:** `db_name`, `db_username`, `db_password` (sensitive),
     `subnet_ids`, `security_group_ids`, `instance_class`, `environment`,
     `project_name`

5. **Outputs de cada módulo:**
   - **vpc:** `vpc_id`, `public_subnet_ids`, `private_subnet_ids`
   - **security-group:** `sg_id`
   - **ec2:** `instance_id`, `public_ip`, `private_ip`
   - **rds:** `db_endpoint`, `db_name`, `db_port`

6. **Linhas para um ambiente de produção — código atual vs. módulos:**
   O `main.tf` atual tem ~180 linhas para 2 ambientes (~90 linhas por
   ambiente). Sem módulos, produção seria **mais uma cópia inteira**: +90
   linhas, chegando a ~270 linhas totais, todas quase idênticas e todas
   precisando ser mantidas em sincronia manualmente. Com módulos, os 4
   módulos são escritos **uma única vez** (a lógica fica concentrada neles);
   um ambiente novo é só um bloco de chamadas `module { ... }` com valores
   diferentes — algo como **20-30 linhas**, não 90. Produção deixa de ser
   "copiar e adaptar 90 linhas" e vira "adicionar um bloco pequeno".

## Parte 2 — Design de Módulos (Diagrama de Dependências)

```
                    ┌──────────────────┐
                    │   modules/vpc     │
                    │                    │
                    │ out: vpc_id        │
                    │ out: public_ids[]  │
                    │ out: private_ids[] │
                    └─────────┬──────────┘
                              │ vpc_id
              ┌───────────────┼───────────────┐
              ▼                                ▼
   ┌────────────────────┐            ┌────────────────────┐
   │ modules/security-   │            │ modules/security-   │
   │ group (api)          │            │ group (rds)          │
   │ out: sg_id            │            │ out: sg_id            │
   └──────────┬───────────┘            └──────────┬───────────┘
              │ sg_id                              │ sg_id
   public_subnet_ids                    private_subnet_ids
              │                                    │
              ▼                                    ▼
   ┌────────────────────┐            ┌────────────────────┐
   │  modules/ec2         │            │  modules/rds         │
   │  (subnet_id +         │            │  (subnet_ids +        │
   │   security_group_ids) │            │   security_group_ids) │
   └────────────────────┘            └────────────────────┘
```

- **Qual módulo deve ser criado primeiro, e por quê:** o `vpc`. Todos os
  outros módulos precisam de `vpc_id` (Security Groups) ou dos IDs das
  subnets (EC2 e RDS) que só existem depois da VPC ser criada — é a base de
  toda a dependência.
- **Os módulos de Security Group dependem de qual output da VPC:**
  `vpc_id` — é o único dado que o `aws_security_group` precisa da VPC para
  saber onde aplicar as regras.
- **De quantos outros módulos o módulo EC2 depende:** 2 — do `vpc` (para o
  `subnet_id` da subnet pública) e do `security-group` (para
  `security_group_ids`).
- **O que acontece com os outros módulos se a VPC for destruída:** o
  Terraform enxerga a dependência implícita via referência aos outputs
  (`module.vpc.vpc_id`, `module.vpc.public_subnet_ids`), então ele tentaria
  destruir primeiro tudo que depende da VPC (SGs, EC2, RDS) antes de poder
  destruir a própria VPC. Se alguém tentasse remover só a VPC do state fora
  de ordem, os outros módulos ficariam órfãos — outputs como `vpc_id`
  deixariam de existir e o próximo `plan` mostraria erro ou tentativa de
  recriação em cascata.
- **Vantagem de um módulo genérico de Security Group em vez de "api-sg" e
  "rds-sg" separados:** com um único módulo parametrizado por
  `ingress_rules` (lista de objetos), a mesma lógica de `aws_security_group`
  é escrita uma vez e reutilizada para qualquer finalidade — API, RDS, e
  amanhã um bastion host ou um load balancer, bastando passar regras
  diferentes. Dois módulos hardcoded (`api-sg`, `rds-sg`) duplicariam a
  mesma estrutura de recurso só mudando as regras, reproduzindo exatamente o
  problema de duplicação que o exercício pede para eliminar.
