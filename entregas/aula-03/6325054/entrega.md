# Entrega — Aula 03: Terraform + IAM

**Aluno:** Leonardo Rafael Contini Costa  
**RA:** 6325054  
**Data:** 3 de setembro

## Repositório

- URL: https://github.com/Leonardocontini/unifaat-devops-portfolio.git

## Evidências

- [x] `providers.tf` com provider AWS configurado
- [x] `main.tf` com users, groups e memberships
- [x] `policies.tf` com mínimo 3 custom policies
- [x] `roles.tf` com service role + instance profile
- [x] `variables.tf` e `outputs.tf` configurados
- [x] `terraform-plan-output.txt` com evidência do plano
- [x] `README.md` com explicação do design e reflexão sobre menor privilégio
- [x] Tags obrigatórias em todos os recursos
- [x] `.gitignore` configurado (sem `.tfstate` no repositório)

## Evidência do Terraform Plan

![evidencia](/entregas/aula-03/6325054/Imagem%20colada.png)


## Design da Estrutura IAM

A estrutura IAM da TechNova foi organizada utilizando grupos para separar responsabilidades.

O grupo `technova-developers` é destinado aos desenvolvedores que precisam consultar dados armazenados no S3. Ele possui uma policy customizada que permite somente `s3:GetObject` e `s3:ListBucket`.

O grupo `technova-platform-eng` é destinado aos profissionais responsáveis pela infraestrutura. Esse grupo possui permissões para consultar recursos EC2, iniciar e parar instâncias específicas e realizar operações de leitura e escrita no S3.

Foram criados três usuários:

* `SEU-RA-juliana-dev` — developers
* `SEU-RA-rafael-platform` — developers + platform-eng
* `SEU-RA-lucas-intern` — developers

A organização por grupos evita a necessidade de configurar permissões individualmente para cada usuário.

## Princípio do Menor Privilégio

O princípio do menor privilégio consiste em conceder a cada usuário, grupo ou serviço somente as permissões necessárias para executar suas funções.

No projeto, esse princípio foi aplicado de duas formas principais:

1. Os desenvolvedores possuem apenas permissões de leitura no S3, não podendo alterar ou excluir objetos.
2. As operações de `StartInstances` e `StopInstances` da EC2 possuem uma condição baseada na tag `Project=TechNova`.

Também foi criada uma policy de `Deny` explícito para ações destrutivas, bloqueando operações como `Delete*` no S3 e `Terminate*` na EC2.

Usar `AmazonS3FullAccess` no lugar de uma policy customizada concederia permissões muito maiores do que as necessárias. Um usuário que deveria apenas consultar arquivos poderia, por exemplo, modificar ou excluir dados.

## Diagrama de Permissões

```text
                    ┌─────────────────────────┐
                    │       IAM Users         │
                    └────────────┬────────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                  │
              ▼                  ▼                  ▼
        Juliana Dev        Rafael Platform       Lucas Intern
              │                  │                  │
              │                  ├──────────────┐   │
              ▼                  ▼              │   ▼
        Developers        Platform-Eng          │ Developers
              │                  │              │
              ▼                  ▼              ▼
        S3 Read Policy    EC2 + S3 Full    Deny Destructive
              │                  │
              ▼                  ▼
             S3             EC2 + S3
```

### Fluxo do Service Role

```text
┌──────────────┐
│     EC2      │
└──────┬───────┘
       │ AssumeRole
       ▼
┌────────────────────┐
│   IAM Role         │
│ technova-ec2-role  │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│ Instance Profile   │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│ S3 App Data        │
│ technova-app-data-*│
└────────────────────┘
```

## Comandos Utilizados

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

### Inicialização

```bash
terraform init
```

### Formatação

```bash
terraform fmt
```

### Validação

```bash
terraform validate
```

### Planejamento

```bash
terraform plan
```

### Aplicação

```bash
terraform apply
```

### Destruição após os testes

```bash
terraform destroy
```

## Reflexão

A criação manual de usuários, grupos e policies pelo Console AWS pode funcionar para ambientes pequenos, mas aumenta a possibilidade de erros e dificulta a reprodução da infraestrutura.

Com Terraform, a estrutura IAM fica registrada como código, permitindo revisão por Pull Request, versionamento, padronização e auditoria das alterações.

Para uma equipe, o Terraform oferece maior rastreabilidade e facilita a reprodução do mesmo ambiente de forma consistente.

## Conclusão

A estrutura implementada utiliza grupos para separar responsabilidades, policies customizadas para aplicar o menor privilégio e uma service role para permitir que a EC2 acesse o S3 sem utilizar credenciais AWS diretamente na máquina.

Toda a infraestrutura é gerenciada como código através do Terraform.
