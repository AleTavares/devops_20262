# Entrega — Aula 03: Terraform + IAM

**Aluno:** Eloísa Brandão
**RA:** 2325096
**Data:** 29/08/2026

## Repositório

* URL: https://github.com/brandelas/unifaat-devops-portfolio

## Evidências

* [x] `providers.tf` com provider AWS `hashicorp/aws ~> 5.0` configurado para `us-east-1`
* [x] `main.tf` com 2 groups, 3 users e memberships
* [x] `policies.tf` com 3 custom policies
* [x] `roles.tf` com service role para EC2 + instance profile
* [x] `variables.tf` e `outputs.tf` configurados
* [x] `terraform-plan-output.txt` com saída real do `terraform plan`
* [x] `README.md` com explicação do design e do princípio do menor privilégio
* [x] Tags obrigatórias aplicadas aos recursos que suportam tags
* [x] `.gitignore` configurado para impedir o versionamento do estado do Terraform

## Evidência do Terraform Plan

O comando `terraform plan` foi executado com sucesso utilizando as credenciais temporárias do AWS Academy Learner Lab.

Resultado obtido:

```text
Plan: 19 to add, 0 to change, 0 to destroy.
```

A saída completa utilizada como evidência está armazenada em:

```text
aula-03/terraform-plan-output.txt
```

## Validação

Foram executados com sucesso:

```text
terraform fmt -check
terraform validate
terraform plan
```

O comando `terraform validate` retornou:

```text
Success! The configuration is valid.
```

## Terraform Apply

Foi realizada uma tentativa de execução do `terraform apply` utilizando o AWS Academy Learner Lab.

Durante a execução, o ambiente retornou `AccessDenied` para operações IAM necessárias à criação dos recursos:

```text
iam:CreateGroup
iam:CreateUser
iam:CreateRole
```

Por esse motivo, o `apply` não foi concluído. A configuração Terraform não foi alterada para tentar contornar a restrição de permissões do ambiente.

## Estrutura Implementada

A solução contém:

* 2 IAM Groups
* 3 IAM Users
* Memberships entre usuários e grupos
* 3 custom policies
* Policy de Deny explícito para operações destrutivas
* Condition para Start/Stop de instâncias EC2 pela tag `Project=TechNova`
* Service Role para EC2
* Instance Profile
* Variables e Outputs
* Tags padronizadas
* Documentação do princípio do menor privilégio

## Pull Request

O Pull Request será aberto no fork da disciplina após o commit e push desta entrega.

Caminho da entrega no fork:

```text
entregas/aula-03/2325096/entrega.md
```
