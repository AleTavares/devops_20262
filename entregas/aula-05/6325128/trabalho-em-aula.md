# Trabalho em Aula — Aula 05: RDS e Remote State

**Aluno:** Felipe Damasceno  
**RA:** 6325128  
**Data:** 10/09/2026

---

## Parte 1 — Análise dos Incidentes

### Cenário A: Perda de Dados

**1. Por que os dados foram perdidos?**

Os dados foram perdidos porque estavam armazenados **em memória** (RAM) ou no **sistema de arquivos efêmero** da instância EC2 — provavelmente em uma estrutura de dados em processo (ex: array/variável no código da API) ou em um banco de dados local sem volume persistente. Quando a instância EC2 foi reiniciada, todo o estado em memória foi descartado, e os 5 pedidos de teste desapareceram junto.

**2. Outros cenários que causariam a mesma perda (mínimo 3):**

- **Crash da aplicação ou do sistema operacional:** se o processo da API travar ou o sistema operacional encontrar um erro fatal (kernel panic, OOM killer), todos os dados em memória são perdidos imediatamente.
- **Encerramento manual ou acidental da instância EC2:** rodar `aws ec2 terminate-instances` ou parar a instância pelo console sem persistência prévia tem o mesmo efeito da reinicialização programada.
- **Escalonamento automático (Auto Scaling):** se um grupo de Auto Scaling substituir a instância por uma nova (por falha de health check, por exemplo), a nova instância começa com estado zerado.
- **Deploy de nova versão da aplicação:** um redeploy que reinicia o processo da API descarta todos os dados que estavam apenas na memória do processo anterior.
- **Interrupção de instância Spot:** instâncias Spot podem ser interrompidas com apenas 2 minutos de aviso, apagando qualquer dado não persistido.

**3. Por que "não reiniciar o EC2" não é uma solução válida?**

Porque reinicializações são **inevitáveis** em produção: a AWS realiza manutenções programadas, patches de segurança do sistema operacional exigem reboot, falhas de hardware forçam migrações, e eventos como queda de energia ou falha de rede podem derrubar a instância a qualquer momento. Além disso, essa "solução" não protege contra nenhum dos outros cenários listados acima (crash, deploy, escalonamento). Confiar em "nunca reiniciar" significa aceitar que **a aplicação não tem confiabilidade**; é uma decisão arquitetural que transfere o risco para o operador humano em vez de resolver o problema na camada correta.

**4. Diferença entre dados em memória e dados persistentes:**

| | Dados em Memória | Dados Persistentes |
|---|---|---|
| **Onde ficam** | RAM do processo/servidor | Disco, banco de dados, S3, etc. |
| **Sobrevivem a reinicializações?** | Não | Sim |
| **Velocidade de acesso** | Muito rápida (nanosegundos) | Mais lenta (milissegundos) |
| **Exemplos** | Variáveis, cache, session in-process | RDS, DynamoDB, EBS, S3 |
| **Uso adequado** | Dados temporários, cache, computação intermediária | Dados de negócio, estado persistente, registros |

Em resumo: dados em memória existem apenas enquanto o processo está vivo; dados persistentes sobrevivem independentemente do ciclo de vida do processo ou da máquina.

---

### Cenário B: Perda do State

**1. O que acontece se rodarem `terraform plan` sem o state?**

Sem o arquivo `terraform.tfstate`, o Terraform não tem **nenhum mapeamento** entre os recursos declarados no código HCL e os recursos reais que existem na AWS. Ele parte do pressuposto de que **não existe nada** provisionado. Por isso, o `terraform plan` vai apresentar um plano para criar todos os recursos do zero — instâncias EC2, Security Groups, VPC, subnets, RDS, etc. — mesmo que eles já existam na conta AWS. O Terraform simplesmente "não enxerga" o que já está lá.

**2. Risco de rodar `terraform apply` nessa situação:**

Os riscos são graves:

- **Tentativa de criar recursos duplicados:** o Terraform vai tentar criar recursos que já existem, o que pode resultar em erros (ex: conflito de nome) ou, pior, na criação de recursos paralelos e redundantes gerando custos desnecessários.
- **Conflitos de nomes e IDs únicos:** recursos como buckets S3 têm nomes globalmente únicos; tentar criar um bucket que já existe resulta em erro ou, se o nome for diferente, em um bucket duplicado.
- **Perda de dados em produção:** se o Terraform decidir recriar um banco de dados RDS (em vez de falhar), os dados existentes são destruídos no processo.
- **State inconsistente:** após um apply parcial sem state original, o novo state só vai mapear os recursos criados nessa execução, deixando todos os recursos originais **órfãos** — gerenciados pela AWS mas invisíveis ao Terraform.
- **Mudanças no Security Group:** no cenário do Rafael, a mudança urgente no Security Group pode abrir ou fechar portas erradas se o Terraform não souber qual é o estado atual das regras.

