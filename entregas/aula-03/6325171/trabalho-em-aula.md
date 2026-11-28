# Trabalho em Aula — Aula 03: Terraform e Seguranca AWS

**Aluno:** Nicolas de Jesus Silva  
**RA:** 6325171  
**Data:** 19/11/2026

## Parte 1 — Analise de Riscos: Infraestrutura Manual

### Riscos e solucoes com Terraform

| # | Risco (infraestrutura manual) | Como Terraform resolve |
|---|-------------------------------|------------------------|
| 1 | O conhecimento da configuracao fica com quem criou os recursos; a saida de uma pessoa dificulta a manutencao. | O codigo versionado registra recursos, parametros e dependencias para que a equipe revise e mantenha a infraestrutura. |
| 2 | Criar staging ou producao manualmente produz ambientes diferentes. | Modulos e variaveis permitem reutilizar a mesma definicao com parametros controlados por ambiente. |
| 3 | Alteracoes no console podem nao ser auditadas ou reproduzidas. | Commits e pull requests registram o motivo, autor e revisao; `plan` mostra as mudancas antes do `apply`. |
| 4 | Uma acao emergencial pode remover recursos importantes sem uma recuperacao clara. | O estado e o plano ajudam a identificar recursos gerenciados; revisoes, backups e protecoes de destruicao reduzem o risco. |
| 5 | Com o crescimento do time, mudancas simultaneas podem gerar configuracoes conflitantes. | Backend remoto com locking, revisao obrigatoria e execucao controlada reduzem concorrencia e divergencia. |

## Parte 2 — Auditoria de Seguranca: Design de IAM

### Estrutura IAM proposta

```text
AWS Account Root (protegida com MFA; nao usada no dia a dia)
|
|-- Group: FinOpsReadOnly
|   |-- User: Carlos Mendes
|   |-- Policy: leitura de billing, Cost Explorer e budgets
|
|-- Group: Developer
|   |-- User: Juliana Santos
|   |-- Policy: listar/descrever EC2 e ler/escrever objetos
|       somente no bucket de desenvolvimento autorizado
|
|-- Group: PlatformOps
|   |-- User: Rafael Oliveira
|   |-- Policy: gerenciar EC2, S3 e VPC nos escopos do time;
|       leitura de IAM (Get/List/Describe), sem criar usuarios,
|       alterar policies ou assumir permissoes administrativas
|
|-- Group: S3ReadOnly
|   |-- User: Lucas
|   |-- Policy: listar o bucket permitido e ler seus objetos
|
|-- Role: TechNovaApiS3Role
    |-- Trust Policy: ec2.amazonaws.com pode assumir a role
    |-- Permissions: ListBucket no bucket technova-app-data;
        GetObject/PutObject somente em arn:aws:s3:::technova-app-data/*
```

### Politicas e controles

- O acesso a billing deve incluir apenas as acoes de leitura necessarias, como `aws-portal:ViewBilling`, `ce:GetCostAndUsage`, `ce:ListCostCategoryDefinitions` e leitura de budgets, respeitando a configuracao de acesso do console de billing.
- A politica de Juliana deve limitar escrita/leitura de S3 a buckets e prefixos de desenvolvimento definidos, sem permitir `s3:*` ou alteracao de bucket policy.
- A role da API deve ser associada a um instance profile da EC2. A aplicacao recebe credenciais temporarias da role; nao deve armazenar access keys no codigo.
- Habilitar MFA para usuarios humanos, manter root sem uso diario e revisar periodicamente as permissoes.

### Violacoes de menor privilegio com Managed Policies

1. `AmazonS3FullAccess` para Juliana ou Lucas daria acesso a buckets fora do projeto, incluindo leitura, escrita e exclusao de dados que nao precisam acessar.
2. `AdministratorAccess` ou `AmazonEC2FullAccess` para Rafael permitiria alterar recursos e permissoes alem do escopo de trabalho; uma credencial comprometida poderia ampliar o impacto para toda a conta.
3. `AmazonS3FullAccess` na role da API permitiria que uma falha da aplicacao alterasse ou apagasse objetos em buckets nao relacionados ao servico.
