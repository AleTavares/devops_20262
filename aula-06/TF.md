# Trabalho de Fixação (TF) — Aula 06: Terraform Modules

## Desafio

Consolidar todos os conceitos de **Terraform Modules** — desde a criação de módulos locais até padrões avançados — construindo uma **biblioteca de módulos reutilizáveis** para a TechNova. A biblioteca deve ser capaz de provisionar ambientes completos (dev + staging) com uma única chamada de módulos. Publique via Pull Request no repositório da disciplina.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | 1 semana a partir da data da aula |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork** | `entregas/aula-06/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com link do repositório + evidências |
| **Arquivos do projeto** | No repositório `unifaat-devops-portfolio`, pasta `aula-06/` |
| **Execução do Lab** | Realizada no **AWS Academy Learner Lab** — o professor confere a nota e o percentual de execução |

> **Avaliação no AWS Academy:** Além do código entregue via PR, o professor verifica no **AWS Academy** a **nota** e o **percentual de execução** do seu laboratório. Execute o Lab completo no ambiente do Academy — a atividade prática no Learner Lab faz parte da avaliação do TF.

### Como Entregar via Pull Request

1. Faça um **fork** do repositório da disciplina (se ainda não fez)
2. Clone o seu fork localmente
3. Crie a pasta `entregas/aula-06/SEU-RA/`
4. Adicione **apenas** o arquivo `entrega.md` (modelo abaixo) — os arquivos do projeto ficam no `unifaat-devops-portfolio`
5. Faça commit e push para o seu fork
6. Abra um **Pull Request** para o repositório original

**Modelo do arquivo `entrega.md`:**

```markdown
# Entrega — Aula 06: Terraform Modules

**Aluno:** [Seu nome completo]  
**RA:** [Seu RA]  
**Data:** [Data da entrega]

## Repositório

- URL: https://github.com/SEU-USUARIO/unifaat-devops-portfolio

## Evidências

- [ ] Módulo VPC com for_each para subnets dinâmicas
- [ ] Módulo Security Group genérico (regras como lista de objetos)
- [ ] Módulo EC2 reutilizável
- [ ] Módulo RDS reutilizável
- [ ] Composição entre módulos (output de um alimenta input de outro)
- [ ] Dois ambientes (dev + staging) usando os mesmos módulos
- [ ] `terraform validate` e `terraform plan` sem erros nos dois ambientes
- [ ] README documentando cada módulo (inputs, outputs, exemplo)

## Evidência do terraform plan

[Cole aqui o output resumido do terraform plan de um dos ambientes ou screenshot]
```

---

## Contexto Narrativo

O CTO Carlos Mendes está impressionado com o progresso da equipe. Após a refatoração em módulos, ele pede o próximo passo:

> "Quero que vocês criem uma **biblioteca de infraestrutura**. Módulos padronizados que qualquer membro da equipe possa usar para criar ambientes completos — VPC, EC2, RDS, Security Groups — tudo modular, documentado e reutilizável. E quero ver dois ambientes funcionando: dev e staging, criados a partir dos mesmos módulos com variáveis diferentes."

---

## Requisitos do Trabalho

### Estrutura do Projeto

> Os arquivos do projeto ficam no seu repositório `unifaat-devops-portfolio`, na pasta `aula-06/`.

```
aula-06/
├── README.md                    # Documentação da biblioteca de módulos
├── environments/
│   ├── dev/
│   │   ├── main.tf             # Chama os módulos para ambiente dev
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   └── terraform.tfvars
│   └── staging/
│       ├── main.tf             # Chama os módulos para ambiente staging
│       ├── variables.tf
│       ├── outputs.tf
│       ├── providers.tf
│       └── terraform.tfvars
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security-group/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── rds/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

### Requisito 1: Módulo VPC (`modules/vpc/`)

O módulo VPC deve:

