# Checklist de Entrega - Prova DevOps

**Aluno(a):** Grazielli Monteiro
**RA:** "6325165"
**Repositório GitHub:** https://github.com/grazykkj/prova-primeiro-bimestre-devops

---

## Checklist do Projeto

- [x] **Parte 1 - Versionamento Git e Organização:** Repositório Git com `.gitignore`, README na raiz e histórico com Conventional Commits.
- [x] **Parte 2 - Dockerfile:** Multi-stage build para Node.js com usuário não-root (`USER node`) e `.dockerignore`.
- [x] **Parte 3 - Docker Compose:** Containers de API e PostgreSQL com volume nomeado (`pgdata`), rede isolada (`reservas_net`) e healthcheck.
- [x] **Parte 4 - Terraform IaC:** Módulos para VPC (2 AZs), Security Groups (menor privilégio), EC2 (`LabInstanceProfile`) e RDS (`db.t3.micro` privado).
- [x] **Remote State:** Arquivos de backend em `infra/backend/` configurados para S3 + DynamoDB.
- [x] **Evidências:** Pasta `evidencias/` contendo `compose-ps.txt`, `docker-build.txt` e `terraform-plan.txt`.
- [x] **Documentação:** Arquivos `relatorio.md` e `entrega.md` completos.

---

Os arquivos completos com os logs de execução e validação da infraestrutura e dos contêineres estão salvos no diretório `/evidencias` do repositório principal:

- `evidencias/docker-build.txt` (Build do container da API)
- `evidencias/compose-ps.txt` (Status dos contêineres ativos localmente)
- `evidencias/terraform-plan.txt` (Planejamento da infraestrutura na AWS)
- `evidencias/terraform-apply.txt` (Provisionamento dos módulos na AWS)
- `evidencias/terraform-destroy.txt` (Destruição dos recursos para economia de créditos)