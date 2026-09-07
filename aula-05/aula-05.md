---
marp: true
paginate: true
backgroundColor: '#F5F7FA'
footer: 'DevOps — UniFAAT 2026-2 | Prof. Alexandre Tavares'
style: |
  section {
    font-family: 'Segoe UI', Arial, sans-serif;
    font-size: 17px;
    padding: 35px 48px 28px 48px;
    color: #333333;
  }
  h1 {
    color: #0D2B45;
    border-bottom: 3px solid #F58220;
    padding-bottom: 5px;
    font-size: 1.45em;
    margin-bottom: 8px;
    margin-top: 0;
  }
  h2 { color: #1B3A5C; font-size: 1.2em; margin: 4px 0; }
  h3 { color: #2E86C1; font-size: 0.98em; margin: 4px 0; }
  p, li { margin: 2px 0; line-height: 1.35; }
  ul, ol { margin: 3px 0; padding-left: 18px; }
  strong { color: #F58220; }
  pre { margin: 4px 0; font-size: 0.72em; line-height: 1.25; }
  code { background-color: #e8eef4; color: #1B3A5C; font-size: 0.82em; padding: 1px 4px; }
  pre code { font-size: 1em; padding: 0; }
  table { font-size: 0.82em; width: 100%; margin: 4px 0; border-collapse: collapse; }
  table th { background-color: #1B3A5C; color: white; padding: 3px 7px; }
  table td { padding: 2px 7px; border-bottom: 1px solid #ddd; }
  blockquote { font-size: 0.88em; border-left: 4px solid #F58220; padding-left: 10px; margin: 4px 0; color: #555; }
  section.title {
    background-color: #1B3A5C;
    color: white !important;
    text-align: center;
    justify-content: center;
    padding: 60px;
  }
  section.title h1 { color: #F58220 !important; border-bottom: 3px solid #F58220; font-size: 2.2em; }
  section.title h2 { color: #F58220 !important; font-size: 1.3em; }
  section.title h3 { color: #ccc !important; }
  section.title p { color: #ccc !important; }
  section.title strong { color: #F58220 !important; }
  footer { color: #888; font-size: 0.62em; }
  img { max-height: 340px; display: block; margin: 6px auto; }
---

<!-- _class: title -->

# Aula 05 — RDS e Remote State

**DevOps — Centro Universitário UniFAAT**
Prof. Alexandre Tavares | Semestre 2026-2

---

# Por que RDS + Remote State?

**Evolução do projeto TechNova:**
- Aula 04: VPC + EC2 com a API rodando na nuvem ✅
- **Aula 05: dados persistentes (RDS) + proteção do state (S3 + DynamoDB)**

**Dois problemas críticos:**
> "Se eu reiniciar o servidor, os pedidos ainda existem?" — **Não**, os dados estão em memória.

> "O laptop do Rafael foi roubado com o `terraform.tfstate`. Como gerenciamos a infra agora?" — Sem o state, o Terraform fica cego.

**A aula:** primeiro a **camada de dados** (RDS), depois a **proteção do mapa da infraestrutura** (Remote State).

> **Fio condutor:** o Spec-Driven continua como método. No Lab 2 você usará o Kiro Spec para criar o backend S3 + DynamoDB.

---

# Objetivos de Aprendizagem

### RDS — Banco de Dados Gerenciado
- Compreender o conceito de banco gerenciado e suas vantagens
- Configurar DB Subnet Groups (subnets privadas, 2 AZs)
- Provisionar RDS PostgreSQL com Terraform
- Conectar o EC2 ao RDS dentro da VPC

### Remote State
- Entender o papel do `terraform.tfstate` e os riscos do state local
- Configurar backend S3 para state remoto
- Usar DynamoDB para locking (evitar conflitos)
- Migrar o state local para o backend remoto

---

# O Problema: Dados em Memória

Na Aula 04, a API da TechNova ficou no EC2 — mas os dados estão na **memória RAM**:

![Dados em memória no EC2](img/EC2TEcnova.png)

**Cenários de perda de dados:**
- `terraform destroy` + `apply` → dados zerados
- Instância reinicia por manutenção AWS → dados zerados
- Auto Scaling substitui a instância → dados zerados
- Erro que crasheia a aplicação → dados zerados

> **Solução:** banco de dados externo e persistente, separado da camada de aplicação.

---

# Self-Managed vs Managed Database

| Aspecto | Self-Managed (EC2) | Managed (RDS) |
|---------|--------------------|---------------|
| Instalação | Você instala e configura | AWS provisiona pronto |
| Patches/Updates | Sua responsabilidade | AWS automático |
| Backups | Você configura scripts | Automáticos (diários) |
| Alta Disponibilidade | Você replica | Multi-AZ com 1 clique |
| Monitoramento | Você instala | CloudWatch integrado |
| Failover | Você implementa | Automático (Multi-AZ) |
| Acesso SSH ao servidor | ✅ Sim | ❌ Não |

> **Para a TechNova:** RDS é a escolha óbvia — equipe pequena, sem DBA, precisa de confiabilidade. Use self-managed apenas com requisitos muito específicos (SO, compliance, engine não suportada).

---

# O que é Amazon RDS?

**RDS** (Relational Database Service) é o serviço de banco de dados relacional gerenciado da AWS. Você foca no schema e nas queries; a AWS cuida da infraestrutura.

![Amazon RDS](img/rds.png)

> Usaremos **PostgreSQL 15** — open source, popular e amplamente suportado.

---

# DB Subnet Group — Por Que 2 AZs?

Um **DB Subnet Group** é o grupo de subnets onde o RDS pode ser posicionado. A AWS **exige pelo menos 2 subnets em AZs diferentes**:

![VPC / DB Subnet Group](img/vpc.png)

- Mesmo com `multi_az = false`, a AWS exige 2 AZs
- Se ativar Multi-AZ, o standby vai para a outra AZ
- Requisito de resiliência — **não é opcional**

---

# Security Group para RDS

O RDS fica em subnet **privada**, aceitando conexões apenas da aplicação EC2:

![Subnet privada](img/subnet.png)

```hcl
ingress {
  from_port       = 5432
  to_port         = 5432
  protocol        = "tcp"
  security_groups = [aws_security_group.ec2_sg.id]  # apenas o EC2
}
```

> **Melhor prática:** referencie o Security Group do EC2 em vez de abrir para o CIDR inteiro da VPC.

---

# Connection String — Conectando ao RDS

Após criar o RDS, você recebe um **endpoint** (DNS) para conexão:

![Endpoint do RDS](img/analiseRDS.png)

```bash
# Instalar cliente PostgreSQL no EC2
sudo yum install -y postgresql15

# Conectar ao RDS (de dentro da VPC)
psql -h technova-db.abc123.us-east-1.rds.amazonaws.com \
     -U technova_admin -d technova -p 5432
```

---

# Multi-AZ — Conceito (não usaremos)

Réplica standby em outra AZ, com failover automático em ~60s. A aplicação usa o mesmo endpoint.

![Multi-AZ](img/multiaz.png)

> **Custo:** dobra os recursos. **NÃO usaremos** no Learner Lab — mas é importante conhecer o conceito para produção.

---

# Configuração do RDS no Learner Lab

| Recurso | Configuração |
|---------|--------------|
| Instância | `db.t3.micro` |
| Armazenamento | 20 GB SSD (gp2) |
| Multi-AZ | ❌ Não usar |

**Pontos de atenção:**
- Use `db.t3.micro` (não `db.t2.micro`, depreciado)
- `allocated_storage = 20`
- `multi_az = false`
- RDS leva **5-10 minutos** para ficar pronto — tenha paciência
- Sempre `terraform destroy` ao final

---

# Remote State — O Problema do State Local

Ao rodar `terraform apply`, o Terraform cria o `terraform.tfstate` local — o **mapa da infraestrutura**:

```json
{
  "resources": [{
    "type": "aws_instance", "name": "api",
    "instances": [{ "attributes": {
      "id": "i-0abc123", "public_ip": "54.123.45.67"
    }}]
  }]
}
```

**Sem esse arquivo, o Terraform:**
- Não sabe o que existe na AWS
- Tenta criar tudo de novo (duplicação)
- Não consegue destruir o que já existe
- Perde a capacidade de `plan` e `diff`

---

# Cenário Rafael — O Laptop Roubado

![Laptop roubado](img/laptopRoubado.png)

> O `terraform.tfstate` é tão importante quanto o código. Perder o state = perder o mapa de tudo que existe na nuvem.

---

# Problemas do State Local

| Problema | Consequência |
|----------|--------------|
| Ponto único de falha | Perdeu o arquivo = perdeu o controle |
| Sem colaboração | Só quem tem o arquivo roda Terraform |
| Sem locking | Dois `apply` simultâneos = state corrompido |
| Sem histórico | Não consegue reverter |
| Sem segurança | Senhas em plain text no arquivo |

---

# Solução: Remote State com S3 + DynamoDB

![Solução Remote State](img/solucaoState.png)

**S3** armazena o state (centralizado, versionado, encriptado, controlado por IAM).
**DynamoDB** fornece o locking (evita escrita simultânea).

---

# S3 Backend — Configuração

```hcl
terraform {
  backend "s3" {
    bucket         = "technova-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "technova-terraform-locks"
  }
}
```

| Parâmetro | Descrição |
|-----------|-----------|
| `bucket` | Bucket S3 (deve existir antes) |
| `key` | Caminho do state dentro do bucket |
| `encrypt` | Encriptação server-side |
| `dynamodb_table` | Tabela para locking |

> **Chicken-and-egg:** o bucket e a tabela precisam existir **antes** de configurar o backend.

---

# DynamoDB Locking

![Locking com DynamoDB](img/remoteStateDynamo.png)

- Partition Key: `LockID` (String)
- O Terraform cria o lock ao iniciar `apply` e remove ao terminar
- Segundo `apply` simultâneo é bloqueado

> **Analogia:** é a chave "ocupado" do banheiro do avião — só um `apply` por vez escreve no state.

---

# Migração de State Local → Remoto

```bash
# 1. Você tem state local (terraform.tfstate)
# 2. Adiciona o bloco backend "s3" no providers.tf
# 3. Executa:

terraform init -migrate-state

# Terraform pergunta:
# "Do you want to copy existing state to the new backend?"
# Responda: yes

# 4. Pronto! State agora está no S3
```

> **No Spec-Driven (Lab 2):** o Kiro gera o `backend.tf` com S3 + DynamoDB. Você valida antes de migrar.

---

# Spec-Driven no Lab 2

No Lab Parte 2, você usará o **Kiro Spec** para criar o backend remoto:

| Etapa | O que você faz |
|---|---|
| **1. Requisitos** | Descreve: bucket S3 versionado/encriptado + tabela DynamoDB de lock |
| **2. Design** | Kiro propõe a estrutura dos recursos |
| **3. Tarefas** | Kiro ordena: bucket → versionamento → encriptação → DynamoDB → backend |
| **4. Código** | Kiro gera; você valida com checklist |

**Checklist de validação:**
- Bucket com versionamento e Block Public Access
- Encriptação habilitada (`encrypt = true`)
- Tabela DynamoDB com `LockID` (String)
- Credenciais do Learner Lab válidas (`source aws-creds.sh`)

---

# Resumo dos Conceitos

| Conceito | Descrição |
|----------|-----------|
| RDS | Banco relacional gerenciado pela AWS |
| DB Subnet Group | Grupo de subnets (2+ AZs) para o RDS |
| Multi-AZ | Réplica standby para alta disponibilidade |
| Connection String | URL de conexão (host:port/database) |
| terraform.tfstate | Mapa entre código e recursos reais |
| Backend S3 | State remoto em bucket S3 |
| DynamoDB Locking | Previne modificações simultâneas |
| State Migration | Mover state local → backend remoto |

---

# Recursos no AWS Academy Learner Lab

Todos os recursos são criados no **AWS Academy Learner Lab**, sem custo para o aluno:

| Componente | Observação |
|------------|-----------|
| VPC, Subnets, IGW, Route Tables | Recursos de rede — leves |
| EC2 t2.micro / RDS db.t3.micro | Instâncias mínimas |
| S3 (state) / DynamoDB (lock) | Consumo mínimo |
| Multi-AZ RDS / NAT Gateway | ⚠️ **NÃO usar** |

> **Sempre** `terraform destroy` ao final, delete o bucket S3 e a tabela DynamoDB manualmente, e encerre a sessão do Learner Lab.

---

# Referências e Próximos Passos

**Referências:**
- Amazon RDS — [docs.aws.amazon.com/AmazonRDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html)
- Terraform S3 Backend — [developer.hashicorp.com/terraform/language/settings/backends/s3](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
- Terraform State Locking — [developer.hashicorp.com/terraform/language/state/locking](https://developer.hashicorp.com/terraform/language/state/locking)
- AWS Academy Learner Lab (ambiente da disciplina)

**Para a próxima aula:**
- Completar o TF desta aula (portfólio + PR + execução no AWS Academy)
- Estudar o `TA.md` da Aula 06
- Executar `terraform destroy` e limpar bucket/tabela

**Próxima aula:**
**Aula 06 — Terraform Modules**
Reutilização e composição de infraestrutura com módulos.
