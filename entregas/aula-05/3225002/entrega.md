# Entrega — Aula 05: RDS e Remote State

**Aluno:** José Henrique Teixeira Luiz
**RA:** 3225002
**Data:** 10/09/2026

## Repositório

- URL: https://github.com/zzin742/unifaat-devops-portfolio
- Pasta: [`aula-05/`](https://github.com/zzin742/unifaat-devops-portfolio/tree/main/aula-05)

## Evidências

- [x] VPC com subnets públicas e privadas em 2 AZs
- [x] RDS PostgreSQL (db.t3.micro) nas subnets privadas
- [x] EC2 t2.micro na subnet pública, conectando ao RDS
- [x] Security Groups corretos (porta 5432 apenas da VPC)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] State armazenado no S3 (evidência abaixo)
- [x] Conexão EC2 → RDS via psql (evidência abaixo)
- [x] `terraform destroy` executado após evidências

## Evidência do State no S3

```
=== EVIDENCIA 1: STATE REMOTO NO S3 ===

--- arquivo do state no bucket ---
2026-09-10 21:33:35      40486 terraform.tfstate

--- versionamento (protege contra state corrompido) ---
{
    "Status": "Enabled"
}

--- criptografia em repouso ---
{
    "SSEAlgorithm": "AES256"
}

--- bloqueio de acesso publico (4 eixos) ---
{
    "BlockPublicAcls": true,
    "IgnorePublicAcls": true,
    "BlockPublicPolicy": true,
    "RestrictPublicBuckets": true
}

--- tabela de lock no DynamoDB ---
{
    "Nome": "technova-tfstate-lock-3225002",
    "PartitionKey": "LockID",
    "Status": "ACTIVE"
}
```

## Evidência da Conexão EC2 → RDS

```
=== TESTE AUTENTICADO: EC2 -> RDS via psql ===
=== 1. versao do servidor ===
                                              version                                              
---------------------------------------------------------------------------------------------------
 PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC) 12.4.0, 64-bit
(1 row)

=== 2. criando tabela e dados ===
CREATE TABLE
INSERT 0 3
=== 3. consultando os dados persistidos ===
 id |   cliente    |       produto        |  valor  |          criado_em           
----+--------------+----------------------+---------+------------------------------
  1 | Ana Souza    | Notebook TechNova 14 | 4299.00 | 2026-09-11 00:34:28.01786+00
  2 | Bruno Lima   | Monitor 27 polegadas | 1899.90 | 2026-09-11 00:34:28.01786+00
  3 | Carla Mendes | Teclado mecanico     |  459.00 | 2026-09-11 00:34:28.01786+00
(3 rows)

=== 4. confirmando que os dados estao no RDS, nao em memoria ===
 total_pedidos 
---------------
             3
(1 row)
```

---

## Desafios extras implementados

**1 — Security Group por identidade, não por endereço.** A porta 5432 aceita o
*Security Group da EC2* como origem, em vez do CIDR da VPC:

```hcl
ingress {
  from_port       = 5432
  to_port         = 5432
  protocol        = "tcp"
  security_groups = [aws_security_group.ec2.id]   # não cidr_blocks
}
```

Pelo CIDR, qualquer recurso futuro dentro de `10.0.0.0/16` herdaria acesso ao
banco sem ninguém decidir isso.

**3 — Instance Profile.** O Learner Lab assume o papel `voclabs`, que não cria
entidades de IAM (`iam:CreateUser` retorna AccessDenied — verificado). Reusei o
`LabInstanceProfile` via data source. O benefício se mantém: a EC2 recebe
credencial temporária pelo metadata service, sem access key em disco.

**4 — User data testa a conexão.** Instala o psql e verifica alcance à porta
5432, gravando em `/var/log/technova-rds-check.log`.

## Decisões de projeto

**O banco é privado por dois mecanismos, não um.** `publicly_accessible = false`
tira o endereço público; as subnets privadas também não têm rota para o IGW.
Qualquer um dos dois sem o outro deixaria brecha.

**Sem NAT Gateway**, conforme o README da aula: cobra por hora e continua
cobrando entre as sessões do Learner Lab. O RDS não precisa de saída para a
internet.

**A senha do banco não entra no user data.** O user data é legível no endpoint
de metadados por qualquer processo da instância. Por isso o teste automático
verifica alcance de rede, e o teste autenticado roda por SSH com a senha vindo
do ambiente:

```bash
PGPASSWORD='...' /usr/local/bin/testar-rds.sh
```

**`db_password` sem valor default.** Sem definição, o Terraform para e pergunta,
em vez de subir um banco com credencial previsível. O valor real fica em
`terraform.tfvars`, que está no `.gitignore`.

## Limpeza

Executada ao final: `terraform destroy` na infra principal, esvaziamento do
bucket (o versionamento impede o destroy com objetos dentro) e `terraform
destroy` no backend. Conta verificada sem RDS nem EC2 remanescentes.

---

## ⚠️ Achado: a SCP do Learner Lab bloqueia o provider da AWS

O `terraform apply` do backend falha na criação do bucket, mesmo com o bucket
sendo criado com sucesso:

```
Error: reading S3 Bucket (...) object lock configuration:
api error AccessDenied: User: .../voclabs/... is not authorized to perform:
s3:GetBucketObjectLockConfiguration ... with an explicit deny in a
service control policy
```

**Não é permissão faltando — é negação explícita na Service Control Policy da
organização do Academy.** O provider AWS v5, logo após criar um `aws_s3_bucket`,
lê a configuração de *object lock* do bucket para popular o state. Essa leitura
é barrada, o recurso é marcado como *tainted* e o apply aborta.

O bucket, porém, **existe** — só o passo de leitura falhou.

### Contorno aplicado

```bash
terraform untaint aws_s3_bucket.state
terraform apply -refresh=false
```

`-refresh=false` pula a leitura bloqueada. As outras chamadas
(`GetBucketVersioning`, `GetBucketEncryption`, `GetPublicAccessBlock`) são
permitidas, então versionamento, criptografia e bloqueio público foram aplicados
normalmente — como comprova a evidência acima.

O mesmo vale para o `terraform destroy` do backend.

A infraestrutura principal (VPC, RDS, EC2) **não** é afetada: o `plan` com
refresh completo roda sem erro e retorna `No changes`.

## Resultado da execução

| Etapa | Resultado |
|---|---|
| Backend (S3 + DynamoDB) | 6 recursos criados |
| Infra principal (VPC + RDS + EC2) | **12 recursos criados** |
| Migração do state para o S3 | `Successfully configured the backend "s3"` |
| RDS | `available` após ~11 min · PostgreSQL 15.17 |
| Conexão EC2 → RDS | ✅ `psql` autenticado, tabela `orders` com 3 registros |
| `terraform plan` final | ✅ `No changes` |
| Destroy | 12 + 6 recursos destruídos |
| Conta ao final | RDS 0 · EC2 0 · buckets 0 · tabelas 0 · VPCs 0 |

**Conta AWS do lab:** `925874601971` · região `us-east-1`
**Identidade:** `arn:aws:sts::925874601971:assumed-role/voclabs/...`
