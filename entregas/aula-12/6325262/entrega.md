# Entrega — Aula 12 (TF)

**Aluno:** Gabriel de Souza Oliveira
**RA:** 6325262
**Data:** 24/11/2026

## Fork do projeto

- URL: https://github.com/biel334/implement_Moodle
- Commit desta semana: https://github.com/biel334/implement_Moodle/commit/50daead2ecc42bbb65e23da41363083881136b57

## O que foi feito nesta aula

Estou com **cerca de metade do desafio concluída**: toda a parte de escrita do projeto está pronta, mas ainda falta tudo que depende de rodar o ambiente. O desafio pede: (1) Moodle local com Docker, (2) Terraform com os módulos `networking`, `compute` e `database`, (3) `user_data.sh` que instala o Docker e sobe o Moodle na EC2, (4) `docs/architecture-design.md` (entrega eliminatória) e (5) workflows de CI/CD, incluindo o `terraform-plan.yml`.

**Até onde avancei** (feito com o Kiro, no commit acima, em `main`):
- Terraform completo: `versions.tf` (provider AWS `~> 5.0`), `variables.tf` e `outputs.tf` raiz e os três módulos com `main.tf`, `variables.tf` e `outputs.tf`. O Kiro registrou `terraform init` e `terraform validate` passando.
- `user_data.sh` escrito (Docker + Compose + Moodle) e `LabRole` usado via data source, sem criar IAM.
- `docs/architecture-design.md` preenchido a partir do template, sem blocos `<!-- TODO: -->`.
- `terraform-plan.yml` implementado (`workflow_dispatch`, init/plan, resumo no `GITHUB_STEP_SUMMARY`).
- Os 64 testes `pytest` do repositório passam. No acompanhamento do Kiro, 69 de 87 itens estão marcados.

**O que ainda não está pronto:** validar o Docker local (`docker compose up` + `health-check.sh`); rodar `terraform plan` com credenciais reais; configurar os secrets no GitHub e executar os workflows; `terraform apply`, health check na EC2 e `terraform destroy`.

**Próximo passo:** conseguir credenciais do Learner Lab, subir o Docker local, rodar o plan e o apply e fechar os itens pendentes.

## Dificuldades encontradas

1. **Docker Desktop não abre no meu computador (Windows)**, então não consegui validar o ambiente local nem rodar o health check. Pretendo testar de outra forma (WSL2/outra máquina).
2. **AWS Academy mostrou "This course has ended" em 17/11** ao tentar entrar no Learner Lab. Sem credenciais, não rodei `terraform plan`/`apply` nem os workflows. Vou procurar o professor para saber como reativar o acesso.
3. **Os créditos do Kiro acabaram em 17/11** (só renovam em 01/12). Como o projeto foi feito com o Kiro, isso limitou o que consegui avançar; decidi não fingir progresso e relatar o estado real.
