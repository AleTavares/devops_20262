# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Andreyh Rodrigues de Souza

**RA:** 6325231

**Data:** 01/10/2026

**Ferramenta de IA utilizada:** Codex (OpenAI)

## Repositório do Projeto

- URL: https://github.com/Andreyh117/prova-primeiro-bimestre-devops

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

Saídas e registros da execução, disponíveis no repositório público do projeto:

- [Histórico Git, merge e branches](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/git-log.txt) · [Refs e pais do merge](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/git-branches.txt)
- [Build Docker](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/docker-build.txt) · [Execução Docker](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/docker-run.txt)
- [Compose e serviços saudáveis](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/compose-ps.txt) · [Persistência do volume](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/compose-persistencia.txt)
- [Terraform validate](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/terraform-validate.txt) · [Terraform plan](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/terraform-plan.txt)
- [Backend e locking](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/backend-locking.txt) · [State e outputs AWS](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/terraform-outputs.txt)
- [RDS privado](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/aws-rds.txt) · [Segurança AWS](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/aws-seguranca.txt)
- [CRUD na EC2/RDS](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/api-aws.txt) · [SQL e persistência RDS](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/rds-crud.txt)
- [Relatório com quatro questões](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/relatorio.md)
- [Destroy Terraform](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/terraform-destroy.txt) · [Auditoria após destroy](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/aws-pos-destroy.txt) · [Limpeza do backend](https://github.com/Andreyh117/prova-primeiro-bimestre-devops/blob/76b01a48c77d43fe2f9083fcc4a2daf2ebede9dd/evidencias/backend-teardown.txt)
