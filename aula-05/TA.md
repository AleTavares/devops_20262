# Trabalho Anterior — Aula 05: RDS e Remote State

## Objetivo

Preparar o aluno para a aula presencial através de leitura teórica sobre **Amazon RDS** (banco de dados gerenciado) e **Remote State** (state remoto com S3 e DynamoDB). Este trabalho deve ser realizado **antes** da aula.

**Tempo estimado:** ~60 minutos de leitura

---

## Parte 1 — Amazon RDS: Banco de Dados Gerenciado (~35 min)

### 1.1 O Problema: Dados em Memória no EC2

Na Aula 04, provisionamos um EC2 com a API da TechNova rodando. A aplicação funciona — mas todos os dados ficam armazenados em **memória RAM**. Isso significa que:

- Se o EC2 reiniciar → dados perdidos
- Se a instância for terminada → dados perdidos para sempre
- Se o Auto Scaling substituir a instância → dados perdidos

**Pergunta crítica:** "Se eu criar um pedido agora e reiniciar o servidor, o pedido ainda vai existir?" Resposta: **Não.**

Para uma aplicação de produção, isso é inaceitável. Precisamos de um banco de dados **externo e persistente** — que sobrevive independentemente do EC2.

### 1.2 Self-Managed Database vs Managed Database (RDS)

Existem duas abordagens para ter um banco de dados na AWS:

**Opção A — Self-Managed (PostgreSQL instalado no EC2):**
- Você cria um EC2
- Instala PostgreSQL manualmente (`apt install postgresql`)
- Configura backup, monitoramento, patches por conta própria
- Você é o DBA (administrador de banco)

**Opção B — Managed (Amazon RDS):**
- AWS provisiona o banco para você
- AWS cuida de patches, backups, monitoramento, failover
- Você só gerencia o schema (tabelas, queries, usuários do banco)

| Aspecto | Self-Managed (EC2) | Managed (RDS) |
|---------|-------------------|---------------|
| Instalação | Manual | Automática |
| Patches do SO | Você aplica | AWS aplica |
| Backup | Você configura scripts | Automático (diário) |
| Monitoramento | Você instala ferramentas | CloudWatch integrado |
| Failover | Você implementa | Automático (Multi-AZ) |
| Acesso SSH ao servidor | ✅ Sim | ❌ Não |
| Tempo de setup | ~1 hora manual | ~10 minutos com Terraform |
| Esforço operacional | Alto | Baixo |

**Conclusão:** Para 95% dos casos, RDS é a melhor escolha. Use self-managed apenas quando precisar de controle total sobre o servidor do banco.

### 1.3 O que é Amazon RDS?

Amazon RDS (Relational Database Service) é um serviço gerenciado que facilita a configuração, operação e escalabilidade de bancos de dados relacionais na nuvem. Engines suportadas:

- **PostgreSQL** (usaremos este)
- MySQL
- MariaDB
- Oracle
- SQL Server
- Aurora (engine proprietária AWS, compatível com MySQL/PostgreSQL)

### 1.4 Conceitos-Chave do RDS

**DB Subnet Group:**
- Um grupo de subnets onde o RDS pode ser posicionado
- **Requisito obrigatório:** deve conter subnets em **pelo menos 2 Availability Zones diferentes**
- Mesmo usando `multi_az = false`, a AWS exige essa configuração
- Motivo: preparação para failover futuro e requisito de resiliência

**Parameter Groups:**
- Configurações do banco de dados (encoding, timeouts, cache)
- AWS fornece defaults sensatos — geralmente não precisa alterar
- Exemplo: `max_connections`, `shared_buffers`, `work_mem`

**Multi-AZ:**
- Cria uma réplica standby em outra AZ automaticamente
- Failover automático em ~60 segundos se o primário falhar
- **Custo:** dobro (paga por 2 instâncias)
- **NÃO usaremos no curso** (não é Free Tier)

**Backups Automáticos:**
- RDS faz backup diário automaticamente (janela configurável)
- Retenção padrão: 7 dias (pode ir até 35)
- Permite restaurar para qualquer ponto no tempo (Point-in-Time Recovery)

### 1.5 Por Que 2 AZs no DB Subnet Group?

