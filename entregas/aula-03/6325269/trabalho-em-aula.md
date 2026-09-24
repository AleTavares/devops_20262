# Trabalho em Aula — Aula 03: Terraform e Segurança AWS

**Aluno:** Sirlande Martins
**RA:** 6325269
**Data:** 27/08/2026

## Parte 1 — Análise de Riscos: Infraestrutura Manual

### Riscos e soluções com Terraform

| # | Risco (infraestrutura manual) | Como Terraform resolve |
|---|---|---|
| 1 | Nenhuma documentação do que foi configurado (Carlos gastou 3h clicando no Console sem registrar nada) | O código `.tf` é a própria documentação — declarativo, versionado no Git, sempre atualizado |
| 2 | Recurso crítico deletado sem forma de recriar (estagiário apagou o bucket por engano) | `terraform apply` recria o recurso exatamente como estava a partir do código; nada depende de memória de quem clicou onde |
| 3 | Impossível reproduzir um ambiente idêntico rapidamente (staging para o investidor) | Os mesmos arquivos `.tf` (com variáveis) recriam o ambiente em minutos, em qualquer conta/região |
| 4 | Passos esquecidos entre configurações dependentes (esqueceu de abrir a porta 3000 no Security Group antes de subir o EC2) | Todos os recursos e suas dependências (VPC, SG, EC2) são declarados juntos; o Terraform resolve a ordem e nada fica de fora |
| 5 | Mudanças aplicadas direto em produção sem revisão por ninguém | Mudança de infra vira Pull Request com `terraform plan` anexado — revisão por pares antes do `apply` |

## Parte 2 — Auditoria de Segurança: Design de IAM

### Estrutura IAM proposta

```
AWS Account Root (NUNCA usar diretamente)
│
├── Group: billing-viewers
│   ├── Users: Carlos Mendes (CTO)
│   └── Policy: billing-readonly (ações: ce:Get*, aws-portal:View*Billing — visualizar billing e relatórios de custo)
│
├── Group: dev-senior
│   ├── Users: Juliana Santos
│   └── Policy: dev-s3-ec2-readonly (ações: s3:GetObject, s3:PutObject, s3:ListBucket no bucket technova-app-data; ec2:Describe* — somente leitura)
│
├── Group: platform-eng
│   ├── Users: Rafael Oliveira
│   └── Policy: platform-eng-access (ações: ec2:*, s3:*, VPC actions; iam:Get*, iam:List* — IAM apenas leitura)
│
├── Group: read-only
│   ├── Users: Lucas (Estagiário)
│   └── Policy: s3-readonly-app-data (ações: s3:GetObject, s3:ListBucket, apenas no bucket technova-app-data)
│
└── Role: technova-api-ec2-role
    ├── Trust Policy: serviço EC2 (ec2.amazonaws.com) pode assumir
    └── Permissions: s3:GetObject, s3:PutObject, apenas no bucket technova-app-data
```

### Violações de menor privilégio com Managed Policies

1. Dar `AmazonS3FullAccess` a Juliana para ela ler/escrever em `technova-app-data` também permitiria deletar qualquer outro bucket da conta — inclusive de outros projetos —, muito além do que seu trabalho exige.
2. Dar `AmazonEC2FullAccess` a Rafael para gerenciar instâncias também permitiria terminar/alterar instâncias e VPCs de produção de outras equipes, quando ele só precisa gerenciar os recursos do seu escopo.
