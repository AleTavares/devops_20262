# Trabalho de Fixação (TF) — Aula 03: Terraform + IAM Completo

## Desafio

Crie uma estrutura completa de IAM para a TechNova usando Terraform, demonstrando domínio de groups, users, policies com menor privilégio, e service roles. Publique via Pull Request no repositório da disciplina.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | 1 semana a partir da data da aula |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork** | `entregas/aula-03/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com link do repositório + evidências |
| **Arquivos do projeto** | No repositório `unifaat-devops-portfolio`, pasta `aula-03/` |
| **Execução do Lab** | Realizada no **AWS Academy Learner Lab** — o professor confere a nota e o percentual de execução |

> **Avaliação no AWS Academy:** Além do código entregue via PR, o professor verifica no **AWS Academy** a **nota** e o **percentual de execução** do seu laboratório. Execute o Lab completo no ambiente do Academy — a atividade prática no Learner Lab faz parte da avaliação do TF.

### Como Entregar via Pull Request

1. Faça um **fork** do repositório da disciplina (se ainda não fez)
2. Clone o seu fork localmente
3. Crie a pasta `entregas/aula-03/SEU-RA/`
4. Adicione **apenas** o arquivo `entrega.md` (modelo abaixo) — os arquivos do projeto ficam no `unifaat-devops-portfolio`
5. Faça commit e push para o seu fork
6. Abra um **Pull Request** para o repositório original

**Modelo do arquivo `entrega.md`:**

```markdown
# Entrega — Aula 03: Terraform + IAM

**Aluno:** [Seu nome completo]  
**RA:** [Seu RA]  
**Data:** [Data da entrega]

## Repositório

- URL: https://github.com/SEU-USUARIO/unifaat-devops-portfolio

## Evidências

- [ ] `providers.tf` com provider AWS configurado
- [ ] `main.tf` com users, groups e memberships
- [ ] `policies.tf` com mínimo 3 custom policies
- [ ] `roles.tf` com service role + instance profile
- [ ] `variables.tf` e `outputs.tf` configurados
- [ ] `terraform-plan-output.txt` com evidência do plano
- [ ] `README.md` com explicação do design e reflexão sobre menor privilégio
- [ ] Tags obrigatórias em todos os recursos
- [ ] `.gitignore` configurado (sem `.tfstate` no repositório)

## Evidência do Terraform Plan

[Cole aqui um trecho do output do `terraform plan` ou screenshot]
```

---

## Instruções

### 1. Acessar o Repositório Portfólio

Os arquivos do projeto desta aula ficam no seu repositório `unifaat-devops-portfolio`:

```bash
cd unifaat-devops-portfolio
git checkout main
git pull
```

### 2. Criar Branch de Desenvolvimento

```bash
git checkout -b feature/aula-03-terraform-iam
```

### 3. Criar a Pasta da Aula

```bash
mkdir -p aula-03
cd aula-03
```

---

## Especificação do Exercício

Implemente a seguinte estrutura IAM para a TechNova:

### 1. Dois Groups com separação de responsabilidades

| Group | Propósito |
|-------|-----------|
| `SEURA-technova-developers` | Devs que precisam de acesso S3 (leitura) |
| `SEURA-technova-platform-eng` | Engenheiros que gerenciam EC2 + S3 (acesso completo) |

### 2. Três Users distribuídos nos groups

| User | Group(s) |
|------|----------|
| `SEURA-juliana-dev` | developers |
| `SEURA-rafael-platform` | developers + platform-eng |
| `SEURA-lucas-intern` | developers (somente leitura via policy restritiva) |

### 3. Custom Policies seguindo menor privilégio

| Policy | Permissões | Anexada a |
|--------|-----------|-----------|
| `SEURA-technova-s3-read` | `s3:GetObject`, `s3:ListBucket` em `technova-*` | Group: developers |
| `SEURA-technova-ec2-s3-full` | EC2 Describe + Start/Stop (com condition tag) + S3 read/write | Group: platform-eng |
| `SEURA-technova-deny-destructive` | Deny explícito para `Delete*`, `Terminate*` | Group: developers (proteção extra) |

### 4. Um Service Role (EC2 → S3)

| Componente | Descrição |
|------------|-----------|
| Role | `SEURA-technova-ec2-role` — EC2 pode assumir |
| Trust Policy | `ec2.amazonaws.com` como Principal |
| Permissions Policy | Read/Write em `technova-app-data-*` |
| Instance Profile | `SEURA-technova-ec2-profile` |

### 5. Tags em TODOS os recursos

Todos os recursos devem ter:

```hcl
tags = {
  Project    = "TechNova"
  ManagedBy  = "Terraform"
  Aluno      = "SEU NOME"
  RA         = "SEU-RA"
  Disciplina = "DevOps - UniFAAT 2026-2"
  Aula       = "03"
}
```

### 6. `.gitignore` obrigatório

```
.terraform/
*.tfstate
*.tfstate.backup
.terraform.lock.hcl
*.tfvars
```

---

## Entregáveis

### No repositório `unifaat-devops-portfolio`, pasta `aula-03/`

| # | Arquivo | Conteúdo |
|---|---------|----------|
| 1 | `providers.tf` | Provider AWS (hashicorp/aws ~> 5.0, us-east-1) |
| 2 | `main.tf` | Users, Groups, Memberships |
| 3 | `policies.tf` | Custom policies (mínimo 3) + attachments |
| 4 | `roles.tf` | Service role + instance profile |
| 5 | `variables.tf` | Variáveis reutilizáveis (project_name, environment, aluno) |
| 6 | `outputs.tf` | Users, groups, policy ARNs, role ARN |
| 7 | `terraform-plan-output.txt` | Output do `terraform plan` (evidência) |
| 8 | `README.md` | Explicação do design (veja template abaixo) |
| 9 | `.gitignore` | Exclusões obrigatórias |

### No fork do repositório da disciplina (via Pull Request)

| # | Arquivo | Conteúdo |
|---|---------|----------|
| 1 | `entregas/aula-03/SEU-RA/entrega.md` | Link do portfólio + evidências |

---

## Template do README.md da entrega

```markdown
# Aula 03 — Terraform + IAM | SEU NOME (RA)

