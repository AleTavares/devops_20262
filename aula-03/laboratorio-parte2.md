![Titulo](img/tituloLab2.png)
# Lab Parte 2: IAM com Terraform via Spec-Driven Development

## Missão: Implementar Controle de Acesso Seguro usando Kiro Spec

> A auditoria de segurança revelou que a TechNova está usando credenciais root compartilhadas — um risco crítico. Sua missão: usar o **Kiro Spec** para gerar a estrutura IAM completa (users, groups, policies, roles), validar cada etapa antes de aplicar, e garantir que o princípio do menor privilégio está sendo respeitado.

---

## Pré-requisitos

- Terraform instalado e funcional (Lab Parte 1)
- AWS CLI configurado com credenciais válidas (Lab Parte 1)
- Kiro instalado e funcional
- Conhecimento do fluxo `terraform init → plan → apply → destroy` (Lab Parte 1)

> **Free Tier:** IAM é **sempre gratuito**. Este lab não gera nenhum custo.

---

## Parte 1 — Preparar o Projeto (10 minutos)

### Passo 1.1: Criar o diretório do projeto

```bash
mkdir terraform-iam-lab
cd terraform-iam-lab
```

### Passo 1.2: Criar `providers.tf`

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

### Passo 1.3: Criar `.gitignore`

```bash
cat > .gitignore << 'EOF'
.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
.terraform.lock.hcl
EOF
```

### Passo 1.4: Inicializar o Terraform

```bash
terraform init
```

### Passo 1.5: Abrir o projeto no Kiro

```bash
kiro .
```

---

## Parte 2 — Usar Kiro Spec para Gerar a Estrutura IAM (45 minutos)

### Passo 2.1: Iniciar uma Sessão Spec no Kiro

No Kiro, inicie uma nova sessão do tipo **Spec** e forneça o seguinte prompt:

> **Prompt para o Spec:**
>
> "Preciso implementar IAM seguro para a empresa TechNova usando Terraform na AWS (us-east-1). O cenário é:
>
> **Equipe:**
> - Juliana Santos — Desenvolvedora Sênior (equipe Development)
> - Rafael Oliveira — Desenvolvedor Backend (equipes Development + Platform Engineering)
> - Lucas — Estagiário (equipe Development, acesso restrito)
>
> **Groups necessários:**
> - `technova-developers` — todos os devs
> - `technova-platform-eng` — equipe de infra
> - `technova-interns` — estagiários (somente leitura)
>
> **Policies (princípio do menor privilégio):**
> - Developers: podem ler S3 em buckets `technova-dados-*`
> - Platform Engineering: podem gerenciar EC2 (start/stop/reboot) apenas instâncias com tag `Project=TechNova`
> - Interns: somente leitura (S3 + EC2 describe) com Deny explícito para ações destrutivas
>
> **Service Role:**
> - Role para EC2 acessar S3 (bucket `technova-app-data-*`) com credenciais temporárias
> - Instance Profile vinculado ao role
>
> **Requisitos técnicos:**
> - Tags obrigatórias: Project, ManagedBy, Team/Purpose
> - Arquivos separados: `groups.tf`, `users.tf`, `policies.tf`, `attachments.tf`, `roles.tf`, `outputs.tf`
> - Outputs: lista de users, groups, policy ARNs, role ARN, instance profile name
> - Nenhuma access key hardcoded
> - Deny explícito para ações destrutivas no grupo de interns"

### Passo 2.2: Revisar os Requisitos (Etapa 1 do Spec)

O Kiro vai gerar um documento de requisitos. **Revise com atenção:**

| Verificação | O que conferir |
|---|---|
| Todos os 3 users estão listados? | Juliana, Rafael, Lucas |
| Todos os 3 groups estão descritos? | developers, platform-eng, interns |
| Memberships estão corretas? | Rafael em 2 groups, Lucas só em interns |
| Policies seguem menor privilégio? | Sem `*` em excesso, resources específicos |
| Deny explícito para interns? | `Delete*`, `Terminate*`, `Create*` |
| Service role descrito? | Trust policy EC2 + permissions S3 |

> **Se algo estiver errado ou faltando:** corrija nesta etapa antes de avançar. É mais barato corrigir requisitos do que código.

### Passo 2.3: Revisar o Design (Etapa 2 do Spec)

O Kiro vai propor a arquitetura. Valide:

- Estrutura de arquivos segue o padrão? (`groups.tf`, `users.tf`, etc.)
- Fluxo de permissões está correto? (Policy → Group → User)
- Role usa trust policy + permissions policy + instance profile?
- Tags estão planejadas em todos os recursos?

### Passo 2.4: Revisar as Tarefas (Etapa 3 do Spec)

O Kiro vai listar as tarefas de implementação. A ordem esperada é:

1. Criar groups
2. Criar users
3. Criar custom policies
4. Anexar policies aos groups (attachments)
5. Criar role + instance profile
6. Declarar outputs

> **Valide a ordem:** groups antes de users (dependência para membership), policies antes de attachments.

### Passo 2.5: Aceitar a Geração de Código (Etapa 4 do Spec)

Deixe o Kiro gerar os arquivos. Em modo **Supervised**, revise cada arquivo antes de aceitar.

---

## Parte 3 — Validar o Código Gerado (30 minutos)

### Passo 3.1: Checklist de Validação

Após o Kiro gerar os arquivos, passe pelo checklist:

