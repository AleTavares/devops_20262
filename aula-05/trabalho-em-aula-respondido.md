# Trabalho em Aula — Aula 05: RDS e Remote State

**Aluno:** Matheus Mantovani  
**RA:** 20262  
**Data:** 18/09/2026

---

## Questões do TA — Gabarito

| Questão | Resposta | Justificativa |
|---------|----------|---------------|
| Q1 — Vantagem do RDS | **c** | RDS gerencia patches, backups e failover automaticamente — elimina o trabalho operacional de DBA |
| Q2 — DB Subnet Group exige 2 AZs | **c** | Para garantir resiliência e possibilitar Multi-AZ no futuro; a AWS exige o requisito mesmo sem Multi-AZ ativo |
| Q3 — Remote State crítico para equipes | **b** | Permite que todos os membros compartilhem o mesmo state e colaborem sem risco de divergência |
| Q4 — Propósito do DynamoDB no backend | **c** | Impede que duas execuções simultâneas de Terraform modifiquem o state ao mesmo tempo (locking) |

---

## Parte 1 — Análise dos Incidentes

### Cenário A: Perda de Dados

**1. Por que os dados foram perdidos?**

Os dados estavam armazenados na memória RAM da instância EC2, dentro do processo Node.js. A memória RAM é um recurso efêmero — seu conteúdo existe apenas enquanto o processo está ativo. Quando o EC2 reiniciou por manutenção da AWS, o processo foi encerrado e toda a memória foi liberada. Não havia persistência: nenhum banco de dados, nenhum arquivo em disco, nenhuma camada de storage externa ao processo.

**2. Outros cenários que causariam a mesma perda (mínimo 3):**

1. `terraform destroy` seguido de `terraform apply` — nova instância, memória zerada
2. Auto Scaling substituindo a instância por falha de health check
3. Crash da aplicação Node.js (memória liberada, dados perdidos ao reiniciar o processo)
4. Atualização de AMI que exige substituição da instância
5. Interrupção de uma Spot Instance pela AWS
6. Falha de hardware na AZ que força substituição da instância

**3. Por que "não reiniciar o EC2" não é uma solução válida:**

A premissa de "nunca reiniciar" é operacionalmente impossível e irresponsável. A AWS realiza manutenção programada nas instâncias (patches de segurança no hypervisor, hardware retirement). Além disso, a aplicação pode crashar a qualquer momento por bug, pressão de memória ou erro de rede. Dependência de uptime contínuo para preservar dados é um anti-pattern crítico — qualquer sistema de produção precisa tolerar falhas e reinicios sem perda de dados. A solução correta é separar a camada de compute (EC2, efêmero) da camada de dados (RDS, durável).

**4. Diferença entre dados em memória e dados persistentes:**

| Característica | Memória RAM (em processo) | Banco de dados persistente (RDS) |
|---|---|---|
| Durabilidade | Existe enquanto o processo vive | Persiste independentemente do compute |
| Sobrevive a reboot | ❌ Não | ✅ Sim |
| Sobrevive a crash | ❌ Não | ✅ Sim |
| Sobrevive a destroy | ❌ Não | ✅ Sim (RDS não é destruído automaticamente) |
| Compartilhável | ❌ Um processo apenas | ✅ Múltiplas instâncias acessam |
| Backup | ❌ Manual/impossível | ✅ Automático (RDS: backups diários) |

---

### Cenário B: Perda do State

**1. O que acontece se rodarem `terraform plan` sem o state? Por quê?**

O Terraform trata o state como a "memória" do que foi provisionado. Sem o `terraform.tfstate`, ele não tem conhecimento de nenhum recurso existente na AWS. O `terraform plan` vai mostrar que **precisa criar tudo do zero** — toda a VPC, EC2, RDS, Security Groups — como se a infraestrutura não existisse. Na prática, a infraestrutura existe e está rodando, mas o Terraform está "cego" para ela. Rodar `plan` resultará em um diff incorreto mostrando `+15 to add, 0 to change, 0 to destroy`.

