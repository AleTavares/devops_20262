# Trabalho em Aula — Aula 03: Terraform e Segurança AWS

**Aluno:** Yuri
**RA:** 6325238
**Data:** 24/09/2026

## Parte 1 — Análise de Riscos: Infraestrutura Manual

### Riscos e soluções com Terraform

| # | Risco (infraestrutura manual)                                                                                                           | Como Terraform resolve                                                                                                                                               |
| - | --------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1 | Configurações podem ser feitas de forma diferente entre os ambientes, causando problemas entre desenvolvimento, homologação e produção. | O Terraform permite definir a infraestrutura como código, possibilitando criar ambientes padronizados a partir da mesma configuração.                                |
| 2 | Um recurso pode ser excluído ou alterado por engano pelo Console AWS, causando indisponibilidade ou perda de dados.                     | As alterações ficam registradas no código e podem ser revisadas antes da aplicação. O Terraform também mostra no `plan` quais recursos serão alterados ou removidos. |
| 3 | Quando um funcionário sai da empresa, pode ser difícil identificar e remover manualmente todos os acessos e recursos relacionados.      | Usuários, grupos, políticas e permissões podem ser definidos e gerenciados como código, facilitando a padronização e a manutenção dos acessos.                       |
| 4 | Em uma auditoria, pode ser difícil descobrir quem criou ou alterou determinada infraestrutura e qual era a configuração utilizada.      | O código Terraform pode ser versionado no Git, permitindo consultar o histórico das alterações e revisar a configuração da infraestrutura.                           |
| 5 | Com o crescimento da equipe, criar usuários, permissões e recursos manualmente aumenta o risco de erros e configurações inconsistentes. | O Terraform automatiza a criação e alteração dos recursos, permitindo repetir configurações de forma padronizada e reduzindo tarefas manuais.                        |

## Parte 2 — Auditoria de Segurança: Design de IAM

### Estrutura IAM proposta

A conta root não deve ser utilizada para as atividades rotineiras. O acesso deve ser separado de acordo com as funções de cada integrante da equipe.

```text
AWS Account Root (NUNCA usar diretamente)
│
├── Group: technova-finance
│   ├── Users: Carlos Mendes
│   └── Policy: TechNovaBillingReadOnly
│       (ações: visualizar billing e relatórios de custos)
│
├── Group: technova-developers
│   ├── Users: Juliana Santos
│   └── Policy: TechNovaDeveloperPolicy
│       (ações: ler/escrever S3 e descrever EC2)
│
├── Group: technova-platform
│   ├── Users: Rafael Oliveira
│   └── Policy: TechNovaPlatformPolicy
│       (ações: gerenciar EC2, S3 e VPC;
│        leitura das informações do IAM)
│
├── Group: technova-readonly
│   ├── Users: Lucas
│   └── Policy: TechNovaS3ReadOnly
│       (ações: listar bucket e ler objetos S3)
│
└── Role: TechNovaApplicationRole
    ├── Trust Policy: serviço EC2 pode assumir
    └── Permissions: ler e escrever no bucket
        technova-app-data
```

### Detalhamento das permissões

**Carlos Mendes — CTO**

Deve possuir acesso somente de leitura às informações financeiras necessárias, como billing e relatórios de custos. Não precisa de permissões para alterar recursos da infraestrutura.

**Juliana Santos — Dev Sênior**

Deve possuir permissões para ler e escrever nos buckets S3 necessários ao desenvolvimento e consultar informações das instâncias EC2.

Exemplos de ações:

```text
s3:GetObject
s3:PutObject
s3:ListBucket
ec2:DescribeInstances
```

**Rafael Oliveira — Platform Engineer**

Precisa de permissões maiores para administrar a infraestrutura, mas ainda dentro das responsabilidades necessárias.

Exemplos:

```text
ec2:Describe*
ec2:RunInstances
ec2:StopInstances
ec2:StartInstances
s3:GetObject
s3:PutObject
s3:ListBucket
ec2:Describe*
vpc:Describe*
iam:Get*
iam:List*
```

**Lucas — Estagiário**

Deve possuir apenas acesso de leitura ao S3.

Exemplos:

```text
s3:ListBucket
s3:GetObject
```

Não deve possuir permissões para criar, alterar ou excluir objetos.

**API TechNova**

A aplicação executada em EC2 deve utilizar uma IAM Role em vez de armazenar credenciais AWS diretamente no código.

A role deve possuir uma trust policy permitindo que o serviço EC2 a assuma:

```text
EC2 → assume role → TechNovaApplicationRole
```

As permissões da role devem permitir somente o acesso necessário ao bucket da aplicação:

```text
s3:GetObject
s3:PutObject
s3:ListBucket
```

com os recursos limitados ao bucket `technova-app-data`.

### Violações de menor privilégio com Managed Policies

**1. Uso de `AmazonS3FullAccess` para um desenvolvedor**

Se Juliana recebesse `AmazonS3FullAccess`, ela poderia ter permissões muito maiores do que as necessárias, incluindo operações em buckets S3 que não fazem parte de sua atividade.

Uma política customizada poderia limitar o acesso somente aos buckets e operações necessários.

**2. Uso de uma política administrativa para o estagiário**

Se Lucas recebesse uma política ampla como `AdministratorAccess`, ele poderia alterar ou excluir recursos da conta AWS, apesar de sua função exigir apenas leitura de objetos S3.

Uma política customizada com `s3:ListBucket` e `s3:GetObject` atenderia à necessidade sem conceder permissões administrativas.

## Conclusão

O gerenciamento da infraestrutura como código com Terraform reduz tarefas manuais e permite manter uma configuração padronizada e versionada. No IAM, a separação por grupos, políticas específicas e roles para serviços permite aplicar o princípio do menor privilégio, concedendo a cada usuário ou aplicação somente as permissões necessárias para suas atividades.