| # | Item | Comando/Verificação | ✅ |
|---|---|---|---|
| 1 | Sintaxe HCL válida | `terraform validate` | |
| 2 | Plan sem erros | `terraform plan` | |
| 3 | Policies sem `Action: ["*"]` | Revisar `policies.tf` | |
| 4 | Policies sem `Resource: "*"` (exceto Describe) | Revisar `policies.tf` | |
| 5 | Deny explícito nos interns | Verificar statement com `Effect = "Deny"` | |
| 6 | Tags em todos os recursos | Verificar blocos `tags {}` | |
| 7 | Trust policy no role = `ec2.amazonaws.com` | Verificar `roles.tf` | |
| 8 | Instance profile vinculado ao role | Verificar `roles.tf` | |
| 9 | Outputs declarados | Verificar `outputs.tf` | |
| 10 | Nenhuma access key no código | Buscar por `aws_iam_access_key` | |

### Passo 3.2: Executar validação

```bash
terraform validate
terraform plan
```

### Passo 3.3: Corrigir se necessário

Se o Kiro gerou algo que viola o checklist:
- Volte ao chat do Kiro e peça a correção específica
- Ou corrija manualmente no editor

**Exemplos de correções comuns:**
- Se gerou `Action = ["s3:*"]` → peça para especificar (`s3:GetObject`, `s3:ListBucket`)
- Se esqueceu tags → peça para adicionar
- Se não separou os arquivos → peça para reorganizar

---

## Parte 4 — Aplicar e Verificar na AWS (20 minutos)

### Passo 4.1: Aplicar

```bash
terraform apply -auto-approve
```

### Passo 4.2: Verificar groups

```bash
aws iam list-groups --query 'Groups[?contains(GroupName, `technova`)]' --output table
```

### Passo 4.3: Verificar membros

```bash
aws iam get-group --group-name technova-developers --query 'Users[].UserName' --output text
```

Resultado esperado: `juliana.santos    rafael.oliveira`

### Passo 4.4: Verificar policies

```bash
aws iam list-policies --scope Local --query 'Policies[?contains(PolicyName, `technova`)].[PolicyName, Arn]' --output table
```

### Passo 4.5: Verificar role e instance profile

```bash
aws iam get-role --role-name technova-ec2-app-role --query 'Role.[RoleName, Arn]' --output table
aws iam list-instance-profiles --query 'InstanceProfiles[?contains(InstanceProfileName, `technova`)].[InstanceProfileName, Roles[0].RoleName]' --output table
```

### Passo 4.6: Modelo de permissões final

![Modelo Permissão](img/modeloPermissao.png)

✅ **Checkpoint:** Estrutura IAM completa da TechNova aplicada na AWS via Spec-Driven.

---

## Parte 5 — Reflexão sobre o Processo Spec-Driven (10 minutos)

### Passo 5.1: Documentar a experiência

Crie um arquivo `spec-reflexao.md` no projeto com as seguintes reflexões:

```markdown
# Reflexão — Spec-Driven para IAM

## O que o Kiro acertou de primeira?
- ...

## O que precisou de correção?
- ...

## O checklist de validação pegou algum problema?
- ...

## Comparação: se eu escrevesse manualmente, quanto tempo levaria?
- ...

## Em quais partes eu confiei no Kiro e em quais eu desconfiei?
- ...

## O princípio do menor privilégio foi respeitado na primeira geração?
- ...
```

> **Esta reflexão faz parte da entrega do TF.** Demonstra pensamento crítico sobre o uso de IA.

---

## Parte 6 — Destruir e Limpar (5 minutos)

### Passo 6.1: Destruir todos os recursos

```bash
terraform destroy
```

Confirme com `yes`.

### Passo 6.2: Confirmar remoção

```bash
aws iam list-users --query 'Users[?contains(UserName, `juliana`) || contains(UserName, `rafael`) || contains(UserName, `lucas`)]' --output text
```

Nenhum resultado = todos os recursos removidos.

✅ **Checkpoint:** Conta limpa. Todos os recursos IAM destruídos.

---

## Troubleshooting

### ❌ Kiro gerou tudo em um único arquivo

Peça: "Separe os recursos em arquivos individuais: groups.tf, users.tf, policies.tf, attachments.tf, roles.tf, outputs.tf"

### ❌ Kiro usou `Action: ["iam:*"]` ou `Resource: "*"`

Peça: "Aplique o princípio do menor privilégio — especifique apenas as ações necessárias e restrinja os resources com ARNs específicos"

### ❌ Erro `EntityAlreadyExists`

Recurso já existe de lab anterior:
```bash
aws iam get-user --user-name juliana.santos
# Se existir, delete manualmente ou altere o nome no código
```

### ❌ Erro `DeleteConflict` ao destruir

```bash
terraform destroy -target=aws_iam_group_membership.dev_members
terraform destroy
```

### ❌ Erro `MalformedPolicyDocument`

- Verifique se `Version` é `"2012-10-17"`
- Confirme vírgulas e colchetes no JSON
- Use `terraform validate` para checar sintaxe

---

## Validação Final

Ao concluir este laboratório, você deve ter:

- [ ] Usado Kiro Spec para gerar a estrutura IAM completa
- [ ] Revisado requisitos, design e tarefas antes da geração de código
- [ ] 3 IAM users: `juliana.santos`, `rafael.oliveira`, `lucas.estagiario`
- [ ] 3 IAM groups: `technova-developers`, `technova-platform-eng`, `technova-interns`
- [ ] 3+ custom policies com princípio do menor privilégio
- [ ] Deny explícito para estagiários
- [ ] 1 IAM role + instance profile para EC2
- [ ] Validado com checklist (sem `*`, com tags, com deny)
- [ ] Reflexão documentada em `spec-reflexao.md`
- [ ] Todos os recursos destruídos com `terraform destroy`

---

*Neste lab você experimentou o Spec-Driven na prática: descreveu o cenário em linguagem natural, o Kiro planejou e gerou o código, e você validou com o checklist de segurança. Este é o workflow profissional — IA como ferramenta, você como decisor.*
