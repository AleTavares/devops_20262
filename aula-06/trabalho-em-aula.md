# Aula 06 — Trabalho em Aula

## Atividade: Identificação de Duplicação e Design de Módulos

**Duração:** 30 minutos
**Formato:** Individual ou duplas
**Entrega:** Discussão em grupo ao final

---

## Contexto

Você foi contratado como consultor DevOps para avaliar o código Terraform da TechNova. Ao abrir o repositório, encontra o seguinte `main.tf` com **180 linhas** que provisiona infraestrutura para dois ambientes (dev e staging). Sua missão é identificar duplicações e propor uma arquitetura modular.

---

## Parte 1: Code Review — Identificação de Duplicação (15 min)

Analise o código abaixo e responda as questões:

```hcl
# ==========================================
# AMBIENTE DEV
# ==========================================

resource "aws_vpc" "dev" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "technova-dev-vpc"
    Environment = "dev"
    Project     = "technova"
  }
}

resource "aws_subnet" "dev_public_1" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "technova-dev-public-1" }
}

resource "aws_subnet" "dev_public_2" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "technova-dev-public-2" }
}

resource "aws_internet_gateway" "dev" {
  vpc_id = aws_vpc.dev.id
  tags   = { Name = "technova-dev-igw" }
}

resource "aws_security_group" "dev_api" {
  name   = "technova-dev-api-sg"
  vpc_id = aws_vpc.dev.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "technova-dev-api-sg" }
}

resource "aws_security_group" "dev_rds" {
  name   = "technova-dev-rds-sg"
  vpc_id = aws_vpc.dev.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.dev_api.id]
  }

  tags = { Name = "technova-dev-rds-sg" }
}

resource "aws_instance" "dev_api" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.dev_public_1.id
  vpc_security_group_ids = [aws_security_group.dev_api.id]
  key_name               = "technova-key"
  tags = { Name = "technova-dev-api" }
}

# ==========================================
# AMBIENTE STAGING (cópia quase idêntica!)
# ==========================================

resource "aws_vpc" "staging" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "technova-staging-vpc"
    Environment = "staging"
    Project     = "technova"
  }
}

resource "aws_subnet" "staging_public_1" {
  vpc_id                  = aws_vpc.staging.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "technova-staging-public-1" }
}

resource "aws_subnet" "staging_public_2" {
  vpc_id                  = aws_vpc.staging.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "technova-staging-public-2" }
}

resource "aws_internet_gateway" "staging" {
  vpc_id = aws_vpc.staging.id
  tags   = { Name = "technova-staging-igw" }
}

resource "aws_security_group" "staging_api" {
  name   = "technova-staging-api-sg"
  vpc_id = aws_vpc.staging.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "technova-staging-api-sg" }
}

resource "aws_security_group" "staging_rds" {
  name   = "technova-staging-rds-sg"
  vpc_id = aws_vpc.staging.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.staging_api.id]
  }

  tags = { Name = "technova-staging-rds-sg" }
}

resource "aws_instance" "staging_api" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.staging_public_1.id
  vpc_security_group_ids = [aws_security_group.staging_api.id]
  key_name               = "technova-key"
  tags = { Name = "technova-staging-api" }
}
```

### Questões para Responder:

1. **Quantos blocos de recursos são duplicados** entre dev e staging? Liste-os.

2. **O que muda** entre os blocos dev e staging? (Dica: são poucos valores)

3. **Quais módulos você criaria** para eliminar essa duplicação? Liste pelo menos 3.

4. **Quais variáveis** cada módulo receberia? (inputs)

5. **Quais outputs** cada módulo exporia?

6. **Se o CTO pedir um ambiente de produção**, quantas linhas você precisaria adicionar com o código atual vs com módulos?

---

## Parte 2: Design de Módulos — Diagrama de Dependências (15 min)

Agora que você identificou os módulos necessários, desenhe o **diagrama de dependências** para a infraestrutura da TechNova.

### Exercício:

Desenhe (no papel, quadro ou ferramenta de sua preferência) um diagrama mostrando:

1. **Quais módulos existem** (caixas)
2. **Quais outputs cada módulo produz** (setas saindo)
3. **Quais inputs cada módulo consome de outros** (setas entrando)
4. **A ordem de criação** (qual módulo precisa existir primeiro)