Quando você cria um DB Subnet Group, precisa de subnets em pelo menos 2 AZs:

```
DB Subnet Group "technova-db-subnet":
  - Subnet em us-east-1a (10.0.2.0/24) ← RDS primário será aqui
  - Subnet em us-east-1b (10.0.4.0/24) ← Standby Multi-AZ ficaria aqui
```

Motivos:
1. **Multi-AZ futuro:** se ativar, o standby precisa de outra AZ
2. **Manutenção:** AWS pode precisar mover o banco entre AZs durante manutenção
3. **Resiliência:** se uma AZ inteira cair, há opção de recovery
4. **Requisito AWS:** criar DB Subnet Group com 1 AZ apenas retorna erro

### 1.6 Segurança do RDS

O RDS deve ficar em **subnet privada** (sem acesso à internet):

- Security Group permite **apenas porta 5432** (PostgreSQL)
- Origem: apenas o CIDR da VPC ou o Security Group do EC2
- Não exponha RDS à internet (0.0.0.0/0) — **jamais!**
- `publicly_accessible = false` (padrão no Terraform)

### 1.7 Connection String

Após criar o RDS, você recebe um **endpoint** (DNS) para conexão:

```
postgresql://usuario:senha@endpoint:5432/nome_do_banco

Exemplo:
postgresql://technova_admin:S3nh4Segura@technova-db.cxyz123.us-east-1.rds.amazonaws.com:5432/technova
```

Componentes:
- **usuario:** definido em `username` na criação
- **senha:** definida em `password` na criação
- **endpoint:** gerado pela AWS (DNS name)
- **porta:** 5432 (padrão PostgreSQL)
- **database:** definido em `db_name` na criação

### 1.8 Free Tier RDS

- **Instance:** db.t3.micro (750 horas/mês por 12 meses)
- **Storage:** 20 GB SSD (gp2)
- **Backup:** 20 GB de armazenamento de backup
- **Multi-AZ:** NÃO incluído (usar `multi_az = false`)
- **⚠️ RDS leva 5-10 minutos para ficar pronto** — não é instantâneo como EC2

### 1.9 Por Que NÃO Rodar PostgreSQL em Docker no EC2 para Produção?

Pode parecer mais simples rodar `docker run postgres` no EC2. Problemas:

- **Dados no container:** se o container morrer, dados perdidos (a menos que use volumes)
- **Sem backup automático:** você precisa implementar
- **Sem failover:** se o EC2 cair, banco cai junto
- **Sem patches automáticos:** vulnerabilidades de segurança
- **Sem monitoramento nativo:** precisa instalar ferramentas
- **Não escala:** está preso ao hardware do EC2

Docker PostgreSQL é ótimo para **desenvolvimento local**. Para produção na AWS, use RDS.

---

## Parte 2 — Remote State: Protegendo o State do Terraform (~25 min)

### 2.1 O Cenário do Laptop Roubado

Rafael, desenvolvedor da TechNova, provisionou toda a infraestrutura (VPC, EC2, RDS) usando Terraform no seu laptop. O arquivo `terraform.tfstate` — com o mapeamento completo da infraestrutura — ficou salvo localmente.

Na sexta-feira, seu laptop foi roubado. Na segunda-feira, a equipe descobriu:

- A infraestrutura existe na AWS (rodando, gerando custo)
- Ninguém tem o `terraform.tfstate`
- `terraform plan` quer criar tudo de novo (acha que nada existe)
- `terraform destroy` não funciona (não sabe o que destruir)
- Recursos órfãos na AWS gerando custo sem controle

**Lição:** O `terraform.tfstate` é tão importante quanto o próprio código Terraform.

### 2.2 O que é terraform.tfstate?

É um arquivo JSON que o Terraform usa para:

1. **Mapear** cada resource no código (.tf) ao recurso real na AWS
2. **Comparar** estado desejado (código) vs estado atual (infra real)
3. **Calcular** o que precisa mudar no `terraform plan`
4. **Rastrear** metadados (IDs, IPs, ARNs, dependências)

Sem o state, o Terraform é "cego" — não sabe o que existe na nuvem.

### 2.3 Problemas do State Local

