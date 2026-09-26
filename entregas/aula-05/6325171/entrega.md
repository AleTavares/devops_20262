# Entrega - Aula 05: RDS e Remote State

**Aluno:** Nicolas de Jesus Silva
**RA:** 6325171  
**Data:** 19/09/2026

## Repositorio

- URL: https://github.com/NxcolasDev/unifaat-devops-portfolio
- Pasta: `aula-05/`
- Branch de desenvolvimento: `feature/aula-05-rds-remote-state`

## Evidencias

- [x] VPC com uma subnet publica e duas privadas em duas AZs
- [x] RDS PostgreSQL `db.t3.micro` privado e criptografado
- [x] EC2 `t2.micro` na subnet publica
- [x] Security Group do RDS aceitando PostgreSQL somente do SG da EC2
- [x] Remote State em S3 com criptografia, versionamento e bloqueio de acesso publico
- [x] DynamoDB `nxcolasdev-technova-locks` ativo para locking
- [x] `user_data.sh` entregue com cliente PostgreSQL
- [x] State remoto confirmado no S3
- [x] SSH na EC2 confirmado
- [x] Conexao EC2 -> RDS via `psql` confirmada
- [x] Dados persistentes consultados na tabela `orders`
- [x] `terraform plan` posterior ao apply sem alteracoes
- [x] `terraform destroy` concluido: 13 recursos destruidos

## Mapa das evidencias

| Arquivo | Evidencia |
|---|---|
| `evidencias/01-plan-inicial-13-recursos.png` | Plan inicial com 13 recursos para criar. |
| `evidencias/02-conexao-psql-e-criacao-tabela.png` | Cliente PostgreSQL e criacao da tabela. |
| `evidencias/03-remote-state-s3-listagem.png` | `terraform.tfstate` armazenado no bucket S3. |
| `evidencias/04-s3-seguranca-e-criptografia.png` | Versionamento, criptografia e Public Access Block do S3. |
| `evidencias/05-dynamodb-lock-ativo.png` | Tabela DynamoDB de locking ativa com chave `LockID`. |
| `evidencias/06-terraform-state-list.png` | Recursos controlados pelo state remoto. |
| `evidencias/07-plan-sem-alteracoes.png` | Plan posterior ao apply sem mudanças. |
| `evidencias/08-ssh-ec2-e-select-version.png` | SSH na EC2 e `SELECT version()` do PostgreSQL. |
| `evidencias/09-dados-persistentes-orders.png` | Consulta dos dados persistidos em `orders`. |
| `evidencias/10-destroy-complete-13-recursos.png` | Destroy concluído com 13 recursos destruídos. |

## Arquivos Terraform

- `backend/`: bootstrap do bucket S3 e da tabela DynamoDB.
- `providers.tf`: provider AWS e backend S3 remoto.
- `main.tf`: arquivo coordenador da configuração.
- `vpc.tf`: VPC, subnets, Internet Gateway e rotas.
- `security.tf`: Security Groups da EC2 e do RDS.
- `rds.tf`: subnet group e instância PostgreSQL.
- `ec2.tf`: AMI, key pair e instância EC2.
- `user_data.sh`: instalação do cliente PostgreSQL no primeiro boot.
- `outputs.tf` e `variables.tf`: valores exportados e parâmetros.

## Observacao

A infraestrutura foi aplicada, validada com SSH e `psql`, conferida com plan sem alterações e destruída ao final. Senhas, estados Terraform, chaves privadas e credenciais AWS não fazem parte do repositório.

Este arquivo deve ser copiado para `entregas/aula-05/6325171/entrega.md` no fork da disciplina.
