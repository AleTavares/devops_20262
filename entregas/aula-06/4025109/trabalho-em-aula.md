# Trabalho em Aula — Aula 06: Módulos Terraform

**Aluno:** Fernanda Tavares  
**RA:** 4025109  
**Data:** 24/09/2026

---

## Parte 1 — Identificação de Duplicação

### 1. Blocos de recursos duplicados entre dev e staging

Todos os 7 tipos de recurso aparecem duplicados — o ambiente staging é uma cópia quase idêntica do dev. São 7 blocos em cada ambiente (14 no total):

| # | Recurso | dev | staging |
|---|---------|-----|---------|
| 1 | `aws_vpc` | `dev` | `staging` |
| 2 | `aws_subnet` (pública 1) | `dev_public_1` | `staging_public_1` |
| 3 | `aws_subnet` (pública 2) | `dev_public_2` | `staging_public_2` |
| 4 | `aws_internet_gateway` | `dev` | `staging` |
| 5 | `aws_security_group` (API) | `dev_api` | `staging_api` |
| 6 | `aws_security_group` (RDS) | `dev_rds` | `staging_rds` |
| 7 | `aws_instance` | `dev_api` | `staging_api` |

A estrutura, as portas dos Security Groups, o `instance_type`, a AMI, a `key_name` e o layout das subnets são **exatamente iguais**. É um caso clássico de copiar-colar-e-trocar-o-nome.

### 2. O que muda entre dev e staging

Pouquíssimos valores. Na prática, apenas dois eixos de variação:

- **CIDR blocks:** dev usa `10.0.0.0/16` (subnets `10.0.1.0/24` e `10.0.2.0/24`); staging usa `10.1.0.0/16` (subnets `10.1.1.0/24` e `10.1.2.0/24`).
- **Nome/Environment nas tags e nos nomes dos recursos:** o prefixo `technova-dev-*` vira `technova-staging-*` e a tag `Environment` muda de `dev` para `staging`.

Todo o resto (AZs `us-east-1a`/`us-east-1b`, `t2.micro`, AMI `ami-0c02fb55956c7d316`, portas 80/22/5432, `key_name`) é idêntico. Isso confirma que os ambientes diferem só por **parâmetros**, não por estrutura — exatamente o que módulos resolvem.

### 3. Módulos que eu criaria (mínimo 3)

Criaria 4 módulos, um por responsabilidade:

- **`modules/vpc`** — VPC, subnets públicas, Internet Gateway e route tables. Responsável pela rede base.
- **`modules/security-group`** — Security Group genérico, com regras de ingress/egress recebidas por variável. Reutilizável tanto para o SG da API quanto para o do RDS.
- **`modules/ec2`** — Instância EC2 da API. Recebe subnet e SG prontos.
- **`modules/rds`** — Banco RDS PostgreSQL. Recebe subnets privadas e SG prontos.

### 4. Variáveis (inputs) de cada módulo

**`modules/vpc`**
```hcl
variable "environment"   { type = string }              # "dev", "staging", "prod"
variable "project_name"  { type = string, default = "technova" }
variable "vpc_cidr"      { type = string }              # "10.0.0.0/16"
variable "public_subnet_cidrs" { type = list(string) }  # ["10.0.1.0/24", "10.0.2.0/24"]
variable "azs"           { type = list(string) }        # ["us-east-1a", "us-east-1b"]
```

**`modules/security-group`**
```hcl
variable "name"        { type = string }
variable "vpc_id"      { type = string }
variable "ingress_rules" {
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
}
variable "tags" { type = map(string) }
```

**`modules/ec2`**
```hcl
variable "name"          { type = string }
variable "ami"           { type = string }
variable "instance_type" { type = string, default = "t2.micro" }
variable "subnet_id"     { type = string }
variable "sg_id"         { type = string }
variable "key_name"      { type = string }
variable "tags"          { type = map(string) }
```

**`modules/rds`**
```hcl
variable "name"           { type = string }
variable "engine_version" { type = string }
variable "instance_class" { type = string, default = "db.t3.micro" }
variable "subnet_ids"     { type = list(string) }   # subnets privadas
variable "sg_id"          { type = string }
variable "tags"           { type = map(string) }
```

### 5. Outputs de cada módulo

**`modules/vpc`**
- `vpc_id`
- `public_subnet_ids` (lista)
- `private_subnet_ids` (lista)
- `igw_id`

**`modules/security-group`**
- `sg_id`

**`modules/ec2`**
- `instance_id`
- `public_ip`
- `private_ip`

