# Trabalho em Aula — Aula 03: Terraform e Segurança AWS

**Aluno:** Felipe Damasceno
**RA:** 6325128  
**Data:** 27/08/2026

---

## Parte 1 — Análise de Riscos: Infraestrutura Manual

### Riscos e soluções com Terraform

| # | Risco (infraestrutura manual) | Como Terraform resolve |
|---|-------------------------------|------------------------|
| 1 | **Sem rastreabilidade de mudanças:** Quando um membro da equipe sai da empresa, ninguém sabe o que ele criou, modificou ou deletou no console. Recursos órfãos ficam rodando gerando custo, e nenhum histórico de alterações existe. | O código Terraform fica versionado no Git. Todo `terraform apply` é registrado, e o `terraform.tfstate` mapeia exatamente o que existe. A saída de um colaborador não apaga o conhecimento da infraestrutura. |
| 2 | **Impossibilidade de replicar ambientes:** Recriar um ambiente idêntico (staging/produção) manualmente é propenso a erro humano — alguém esquece uma regra de security group, uma variável de ambiente, ou usa um tamanho de instância diferente. Os ambientes ficam divergentes ao longo do tempo. | Com Terraform e uso de `workspaces` ou módulos parametrizados, o mesmo código cria ambientes idênticos com variáveis diferentes. `terraform apply -var-file=staging.tfvars` garante paridade total entre ambientes. |
| 3 | **Falha em auditoria de compliance:** Auditores precisam saber quem criou cada recurso, quando e com qual configuração. No console, essa informação depende do CloudTrail (que pode não estar habilitado) e não mostra a intenção ou o contexto da mudança. | A infraestrutura como código é, por si só, documentação auditável. O histórico do Git mostra quem fez cada alteração, quando e por quê (via commit message). Políticas de aprovação via Pull Request adicionam camada de revisão. |
| 4 | **Dificuldade de diagnóstico em incidentes noturnos:** Às 3h da manhã, identificar o que foi alterado manualmente horas antes de uma falha é quase impossível sem documentação. O engenheiro de plantão precisa investigar o console recurso por recurso. | O estado desejado está no código. O `terraform plan` mostra imediatamente qualquer desvio entre o código e o estado real (`drift detection`). Revertendo o commit e aplicando novamente, o ambiente volta ao estado anterior de forma controlada. |
| 5 | **Falta de governança com crescimento de equipe:** Com 4 pessoas, um acordo informal funciona. Com 20, múltiplas pessoas fazendo mudanças simultâneas no console causam conflitos, recursos duplicados e sobrescrita de configurações umas das outras, sem nenhum processo de aprovação. | O fluxo de trabalho via Git (Pull Requests, code review, CI/CD com `terraform plan` automatizado) cria um processo formal e escalável. O Terraform Cloud/Enterprise oferece ainda state locking, impedindo aplicações simultâneas e conflitos de estado. |

---

## Parte 2 — Auditoria de Segurança: Design de IAM

### Estrutura IAM proposta

```
AWS Account Root (NUNCA usar diretamente)
│
├── Group: Billing-ReadOnly
│   ├── Users: Carlos Mendes (CTO)
│   └── Policy: BillingReadOnlyPolicy
│       (ações: aws-portal:ViewBilling, ce:GetCostAndUsage,
│               ce:GetCostForecast, budgets:ViewBudget)
│
├── Group: Developers
│   ├── Users: Juliana Santos (Dev Sênior)
│   └── Policy: DeveloperAccessPolicy
│       (ações: s3:GetObject, s3:PutObject, s3:ListBucket,
│               s3:DeleteObject, ec2:DescribeInstances,
│               ec2:DescribeSecurityGroups, ec2:DescribeVpcs)
│
├── Group: Platform-Engineering
│   ├── Users: Rafael Oliveira (Platform Eng)
│   └── Policy: PlatformEngineeringPolicy
│       (ações: ec2:*, s3:*, vpc-related: ec2:CreateVpc,
│               ec2:DeleteVpc, ec2:ModifyVpcAttribute,
│               iam:GetPolicy, iam:ListRoles, iam:ListUsers,
│               iam:GetRole — somente leitura em IAM)
│
├── Group: Interns
│   ├── Users: Lucas (Estagiário)
│   └── Policy: S3ReadOnlyPolicy
│       (ações: s3:GetObject, s3:ListBucket — somente leitura,
│               restrito a buckets não-sensíveis via Condition)
│
└── Role: TechNovaAppRole
    ├── Trust Policy: Serviço EC2 (ec2.amazonaws.com) pode assumir
    └── Permissions: AppDataAccessPolicy
        (ações: s3:GetObject, s3:PutObject, s3:DeleteObject,
                s3:ListBucket — restrito ao bucket technova-app-data
                via: "Resource": "arn:aws:s3:::technova-app-data/*")
```

### Violações do princípio do menor privilégio com AWS Managed Policies

1. **`AmazonS3FullAccess` para Juliana (Dev Sênior):** Essa managed policy concede `s3:*` em `*` (todos os buckets e objetos da conta). Juliana precisaria apenas de leitura/escrita em buckets específicos do projeto, sem permissão para criar ou deletar buckets, alterar políticas de bucket, configurar replicação ou modificar configurações de criptografia. Com `AmazonS3FullAccess`, ela poderia acidentalmente deletar um bucket de produção ou expor dados ao tornar um bucket público — ações completamente fora do escopo do seu cargo.

2. **`AmazonEC2FullAccess` para Juliana ou Lucas:** A managed policy `AmazonEC2FullAccess` dá permissão para iniciar, parar, terminar e modificar instâncias EC2, além de gerenciar security groups e key pairs. Juliana precisa apenas de `ec2:Describe*` (somente leitura). Lucas não deveria ter nenhum acesso a EC2. Qualquer um dos dois, com essa policy, poderia encerrar instâncias de produção, modificar regras de firewall abrindo portas críticas, ou provisionar instâncias de alto custo — violando diretamente o princípio do menor privilégio e criando riscos operacionais e financeiros sérios.
