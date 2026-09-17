# Trabalho em Aula — Aula 03: Terraform e Segurança AWS

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 27/08/2026

## Parte 1 — Análise de Riscos: Infraestrutura Manual

### Riscos e soluções com Terraform

| # | Risco (infraestrutura manual) | Como Terraform resolve |
|---|-------------------------------|------------------------|
| 1 | **Conhecimento na cabeça de uma pessoa:** quando um membro sai da empresa, a infra provisionada "no clique" vira caixa-preta — ninguém sabe o que existe nem por quê. | A infra vira código versionado no Git: qualquer pessoa lê os `.tf` e entende o que existe. O histórico do repositório mostra quem mudou o quê e quando. |
| 2 | **Ambientes divergentes (staging ≠ produção):** recriar um ambiente idêntico à mão é lento e sempre escapa uma configuração, gerando o clássico "na minha máquina funciona". | O mesmo código aplicado com `workspaces`/variáveis gera ambientes idênticos e reproduzíveis. `terraform plan` prova a paridade antes de aplicar. |
| 3 | **Auditoria de compliance sem rastro:** no Console não há evidência do estado desejado nem de quem alterou; a auditoria vira arqueologia. | O código é a documentação viva e auditável; o `state` registra o estado real; o Git registra autoria e justificativa (Conventional Commits). |
| 4 | **Incidente às 3h da manhã:** recriar/corrigir recurso deletado por engano depende de memória e improviso, aumentando o downtime. | `terraform apply` recria o recurso ao estado declarado em minutos, de forma idempotente e sem depender de quem está de plantão. |
| 5 | **Escala da equipe (4 → 20 pessoas):** múltiplas mãos no Console geram conflitos, mudanças silenciosas e drift sem controle. | Fluxo de PR + review sobre o código: mudanças passam por revisão antes de virar realidade; `plan` no CI mostra o impacto e evita drift. |

## Parte 2 — Auditoria de Segurança: Design de IAM

### Estrutura IAM proposta

```
AWS Account Root (NUNCA usar diretamente)
│
├── Group: finance
│   ├── Users: carlos.mendes (CTO)
│   └── Policy: finance-billing-read
│       (ações: aws-portal:View*, ce:Get*/Describe*, cur:Describe* — apenas leitura de billing/custos)
│
├── Group: developers
│   ├── Users: juliana.santos (Dev Sênior)
│   └── Policy: developers-s3rw-ec2read
│       (ações: s3:GetObject/PutObject/ListBucket em buckets do time + ec2:Describe*)
│
├── Group: platform
│   ├── Users: rafael.oliveira (Platform Eng)
│   └── Policy: platform-manage
│       (ações: ec2:*, s3:*, ec2:*Vpc*/*Subnet*/*RouteTable* + iam:Get*/List* — IAM apenas leitura)
│
├── Group: interns
│   ├── Users: lucas (Estagiário)
│   └── Policy: interns-s3-readonly
│       (ações: s3:GetObject, s3:ListBucket — somente leitura; Deny explícito em s3:Delete*/Put*)
│
└── Role: technova-api-role
    ├── Trust Policy: Serviço ec2.amazonaws.com pode assumir (Instance Profile)
    └── Permissions: technova-api-s3rw
        (ações: s3:GetObject/PutObject/ListBucket restritas ao bucket technova-app-data)
```

**Racional:** permissões são atribuídas a **groups** (nunca direto ao user), e o serviço usa **role** com credenciais temporárias via Instance Profile — sem access keys estáticas no código. É exatamente a estrutura que implementamos com Terraform no `terraform-iam-lab`.

### Violações de menor privilégio com Managed Policies

1. **`AmazonS3FullAccess` no group `developers`:** a Juliana precisa ler/escrever nos buckets **do time**, mas a managed policy libera `s3:*` em **todos** os buckets da conta — incluindo deletar buckets de produção e alterar políticas de acesso. Uma custom policy restringe as ações (`Get/Put/List`) ao ARN dos buckets específicos.

2. **`AmazonS3ReadOnlyAccess` na role da API:** a API só deveria ler/escrever no bucket `technova-app-data`, mas a managed policy dá leitura em **todos** os buckets. Se a instância for comprometida, o atacante lê dados de qualquer bucket da conta. Uma custom policy com `Resource` no ARN do bucket específico limita o raio de impacto (blast radius).
