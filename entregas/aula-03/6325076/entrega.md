# Entrega — Aula 03 — Terraform + IAM Completo

**Aluno:** Pablo Augusto Ramos Sobral  
**RA:** 6325076  
**Disciplina:** DevOps - UniFAAT 2026-2  
**Aula:** 03  

## Portfólio

[Ver implementação da Aula 03](https://github.com/Pablao02/unifaat-devops-portfolio/tree/feature/aula-03-terraform-iam/aula-03)

## Evidências

- [x] `terraform fmt`
- [x] `terraform validate` — configuração válida
- [x] `terraform plan` — 17 recursos planejados para criação
- [x] `terraform-plan-output.txt`
- [x] `terraform apply` executado no AWS Academy
- [x] `iam-access-denied.txt`
- [x] README com documentação
- [x] `.gitignore` configurado para não versionar o Terraform State
- [ ] Provisionamento dos recursos IAM concluído no AWS Academy — bloqueado por `AccessDenied` da role `voclabs`

## Observação

A configuração Terraform foi validada com sucesso e o plano foi gerado. A aplicação dos recursos no AWS Academy foi bloqueada por permissões IAM insuficientes da conta de laboratório (`AccessDenied`).
