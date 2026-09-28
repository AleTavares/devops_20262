# Trabalho em Aula — Aula 05: RDS e Remote State

**Aluno:** Fernanda Tavares  
**RA:** 4025109  
**Data:** 17/09/2026

---

## Parte 1 — Análise dos Incidentes

### Cenário A: Perda de Dados

**1. Por que os dados foram perdidos?**

Os dados foram perdidos porque estavam armazenados apenas na memória da instância EC2 — provavelmente em variáveis da aplicação ou em um banco de dados SQLite/em memória rodando localmente no mesmo processo. Quando a instância reiniciou, tudo que existia apenas em memória (RAM) ou em armazenamento efêmero (como o instance store) foi descartado. Não havia nenhum serviço de persistência externo à instância.

**2. Outros cenários que causariam a mesma perda (mínimo 3):**

- **Encerramento acidental da instância:** Rodar `terraform destroy` ou desligar a EC2 pelo console destrói o estado da memória completamente.
- **Falha de hardware no host físico da AWS:** A AWS migra a instância para outro host, resultando em reinicialização e perda de dados em memória.
- **Deploy de nova versão da aplicação:** Subir um novo container ou reiniciar o processo da API apaga qualquer dado que não estava persistido externamente.
- **Auto Scaling terminando instâncias:** Em cenários de scale-in, instâncias são encerradas sem cerimônia, levando todos os dados locais consigo.
- **Crash da aplicação com restart automático (ex: systemd ou Docker restart policy):** O processo reinicia limpo, sem nenhum dado da sessão anterior.

**3. Por que "não reiniciar o EC2" não é uma solução válida?**

Porque a premissa ignora a natureza efêmera de infraestrutura cloud. Instâncias EC2 podem ser reiniciadas ou encerradas por diversas razões fora do controle da equipe: manutenção programada da AWS, falhas de hardware, atualizações de segurança, eventos de Auto Scaling, ou simplesmente um deploy. Além disso, uma arquitetura que depende de "nunca reiniciar" é frágil por definição — não tem resiliência nem escalabilidade. A solução correta é externalizar o estado para um serviço de persistência dedicado (como RDS), não tentar evitar reinicializações.

**4. Diferença entre dados em memória e dados persistentes:**

| | Dados em Memória (RAM) | Dados Persistentes |
|---|---|---|
| **Onde ficam** | RAM da instância EC2 | Serviço externo: RDS, S3, DynamoDB |
| **Sobrevivem ao restart** | ❌ Não | ✅ Sim |
| **Velocidade de acesso** | Muito rápida | Mais lenta (rede) |
| **Exemplo** | Variáveis da aplicação, cache | Banco de dados RDS, arquivos no S3 |
| **Adequado para** | Dados temporários, processamento | Dados que precisam existir após falhas |

Dados em memória existem apenas enquanto o processo está rodando. Dados persistentes são gravados em disco (ou serviço externo) e sobrevivem a reinicializações, falhas e deploys.

---

### Cenário B: Perda do State

**1. O que acontece se rodarem `terraform plan` sem o state?**

O Terraform interpreta a ausência do `terraform.tfstate` como "não existe nada gerenciado ainda". Ao rodar `terraform plan`, ele compara o código `.tf` com um state vazio — e portanto planeja **criar todos os recursos do zero**, como se fosse uma infraestrutura nova. Recursos que já existem na AWS serão listados como `+ create`, não como recursos já gerenciados. O Terraform não consulta a AWS diretamente para descobrir o que existe; ele confia no state como fonte da verdade.

**2. Risco de rodar `terraform apply` nessa situação:**

O risco é crítico. Com state vazio, o `apply` tentará criar recursos que já existem na AWS. Dois cenários possíveis:

- **Conflito de nomes:** Recursos com nomes únicos (como buckets S3, IAM roles) já existem → o apply falha com erro de duplicidade.
- **Duplicação silenciosa:** Recursos sem restrição de unicidade (como Security Groups, instâncias EC2) podem ser criados em duplicata → infraestrutura paralela não gerenciada, custos duplicados, comportamento imprevisível.

