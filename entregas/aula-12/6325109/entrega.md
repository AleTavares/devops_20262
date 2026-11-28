# Entrega — Aula 12 (TF)

**Aluno:** Carina Gonçalves dos Santos Dalpino
**RA:** 6325109
**Data:** 23/11/2026

## Fork do projeto

- URL: https://github.com/CarinaDalpino/implement_Moodle
- Commit desta semana: https://github.com/CarinaDalpino/implement_Moodle/commit/a7d158e2ecfed17c0ab6d4d3c756343be08c2b0c
- Branch com o trabalho: `feature/terraform-aws`

## O que foi feito nesta aula

Nesta semana avancei da infraestrutura em Terraform até a automação e a documentação do desafio.
Criei os módulos `networking`, `compute` e `database` (VPC com subnets públicas e privadas, EC2 com `user_data.sh` e RDS PostgreSQL privado) e documentei a arquitetura em `docs/architecture-design.md`.
Ajustei os workflows de CI: o `terraform-validate` falhava por um `hashFiles` inválido no nível do job, e o `docker-lint` passou a ignorar a regra DL3008 do hadolint e a rodar também via `workflow_dispatch`.
Registrei as evidências do CI, do deploy na AWS e do health check em `docs/img/`, e o `pytest` passa com 64 testes.
Usei o Kiro de duas formas: criei a Spec `docker-env-fix` em `.kiro/specs/` e rodei o workflow `investigate`, cujo relatório está em `docs/kiro-investigate-report.md`.
O trabalho está na branch `feature/terraform-aws`, que já tem um Pull Request aberto no meu fork.
Ainda não está pronto: o `entrega.md` da prova P2, com os links para todas as evidências, e o `terraform destroy` ao final para liberar os recursos do Lab.
Próximo passo: montar o `entrega.md` da prova e conferir o checklist final antes da entrega.

## Dificuldades encontradas

A principal dificuldade foi o `env_file` do `docker-compose.yml`: os dois serviços liam o `.env.example` e não o `.env`. Por isso, a senha que eu alterava em `docker/.env` chegava ao Moodle, mas nunca ao PostgreSQL, e o banco continuava com a senha do template.
Usei o workflow `investigate` do Kiro para localizar a causa. Confirmei no histórico do Git que o commit inicial apontava para `.env.example` e corrigi no commit `362c0e8`, apontando os dois serviços para `.env`.
O relatório também me alertou para outro ponto: o volume `db_data` só aplica a senha na primeira inicialização, então para trocar a senha de um ambiente já iniciado é preciso recriar o volume ou alterar a senha no banco.
Outra dificuldade foi o CI: o `hashFiles` no nível do job derrubava o workflow, e o hadolint reprovava o Dockerfile pela regra DL3008. Resolvi removendo o `hashFiles` do job e ajustando o nível de falha do hadolint.