# Aula 06 — Trabalho em Aula

**Aluno:** Yuri Batista Sanches
**RA:** 6325238
**Data:** 24/09/2026

## Parte 1 — Code Review: Identificação de Duplicação

### 1. Quantos blocos de recursos são duplicados entre dev e staging?

Foram identificados **6 tipos de recursos duplicados** entre os ambientes:

* VPC
* Subnets públicas
* Internet Gateway
* Security Group da API
* Security Group do RDS
* Instância EC2

A estrutura dos recursos é praticamente a mesma, mudando principalmente os valores específicos de cada ambiente.

### 2. O que muda entre os blocos dev e staging?

As principais diferenças são:

* Nome do ambiente: `dev` ou `staging`
* CIDR da VPC:

  * Dev: `10.0.0.0/16`
  * Staging: `10.1.0.0/16`
* CIDRs das subnets
* Nomes e tags dos recursos
* Referências para a VPC e Security Groups correspondentes

Grande parte da configuração permanece igual, como as portas, tipo da instância, AMI e disponibilidade nas mesmas Availability Zones.

### 3. Quais módulos eu criaria?

Eu criaria pelo menos os seguintes módulos:

1. `modules/vpc`

   * VPC
   * Subnets
   * Internet Gateway
   * Route Tables

2. `modules/security-group`

   * Security Groups
   * Regras de entrada e saída configuráveis

3. `modules/ec2`

   * Instância EC2
   * Configurações de rede e Security Group

4. `modules/rds`

   * Banco RDS
   * DB Subnet Group
   * Configurações do banco

Dessa forma, os mesmos módulos poderiam ser utilizados em dev, staging e produção, alterando apenas as variáveis.

### 4. Quais variáveis cada módulo receberia?

**VPC:**

* `vpc_cidr`
* `environment`
* `project_name`
* `availability_zones`
* `public_subnets`
* `private_subnets`

**Security Group:**

* `name`
* `vpc_id`
* `ingress_rules`
* `egress_rules`
* `environment`

**EC2:**

* `ami_id`
* `instance_type`
* `subnet_id`
* `security_group_ids`
* `key_name`
* `environment`

**RDS:**

* `db_name`
* `engine`
* `engine_version`
* `instance_class`
* `subnet_ids`
* `security_group_ids`
* `username`
* `password`
* `environment`

### 5. Quais outputs cada módulo exporia?

**VPC:**

* `vpc_id`
* `public_subnet_ids`
* `private_subnet_ids`
* `internet_gateway_id`

**Security Group:**

* `sg_id`

**EC2:**

* `instance_id`
* `public_ip`
* `private_ip`

**RDS:**

* `db_instance_id`
* `db_endpoint`
* `db_port`

Esses outputs permitem que um módulo utilize os recursos criados por outro módulo.

### 6. Produção: código atual vs módulos

Com o código atual, seria necessário praticamente copiar novamente os blocos de recursos de dev ou staging e alterar os valores específicos de produção. Isso aumentaria bastante o tamanho do `main.tf` e a duplicação.

Com módulos, seria necessário apenas criar uma nova chamada para os mesmos módulos, passando as configurações de produção.

Por exemplo:

```hcl
module "production_vpc" {
  source   = "./modules/vpc"
  vpc_cidr = "10.2.0.0/16"
  environment = "production"
}
```

Assim, a quantidade de código adicional seria muito menor e mais fácil de manter.

---

# Parte 2 — Design de Módulos

## Diagrama de dependências

```text
                    ┌─────────────────┐
                    │   VPC Module    │
                    │                 │
                    │ Outputs:        │
                    │ - vpc_id        │
                    │ - public_subnets│
                    │ - private_subnets
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ▼                             ▼
     ┌─────────────────┐           ┌─────────────────┐
     │  SG API Module  │           │  SG RDS Module  │
     │                 │           │                 │
     │ Output: sg_id   │           │ Output: sg_id   │
     └────────┬────────┘           └────────┬────────┘
              │                             │
              │                             │
              ▼                             ▼
     ┌─────────────────┐           ┌─────────────────┐
     │   EC2 Module    │           │   RDS Module    │
     │                 │           │                 │
     │ subnet_id       │           │ private_subnets │
     │ sg_id            │           │ sg_id           │
     └─────────────────┘           └─────────────────┘
```

### 1. Qual módulo deve ser criado primeiro?

O módulo **VPC** deve ser criado primeiro porque os outros recursos precisam da rede para funcionar.

A VPC fornece o `vpc_id` e as subnets que serão utilizadas pelos Security Groups, EC2 e RDS.

### 2. Os módulos de Security Group dependem de qual output da VPC?

Eles dependem principalmente do:

```text
vpc_id
```

Esse ID informa em qual VPC o Security Group será criado.

### 3. O módulo EC2 depende de quantos outros módulos?

O EC2 depende diretamente de **dois módulos principais**:

* VPC, através do `subnet_id`
* Security Group, através do `sg_id`

Portanto, primeiro a rede e o Security Group precisam estar disponíveis.

### 4. Se destruir a VPC, o que acontece com os outros módulos?

Os recursos que dependem da VPC também precisam ser destruídos ou ficarão sem a infraestrutura de rede necessária.

Por exemplo, EC2, RDS, Security Groups e subnets estão associados à VPC. Por isso, o Terraform normalmente precisa remover esses recursos antes de conseguir destruir a VPC.

### 5. Qual a vantagem de ter um módulo genérico de Security Group?

Um módulo genérico evita duplicação de código.

Em vez de criar um módulo específico para API e outro para RDS com código praticamente igual, podemos utilizar o mesmo módulo e alterar as regras por meio de variáveis.

Isso facilita:

* Reutilização;
* Manutenção;
* Padronização;
* Criação de novos ambientes;
* Alteração das regras de segurança.

Assim, o mesmo módulo pode ser utilizado para `dev`, `staging` e `production`, apenas passando configurações diferentes.
