# Trabalho em Aula — Aula 06: Módulos Terraform

**Aluno:** Matheus Mantovani  
**RA:** 20262  
**Data:** 18/09/2026

---

## Questões do TA — Gabarito

| Questão | Resposta | Justificativa |
|---------|----------|---------------|
| Q1 — Principal benefício de módulos | **b** | Módulos permitem reutilizar código e eliminar duplicação (DRY) |
| Q2 — Diferença count vs for_each | **c** | `count` indexa por número (0,1,2); `for_each` indexa por chave nomeada |
| Q3 — Quando usar módulo do Registry | **b** | Para infraestrutura padrão (VPC, RDS) com muitas opções e em produção |
| Q4 — Composição de módulos | **c** | O output de um módulo é passado como input (variável) para outro módulo |

---

## Parte 1 — Identificação de Duplicação (Code Review)

### 1. Blocos de recursos duplicados entre dev e staging

Todos os 7 tipos de recursos são duplicados:

| Recurso dev | Recurso staging | O que muda |
|-------------|-----------------|------------|
| `aws_vpc.dev` | `aws_vpc.staging` | `cidr_block`, tags `Name`/`Environment` |
| `aws_subnet.dev_public_1` | `aws_subnet.staging_public_1` | `cidr_block`, tag `Name` |
| `aws_subnet.dev_public_2` | `aws_subnet.staging_public_2` | `cidr_block`, tag `Name` |
| `aws_internet_gateway.dev` | `aws_internet_gateway.staging` | tag `Name` |
| `aws_security_group.dev_api` | `aws_security_group.staging_api` | `name`, `vpc_id`, tag `Name` |
| `aws_security_group.dev_rds` | `aws_security_group.staging_rds` | `name`, `vpc_id`, tag `Name` |
| `aws_instance.dev_api` | `aws_instance.staging_api` | `subnet_id`, `vpc_security_group_ids`, tag `Name` |

**Total: 7 tipos × 2 ambientes = 14 blocos, sendo ~90% código idêntico.**

### 2. O que muda entre dev e staging

Apenas 4 valores diferem em todo o código:
1. **VPC CIDR:** `10.0.0.0/16` (dev) vs `10.1.0.0/16` (staging)
2. **Subnet CIDRs:** `10.0.x.0/24` vs `10.1.x.0/24`
3. **Prefixo de nomes/tags:** `technova-dev-*` vs `technova-staging-*`
4. **`environment` nas tags:** `"dev"` vs `"staging"`

Ou seja, ~180 linhas de código onde apenas ~8 valores são diferentes entre os dois ambientes. Isso é exatamente o problema DRY.

### 3. Módulos que eu criaria (mínimo 3)

1. **`modules/vpc`** — encapsula VPC + subnets (públicas e privadas) + IGW + Route Tables
2. **`modules/security-group`** — módulo genérico que aceita regras de ingress como lista de objetos
3. **`modules/ec2`** — instância EC2 com AMI, tipo, subnet, SGs e user_data configuráveis
4. **`modules/rds`** — DB Subnet Group + instância RDS PostgreSQL

### 4. Variáveis (inputs) de cada módulo

**`modules/vpc`:**
- `vpc_cidr` (string) — CIDR da VPC
- `project_name` (string) — prefixo dos nomes
- `environment` (string) — dev/staging/prod
- `subnets` (map(object)) — mapa com cidr, az e type para cada subnet

**`modules/security-group`:**
- `name` (string) — nome do SG
- `vpc_id` (string) — ID da VPC onde criar
- `ingress_rules` (list(object)) — regras de entrada
- `project_name` (string), `environment` (string)

**`modules/ec2`:**
- `instance_name` (string), `instance_type` (string, default t2.micro)
- `ami_id` (string), `subnet_id` (string)
- `security_group_ids` (list(string)), `key_name` (string)
- `user_data` (string, opcional)

**`modules/rds`:**
- `db_name` (string), `db_username` (string), `db_password` (string, sensitive)
- `subnet_ids` (list(string)), `security_group_ids` (list(string))
- `instance_class` (string, default db.t3.micro)
- `project_name` (string), `environment` (string)

### 5. Outputs de cada módulo

**`modules/vpc`:** `vpc_id`, `public_subnet_ids`, `private_subnet_ids`

**`modules/security-group`:** `sg_id`, `sg_name`