- Criar uma VPC com CIDR configurável
- Usar `for_each` para criar subnets dinamicamente a partir de um mapa
- Suportar subnets públicas e privadas
- Criar Internet Gateway e Route Table para subnets públicas
- Expor outputs: `vpc_id`, `public_subnet_ids`, `private_subnet_ids`

**Variáveis mínimas:**
| Variável | Tipo | Descrição |
|----------|------|-----------|
| `vpc_cidr` | string | CIDR da VPC |
| `project_name` | string | Nome do projeto |
| `environment` | string | Ambiente |
| `subnets` | map(object) | Mapa de subnets com cidr, az e type |

---

### Requisito 2: Módulo Security Group (`modules/security-group/`)

O módulo Security Group deve:

- Ser **genérico** — funcionar para qualquer tipo de SG (API, RDS, bastion)
- Aceitar regras de ingress como lista de objetos
- Ter regra de egress padrão (all traffic outbound)
- Expor output: `sg_id`

**Variáveis mínimas:**
| Variável | Tipo | Descrição |
|----------|------|-----------|
| `name` | string | Nome do Security Group |
| `vpc_id` | string | ID da VPC |
| `ingress_rules` | list(object) | Regras de entrada |
| `environment` | string | Ambiente |
| `project_name` | string | Nome do projeto |

---

### Requisito 3: Módulo EC2 (`modules/ec2/`)

O módulo EC2 deve:

- Criar uma instância EC2 com AMI, tipo, subnet e SG configuráveis
- Aceitar user_data opcional
- Usar instância t2.micro
- Expor outputs: `instance_id`, `public_ip`, `private_ip`

**Variáveis mínimas:**
| Variável | Tipo | Descrição |
|----------|------|-----------|
| `instance_name` | string | Nome da instância |
| `instance_type` | string | Tipo (default: t2.micro) |
| `ami_id` | string | AMI ID |
| `subnet_id` | string | Subnet ID |
| `security_group_ids` | list(string) | Lista de SG IDs |
| `key_name` | string | Key pair name |

---

### Requisito 4: Módulo RDS (`modules/rds/`)

O módulo RDS deve:

- Criar um DB Subnet Group com subnets privadas
- Criar uma instância RDS PostgreSQL (db.t3.micro)
- Configurações sensatas para desenvolvimento (skip_final_snapshot, etc.)
- Expor outputs: `db_endpoint`, `db_name`, `db_port`

**Variáveis mínimas:**
| Variável | Tipo | Descrição |
|----------|------|-----------|
| `db_name` | string | Nome do database |
| `db_username` | string | Usuário master |
| `db_password` | string (sensitive) | Senha master |
| `subnet_ids` | list(string) | Subnet IDs para DB Subnet Group |
| `security_group_ids` | list(string) | SG IDs para o RDS |
| `instance_class` | string | Classe da instância (default: db.t3.micro) |
| `environment` | string | Ambiente |
| `project_name` | string | Nome do projeto |

---

### Requisito 5: Composição de Módulos

O root module de cada ambiente (`environments/dev/main.tf` e `environments/staging/main.tf`) deve:

- Chamar os 4 módulos (VPC, SG, EC2, RDS)
- Demonstrar composição: output do VPC → input do SG e EC2/RDS
- Output do SG → input do EC2 e RDS
- Cada ambiente com variáveis diferentes (CIDRs, nomes)

**Exemplo de composição esperada:**

```hcl
module "vpc" {
  source = "../../modules/vpc"
  # ...
}

module "api_sg" {
  source = "../../modules/security-group"
  vpc_id = module.vpc.vpc_id  # ← Composição!
  # ...
}

module "api_server" {
  source             = "../../modules/ec2"
  subnet_id          = module.vpc.public_subnet_ids[0]  # ← Composição!
  security_group_ids = [module.api_sg.sg_id]            # ← Composição!
  # ...
}

module "database" {
  source             = "../../modules/rds"
  subnet_ids         = module.vpc.private_subnet_ids   # ← Composição!
  security_group_ids = [module.rds_sg.sg_id]           # ← Composição!
  # ...
}
```