**2. Risco de rodar `terraform apply` nessa situação:**

Altíssimo. Sem o state, o Terraform tentará **criar duplicatas** de todos os recursos. Alguns recursos com nomes únicos (como S3 buckets, IAM roles) darão erro de conflito. Outros, como EC2, VPCs e Security Groups, serão duplicados — gerando recursos órfãos gerando custo sem controle. Pior: se o apply "parcialmente" suceder, o novo state mapeia apenas os recursos recém-criados, e os antigos ficam completamente fora do controle do Terraform. Resultado: infraestrutura duplicada, custos dobrados, e impossibilidade de gerenciar os recursos antigos via Terraform.

**3. Terraform import como solução de emergência:**

Sim, `terraform import` permite "adotar" recursos existentes na AWS para dentro de um state novo. O processo é manual e trabalhoso: para cada recurso existente, você precisa identificar o ID na AWS e rodar `terraform import <resource_type>.<name> <aws_id>`. Em uma infraestrutura complexa com dezenas de recursos, isso pode levar horas. É uma solução de emergência válida mas dolorosa — exatamente o cenário que o remote state previne. A partir do Terraform 1.5, existe o `terraform import` em bloco via configuração HCL, que facilita o processo.

**4. Como essa situação poderia ter sido prevenida:**

- **Remote state no S3** — o state fica centralizado, não no laptop de ninguém
- **State versionado no S3** — mesmo que o state seja corrompido, é possível restaurar versão anterior
- **Nunca versionar `.tfstate` no Git** (mas usar S3 como backend)
- **Política de equipe:** qualquer infraestrutura de produção deve ter backend remoto configurado **antes** do primeiro `apply`
- **Backup periódico** do tfstate como camada extra de proteção

---

## Parte 2 — Design da Arquitetura

### Diagrama da arquitetura completa

```
                          INTERNET
                              │
                    ┌─────────▼──────────┐
                    │  Internet Gateway  │
                    │   (technova-igw)   │
                    └─────────┬──────────┘
                              │
┌─────────────────────────────▼──────────────────────────────────────────────┐
│  VPC: 10.0.0.0/16  (technova-vpc)  — us-east-1                            │
│                                                                            │
│  ┌─────── Subnet Pública ──────────────────────┐                          │
│  │  10.0.1.0/24  |  AZ: us-east-1a             │                          │
│  │                                             │                          │
│  │  ┌────────────────────────────────────┐     │                          │
│  │  │  EC2 t2.micro  (technova-api)      │     │                          │
│  │  │  SG: porta 22 (SSH), 3000 (API)    │     │                          │
│  │  │  PostgreSQL client instalado       │     │                          │
│  │  │  iam_instance_profile: LabInstance │     │                          │
│  │  └──────────────┬─────────────────────┘     │                          │
│  └─────────────────┼───────────────────────────┘                          │
│                    │ porta 5432 (dentro da VPC)                            │
│  ┌─────── Subnet Privada 1 ─────────────────────────────────────┐         │
│  │  10.0.2.0/24  |  AZ: us-east-1a                              │         │
│  │                                   ┌────────────────────────┐ │         │
│  │  DB Subnet Group ─────────────────►  RDS PostgreSQL 15      │ │         │
│  │  (ambas as subnets privadas)       │  db.t3.micro           │ │         │
│  │                                   │  SG: porta 5432 da VPC │ │         │
│  │                                   │  multi_az = false      │ │         │
│  │                                   │  storage_encrypted     │ │         │
│  └───────────────────────────────────┴────────────────────────┘─┘         │
│                                                                            │
│  ┌─────── Subnet Privada 2 ─────────────────────────────────────┐         │
│  │  10.0.4.0/24  |  AZ: us-east-1b                              │         │
│  │  (para DB Subnet Group — AZ diferente obrigatória)           │         │
│  │  (futuro: RDS standby Multi-AZ ficaria aqui)                 │         │
│  └──────────────────────────────────────────────────────────────┘         │
└────────────────────────────────────────────────────────────────────────────┘

FORA DA VPC (serviços globais AWS):
┌─────────────────────────┐    ┌──────────────────────────────┐
│  S3 Bucket              │    │  DynamoDB Table              │
│  technova-tf-state-xxxx │    │  technova-terraform-locks    │
│  ✅ Versionamento        │    │  Partition Key: LockID       │
│  ✅ Encriptação SSE-S3   │    │  billing: PAY_PER_REQUEST    │
│  ✅ Block Public Access  │    │                              │
│  terraform.tfstate ◄────┼────┼── Terraform backend "s3"     │
└─────────────────────────┘    └──────────────────────────────┘
         ▲                              ▲
         └──────── terraform apply ─────┘
                  (adquire lock no DynamoDB,
                   escreve state no S3,
                   libera lock)
```

