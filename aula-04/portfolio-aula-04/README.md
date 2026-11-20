# Infraestrutura TechNova — Aula 04: VPC + EC2 Multi-AZ

Infraestrutura completa de rede e compute para a TechNova provisionada com Terraform no AWS Academy Learner Lab. Implementa VPC customizada com 4 subnets distribuídas em 2 Availability Zones e uma instância EC2 t2.micro com a API Node.js rodando via User Data.

---

## Diagrama da Arquitetura

```
                              INTERNET
                                  │
                    ┌─────────────▼──────────────┐
                    │      Internet Gateway       │
                    │       (technova-igw)        │
                    └─────────────┬──────────────┘
                                  │
┌─────────────────────────────────▼──────────────────────────────────────┐
│  VPC: 10.0.0.0/16  (technova-vpc)                                      │
│                                                                        │
│  Route Table Pública: 0.0.0.0/0 → IGW                                 │
│                                                                        │
│  ┌───────────────────────────┐    ┌───────────────────────────┐        │
│  │   Subnet Pública AZ-a     │    │   Subnet Pública AZ-b     │        │
│  │   10.0.1.0/24             │    │   10.0.3.0/24             │        │
│  │   us-east-1a              │    │   us-east-1b              │        │
│  │                           │    │                           │        │
│  │  ┌─────────────────────┐  │    │  (futuro: ALB / EC2)      │        │
│  │  │  EC2 t2.micro        │  │    │                           │        │
│  │  │  technova-api-server │  │    │                           │        │
│  │  │  API Node.js :3000   │  │    │                           │        │
│  │  │  SG: 22 + 3000       │  │    │                           │        │
│  │  │  LabInstanceProfile  │  │    │                           │        │
│  │  └─────────────────────┘  │    │                           │        │
│  └───────────────────────────┘    └───────────────────────────┘        │
│                                                                        │
│  Route Table Privada: 10.0.0.0/16 → local  (sem acesso à internet)    │
│                                                                        │
│  ┌───────────────────────────┐    ┌───────────────────────────┐        │
│  │   Subnet Privada AZ-a     │    │   Subnet Privada AZ-b     │        │
│  │   10.0.2.0/24             │    │   10.0.4.0/24             │        │
│  │   us-east-1a              │    │   us-east-1b              │        │
│  │                           │    │                           │        │
│  │  (futuro: RDS primary)    │    │  (futuro: RDS standby)    │        │
│  │  SG DB: 5432 ← VPC only  │    │  SG DB: 5432 ← VPC only  │        │
│  └───────────────────────────┘    └───────────────────────────┘        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Recursos Criados

| Recurso | Nome | Função |
|---------|------|--------|
| `aws_vpc` | technova-vpc | Rede virtual isolada (10.0.0.0/16) |
| `aws_subnet` (×2 públicas) | technova-public-subnet-1/2 | Subnets com acesso à internet, uma por AZ |
| `aws_subnet` (×2 privadas) | technova-private-subnet-1/2 | Subnets internas para banco/cache, uma por AZ |
| `aws_internet_gateway` | technova-igw | Conecta a VPC à internet |
| `aws_route_table` | technova-public-rt | Direciona 0.0.0.0/0 → IGW |
| `aws_route_table_association` (×2) | — | Liga a RT pública às 2 subnets públicas |
| `aws_security_group` | technova-api-sg | Permite SSH (22) e API (3000) de 0.0.0.0/0 |
| `aws_security_group` | technova-db-sg | Permite PostgreSQL (5432) apenas da VPC |
| `tls_private_key` | — | Gera par de chaves RSA 4096 localmente |
| `aws_key_pair` | technova-key | Registra chave pública na AWS |
| `local_file` | technova-key.pem | Salva chave privada local (chmod 400) |
| `aws_instance` | technova-api-server | EC2 t2.micro com API Node.js 18 |

---

## Pré-requisitos

- **AWS CLI** instalado e configurado
- **Terraform** ≥ 1.0 instalado
- Acesso ao **AWS Academy Learner Lab** ativo (credenciais temporárias)
- **Git** instalado

---

## Como Usar

### 1. Configurar credenciais do AWS Academy

Crie um arquivo `aws-creds.sh` na raiz do projeto (está no `.gitignore`):

```bash
#!/bin/bash
export AWS_ACCESS_KEY_ID="ASIA_SUA_KEY_AQUI"
export AWS_SECRET_ACCESS_KEY="SUA_SECRET_AQUI"
export AWS_SESSION_TOKEN="SEU_TOKEN_AQUI"
export AWS_DEFAULT_REGION="us-east-1"
echo "Credenciais AWS Academy carregadas."
```

Carregue no terminal atual:

```bash
source aws-creds.sh
aws sts get-caller-identity  # verifica se está funcionando
```

### 2. Inicializar o Terraform

```bash
terraform init
```

### 3. Revisar o plano

```bash
terraform plan
# Salvar evidência:
terraform plan > terraform-plan-output.txt
```

Deve mostrar **~13 recursos a criar** (VPC, 4 subnets, IGW, RT, 2 RT associations, 2 SGs, key pair, EC2).

### 4. Aplicar

```bash
terraform apply
```

Digite `yes` quando solicitado. Anote os outputs ao final.

### 5. Testar a API

Aguarde ~3 minutos para o User Data concluir, depois:

```bash
export API_IP=$(terraform output -raw ec2_public_ip)

