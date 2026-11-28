# Entrega — Aula 11 (TF)

**Aluno:** Matheus Mantovani
**RA:** 1120245
**Data:** 2026-10-24

## Fork do projeto

- URL: https://github.com/Manntto/implement_Moodle
- Commit desta semana: https://github.com/Manntto/implement_Moodle/commit/ba55e88

## O que foi feito nesta aula

Nesta semana avancei no desafio técnico do Moodle em três frentes principais:

**1. Ambiente Docker local:** O Moodle está rodando localmente com `docker compose up -d` na pasta `docker/`. O ambiente sobe o Moodle 4.x com PostgreSQL 15, acessível em `http://localhost:8080`. Validei o acesso às rotas `/` e `/login/index.php` retornando HTTP 200.

**2. Documento de arquitetura:** Preenchi o `docs/architecture-design.md` com a arquitetura completa da solução AWS: VPC 10.0.0.0/16 com 1 subnet pública (us-east-1a) para a EC2 e 2 subnets privadas (us-east-1a, us-east-1b) para o RDS. EC2 t3.medium com `LabInstanceProfile`, RDS PostgreSQL 15 db.t3.micro com `publicly_accessible = false`. Incluí justificativas de segurança e estimativa de custo.

**3. Workflow terraform-plan.yml:** Implementei o stub do workflow com `terraform init -backend=false`, `terraform validate` e `terraform plan` acionado por `workflow_dispatch` e PRs. Configurei os secrets `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` e `AWS_SESSION_TOKEN` para o Learner Lab.

O próximo passo é executar o `terraform apply` com o Lab ativo para provisionar a EC2 e o RDS, e então validar o deploy do Moodle na nuvem via `user_data.sh`.

## Dificuldades encontradas

A principal dificuldade foi lidar com as credenciais temporárias do Learner Lab no workflow de CI. As credenciais expiram em ~4 horas, o que inviabiliza pipelines que rodam automaticamente em qualquer momento. A solução foi usar `workflow_dispatch` (acionamento manual) para o `terraform-plan.yml`, garantindo que seja executado apenas quando as credenciais estiverem frescas. Em produção real, usaria OIDC com IAM Role para eliminar completamente o gerenciamento manual de credenciais.
