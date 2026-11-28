# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Matheus Gabriel Correa Braga Viana  
**RA:** 6325053  
**Data:** 01/10/2026  
**Ferramentas de IA utilizadas:** ChatGPT e Claude. O uso de cada ferramenta está descrito no relatório.

## Repositório do Projeto

- **URL:** https://github.com/Matiasdocs/prova-primeiro-bimestre-devops
- **Commit de referência:** [2676dbd](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/commit/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6)
- **README:** [Identificação, arquitetura e instruções de execução](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/README.md)
- **Relatório:** [relatorio.md — respostas às quatro questões](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/relatorio.md)
- **Evidências:** [Pasta evidencias](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/tree/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias)

Os links abaixo apontam para a versão do projeto identificada pelo commit de referência.

## Checklist de Evidências

- [x] Repositório público com README (nome + RA) e .gitignore
- [x] Mínimo de 6 commits com Conventional Commits + feature branch
- [x] API com **CRUD completo** de reservas (POST, GET, GET/:id, PUT, DELETE) + /health
- [x] Rotas de CRUD gravando no **banco PostgreSQL** (não em memória)
- [x] Dockerfile funcional da API de Reservas
- [x] docker-compose.yml (API + PostgreSQL) subindo com um comando
- [x] Terraform modularizado (vpc, security-group, ec2, rds)
- [x] **RDS PostgreSQL provisionado** nas subnets privadas (banco da API na nuvem)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] Uso de LabRole/LabInstanceProfile (sem criar IAM próprio)
- [x] terraform validate e terraform plan sem erros
- [x] relatorio.md completo (4 questões)
- [x] terraform destroy executado após evidências

## Evidências

### Código e histórico Git

- [API: rotas, validações e consultas PostgreSQL](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/app/src/index.js)
- [Dockerfile da API](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/app/Dockerfile)
- [Docker Compose: API, PostgreSQL, rede, volume e healthchecks](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/docker-compose.yml)
- [Módulos Terraform: vpc, security-group, ec2 e rds](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/tree/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/infra/modules)
- [Bootstrap do backend S3 e DynamoDB](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/tree/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/infra/backend)
- [Provider e configuração do backend principal](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/infra/providers.tf)
- [Arquivos ignorados pelo Git](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/.gitignore)
- [Histórico do repositório](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/commits/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6)
- [Registro do histórico Git](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/git-log.txt) e [registro de merges](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/git-merges.txt). Esses arquivos são capturas do histórico feitas durante a execução; os commits posteriores também aparecem no histórico do repositório.
- [Merge da feature branch feat/prova-devops](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/commit/7b35d26)

### Histórico de uso das IAs

- [Histórico de prompts e interações com as IAs](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/Historico%20prompts%20-%20I.A.txt).
- O relato do uso de ChatGPT e Claude está nas respostas do `relatorio.md`, especialmente na Questão 2.

### Docker, CRUD e persistência local

| Evidência | Arquivo |
|---|---|
| Build da imagem da API | [docker-build.txt](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/docker-build.txt) |
| API e PostgreSQL com status healthy no Compose | [compose-ps.txt](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/compose-ps.txt) |
| CRUD completo, validações e códigos HTTP | [crud-local.txt](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/crud-local.txt) |
| Reserva preservada após recriar os serviços mantendo o volume | [persistencia-local.json](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/persistencia-local.json) |
| Consulta da reserva diretamente no PostgreSQL local | [postgresql-local.txt](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/postgresql-local.txt) |

### Terraform e aplicação na AWS

| Evidência | Arquivo |
|---|---|
| Validação da infraestrutura principal | [terraform-validate.txt](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/terraform-validate.txt) |
| Validação do bootstrap do backend | [terraform-backend-validate.txt](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/terraform-backend-validate.txt) |
| Plano registrado durante o provisionamento | [terraform-plan.txt](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/terraform-plan.txt) |
| Outputs da EC2, RDS e aplicação | [terraform-outputs.txt](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/terraform-outputs.txt) |
| Log do deploy, build Docker na EC2 e conexão ao RDS | [docker-aws.txt](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/docker-aws.txt) |
| /health com status ok e database ok | [health-aws.json](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/health-aws.json) |
| CRUD completo e validações na URL da EC2 | [crud-aws.txt](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/crud-aws.txt) |
| Reserva no RDS recuperada após recriação do container da API | [persistencia-rds.json](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/persistencia-rds.json) |

O arquivo `terraform-plan.txt` registra uma etapa do provisionamento com **2 recursos a criar**: a instância RDS e seu subnet group. A implantação e os testes posteriores estão documentados pelos outputs, pelo log de deploy e pelas respostas da API.

### Capturas do console AWS

| Configuração | Captura |
|---|---|
| Subnets privadas | [aws-subnets-privadas.png](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/aws-subnets-privadas.png) |
| Security Group da EC2: portas 22 e 3000 | [aws-sg-ec2-22-3000.png](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/aws-sg-ec2-22-3000.png) |
| Security Group do RDS: porta 5432 com origem no SG da EC2 | [aws-sg-rds-5432.png](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/aws-sg-rds-5432.png) |
| Conectividade do RDS e acesso público desativado | [aws-rds-conectividade.png](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/aws-rds-conectividade.png) |
| Criptografia do RDS | [aws-rds-criptografia.png](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/aws-rds-criptografia.png) |
| Versionamento e criptografia do bucket S3 de state | [aws-s3-versionamento-criptografia.png](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/aws-s3-versionamento-criptografia.png) |
| Bloqueio de acesso público do bucket S3 | [aws-s3-bloqueio-publico.png](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/aws-s3-bloqueio-publico.png) |
| Tabela DynamoDB para locking do state | [aws-dynamodb-locks.png](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/aws-dynamodb-locks.png) |

### Destruição após os testes

- [terraform-destroy.txt](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/terraform-destroy.txt): `Destroy complete! Resources: 25 destroyed.`
- [terraform-backend-destroy.txt](https://github.com/Matiasdocs/prova-primeiro-bimestre-devops/blob/2676dbd30aaabcf1d593d4626c0b6cf1d46ea3c6/evidencias/terraform-backend-destroy.txt): `Destroy complete! Resources: 2 destroyed.`

A infraestrutura principal foi destruída antes do backend. As evidências foram salvas durante a execução; a URL da API registrada nos outputs corresponde ao ambiente utilizado nos testes, que já foi removido.
