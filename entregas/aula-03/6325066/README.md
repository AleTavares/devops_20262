# Aula 03 — Terraform + IAM | Maximus Ponciano (6325066)

## Design da Estrutura IAM

- **Por que criou esses groups?** Criei os groups `developers` e `platform-eng` para separar as permissões em níveis de acesso. Assim, consigo dar permissões limitadas a quem precisa apenas consultar dados e permissões estendidas a quem administra.
- **Como separou as responsabilidades?** Membros de `developers` só leem S3 (como a Juliana e Lucas), enquanto membros de `platform-eng` têm poder de gerenciar EC2 e S3 (como o Rafael). O Lucas está apenas em developers, e ainda assim sua política é bem restrita (menor privilégio).
- **Quais ações cada policy permite e por quê?** 
  - `s3-read`: `GetObject` e `ListBucket` para permitir consulta aos dados de desenvolvimento.
  - `ec2-s3-full`: Gerenciamento de instâncias EC2 e S3, mas com `Condition` para só atuar onde a Tag Project for TechNova, impedindo alterações globais.
  - `deny-destructive`: Bloqueia exclusão de recursos essenciais, como deletar Buckets ou terminar instâncias, servindo de proteção mesmo se outra policy autorizar.

## Princípio do Menor Privilégio

- **O que é o princípio?** Consiste em fornecer apenas os privilégios exatos e estritamente necessários para a execução de uma tarefa, pelo menor período possível, reduzindo a superfície de ataque.
- **Dê 2 exemplos de como aplicou no seu código**: 
  1. A `Condition` limitando Start/Stop do EC2 apenas em recursos com a Tag `Project=TechNova`.
  2. A declaração explícita de `s3:GetObject` e `s3:ListBucket` apontando especificamente para o prefixo de buckets `technova-*`.
- **O que aconteceria se você usasse AmazonS3FullAccess em vez da sua custom policy?** Os usuários de development poderiam criar, deletar ou modificar qualquer arquivo ou bucket de toda a conta AWS, incluindo configurações sensíveis de produção, o que é um grande risco de segurança.

## Diagrama de Permissões

```text
juliana-dev ────┐
                ├───> developers group ────> technova-s3-read (Allow S3 Read)
lucas-intern ───┘                      └───> technova-deny-destructive (Deny Delete)
 
rafael-platform ────> platform-eng group ──> technova-ec2-s3-full (Allow EC2/S3)
                  └─> developers group ────> (Herda policies de developers também)

EC2 Instance ──> technova-ec2-profile ──> technova-ec2-role ──> technova-ec2-role-policy (Allow S3 R/W em app-data-*)
```

## Comandos Utilizados

```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

## Reflexão

- **Compare a criação manual de IAM pelo Console AWS vs. Terraform:** Pelo Console, o trabalho é demorado, sujeito a erros humanos e esquecimentos (como esquecer de aplicar a policy de Deny).
- **Qual abordagem é mais segura e auditável para uma equipe? Por quê?** Com o Terraform (IaC), as configurações são documentadas, testadas com comandos como `terraform validate` e `terraform plan`, versionadas via Git, e qualquer alteração requer um Pull Request e revisão de outros pares, aumentando enormemente a rastreabilidade e segurança (auditabilidade).