**Módulos a considerar:**
- `modules/vpc` — VPC, Subnets, Internet Gateway, Route Tables
- `modules/security-group` — Security Group genérico com regras configuráveis
- `modules/ec2` — Instância EC2 (precisa de subnet_id e sg_id)
- `modules/rds` — RDS (precisa de subnet_ids privadas e sg_id)

### Diagrama Esperado (referência):

```
┌──────────────┐
│  VPC Module  │
│              │
│  Outputs:    │
│  - vpc_id    │
│  - subnet_ids│
└──────┬───────┘
       │
       │ vpc_id
       ▼
┌──────────────────┐          ┌──────────────────┐
│  SG Module (API) │          │  SG Module (RDS) │
│                  │          │                  │
│  Outputs:        │          │  Outputs:        │
│  - sg_id         │──┐       │  - sg_id         │──┐
└──────────────────┘  │       └──────────────────┘  │
                      │                              │
       subnet_ids     │ sg_id         subnet_ids     │ sg_id
       ┌──────────────┘               ┌──────────────┘
       │                              │
       ▼                              ▼
┌──────────────┐              ┌──────────────┐
│  EC2 Module  │              │  RDS Module  │
└──────────────┘              └──────────────┘
```

### Perguntas para o Diagrama:

1. **Qual módulo deve ser criado primeiro?** Por quê?
2. **Os módulos de Security Group dependem de qual output da VPC?**
3. **O módulo EC2 depende de quantos outros módulos?**
4. **Se você destruir a VPC, o que acontece com os outros módulos?**
5. **Qual a vantagem de ter um módulo genérico de Security Group** ao invés de um "api-sg" e um "rds-sg" separados?

---

## Critérios de Avaliação

| Critério | Peso |
|----------|------|
| Identificou corretamente os blocos duplicados | 20% |
| Propôs módulos adequados com separação clara | 25% |
| Definiu inputs e outputs corretos para cada módulo | 25% |
| Diagrama de dependências coerente e correto | 20% |
| Participação na discussão em grupo | 10% |

---

## Discussão em Grupo (após os 30 min)

O professor conduzirá uma discussão com as seguintes perguntas:

1. Alguém identificou algum módulo diferente dos esperados? Por quê?
2. Quantas linhas teríamos com módulos vs sem módulos para 3 ambientes?
3. Qual a maior dificuldade que vocês imaginam na hora de refatorar código existente em módulos?
4. Alguém pensou em usar `for_each` para criar os dois ambientes com um único bloco de módulo?

> **Dica:** Não existe uma única resposta "correta" para design de módulos. O importante é a **justificativa** da sua escolha e a **coerência** entre inputs, outputs e dependências.

---

## Entrega

### Onde entregar

No fork do repositório da disciplina, na pasta de entrega da aula:

```
entregas/aula-06/SEU-RA/trabalho-em-aula.md
```

### O que entregar

Um arquivo `trabalho-em-aula.md` com as respostas das atividades realizadas em sala:

```markdown
# Trabalho em Aula — Aula 06: Módulos Terraform

**Aluno:** [Seu nome completo]  
**RA:** [Seu RA]  
**Data:** [Data da aula]

## Parte 1 — Identificação de Duplicação

1. Blocos de recursos duplicados entre dev e staging: ...
2. O que muda entre dev e staging: ...
3. Módulos que eu criaria (mín. 3): ...
4. Variáveis (inputs) de cada módulo: ...
5. Outputs de cada módulo: ...
6. Linhas para ambiente de produção (código atual vs com módulos): ...

## Parte 2 — Design de Módulos (Diagrama de Dependências)

[Descreva ou cole o diagrama de dependências entre os módulos]

- Módulo criado primeiro e por quê: ...
- Output da VPC que os Security Groups consomem: ...
- Quantos módulos o EC2 depende: ...
- O que acontece com os outros módulos ao destruir a VPC: ...
- Vantagem de um módulo genérico de Security Group: ...
```

### Como entregar

- O arquivo pode ser adicionado no **mesmo PR** do TF ou em PR separado
- A entrega é **individual** — mesmo que a atividade tenha sido em grupo
- O trabalho em aula vale **1 ponto na nota final** do semestre (contabilizado apenas ao final, com **todos** os trabalhos entregues)