## Design da Estrutura IAM

[Explique as decisões de design:
- Por que criou esses groups?
- Como separou as responsabilidades?
- Quais ações cada policy permite e por quê?]

## Princípio do Menor Privilégio

[Explique com suas palavras:
- O que é o princípio?
- Dê 2 exemplos de como aplicou no seu código
- O que aconteceria se você usasse AmazonS3FullAccess em vez da sua custom policy?]

## Diagrama de Permissões

```
[Desenhe o fluxo: User → Group → Policy → Recursos]
[Inclua o Role → Instance Profile → EC2 → S3]
```

## Comandos Utilizados

```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

## Reflexão

[Compare a criação manual de IAM pelo Console AWS vs. Terraform.
Qual abordagem é mais segura e auditável para uma equipe? Por quê?]
```

---

## Publicar e Criar o Pull Request

### 1 — Merge e push no `unifaat-devops-portfolio`

```bash
# Na raiz do portfólio
git add aula-03/
git commit -m "feat(aula-03): IAM completo com Terraform

- providers.tf, main.tf, policies.tf, roles.tf
- 2 groups, 3 users, 3 custom policies, 1 service role
- terraform-plan-output.txt com evidência
- Aluno: SEU NOME (RA: SEU-RA)"

git checkout main
git merge feature/aula-03-terraform-iam
git push origin main
git push origin feature/aula-03-terraform-iam
```

### 2 — Registrar entrega no fork da disciplina

```bash
# No repositório do fork da disciplina
cd /caminho/para/seu-fork-da-disciplina

git checkout -b entregas/aula-03/SEU-RA
mkdir -p entregas/aula-03/SEU-RA
```

Crie o arquivo `entrega.md` (modelo na seção de Informações de Entrega) e então:

```bash
git add entregas/aula-03/SEU-RA/entrega.md
git commit -m "feat(aula-03): entrega TF - SEU NOME (RA: SEU-RA)"
git push -u origin entregas/aula-03/SEU-RA
```

Abra o Pull Request no GitHub com:
- **Título:** `[Aula 03] RA: SEU-RA - SEU NOME`
- **Base:** `main`
- **Compare:** `entregas/aula-03/SEU-RA`

---

## Critérios de Avaliação

| # | Critério | Peso | Verificação |
|---|----------|------|-------------|
| 1 | **Execução no AWS Academy** | **20%** | Nota e percentual de execução do laboratório conferidos pelo professor no AWS Academy |
| 2 | PR aberto corretamente em `entregas/aula-03/RA/` | 5% | Branch e path corretos |
| 3 | `providers.tf` com provider AWS configurado | 5% | hashicorp/aws, us-east-1 |
| 4 | Mínimo 2 IAM groups com separação de responsabilidades | 10% | Nomes distintos, propósitos claros |
| 5 | Mínimo 3 IAM users distribuídos entre groups | 5% | Memberships declaradas |
| 6 | Mínimo 3 custom policies com menor privilégio | 15% | Actions específicas, Resources limitados |
| 7 | Policies demonstram uso de Conditions ou Deny explícito | 10% | Pelo menos 1 policy com Condition ou Deny |
| 8 | Service role para EC2 com trust policy e instance profile | 10% | assume_role_policy + policy_attachment + profile |
| 9 | Tags obrigatórias em todos os recursos | 5% | Project, ManagedBy, Aluno, RA |
| 10 | `terraform-plan-output.txt` com evidência do plano | 10% | Plan mostrando recursos a serem criados |
| 11 | README.md com explicação do design (não template) | 5% | Reflexões reais sobre menor privilégio |

**Total:** 100%

---

## Regras Importantes

1. **⚠️ `terraform destroy` após testar** — Nunca deixe recursos ativos após capturar evidência
2. **⚠️ Nunca commite `*.tfstate`** — O `.gitignore` deve excluir arquivos de estado
3. **⚠️ Prefixe todos os nomes com seu RA** — Evita conflitos com colegas na mesma conta
4. **⚠️ Use `terraform validate`** antes do plan — Detecta erros de sintaxe antecipadamente
5. **⚠️ Use `terraform fmt`** — Formata os arquivos `.tf` automaticamente

---

## Dicas

- Use o lab como referência para a estrutura dos arquivos
- Nomes de recursos IAM não precisam ser globalmente únicos (diferente de S3), mas use prefixo pessoal por organização
- A policy de **Deny explícito** sempre prevalece sobre Allow — use para garantir segurança
- Consulte o [IAM Actions Reference](https://docs.aws.amazon.com/service-authorization/latest/reference/) para nomes exatos das actions
- Se tiver erro `AccessDenied` para criar IAM, verifique se suas credenciais têm `IAMFullAccess`
- IAM é gratuito — você pode testar quantas vezes precisar sem custo

---

*Ao concluir este trabalho, seu portfólio demonstra competência em IaC (Terraform) e segurança cloud (IAM). Você saiu do uso de credenciais root para um modelo de menor privilégio gerenciado como código — uma habilidade essencial para qualquer engenheiro DevOps.*