| Problema | Descrição |
|----------|-----------|
| **Ponto único de falha** | Arquivo no laptop → roubou/formatou = perdeu |
| **Sem colaboração** | Só quem tem o arquivo pode rodar Terraform |
| **Sem locking** | 2 devs rodando apply = state corrompido |
| **Sem versionamento** | Não tem como voltar para state anterior |
| **Inseguro** | State contém senhas do RDS em plain text! |

### 2.4 Solução: S3 + DynamoDB

**S3 Bucket** armazena o state:
- Centralizado (toda equipe acessa)
- Versionado (histórico de mudanças, rollback)
- Encriptado (senhas protegidas)
- Controlado por IAM (quem pode ler/escrever)

**DynamoDB Table** fornece locking:
- Quando alguém roda `terraform apply`, um lock é criado
- Outra pessoa tentando rodar ao mesmo tempo é bloqueada
- Previne corrupção por escrita simultânea

### 2.5 Configuração do Backend S3

```hcl
terraform {
  backend "s3" {
    bucket         = "meu-terraform-state"      # Bucket S3 (deve existir)
    key            = "projeto/terraform.tfstate" # Caminho no bucket
    region         = "us-east-1"                # Região
    encrypt        = true                       # Encriptação SSE-S3
    dynamodb_table = "terraform-locks"          # Tabela de locking
  }
}
```

**Importante:** O bucket S3 e a tabela DynamoDB devem ser criados **antes** de configurar o backend. É o clássico "chicken-and-egg" do Terraform.

### 2.6 DynamoDB Locking

A tabela DynamoDB precisa de:
- **Partition Key:** `LockID` (tipo String)
- Nada mais — o Terraform gerencia o conteúdo automaticamente

Quando `terraform apply` roda:
1. Terraform cria registro na DynamoDB com `LockID` = path do state
2. Executa o apply
3. Remove o registro (libera lock)

Se outro dev tentar rodar ao mesmo tempo:
```
Error: Error locking state: Error acquiring the state lock
Lock Info:
  ID:        12345-abcde
  Path:      meu-terraform-state/projeto/terraform.tfstate
  Operation: OperationTypeApply
  Who:       rafael@laptop
  Created:   2025-01-15 10:30:00
```

### 2.7 Migração de State Local → Remoto

Processo em 3 passos:

1. **Criar** bucket S3 e tabela DynamoDB
2. **Adicionar** bloco `backend "s3"` no `providers.tf`
3. **Executar** `terraform init -migrate-state`

O Terraform pergunta se deseja copiar o state existente para o novo backend. Responda `yes`. Após a migração, o state local pode ser removido (Terraform cria backup automaticamente).

### 2.8 Segurança do State Remoto

Best practices:
- **Encriptação:** `encrypt = true` no backend (SSE-S3)
- **Versionamento:** habilitar no bucket S3 (permite rollback)
- **Block Public Access:** bucket S3 nunca deve ser público
- **IAM:** apenas pessoas autorizadas acessam o bucket
- **Não versionar .tfstate no Git:** adicione ao `.gitignore`

### 2.9 Free Tier — S3 e DynamoDB

- **S3:** 5 GB armazenamento + 20.000 GET + 2.000 PUT (12 meses)
- **DynamoDB:** 25 GB armazenamento + 25 Write/Read Capacity Units (sempre gratuito)

O arquivo terraform.tfstate raramente passa de 100 KB. A tabela de lock usa bytes por registro. Estamos muito longe dos limites gratuitos.

---

## Questões de Verificação

Responda as questões abaixo para validar sua compreensão. As respostas serão discutidas no início da aula.

### Questão 1 — Vantagem do RDS

**Qual é a principal vantagem do Amazon RDS sobre instalar PostgreSQL manualmente em um EC2?**

a) RDS é mais barato que EC2
b) RDS permite acesso SSH ao servidor do banco
c) RDS gerencia patches, backups e failover automaticamente
d) RDS suporta mais tipos de banco de dados que PostgreSQL instalado manualmente

### Questão 2 — DB Subnet Group

**Por que o DB Subnet Group do RDS exige subnets em pelo menos 2 Availability Zones diferentes?**