**`modules/rds`**
- `db_endpoint`
- `db_port`
- `db_instance_id`

### 6. Linhas para adicionar um ambiente de produção — atual vs com módulos

- **Com o código atual (copiar-colar):** precisaria duplicar todos os 7 blocos novamente, trocando prefixos e CIDRs. São cerca de **~90 linhas** por ambiente (metade das 180 atuais). Além do volume, cada mudança futura precisa ser replicada nos 3 lugares → altíssimo risco de inconsistência.

- **Com módulos:** basta um bloco de chamada de ambiente com os parâmetros de prod. Algo em torno de **~10 a 15 linhas**:

```hcl
module "vpc_prod" {
  source              = "./modules/vpc"
  environment         = "prod"
  vpc_cidr            = "10.2.0.0/16"
  public_subnet_cidrs = ["10.2.1.0/24", "10.2.2.0/24"]
  azs                 = ["us-east-1a", "us-east-1b"]
}
# + chamadas dos módulos sg, ec2, rds passando os outputs da vpc_prod
```

Ou, indo além, usando `for_each` sobre um mapa de ambientes, produção entra apenas adicionando uma **chave no mapa** (2-3 linhas).

---

## Parte 2 — Design de Módulos (Diagrama de Dependências)

```
                    ┌──────────────────────┐
                    │      VPC Module      │
                    │  Inputs:             │
                    │   environment, cidr  │
                    │  Outputs:            │
                    │   - vpc_id           │
                    │   - public_subnet_ids│
                    │   - private_subnet_ids│
                    └──────────┬───────────┘
                               │ vpc_id
                 ┌─────────────┴──────────────┐
                 ▼                            ▼
      ┌────────────────────┐      ┌────────────────────┐
      │  SG Module (API)   │      │  SG Module (RDS)   │
      │  in: vpc_id, rules │      │  in: vpc_id, rules │
      │  out: sg_id        │      │  out: sg_id        │
      └─────────┬──────────┘      └──────────┬─────────┘
                │ sg_id                       │ sg_id
    subnet_id   │                subnet_ids   │
   (da VPC)  ┌──┘               (da VPC)   ┌──┘
             ▼                             ▼
     ┌──────────────┐             ┌──────────────┐
     │  EC2 Module  │             │  RDS Module  │
     │ in: subnet,  │             │ in: subnets, │
     │     sg_id    │             │     sg_id    │
     └──────────────┘             └──────────────┘

Ordem de criação:  VPC → Security Groups → EC2 / RDS
```

**Módulo criado primeiro e por quê:**  
O **módulo VPC** é criado primeiro. Ele é a fundação da rede — produz `vpc_id` e os `subnet_ids` dos quais todos os outros dependem. Sem a VPC existir, não há onde colocar Security Groups, EC2 ou RDS. O Terraform infere essa ordem automaticamente pelo grafo de dependências (os outros módulos referenciam os outputs da VPC).

**Output da VPC que os Security Groups consomem:**  
Os Security Groups consomem o output **`vpc_id`** — todo SG precisa ser associado a uma VPC. O RDS SG também usa o `sg_id` do API SG como origem permitida na porta 5432.

**Quantos módulos o EC2 depende:**  
Depende de **2 módulos**: o **VPC** (fornece o `subnet_id` público) e o **Security Group da API** (fornece o `sg_id`).

**O que acontece com os outros módulos ao destruir a VPC:**  
Não é possível destruir a VPC isoladamente enquanto houver recursos dentro dela. Pelo grafo de dependências, o Terraform destrói na **ordem inversa da criação**: primeiro EC2 e RDS, depois os Security Groups, e só então a VPC. Se forçado, a AWS bloquearia a operação por dependência (a VPC ainda contém subnets, SGs e instâncias). Ou seja, destruir a VPC implica destruir toda a stack que vive dentro dela.

**Vantagem de um módulo genérico de Security Group:**  
Um único módulo `security-group` parametrizado por regras (`ingress_rules`) elimina a necessidade de escrever um módulo específico para API e outro para RDS. Vantagens:
- **Menos código e menos duplicação** — a mesma lógica serve para qualquer SG.
- **Consistência** — todos os SGs seguem o mesmo padrão de tags, naming e estrutura.
- **Flexibilidade** — criar um SG novo (ex: para um cache Redis na porta 6379) é só mais uma chamada do módulo com regras diferentes, sem escrever recurso novo.
- **Manutenção centralizada** — uma correção no módulo (ex: adicionar suporte a IPv6) beneficia todos os SGs de uma vez.
