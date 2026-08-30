# Trabalho de Fixação (TF) — Aula 05: RDS e Remote State

## Desafio

Demonstrar domínio completo dos conceitos de banco de dados gerenciado (RDS) e remote state (S3 + DynamoDB) criando uma infraestrutura completa com dados persistentes e state protegido. Publique via Pull Request no repositório da disciplina.

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Prazo** | 1 semana a partir da data da aula |
| **Forma de entrega** | Pull Request (PR) para o repositório da disciplina |
| **Pasta de entrega no fork** | `entregas/aula-05/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com link do repositório + evidências |
| **Arquivos do projeto** | No repositório `unifaat-devops-portfolio`, pasta `aula-05/` |

### Como Entregar via Pull Request

1. Faça um **fork** do repositório da disciplina (se ainda não fez)
2. Clone o seu fork localmente
3. Crie a pasta `entregas/aula-05/SEU-RA/`
4. Adicione **apenas** o arquivo `entrega.md` (modelo abaixo) — os arquivos do projeto ficam no `unifaat-devops-portfolio`
5. Faça commit e push para o seu fork
6. Abra um **Pull Request** para o repositório original

**Modelo do arquivo `entrega.md`:**

```markdown
# Entrega — Aula 05: RDS e Remote State

**Aluno:** [Seu nome completo]  
**RA:** [Seu RA]  
**Data:** [Data da entrega]

## Repositório

- URL: https://github.com/SEU-USUARIO/unifaat-devops-portfolio

## Evidências

- [ ] VPC com subnets públicas e privadas em 2 AZs
- [ ] RDS PostgreSQL (db.t3.micro) nas subnets privadas
- [ ] EC2 t2.micro na subnet pública, conectando ao RDS
- [ ] Security Groups corretos (porta 5432 apenas da VPC)
- [ ] Remote State configurado (S3 + DynamoDB)
- [ ] State armazenado no S3 (evidência abaixo)
- [ ] Conexão EC2 → RDS via psql (evidência abaixo)
- [ ] `terraform destroy` executado após evidências

## Evidência do State no S3

[Cole aqui o output do `aws s3 ls` ou screenshot]

## Evidência da Conexão EC2 → RDS

