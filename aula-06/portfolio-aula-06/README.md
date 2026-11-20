# Biblioteca de Módulos Terraform — TechNova Aula 06

Biblioteca de módulos Terraform reutilizáveis para provisionar ambientes completos da TechNova (VPC, Security Groups, EC2, RDS). Demonstra o princípio DRY aplicado a infraestrutura como código, com dois ambientes (dev e staging) criados a partir dos mesmos módulos com variáveis diferentes.

---

## Diagrama de Dependências entre Módulos

```
                    ┌───────────────────────────────────┐
                    │          modules/vpc               │
                    │  vpc_cidr, project, env, subnets   │
                    │                                    │
                    │  outputs:                          │
                    │  ├── vpc_id ──────────────────────►├──┐
                    │  ├── public_subnet_ids ───────────►│  │
                    │  └── private_subnet_ids ──────────►│  │
                    └───────────────────────────────────┘  │
                         │            │            │        │
                    vpc_id       vpc_id      public_id  private_ids
                         │            │            │        │
                         ▼            ▼            │        │
              ┌──────────────┐  ┌──────────────┐  │        │
              │  modules/    │  │  modules/    │  │        │
              │  security-   │  │  security-   │  │        │
              │  group (API) │  │  group (RDS) │  │        │
              │              │  │              │  │        │
              │  output:     │  │  output:     │  │        │
              │  sg_id ─────►│  │  sg_id ─────►│  │        │
              └──────────────┘  └──────────────┘  │        │
                    │ sg_id           │ sg_id      │        │
                    │                │            ▼        ▼
                    ▼                │     ┌──────────┐ ┌──────────┐
             ┌──────────────┐        └────►│ modules/ │ │ modules/ │
             │  modules/ec2 │             │   rds    │ │   rds    │
             │              │             │          │ │  (via    │
             │  subnet_id ◄─┤             │ subnets ◄┘ │ sg_ids) │
             │  sg_ids    ◄─┤             └──────────┘ └──────────┘
             └──────────────┘
```

**Regra de criação:** VPC → Security Groups → EC2 e RDS (Terraform resolve automaticamente via grafo de dependências)

---

## Módulos Disponíveis

### `modules/vpc`

Cria VPC completa com subnets dinâmicas usando `for_each`, Internet Gateway e Route Tables.

**Inputs:**

| Nome | Tipo | Obrigatório | Descrição |
|------|------|-------------|-----------|
| `vpc_cidr` | string | ✅ | CIDR block da VPC |
| `project_name` | string | ✅ | Nome do projeto |
| `environment` | string | ✅ | Ambiente (dev, staging, prod) |
| `subnets` | map(object) | ✅ | Mapa de subnets: `{cidr, az, type}` |

**Outputs:**

| Nome | Descrição |
|------|-----------|
| `vpc_id` | ID da VPC criada |
| `public_subnet_ids` | Lista de IDs das subnets públicas |
| `private_subnet_ids` | Lista de IDs das subnets privadas |
| `all_subnet_ids` | Mapa completo chave → ID |
| `internet_gateway_id` | ID do IGW |

**Exemplo:**
```hcl
module "vpc" {
  source       = "../../modules/vpc"
  vpc_cidr     = "10.0.0.0/16"
  project_name = "technova"
  environment  = "dev"
  subnets = {
    "public-1"  = { cidr = "10.0.1.0/24", az = "us-east-1a", type = "public" }
    "private-1" = { cidr = "10.0.3.0/24", az = "us-east-1a", type = "private" }
    "private-2" = { cidr = "10.0.4.0/24", az = "us-east-1b", type = "private" }
  }
}
```

---

### `modules/security-group`

Módulo genérico de Security Group — funciona para API, RDS, bastion ou qualquer outro uso.

**Inputs:**

| Nome | Tipo | Obrigatório | Descrição |
|------|------|-------------|-----------|
| `name` | string | ✅ | Nome do SG (sem prefixo de projeto/env) |
| `description` | string | ❌ | Descrição |
| `vpc_id` | string | ✅ | ID da VPC |
| `project_name` | string | ✅ | Nome do projeto |
| `environment` | string | ✅ | Ambiente |
| `ingress_rules` | list(object) | ❌ | Regras de entrada |

**Outputs:**

| Nome | Descrição |
|------|-----------|
| `sg_id` | ID do Security Group |
| `sg_name` | Nome do Security Group |
| `sg_arn` | ARN do Security Group |

**Exemplo:**
```hcl
module "api_sg" {
  source       = "../../modules/security-group"
  name         = "api-sg"
  vpc_id       = module.vpc.vpc_id
  project_name = "technova"
  environment  = "dev"
  ingress_rules = [
    { port = 22,   protocol = "tcp", description = "SSH",     cidr_blocks = ["0.0.0.0/0"] },
    { port = 3000, protocol = "tcp", description = "API",     cidr_blocks = ["0.0.0.0/0"] },
    { port = 5432, protocol = "tcp", description = "Postgres", source_sg_id = module.api_sg.sg_id }
  ]
}
```

---

### `modules/ec2`

Instância EC2 reutilizável com AMI, tipo, subnet e Security Groups configuráveis.

**Inputs:**

