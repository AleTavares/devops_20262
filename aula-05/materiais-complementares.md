# Materiais Complementares — Aula 05: RDS e Remote State

## Documentação Oficial

### Amazon RDS
- [Amazon RDS User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html) — Guia completo do serviço
- [RDS PostgreSQL User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html) — Específico para PostgreSQL
- [RDS Free Tier](https://aws.amazon.com/rds/free/) — Limites e elegibilidade do Free Tier
- [RDS Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html) — Melhores práticas oficiais
- [DB Subnet Groups](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html) — Configuração de rede

### Terraform — RDS
- [aws_db_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) — Recurso Terraform para RDS
- [aws_db_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) — Recurso Terraform para DB Subnet Group
- [RDS Terraform Examples](https://github.com/hashicorp/terraform-provider-aws/tree/main/examples/rds) — Exemplos oficiais

### Terraform — Backend e State
- [Backend Configuration](https://developer.hashicorp.com/terraform/language/settings/backends/configuration) — Configuração de backends
- [S3 Backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3) — Documentação do backend S3
- [State Management](https://developer.hashicorp.com/terraform/language/state) — Conceitos de state
- [State Commands](https://developer.hashicorp.com/terraform/cli/commands/state) — CLI commands para state
- [State Locking](https://developer.hashicorp.com/terraform/language/state/locking) — Mecanismo de locking

### Amazon S3
- [S3 User Guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html) — Guia completo
- [S3 Versioning](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html) — Versionamento de objetos
- [S3 Encryption](https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html) — Encriptação server-side
- [S3 Free Tier](https://aws.amazon.com/s3/pricing/) — 5 GB gratuitos por 12 meses

### Amazon DynamoDB
- [DynamoDB Developer Guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html) — Guia completo
- [Creating Tables](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/WorkingWithTables.Basics.html) — Criação de tabelas
- [DynamoDB Free Tier](https://aws.amazon.com/dynamodb/pricing/) — 25 GB sempre gratuito

---

## Vídeos em Português

### RDS
- [AWS RDS - Banco de Dados Gerenciado (LinuxTips)](https://www.youtube.com/results?search_query=aws+rds+tutorial+portugues) — Conceitos e prática
- [Terraform + RDS PostgreSQL (Caio Delgado)](https://www.youtube.com/results?search_query=terraform+rds+postgresql+portugues) — Terraform com RDS
- [RDS vs EC2 Database - Quando usar cada um](https://www.youtube.com/results?search_query=rds+vs+ec2+database+portugues) — Comparação prática

### Remote State
- [Terraform Remote State com S3 (LinuxTips)](https://www.youtube.com/results?search_query=terraform+remote+state+s3+portugues) — Configuração completa
- [Terraform Backend S3 + DynamoDB (Mateus Müller)](https://www.youtube.com/results?search_query=terraform+backend+s3+dynamodb+portugues) — Tutorial passo a passo
- [Gerenciamento de State no Terraform](https://www.youtube.com/results?search_query=terraform+state+management+portugues) — Conceitos e comandos

---

## Vídeos em Inglês

### RDS
- [AWS RDS Tutorial (freeCodeCamp)](https://www.youtube.com/results?search_query=aws+rds+tutorial+freecodecamp) — Tutorial completo
- [AWS re:Invent — Amazon RDS Under the Hood](https://www.youtube.com/results?search_query=aws+reinvent+rds+under+the+hood) — Como RDS funciona internamente
- [Terraform AWS RDS (Cloud Quick Labs)](https://www.youtube.com/results?search_query=terraform+aws+rds+quick+lab) — Lab prático

### Remote State
- [Terraform Remote State (HashiCorp)](https://www.youtube.com/results?search_query=hashicorp+terraform+remote+state+tutorial) — Tutorial oficial
- [Terraform S3 Backend Complete Guide](https://www.youtube.com/results?search_query=terraform+s3+backend+complete+guide) — Guia completo
- [Terraform State Management Best Practices](https://www.youtube.com/results?search_query=terraform+state+management+best+practices) — Boas práticas

---

## Ferramentas Úteis

### Clientes PostgreSQL
- [pgAdmin 4](https://www.pgadmin.org/) — Cliente GUI oficial do PostgreSQL (gratuito)
- [DBeaver](https://dbeaver.io/) — Cliente universal de banco de dados (gratuito, suporta múltiplos bancos)
- [psql (CLI)](https://www.postgresql.org/docs/current/app-psql.html) — Cliente de linha de comando (já usado no lab)

> **Nota:** Para conectar pgAdmin ou DBeaver ao RDS em subnet privada, você precisaria de um SSH tunnel via EC2, ou usar VPN. No nosso lab, usamos `psql` direto do EC2.

### AWS Console
- [Console RDS](https://console.aws.amazon.com/rds/) — Gerenciar instâncias RDS
- [Console S3](https://console.aws.amazon.com/s3/) — Verificar bucket e state
- [Console DynamoDB](https://console.aws.amazon.com/dynamodb/) — Verificar tabela de locks

### Terraform
- [Terraform Cloud](https://app.terraform.io/) — Alternativa ao S3 backend (gerenciado pela HashiCorp)
- [tfenv](https://github.com/tfutils/tfenv) — Gerenciador de versões do Terraform
- [tflint](https://github.com/terraform-linters/tflint) — Linter para código Terraform

---

## Artigos e Blog Posts

### RDS
- [Choosing Between Amazon RDS, Aurora, and Self-Managed Databases](https://aws.amazon.com/blogs/database/) — Blog AWS Database
- [RDS Security Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.html) — Segurança do RDS
- [PostgreSQL vs MySQL on RDS](https://aws.amazon.com/compare/the-difference-between-mysql-vs-postgresql/) — Comparação de engines

### Remote State
- [How to Manage Terraform State (Gruntwork)](https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa) — Artigo referência sobre state
- [Terraform S3 Backend Best Practices](https://developer.hashicorp.com/terraform/language/settings/backends/s3) — Documentação oficial
- [The Terraform State File: What It Is and How to Protect It](https://spacelift.io/blog/terraform-state) — Segurança do state
- [Terraform State Locking with DynamoDB](https://developer.hashicorp.com/terraform/language/state/locking) — Como locking funciona

---

## Exercícios Extras de Prática

### Nível Básico
1. Crie um RDS MySQL (em vez de PostgreSQL) e conecte do EC2
2. Mude o `allocated_storage` de 20 para 25 e observe o `terraform plan` (in-place update)
3. Adicione um segundo key no S3 backend (ex: `staging/terraform.tfstate`) — entenda a organização

### Nível Intermediário
4. Configure Parameter Group customizado para o PostgreSQL (ex: altere `max_connections`)
5. Habilite Performance Insights no RDS e observe métricas no console
6. Use `terraform workspace` para criar ambientes dev/prod com states separados
7. Implemente IAM policy restritiva: permita acesso ao bucket S3 apenas para usuários específicos

### Nível Avançado
8. Configure read replica do RDS (entenda replicação assíncrona)
9. Implemente backup cross-region do state (replicação S3)
10. Crie módulo Terraform reutilizável para RDS + Remote State
11. Configure notifications (SNS) quando alguém modifica o state no S3

---

## Conceitos para a Próxima Aula

Na **Aula 06**, avançaremos para temas que constroem sobre o que aprendemos:

- **Load Balancers (ALB):** Distribuir tráfego entre múltiplos EC2
- **Auto Scaling Groups:** Escalar EC2 automaticamente baseado em demanda
- **Target Groups:** Conectar ALB aos EC2

A base que construímos (VPC + RDS + Remote State) será fundamental — todos esses novos componentes serão adicionados à mesma arquitetura, e o state remoto garantirá que toda a equipe pode colaborar com segurança.

---

## Referência Rápida de Comandos

### Terraform State
```bash
terraform state list              # Listar todos os recursos
terraform state show <resource>   # Detalhes de um recurso
terraform state pull              # Baixar state remoto
terraform state push              # Upload state para remoto
terraform state rm <resource>     # Remover recurso do state
terraform state mv <old> <new>    # Mover/renomear no state
terraform import <resource> <id>  # Importar recurso existente
terraform force-unlock <id>       # Forçar liberação de lock
```

### AWS CLI — S3
```bash
aws s3 ls s3://bucket/             # Listar objetos
aws s3 cp s3://bucket/file ./      # Baixar arquivo
aws s3 rm s3://bucket/ --recursive # Esvaziar bucket
aws s3api get-bucket-versioning --bucket name  # Ver versionamento
aws s3api get-bucket-encryption --bucket name  # Ver encriptação
```

### AWS CLI — RDS
```bash
aws rds describe-db-instances       # Listar instâncias RDS
aws rds describe-db-subnet-groups   # Listar DB Subnet Groups
aws rds reboot-db-instance --db-instance-identifier name  # Reiniciar RDS
```

### PostgreSQL (psql)
```bash
psql -h <host> -U <user> -d <db> -p 5432  # Conectar
\l                                          # Listar databases
\dt                                         # Listar tabelas
\d <table>                                  # Descrever tabela
\q                                          # Sair
```