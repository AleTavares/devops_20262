![Titulo](img/titulolab1.png)
# Lab Parte 1: Primeiros Passos com Terraform na AWS

**Tempo estimado:** 120 minutos

## Missão: Provisionar o Primeiro Recurso na Nuvem

> A equipe de Platform Engineering da TechNova recebeu uma ordem direta do CTO: "Chega de clicar no Console AWS. Quero infraestrutura como código." Sua missão é instalar o Terraform, configurar as credenciais da AWS, e criar um bucket S3 real na nuvem — tudo via código.

---

## Pré-requisitos

- Conta AWS criada (com Free Tier ativo) — [Criar conta AWS](https://aws.amazon.com/free/)
- Docker e Docker Compose funcionando (Aulas 01-02)
- Git instalado e configurado (Aulas 01-02)
- Terminal (Git Bash no Windows, Terminal no macOS/Linux)
- Editor de texto (VS Code com extensão HashiCorp Terraform recomendada)

> **⚠️ Free Tier:** Todos os recursos criados neste lab são elegíveis ao AWS Free Tier. Lembre-se de executar `terraform destroy` ao final para evitar qualquer custo.

---

## Parte 1 — Instalando o Terraform (10 minutos)

### Passo 1.1: Verificar se o Terraform já está instalado

```bash
terraform version
```

Se aparecer a versão (≥ 1.0), pule para a Parte 2.

### Passo 1.2: Instalar o Terraform

#### Linux (Ubuntu/Debian)

```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install terraform
```

#### macOS (Homebrew)

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

#### Windows (Chocolatey)

```powershell
choco install terraform
```

### Passo 1.3: Verificar a instalação

```bash
terraform version
```

Resultado esperado:
```
Terraform v1.7.x
on linux_amd64
```

✅ **Checkpoint:** Terraform instalado e acessível no terminal.

---

## Parte 2 — Configurando Credenciais AWS (15 minutos)

### Passo 2.1: Instalar o AWS CLI (se não tiver)

#### Linux

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

#### macOS

```bash
brew install awscli
```

#### Windows

Baixe o instalador em: https://aws.amazon.com/cli/

### Passo 2.2: Criar credenciais de acesso no IAM

> **⚠️ Segurança:** Idealmente, não use a conta root. Crie um usuário IAM dedicado para Terraform. Se for a primeira vez, pode usar root temporariamente — corrigiremos no Lab Parte 2.

1. Acesse o Console AWS → IAM → Users → Create User
2. Nome: `terraform-lab` (ou seu nome pessoal)
3. Permissões: anexe as policies `AmazonS3FullAccess` e `IAMFullAccess` (para este lab)
4. Crie uma Access Key (tipo: CLI)
5. **Anote** o `Access Key ID` e `Secret Access Key` — eles aparecem apenas uma vez!

### Passo 2.3: Configurar as credenciais localmente

```bash
aws configure
```

Preencha:
```
AWS Access Key ID [None]: SUA_ACCESS_KEY_AQUI
AWS Secret Access Key [None]: SUA_SECRET_KEY_AQUI
Default region name [None]: us-east-1
Default output format [None]: json
```

### Passo 2.4: Verificar que as credenciais funcionam

```bash
aws sts get-caller-identity
```

Resultado esperado:
```json
{
    "UserId": "AIDAIOSFODNN7EXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-lab"
}
```

✅ **Checkpoint:** AWS CLI configurado e autenticado. O Terraform usará estas mesmas credenciais.

---

## Parte 3 — Primeiro Projeto Terraform: Bucket S3 (30 minutos)

### Passo 3.1: Criar o diretório do projeto

```bash
mkdir terraform-lab-s3
cd terraform-lab-s3
```

### Passo 3.2: Criar o arquivo `providers.tf`

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

### Passo 3.3: Criar o arquivo `main.tf`

```hcl
# =============================================
# Lab Parte 1: Primeiro recurso Terraform na AWS
# TechNova - Infraestrutura como Código
# =============================================

# Bucket S3 para armazenar dados da TechNova
resource "aws_s3_bucket" "technova_lab" {
  bucket = "technova-lab-SEU-NOME-2024"   # ⚠️ Substitua SEU-NOME

  tags = {
    Name        = "technova-lab"
    Environment = "development"
    Project     = "TechNova"
    ManagedBy   = "Terraform"
    Aula        = "03"
  }
}

# Bloquear acesso público (boa prática de segurança)
resource "aws_s3_bucket_public_access_block" "technova_lab_block" {
  bucket = aws_s3_bucket.technova_lab.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Habilitar versionamento no bucket
resource "aws_s3_bucket_versioning" "technova_lab_versioning" {
  bucket = aws_s3_bucket.technova_lab.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

> **⚠️ IMPORTANTE:** Nomes de buckets S3 são **globalmente únicos** na AWS. Substitua `SEU-NOME` pelo seu nome ou RA (ex: `technova-lab-joao-silva-2024`).

### Passo 3.4: Criar o `.gitignore`

```bash
cat > .gitignore << 'EOF'
# Terraform
.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
.terraform.lock.hcl

# OS
.DS_Store
Thumbs.db
EOF
```

### Passo 3.5: Verificar a estrutura

```bash
ls -la
```

Estrutura esperada:
![Estrutura Lab](img/estruturaLabParte1.png)

### Passo 3.6: Inicializar o projeto (`terraform init`)

```bash
terraform init
```

Resultado esperado:
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.xx.x...

Terraform has been successfully initialized!
```

### Passo 3.7: Planejar as mudanças (`terraform plan`)

```bash
terraform plan
```

Observe o output — o Terraform mostra que 3 recursos serão criados (`+`):
```
Plan: 3 to add, 0 to change, 0 to destroy.
```

### Passo 3.8: Aplicar as mudanças (`terraform apply`)

```bash
terraform apply
```

Quando solicitado, digite `yes` e pressione Enter:
```
Do you want to perform these actions?
  Enter a value: yes
```

Resultado esperado:
```
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

🎉 **Parabéns!** Você criou seu primeiro recurso na AWS usando Terraform!

### Passo 3.9: Verificar o recurso na AWS

```bash
aws s3 ls | grep technova
```

✅ **Checkpoint:** Bucket S3 criado via Terraform. Estado rastreado.

---

## Parte 4 — Modificando e Reaplicando (15 minutos)

### Passo 4.1: Adicionar uma nova tag ao bucket

Edite o `main.tf` e adicione uma tag:

```hcl
  tags = {
    Name        = "technova-lab"
    Environment = "development"
    Project     = "TechNova"
    ManagedBy   = "Terraform"
    Aula        = "03"
    Team        = "Platform Engineering"   # ← Nova tag
  }
```

### Passo 4.2: Ver o que mudou (plan)

```bash
terraform plan
```

Resultado esperado — o `~` indica modificação (não recriação):
```
  # aws_s3_bucket.technova_lab will be updated in-place
  ~ resource "aws_s3_bucket" "technova_lab" {
      ~ tags = {
          + "Team" = "Platform Engineering"
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

### Passo 4.3: Aplicar a modificação

```bash
terraform apply -auto-approve
```

### Passo 4.4: Testar idempotência

```bash
terraform plan
```

Resultado esperado:
```
No changes. Your infrastructure matches the configuration.
```

**Idempotência:** aplicar o mesmo código duas vezes não cria duplicatas. O Terraform detecta que o estado atual já corresponde ao desejado.

✅ **Checkpoint:** Infraestrutura modificada via código. Idempotência confirmada.

---

## Parte 5 — Variáveis e Outputs (20 minutos)

### Passo 5.1: Criar o arquivo `variables.tf`

```hcl
variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "TechNova"
}

variable "environment" {
  description = "Ambiente (development, staging, production)"
  type        = string
  default     = "development"
}

variable "bucket_suffix" {
  description = "Sufixo único para o nome do bucket (seu nome ou RA)"
  type        = string
}
```

### Passo 5.2: Criar o arquivo `outputs.tf`

```hcl
output "bucket_name" {
  description = "Nome do bucket S3 criado"
  value       = aws_s3_bucket.technova_lab.bucket
}

output "bucket_arn" {
  description = "ARN (identificador único AWS) do bucket"
  value       = aws_s3_bucket.technova_lab.arn
}

output "bucket_region" {
  description = "Região onde o bucket foi criado"
  value       = aws_s3_bucket.technova_lab.region
}
```

### Passo 5.3: Criar o arquivo `terraform.tfvars`

```hcl
bucket_suffix = "seu-nome-aqui"   # ⚠️ Substitua pelo seu nome
```

### Passo 5.4: Atualizar o `main.tf` para usar variáveis

Substitua o nome fixo do bucket por:

```hcl
resource "aws_s3_bucket" "technova_lab" {
  bucket = "technova-lab-${var.bucket_suffix}-2024"

  tags = {
    Name        = "technova-lab"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Aula        = "03"
    Team        = "Platform Engineering"
  }
}
```

### Passo 5.5: Aplicar com variáveis

```bash
terraform plan
terraform apply -auto-approve
```

Os outputs serão exibidos após o apply:
```
Outputs:

bucket_name = "technova-lab-seu-nome-2024"
bucket_arn = "arn:aws:s3:::technova-lab-seu-nome-2024"
bucket_region = "us-east-1"
```

✅ **Checkpoint:** Variáveis e outputs funcionando. Código mais flexível e reutilizável.

---

## Parte 6 — Destruindo e Limpando (10 minutos)

### Passo 6.1: Planejar a destruição

```bash
terraform plan -destroy
```

### Passo 6.2: Executar a destruição

```bash
terraform destroy
```

Confirme com `yes`:
```
Destroy complete! Resources: 3 destroyed.
```

### Passo 6.3: Confirmar remoção

```bash
aws s3 ls | grep technova
```

Nenhum resultado = bucket removido com sucesso.

> **⚠️ Free Tier:** Sempre execute `terraform destroy` ao final dos exercícios.

✅ **Checkpoint:** Recursos destruídos. Nenhum custo será gerado.

---

## Parte 7 — Versionando com Git (10 minutos)

### Passo 7.1: Inicializar repositório Git

```bash
git init
git add .
git status
```

Verifique que `.terraform/` e `*.tfstate` **NÃO** aparecem (o `.gitignore` funciona).

### Passo 7.2: Fazer o commit

```bash
git commit -m "feat: primeiro recurso AWS com Terraform (bucket S3)"
```

### Passo 7.3: Verificar os arquivos versionados

```bash
git ls-files
```

Resultado esperado:
```
.gitignore
main.tf
outputs.tf
providers.tf
terraform.tfvars
variables.tf
```

✅ **Checkpoint:** Projeto Terraform versionado no Git sem arquivos de estado.

---

## Troubleshooting — Problemas Comuns

### ❌ Erro: `BucketAlreadyExists`

**Causa:** O nome do bucket já está em uso (nomes são globais).
**Solução:** Use um nome mais único com seu RA ou timestamp.

### ❌ Erro: `NoCredentialProviders`

**Causa:** AWS CLI não configurado.
**Solução:** Execute `aws configure` e insira suas credenciais.

### ❌ Erro: `Invalid provider configuration`

**Causa:** Provider não inicializado.
**Solução:** Execute `terraform init`.

### ❌ Erro: `AccessDenied`

**Causa:** O usuário IAM não tem permissão para S3.
**Solução:** Verifique se a policy `AmazonS3FullAccess` está anexada ao seu usuário.

### ❌ Erro: `terraform: command not found`

**Causa:** Terraform não instalado ou não está no PATH.
**Solução:** Reinstale seguindo os passos da Parte 1.

---

## Validação Final

Ao concluir este laboratório, você deve ter:

- [ ] Terraform instalado e funcional (`terraform version`)
- [ ] AWS CLI configurado com credenciais válidas (`aws sts get-caller-identity`)
- [ ] Projeto Terraform com: `providers.tf`, `main.tf`, `variables.tf`, `outputs.tf`
- [ ] `.gitignore` configurado para excluir `.terraform/` e `*.tfstate`
- [ ] Executado `terraform init` com sucesso
- [ ] Executado `terraform plan` e revisado o plano
- [ ] Executado `terraform apply` e criado o bucket S3
- [ ] Confirmado o bucket via `aws s3 ls`
- [ ] Testado idempotência (plan sem mudanças)
- [ ] Modificado o recurso (nova tag) e aplicado a mudança
- [ ] Usado variáveis e outputs
- [ ] Executado `terraform destroy` e confirmado a remoção
- [ ] Projeto versionado no Git sem arquivos de estado

---

*A TechNova deu seu primeiro passo na infraestrutura como código! O CTO terá sua resposta: é possível criar infraestrutura AWS sem clicar no Console. Agora, no Lab Parte 2, resolveremos o segundo problema: segurança — implementando IAM com Terraform.*