| Nome | Tipo | Obrigatório | Descrição |
|------|------|-------------|-----------|
| `instance_name` | string | ✅ | Nome da instância |
| `instance_type` | string | ❌ | Tipo (default: `t2.micro`) |
| `ami_id` | string | ✅ | ID da AMI |
| `subnet_id` | string | ✅ | ID da subnet |
| `security_group_ids` | list(string) | ✅ | Lista de SG IDs |
| `key_name` | string | ✅ | Nome do Key Pair |
| `iam_instance_profile` | string | ❌ | Instance Profile (default: `LabInstanceProfile`) |
| `user_data` | string | ❌ | Script de inicialização |
| `project_name` | string | ✅ | Nome do projeto |
| `environment` | string | ✅ | Ambiente |

**Outputs:** `instance_id`, `public_ip`, `private_ip`, `public_dns`

---

### `modules/rds`

DB Subnet Group + instância RDS PostgreSQL 15 nas subnets privadas.

**Inputs:**

| Nome | Tipo | Obrigatório | Descrição |
|------|------|-------------|-----------|
| `project_name` | string | ✅ | Nome do projeto |
| `environment` | string | ✅ | Ambiente |
| `db_name` | string | ✅ | Nome do banco |
| `db_username` | string | ✅ | Usuário master |
| `db_password` | string (sensitive) | ✅ | Senha master |
| `subnet_ids` | list(string) | ✅ | Subnets privadas (mín. 2 AZs) |
| `security_group_ids` | list(string) | ✅ | SG IDs |
| `instance_class` | string | ❌ | Classe (default: `db.t3.micro`) |
| `allocated_storage` | number | ❌ | GB (default: 20) |

**Outputs:** `db_endpoint`, `db_address`, `db_port`, `db_name`, `db_identifier`

---

## Ambientes

### Dev (`environments/dev/`)

| Recurso | Configuração |
|---------|-------------|
| VPC CIDR | `10.0.0.0/16` |
| Subnets públicas | `10.0.1.0/24`, `10.0.2.0/24` |
| Subnets privadas | `10.0.3.0/24`, `10.0.4.0/24` |
| EC2 | t2.micro — technova-dev-api-server |
| RDS | db.t3.micro — banco `technova_dev` |

### Staging (`environments/staging/`)

| Recurso | Configuração |
|---------|-------------|
| VPC CIDR | `10.1.0.0/16` |
| Subnets públicas | `10.1.1.0/24`, `10.1.2.0/24` |
| Subnets privadas | `10.1.3.0/24`, `10.1.4.0/24` |
| EC2 | t2.micro — technova-staging-api-server |
| RDS | db.t3.micro — banco `technova_staging` |

---

## Como Usar

### Pré-requisitos

- AWS CLI instalado e configurado
- Terraform ≥ 1.0
- Acesso ao AWS Academy Learner Lab

### 1. Configurar credenciais

```bash
source aws-creds.sh
aws sts get-caller-identity
```

### 2. Criar terraform.tfvars com a senha (nunca commitar)

```bash
# environments/dev/terraform.tfvars já existe — ajuste a senha
# environments/staging/terraform.tfvars já existe — ajuste a senha
```

### 3. Aplicar um ambiente

```bash
cd environments/dev/
terraform init
terraform validate
terraform plan
terraform apply
```

### 4. Ver outputs e testar

```bash
terraform output ec2_public_ip
terraform output ssh_command
terraform output psql_command
```

### 5. Destruir após testes

```bash
terraform destroy
# SEMPRE destrua para não consumir recursos do Learner Lab
```

### Adicionar um novo ambiente (produção)

1. Copie `environments/dev/` para `environments/prod/`
2. Mude os CIDRs para `10.2.0.0/16` e seus subnets
3. Mude `db_name` para `technova_prod`
4. `terraform init && terraform apply`

Isso é o poder dos módulos: um novo ambiente completo em minutos.

---

## Estrutura de Arquivos

```
aula-06/
├── .gitignore
├── README.md
├── modules/
│   ├── vpc/
│   │   ├── main.tf        # VPC + subnets (for_each) + IGW + Route Tables
│   │   ├── variables.tf   # vpc_cidr, project_name, environment, subnets (map)
│   │   └── outputs.tf     # vpc_id, public_subnet_ids, private_subnet_ids
│   ├── security-group/
│   │   ├── main.tf        # SG genérico + regras via aws_security_group_rule
│   │   ├── variables.tf   # name, vpc_id, ingress_rules (list de objetos)
│   │   └── outputs.tf     # sg_id, sg_name, sg_arn
│   ├── ec2/
│   │   ├── main.tf        # Instância EC2 com user_data opcional
│   │   ├── variables.tf   # instance_name, ami_id, subnet_id, sg_ids, key_name
│   │   └── outputs.tf     # instance_id, public_ip, private_ip
│   └── rds/
│       ├── main.tf        # DB Subnet Group + RDS PostgreSQL 15
│       ├── variables.tf   # db_name, username, password (sensitive), subnet_ids
│       └── outputs.tf     # db_endpoint, db_address, db_port
└── environments/
    ├── dev/
    │   ├── providers.tf   # Provider AWS + required_providers
    │   ├── variables.tf   # aws_region, db_password
    │   ├── main.tf        # Chama os 4 módulos com CIDRs 10.0.x.x
    │   ├── outputs.tf     # IPs, URLs, comandos SSH/psql
    │   └── terraform.tfvars  # ← no .gitignore
    └── staging/
        ├── providers.tf
        ├── variables.tf
        ├── main.tf        # Mesmos módulos, CIDRs 10.1.x.x
        ├── outputs.tf
        └── terraform.tfvars  # ← no .gitignore
```
