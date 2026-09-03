# Trabalho em Aula — Aula 03: Terraform e Segurança AWS

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 29/08/2026

## Parte 1 — Análise de Riscos: Infraestrutura Manual

### Riscos e soluções com Terraform

| # | Risco (infraestrutura manual) | Como Terraform resolve |
|---|-------------------------------|------------------------|
| 1 | **Conhecimento tribal / saída de funcionário** — quem clicou e montou a infra leva esse conhecimento junto quando sai da empresa; ninguém mais sabe reproduzir o ambiente do zero. | A infra vira **código versionado no Git** (`.tf` files), legível e revisável por qualquer pessoa da equipe — não depende da memória de quem apertou os botões no Console. |
| 2 | **Ambientes divergentes (staging vs. produção)** — cada ambiente é montado manualmente em momentos diferentes e nunca fica 100% igual (config drift), gerando bugs que só aparecem em produção. | O **mesmo módulo/config** é aplicado aos dois ambientes, variando só por `variables.tf`/`.tfvars` (ex.: workspaces), garantindo paridade real entre staging e produção. |
| 3 | **Auditoria de compliance** — não existe registro confiável de quem criou cada recurso, quando, ou por qual motivo; na melhor das hipóteses há um print de tela desatualizado. | O **state file** + o **histórico do Git** (autor, data, mensagem de commit, Pull Request revisado) formam uma trilha de auditoria completa: dá pra provar quem autorizou cada permissão e por quê. |
| 4 | **Incidente às 3h da manhã** — algo para de funcionar e ninguém sabe o que mudou, porque as mudanças foram cliques manuais não documentados. | `terraform plan` mostra o **diff exato** entre o estado atual e o desejado antes de qualquer mudança; o incidente pode ser correlacionado com o último `apply`/commit, cortando o tempo de troubleshooting de horas para minutos. |
| 5 | **Equipe cresce de 4 para 20 pessoas** — mais gente com acesso de clique no Console significa mais erro humano e mais gente com permissão de deletar algo em produção por engano (exatamente o caso do estagiário que apagou o bucket no TA). | Mudanças de infra passam a exigir **Pull Request revisado** antes do `apply`, e o acesso direto ao Console pode ser restrito via IAM de menor privilégio — só o pipeline de CI/CD aplica mudanças, reduzindo a superfície de erro humano. |

---

## Parte 2 — Auditoria de Segurança: Design de IAM

### Estrutura IAM proposta

```
AWS Account Root (NUNCA usar diretamente)
│
├── Group: technova-finance
│   ├── Users: Carlos Mendes (CTO)
│   └── Policy: technova-billing-read
│       (ações: aws-portal:ViewBilling, ce:GetCostAndUsage, ce:GetCostForecast —
│        somente visualização de billing/custos, sem acesso a nenhum recurso da conta)
│
├── Group: technova-developers
│   ├── Users: Juliana Santos (Dev Sênior)
│   └── Policy: technova-dev-s3-ec2
│       (ações: s3:GetObject / s3:PutObject / s3:ListBucket em technova-*,
│        ec2:Describe* — lê/escreve dados, mas não inicia, para nem termina instâncias)
│
├── Group: technova-platform-eng
│   ├── Users: Rafael Oliveira (Platform Eng)
│   └── Policy: technova-platform-full
│       (ações: gerenciamento completo de EC2 — Run/Start/Stop/Terminate/Security Groups,
│        S3 read/write em technova-*, gerenciamento de VPC,
│        IAM somente leitura — iam:Get*/iam:List*, sem Create/Delete/Attach)
│
├── Group: technova-interns
│   ├── Users: Lucas (Estagiário)
│   └── Policy: technova-s3-readonly
│       (ações: s3:GetObject / s3:ListBucket em technova-* — sem PutObject, sem DeleteObject)
│
└── Role: technova-api-ec2-role  (para o serviço "API TechNova")
    ├── Trust Policy: Serviço ec2.amazonaws.com pode assumir (sts:AssumeRole)
    └── Permissions: technova-api-permissions
        (ações: s3:GetObject / s3:PutObject / s3:ListBucket,
         restritas ao bucket technova-app-data — credenciais temporárias via Instance Profile,
         sem access keys fixas gravadas na instância)
```

**Por que separar assim:**

- Cada group corresponde a uma **responsabilidade**, não a uma pessoa — se amanhã entrar um segundo Platform Engineer, ele só precisa ser adicionado ao membership do group `technova-platform-eng`, sem reescrever nenhuma policy.
- O estagiário (Lucas) tem seu próprio group **read-only**, separado dos developers, porque ele não deveria ter `PutObject` — diferente de Juliana, que precisa escrever em S3 no dia a dia.
- Rafael, como Platform Eng, precisa **ler** IAM (para saber o que já existe antes de provisionar algo novo), mas não precisa **criar/deletar** usuários ou policies — essa ação fica reservada para quem administra a conta, evitando que ele se autoconceda mais permissões.
- O serviço (API TechNova) usa um **Role**, não um usuário IAM com access key fixa: a instância EC2 assume o role e recebe credenciais temporárias, então não existe uma chave de longa duração vazando em variável de ambiente ou log.

### Violações de menor privilégio com Managed Policies

1. **Lucas (Estagiário) com `AmazonS3FullAccess` em vez da policy custom `technova-s3-readonly`:** ele passaria a ter `s3:*` — incluindo `DeleteObject` e `DeleteBucket` — sobre **todos os buckets da conta**, não só os `technova-*`. É literalmente o incidente descrito no TA (estagiário apagou um bucket sem querer), só que pior: com a managed policy, o erro não fica restrito aos buckets da TechNova, pode atingir dados de qualquer outro projeto na mesma conta.
2. **Rafael (Platform Eng) com `IAMFullAccess` em vez de uma policy read-only (`iam:Get*`/`iam:List*`):** ele conseguiria criar um novo usuário IAM, anexar `AdministratorAccess` a esse usuário (ou a si mesmo) e efetivamente virar root da conta. Isso é uma escalada de privilégio silenciosa — a policy read-only elimina esse caminho porque `iam:CreateUser`/`iam:AttachUserPolicy` simplesmente não estão na lista de ações permitidas.