Em ambos os casos, o state gerado pelo apply não reflete a infraestrutura real já existente, criando uma divergência permanente difícil de corrigir.

**3. `terraform import` como solução de emergência:**

Sim, o `terraform import` permite "reconectar" recursos existentes na AWS ao Terraform sem recriá-los. O fluxo é:

```bash
terraform import aws_security_group.main sg-0abc123def456789
```

Isso lê o estado atual do recurso na AWS e escreve no `terraform.tfstate` local. O processo é trabalhoso — cada recurso precisa ser importado individualmente, e o código `.tf` correspondente já deve existir. Para infraestruturas grandes, ferramentas como `terraformer` automatizam a geração reversa, mas é uma operação de recuperação complexa e propensa a erros.

**4. Como prevenir essa situação:**

- **Remote state no S3:** Armazenar o `terraform.tfstate` em um bucket S3 com versionamento habilitado. O state fica na nuvem, acessível a toda a equipe, independente do laptop de qualquer pessoa.
- **Locking com DynamoDB:** Evita que dois operadores modifiquem o state simultaneamente.
- **Nunca commitar o `.tfstate` no Git:** O state pode conter segredos (senhas, chaves). Usar `.gitignore` para excluí-lo.
- **Backup automático:** Com S3 + versionamento, qualquer versão anterior do state pode ser restaurada em segundos.
- **Acesso via CI/CD:** Executar `terraform apply` via pipeline (GitHub Actions, etc.) em vez de máquinas locais elimina a dependência de laptops individuais.

---

## Parte 2 — Design da Arquitetura

### Descrição da Arquitetura TechNova

```
┌─────────────────────────────────────────────────────────────────┐
│  AWS Cloud                                                      │
│                                                                 │
│  ┌─── VPC: 10.0.0.0/16 ────────────────────────────────────┐   │
│  │                                                          │   │
│  │  ┌─ us-east-1a ──────────┐  ┌─ us-east-1b ───────────┐  │   │
│  │  │                       │  │                         │  │   │
│  │  │  Subnet Pública       │  │  Subnet Privada B       │  │   │
│  │  │  10.0.1.0/24          │  │  10.0.3.0/24            │  │   │
│  │  │  ┌────────────────┐   │  │  ┌───────────────────┐  │  │   │
│  │  │  │  EC2 (API)     │   │  │  │  RDS PostgreSQL   │  │  │   │
│  │  │  │  t3.micro      │───┼──┼─▶│  (standby AZ)    │  │  │   │
│  │  │  │  porta 22,3000 │   │  │  └───────────────────┘  │  │   │
│  │  │  └───────┬────────┘   │  └─────────────────────────┘  │   │
│  │  │          │ porta 5432 │                                │   │
│  │  │  Subnet Privada A     │                                │   │
│  │  │  10.0.2.0/24          │                                │   │
│  │  │  ┌────────────────┐   │                                │   │
│  │  │  │  RDS PostgreSQL│   │                                │   │
│  │  │  │  (primary)     │   │                                │   │
│  │  │  └────────────────┘   │                                │   │
│  │  └───────────────────────┘                                │   │
│  │                          │                                │   │
│  │  Internet Gateway ◀──────┘ (somente subnet pública)      │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌── Fora da VPC ──────────────────────────────────────────┐    │
│  │  S3 Bucket (terraform remote state)                     │    │
│  │  DynamoDB Table (terraform state locking)               │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
         ▲
    Internet
```

### Security Groups

| Recurso | Regra de entrada | Origem |
|---|---|---|
| EC2 | porta 22 (SSH) | 0.0.0.0/0 (ou IP restrito) |
| EC2 | porta 3000 (API) | 0.0.0.0/0 |
| RDS | porta 5432 (PostgreSQL) | Security Group do EC2 apenas |