[Cole aqui o output do psql ou screenshot]
```

---

## Exercício: Infraestrutura Completa com Data Layer e Remote State

### Descrição

Provisione a infraestrutura completa da TechNova com:

1. **Rede (VPC):** VPC com 2 subnets privadas em AZs diferentes + 1 subnet pública
2. **Banco de Dados (RDS):** PostgreSQL db.t3.micro nas subnets privadas
3. **Servidor (EC2):** t2.micro na subnet pública, capaz de conectar ao RDS
4. **Segurança:** Security Groups corretamente configurados (EC2→RDS na porta 5432)
5. **Remote State:** Backend S3 + DynamoDB configurado e funcional

### Requisitos Técnicos

#### Rede (VPC)
- [ ] VPC com CIDR `10.0.0.0/16`
- [ ] 1 subnet pública (para EC2) com rota para Internet Gateway
- [ ] 2 subnets privadas em **AZs diferentes** (para DB Subnet Group)
- [ ] Internet Gateway configurado
- [ ] Route Table associada à subnet pública
- [ ] Todas as subnets com tags adequadas

#### Banco de Dados (RDS)
- [ ] DB Subnet Group com as 2 subnets privadas
- [ ] Security Group para RDS (porta 5432 apenas da VPC ou do SG do EC2)
- [ ] RDS PostgreSQL 15 com `instance_class = "db.t3.micro"`
- [ ] `allocated_storage = 20`, `storage_type = "gp2"`
- [ ] `multi_az = false`, `publicly_accessible = false`
- [ ] `storage_encrypted = true`
- [ ] `skip_final_snapshot = true` (para lab)
- [ ] `db_name`, `username`, `password` configurados via variáveis

#### Servidor (EC2)
- [ ] EC2 t2.micro na subnet pública
- [ ] Security Group para EC2 (SSH porta 22, API porta 3000)
- [ ] Key pair configurado para acesso SSH
- [ ] PostgreSQL client instalado (via user_data ou manualmente)
- [ ] Capaz de conectar ao RDS via psql

#### Remote State
- [ ] Bucket S3 criado com:
  - Encriptação server-side habilitada
  - Versionamento habilitado
  - Block Public Access ativado (todos = true)
- [ ] Tabela DynamoDB com partition key `LockID` (String)
- [ ] Backend `s3` configurado no `providers.tf` com `encrypt = true` e `dynamodb_table`
- [ ] State armazenado no S3 (provado via `aws s3 ls` ou screenshot)

#### Organização do Código
- [ ] `.gitignore` correto (inclui `.terraform/`, `*.tfstate`, `terraform.tfvars`, `*.pem`)
- [ ] Variáveis sensíveis marcadas com `sensitive = true`
- [ ] Outputs úteis (RDS endpoint, EC2 IP, connection string)
- [ ] Tags em todos os recursos (`Name`, `Project`, `Aula`)
- [ ] Código organizado em múltiplos arquivos (.tf separados por responsabilidade)

---

### Evidências Obrigatórias

Inclua no seu PR as seguintes evidências:

#### 1. State remoto funcional
```bash
# Evidência: state está no S3
aws s3 ls s3://SEU-BUCKET/caminho/
# OU screenshot do console S3 mostrando o arquivo terraform.tfstate
```

#### 2. Conexão EC2 → RDS
```bash
# Evidência: psql conecta do EC2 ao RDS
psql -h <ENDPOINT> -U <USER> -d <DB> -c "SELECT version();"
# OU screenshot mostrando o prompt do PostgreSQL
```

#### 3. Dados persistentes
```bash
# Evidência: dados criados e consultados
psql -h <ENDPOINT> -U <USER> -d <DB> -c "SELECT * FROM orders;"
# Mostrando que tabela e dados existem
```

#### 4. Terraform plan limpo
```bash
terraform plan
# Deve mostrar "No changes" após apply (infraestrutura em dia)
```

---

> **⚠️ NÃO inclua no PR:**
> - `terraform.tfvars` (contém senha!)
> - `*.tfstate` ou `*.tfstate.backup`
> - Diretório `.terraform/`
> - Chaves privadas (`.pem`)

---

### Critérios de Avaliação

| Critério | Peso | Descrição |
|----------|------|-----------|
| VPC e Networking | 15% | VPC, subnets (2 privadas em AZs diferentes + 1 pública), IGW, routes |
| RDS PostgreSQL | 25% | DB Subnet Group, SG, instância configurada corretamente (Free Tier) |
| EC2 + Conexão | 15% | EC2 funcional, conecta ao RDS, Security Groups corretos |
| Remote State | 25% | S3 + DynamoDB configurados, state migrado, backend funcional |
| Segurança | 10% | Encriptação, block public access, variáveis sensíveis, .gitignore |
| Organização | 10% | Código limpo, tags, outputs, arquivos separados, evidências claras |

**Nota mínima para aprovação:** 60%

---

### Desafios Extras (Bônus)

Para quem quer ir além (não obrigatório, mas agrega pontos extras):

1. **Melhor Security Group:** Em vez de abrir porta 5432 para toda a VPC (CIDR), referencie o Security Group do EC2 como origem
2. **Terraform Workspaces:** Configure workspaces (dev/prod) com states separados no mesmo bucket
3. **IAM Role para EC2:** Crie Instance Profile com permissão mínima para o EC2
4. **Automation:** User data que instala psql E testa a conexão automaticamente (salvando resultado em log)

---

### Lembretes Importantes

> **⚠️ DESTRUA TUDO APÓS CAPTURAR EVIDÊNCIAS:**
>
> ```bash
> # 1. Destruir infraestrutura principal
> cd seu-projeto/
> terraform destroy
>
> # 2. Esvaziar bucket S3 (inclui versões)
> aws s3 rm s3://SEU-BUCKET --recursive
> # Para versões: use o comando da Parte 8.2 do Lab
>
> # 3. Destruir infraestrutura de backend
> cd backend/
> terraform destroy
>
> # 4. Verificar no console: nenhum recurso restante
> ```
>
> Recursos esquecidos geram custo na sua conta AWS!

> **📋 Fluxo de trabalho recomendado:**
> 1. Crie a infraestrutura de backend (S3 + DynamoDB) primeiro
> 2. Crie a infraestrutura principal (VPC + RDS + EC2) com backend configurado
> 3. Teste a conexão EC2 → RDS
> 4. Capture evidências (screenshots/outputs)
> 5. Faça commit e push para branch
> 6. Crie o PR para `entregas/aula-05/RA/`
> 7. Destrua tudo (terraform destroy + esvaziar bucket)

---

### Prazo e Formato de Entrega

- **Prazo:** 1 semana após a aula
- **Formato:** Pull Request no repositório da disciplina
- **Branch:** `entregas/aula-05/SEU-RA`
- **Target:** branch `main`
- **Destino dos arquivos:** `entregas/aula-05/SEU-RA/`
- **Título do PR:** `[Aula 05] RA: SEU-RA - SEU NOME`

---

## Entrega

### 1 — Publicar no portfólio

```bash
cd unifaat-devops-portfolio
git checkout -b feature/aula-05-rds-remote-state
# ... desenvolva os arquivos .tf em aula-05/ ...
git add aula-05/
git commit -m "feat(aula-05): RDS + Remote State com Terraform"
git checkout main
git merge feature/aula-05-rds-remote-state
git push origin main
git push origin feature/aula-05-rds-remote-state
```

### 2 — Registrar entrega no fork da disciplina

```bash
cd /caminho/para/seu-fork-da-disciplina
git checkout -b entregas/aula-05/SEU-RA
mkdir -p entregas/aula-05/SEU-RA
# Crie o arquivo entrega.md (modelo na seção Informações de Entrega)
git add entregas/aula-05/SEU-RA/entrega.md
git commit -m "feat(aula-05): entrega TF - SEU NOME (RA: SEU-RA)"
git push -u origin entregas/aula-05/SEU-RA
```

Abra o Pull Request no GitHub com:
- **Título:** `[Aula 05] RA: SEU-RA - SEU NOME`
- **Base:** `main`
- **Compare:** `entregas/aula-05/SEU-RA`

> **⚠️ Lembrete final:** Execute `terraform destroy` ANTES de fazer o PR. As evidências provam que funcionou. Não deixe recursos rodando na AWS!

> **Dúvidas?** Abra uma issue no repositório ou pergunte no canal da disciplina.