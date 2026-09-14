# TF 03 — Terraform + IAM Completo

**Aluno:** Thiago Marques Bueno
**RA:** 6325304
**Disciplina:** DevOps - UniFAAT 2026-2
**Aula:** 03

## Repositório do Portfólio

O código completo da atividade foi desenvolvido no meu repositório de portfólio:

**Repositório:** https://github.com/thiagoov19/unifaat-devops-portfolio.git

**Pasta da atividade:** `aula-03/`

**Branch:** `feature/aula-03-terraform-iam`


## Implementação

A atividade foi desenvolvida utilizando Terraform e contempla:

* Configuração do provider AWS na região `us-east-1`;
* Grupo `6325304-technova-developers`;
* Grupo `6325304-technova-platform-eng`;
* Usuários:

  * `6325304-juliana-dev`
  * `6325304-rafael-platform`
  * `6325304-lucas-intern`
* Associação dos usuários aos grupos;
* Policy de leitura do S3;
* Policy de gerenciamento de EC2 e leitura/escrita no S3;
* Policy de proteção contra ações destrutivas;
* IAM Role para EC2;
* Instance Profile para EC2;
* Condição de acesso às instâncias EC2 utilizando a tag `Project = TechNova`;
* Tags padronizadas nos recursos suportados;
* Outputs das principais informações criadas pelo Terraform.

## Validação

Foram executados os comandos:

```text
terraform init
terraform fmt
terraform validate
terraform plan
```

A validação do Terraform foi concluída com sucesso.

O `terraform plan` apresentou:

```text
Plan: 16 to add, 0 to change, 0 to destroy.
```

O arquivo `terraform-plan-output.txt` contendo a evidência do planejamento também foi incluído no projeto.

## Execução no AWS Academy

Foi realizada uma tentativa de execução com:

```text
terraform apply
```

A execução foi bloqueada pelo ambiente AWS Academy Learner Lab devido às permissões IAM disponíveis para o usuário temporário do laboratório.

Entre as operações negadas pela AWS estão:

```text
iam:CreateGroup
iam:CreateUser
iam:CreateRole
iam:TagPolicy
```

O erro retornado foi `AccessDenied`, indicando que as operações necessárias para criação da estrutura IAM não são permitidas pela política de acesso do ambiente utilizado.

O código Terraform e o planejamento foram mantidos conforme os requisitos da atividade, sem remover os recursos IAM necessários apenas para contornar a restrição do laboratório.

## Estrutura do projeto

```text
aula-03/
├── .gitignore
├── main.tf
├── outputs.tf
├── policies.tf
├── providers.tf
├── README.md
├── roles.tf
├── terraform-plan-output.txt
└── variables.tf
```

## Observação

O projeto foi versionado em Git na branch:

`feature/aula-03-terraform-iam`

O arquivo de estado do Terraform não foi incluído no repositório, conforme as boas práticas e requisitos da atividade.
