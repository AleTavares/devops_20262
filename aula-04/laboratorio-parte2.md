# Laboratório Parte 2 — EC2 na VPC via Spec-Driven | Aula 04

![Lab2](img/lab2Cab.png)

## Missão

Usar o **Kiro Spec** para provisionar uma instância EC2 dentro da VPC customizada criada no Lab Parte 1, com a API TechNova rodando e acessível publicamente via porta 3000. Validar cada etapa do Spec antes de aplicar.

**Pré-requisito:** Laboratório Parte 1 completo (VPC, subnets, IGW, Security Groups existindo)

> **IMPORTANTE:** Este lab DEPENDE dos recursos criados no Lab Parte 1. Execute `terraform output` para confirmar que a infraestrutura de rede está ativa.

---

## Arquitetura Final

![Arquitetura](img/lab2Arquitetura.png)

---

## Verificação Inicial

Antes de começar, confirme que o Lab Parte 1 está ativo:

```bash
cd aula-04-vpc-ec2
terraform output
```

Você deve ver os IDs da VPC, subnets e Security Groups.

---

## Parte 1 — Preparar o Ambiente (10 min)

### 1.1 Gerar chave SSH

A instância EC2 precisa de uma chave SSH. Gere localmente:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/technova-key -N ""
chmod 400 ~/.ssh/technova-key
```

### 1.2 Abrir o projeto no Kiro

```bash
kiro .
```

---

## Parte 2 — Usar Kiro Spec para Gerar a Infraestrutura EC2 (40 min)

### 2.1 Iniciar uma Sessão Spec no Kiro

Inicie uma nova sessão do tipo **Spec** e forneça o seguinte prompt:

> **Prompt para o Spec:**
>
> "Preciso adicionar uma instância EC2 ao projeto Terraform existente (que já tem VPC, subnets, IGW e Security Groups criados no Lab Parte 1). Estou usando o **AWS Academy Learner Lab**, que **não permite criar IAM Roles** — devo usar o instance profile pré-existente chamado `LabInstanceProfile` (que contém a role `LabRole`). O cenário é:
>
> **Instância EC2:**
> - Tipo: t2.micro (Free Tier)
> - AMI: Amazon Linux 2023 (buscar via data source `aws_ami`, owner `amazon`, filtro `al2023-ami-2023.*-x86_64`)
> - Subnet: subnet pública (já existe como `aws_subnet.public`)
> - Security Group: SG da API (já existe como `aws_security_group.api`)
> - Key Pair: registrar a chave pública `~/.ssh/technova-key.pub` via `aws_key_pair`
> - User Data: script `user_data.sh` que instala Node.js 18, cria uma API Express na porta 3000, e inicia automaticamente
> - Disco: 8 GB gp2
>
> **IAM (usar recurso pré-existente do Learner Lab):**
> - NÃO criar `aws_iam_role`, `aws_iam_role_policy_attachment` nem `aws_iam_instance_profile` (o Learner Lab bloqueia a criação de roles)
> - Usar o instance profile existente: `iam_instance_profile = "LabInstanceProfile"` diretamente no `aws_instance`
>
> **User Data (`user_data.sh`) deve:**
> - Atualizar o sistema (`yum update -y`)
> - Instalar Node.js 18 via nodesource
> - Criar uma API Express com 3 endpoints: `GET /` (info), `GET /health`, `GET /orders`
> - Iniciar a API com nohup na porta 3000
> - Logar progresso em `/var/log/technova-setup.log`
>
> **Outputs necessários:**
> - `ec2_public_ip` — IP público da instância
> - `ec2_public_dns` — DNS público
> - `ssh_command` — comando SSH completo para conectar
> - `api_url` — URL da API (http://IP:3000)
>
> **Tags obrigatórias:** Name, Project=TechNova, ManagedBy=Terraform
>
> **Restrições:**
> - Adicionar ao `main.tf` existente (não criar novo arquivo de providers)
> - Usar `file()` para ler a chave pública e o user_data
> - Não usar access keys hardcoded — usar o instance profile `LabInstanceProfile`
> - Não criar recursos IAM (usar apenas o que já existe no Learner Lab)"

### 2.2 Revisar os Requisitos (Etapa 1 do Spec)

O Kiro vai gerar um documento de requisitos. **Revise:**

| Verificação | O que conferir |
|---|---|
| EC2 é t2.micro? | Free Tier garantido |
| AMI via data source? | Não fixou ID de AMI |
| Subnet é a pública? | Referência a `aws_subnet.public` |
| Security Group correto? | Referência a `aws_security_group.api` |
| Key Pair usa `file()`? | Lê `~/.ssh/technova-key.pub` |
| User Data instala Node 18? | Via nodesource |
| API tem 3 endpoints? | `/`, `/health`, `/orders` |
| Usa `LabInstanceProfile`? | `iam_instance_profile = "LabInstanceProfile"` — NÃO cria role |
| Outputs listados? | IP, DNS, SSH command, API URL |

### 2.3 Revisar o Design (Etapa 2 do Spec)

Valide a arquitetura proposta:

- Os novos recursos se integram ao `main.tf` existente?
- O `user_data.sh` é arquivo separado (não inline)?
- O EC2 referencia `LabInstanceProfile` (sem criar recursos IAM)?
- Tags presentes em todos os recursos?

### 2.4 Revisar as Tarefas (Etapa 3 do Spec)

A ordem esperada é:

1. Data source `aws_ami` (buscar AMI)
2. `aws_key_pair` (registrar chave SSH)
3. Criar `user_data.sh`
4. `aws_instance` (EC2) — usando `iam_instance_profile = "LabInstanceProfile"`
5. Outputs

> **Nota:** Não há tarefas de criação de IAM Role/Instance Profile — no Learner Lab usamos o `LabInstanceProfile` que já existe.

### 2.5 Aceitar a Geração de Código (Etapa 4 do Spec)

Deixe o Kiro gerar os arquivos. Em modo **Supervised**, revise cada mudança antes de aceitar.

---

## Parte 3 — Validar o Código Gerado (20 min)

### 3.1 Checklist de Validação

| # | Item | Comando/Verificação | ✅ |
|---|---|---|---|
| 1 | Sintaxe HCL válida | `terraform validate` | |
| 2 | Plan mostra ~2 novos recursos | `terraform plan` | |
| 3 | AMI via data source (não ID fixo) | Verificar `data "aws_ami"` | |
| 4 | Instance type é `t2.micro` | Verificar `aws_instance` | |
| 5 | Subnet é a pública | `subnet_id = aws_subnet.public.id` | |
| 6 | SG é o da API | `vpc_security_group_ids` correto | |
| 7 | User Data usa `file("user_data.sh")` | Verificar `aws_instance` | |
| 8 | Usa `LabInstanceProfile` (não cria role) | `iam_instance_profile = "LabInstanceProfile"` | |
| 9 | NÃO há `aws_iam_role` no código | Buscar por `aws_iam_role` (não deve existir) | |
| 10 | Nenhuma access key hardcoded | Buscar por `aws_iam_access_key` | |
| 11 | Tags em todos os recursos | Verificar blocos `tags {}` | |
| 12 | `user_data.sh` instala Node 18 | Revisar script | |
| 13 | API escuta em `0.0.0.0:3000` | Verificar `server.js` no script | |
| 14 | Outputs declarados (4) | IP, DNS, SSH, URL | |

### 3.2 Executar validação

```bash
terraform validate
terraform plan
```

**Plan esperado:**
```
Plan: 2 to add, 0 to change, 0 to destroy.

  + aws_key_pair.main
  + aws_instance.api
