# Laboratório Parte 2 — S3 Backend + DynamoDB Lock (Spec-Driven com Kiro)

## Missão

Proteger o state do Terraform da TechNova usando o Kiro como copiloto: criar uma Spec que descreve a necessidade de remote state, revisar os artefatos gerados, e implementar a infraestrutura de backend (S3 + DynamoDB) via workflow Spec-Driven. Ao final, o aluno terá o state migrado para o S3 e terá praticado o uso de IA como ferramenta de produtividade para IaC.

**Duração:** ~120 minutos

**Resultado esperado:** State do Terraform armazenado de forma segura no S3, com locking via DynamoDB, gerado com auxílio do Kiro e validado manualmente.

---

## Pré-requisitos

- AWS CLI configurado (`aws sts get-caller-identity` funciona)
- Terraform instalado (`terraform version` funciona)
- Kiro instalado e funcional ([download](https://kiro.dev/))
- Laboratório Parte 1 concluído (infraestrutura RDS provisionada)
- Conexão com internet

> **⚠️ Nota:** Se o Kiro não estiver disponível, o professor indicará uma alternativa equivalente.

---

## Parte 1 — Criando a Spec no Kiro (25 minutos)

### 1.1 Abrir o projeto no Kiro

Crie uma pasta separada para a infraestrutura de backend:

```bash
mkdir -p ~/labs/aula-05-backend
cd ~/labs/aula-05-backend
git init
```

Abra a pasta `~/labs/aula-05-backend` no Kiro.

### 1.2 Iniciar uma sessão Spec

No Kiro, clique em **New Session** e selecione o tipo **Spec**.

### 1.3 Descrever o que você quer construir

Na sessão Spec, use o seguinte prompt:

> **Prompt:**
> ```
> Preciso criar a infraestrutura de backend para armazenar o Terraform state
> de forma segura e compartilhada na AWS. Os requisitos são:
>
> 1. Um bucket S3 para armazenar o arquivo terraform.tfstate com:
>    - Nome com sufixo aleatório para ser globalmente único
>    - Versionamento habilitado (para rollback)
>    - Encriptação server-side com KMS
>    - Block Public Access em todas as 4 configurações (true)
>    - Lifecycle prevent_destroy = false (é um lab)
>
> 2. Uma tabela DynamoDB para locking do state com:
>    - Partition key chamada "LockID" do tipo String
>    - billing_mode = PAY_PER_REQUEST
>
> 3. Outputs que exportem:
>    - Nome do bucket S3
>    - ARN do bucket S3
>    - Nome da tabela DynamoDB
>
> 4. Organização:
>    - Provider AWS na região us-east-1
>    - Terraform >= 1.0, provider hashicorp/aws ~> 5.0
>    - Tags em todos os recursos: Project = "TechNova", Purpose = "Terraform Remote State"
>    - Código separado em arquivos: main.tf, s3.tf, dynamodb.tf, outputs.tf
> ```

### 1.4 Revisar o documento de Requisitos

O Kiro irá gerar um documento de requisitos. Verifique:

- [ ] Bucket S3 com versionamento, encriptação e block public access?
- [ ] DynamoDB com partition key `LockID` (String)?
- [ ] Outputs com nome do bucket e da tabela?
- [ ] Provider AWS correto (us-east-1, ~> 5.0)?

Se algo estiver faltando, corrija antes de avançar.

### 1.5 Revisar o documento de Design

Verifique a estrutura proposta:

- [ ] Arquivos separados por responsabilidade (s3.tf, dynamodb.tf)?
- [ ] Uso de `random_id` para nome único do bucket?
- [ ] Variáveis de entrada previstas (project_name)?

### 1.6 Revisar as Tarefas de Implementação

Verifique se as tarefas cobrem:

1. Configuração do provider
2. Criação do bucket S3 com todas as configurações
3. Criação da tabela DynamoDB
4. Outputs

Se alguma tarefa estiver faltando, peça ao Kiro para adicionar.

✅ **Checkpoint:** Spec completa e revisada.

---

## Parte 2 — Gerando o Código com Kiro (20 minutos)

### 2.1 Executar as tarefas

Autorize o Kiro a executar as tarefas. Use o modo **Supervised** para acompanhar cada arquivo sendo criado.

### 2.2 Verificar os arquivos gerados

A estrutura esperada ao final:

```
aula-05-backend/
├── main.tf              ← Provider e configuração Terraform
├── s3.tf                ← Bucket S3 com versionamento, encriptação, block public access
├── dynamodb.tf          ← Tabela DynamoDB para locking
├── outputs.tf           ← Outputs (bucket name, ARN, table name)
└── variables.tf         ← Variáveis (project_name, etc.)
```

### 2.3 Validar com checklist

| Item | ✅/❌ | Observação |
|------|:---:|-----------|
| Provider AWS correto (`us-east-1`, `~> 5.0`)? | | |
| Bucket S3 com `random_id` ou sufixo único? | | |
| Versionamento habilitado no bucket? | | |
| Encriptação SSE-KMS habilitada? | | |
| Block Public Access (4 configurações = true)? | | |
| DynamoDB com `hash_key = "LockID"` (String)? | | |
| DynamoDB com `billing_mode = "PAY_PER_REQUEST"`? | | |
| Tags em todos os recursos? | | |
| Outputs exportando bucket name e table name? | | |

### 2.4 Intervir quando necessário

Se o Kiro errou ou omitiu algo, corrija via chat:

> **Exemplos de intervenção:**
> - "O bucket não tem block_public_acls configurado. Adicione o recurso aws_s3_bucket_public_access_block."
> - "A tabela DynamoDB precisa do attribute com nome LockID e tipo S. Corrija."
> - "Faltou o random_id para gerar sufixo único no nome do bucket."

### 2.5 Validar a sintaxe

```bash
terraform init
terraform validate
```

Se houver erros, cole no chat do Kiro e peça para corrigir.

✅ **Checkpoint:** Código gerado, validado e sem erros.

---

## Parte 3 — Aplicando a Infraestrutura de Backend (15 minutos)

### 3.1 Planejar

```bash
terraform plan
```

Verifique que o plano mostra a criação de:
- 1 bucket S3
- 1 configuração de versionamento
- 1 configuração de encriptação
- 1 block public access
- 1 tabela DynamoDB
- 1 random_id

### 3.2 Aplicar

```bash
terraform apply
```

Confirme com `yes`. Anote os outputs:

```
s3_bucket_name = "technova-terraform-state-a1b2c3d4"
dynamodb_table_name = "technova-terraform-locks"
```

> **⚠️ Guarde esses valores!** Serão usados na próxima parte.

### 3.3 Verificar no console AWS

- Acesse S3 → verifique que o bucket existe com versionamento e encriptação
- Acesse DynamoDB → verifique que a tabela existe com partition key `LockID`

✅ **Checkpoint:** Infraestrutura de backend criada na AWS.

---

## Parte 4 — Configurando o Backend no Projeto Principal (20 minutos)

### 4.1 Voltar ao projeto principal

```bash
cd ~/labs/aula-05-rds
```

### 4.2 Pedir ao Kiro para configurar o backend

Abra o projeto `aula-05-rds` no Kiro e peça (em sessão Vibe, não Spec):

> **Prompt:**
> "Adicione a configuração de backend S3 ao meu providers.tf. O bucket é `[COLE SEU BUCKET]`, a key é `aula-05/terraform.tfstate`, a região é `us-east-1`, encrypt = true, e a tabela DynamoDB é `[COLE SUA TABELA]`."

### 4.3 Revisar o que o Kiro gerou

O `providers.tf` deve conter algo como:

```hcl
terraform {
  backend "s3" {
    bucket         = "technova-terraform-state-a1b2c3d4"
    key            = "aula-05/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "technova-terraform-locks"
  }

  # ... required_providers ...
}
```

Verifique que os nomes do bucket e da tabela estão corretos (use os outputs da Parte 3).

### 4.4 Migrar o state

```bash
terraform init -migrate-state
```

Quando perguntado "Do you want to copy existing state to the new backend?", responda **yes**.

### 4.5 Verificar migração

```bash
# State local deve estar vazio
cat terraform.tfstate

# State está no S3
aws s3 ls s3://SEU-BUCKET/aula-05/

# Terraform funciona normalmente
terraform state list
terraform plan
# Deve mostrar "No changes"
```

✅ **Checkpoint:** State migrado com sucesso para o S3.

---

## Parte 5 — Testando Colaboração e Locking (20 minutos)

### 5.1 Simular outro desenvolvedor

```bash
cp -r ~/labs/aula-05-rds ~/labs/aula-05-rds-dev2
cd ~/labs/aula-05-rds-dev2
rm -f terraform.tfstate terraform.tfstate.backup
terraform init
```

### 5.2 Verificar que "Dev 2" acessa o mesmo state

```bash
terraform state list
terraform plan
# Deve mostrar "No changes"
```

### 5.3 Testar locking

Abra **dois terminais** simultaneamente:

**Terminal 1:**
```bash
cd ~/labs/aula-05-rds
terraform apply -auto-approve
```

**Terminal 2 (executar DURANTE o apply do Terminal 1):**
```bash
cd ~/labs/aula-05-rds-dev2
terraform plan
```

**Resultado esperado no Terminal 2:**
```
Error: Error acquiring the state lock
Lock Info:
  ID:        xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  Operation: OperationTypeApply
  Who:       seu-usuario@seu-host
```

✅ **Locking funciona!** O DynamoDB impediu conflito de escrita simultânea.

### 5.4 Verificar segurança do bucket

```bash
# Encriptação
aws s3api get-bucket-encryption --bucket SEU-BUCKET

# Versionamento
aws s3api get-bucket-versioning --bucket SEU-BUCKET

# Block Public Access
aws s3api get-public-access-block --bucket SEU-BUCKET
```

✅ **Checkpoint:** Colaboração e locking validados, segurança conferida.

---

## Parte 6 — Reflexão: Spec-Driven vs Manual (10 minutos)

### 6.1 Comparar com o Lab Parte 1

No Lab Parte 1 (RDS), você criou a infraestrutura seguindo um roteiro passo a passo manual. Neste Lab (Remote State), você usou o Kiro com Spec. Compare:

| Aspecto | Lab 1 (manual) | Lab 2 (Spec-Driven) |
|---------|---------------|---------------------|
| Tempo para ter o código pronto | | |
| Quantidade de erros de sintaxe | | |
| Você entendeu o que foi gerado? | | |
| Precisou corrigir algo do Kiro? | | |
| Qual abordagem preferiu? | | |

### 6.2 Quando usar Spec vs Manual?

Reflita:
- Para qual tipo de infraestrutura o Spec-Driven funciona melhor? (nova, do zero)
- Para qual tipo o manual é mais adequado? (ajuste fino, debugging)
- O que acontece se você aceitar o código do Kiro sem validar?

### 6.3 O que o Kiro acertou e errou?

Registre:
- **Acertou:** (ex: estrutura de arquivos, providers, outputs)
- **Errou/Omitiu:** (ex: alguma configuração de segurança, nome incorreto)
- **Precisou de intervenção:** (ex: block public access, billing_mode)

---

## Parte 7 — Cleanup (10 minutos)

### 7.1 Destruir infraestrutura principal

```bash
cd ~/labs/aula-05-rds
terraform destroy
```

### 7.2 Esvaziar e destruir infraestrutura de backend

```bash
# Esvaziar bucket (incluindo versões)
BUCKET="SEU-BUCKET-AQUI"
aws s3api list-object-versions \
  --bucket $BUCKET \
  --query 'Versions[].{Key:Key,VersionId:VersionId}' \
  --output text | while read key version; do
    aws s3api delete-object \
      --bucket $BUCKET \
      --key "$key" \
      --version-id "$version"
done

# Destruir backend
cd ~/labs/aula-05-backend
terraform destroy
```

### 7.3 Limpar diretórios temporários

```bash
rm -rf ~/labs/aula-05-rds-dev2
```

### 7.4 Verificar no console AWS

Confirme que não há recursos restantes:
- S3 → bucket removido
- DynamoDB → tabela removida
- EC2 → nenhuma instância
- RDS → nenhum banco

---

## Troubleshooting

### Problema: "S3 bucket does not exist"

**Causa:** O bucket referenciado no backend não foi criado ainda.

**Solução:** Complete as Partes 1-3 (criar backend) antes de configurar o backend no projeto principal.

### Problema: "Error acquiring the state lock"

**Causa:** Apply anterior falhou e o lock ficou preso.

**Solução:**
```bash
terraform force-unlock <LOCK_ID>
```

### Problema: "AccessDenied" ao acessar S3

**Causa:** Usuário IAM sem permissão no bucket.

**Solução:** Verifique que tem `s3:GetObject`, `s3:PutObject`, `s3:ListBucket` no bucket e `dynamodb:GetItem`, `dynamodb:PutItem`, `dynamodb:DeleteItem` na tabela.

### Problema: "BucketNotEmpty" ao destruir

**Causa:** Bucket ainda tem objetos (versões do state).

**Solução:** Esvazie o bucket primeiro (Parte 7.2).

---

## Checklist de Validação

Antes de encerrar, verifique:

- [ ] Spec criada e revisada no Kiro (requisitos + design + tarefas)
- [ ] Código de backend gerado pelo Kiro e validado
- [ ] Bucket S3 criado com encriptação, versionamento e block public access
- [ ] DynamoDB table criada com partition key "LockID"
- [ ] Backend configurado no projeto principal
- [ ] State migrado com sucesso (`terraform init -migrate-state`)
- [ ] Colaboração funciona (Dev 2 acessa mesmo state)
- [ ] Locking funciona (apply simultâneo bloqueado)
- [ ] Segurança verificada (encryption, versioning, public access block)
- [ ] Reflexão Spec-Driven vs Manual preenchida
- [ ] Todos os recursos destruídos
- [ ] Nenhum recurso órfão na AWS

---

## Resumo: Spec-Driven para IaC

| Cenário | Recomendação |
|---------|-------------|
| Criar infraestrutura nova do zero | ✅ Spec-Driven — gera rápido, você revisa |
| Adicionar recurso a infraestrutura existente | ✅ Chat Vibe — prompt rápido, ajuste pontual |
| Debugging de erro no Terraform | ✅ Chat Vibe — cole o erro, peça análise |
| Refatorar código Terraform existente | ⚠️ Avalie — Kiro pode ajudar mas precisa de contexto |
| Configurações de segurança críticas | ⚠️ Sempre valide com docs oficiais |
| Aceitar código sem entender | ❌ Nunca — você é responsável pela infraestrutura |

---

*Parabéns! Você criou a infraestrutura de Remote State usando Spec-Driven Development com Kiro. A TechNova agora tem dados persistentes (RDS, Lab 1) e state protegido (S3 + DynamoDB, Lab 2). Na Tarefa de Fixação, você combinará ambos em uma entrega completa.*
