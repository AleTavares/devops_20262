# Trabalho em Aula — Aula 03: Terraform e Segurança AWS

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 24/08/2026

---

## Parte 1 — Análise de Riscos: Infraestrutura Manual

### Riscos e soluções com Terraform

| # | Risco (infraestrutura manual) | Como Terraform resolve |
|---|-------------------------------|------------------------|
| 1 | **Sem rastreabilidade:** ninguém sabe quem criou qual recurso, quando ou com quais configurações. O estagiário deletou o bucket e ninguém sabia o que recriar | Cada mudança vira um commit com autor, data e mensagem. O `git log` é o histórico completo de toda a infraestrutura — auditável por qualquer pessoa da equipe |
| 2 | **Sem reprodutibilidade:** para criar um ambiente idêntico (staging, disaster recovery), o processo começa do zero a cada vez, com risco de configurações divergentes | `terraform apply` recria a infraestrutura exatamente igual em qualquer conta AWS. O código é a documentação viva — staging e produção ficam idênticos |
| 3 | **Sem revisão por pares:** qualquer pessoa com acesso ao Console pode alterar infraestrutura sem nenhuma aprovação — abre caminho para erros e mudanças não autorizadas | Mudanças de infraestrutura viram Pull Requests. Um colega revisa o `terraform plan` antes de qualquer `apply` — o mesmo fluxo que código de aplicação |
| 4 | **Escala mal com o crescimento da equipe:** com 4 pessoas dá para gerenciar. Com 20 pessoas e múltiplos ambientes, a coordenação por e-mail e prints de tela se torna caótica | O repositório é a fonte única de verdade. Qualquer dev clona, roda `plan` para ver o estado atual e propõe mudanças via branch — processo padronizado independente do tamanho da equipe |
| 5 | **Dependência de pessoas específicas:** se Carlos (único que sabe criar a VPC) tira férias ou sai da empresa, a infraestrutura fica "órfã" sem documentação de como foi criada | Com Terraform, o conhecimento está no código. Qualquer engenheiro com acesso ao repositório consegue entender, reproduzir e evoluir a infraestrutura sem depender de uma pessoa específica |

---

## Parte 2 — Auditoria de Segurança: Design de IAM

### Estrutura IAM proposta

```
AWS Account Root (NUNCA usar diretamente)
│
├── Group: technova-developers
│   ├── Users: juliana-dev, lucas-intern, rafael-platform
│   ├── Policy: technova-s3-read
│   │   └── Allow: s3:GetObject, s3:ListBucket → arn:aws:s3:::technova-*
│   │   └── Condition: s3:prefix = "app/*" (restringe listagem ao prefixo da app)
│   └── Policy: technova-deny-destructive
│       └── Deny: s3:DeleteBucket, ec2:TerminateInstances, iam:DeleteUser, ...
│
├── Group: technova-platform-eng
│   ├── Users: rafael-platform
│   └── Policy: technova-ec2-s3-full
│       ├── Allow: ec2:Describe* → *
│       ├── Allow: ec2:StartInstances, StopInstances → instâncias com tag Project=TechNova
│       └── Allow: s3:GetObject, s3:PutObject, s3:ListBucket → technova-*
│
└── Role: technova-ec2-role
    ├── Trust Policy: ec2.amazonaws.com pode assumir (sts:AssumeRole)
    ├── Policy: technova-ec2-s3-app-data
    │   └── Allow: s3:GetObject, s3:PutObject → technova-app-data-*
    └── Instance Profile: technova-ec2-profile
        └── Anexado às instâncias EC2 para acesso automático sem access keys
```

**Decisões de design:**

- **Carlos (CTO):** só precisa ver billing → `aws-portal:ViewBilling` em um grupo separado `cto-billing`. Não recebe acesso a EC2, S3 ou IAM operacionais — ele gerencia pessoas, não infraestrutura
- **Juliana (Dev Sênior):** grupo `developers` → leitura S3 restrita ao prefixo `app/` + Deny destrutivo
- **Rafael (Platform Eng):** dois grupos — `developers` (para visibilidade S3) + `platform-eng` (para gerenciar EC2 com restrição por tag)
- **Lucas (Estagiário):** grupo `developers` — mesma policy de leitura, mas o Deny destrutivo bloqueia qualquer ação irreversível que ele tente
- **API TechNova (EC2):** Service Role com credenciais temporárias automáticas — sem access keys fixas no código

### Violações de menor privilégio com AWS Managed Policies

**1. `AmazonS3FullAccess` para o grupo developers:**

Se eu atribuísse `AmazonS3FullAccess` ao grupo `developers` em vez da custom policy `s3_read`:
- Lucas (estagiário) poderia executar `s3:DeleteBucket` em qualquer bucket da conta — incluindo backups de produção
- Juliana poderia fazer `s3:PutObject` em buckets de outros projetos na mesma conta
- A permissão seria válida para **todos os buckets** da conta, não apenas os `technova-*`
- O Deny da policy `deny_destructive` cobriria parcialmente, mas não todos os casos — `s3:PutBucketAcl`, `s3:PutEncryptionConfiguration` continuariam permitidos

**2. `AmazonEC2FullAccess` para o grupo platform-eng:**

Se eu atribuísse `AmazonEC2FullAccess` em vez da custom policy `ec2_s3_full`:
- Rafael poderia executar `ec2:TerminateInstances` em **qualquer instância** da conta, sem restrição de tag
- Poderia deletar VPCs, Security Groups e Subnets de outros projetos ou ambientes (produção) que compartilham a mesma conta AWS
- Poderia criar instâncias sem limite — potencial vetor de escalada de custos ou uso indevido
- A custom policy `ec2_s3_full` restringe Start/Stop a instâncias com `Project=TechNova`, protegendo recursos de outros projetos na conta

---

*Esta atividade foi a base para o TF desta aula: a estrutura IAM desenhada aqui foi implementada exatamente em Terraform, com todos os recursos versionados no repositório e auditáveis por Pull Request.*
