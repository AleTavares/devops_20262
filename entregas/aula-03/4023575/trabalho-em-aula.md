# Trabalho em Aula — Aula 03: Terraform e Segurança AWS
**Aluno:** Emilly Santos 
**Data:** 12/09/2026

## Parte 1 — Análise de Riscos: Infraestrutura Manual

### Riscos e soluções com Terraform

| # | Risco (infraestrutura manual) | Como Terraform resolve |
|---|-------------------------------|------------------------|
| 1 | Perda de conhecimento quando um membro da equipe sai (infraestrutura não documentada). | Infraestrutura como Código (IaC): toda a arquitetura fica declarada e versionada no Git. |
| 2 | Dificuldade e divergência ao replicar ambientes (staging vs. produção). | Reuso de módulos e uso de arquivos de variáveis (`.tfvars`) para recriar ambientes idênticos. |
| 3 | Impossibilidade de realizar auditoria de segurança e compliance sobre quem alterou um recurso. | Rastreabilidade total através do código no Git e comandos de `terraform plan` antes da aplicação. |
| 4 | Erro humano operacional em momentos de crise (ex: deleção acidental de recursos via Console). | Validação prévia de mudanças (`plan`) e gerenciamento de estado declarativo que impede alterações destrutivas não intencionais. |
| 5 | Gargalo operacional conforme a equipe cresce (falta de padronização nas alterações). | Processo automatizado de *Code Review* para infraestrutura via Pull Requests. |

---

## Parte 2 — Auditoria de Segurança: Design de IAM

### Estrutura IAM proposta

text
AWS Account Root (NUNCA usar diretamente)
│
├── Group: BillingViewers
│   ├── Users: Carlos Mendes (CTO)
│   └── Policy: AWSBudgetsReadOnlyAccess / JobFunction: Billing (ações: aws-portal:View*, budgets:View*)
│
├── Group: Developers
│   ├── Users: Juliana Santos (Dev Sênior)
│   └── Policy: CustomDevPolicy (ações: s3:GetObject, s3:PutObject, ec2:DescribeInstances)
│
├── Group: PlatformEngineers
│   ├── Users: Rafael Oliveira (Platform Eng)
│   └── Policy: CustomSysAdminPolicy (ações: ec2:, s3:, vpc:, iam:Get, iam:List*)
│
├── Group: ReadOnlyAuditors
│   ├── Users: Lucas (Estagiário)
│   └── Policy: CustomS3ReadOnly (ações: s3:GetObject, s3:ListBucket)
│
└── Role: EC2-RDS-Access-Role
├── Trust Policy: Serviço ec2.amazonaws.com pode assumir
└── Permissions: CustomS3AppPolicy (ações: s3:GetObject, s3:PutObject no bucket technova-app-data)


### Violações de menor privilégio com Managed Policies

1. **Uso de `AmazonS3FullAccess` para desenvolvedores:** Permitiria que usuários excluíssem buckets inteiros de produção (`s3:DeleteBucket`) ou alterassem políticas de acesso público, quando só precisavam ler/gravar objetos.
2. **Uso de `AdministratorAccess` para equipe de infraestrutura:** Concederia acesso total para deletar logs de auditoria (CloudTrail), alterar a conta Root e criar usuários com privilégios elevados sem supervisão.
