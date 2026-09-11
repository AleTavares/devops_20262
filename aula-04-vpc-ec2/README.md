# Infraestrutura TechNova — Aula 04

VPC + EC2 com Terraform no AWS Academy Learner Lab.

---

## Diagrama da Arquitetura

```
                          Internet
                             │
                             ▼
                    ┌─────────────────┐
                    │ Internet Gateway │
                    │  (technova-igw)  │
                    └────────┬────────┘
                             │
        ┌────────────────────▼────────────────────┐
        │           VPC: 10.0.0.0/16              │
        │           (technova-vpc)                │
        │                                         │
        │  ┌──────────────────────────────────┐   │
        │  │   Subnet Pública 10.0.1.0/24     │   │
        │  │   AZ: us-east-1a                 │   │
        │  │                                  │   │
        │  │  ┌────────────────────────────┐  │   │
        │  │  │  EC2: t2.micro             │  │   │
        │  │  │  (technova-api-ec2)        │  │   │
        │  │  │  AMI: Amazon Linux 2023    │  │   │
        │  │  │  API Node.js: porta 3000   │  │   │
        │  │  │  IAM: LabInstanceProfile   │  │   │
        │  │  └────────────────────────────┘  │   │
        │  │                                  │   │
        │  │  SG (technova-api-sg):           │   │
        │  │    Inbound  22   TCP 0.0.0.0/0   │   │
        │  │    Inbound  3000 TCP 0.0.0.0/0   │   │
        │  │    Outbound all  TCP 0.0.0.0/0   │   │
        │  │                                  │   │
        │  │  Route Table → 0.0.0.0/0 → IGW  │   │
        │  └──────────────────────────────────┘   │
        │                                         │
        │  ┌──────────────────────────────────┐   │
        │  │   Subnet Privada 10.0.2.0/24     │   │
        │  │   AZ: us-east-1a                 │   │
        │  │                                  │   │
        │  │  Recursos futuros:               │   │
        │  │    - RDS PostgreSQL              │   │
        │  │    - Cache Redis                 │   │
        │  │                                  │   │
        │  │  SG (technova-db-sg):            │   │
        │  │    Inbound 5432 TCP 10.0.0.0/16  │   │
        │  │                                  │   │
        │  │  Route Table → apenas local      │   │
        │  └──────────────────────────────────┘   │
        └─────────────────────────────────────────┘
```

---

## Recursos Criados

| Recurso | Nome | Função |
|---------|------|--------|
| `aws_vpc` | technova-vpc | Rede virtual isolada (10.0.0.0/16) |
| `aws_subnet` (pública) | technova-public-subnet | Hospeda EC2 e recursos com acesso à internet |
| `aws_subnet` (privada) | technova-private-subnet | Futuros bancos de dados e workers |
| `aws_internet_gateway` | technova-igw | Porta de entrada/saída para a internet |
| `aws_route_table` | technova-public-rt | Direciona 0.0.0.0/0 para o IGW |
| `aws_route_table_association` | — | Associa a RT pública à subnet pública |
| `aws_security_group` (api) | technova-api-sg | Libera portas 22 e 3000 para a EC2 |
| `aws_security_group` (db) | technova-db-sg | Libera porta 5432 apenas da VPC |
| `aws_key_pair` | technova-key | Par de chaves SSH para acesso à instância |
| `data.aws_ami` | — | Busca a AMI mais recente do Amazon Linux 2023 |
| `aws_instance` | technova-api-ec2 | Instância EC2 t2.micro rodando a API |

---

## Pré-requisitos

- [AWS CLI](https://aws.amazon.com/cli/) instalado
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- Acesso ao **AWS Academy Learner Lab** ativo (status verde)
- Chave SSH gerada localmente:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/technova-key -N ""
chmod 400 ~/.ssh/technova-key
```

---

## Como Usar

### 1. Carregar credenciais do AWS Academy

Copie os valores de **AWS Details → AWS CLI → Show** no Learner Lab para o arquivo `aws-creds.sh` e execute:

```bash
source aws-creds.sh
aws sts get-caller-identity   # confirma que as credenciais estão válidas
```

> `aws-creds.sh` está no `.gitignore` — nunca suba credenciais para o repositório.

### 2. Inicializar o Terraform

```bash
terraform init
```

### 3. Revisar o plano

```bash
terraform plan
```

Esperado: **10 recursos** a criar (VPC, 2 subnets, IGW, RT, RT association, 2 SGs, Key Pair, EC2).

### 4. Aplicar

```bash
terraform apply
```

Digite `yes` quando solicitado. Anote os outputs ao final (IP público, URL da API, comando SSH).

### 5. Testar a API

Aguarde ~3 minutos para o User Data terminar e então:

```bash
export API_IP=$(terraform output -raw ec2_public_ip)

curl http://$API_IP:3000          # informações da API
curl http://$API_IP:3000/health   # health check
curl http://$API_IP:3000/orders   # lista de pedidos
```

### 6. Testar SSH

```bash
ssh -i ~/.ssh/technova-key ec2-user@$(terraform output -raw ec2_public_ip)
```

Dentro da instância:
```bash
node --version                 # v18.x
curl localhost:3000            # API respondendo localmente
aws sts get-caller-identity    # confirma que usa LabRole (sem access keys)
exit
```

### 7. Destruir após as evidências

```bash
terraform destroy
```

> **Sempre destrua ao final do lab** para evitar consumo desnecessário de créditos do Learner Lab.

---

## Decisões Técnicas

**Por que separar subnet pública e privada?**  
Segurança em camadas (defesa em profundidade). A API pode ser comprometida — se isso acontecer, o banco de dados ainda está protegido pela barreira de rede da subnet privada. Nenhum tráfego externo chega diretamente ao banco.

**Por que não usar NAT Gateway?**  
O NAT Gateway custa ~$32/mês, o que consumiria os créditos do Learner Lab rapidamente. Para o lab, o banco de dados não precisa de acesso externo. Em produção, o NAT Gateway seria necessário para que o banco aplique patches de segurança.

**Por que `LabInstanceProfile` em vez de criar uma IAM Role?**  
O AWS Academy Learner Lab bloqueia a criação de IAM Roles por design. O `LabInstanceProfile` é a role pré-configurada do ambiente educacional. Em produção, criaria-se uma role dedicada com o menor privilégio necessário.

**Por que `t2.micro`?**  
É o único tipo de instância EC2 elegível ao Free Tier (750h/mês). Suficiente para o laboratório e sem custo adicional.

**Por que AMI via data source?**  
IDs de AMI variam por região e mudam a cada nova versão. Usar `data "aws_ami"` garante que o Terraform sempre busca a versão mais recente do Amazon Linux 2023 na região correta, sem hardcoding.

---

## Estrutura do Projeto

```
aula-04-vpc-ec2/
├── providers.tf       # Configuração do provider AWS e default_tags
├── variables.tf       # Variáveis: região, CIDRs, AZ, nome do projeto
├── main.tf            # Todos os recursos: VPC, subnets, IGW, RT, SGs, Key Pair, EC2
├── outputs.tf         # Outputs: IDs, IPs, URL da API, comando SSH
├── user_data.sh       # Bootstrap: instala Node.js 18, cria e inicia a API Express
├── README.md          # Este arquivo
└── .gitignore         # Ignora .tfstate, .terraform/, .pem, aws-creds.sh
```