**3. Terraform import como solução de emergência:**

Sim, o comando `terraform import` permite "adotar" recursos existentes na AWS para dentro de um novo state file. O fluxo seria:

```bash
# Exemplo: importar uma instância EC2 existente
terraform import aws_instance.api i-0abc123def456789

# Importar um Security Group
terraform import aws_security_group.ec2_sg sg-0123456789abcdef

# Importar um RDS
terraform import aws_db_instance.postgres mydb-identifier
```

O processo é trabalhoso: é preciso identificar o ID de cada recurso no console da AWS e executar um `import` separado para cada um. Após importar, o `terraform plan` deve mostrar zero diferenças entre o state e a infraestrutura real — qualquer divergência precisa ser resolvida manualmente no código HCL antes de aplicar qualquer mudança.

**4. Como essa situação poderia ter sido prevenida:**

- **Remote State no S3:** armazenar o `terraform.tfstate` em um bucket S3 compartilhado pela equipe, não na máquina local de nenhum desenvolvedor. O arquivo fica acessível para todos independente de quem está usando no momento.
- **Versionamento do bucket S3:** ativar versionamento no bucket protege contra exclusão acidental e permite rollback do state para uma versão anterior.
- **Nunca commitar o state no Git:** o `.gitignore` deve incluir `*.tfstate` e `*.tfstate.backup`, pois além do risco de perda, o state pode conter informações sensíveis (senhas, chaves).
- **Locking com DynamoDB:** impede que duas pessoas modifiquem o state simultaneamente, evitando corrupção.

---

## Parte 2 — Design da Arquitetura

### Diagrama Arquitetural (descrição textual)

