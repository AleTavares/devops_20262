# Entrega — Aula 11: Blue/Green e Canary Deployments

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 12/11/2026

## Repositório

- URL: https://github.com/gabrielreis354/implement_Moodle

## Estratégia escolhida

- [ ] Opção A — Blue/Green
- [ ] Opção B — Canary

> Relatório de progresso: a estratégia ainda não foi implementada. Decisão de planejamento: Blue/Green como base; Canary somente se houver bônus por ele.

## Evidências

- [ ] Terraform do ALB + 2 Target Groups aplicável (`terraform validate`/`plan`)
- [ ] Workflow (ou script) de deploy com validação e rollback
- [ ] Imagem puxada do **Amazon ECR** no deploy das instâncias
- [ ] `EXPLICACAO.md` preenchido
- [ ] Screenshots (ALB respondendo, traffic switch/rollout, rollback acionado)

## Evidência do Deploy Rodando

Esta entrega é um **relatório de progresso** do desafio técnico (repositório `implement_Moodle`, fork de `AleTavares/implement_Moodle`). Nenhuma infraestrutura foi aplicada na AWS até aqui; nada ficou ativo no Learner Lab.

### O que foi feito
- Análise da Aula 11 (requisitos, critérios, armadilhas) e do desafio Moodle (rubrica de 100 pts, restrições do Learner Lab).
- Validação do ambiente Docker local em cópia de teste (fork intacto): `docker compose config` OK; `docker build` OK (PHP 8.1.34, Moodle 4.1.22); `docker compose up` sobe `db` (healthy) e `moodle`.
- Achados confirmados por teste:
  1. O Moodle sobe no instalador web (`/install.php`): não há `config.php` e as variáveis `MOODLE_*` do compose não são consumidas pela imagem.
  2. Falta a extensão PHP `pgsql` (`pg_connect` indisponível; só há `pdo_pgsql`), necessária ao driver PostgreSQL do Moodle; também faltam `soap` e `exif`.
  3. O compose usa `env_file: .env.example` enquanto a interpolação lê o `.env` (risco de senhas divergentes).
  4. O `.gitignore` não cobre `.terraform/`; a documentação cita arquivos inexistentes (`versions.tf`, `backend.tf.example`, `terraform.tfvars.example`).
- Hipótese testada e descartada: falso negativo do `health-check.sh` com `pipefail`.

### Uso de IA (quem fez o quê)
- Claude Code: análise, testes e este relatório (log literal dos prompts mantido pelo aluno).
- Kiro: será o gerador principal na prova.

### Próximos passos
Spec do Blue/Green (ALB + 2 Target Groups + workflow + rollback), `terraform validate`/`plan`, apply curto no Learner Lab com evidências e `terraform destroy` imediato.
