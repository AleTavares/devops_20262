# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Gabriel Reis Cunha
**RA:** 6325149
**Data:** 03/09/2026

## Repositório

- URL: https://github.com/gabrielreis354/unifaat-devops-portfolio
- Pasta do projeto: [`aula-04/`](https://github.com/gabrielreis354/unifaat-devops-portfolio/tree/main/aula-04)

## Evidências

- [x] VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs
- [x] Internet Gateway + Route Tables configurados
- [x] Security Groups com menor privilégio (api: 22/3000; db: 5432 só da VPC)
- [x] EC2 t2.micro com User Data (API rodando na porta 3000)
- [x] Instance Profile com IAM Role (trust `ec2.amazonaws.com`, `AmazonS3ReadOnlyAccess`)
- [x] Tags em todos os recursos (Name, Project, Environment, ManagedBy, Owner)
- [x] `terraform-plan-output.txt` com evidência do plano (`Plan: 18 to add`)
- [x] README com diagrama da arquitetura (ASCII), decisões técnicas e tabela de recursos
- [x] `terraform destroy` executado após evidências (15 destroyed, nada ativo)

## Evidência da API Rodando

Ciclo completo executado no AWS Academy Learner Lab (identidade IAM `voclabs`, **não-root**):
`terraform apply` → 15 recursos criados → API respondendo → `terraform destroy` → 15 destruídos.

IP público da instância: `3.84.29.202` (efêmero; recurso já destruído).

```json
GET /
{"message":"TechNova API - Rodando na AWS!","hostname":"ip-10-0-1-222.ec2.internal","uptime_s":6,"aula":"04"}

GET /health
{"status":"healthy","service":"technova-api"}

GET /orders
{"orders":[{"id":1,"product":"Widget A","status":"shipped"},{"id":2,"product":"Widget B","status":"processing"}]}
```

### Evidência do Terraform Plan

```
Plan: 18 to add, 0 to change, 0 to destroy.

  # aws_vpc.main                                    # aws_security_group.api
  # aws_subnet.public["public-1"]                   # aws_security_group.db
  # aws_subnet.public["public-2"]                   # aws_key_pair.main
  # aws_subnet.private["private-1"]                 # tls_private_key.ssh
  # aws_subnet.private["private-2"]                 # local_file.private_key
  # aws_internet_gateway.main                       # aws_iam_role.ec2_role[0]
  # aws_route_table.public                          # aws_iam_role_policy_attachment.ec2_s3_read[0]
  # aws_route_table_association.public["public-1"]  # aws_iam_instance_profile.ec2_profile[0]
  # aws_route_table_association.public["public-2"]  # aws_instance.api
```

> **Nota sobre o Instance Profile:** o TF exige criar uma IAM Role própria (comprovado pelo
> `plan`, `create_iam_role=true`). O AWS Academy Learner Lab (role `voclabs`) bloqueia
> `iam:CreateRole`; por isso o `apply` funcional usou o `LabInstanceProfile` já existente
> (`create_iam_role=false`), mantendo a EC2 com credenciais temporárias via role, sem
> access keys no código.

> **Custos:** apenas recursos Free Tier (t2.micro) foram usados e **todos foram destruídos**
> imediatamente após a captura das evidências. Nenhum recurso permanece ativo.