---

### Requisito 6: Dois Ambientes (Dev + Staging)

| Aspecto | Dev | Staging |
|---------|-----|---------|
| VPC CIDR | 10.0.0.0/16 | 10.1.0.0/16 |
| Subnets Públicas | 10.0.1.0/24, 10.0.2.0/24 | 10.1.1.0/24, 10.1.2.0/24 |
| Subnets Privadas | 10.0.3.0/24, 10.0.4.0/24 | 10.1.3.0/24, 10.1.4.0/24 |
| EC2 | t2.micro | t2.micro |
| RDS | db.t3.micro | db.t3.micro |
| DB Name | technova_dev | technova_staging |
| Naming Pattern | technova-dev-* | technova-staging-* |

---

### Requisito 7: Documentação (README.md)

O `README.md` na raiz da entrega deve conter:

1. **Visão geral** — O que a biblioteca de módulos faz
2. **Arquitetura** — Diagrama de dependências entre módulos
3. **Módulos disponíveis** — Tabela com nome, descrição, inputs e outputs de cada módulo
4. **Como usar** — Exemplo de uso para criar um novo ambiente
5. **Pré-requisitos** — O que é necessário para rodar (AWS CLI, Terraform, Key Pair)

**Exemplo de documentação de módulo:**

```markdown
### Módulo VPC

**Descrição:** Cria VPC completa com subnets dinâmicas (for_each), IGW e route tables.

**Inputs:**
| Nome | Tipo | Obrigatório | Descrição |
|------|------|-------------|-----------|
| vpc_cidr | string | Sim | CIDR block da VPC |
| subnets | map(object) | Sim | Mapa de subnets |
| project_name | string | Sim | Nome do projeto |
| environment | string | Sim | Ambiente |

**Outputs:**
| Nome | Descrição |
|------|-----------|
| vpc_id | ID da VPC criada |
| public_subnet_ids | Lista de IDs das subnets públicas |
| private_subnet_ids | Lista de IDs das subnets privadas |

**Exemplo de uso:**
\```hcl
module "vpc" {
  source       = "../../modules/vpc"
  vpc_cidr     = "10.0.0.0/16"
  project_name = "technova"
  environment  = "dev"
  subnets = {
    "public-1" = { cidr = "10.0.1.0/24", az = "us-east-1a", type = "public" }
  }
}
\```
```

---

## Critérios de Avaliação

| Critério | Peso | Descrição |
|----------|------|-----------|
| Módulo VPC funcional com for_each | 15% | VPC, subnets dinâmicas, IGW, route tables |
| Módulo Security Group genérico | 10% | Aceita regras como lista de objetos |
| Módulo EC2 funcional | 10% | Instância com AMI, SG, subnet configuráveis |
| Módulo RDS funcional | 15% | DB Subnet Group + instância PostgreSQL |
| Composição entre módulos | 15% | Outputs de um módulo alimentam inputs de outro |
| Dois ambientes (dev + staging) | 15% | Mesmos módulos, variáveis diferentes |
| README com documentação | 10% | Inputs, outputs e exemplo de uso para cada módulo |
| Organização e boas práticas | 10% | Estrutura de diretórios, naming, tags, .gitignore |

**Total:** 100%

---

## Validação Local

> **⚠️ Não é obrigatório executar `terraform apply`** — o importante é que `terraform validate` e `terraform plan` passem sem erros nos dois ambientes. Se quiser testar o apply, lembre-se de destruir TUDO depois para não consumir recursos do Learner Lab.

```bash
# Validar ambiente dev
cd aula-06/environments/dev
terraform init
terraform validate
terraform plan

# Validar ambiente staging
cd ../staging
terraform init
terraform validate
terraform plan
```

---

## Entrega

### 1 — Publicar no portfólio

