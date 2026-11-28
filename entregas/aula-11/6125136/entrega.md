# Entrega — Aula 11 (TF)

**Aluno:** Hector Marcelo Pedroso Dos Santos
**RA:** 6125136
**Data:** 21/11/2026

## Fork do projeto

- URL: https://github.com/hectorbackfront/implement_Moodle
- Commit desta semana: https://github.com/hectorbackfront/implement_Moodle/commit/c3b78975c129659a42993b7e7fb2dc593d4b3139

## O que foi feito nesta aula

Até aqui o fork estava igual ao template: não havia Terraform nem documento de arquitetura. Nesta semana avancei em duas frentes, ambas no commit acima:

- **`docs/architecture-design.md`** (entrega eliminatória): criei a partir do template e preenchi todas as seções, sem nenhum `TODO` restante. Inclui diagrama em ASCII (VPC, 2 subnets públicas e 2 privadas em 2 AZs, IGW, route table, EC2, RDS, Security Groups e o fluxo Internet → IGW → EC2 → RDS), decisões de design, componentes, segurança, escalabilidade e estimativa de custo.
- **Terraform, módulo `networking`**: VPC `10.0.0.0/16`, 2 subnets públicas e 2 privadas, Internet Gateway, route table pública, `sg-app` (80 público e 22 restrito a uma variável) e `sg-db` (5432 somente a partir do `sg-app`). Também criei `versions.tf` (provider AWS `~> 5.0`), `main.tf`, `variables.tf` e `outputs.tf` na raiz. `terraform fmt -check -recursive` e `terraform validate` passam. Ajustei o `.gitignore` para ignorar `.terraform/`.

**Ainda não está pronto:** módulos `compute` (EC2 com `LabInstanceProfile` e `user_data.sh`) e `database` (RDS PostgreSQL 15 privado), o `terraform plan` (ainda não rodei, depende das credenciais do Learner Lab), o workflow `terraform-plan.yml`, a estimativa de custo na AWS Pricing Calculator (fiz uma estimativa manual com preços públicos) e a validação do Docker local com screenshot.

**Próximo passo:** implementar `database` e `compute`, depois o workflow de plan.

## Dificuldades encontradas

- **Diferenças entre o `CHALLENGE.md` e o enunciado da prova.** O template pede `t3.medium`, 1 subnet pública e `LabRole`; a prova pede `t3.micro`, 2 subnets públicas e `LabInstanceProfile`. Percebi isso ao comparar os dois textos e segui o enunciado da prova no documento e no Terraform.
- **Por que o RDS exige 2 AZs.** Entendi que o `aws_db_subnet_group` precisa de subnets em pelo menos duas AZs, mesmo com uma única instância; por isso criei duas subnets privadas.
- **`.terraform/` fora do `.gitignore`.** Ao rodar `terraform init`, o binário do provider (centenas de MB) apareceria no commit. Notei antes do commit e adicionei `.terraform/` ao `.gitignore`.
- **Dúvida:** o documento de arquitetura descreve `compute` e `database` que ainda não implementei; deixei isso explícito no próprio documento para não afirmar algo que ainda não existe.

## Uso de IA

Usei o Claude Code como apoio: ele gerou o rascunho do documento de arquitetura e do módulo `networking`, que revisei, e orientou a organização das entregas. As decisões de rede e a conferência com o enunciado foram minhas.