```

> Note que **não há recursos IAM** no plan — o EC2 apenas referencia o `LabInstanceProfile` existente.

### 3.3 Corrigir se necessário

Se o Kiro gerou algo que viola o checklist, peça correção no chat:
- Se fixou ID de AMI → peça para usar data source
- Se colocou user data inline → peça para usar `file()`
- Se **criou `aws_iam_role` ou `aws_iam_instance_profile`** → peça para usar o `LabInstanceProfile` existente (o Learner Lab bloqueia criação de roles)
- Se esqueceu tags → peça para adicionar
- Se esqueceu algum output → peça para complementar

---

## Parte 4 — Aplicar e Testar (25 min)

### 4.1 Aplicar

```bash
terraform apply
```

Digite `yes` quando solicitado. Anote os outputs.

### 4.2 Aguardar inicialização

A instância precisa de **2-3 minutos** para executar o User Data (instalar Node.js, criar API, iniciar):

```bash
echo "Aguardando instância inicializar..."
sleep 180
```

### 4.3 Testar a API

```bash
export API_IP=$(terraform output -raw ec2_public_ip)

# Endpoint principal
curl http://$API_IP:3000

# Health check
curl http://$API_IP:3000/health

# Orders
curl http://$API_IP:3000/orders
```

**Respostas esperadas:**
```json
{"message":"TechNova API - Rodando na AWS!","hostname":"ip-10-0-1-xxx",...}
{"status":"healthy","service":"technova-api"}
{"orders":[{"id":1,"product":"Widget A","status":"shipped"},{"id":2,...}]}
```

### 4.4 Testar SSH

```bash
ssh -i ~/.ssh/technova-key ec2-user@$API_IP
```

Uma vez dentro:
```bash
node --version          # Esperado: v18.x
curl localhost:3000     # API rodando
aws sts get-caller-identity  # Mostra a Role (não access keys)
exit
```

### 4.5 Verificar o Instance Profile (LabRole)

O comando `aws sts get-caller-identity` dentro do EC2 deve mostrar a `LabRole`:
```json
{
  "Arn": "arn:aws:sts::XXXX:assumed-role/LabRole/i-0abc..."
}
```

Isso confirma: o EC2 está usando o `LabInstanceProfile` (que contém a `LabRole`) com credenciais temporárias — sem access keys no código.

> **Por que LabRole?** No AWS Academy Learner Lab não é permitido criar IAM Roles. A `LabRole` é uma role pré-configurada com permissões amplas para uso educacional. Em um ambiente de produção real, você criaria uma role dedicada com menor privilégio (como fizemos conceitualmente na Aula 03).

---

## Parte 5 — Reflexão Spec-Driven (10 min)

Crie um arquivo `spec-reflexao.md` no projeto:

```markdown
# Reflexão — Spec-Driven para EC2 na VPC

