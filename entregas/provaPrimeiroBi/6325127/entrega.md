# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Marcos Eduardo dos Santos Sousa
**RA:** 6325127
**Data:** 01/10/2026
**Ferramenta de IA utilizada:** Claude (Claude Code)

## Repositório do Projeto

- URL: https://github.com/MarcosSantt/prova-primeiro-bimestre-devops

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

- Build e execução local: `evidencias/docker-build.txt`, `evidencias/compose-ps.txt`, `evidencias/api-local.txt`
- Bootstrap do remote state (S3 + DynamoDB): `evidencias/bootstrap-apply.txt`
- Terraform plan/apply da infraestrutura: `evidencias/terraform-plan.txt`, `evidencias/terraform-apply-inicial.txt`, `evidencias/terraform-apply.txt`
- API funcionando na AWS: `evidencias/api-aws.txt`
- Isolamento do RDS (acessível só pelo SG da EC2): `evidencias/rds-isolamento.txt`
- Destroy da infraestrutura e do backend: `evidencias/terraform-destroy.txt` (22 recursos destruídos), `evidencias/terraform-destroy-backend.txt` (5 recursos destruídos)
- Screenshots (`evidencias/screenshots/01` a `15`): build da imagem, `docker compose ps`, terraform plan/apply, API respondendo na AWS, console EC2/RDS/SG/S3, terraform destroy

Todos os outputs e screenshots completos estão disponíveis na pasta [`evidencias/`](https://github.com/MarcosSantt/prova-primeiro-bimestre-devops/tree/main/evidencias) do repositório do projeto.
