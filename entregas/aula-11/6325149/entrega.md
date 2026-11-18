# Entrega — Aula 11 (TF)

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 18/11/2026

## Fork do projeto

- URL: https://github.com/gabrielreis354/implement_Moodle
- Commit desta semana: https://github.com/gabrielreis354/implement_Moodle/commit/a86c7b1125c19f43af57a7f0dd4ad302f47ab86f

## O que foi feito nesta aula

Analisei a Aula 11 e o desafio `implement_Moodle` (rubrica, restrições do Learner Lab) e validei o ambiente Docker local em uma cópia de teste, sem alterar o template. `docker compose config` e `docker build` passam (PHP 8.1.34, Moodle 4.1.22) e `docker compose up` sobe o `db` (healthy) e o `moodle`. O registro completo está em `docs/progress-notes.md`, no commit acima.

O que funcionou / o que encontrei:
- O Moodle responde, mas cai no instalador web (`/install.php`): não há `config.php` e as variáveis `MOODLE_*` do compose não são consumidas pela imagem.
- Falta a extensão PHP `pgsql` (só há `pdo_pgsql`; `pg_connect()` inexistente), necessária ao driver PostgreSQL do Moodle.
- `env_file: .env.example` no compose (o `.env` real não é lido por ele) e `.gitignore` sem `.terraform/`/`*.tfstate` e com `.kiro/` ignorado.

Ainda não está pronto: módulos Terraform (`networking`, `compute`, `database`), `terraform-plan.yml`, `docs/architecture-design.md` e a Spec do Kiro. Nada foi aplicado na AWS; não há recursos ativos no Learner Lab.

Próximo passo: corrigir os achados com o Kiro (Spec do módulo `compute`), criar os módulos Terraform e validar com `terraform validate`/`plan`.

Uso de IA: Claude Code (análise, testes e verificação, com log literal dos prompts); o Kiro será o gerador principal dos artefatos da prova.

## Dificuldades encontradas

O ambiente Docker "funcional" do template não sobe pronto: o Moodle abre o instalador web e a extensão `pgsql` não está instalada, o que impediria a conexão com o PostgreSQL. Abordei confirmando cada hipótese por teste (build, `compose up`, `php -m`, `function_exists('pg_connect')`) em vez de assumir, e descartei uma hipótese que não se confirmou (falso negativo do `health-check.sh` com `pipefail`). Também a rede lenta do WSL atrasou o build/pull e a porta 8080 ficou indisponível; usei a 8081 no teste.
