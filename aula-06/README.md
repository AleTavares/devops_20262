# Aula 06 — Terraform Modules: Do Básico ao Avançado

## Objetivos de Aprendizagem

Ao final desta aula, o aluno será capaz de:

1. Compreender o conceito de módulos e por que são essenciais para código reutilizável
2. Identificar padrões de duplicação e refatorar em módulos locais
3. Criar módulos com estrutura padrão (main.tf, variables.tf, outputs.tf)
4. Passar input variables e consumir outputs de módulos
5. Utilizar count e for_each para criar recursos dinamicamente
6. Navegar e consumir módulos do Terraform Registry
7. Compor módulos entre si (output de um alimenta input de outro)
8. Implementar versionamento de módulos e terraform_remote_state

---

## Contexto Narrativo

> **O Resgate da TechNova — Episódio 6: "Refatoração: De Código Repetido a Módulos Reutilizáveis"**

Após proteger o state no S3 e configurar o RDS na aula anterior, a equipe da TechNova respira aliviada. Mas na segunda-feira, o CTO Carlos Mendes convoca uma reunião de emergência:

> "Pessoal, recebi uma demanda dos investidores. Eles querem ver a aplicação rodando em três ambientes separados: desenvolvimento, staging e produção. E querem isso para ontem."

Rafael abre o repositório de Terraform e percebe o problema:

> "Para criar staging, eu teria que copiar 300 linhas de código e mudar meia dúzia de valores. E para produção, mais 300 linhas. Três ambientes = três cópias do mesmo código. Se precisar mudar uma regra de Security Group, tenho que alterar em três lugares. Isso não escala."

A consultora Marina sorri — esse é exatamente o problema que módulos Terraform resolvem:

> "Vocês estão violando o princípio DRY — Don't Repeat Yourself. Cada VPC, cada Security Group, cada EC2 que vocês definem é basicamente o mesmo código com valores diferentes. A solução é **modularizar**: extrair o código comum em módulos reutilizáveis e chamá-los com variáveis diferentes para cada ambiente. Um módulo de VPC, um de Security Group, um de EC2, um de RDS. Depois, para criar staging, basta chamar os mesmos módulos com parâmetros diferentes."

Carlos gosta da ideia:

> "Então ao invés de ter 900 linhas repetidas para três ambientes, teremos os módulos definidos uma vez e três chamadas com variáveis diferentes? Isso é elegante. E quando precisarmos do quarto ambiente para testes de carga?"

Marina completa:

> "Uma linha. Literalmente. Você copia o bloco module, muda os valores, e tem um ambiente novo idêntico em estrutura mas com configurações próprias. E quando vocês ficarem mais avançados, vamos usar **for_each** para criar múltiplos recursos dinamicamente, consumir módulos prontos do **Terraform Registry** com milhões de downloads, e até ler state de outros projetos com **terraform_remote_state**."

Esse é o desafio desta aula: transformar código repetido em uma **biblioteca de módulos reutilizáveis**, e depois aplicar padrões avançados para escalar a infraestrutura da TechNova.

---

## Cronograma da Aula

| Bloco | Atividade |
|:-----:|-----------|
| 1 | Revisão TA + Discussão em Grupo |
| 2 | Conteúdo Teórico — Modules Fundamentals |
| 3 | Laboratório Parte 1 — Criando Módulos Locais |
| 4 | Conteúdo Teórico — Patterns Avançados |
| 5 | Laboratório Parte 2 — for_each, Registry e Composição |
| 6 | Encerramento + Orientação TF |

---

## Pré-requisitos

