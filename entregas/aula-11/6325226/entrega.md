# Entrega — Aula 11 (TF)

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 2026-11-12

## Link do commit

- Fork: https://github.com/lucaskenway/implement_Moodle
- Commit: https://github.com/lucaskenway/implement_Moodle/commit/f948b86e0831aa849a6d5b9c89f170c5b91accf5

## O que foi feito nesta aula

- Fiz o fork do `implement_Moodle`, clonei e li o `CHALLENGE.md`, a rubrica, o `architecture.md` e os workflows para entender os entregáveis da prova.
- Validei o ambiente Docker local: `docker compose up -d --build` subiu PostgreSQL 15 (healthcheck `healthy`) e o Moodle 4.1.22, que responde em `http://localhost:8080` (redireciona para `install.php`). O `scripts/health-check.sh` passou.
- Corrigi o `docker-compose.yml`: o `env_file` apontava para o `.env.example` (senhas de exemplo). Agora lê o `docker/.env`, que está no `.gitignore`, com senhas geradas aleatoriamente.
- Rodei o `pytest` do template: 41 passaram e 10 foram pulados, porque a pasta `terraform/modules/` ainda não existe.
- Comecei o `docs/architecture-design.md` (item eliminatório): visão geral, decisões de design, componentes planejados (VPC `10.0.0.0/16`, 1 subnet pública e 2 privadas, SGs, EC2 `t3.medium`, RDS `db.t3.micro`), segurança, escalabilidade e custo estimado (~US$ 51/mês).
- As evidências estão em `evidencias/` no fork, em TXT e PNG renderizado.
- **Ainda não está pronto:** os módulos Terraform, o `user_data.sh`, o `terraform-plan.yml`, o diagrama real com ícones AWS, o link do Pricing Calculator e o uso do Kiro (Spec).
- **Próximo passo:** criar `terraform/` com `versions.tf` e o módulo `networking`, rodando `terraform validate` e `plan` no Learner Lab.
- **Uso de IA:** usei o Claude Code como apoio para revisar o template, rodar os comandos e redigir o rascunho do documento de arquitetura. Revisei o conteúdo gerado.

## Dificuldades encontradas

- **Docker no WSL:** o daemon do Docker dentro do WSL estava parado, e iniciá-lo exige `sudo`. Usei o engine do Docker Desktop (Windows) pelo `docker.exe`. No meio do trabalho a interoperabilidade WSL→Windows caiu (`UtilAcceptVsock: accept4 failed 110`), e por isso não consegui terminar a instalação do Moodle pela CLI (`admin/cli/install.php`). O site sobe e responde, mas ainda para no instalador web. Vou concluir pelo navegador ou reiniciando o WSL (`wsl --shutdown`).
- **pytest em `/mnt/c`:** o teste `test_git_ignores_sensitive_filenames` falhou com `DeadlineExceeded` do Hypothesis (210 ms contra o limite de 200 ms). O teste chama `git check-ignore`, que é lento no sistema de arquivos do Windows montado no WSL. Rodando uma cópia no FS Linux, os 41 testes passaram. A falha é de desempenho do ambiente, não do `.gitignore`.
- **Senhas do compose:** com `env_file: .env.example`, trocar as senhas só no `.env` deixaria o Postgres e o Moodle com senhas diferentes, porque o Postgres lê o `env_file` e o Moodle lê a interpolação `${...}` do `.env`. A correção foi apontar os dois serviços para o mesmo `.env`.
