# Entrega — Aula 06: Terraform Modules

**Aluno:** Rafael Nogueira Maruca  
**RA:** 6322006  
**Data:** 12/11/2026

## Repositório

- URL: https://github.com/rafadical/unifaat-devops-portfolio
- Pasta da aula: [`aula-06/`](https://github.com/rafadical/unifaat-devops-portfolio/tree/main/aula-06)
- Documentação dos módulos: [`aula-06/README.md`](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-06/README.md)

## Evidências

- [x] Módulo VPC com for_each para subnets dinâmicas — [`modules/vpc`](https://github.com/rafadical/unifaat-devops-portfolio/tree/main/aula-06/modules/vpc)
- [x] Módulo Security Group genérico (regras como lista de objetos, origem por CIDR ou por outro SG) — [`modules/security-group`](https://github.com/rafadical/unifaat-devops-portfolio/tree/main/aula-06/modules/security-group)
- [x] Módulo EC2 reutilizável — [`modules/ec2`](https://github.com/rafadical/unifaat-devops-portfolio/tree/main/aula-06/modules/ec2)
- [x] Módulo RDS reutilizável — [`modules/rds`](https://github.com/rafadical/unifaat-devops-portfolio/tree/main/aula-06/modules/rds)
- [x] Composição entre módulos: VPC → SG/EC2/RDS e SG da API → SG do RDS → RDS
- [x] Dois ambientes (dev + staging) com o mesmo `main.tf` e `terraform.tfvars` diferentes
- [x] `terraform validate` sem erros nos dois ambientes
- [ ] `terraform plan` contra a AWS — não executado (sessão do Learner Lab indisponível); a composição foi verificada com `terraform test` usando `mock_provider`
- [x] README documentando cada módulo (inputs, outputs, exemplo)

## Evidência da validação

Saída completa: [`aula-06/evidencias/validate-test.txt`](https://github.com/rafadical/unifaat-devops-portfolio/blob/main/aula-06/evidencias/validate-test.txt)

```
$ terraform fmt -check -recursive
(sem diferenças)

$ cd environments/dev && terraform validate
Success! The configuration is valid.

$ cd environments/staging && terraform validate
Success! The configuration is valid.

$ cd environments/dev && terraform test
tests/composicao.tftest.hcl... in progress
  run "dev_cria_subnets_e_composicao"... pass
  run "staging_usa_os_mesmos_modulos_com_outros_valores"... pass
tests/composicao.tftest.hcl... pass

Success! 2 passed, 0 failed.
```

O teste aplica os dois ambientes com o provider AWS simulado e verifica: 2 subnets públicas e 2 privadas, database `technova_dev` / `technova_staging` e Security Groups separados para API e RDS.
