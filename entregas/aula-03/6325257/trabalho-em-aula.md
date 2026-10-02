# Trabalho em Aula — Aula 03: Terraform e Segurança AWS

**Aluno:** [Luiza Carneiro Rolfsen]  
**RA:** [6325257]  
**Data:** [22/09/2026]

## Parte 1 — Análise de Riscos: Infraestrutura Manual

### Riscos e soluções com Terraform

| # | Risco (infraestrutura manual) | Como Terraform resolve |
|---|-------------------------------|------------------------|
| 1 | **Perda de conhecimento:** Configurações ficam apenas na cabeça de quem criou (como o bucket apagado). | **Infraestrutura como Código (IaC):** O arquivo `.tf` funciona como uma documentação viva e executável de tudo o que existe na nuvem. |
| 2 | **Erro humano e inconsistência:** Esquecer de abrir portas ou configurar redes ao tentar criar um ambiente idêntico. | **Reprodutibilidade:** O Terraform garante que a execução do código crie ambientes (ex: staging e produção) de forma exatamente idêntica, mil vezes seguidas. |
| 3 | **Falta de rastreabilidade:** Não é possível saber quem fez alterações no Console para auditorias de compliance. | **Versionamento:** Aliando Terraform ao Git, toda alteração de infraestrutura fica registrada no histórico de commits (quem alterou, quando e por quê). |
| 4 | **Lentidão na recuperação (Disaster Recovery):** Levar horas clicando em telas para recriar o ambiente sob pressão de madrugada. | **Automação:** Basta executar um único comando (`terraform apply`) para recriar centenas de recursos em poucos minutos e sem falhas. |
| 5 | **Conflitos na equipe:** Várias pessoas acessando e alterando o Console AWS ao mesmo tempo, sobrescrevendo o trabalho dos outros. | **Revisão e Bloqueio (State Lock):** O Terraform bloqueia o estado durante a execução para evitar conflitos concorrentes, e as mudanças passam por Pull Requests. |

## Parte 2 — Auditoria de Segurança: Design de IAM

### Estrutura IAM proposta

    AWS Account Root (NUNCA usar diretamente)
    │
    ├── Group: Financeiro_Diretoria
    │   ├── Users: Carlos Mendes
    │   └── Policy: BillingReadOnlyPolicy (ações: Visualizar billing e ler relatórios de custo)
    │
    ├── Group: Platform_Engineering
    │   ├── Users: Rafael Oliveira
    │   └── Policy: InfraAdminPolicy (ações: Gerenciar EC2, S3, VPC; Ler IAM)
    │
    ├── Group: Desenvolvedores
    │   ├── Users: Juliana Santos, Lucas
    │   └── Policy: DevBasePolicy (ações: Somente leitura no S3, Descrever EC2)
    │       * (Nota: Juliana recebe uma política extra via usuário para Escrita no S3)
    │
    └── Role: APITechNovaRole
        ├── Trust Policy: Serviço EC2 pode assumir
        └── Permissions: AppDataBucketPolicy (ações: Ler/escrever apenas no bucket 'technova-app-data')

### Violações de menor privilégio com Managed Policies

1. **O raio de explosão da API (Risco de invasão):** Se a Role da API recebesse a *Managed Policy* genérica `AmazonS3FullAccess` em vez de uma restrita ao bucket dela, um hacker que invadisse a aplicação ganharia poder para acessar, vazar ou deletar todos os buckets da empresa (incluindo backups e arquivos de estado do Terraform).
2. **Acesso cruzado perigoso (Risco de acidentes):** Se o grupo de Desenvolvedores recebesse `AmazonEC2FullAccess` apenas porque a Juliana precisa interagir com os servidores, ela ou o estagiário teriam permissão para desligar ou deletar máquinas de produção acidentalmente, violando a regra de ter apenas a permissão mínima para "ler/descrever" a EC2.