- **AWS Academy Learner Lab** ativo — acesse via [AWS Academy](https://awsacademy.instructure.com/) com o convite do professor
- **Terraform** instalado (≥ 1.0) — [Download](https://developer.hashicorp.com/terraform/downloads)
- **AWS CLI** instalado — [Guia](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- **Conhecimentos das Aulas 01-05:** Git, Docker, Docker Compose, Kiro, Terraform (init/plan/apply/destroy, variables, outputs, state), IAM, VPC (subnets, IGW, Route Tables), EC2, RDS, Remote State (S3 + DynamoDB)
- Editor de texto (VS Code com extensão HashiCorp Terraform recomendada)

> **⚙️ AWS Academy Learner Lab:** Neste curso usamos o **AWS Academy Learner Lab**, não uma conta AWS pessoal. Pontos de atenção:
> - **Credenciais temporárias:** cada sessão gera novas credenciais (Access Key, Secret Key e **Session Token**). Carregue-as via variáveis de ambiente com um script `aws-creds.sh` (`source aws-creds.sh`) no início de cada sessão — mesmo procedimento das Aulas 04 e 05.
> - **Região fixa:** use sempre **us-east-1**.
> - **Sem criar IAM users/groups/roles:** o Learner Lab bloqueia essas operações. Para permissões de serviços (ex: EC2 acessar S3), use a role pré-existente **`LabRole`** e o instance profile **`LabInstanceProfile`**.
> - **Sessão expira:** o Lab expira (~4h). **Sempre execute `terraform destroy`** ao final.
>
> **Configurar credenciais a cada sessão** (detalhes no Lab Parte 1):
> ```bash
> # No Learner Lab: AWS Details → AWS CLI → Show → copie os valores para aws-creds.sh
> source aws-creds.sh
> aws sts get-caller-identity   # verifica o acesso (deve mostrar o role voclabs)
> ```

---

## Entrega do Trabalho em Aula

O trabalho em aula vale **1 ponto na nota final** do semestre (contabilizado apenas ao final, com todos os trabalhos entregues).

### Onde entregar

Na **mesma pasta** da entrega do TF, no fork da disciplina:

```
entregas/aula-06/SEU-RA/trabalho-em-aula.md
```

### O que entregar

Um arquivo `trabalho-em-aula.md` com as respostas das atividades realizadas em sala (discussões, diagramas, análises).

### Observações

- A entrega é **individual** — mesmo que a atividade tenha sido em grupo
- O arquivo pode ser adicionado no **mesmo PR** do TF ou em PR separado
- Entregas parciais (apenas algumas aulas) **não garantem o ponto**

---

## Entrega do Trabalho de Fixação (TF)

O TF desta aula deve ser desenvolvido no **seu repositório pessoal** (`unifaat-devops-portfolio`, pasta `aula-06/`). A entrega neste repositório da disciplina consiste em um **arquivo Markdown (`entrega.md`)** contendo o **link para o seu repositório** e as evidências solicitadas.

### Passo a Passo

1. **Desenvolva o TF** no seu repositório pessoal (`unifaat-devops-portfolio/aula-06/`)
2. Faça **fork** do repositório da disciplina (se ainda não fez)
3. Crie uma **branch**: `SEU-RA/tf-06`
4. Crie a pasta `entregas/aula-06/SEU-RA/`
5. Adicione o arquivo **`entrega.md`** com o link do seu repositório + evidências
6. Faça commits descritivos seguindo [Conventional Commits](https://www.conventionalcommits.org/pt-br/)
7. Abra um **Pull Request** para o repositório original com título: `[Aula 06] RA: XXXXX - Nome Completo`

> **Importante:** O repositório pessoal do aluno deve estar **público** para que o professor consiga avaliar. Além do código, o professor verifica no **AWS Academy** a nota e o percentual de execução do laboratório.

Para detalhes completos sobre os entregáveis e critérios de avaliação, consulte o arquivo [`TF.md`](TF.md).

---

## Conteúdo Teórico — Parte 1: Modules Fundamentals

### 1. O Problema: Código Duplicado

Vamos olhar o repositório da TechNova após 5 aulas. O arquivo `main.tf` está com mais de 200 linhas e contém:

```hcl
# VPC para o ambiente de desenvolvimento
resource "aws_vpc" "dev" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "technova-dev-vpc" }
}

resource "aws_subnet" "dev_public" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.0.1.0/24"
  # ... mais 10 linhas
}

resource "aws_security_group" "dev_api" {
  vpc_id = aws_vpc.dev.id
  # ... 20 linhas de regras
}

# Agora o CTO quer staging... copiamos tudo?
resource "aws_vpc" "staging" {
  cidr_block           = "10.1.0.0/16"  # Só muda o CIDR!
  enable_dns_hostnames = true
  tags = { Name = "technova-staging-vpc" }
}

resource "aws_subnet" "staging_public" {
  vpc_id     = aws_vpc.staging.id
  cidr_block = "10.1.1.0/24"  # Só muda o CIDR!
  # ... mesmas 10 linhas
}

resource "aws_security_group" "staging_api" {
  vpc_id = aws_vpc.staging.id
  # ... mesmas 20 linhas de regras
}
```

**O que há de errado?**
- 90% do código é idêntico entre dev e staging
- Para adicionar produção, mais uma cópia inteira
- Se precisar alterar uma regra de Security Group → alterar em todos os ambientes
- Risco de esquecer um ambiente e ter drift de configuração
- Arquivo `main.tf` com 600+ linhas → impossível de manter

![Problema do Código Duplicado](img/codigoDuplicado.png)

### 2. O Princípio DRY — Don't Repeat Yourself

O DRY é um dos princípios fundamentais de engenharia de software:

> "Cada peça de conhecimento deve ter uma representação única, inequívoca e autoritativa dentro de um sistema."

Aplicado a infraestrutura:

| Sem DRY (Código Duplicado) | Com DRY (Módulos) |
|---|---|
| VPC definida 3x para 3 ambientes | VPC definida 1x no módulo, chamada 3x |
| Mudança = alterar em 3 lugares | Mudança = alterar no módulo, reflete em todos |
| 600 linhas de código repetido | 100 linhas no módulo + 30 linhas de chamadas |
| Risco de drift entre ambientes | Garantia de consistência |

![Princípio DRY: Antes e Depois](img/principioDRY.png)

### 3. O que é um Módulo Terraform?

Um módulo Terraform é simplesmente um **diretório contendo arquivos `.tf`**. Sim, é só isso.

![Oque  é Modulo](img/oqueeModulo.png)

**Definição formal:**
- **Root Module:** O diretório onde você executa `terraform plan/apply`
- **Child Module:** Qualquer diretório referenciado por um bloco `module {}` no root

![Root Module e Child Modules](img/rootChildModule.png)

### 4. Estrutura Padrão de um Módulo

Todo módulo bem estruturado segue a convenção de 3 arquivos:

![Estrutura Módulo](img/rdEstruturaMoculo.png)

| Arquivo | Responsabilidade | Analogia |
|---------|-----------------|----------|
| `main.tf` | Define os recursos (lógica principal) | Corpo da função |
| `variables.tf` | Declara parâmetros de entrada | Parâmetros da função |
| `outputs.tf` | Declara valores de saída | Return da função |

**Analogia com programação:**

```python
# Isso é basicamente o que um módulo faz:
def criar_vpc(cidr, project_name, environment):   # variables.tf
    vpc = aws.create_vpc(cidr=cidr)                # main.tf
    subnet = aws.create_subnet(vpc_id=vpc.id)
    return {"vpc_id": vpc.id, "subnet_id": subnet.id}  # outputs.tf
```

![Módulo como Função](img/moduloComoFuncao.png)

### 5. Input Variables — Parametrizando o Módulo

O arquivo `variables.tf` dentro do módulo declara o que o módulo precisa receber:

```hcl
# modules/vpc/variables.tf

variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "Nome do projeto para tags"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Lista de CIDRs para subnets públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
```

### 6. Outputs — Expondo Dados do Módulo

O arquivo `outputs.tf` define o que o módulo retorna para quem o chamou:

```hcl
# modules/vpc/outputs.tf

output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = aws_subnet.private[*].id
}
```

### 7. Chamando um Módulo — O Bloco module {}

No root module (diretório raiz), você chama o child module assim:

```hcl
# root/main.tf

module "vpc_dev" {
  source = "./modules/vpc"  # Caminho relativo ao módulo

  # Passando variáveis (inputs)
  vpc_cidr            = "10.0.0.0/16"
  project_name        = "technova"
  environment         = "dev"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Consumindo outputs do módulo
resource "aws_instance" "api" {
  subnet_id = module.vpc_dev.public_subnet_ids[0]
  # ...
}
```

**Fluxo completo:**

![Roor Module](img/rootmodule.png)

### 8. Reutilização — O Poder dos Módulos

Com módulos, criar um novo ambiente é trivial:

```hcl
# Ambiente DEV
module "vpc_dev" {
  source       = "./modules/vpc"
  vpc_cidr     = "10.0.0.0/16"
  project_name = "technova"
  environment  = "dev"
}

# Ambiente STAGING — mesmo módulo, variáveis diferentes!
module "vpc_staging" {
  source       = "./modules/vpc"
  vpc_cidr     = "10.1.0.0/16"
  project_name = "technova"
  environment  = "staging"
}

# Ambiente PROD — mais uma chamada!
module "vpc_prod" {
  source       = "./modules/vpc"
  vpc_cidr     = "10.2.0.0/16"
  project_name = "technova"
  environment  = "prod"
}
```

**Resultado:** 3 VPCs completas (com subnets, IGW, routes) definidas em 18 linhas ao invés de 300+.

### 9. Exemplo Completo: Módulo VPC

```hcl
# modules/vpc/main.tf

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
```

---

## Conteúdo Teórico — Parte 2: Padrões Avançados

### 1. Meta-Arguments: count e for_each

Até agora usamos `count` para criar múltiplos recursos a partir de uma lista. Mas existe uma alternativa mais poderosa: `for_each`.

**count — Criação por índice numérico:**

```hcl
variable "subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

resource "aws_subnet" "public" {
  count      = length(var.subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidrs[count.index]

  tags = {
    Name = "subnet-${count.index + 1}"
  }
}

# Acesso: aws_subnet.public[0], aws_subnet.public[1], ...
```

**for_each — Criação por chave nomeada:**

```hcl
variable "subnets" {
  default = {
    "public-1" = { cidr = "10.0.1.0/24", az = "us-east-1a", type = "public" }
    "public-2" = { cidr = "10.0.2.0/24", az = "us-east-1b", type = "public" }
    "private-1" = { cidr = "10.0.3.0/24", az = "us-east-1a", type = "private" }
  }
}

resource "aws_subnet" "this" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.project_name}-${each.key}"
    Type = each.value.type
  }
}

# Acesso: aws_subnet.this["public-1"], aws_subnet.this["private-1"], ...
```

![Criação Dinâmica com for_each](img/forEachDinamico.png)

### 2. count vs for_each — Quando Usar Cada Um

| Aspecto | count | for_each |
|---------|-------|----------|
| Identificação | Por índice (0, 1, 2) | Por chave ("public-1") |
| Remoção de item | Remove item do meio → reindexação de TUDO | Remove item → só aquele recurso é destruído |
| Tipo de dado | list | map ou set |
| Legibilidade | `aws_subnet.public[0]` | `aws_subnet.this["public-1"]` |
| Recomendação | Recursos idênticos e descartáveis | Recursos nomeados e identificáveis |

**Problema do count com remoção:**

```
# Com count = ["a", "b", "c"] → subnets [0], [1], [2]
# Remove "b" → count = ["a", "c"]
# Terraform: destroy [1] e [2], recriar [1] com "c"
# RESULTADO: 2 recursos destruídos e recriados desnecessariamente!

# Com for_each = {"a": ..., "b": ..., "c": ...}
# Remove "b"
# Terraform: destroy apenas ["b"]
# RESULTADO: Apenas 1 recurso destruído ✅
```

> **Regra prática:** Use `for_each` na maioria dos casos. Use `count` apenas quando os recursos são verdadeiramente intercambiáveis (ex: N réplicas idênticas).

![count vs for_each na Remoção](img/countVsForeachRemocao.png)

### 3. Terraform Registry — Módulos da Comunidade

O [Terraform Registry](https://registry.terraform.io/) é o repositório oficial de módulos mantidos pela comunidade e pela HashiCorp:

![Terraform Registry](img/tfRegistry.png)

**Usando módulo do Registry:**

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "technova-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = false  # evita custo do NAT Gateway
  enable_dns_hostnames = true

  tags = {
    Environment = "dev"
    Project     = "technova"
  }
}
```

### 4. Decisão: Local vs Registry

| Critério | Módulo Local | Módulo Registry |
|----------|-------------|----------------|
| Controle total | ✅ Você controla tudo | ❌ Código de terceiros |
| Rapidez de implementação | ❌ Você escreve tudo | ✅ Pronto para usar |
| Funcionalidades | Apenas o que você cria | Centenas de opções |
| Manutenção | Sua responsabilidade | Comunidade mantém |
| Aprendizado | ✅ Excelente para aprender | ❌ Abstrai a complexidade |
| Produção | Para casos específicos | ✅ Recomendado para produção |

> **Para este curso:** Usamos módulos locais para **aprender** a estrutura e os conceitos. Em produção, é comum usar módulos do Registry como base e customizar com módulos locais para lógica específica.

![Módulo Local vs Terraform Registry](img/localVsRegistry.png)

### 5. Composição de Módulos

Módulos podem ser conectados entre si: o output de um alimenta o input de outro.

```hcl
# Módulo VPC → cria VPC e subnets
module "vpc" {
  source       = "./modules/vpc"
  vpc_cidr     = "10.0.0.0/16"
  project_name = "technova"
  environment  = "dev"
}

# Módulo Security Group → precisa do vpc_id (output do módulo VPC)
module "api_sg" {
  source   = "./modules/security-group"
  name     = "technova-api-sg"
  vpc_id   = module.vpc.vpc_id          # ← output do módulo VPC
  ingress_rules = [
    { port = 80, cidr = "0.0.0.0/0", description = "HTTP" },
    { port = 22, cidr = "0.0.0.0/0", description = "SSH" }
  ]
}

# Módulo EC2 → precisa de subnet_id e security_group_id
module "api_server" {
  source            = "./modules/ec2"
  instance_type     = "t2.micro"
  subnet_id         = module.vpc.public_subnet_ids[0]  # ← output VPC
  security_group_id = module.api_sg.sg_id              # ← output SG
  key_name          = "technova-key"
}
```

**Diagrama de dependências:**

![Composição de Módulos VPC → SG → EC2](img/composicaoModulos.png)

### 6. Versionamento de Módulos

Para módulos em repositórios Git, você pode referenciar versões específicas:

```hcl
# Módulo de Git com tag de versão
module "vpc" {
  source = "git::https://github.com/technova/terraform-modules.git//modules/vpc?ref=v1.2.0"
}

# Módulo do Registry com version constraint
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"   # Aceita 5.x.x mas não 6.0.0
}
```

**Constraints de versão:**

| Constraint | Significado |
|-----------|------------|
| `= 1.0.0` | Exatamente 1.0.0 |
| `>= 1.0.0` | 1.0.0 ou maior |
| `~> 1.0` | >= 1.0, < 2.0 (pessimistic) |
| `~> 1.0.0` | >= 1.0.0, < 1.1.0 |
| `>= 1.0, < 2.0` | Range explícito |

### 7. terraform_remote_state — Lendo State de Outro Projeto

Quando você tem projetos Terraform separados (ex: networking em um, aplicação em outro), pode ler outputs de um no outro:

```hcl
# Projeto B quer ler outputs do Projeto A (que criou a VPC)

data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "technova-terraform-state"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

# Usando o output do outro projeto
resource "aws_instance" "api" {
  subnet_id = data.terraform_remote_state.networking.outputs.public_subnet_ids[0]
  # ...
}
```

**Quando usar terraform_remote_state:**
- Equipes diferentes gerenciam partes diferentes da infraestrutura
- Projeto de networking separado do projeto de aplicação
- Ambientes que precisam referenciar recursos base (shared VPC, etc.)

![Network](img/network.png)

---

## Resumo dos Conceitos

| Conceito | Descrição |
|----------|-----------|
| Módulo | Diretório com arquivos .tf que encapsula recursos reutilizáveis |
| Root Module | Diretório onde você executa terraform plan/apply |
| Child Module | Módulo chamado por um bloco module {} |
| variables.tf | Inputs do módulo (parâmetros de entrada) |
| outputs.tf | Valores expostos pelo módulo para uso externo |
| DRY | Don't Repeat Yourself — eliminar duplicação de código |
| count | Meta-argument para criar N recursos por índice |
| for_each | Meta-argument para criar recursos por chave nomeada |
| Terraform Registry | Repositório oficial de módulos da comunidade |
| Composição | Conectar módulos via outputs→inputs |
| Versionamento | Referenciar versão específica de um módulo (tags, constraints) |
| terraform_remote_state | Data source para ler outputs de outro projeto Terraform |

---

## Recursos no AWS Academy Learner Lab

Todos os recursos desta aula são criados dentro do **AWS Academy Learner Lab**, sem custo para o aluno. Ainda assim, mantenha boas práticas de recursos:

| Componente | Observação |
|------------|-----------|
| VPC, Subnets, IGW, Route Tables | Recursos de rede — leves |
| Security Groups | Sem custo |
| EC2 t2.micro | Instância mínima |
| S3 (state file) | Consumo mínimo |
| NAT Gateway | ⚠️ **NÃO usar** |

> **⚠️ Sempre execute `terraform destroy` após cada laboratório e encerre a sessão do Learner Lab ao terminar.**

---

*Próximas etapas: Laboratório Parte 1 (Criando Módulos Locais) → Laboratório Parte 2 (for_each, Registry e Composição) → TF (Trabalho de Fixação)*
