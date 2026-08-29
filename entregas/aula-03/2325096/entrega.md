# Entrega — Aula 03: Terraform + IAM

**Aluno:** Eloísa Brandão
**RA:** 2325096
**Data:** 29/08/2026

## Repositório

* URL: https://github.com/brandelas/unifaat-devops-portfolio

## Evidências

* [x] `providers.tf` com provider AWS configurado
* [x] `main.tf` com users, groups e memberships
* [x] `policies.tf` com mínimo 3 custom policies
* [x] `roles.tf` com service role + instance profile
* [x] `variables.tf` e `outputs.tf` configurados
* [x] `terraform-plan-output.txt` com evidência do plano
* [x] `README.md` com explicação do design e reflexão sobre menor privilégio
* [x] Tags obrigatórias aplicadas aos recursos que suportam tags
* [x] `.gitignore` configurado sem versionamento de `.tfstate`

## Evidência do Terraform Plan

O comando `terraform plan` foi executado com sucesso utilizando as credenciais temporárias do AWS Academy Learner Lab.

Resultado:

```text
Plan: 19 to add, 0 to change, 0 to destroy.
```

A saída completa do plano está armazenada no arquivo:

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

O `terraform validate` retornou:

```text
Success! The configuration is valid.
```

## Observação sobre o Terraform Apply

Durante a tentativa de execução do `terraform apply`, o AWS Academy Learner Lab retornou `AccessDenied` para operações de IAM necessárias à criação de grupos, usuários e role, incluindo:

```text
iam:CreateGroup
iam:CreateUser
iam:CreateRole
```

A configuração Terraform foi mantida sem alterações para contornar essa restrição de permissões do ambiente.

## Estrutura implementada

A solução contém:

* 2 IAM Groups
* 3 IAM Users
* Memberships entre usuários e grupos
* 3 custom policies
* Policy de Deny explícito para operações destrutivas
* Condition para controle de Start/Stop de instâncias EC2 pela tag `Project=TechNova`
* Service Role para EC2
* Instance Profile
* Variables e Outputs
* Tags padronizadas
* Documentação do princípio do menor privilégio
