# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Henri da Silva Despezzi
**RA:** 6325064
**Data:** 01/10/2026
**Ferramenta de IA utilizada:** Claude (Anthropic)

## Repositório do Projeto

- URL: https://github.com/HenriSD/prova-primeiro-bimestre-devops

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

Todas as evidências em texto estão versionadas na pasta `evidencias/` do repositório do projeto:

- `evidencias/docker-build.txt` — build da imagem Docker da API (multi-stage, usuário não-root)
- `evidencias/compose-ps.txt` e logs do Compose — API + PostgreSQL subindo juntos, com healthcheck
- `evidencias/terraform-plan.txt` — plano completo do Terraform (17 recursos: VPC, subnets, SGs, EC2, RDS)
- `evidencias/terraform-outputs.txt` — outputs do apply (IP da EC2, endpoint do RDS)
- `evidencias/api-logs-aws.txt` — logs da API rodando na EC2, conectada ao RDS via SSL
- `evidencias/teste-api-aws.txt` — testes de CRUD feitos via curl contra a API já na nuvem (IP público), confirmando leitura/gravação real no RDS

A infraestrutura foi provisionada de verdade na AWS Academy Learner Lab (VPC, EC2, RDS),
testada de ponta a ponta (API pública → EC2 → RDS em subnet privada), e destruída em
seguida (`terraform destroy`, 18 recursos removidos) para não consumir créditos do Lab.