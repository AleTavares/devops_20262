# Entrega — Aula 05: RDS e Remote State

**Aluno:** Eloísa Brandão
**RA:** 2325096
**Data:** 25/09/2026

## Repositório

* Projeto: [unifaat-devops-portfolio](https://github.com/brandelas/unifaat-devops-portfolio)
* Código da Aula 05: [aula-05 no branch 2325096/tf-05](https://github.com/brandelas/unifaat-devops-portfolio/tree/2325096/tf-05/aula-05)

## Evidências

* [x] VPC com subnets públicas e privadas em 2 AZs
* [x] RDS PostgreSQL (`db.t3.micro`) nas subnets privadas
* [x] EC2 `t2.micro` na subnet pública
* [x] Security Groups configurados para a comunicação com o RDS
* [x] Remote State configurado com S3 + DynamoDB
* [x] Variáveis sensíveis configuradas para credenciais do banco
* [x] `.gitignore` configurado para não versionar `.terraform/`, arquivos de state, `terraform.tfvars` e chaves `.pem`
* [x] `terraform validate` executado com sucesso
* [x] `terraform fmt -check -recursive` executado com sucesso
* [ ] State armazenado no S3 com evidência de execução
* [ ] Conexão EC2 → RDS via `psql`
* [ ] Evidência de dados persistidos no RDS
* [ ] `terraform plan` sem alterações após o provisionamento
* [ ] `terraform destroy` executado após as evidências

## Observação

A infraestrutura da Aula 05 foi implementada no repositório `unifaat-devops-portfolio`, no branch `2325096/tf-05`.

Durante a validação, os comandos locais de sintaxe e formatação foram executados. Uma tentativa de acesso à AWS retornou:

```text
InvalidToken: The provided token is malformed or otherwise invalid.
```

Por esse motivo, o provisionamento da infraestrutura na AWS não foi executado e as evidências de execução relacionadas ao S3, EC2 → RDS e `terraform destroy` não estão sendo declaradas como concluídas.