```bash
cd unifaat-devops-portfolio
git checkout -b feature/aula-06-modules
mkdir -p aula-06/modules/{vpc,security-group,ec2,rds}
mkdir -p aula-06/environments/{dev,staging}
# ... desenvolva os módulos e ambientes em aula-06/ ...
git add aula-06/
git commit -m "feat(aula-06): biblioteca de módulos Terraform - VPC, SG, EC2, RDS"
git checkout main
git merge feature/aula-06-modules
git push origin main
git push origin feature/aula-06-modules
```

### 2 — Registrar entrega no fork da disciplina

```bash
cd /caminho/para/seu-fork-da-disciplina
git checkout -b entregas/aula-06/SEU-RA
mkdir -p entregas/aula-06/SEU-RA
# Crie o arquivo entrega.md (modelo na seção Informações de Entrega)
git add entregas/aula-06/SEU-RA/entrega.md
git commit -m "feat(aula-06): entrega TF - SEU NOME (RA: SEU-RA)"
git push -u origin entregas/aula-06/SEU-RA
```

Abra o Pull Request no GitHub com:
- **Título:** `[Aula 06] RA: SEU-RA - SEU NOME`
- **Base:** `main`
- **Compare:** `entregas/aula-06/SEU-RA`

---

## Checklist de Entrega (use no PR)

```markdown
## Checklist

### Módulos
- [ ] modules/vpc/ — VPC com for_each, IGW, route tables
- [ ] modules/security-group/ — SG genérico com regras dinâmicas
- [ ] modules/ec2/ — EC2 com AMI, subnet, SG configuráveis
- [ ] modules/rds/ — RDS PostgreSQL com DB Subnet Group

### Ambientes
- [ ] environments/dev/ — terraform validate ✅, terraform plan ✅
- [ ] environments/staging/ — terraform validate ✅, terraform plan ✅

### Composição
- [ ] VPC output → SG input (vpc_id)
- [ ] VPC output → EC2 input (subnet_id)
- [ ] VPC output → RDS input (subnet_ids)
- [ ] SG output → EC2 input (security_group_ids)
- [ ] SG output → RDS input (security_group_ids)

### Documentação
- [ ] README.md com visão geral e diagrama
- [ ] Cada módulo documentado (inputs, outputs, exemplo)

### Boas Práticas
- [ ] .gitignore configurado
- [ ] Nenhum .tfstate ou .terraform/ no repositório
- [ ] Tags em todos os recursos (Name, Environment, Project, ManagedBy)
- [ ] Variáveis com description e type definidos
- [ ] Outputs com description definido
- [ ] db_password marcada como sensitive
```

---

## Dicas

1. **Comece pelo módulo VPC** — é a base de tudo. Depois SG, depois EC2, por último RDS.
2. **Teste incrementalmente** — terraform validate após cada módulo, não espere criar tudo para testar.
3. **Use o Lab como referência** — o código do Laboratório Parte 1 e 2 é sua base.
4. **Copie a estrutura** — não precisa reinventar. Adapte o código dos labs para os requisitos do TF.
5. **Cuidado com o RDS** — db_password não deve ter caracteres especiais problemáticos (`@`, `/`, `"`). Use alfanuméricos.
6. **Destroy!** — Se fizer apply para testar, **sempre** destrua no final para não consumir recursos do Learner Lab.

---

## Lembrete — Recursos no AWS Academy Learner Lab

| Recurso | Nota |
|---------|------|
| EC2 t2.micro | Instância mínima — evite rodar várias ao mesmo tempo |
| RDS db.t3.micro | Instância mínima — leva 5-10 min para provisionar |
| VPC/Subnets/SG | Recursos de rede leves |
| S3 | Para o state file |

> **⚠️ Dois ambientes (dev + staging) ao mesmo tempo** consomem o dobro de recursos do Learner Lab.
>
> **Solução:** Teste um ambiente por vez, ou valide apenas com `terraform plan` (sem apply).
> **Sempre execute `terraform destroy` após os testes e encerre a sessão do Learner Lab!**
