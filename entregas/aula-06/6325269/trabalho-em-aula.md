# Trabalho em Aula — Aula 06: Módulos Terraform

**Aluno:** Sirlande Martins  
**RA:** 6325269  
**Data:** 24/09/2026

## Parte 1 — Identificação de Duplicação

1. **Blocos de recursos duplicados entre dev e staging:** o arquivo tem 14 blocos `resource`, que
   formam **7 pares** idênticos na estrutura, um de cada ambiente:
   - `aws_vpc` (`dev` / `staging`)
   - `aws_subnet` pública 1 (`dev_public_1` / `staging_public_1`)
   - `aws_subnet` pública 2 (`dev_public_2` / `staging_public_2`)
   - `aws_internet_gateway` (`dev` / `staging`)
   - `aws_security_group` da API (`dev_api` / `staging_api`)
   - `aws_security_group` do RDS (`dev_rds` / `staging_rds`)
   - `aws_instance` da API (`dev_api` / `staging_api`)

   Ou seja, o bloco de staging (~85 linhas) é praticamente um copy-paste do bloco de dev.

2. **O que muda entre dev e staging:** só três coisas:
   - **O nome do ambiente** (`dev` → `staging`), que aparece nos nomes lógicos dos recursos, nas tags
     `Name`/`Environment` e no `name` dos Security Groups.
   - **O CIDR da VPC**: `10.0.0.0/16` → `10.1.0.0/16`.
   - **Os CIDRs das subnets**, que acompanham a VPC: `10.0.1.0/24` e `10.0.2.0/24` → `10.1.1.0/24` e
     `10.1.2.0/24`.

   Todo o resto é igual nos dois: AZs (`us-east-1a`/`us-east-1b`), AMI, `instance_type`
   (`t2.micro`), `key_name`, portas liberadas (80, 22, 5432), regra de egress e tag `Project`.

3. **Módulos que eu criaria (mín. 3):**
   - **`modules/vpc`**: VPC, subnets públicas (e privadas, para o RDS), Internet Gateway e Route
     Tables. No código atual o IGW é criado mas nenhuma route table aponta para ele, então as subnets
     "públicas" não têm rota de saída para a internet. O módulo já corrigiria isso.
   - **`modules/security-group`**: um Security Group genérico, com as regras de ingress/egress
     recebidas por variável. Chamado duas vezes: uma para a API e outra para o RDS.
   - **`modules/ec2`**: a instância da API.
   - **`modules/rds`** (opcional agora, mas previsto): DB Subnet Group + instância RDS, consumindo o
     SG do RDS que hoje é criado sem nenhum banco associado.

   Na raiz fica um único `main.tf` chamando esses módulos, com os valores de cada ambiente em
   arquivos `.tfvars` separados (`dev.tfvars`, `staging.tfvars`).

4. **Variáveis (inputs) de cada módulo:**

   | Módulo | Inputs |
   |--------|--------|
   | `vpc` | `project`, `environment`, `vpc_cidr`, `public_subnet_cidrs` (lista), `private_subnet_cidrs` (lista), `availability_zones` (lista) |
   | `security-group` | `project`, `environment`, `name`, `vpc_id`, `ingress_rules` (lista de objetos com porta, protocolo e `cidr_blocks` ou `security_groups`), `egress_rules` |
   | `ec2` | `project`, `environment`, `ami`, `instance_type`, `subnet_id`, `security_group_ids` (lista), `key_name` |
   | `rds` | `project`, `environment`, `subnet_ids` (privadas), `security_group_ids`, `engine_version`, `instance_class`, `db_name`, `db_username`, `db_password` (`sensitive = true`) |

   `project` e `environment` servem para montar os nomes e as tags padronizadas
   (`technova-<env>-<recurso>`), no lugar das strings fixas repetidas no código atual.

5. **Outputs de cada módulo:**

   | Módulo | Outputs |
   |--------|---------|
   | `vpc` | `vpc_id`, `vpc_cidr`, `public_subnet_ids`, `private_subnet_ids`, `internet_gateway_id` |
   | `security-group` | `security_group_id`, `security_group_name` |
   | `ec2` | `instance_id`, `public_ip`, `private_ip` |
   | `rds` | `db_endpoint`, `db_port`, `db_instance_id` |

