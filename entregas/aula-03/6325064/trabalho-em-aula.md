# Trabalho em Aula — Aula 03: Terraform e Segurança AWS

**Aluno:** Henri da Silva Despezzi  
**RA:** 6325064
**Data:** 27/08/2026

## Parte 1 — Análise de Riscos: Infraestrutura Manual

### Riscos e soluções com Terraform

| # | Risco (infraestrutura manual) | Como Terraform resolve |
| --- | --- | --- |
| 1 | **Falta de rastreabilidade e histórico:** Alterações feitas diretamente no Console AWS por diferentes pessoas não geram histórico claro de quem alterou o quê, nem o motivo da mudança. | O Terraform utiliza o controle de versão (Git), onde cada alteração passa por *pull requests*, code review e histórico detalhado de *commits*. |
| 2 | **Dificuldade na replicação de ambientes:** Criar um ambiente idêntico de *staging* ou produção manualmente é passível de falhas humanas, esquecimento de recursos e discrepâncias. | Através do *Infrastructure as Code* (IaC), o mesmo código pode ser aplicado em múltiplos workspaces ou arquivos de variáveis para provisionar ambientes idênticos de forma automatizada. |
| 3 | **Ausência de documentação e dependência de pessoas:** Se um colaborador sai da empresa, o conhecimento de como a infraestrutura foi montada vai embora junto, já que não há documentação formal. | O código Terraform atua como a própria documentação viva e declarativa da infraestrutura, descrevendo explicitamente todos os recursos em execução. |
| 4 | **Vulnerabilidade a erros humanos e exclusões acidentais:** Como relatado no caso em que um estagiário deletou um bucket por engano, a interface gráfica permite cliques acidentais e exclusões destrutivas imediatas. | O Terraform possui o comando `terraform plan`, que permite visualizar antecipadamente todas as alterações e exclusões antes de aplicá-las em produção, além de permitir o bloqueio de estados (*state locking*). |
| 5 | **Dificuldade de troubleshooting em incidentes críticos (ex: 3h da manhã):** Sem registro do que foi alterado recentemente, diagnosticar o motivo de uma falha em ambiente produtivo se torna uma tarefa lenta e desgastante. | O uso do arquivo de estado (*state file*) e do histórico do Git permite identificar rapidamente qual foi a última alteração aplicada na infraestrutura e realizar um *rollback* seguro. |

---

## Parte 2 — Auditoria de Segurança: Design de IAM

### Estrutura IAM proposta

AWS Account Root (NUNCA usar diretamente)
│
├── Group: Billing-Group
│   ├── Users: Carlos Mendes (CTO)
│   └── Policy: ViewBillingPolicy (ações: `aws-portal:ViewBilling`, `ce:*`, `budgets:*`)
│
├── Group: Platform-Admin-Group
│   ├── Users: Rafael Oliveira (Platform Eng)
│   └── Policy: PlatformAdminPolicy (ações: `ec2:*`, `s3:*`, `vpc:*`, `iam:Get*`, `iam:List*`)
│
├── Group: Developers-Group
│   ├── Users: Juliana Santos (Dev Sênior), Lucas (Estagiário - *nota: o estagiário pode ter uma policy restrita apenas ao S3*)
│   └── Policy: S3ReadWritePolicy / S3ReadOnlyPolicy (ações para Dev: `s3:GetObject`, `s3:PutObject`, `s3:ListBucket`, `ec2:Describe*`)
│
└── Role: TechNova-API-Role
├── Trust Policy: Serviço `ec2.amazonaws.com` pode assumir
└── Permissions: AppDataS3Policy (ações: `s3:GetObject`, `s3:PutObject` no bucket `technova-app-data`)

*(Nota: Para atender perfeitamente aos níveis de acesso distintos de Juliana e Lucas, o ideal é separá-los em grupos ou atribuir policies inline/diretas específicas, mantendo o princípio do menor privilégio).*

### Violações de menor privilégio com Managed Policies

1. **Uso de `AmazonS3FullAccess` para o Estagiário (Lucas):** O requisito era que o estagiário apenas visualizasse o S3 (*somente leitura*). Se utilizarmos a policy gerenciada `AmazonS3FullAccess`, ele não apenas terá acesso total de leitura, mas também poderá criar, modificar e **deletar** qualquer bucket ou objeto na conta da empresa, violando severamente a segurança.
2. **Uso de `AmazonEC2FullAccess` para a equipe de desenvolvimento:** Conceder acesso total ao EC2 via managed policy permitiria que qualquer desenvolvedor criasse instâncias de alto custo sem controle, modificasse grupos de segurança abrindo portas sensíveis para a internet pública (`0.0.0.0/0`) ou deletasse infraestruturas críticas de outros times.