**`modules/ec2`:** `instance_id`, `public_ip`, `private_ip`

**`modules/rds`:** `db_endpoint`, `db_address`, `db_port`, `db_name`

### 6. Linhas para ambiente de produção: código atual vs com módulos

**Código atual (sem módulos):**  
Cada ambiente = ~90 linhas. Produção = mais ~90 linhas copiadas e coladas.  
3 ambientes = ~270 linhas, sendo ~250 linhas de repetição pura.

**Com módulos:**  
Os módulos são definidos uma vez (~120 linhas no total).  
Adicionar produção = ~20 linhas de chamadas `module {}` com variáveis diferentes.  
3 ambientes = ~120 linhas de módulos + ~60 linhas de chamadas = ~180 linhas totais.  
Redução: de 270 para 180 linhas, e qualquer mudança de regra é feita em 1 lugar.

---

## Parte 2 — Design de Módulos: Diagrama de Dependências

### Diagrama ASCII

```
                    ┌─────────────────────────────────────┐
                    │          modules/vpc                 │
                    │                                      │
                    │  vars: vpc_cidr, project, env,       │
                    │        subnets (map)                 │
                    │                                      │
                    │  outputs:                            │
                    │  - vpc_id ──────────────────────────►│──┐
                    │  - public_subnet_ids ───────────────►│  │
                    │  - private_subnet_ids ──────────────►│  │
                    └─────────────────────────────────────┘  │
                              │         │         │           │
                 ─────────────┘         │         └─────────  │
                 │  vpc_id              │  vpc_id         │    │
                 ▼                      ▼                 │    │
    ┌────────────────────┐  ┌────────────────────┐       │    │
    │  modules/security- │  │  modules/security- │       │    │
    │  group (API SG)    │  │  group (RDS SG)    │       │    │
    │                    │  │                    │       │    │
    │  outputs:          │  │  outputs:          │       │    │
    │  - sg_id ──────┐   │  │  - sg_id ──────┐  │       │    │
    └────────────────┼───┘  └────────────────┼──┘       │    │
                     │                       │           │    │
         sg_id       │       subnet_id       │  sg_id    │ subnet_ids
         ────────────┘  ─────────────────────┘  ─────────┘────────┘
              │                   │                  │         │
              ▼                   ▼                  ▼         ▼
    ┌─────────────────┐         ┌──────────────────────────────────┐
    │  modules/ec2    │         │          modules/rds             │
    │                 │         │                                  │
    │  vars:          │         │  vars: subnet_ids (privadas)     │
    │  - subnet_id    │         │        security_group_ids        │
    │  - sg_ids       │         │        db_name, username, passwd │
    │                 │         │                                  │
    │  outputs:       │         │  outputs:                        │
    │  - public_ip    │         │  - db_endpoint, db_port          │
    └─────────────────┘         └──────────────────────────────────┘
```

### Respostas às perguntas do diagrama

**1. Módulo criado primeiro e por quê:**  
`modules/vpc` deve ser criado primeiro. Ele produz `vpc_id`, `public_subnet_ids` e `private_subnet_ids` — todos os outros módulos dependem desses valores. O Terraform resolve isso automaticamente via grafo de dependências, mas conceitualmente a VPC é a fundação de toda a rede.

**2. Output da VPC que os Security Groups consomem:**  
`vpc_id` — necessário para associar o Security Group à VPC correta.

**3. Quantos módulos o EC2 depende:**  
2 módulos: `modules/vpc` (para o `subnet_id`) e `modules/security-group` (para os `security_group_ids`).

**4. O que acontece ao destruir a VPC:**  
Todos os recursos dependentes são destruídos em cascata: subnets, IGW, Route Tables, Security Groups, EC2 e RDS. O Terraform calcula o grafo de dependências inversas e destrói na ordem correta (primeiro EC2 e RDS, depois SGs, depois subnets/IGW, por último a VPC).

**5. Vantagem de um módulo genérico de Security Group:**  
Um módulo genérico que aceita `ingress_rules` como lista de objetos serve para qualquer SG (API, RDS, bastion, ALB) sem duplicar código. Em vez de ter um módulo `modules/api-sg` e outro `modules/rds-sg` com estrutura idêntica, um único `modules/security-group` é chamado com parâmetros diferentes. Mudança na estrutura do SG (ex: adicionar tag nova) precisa ser feita em um único lugar.