**Componentes acessíveis da internet:**
- EC2 (IP público, portas 22 e 3000 abertas via Security Group)
- Internet Gateway (ponto de entrada/saída da VPC)

**Componentes isolados (sem acesso externo):**
- RDS PostgreSQL (subnet privada, sem IP público, `publicly_accessible = false`)
- Subnet Privada 1 e 2 (sem rota para IGW na Route Table)

**Por que o RDS precisa de 2 AZs no DB Subnet Group:**
A AWS exige que o DB Subnet Group contenha subnets em pelo menos 2 Availability Zones, mesmo que `multi_az = false`. Os motivos são: (1) preparação para failover futuro — se ativar Multi-AZ, o standby precisa existir em outra AZ; (2) manutenção da AWS — durante janelas de manutenção, a AWS pode precisar mover o banco entre AZs; (3) resiliência mínima — se uma AZ inteira sofrer falha catastrófica, há opção de recovery manual. Tentar criar um DB Subnet Group com subnets em apenas 1 AZ retorna erro da API da AWS.

---

## Parte 3 — Discussão: Conflito Simultâneo

### Cenários reais onde conflito de state ocorreria:

1. **CI/CD + desenvolvedor manual:** Pipeline de CD roda `terraform apply` automaticamente ao fazer merge de PR, enquanto um dev testa mudança localmente com `apply` simultâneo
2. **Dois PRs mergeados simultaneamente:** GitHub Actions dispara dois workflows de `apply` ao mesmo tempo
3. **Hotfix de emergência:** Dev aplica correção urgente enquanto pipeline noturno de reconciliação ainda está rodando
4. **Multi-região sem workspaces:** Equipes em fusos diferentes aplicam mudanças sem coordenação

### Impacto de um state corrompido:

Um state corrompido é um dos piores cenários em IaC. O Terraform passa a ter uma visão inconsistente da realidade: pode tentar destruir recursos que ainda existem, criar duplicatas de recursos já criados, ou simplesmente falhar em todos os comandos com erros de parsing JSON. Recuperar um state corrompido exige: (1) restaurar versão anterior do S3 (por isso versionamento é obrigatório), (2) comparar state restaurado com estado real da AWS, (3) rodar `terraform refresh` ou `terraform import` para reconciliar divergências. Em infra de produção, isso pode significar horas de downtime e risco de perda de dados.

### Como locking com DynamoDB resolve:

O DynamoDB funciona como um mutex distribuído. Quando o Terraform inicia qualquer operação de escrita (`apply`, `destroy`), ele tenta criar um registro na tabela DynamoDB com `LockID = <path do state>`. Se o registro já existe (outro processo está rodando), o Terraform falha imediatamente com erro de lock — **antes** de qualquer modificação. Isso garante que apenas um processo por vez modifica o state. Após a operação concluir (com sucesso ou erro), o lock é removido automaticamente. Se o processo morrer sem liberar o lock, é possível usar `terraform force-unlock <lock-id>` para liberar manualmente, mas isso deve ser feito com cautela.
