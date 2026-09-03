# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 2026-09-03

## Repositório

- URL: https://github.com/lucaskenway/unifaat-devops-portfolio/tree/main/aula-04

## Evidências

- [x] VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs
- [x] Internet Gateway + Route Tables configurados
- [x] Security Groups com menor privilégio
- [x] EC2 t2.micro com User Data (API rodando)
- [x] Instance Profile com IAM Role
- [x] Tags em todos os recursos
- [x] `terraform-plan-output.txt` com evidência do plano
- [x] README com diagrama da arquitetura
- [x] `terraform destroy` executado após evidências

## Evidência do Terraform Apply

Reexecutado do zero em 2026-09-03 (nova sessão do Learner Lab — `terraform plan` partiu de state vazio, 13 recursos a criar):

```
Apply complete! Resources: 2 added, 0 changed, 1 destroyed.
(aws_key_pair.main foi reimportado da conta e recriado por diferença de tags;
 os demais 11 recursos — VPC, 4 subnets, IGW, route table + associações, 2 SGs —
 foram criados na mesma execução)

Outputs:

api_security_group_id = "sg-0b6b12b58d0a2d131"
api_url = "http://54.224.222.223:3000"
db_security_group_id = "sg-083fd09033b610cf4"
ec2_public_ip = "54.224.222.223"
private_subnet_ids = [
  "subnet-063810eaf5cb2a349",
  "subnet-088f4d88dcccab752",
]
public_subnet_ids = [
  "subnet-070faff7c1de9f0f4",
  "subnet-03f317f51a02e3a42",
]
ssh_command = "ssh -i ~/.ssh/technova-key ec2-user@54.224.222.223"
vpc_id = "vpc-08f00cc5ac24fa8b3"
```

Plan completo (16 recursos planejados) em [`aula-04/evidencia-plan-inicial.txt`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-04/evidencia-plan-inicial.txt) no repositório do portfólio. Plan final sem drift (`No changes. Your infrastructure matches the configuration.`) em [`aula-04/evidencia-plan.txt`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-04/evidencia-plan.txt).

## Evidência da API Rodando

```
=== GET / ===
{"message":"TechNova API - Rodando na AWS!","hostname":"ip-10-0-1-118.ec2.internal","timestamp":"2026-09-03T18:27:30.052Z"}

=== GET /health ===
{"status":"healthy","service":"technova-api"}

=== GET /orders ===
{"orders":[{"id":1,"product":"Widget A","status":"shipped"},{"id":2,"product":"Widget B","status":"processing"}]}
```

## Evidência SSH + IAM Role

```
$ ssh -i ~/.ssh/technova-key ec2-user@54.224.222.223 "node --version && aws sts get-caller-identity"
v18.20.8
{
    "UserId": "AROA6OBGCA6ANPU5F2RQD:i-080c6f6a8f9079d36",
    "Account": "992217270144",
    "Arn": "arn:aws:sts::992217270144:assumed-role/LabRole/i-080c6f6a8f9079d36"
}
```

Confirma que a instância assume um role (sem access keys hardcoded) — nesse caso o `LabRole`, referenciado via `LabInstanceProfile`.

## Nota sobre a limitação do AWS Academy Learner Lab

A modelagem original de `iam.tf` criava um `aws_iam_role` dedicado (trust `ec2.amazonaws.com`) com `AmazonS3ReadOnlyAccess` anexado. O primeiro `terraform apply` falhou com `AccessDenied: iam:CreateRole`, pois o role assumido pelo aluno no Learner Lab (`voclabs`) não tem permissão para gerenciar IAM — só a Academy pode. A solução foi referenciar via `data` o `LabInstanceProfile` já existente na conta (que usa o `LabRole`, com permissões amplas, incluindo leitura de S3), documentada no README do projeto. Detalhes completos em [`aula-04/README.md`](https://github.com/lucaskenway/unifaat-devops-portfolio/blob/main/aula-04/README.md#decisões-técnicas).

`terraform destroy` executado ao final: `Destroy complete! Resources: 13 destroyed.` (verificado novamente em 2026-09-03, após a reexecução completa).