6. **Linhas para ambiente de produção (código atual vs com módulos):**
   - **Código atual:** mais **~85 linhas**, copiando o bloco inteiro de staging e trocando à mão
     `staging` → `prod` em uns 20 lugares (nomes lógicos, referências, tags) e os CIDRs. Cada troca
     esquecida vira um bug, por exemplo uma subnet de prod apontando para a VPC de staging.
   - **Com módulos:** só um arquivo **`prod.tfvars` com ~6 a 8 linhas** (`environment = "prod"`,
     `vpc_cidr = "10.2.0.0/16"`, os CIDRs das subnets e o `instance_type`). Nenhuma linha de
     `resource` é escrita de novo. Mesmo se o ambiente fosse um root module separado com as chamadas
     `module` explícitas, seriam ~25 a 30 linhas, e ainda sem duplicar lógica.

## Parte 2 — Design de Módulos (Diagrama de Dependências)

```
                    ┌──────────────────────────┐
                    │        VPC Module        │
                    │  (VPC, subnets, IGW, RT) │
                    │                          │
                    │  Outputs:                │
                    │  - vpc_id                │
                    │  - public_subnet_ids     │
                    │  - private_subnet_ids    │
                    └─────┬──────────────┬─────┘
                          │ vpc_id       │ vpc_id
                          ▼              ▼
           ┌──────────────────┐     ┌──────────────────┐
           │  SG Module (API) │────►│  SG Module (RDS) │
           │                  │sg_id│  ingress 5432    │
           │  Outputs:        │     │  origem = SG API │
           │  - sg_id         │     │  Outputs:        │
           └────────┬─────────┘     │  - sg_id         │
                    │ sg_id         └────────┬─────────┘
                    │                        │ sg_id
  public_subnet_ids │                        │  private_subnet_ids
  (da VPC) ───────► ▼                        ▼  ◄─────── (da VPC)
           ┌──────────────────┐     ┌──────────────────┐
           │    EC2 Module    │     │    RDS Module    │
           │  Outputs:        │     │  Outputs:        │
           │  - instance_id   │     │  - db_endpoint   │
           │  - public_ip     │     │  - db_port       │
           └──────────────────┘     └──────────────────┘

Ordem de criação:
  1º VPC  →  2º SG API  →  3º SG RDS  →  4º EC2 e RDS (em paralelo)
```

A diferença para o diagrama de referência é a seta **SG API → SG RDS**. No código original, a regra de
ingress 5432 do RDS usa `security_groups = [aws_security_group.dev_api.id]`, ou seja, o SG do RDS
depende do `sg_id` do SG da API e não pode ser criado antes dele.

- **Módulo criado primeiro e por quê:** o **módulo VPC**. Todos os outros recursos ficam "dentro" da
  VPC: os Security Groups precisam do `vpc_id`, e EC2 e RDS precisam dos IDs das subnets. Sem VPC, nenhum
  outro módulo tem os inputs de que precisa. O Terraform descobre essa ordem sozinho a partir das
  referências (`module.vpc.vpc_id`), sem precisar de `depends_on`.
- **Output da VPC que os Security Groups consomem:** o **`vpc_id`**. Um Security Group sempre pertence a
  uma VPC específica.
- **Quantos módulos o EC2 depende:** de **2**: o **VPC** (usa o `public_subnet_ids`, que define em qual
  subnet a instância sobe) e o **SG da API** (usa o `sg_id`). O RDS depende da VPC (`private_subnet_ids`)
  e do SG do RDS e, de forma indireta, também do SG da API.
- **O que acontece com os outros módulos ao destruir a VPC:** eles são destruídos também. Como todos
  dependem dela, o Terraform monta a ordem inversa do grafo: primeiro EC2 e RDS, depois o SG do RDS, o SG
  da API e, por último, subnets, IGW e a VPC. Um `terraform destroy -target=module.vpc` também leva junto
  tudo o que depende da VPC. Fora do Terraform, a própria AWS não deixa apagar uma VPC que ainda tem
  instâncias, ENIs ou SGs dentro dela.
- **Vantagem de um módulo genérico de Security Group:** **uma única implementação** serve para qualquer
  SG (API, RDS e outros que vierem, como um bastion ou um load balancer). O que muda entre eles são só
  as regras, e elas entram por variável. Assim uma correção ou padronização (tags, descrição
  obrigatória, egress padrão) é feita em um lugar só e vale para todos. Com um `api-sg` e um `rds-sg`
  separados, o código de "criar SG com regras" ficaria repetido em dois módulos, que é justamente a
  duplicação que a refatoração quer eliminar.