```
┌─────────────────────────────────────────────────────────────────────┐
│                        AWS Account                                  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  VPC: 10.0.0.0/16                                            │   │
│  │                                                              │   │
│  │  ┌──────────────────────┐  ┌──────────────────────────────┐  │   │
│  │  │  us-east-1a          │  │  us-east-1b                  │  │   │
│  │  │                      │  │                              │  │   │
│  │  │ ┌──────────────────┐ │  │                              │  │   │
│  │  │ │ Subnet Pública   │ │  │                              │  │   │
│  │  │ │ 10.0.1.0/24      │ │  │                              │  │   │
│  │  │ │                  │ │  │                              │  │   │
│  │  │ │ ┌──────────────┐ │ │  │                              │  │   │
│  │  │ │ │  EC2 (API)   │ │ │  │                              │  │   │
│  │  │ │ │  SG: 22,3000 │ │ │  │                              │  │   │
│  │  │ │ └──────┬───────┘ │ │  │                              │  │   │
│  │  │ └────────┼─────────┘ │  │                              │  │   │
│  │  │          │ porta 5432│  │                              │  │   │
│  │  │ ┌────────▼─────────┐ │  │ ┌──────────────────────────┐│  │   │
│  │  │ │ Subnet Privada   │ │  │ │ Subnet Privada           ││  │   │
│  │  │ │ 10.0.2.0/24      │ │  │ │ 10.0.3.0/24              ││  │   │
│  │  │ │                  │ │  │ │                          ││  │   │
│  │  │ │ ┌──────────────┐ │ │  │ │ ┌──────────────────────┐││  │   │
│  │  │ │ │ RDS Primary  │ │ │  │ │ │ RDS Standby (AZ req.)│││  │   │
│  │  │ │ │ PostgreSQL   │ │ │  │ │ │ DB Subnet Group      │││  │   │
│  │  │ │ │ SG: 5432     │ │ │  │ │ │ SG: 5432             │││  │   │
│  │  │ │ │ (só do EC2)  │ │ │  │ │ │ (só do EC2)          │││  │   │
│  │  │ │ └──────────────┘ │ │  │ │ └──────────────────────┘││  │   │
│  │  │ └──────────────────┘ │  │ └──────────────────────────┘│  │   │
│  │  └──────────────────────┘  └──────────────────────────────┘  │   │
│  │                │                                              │   │
│  │         ┌──────▼──────┐                                      │   │
│  │         │  Internet   │                                      │   │
│  │         │  Gateway    │                                      │   │
│  └─────────┴──────┬──────┴──────────────────────────────────────┘   │
│                   │                                                  │
│                 Internet                                             │
│                                                                      │
│  ┌─────────────────────┐    ┌─────────────────────────────────────┐  │
│  │  S3 Bucket          │    │  DynamoDB Table                     │  │
│  │  (Remote TF State)  │    │  (State Locking)                    │  │
│  │  fora da VPC        │    │  fora da VPC                        │  │
│  └─────────────────────┘    └─────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

### Identificação dos componentes

**Componentes acessíveis da internet:**

- **EC2 (API):** está na subnet pública com rota para o Internet Gateway. As portas 22 (SSH) e 3000 (API HTTP) estão abertas no Security Group para tráfego externo.
- **Internet Gateway:** é o ponto de entrada/saída da VPC para a internet pública.
- **S3 Bucket e DynamoDB:** tecnicamente acessíveis via internet (são serviços gerenciados da AWS fora da VPC), mas o acesso é controlado por IAM policies, não por Security Groups.

**Componentes isolados (sem acesso direto da internet):**

- **RDS PostgreSQL:** está nas subnets privadas, que não têm rota para o Internet Gateway. O Security Group permite conexão na porta 5432 **apenas** a partir do Security Group do EC2 — nenhum tráfego externo chega ao banco.
- **Subnets privadas (10.0.2.0/24 e 10.0.3.0/24):** não possuem route table apontando para o Internet Gateway, portanto são completamente isoladas da internet pública.

**Por que o RDS precisa de subnets em 2 AZs mesmo sem Multi-AZ ativo?**

A AWS exige que um **DB Subnet Group** contenha subnets em pelo menos **duas Availability Zones diferentes**. Isso é um requisito obrigatório da API do RDS, independente de Multi-AZ estar habilitado ou não. O motivo é que a AWS precisa de flexibilidade para posicionar (ou reposicionar) a instância de banco de dados dentro da região — por exemplo, durante uma falha de AZ, uma manutenção ou uma futura ativação de Multi-AZ. Sem esse requisito satisfeito, o próprio Terraform (ou o console da AWS) retorna erro ao tentar criar o RDS.

---

## Parte 3 — Discussão: Conflito Simultâneo

### Cenários reais onde conflito de state ocorreria

- **CI/CD + desenvolvedor simultâneos:** um pipeline de deploy automático (GitHub Actions, GitLab CI) roda `terraform apply` após um merge na branch main, ao mesmo tempo em que um desenvolvedor aplica uma mudança de emergência manualmente no terminal — ambos partem do mesmo state e a corrida (race condition) é inevitável sem locking.
- **Dois engenheiros de infraestrutura sem comunicação:** em times distribuídos (fusos horários diferentes), Dev A no Brasil começa a trabalhar quando Dev B na Europa ainda não terminou seu apply — sem locking, os dois operam sobre o mesmo state simultaneamente.
- **Múltiplos workspaces compartilhando state:** em ambientes onde staging e produção compartilham configurações e o state não está devidamente separado, uma mudança em staging pode contaminar o state de produção.
- **Retry automático em pipelines:** um pipeline que falhou na metade e foi reexecutado automaticamente pode colidir com um apply ainda em andamento do run anterior que travou mas não liberou o lock.

### Impacto de um state corrompido

Um state corrompido é um dos cenários mais críticos em infraestrutura como código:

- **Terraform perde o rastreamento de recursos:** recursos reais na AWS ficam "órfãos" — existem, geram custo, mas o Terraform não sabe que eles existem e pode tentar recriá-los.
- **Destruição acidental de recursos:** se o Terraform interpreta que um recurso "novo" do state corrompido substitui um existente, pode emitir um `destroy` seguido de `create` — apagando um banco de dados de produção, por exemplo.
- **Drift silencioso:** mudanças manuais feitas na AWS enquanto o state está corrompido não são capturadas, levando a divergências crescentes entre o código e a realidade.
- **Impossibilidade de aplicar mudanças:** com o state inconsistente, todo `terraform plan` produz resultados imprevisíveis, paralisando a equipe até que o state seja restaurado ou reconstruído manualmente via `terraform import`.
- **Custo de recuperação alto:** reconstruir o state de uma infraestrutura complexa via `terraform import` pode levar horas ou dias, dependendo do número de recursos.

### Como o locking com DynamoDB resolve o problema

O DynamoDB locking garante **exclusão mútua** nas operações de escrita no state: apenas um processo pode adquirir o lock por vez. O Terraform registra um item na tabela DynamoDB com metadados do lock (quem está executando, desde quando, qual operação). Qualquer outro `terraform apply` que tente rodar simultaneamente detecta o lock existente e aguarda ou falha com uma mensagem clara — nunca sobrescreve um state em uso. Quando a operação termina (com sucesso ou erro), o lock é liberado e o próximo processo pode prosseguir com o state **atualizado**. Isso transforma uma operação concorrente perigosa em uma fila serializada e segura.
