# Entrega — Aula 12 (TF)

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 19/11/2026

## Fork do projeto

- URL: https://github.com/gabrielreis354/implement_Moodle
- Commit desta semana: https://github.com/gabrielreis354/implement_Moodle/commit/0e2a9b6c9304bf0be429f0a9e45e3f2e000a5ed4
- Todos os commits da semana (12, branch `feature/terraform-aws`): https://github.com/gabrielreis354/implement_Moodle/compare/main...feature/terraform-aws

## O que foi feito nesta aula

Corrigi os erros propositais do template e implementei toda a infraestrutura Terraform do desafio, sem aplicar nada na AWS.
- **Docker:** o Moodle subia no instalador web e não falava com o PostgreSQL (faltava a extensão PHP `pgsql`; as variáveis `MOODLE_*` não eram usadas). Criei um `entrypoint.sh` que instala o Moodle por CLI, adicionei `pgsql`/`soap`/`exif`, corrigi `env_file`, os volumes, o `.gitignore` (que ignorava `.kiro/`) e o `hadolint`, e criei o `docker-compose.aws.yml` (sem banco local) para a EC2.
- **Terraform:** módulos `networking` (VPC, 2 subnets públicas e 2 privadas, IGW, `sg-app`, `sg-db`), `database` (RDS PostgreSQL 15 privado) e `compute` (EC2 `t3.micro` AL2023 com `user_data.sh`: Docker, Compose v2, swap, clone, IMDSv2, `.env`, espera do RDS e `docker compose up`), mais a raiz que liga os três.
- **Kiro:** Spec do módulo `compute` em `.kiro/specs/`, workflow `feature-pipeline` (evidência aceita pelo professor), e os módulos `database` e `networking` por chat. O Claude Code revisou e corrigiu o que o Kiro gerou, e escreveu a raiz (tudo declarado nos commits).
- **Validação (testada de verdade):** `docker compose up` com login do Moodle em HTTP 200 sem redirecionar ao instalador, `health-check.sh` com exit 0 e persistência após restart; `hadolint` e `shellcheck` limpos; `terraform fmt -check -recursive` e `terraform validate` OK com o provider AWS 5.100.0; `user_data.sh` renderizado e validado; casos de validação das variáveis testados; `pytest` com 66 testes passando; varredura sem credenciais nos commits.
- **Ainda não está pronto:** o `terraform plan`/`apply` (a sessão do Learner Lab expirou), o `terraform-plan.yml`, o `docs/architecture-design.md`, o README e o screenshot do plan.
- **Próximo passo:** renovar as credenciais, rodar o `plan`, implementar o workflow, escrever o documento de arquitetura e fazer um `apply` curto com health-check e `destroy` imediato.

Uso de IA: Kiro (Spec, workflow e módulos) e Claude Code (revisão, correções, raiz e testes), com log literal dos prompts mantido por mim.

## Dificuldades encontradas

- **Pacote inexistente:** o `user_data` da Spec instalava `docker-compose-plugin`, que não existe no Amazon Linux 2023 (confirmei em um contêiner `amazonlinux:2023`); passei a baixar o binário do Compose v2.
- **Regex no Terraform:** a validação da senha do admin usava lookahead, que o Terraform (RE2) não suporta; dentro de `can()` o erro era engolido e toda senha era rejeitada. Testei casos válidos e inválidos e troquei por `alltrue([...])` com uma regex por exigência.
- **`templatefile`:** `${...}` dentro de um comentário do `user_data.sh` quebrava a renderização; só descobri ao renderizar o template de verdade, em vez de confiar no `validate`.
- **Detalhes de ambiente:** o Kiro gravava arquivos com BOM (o `fmt -check` falhava), o Windows reserva a porta 8080 nesta máquina (usei 8081) e a sessão do Lab expirou antes do `plan`. Em todos os casos confirmei a causa por teste antes de corrigir.
