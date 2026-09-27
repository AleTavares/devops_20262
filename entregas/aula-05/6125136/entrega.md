# Entrega — Aula 05: RDS e Remote State

**Aluno:** Hector Marcelo Pedroso dos Santos
**RA:** 6125136
**Data:** 22/09/2026

## Repositório

- URL: https://github.com/hectorbackfront/unifaat-devops-portfolio
- Pasta do projeto: `aula-05/` (código) e `aula-05/backend/` (backend do state)

## Evidências

- [x] VPC com subnets públicas e privadas em 2 AZs
- [x] RDS PostgreSQL (db.t3.micro) nas subnets privadas
- [x] EC2 t2.micro na subnet pública, conectando ao RDS
- [x] Security Groups corretos (porta 5432 apenas do SG da EC2 — bônus)
- [x] Remote State configurado (S3 + DynamoDB)
- [x] State armazenado no S3 (evidência abaixo)
- [x] Conexão EC2 → RDS via psql (evidência abaixo, automática via `user_data`)
- [x] `terraform destroy` executado após evidências

Evidências completas (state, conexão, dados persistentes e `terraform plan` limpo)
estão documentadas no README do projeto:
https://github.com/hectorbackfront/unifaat-devops-portfolio/blob/master/aula-05/README.md#evidências

## Evidência do State no S3

```text
$ aws s3 ls s3://technova-terraform-state-16d6db44/aula-05/
2026-09-22 20:06:35      37844 terraform.tfstate
```

## Evidência da Conexão EC2 → RDS

Log gravado automaticamente pelo `user_data` em `/var/log/technova-db-test.log`:

```text
=== Teste automatico de conexao EC2 -> RDS ===
Tue Sep 22 23:07:00 UTC 2026
                                              version
---------------------------------------------------------------------------------------------------
 PostgreSQL 15.17 on x86_64-pc-linux-gnu, compiled by x86_64-pc-linux-gnu-gcc (GCC) 12.4.0, 64-bit
(1 row)

Conexao OK na tentativa 1
```

Toda a infraestrutura foi destruída (`terraform destroy` no projeto principal e no
backend, com esvaziamento prévio do bucket S3) logo após a coleta das evidências.