### Componentes acessíveis da internet:

- **EC2** (via Internet Gateway) — expõe a API na porta 3000 e permite SSH na 22
- **Internet Gateway** — ponto de entrada/saída da VPC para a internet pública

### Componentes isolados (sem acesso direto da internet):

- **RDS PostgreSQL** — em subnets privadas, sem route para Internet Gateway; só aceita conexões vindas do Security Group do EC2
- **S3 e DynamoDB** — acessados via endpoint de serviço AWS (não pela internet pública) ou via credenciais IAM

### Por que o RDS precisa de subnets em 2 AZs mesmo sem Multi-AZ?

O AWS RDS exige um **DB Subnet Group** com subnets em pelo menos 2 Availability Zones para ser criado — mesmo que a instância rode em apenas uma AZ no momento. Isso é um requisito da AWS por dois motivos:

1. **Preparação para failover futuro:** Se a equipe decidir habilitar Multi-AZ depois, a infraestrutura de rede já está pronta sem precisar recriar o banco.
2. **Resiliência da plataforma:** A AWS precisa ter flexibilidade para mover recursos entre AZs em caso de manutenção ou falha, e isso requer que a rede esteja configurada em múltiplas zonas desde o início.

---

## Parte 3 — Discussão: Conflito Simultâneo

### Cenários reais onde o conflito de state ocorreria:

1. **CI/CD + desenvolvedor simultâneos:** Um pipeline de GitHub Actions roda `terraform apply` automaticamente após um merge, enquanto um desenvolvedor executa `terraform apply` localmente para testar uma mudança urgente de Security Group. Ambos partem do mesmo state, e o que terminar por último sobrescreve as mudanças do primeiro.

2. **Dois PRs mergeados quase ao mesmo tempo:** PR-A adiciona um novo bucket S3 e PR-B modifica uma IAM policy. Ambos são mergeados em minutos de diferença e seus pipelines rodam em paralelo. Sem locking, o state do pipeline mais lento sobrescreve o do mais rápido, "esquecendo" uma das mudanças.

3. **Hotfix manual durante deploy programado:** Uma falha em produção força um engenheiro a rodar `terraform apply` manualmente enquanto o deploy noturno automatizado também está em execução.

### Impacto de um state corrompido:

- **Drift silencioso:** O Terraform passa a não saber quais recursos realmente existem, podendo tentar recriar recursos já existentes ou não detectar recursos que foram deletados manualmente.
- **Risco de destruição acidental:** Em um state corrompido onde um recurso "some" do registro, o próximo `apply` pode tentar criá-lo novamente — ou pior, um `plan` pode mostrar recursos existentes como "para destruir".
- **Paralisia operacional:** A equipe perde a capacidade de fazer mudanças com confiança até o state ser restaurado ou reconstruído via `terraform import`.
- **Custo e tempo de recuperação:** Recriar o state via import para uma infraestrutura grande pode levar horas, durante as quais mudanças urgentes ficam bloqueadas.

### Como o locking com DynamoDB resolve:

O DynamoDB atua como um mutex distribuído. Quando um operador inicia um `terraform apply`, o Terraform:

1. Tenta escrever um item na tabela DynamoDB com o ID do lock
2. Se conseguir → prossegue com o apply
3. Se a tabela já tiver um lock ativo → retorna erro imediatamente: `Error acquiring the state lock`
4. Ao terminar (com sucesso ou falha) → remove o lock da tabela

Isso garante que apenas **um** processo modifica o state por vez. O segundo operador recebe um erro claro com informações sobre quem detém o lock e desde quando — podendo aguardar ou, em casos de lock travado (crash), forçar a liberação com `terraform force-unlock <lock-id>`.

O resultado é **serialização das operações**: as mudanças de Dev A e Dev B são aplicadas sequencialmente, cada uma lendo o state mais recente, sem sobrescrita e sem perda de mudanças.
