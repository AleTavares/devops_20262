# Trabalho em Aula - Aula 06: Modulos Terraform

**Aluno:** Carina Goncalves dos Santos Dalpino
**RA:** 6325109
**Data:** 19/09/2026

## Parte 1 - Identificacao de Duplicacao

### 1. Blocos de recursos duplicados entre dev e staging

Todos os blocos se repetem entre os dois ambientes, mudando apenas os valores:
- `aws_vpc` (dev e staging)
- `aws_subnet` publicas (2 por ambiente = 4 no total)
- `aws_internet_gateway` (dev e staging)
- `aws_security_group` da API (dev e staging)
- `aws_security_group` do RDS (dev e staging)
- `aws_instance` da API (dev e staging)

Ou seja, praticamente 100% da estrutura e duplicada - a mesma arquitetura escrita duas vezes.

### 2. O que muda entre dev e staging

Poucos valores mudam:
- CIDR da VPC: dev = 10.0.0.0/16, staging = 10.1.0.0/16
- CIDRs das subnets: dev = 10.0.x, staging = 10.1.x
- Prefixo dos nomes/tags: technova-dev-* vs technova-staging-*
- Valor da tag Environment: "dev" vs "staging"

A estrutura (tipos de recurso, portas, protocolos, relacionamentos) e identica.

### 3. Modulos que eu criaria (minimo 3)

1. **modules/vpc** - VPC, subnets (com for_each), Internet Gateway e Route Table
2. **modules/security-group** - Security Group generico com regras configuraveis
3. **modules/ec2** - Instancia EC2 reutilizavel
4. **modules/rds** - RDS PostgreSQL com DB Subnet Group

### 4. Variaveis (inputs) de cada modulo

- **vpc:** vpc_cidr, project_name, environment, subnets (map de objetos com cidr/az/type)
- **security-group:** name, vpc_id, ingress_rules (lista de objetos), environment, project_name
- **ec2:** instance_name, instance_type, ami_id, subnet_id, security_group_ids, key_name
- **rds:** db_name, db_username, db_password, subnet_ids, security_group_ids, instance_class, environment, project_name

### 5. Outputs de cada modulo

- **vpc:** vpc_id, public_subnet_ids, private_subnet_ids
- **security-group:** sg_id, sg_name
- **ec2:** instance_id, public_ip, private_ip
- **rds:** db_endpoint, db_name, db_port

### 6. Linhas para ambiente de producao (codigo atual vs com modulos)

- **Codigo atual (sem modulos):** seria necessario copiar todo o bloco de novo - cerca de 90 linhas adicionais para producao, com alto risco de inconsistencia.
- **Com modulos:** basta um novo arquivo terraform.tfvars (cerca de 10 linhas) apontando os mesmos modulos com CIDR 10.2.0.0/16. A logica nao se repete.

## Parte 2 - Design de Modulos (Diagrama de Dependencias)

```
                    +-------------------+
                    |    Modulo VPC     |
                    |                   |
                    | Outputs:          |
                    | - vpc_id          |
                    | - public_subnet_ids
                    | - private_subnet_ids
                    +---------+---------+
                              |
        +---------------------+---------------------+
        | vpc_id              | public_subnet_ids   | private_subnet_ids
        v                     v                     v
+----------------+   +-----------------+   +------------------+
| Security Group |   |   Modulo EC2    |   |   Modulo RDS     |
| (API + RDS)    |   |                 |   |                  |
| Output: sg_id  |   | usa subnet + sg |   | usa subnets + sg |
+-------+--------+   +--------+--------+   +--------+---------+
        |                     ^                     ^
        |  sg_id (API)        |                     |
        +---------------------+                     |
        |  sg_id (RDS)                              |
        +-------------------------------------------+
```

- **Modulo criado primeiro e por que:** o modulo VPC, porque e a base de tudo. Os Security Groups precisam do vpc_id, e EC2/RDS precisam das subnets. Sem a VPC nada mais pode ser criado.

- **Output da VPC que os Security Groups consomem:** o `vpc_id`.

- **Quantos modulos o EC2 depende:** 2 modulos - o VPC (para o subnet_id publico) e o Security Group (para o sg_id da API).

- **O que acontece com os outros modulos ao destruir a VPC:** o Terraform impede ou destroi em cascata. Como Security Groups, EC2 e RDS dependem de recursos da VPC (vpc_id, subnets), todos precisam ser destruidos antes ou junto com a VPC. O grafo de dependencias garante a ordem correta (destroi EC2/RDS/SG primeiro, VPC por ultimo).

- **Vantagem de um modulo generico de Security Group:** com um unico modulo parametrizavel evitamos escrever dois modulos quase iguais (api-sg e rds-sg). As regras entram como lista de objetos (ingress_rules), entao o mesmo codigo serve para API (portas 80/22), RDS (porta 5432), bastion, etc. Menos duplicacao, manutencao em um lugar so, e consistencia garantida.

## Discussao em Grupo - Reflexoes

- **Linhas com modulos vs sem, para 3 ambientes:** sem modulos seria cerca de 270 linhas (90 x 3, tudo copiado); com modulos ~60 linhas (modulos + 3 arquivos tfvars pequenos).
- **Maior dificuldade ao refatorar:** identificar corretamente os limites de cada modulo (o que e generico vs especifico) e mapear os inputs/outputs sem quebrar as dependencias existentes.
- **for_each para os dois ambientes:** e possivel usar for_each num unico bloco de modulo iterando sobre um mapa de ambientes, mas separar em environments/dev e environments/staging com tfvars distintos deixa o state isolado por ambiente, o que e mais seguro.