a) Porque o RDS sempre roda em 2 AZs simultaneamente
b) Para distribuir o custo entre diferentes data centers
c) Para garantir resiliência e possibilitar Multi-AZ no futuro
d) Porque subnets em 1 AZ não suportam PostgreSQL

### Questão 3 — Remote State

**Por que o state remoto (S3) é crítico para equipes que trabalham com Terraform?**

a) Porque o state local é mais lento para operações de plan
b) Porque permite que todos os membros da equipe compartilhem o mesmo state e colaborem
c) Porque a AWS exige state remoto para provisionar recursos
d) Porque o state local não funciona com recursos RDS

### Questão 4 — DynamoDB Locking

**Qual é o propósito da tabela DynamoDB configurada no backend S3 do Terraform?**

a) Armazenar os outputs do Terraform para consulta
b) Fazer backup do state em caso de falha do S3
c) Impedir que duas execuções simultâneas de Terraform modifiquem o state ao mesmo tempo
d) Armazenar as variáveis sensíveis (senhas) separadas do state

---

## Gabarito

| Questão | Resposta | Justificativa |
|:-------:|:--------:|---------------|
| 1 | C | RDS gerencia patches, backups e failover automaticamente — libera a equipe de administrar o banco e reduz risco de falhas humanas. Não é mais barato, não permite SSH, e "mais tipos de banco" não é vantagem nesse contexto. |
| 2 | C | A AWS exige subnets em 2+ AZs para garantir resiliência: possibilitar Multi-AZ no futuro, permitir manutenção de hardware entre AZs, e garantir recovery se uma AZ falhar. |
| 3 | B | O state remoto permite colaboração: todos os membros da equipe e o CI/CD acessam o mesmo state centralizado no S3. Sem isso, apenas quem tem o arquivo local pode rodar Terraform. |
| 4 | C | A tabela DynamoDB serve para locking — impede dois `terraform apply` simultâneos de modificar o state ao mesmo tempo, prevenindo corrupção do arquivo. |

---

## Preparação para a Aula

Após completar a leitura:

1. ✅ Entende por que dados em memória são inadequados para produção
2. ✅ Sabe diferenciar self-managed database de managed database (RDS)
3. ✅ Compreende o requisito de 2 AZs para DB Subnet Group
4. ✅ Entende o papel do terraform.tfstate e riscos do state local
5. ✅ Sabe explicar como S3 + DynamoDB resolvem o problema
6. ✅ Respondeu as 4 questões de verificação

> **Na aula:** Discutiremos as respostas, faremos exercício em grupo sobre os incidentes da TechNova (dados perdidos + state perdido), e depois partiremos para os laboratórios práticos.


---

## Referências

### Amazon RDS

- Amazon Web Services. **What is Amazon RDS?**. AWS Documentation. Disponível em: [https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html)
- Amazon Web Services. **Creating a DB instance**. AWS Documentation. Disponível em: [https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateDBInstance.html](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateDBInstance.html)
- Amazon Web Services. **Working with DB subnet groups**. AWS Documentation. Disponível em: [https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html)
- Amazon Web Services. **Multi-AZ deployments**. AWS Documentation. Disponível em: [https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html)

### Terraform — RDS

- HashiCorp. **AWS DB Instance Resource**. Terraform Registry. Disponível em: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance)
- HashiCorp. **AWS DB Subnet Group Resource**. Terraform Registry. Disponível em: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group)

### Terraform — Remote State

- HashiCorp. **Backend Configuration**. Terraform Documentation. Disponível em: [https://developer.hashicorp.com/terraform/language/settings/backends/configuration](https://developer.hashicorp.com/terraform/language/settings/backends/configuration)
- HashiCorp. **S3 Backend**. Terraform Documentation. Disponível em: [https://developer.hashicorp.com/terraform/language/settings/backends/s3](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
- HashiCorp. **State Locking**. Terraform Documentation. Disponível em: [https://developer.hashicorp.com/terraform/language/state/locking](https://developer.hashicorp.com/terraform/language/state/locking)

### Amazon S3 e DynamoDB

- Amazon Web Services. **Amazon S3 User Guide**. AWS Documentation. Disponível em: [https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html)
- Amazon Web Services. **Amazon DynamoDB Developer Guide**. AWS Documentation. Disponível em: [https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html)