curl http://$API_IP:3000          # informações da instância
curl http://$API_IP:3000/health   # health check
curl http://$API_IP:3000/orders   # pedidos simulados
```

### 6. Acessar via SSH

```bash
ssh -i ./technova-key.pem ec2-user@$(terraform output -raw ec2_public_ip)

# Dentro da instância:
node --version                # v18.x
systemctl status technova-api # serviço rodando
aws sts get-caller-identity   # confirma LabRole via Instance Profile
```

### 7. Destruir após as evidências

```bash
terraform destroy
```

> **Sempre destrua após o lab** para evitar consumo do Free Tier e créditos do Academy.

---

## Decisões Técnicas

**Por que Multi-AZ?**  
Distribuir subnets em 2 AZs (us-east-1a e us-east-1b) é o mínimo para alta disponibilidade. Se uma AZ sofrer uma falha física, os recursos na outra continuam operando. Essa estrutura também é pré-requisito para um Application Load Balancer no futuro (ALB exige pelo menos 2 AZs).

**Por que separar subnets públicas e privadas?**  
Defesa em profundidade: o banco de dados nunca deve ter rota para a internet, independente do Security Group. A subnet privada garante isolamento de rede como segunda camada de proteção. Mesmo que o SG do banco seja mal configurado, sem rota para o IGW o tráfego não chega.

**Por que `tls_private_key` em vez de chave pré-existente?**  
Para que o projeto seja reproduzível — qualquer pessoa que clonar o repositório pode executar `terraform apply` sem precisar gerar a chave manualmente. O arquivo `.pem` é gerado localmente e está no `.gitignore`.

**Por que `LabInstanceProfile` em vez de criar uma IAM Role?**  
O TF.md pede uma IAM Role com `AmazonS3ReadOnlyAccess`. Em produção, criaríamos `aws_iam_role` + `aws_iam_role_policy_attachment` + `aws_iam_instance_profile` com essa permissão. Porém, o AWS Academy Learner Lab bloqueia a criação de IAM Roles por política de segurança do ambiente educacional (`AccessDenied: iam:CreateRole`). O `LabInstanceProfile` é pré-configurado com a `LabRole`, que inclui `AmazonS3ReadOnlyAccess` e outras permissões necessárias para o lab. Essa é a abordagem documentada no `laboratorio-parte2.md` da disciplina para o contexto do Academy.

**Por que systemd em vez de `nohup`?**  
O systemd reinicia a API automaticamente se ela falhar (`Restart=on-failure`) e persiste após reboot da instância. É a abordagem de produção correta para processos longos no Linux.

---

## Estrutura de Arquivos

```
terraform-vpc-ec2/
├── providers.tf       # Terraform e provider AWS/TLS/local
├── variables.tf       # Todas as variáveis com defaults
├── main.tf            # Recursos: VPC, subnets, IGW, RT, SGs, Key Pair, EC2
├── outputs.tf         # 18 outputs: IPs, URLs, comandos prontos
├── user_data.sh       # Script de boot: instala Node.js 18 + API Express
├── .gitignore         # Exclui .tfstate, .pem, aws-creds.sh
└── README.md          # Este arquivo
```
