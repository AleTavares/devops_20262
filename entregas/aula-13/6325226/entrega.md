# Entrega — Aula 13 (TF)

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 2026-11-19

## Fork do projeto

- URL: https://github.com/lucaskenway/implement_Moodle
- Commit desta semana: https://github.com/lucaskenway/implement_Moodle/commit/1bb852e

> ## ✅ O que o TF pede × onde está no fork
>
> | # | Requisito do TF (`aula-13/relatorio-tf.md`) | Status | Onde conferir |
> |---|---|:---:|---|
> | 1 | `user_data.sh` no módulo `compute` instala o Docker na EC2 e sobe o Moodle no boot com `docker compose up -d` | ✅ | [`terraform/modules/compute/user_data.sh`](https://github.com/lucaskenway/implement_Moodle/blob/1bb852e/terraform/modules/compute/user_data.sh) · print do Moodle na EC2: [`008_aws-ec2-moodle-install.png`](https://github.com/lucaskenway/implement_Moodle/blob/1bb852e/evidencias/2026-11-15_deploy-aws/008_aws-ec2-moodle-install.png) |
> | 2 | Variáveis do banco passadas com segurança, sem senha no código | ✅ | `db_username`, `db_password` e `moodle_admin_password` são `sensitive = true` em [`terraform/variables.tf`](https://github.com/lucaskenway/implement_Moodle/blob/1bb852e/terraform/variables.tf) e vêm do `terraform.tfvars`. O [`.gitignore`](https://github.com/lucaskenway/implement_Moodle/blob/1bb852e/.gitignore) ignora `*.tfvars`, `.env` e `*.tfstate`. |
> | 3 | Módulos `networking` e `database` avançados | ✅ | [`terraform/modules/`](https://github.com/lucaskenway/implement_Moodle/tree/1bb852e/terraform/modules) (`networking`, `database`, `compute`) |
> | 4 | `terraform validate` sem erros | ✅ | `Success! The configuration is valid.` · print do CI: [`001_terraform-validate-main-sucesso.png`](https://github.com/lucaskenway/implement_Moodle/blob/1bb852e/evidencias/2026-11-15_actions-main/001_terraform-validate-main-sucesso.png) |
> | 5 | `terraform plan` sem erros | ✅ | `Plan: 12 to add, 0 to change, 0 to destroy.` · [`004_actions-terraform-plan-saida.txt`](https://github.com/lucaskenway/implement_Moodle/blob/1bb852e/evidencias/2026-11-14_prints/004_actions-terraform-plan-saida.txt) · [print do run](https://github.com/lucaskenway/implement_Moodle/blob/1bb852e/evidencias/2026-11-14_prints/003_actions-terraform-plan-run-sucesso.png) |
> | 6 | `docs/architecture-design.md` com diagrama e descrição dos componentes | ✅ | [`docs/architecture-design.md`](https://github.com/lucaskenway/implement_Moodle/blob/1bb852e/docs/architecture-design.md) (diagrama Mermaid, decisões de design, componentes, segurança, escalabilidade e custo) |
> | 7 | `pytest -v` na pasta `tests/` | ✅ | **64 passed**, no commit `1bb852e` |
> | 8 | Commit do progresso no fork | ✅ | [`1bb852e`](https://github.com/lucaskenway/implement_Moodle/commit/1bb852e) em `main` |

## O que foi feito nesta aula

- Escrevi a Spec no Kiro (`.kiro/specs/moodle-aws-p2`) e, a partir dela, implementei os três módulos Terraform:
  - `networking`: VPC, subnets, Internet Gateway, route table e Security Groups;
  - `database`: RDS PostgreSQL 15 em subnets privadas de 2 AZs, com `publicly_accessible = false` e porta 5432 aberta só para o SG da EC2;
  - `compute`: EC2 com `LabInstanceProfile`.
- O `user_data.sh`, processado por `templatefile()`:
  - instala Docker e Git;
  - instala o Docker Compose como plugin, com versão fixa;
  - clona o fork;
  - gera o `docker/.env` com o endpoint do RDS e as credenciais, que vêm de variáveis `sensitive`;
  - sobe o Moodle com `docker compose up -d`.

  Todo o log vai para `/var/log/user-data.log`.
- Fiz o deploy no Learner Lab e o Moodle abriu na EC2 (print `008_aws-ec2-moodle-install.png`).
- Finalizei o `docs/architecture-design.md`.
- Corrigi o workflow de `terraform validate` e implementei o `terraform-plan` no GitHub Actions. Os dois passam na `main`.
- O `pytest` do template passa por completo (64 testes).
- As evidências (prints, saídas e conversas do Kiro) estão em [`evidencias/`](https://github.com/lucaskenway/implement_Moodle/tree/1bb852e/evidencias).
- **Ainda não está pronto:** os ajustes finais da P2. Eles estão na branch `fix/p2-correcoes` e ainda não foram para a `main`.
- **Próximo passo:** finalizar essas correções e revisar o `architecture-design.md` contra a rubrica da prova.

## Dificuldades encontradas

- **Escape no `user_data.sh` com `templatefile()`:** o Terraform tenta interpolar toda variável no formato do Terraform, inclusive as do shell. Isso quebrou a versão do Compose. Resolvi escrevendo as variáveis de shell com cifrão duplo e passando `compose_version` como variável do template (commit `79a4976`). Também documentei a regra no cabeçalho do script (`7890079`).
- **Docker Compose no Amazon Linux 2023:** o `docker-compose-plugin` não existe no `dnf`. Resolvi baixando o binário oficial de uma release fixa para `/usr/local/lib/docker/cli-plugins/`.
- **Instance profile no Learner Lab:** o Lab não permite criar roles IAM. Tive que usar o `LabInstanceProfile`, que já existe no Lab, em vez de criar um (`7c953e2`).
- **Imagem do Moodle sem driver do PostgreSQL:** faltava a extensão `pgsql` no Dockerfile (`7ef0233`). Além disso, o compose carregava o `.env.example` em vez do `docker/.env` (`09a89b9`, `436c5bc`).

> Uso de IA: o projeto foi feito com o **Kiro** (Spec + sessões registradas em `evidencias/2026-11-13_kiro-sessao-p2` e `evidencias/2026-11-14_kiro-sessao-p2`). Este relatório foi redigido com apoio de IA e revisado por mim.
