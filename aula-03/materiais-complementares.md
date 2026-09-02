# Materiais Complementares — Aula 03: Terraform e Segurança AWS (IAM)

## 📚 Documentação Oficial

### Terraform

- **[Terraform Documentation](https://developer.hashicorp.com/terraform/docs)** — Documentação oficial completa
- **[Terraform Language (HCL)](https://developer.hashicorp.com/terraform/language)** — Referência da linguagem: blocos, expressões, funções
- **[Terraform CLI Commands](https://developer.hashicorp.com/terraform/cli/commands)** — Todos os comandos (init, plan, apply, destroy)
- **[Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)** — Provider AWS com todos os recursos
- **[S3 Bucket Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)** — Referência do `aws_s3_bucket`
- **[Get Started - AWS](https://developer.hashicorp.com/terraform/tutorials/aws-get-started)** — Tutorial oficial passo a passo

### AWS IAM

- **[IAM User Guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/)** — Documentação oficial completa do IAM
- **[IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)** — Boas práticas de segurança
- **[IAM Policy Reference](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies.html)** — Referência da linguagem de policies
- **[IAM Actions Reference](https://docs.aws.amazon.com/service-authorization/latest/reference/)** — Lista de todas as actions por serviço
- **[IAM Policy Simulator](https://policysim.aws.amazon.com/)** — Testar policies antes de aplicar
- **[Principle of Least Privilege](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html#grant-least-privilege)** — Guia oficial

### Terraform + IAM

- **[aws_iam_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user)** — Criar users
- **[aws_iam_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group)** — Criar groups
- **[aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)** — Criar roles
- **[aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)** — Criar policies
- **[aws_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile)** — Instance Profile

---

## 🎥 Vídeos Recomendados

### Em Português

| Vídeo | Canal | Duração | Tópico |
|-------|-------|---------|--------|
| [Terraform em 10 minutos](https://www.youtube.com/watch?v=bYvdJKTwx_I) | Full Cycle | ~15 min | Introdução ao Terraform |
| [Terraform do Zero na AWS](https://www.youtube.com/watch?v=4FellihAcV8) | Fabricio Veronez | ~45 min | Tutorial completo para iniciantes |
| [Infraestrutura como Código](https://www.youtube.com/watch?v=S-nBkPLHiDM) | LINUXtips | ~30 min | Conceito de IaC |
| [Terraform: Primeiros Passos](https://www.youtube.com/watch?v=bIPF_hzmQGE) | Cod3r | ~20 min | Instalação e prática |
| [AWS IAM do Zero](https://www.youtube.com/watch?v=y7m6gHQGLcA) | Fabricio Veronez | ~40 min | IAM para iniciantes |
| [Segurança na AWS com IAM](https://www.youtube.com/watch?v=UKsVCJyNM2A) | LINUXtips | ~35 min | Users, groups, roles na prática |
| [Terraform + IAM](https://www.youtube.com/watch?v=o2BSAJPyqJQ) | Full Cycle | ~30 min | Gerenciando IAM com Terraform |
| [Princípio do Menor Privilégio](https://www.youtube.com/watch?v=3iWjXbMo0GQ) | Cloud Treinamentos | ~20 min | Explicação detalhada |

### Em Inglês (com legendas)

| Vídeo | Canal | Duração | Tópico |
|-------|-------|---------|--------|
| [Terraform in 100 Seconds](https://www.youtube.com/watch?v=tomUWcQ0P3k) | Fireship | ~2 min | Explicação ultra-rápida |
| [Terraform Course for Beginners](https://www.youtube.com/watch?v=SLB_c_ayRMo) | freeCodeCamp | ~2.5h | Curso completo gratuito |
| [Terraform Explained](https://www.youtube.com/watch?v=HmxkYNv1ksg) | TechWorld with Nana | ~15 min | Conceitos fundamentais |
| [AWS IAM Core Concepts](https://www.youtube.com/watch?v=iYAB_brQ2xE) | Be A Better Dev | ~15 min | Conceitos do IAM |
| [IAM Policies Explained](https://www.youtube.com/watch?v=YQsK4MtsELU) | Stephane Maarek | ~20 min | Policies e JSON |
| [AWS Security Essentials](https://www.youtube.com/watch?v=Lh_4t5pG6MA) | freeCodeCamp | ~2h | Curso completo segurança |

---

## 📋 Cheat Sheets

### Terraform CLI

| Comando | Descrição |
|---------|-----------|
| `terraform init` | Inicializa projeto, baixa plugins |
| `terraform plan` | Mostra mudanças planejadas (dry-run) |
| `terraform apply` | Aplica mudanças |
| `terraform destroy` | Remove todos os recursos |
| `terraform fmt` | Formata arquivos .tf |
| `terraform validate` | Valida sintaxe |
| `terraform show` | Mostra estado atual |
| `terraform output` | Exibe outputs definidos |
| `terraform state list` | Lista recursos no state |

### IAM Policy Actions (mais comuns)

| Serviço | Ação | Descrição |
|---------|------|-----------|
| S3 | `s3:GetObject` | Ler um objeto de um bucket |
| S3 | `s3:PutObject` | Escrever um objeto |
| S3 | `s3:DeleteObject` | Deletar um objeto |
| S3 | `s3:ListBucket` | Listar objetos em um bucket |
| EC2 | `ec2:DescribeInstances` | Visualizar instâncias |
| EC2 | `ec2:StartInstances` | Iniciar instâncias |
| EC2 | `ec2:StopInstances` | Parar instâncias |
| EC2 | `ec2:TerminateInstances` | Encerrar (deletar) instâncias |
| IAM | `iam:CreateUser` | Criar um user |
| IAM | `iam:DeleteUser` | Deletar um user |
| IAM | `iam:AttachUserPolicy` | Anexar policy a user |

### Formato de ARN (Amazon Resource Name)

```
arn:aws:SERVIÇO:REGIÃO:CONTA:RECURSO

Exemplos:
arn:aws:s3:::meu-bucket                    → Bucket S3
arn:aws:s3:::meu-bucket/*                  → Objetos dentro do bucket
arn:aws:ec2:us-east-1:123456:instance/*    → Todas EC2 na região
arn:aws:iam::123456:user/juliana           → User IAM (global)
```

### Template de Policy JSON

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "NomeDescritivo",
      "Effect": "Allow",
      "Action": ["servico:Acao1", "servico:Acao2"],
      "Resource": ["arn:aws:servico:regiao:conta:recurso"],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    }
  ]
}
```

### Terraform IAM Resources — Referência Rápida

| Recurso | Propósito |
|---------|-----------|
| `aws_iam_user` | Criar user |
| `aws_iam_group` | Criar group |
| `aws_iam_group_membership` | Users → Group |
| `aws_iam_policy` | Criar policy customizada |
| `aws_iam_group_policy_attachment` | Policy → Group |
| `aws_iam_role` | Criar role |
| `aws_iam_role_policy_attachment` | Policy → Role |
| `aws_iam_instance_profile` | Profile para EC2 |

---

## 🛠️ Ferramentas Úteis

### IDEs e Extensões

- **[VS Code Terraform Extension](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)** — Autocompletar, validação, formatação (oficial HashiCorp)
- **[VS Code AWS Toolkit](https://marketplace.visualstudio.com/items?itemName=AmazonWebServices.aws-toolkit-vscode)** — Integração AWS no VS Code

### Validação e Segurança

- **[terraform fmt](https://developer.hashicorp.com/terraform/cli/commands/fmt)** — Formatação automática
- **[terraform validate](https://developer.hashicorp.com/terraform/cli/commands/validate)** — Validação de sintaxe
- **[tflint](https://github.com/terraform-linters/tflint)** — Linter para Terraform
- **[tfsec](https://github.com/aquasecurity/tfsec)** — Scanner de segurança para Terraform
- **[checkov](https://www.checkov.io/)** — Análise estática de segurança para IaC
- **[IAM Policy Simulator](https://policysim.aws.amazon.com/)** — Simula permissões
- **[IAM Access Analyzer](https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html)** — Identifica acessos externos
- **[AWS Policy Generator](https://awspolicygen.s3.amazonaws.com/policygen.html)** — Gerador visual de policies

### Gerenciamento AWS

- **[AWS Console](https://console.aws.amazon.com/)** — Interface web (para verificação visual)
- **[AWS CloudShell](https://aws.amazon.com/cloudshell/)** — Terminal no navegador com AWS CLI
- **[AWS Cost Explorer](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/)** — Monitorar custos
- **[AWS CloudTrail](https://aws.amazon.com/cloudtrail/)** — Registra todas as chamadas de API

---

## 📖 Artigos e Guias

### Terraform

- **[Why Infrastructure as Code?](https://developer.hashicorp.com/terraform/intro)** — Por que IaC importa
- **[Terraform vs. CloudFormation vs. Pulumi](https://developer.hashicorp.com/terraform/intro/vs)** — Comparação de ferramentas
- **[Terraform State Explained](https://developer.hashicorp.com/terraform/language/state)** — Documentação do state
- **[Terraform Best Practices](https://www.terraform-best-practices.com/)** — Guia da comunidade

### Segurança e IAM

- **[AWS Security Best Practices](https://docs.aws.amazon.com/security/)** — Hub de segurança AWS
- **[AWS Well-Architected - Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html)** — Pilar de Segurança
- **[AWS IAM Security Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)** — 15 boas práticas oficiais
- **[Least Privilege Access Guide](https://docs.aws.amazon.com/wellarchitected/latest/framework/sec_permissions_least_privileges.html)** — Guia detalhado
- **[GitGuardian State of Secrets Sprawl](https://www.gitguardian.com/state-of-secrets-sprawl-on-github-2023)** — Relatório sobre credenciais vazadas

---

## 🎯 Prática Extra

Se quiser praticar mais:

1. **Crie múltiplos buckets** — Adicione um segundo `resource "aws_s3_bucket"` e observe o Terraform gerenciar ambos

2. **Teste drift detection** — Após `apply`, altere uma tag manualmente no Console AWS e execute `terraform plan` para ver o Terraform detectar a diferença

3. **Crie um role para Lambda** — Similar ao role para EC2:
   ```hcl
   resource "aws_iam_role" "lambda_role" {
     name = "technova-lambda-role"
     assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [{
         Effect    = "Allow"
         Principal = { Service = "lambda.amazonaws.com" }
         Action    = "sts:AssumeRole"
       }]
     })
   }
   ```

4. **Use Conditions** — Restrinja ações por região:
   ```json
   "Condition": {
     "StringEquals": {
       "aws:RequestedRegion": "us-east-1"
     }
   }
   ```

5. **Explore o IAM Policy Simulator** — Teste se suas policies permitem ou negam ações específicas

6. **Adicione policy de MFA** — Force MFA para ações sensíveis:
   ```json
   {
     "Sid": "DenyWithoutMFA",
     "Effect": "Deny",
     "Action": ["iam:*", "ec2:TerminateInstances"],
     "Resource": "*",
     "Condition": {
       "BoolIfExists": { "aws:MultiFactorAuthPresent": "false" }
     }
   }
   ```

---

## 💰 AWS Free Tier — Informações Importantes

### Recursos desta aula:

| Serviço | Custo | Limite |
|---------|-------|--------|
| **S3** | 12 meses grátis | 5 GB, 20.000 GET, 2.000 PUT/mês |
| **IAM** | Sempre gratuito | Sem limites (users, groups, roles, policies) |

### Dicas para evitar cobranças:

1. ✅ Sempre execute `terraform destroy` após os labs
2. ✅ Configure **AWS Budgets** para alertas de custo (ex: alerta se > $1)
3. ✅ Verifique o **Cost Explorer** semanalmente
4. ✅ Use apenas `us-east-1` (mais recursos Free Tier disponíveis)

---

## 🔗 Conexão com Próximas Aulas

| Aula | Tópico | Como se conecta |
|------|--------|-----------------|
| Aula 04 | EC2 e Networking | Usar Instance Profile + Role para EC2 acessar S3 |
| Aula 05 | RDS e Banco de Dados | Policies para acesso ao RDS |
| Aula 06 | Terraform Avançado | Remote state (S3 + DynamoDB), modules |
| Aula 07 | CI/CD | OIDC Role para GitHub Actions sem access keys |

---

## 📝 Referência: Docker Compose → Terraform

| Aspecto | Docker Compose | Terraform |
|---------|----------------|-----------|
| Arquivo | `docker-compose.yml` | `main.tf` |
| Linguagem | YAML | HCL |
| Escopo | Containers locais | Recursos na nuvem |
| Criar | `docker compose up` | `terraform apply` |
| Destruir | `docker compose down` | `terraform destroy` |
| Estado | Docker Engine | `terraform.tfstate` |
| Preview | — | `terraform plan` |
| Idempotente | Sim | Sim |
| Versionável | Sim (Git) | Sim (Git) |

---

*Estes materiais complementam o conteúdo da aula. Dedique tempo para explorar os tutoriais do HashiCorp Learn e o IAM Policy Simulator — eles reforçam os conceitos de forma prática. Na Aula 04, usaremos os conceitos de Terraform e IAM para criar instâncias EC2 com acesso seguro a outros serviços AWS.*