## O que o Kiro acertou de primeira?
- ...

## O que precisou de correção?
- ...

## O user_data.sh gerado funcionou sem ajustes?
- ...

## O checklist pegou algum problema de segurança?
- ...

## Comparação com o Lab 1 (manual): qual abordagem foi mais rápida?
- ...

## Em quais partes o Spec-Driven brilhou e em quais foi limitado?
- ...
```

---

## Parte 6 — Destruir e Limpar (5 min)

### 6.1 Destruir TUDO

```bash
terraform destroy
```

Confirme com `yes`. Isso remove EC2 + VPC + tudo do Lab 1 e Lab 2.

### 6.2 Verificar

```bash
terraform state list
# Esperado: (vazio)
```

> **SEMPRE destrua após o lab** para evitar custos. As evidências (outputs, curl responses) provam que funcionou.

---

## Troubleshooting

### ❌ "Connection refused" na porta 3000

User Data ainda está executando. Espere mais 2-3 minutos. Se persistir:
```bash
ssh -i ~/.ssh/technova-key ec2-user@$API_IP
sudo cat /var/log/cloud-init-output.log | tail -30
cat /var/log/technova-setup.log
```

### ❌ "SSH timeout"

Verifique:
- Security Group tem porta 22 aberta? (`terraform state show aws_security_group.api`)
- Instância está na subnet pública? (`terraform output`)
- Instância tem IP público? (`terraform output ec2_public_ip`)

### ❌ "Permission denied (publickey)"

```bash
chmod 400 ~/.ssh/technova-key
ssh -i ~/.ssh/technova-key ec2-user@$API_IP  # ec2-user, não root
```

### ❌ Kiro gerou AMI com ID fixo

Peça: "Use um data source aws_ami para buscar a AMI mais recente do Amazon Linux 2023 em vez de fixar o ID"

### ❌ Kiro colocou user data inline (heredoc)

Peça: "Coloque o user data em um arquivo separado user_data.sh e use file() para referenciá-lo"

### ❌ Erro `AccessDenied` em `iam:CreateRole` no `terraform apply`

O Kiro gerou recursos IAM que o Learner Lab bloqueia. Peça: "Remova os recursos aws_iam_role, aws_iam_role_policy_attachment e aws_iam_instance_profile. Use o instance profile existente com `iam_instance_profile = \"LabInstanceProfile\"` diretamente no aws_instance."

### ❌ Erro `ExpiredToken` durante o apply

As credenciais do Learner Lab expiraram no meio do lab. Reinicie o lab (Start Lab) e recopie as credenciais para `~/.aws/credentials`, depois rode o `terraform apply` novamente.

---

## Validação Final

- [ ] Usou Kiro Spec para gerar a infraestrutura EC2
- [ ] Revisou requisitos, design e tarefas antes da geração
- [ ] `terraform plan` mostra ~5 novos recursos (sem erros)
- [ ] `curl http://<IP>:3000` retorna JSON da API
- [ ] `curl http://<IP>:3000/health` retorna `{"status":"healthy"}`
- [ ] SSH funciona: `ssh -i ~/.ssh/technova-key ec2-user@<IP>`
- [ ] `aws sts get-caller-identity` dentro do EC2 mostra a `LabRole`
- [ ] Checklist de validação aprovado (sem criar IAM, usando LabInstanceProfile, com tags, AMI via data source)
- [ ] Reflexão documentada em `spec-reflexao.md`
- [ ] `terraform destroy` removeu todos os recursos
- [ ] Código versionado no Git (sem .tfstate, sem .pem)

---

## Estrutura Final do Projeto

![Estrutura](img/lab2EstruturaFinal.png)

---

*Neste lab você usou Spec-Driven para provisionar infraestrutura real na AWS. Descreveu o cenário, o Kiro planejou e gerou o código, e você validou com o checklist antes de aplicar. O resultado: API rodando na nuvem, com IAM Role seguro, e tudo destruído ao final. Este é o workflow profissional.*
