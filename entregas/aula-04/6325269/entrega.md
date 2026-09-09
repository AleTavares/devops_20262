# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Sirlande Martins
**RA:** 6325269
**Data:** 09/09/2026

## Repositório

- URL: https://github.com/Sir-Jr/unifaat-devops-portfolio

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

## Evidência do Terraform Plan

```
$ terraform init && terraform validate && terraform plan

Terraform has been successfully initialized!
Success! The configuration is valid.

  # aws_vpc.main will be created
  # aws_subnet.public[0] will be created
  # aws_subnet.public[1] will be created
  # aws_subnet.private[0] will be created
  # aws_subnet.private[1] will be created
  # aws_internet_gateway.main will be created
  # aws_route_table.public will be created
  # aws_route_table_association.public[0] will be created
  # aws_route_table_association.public[1] will be created
  # aws_security_group.api will be created
  # aws_security_group.db will be created
  # aws_key_pair.main will be created
  # aws_instance.api will be created

Plan: 13 to add, 0 to change, 0 to destroy.
```

## Evidência da API Rodando

```
$ curl http://3.87.56.15:3000
{"message":"TechNova API - Rodando na AWS!","hostname":"ip-10-0-1-171.ec2.internal","timestamp":"2026-09-09T23:01:38.104Z"}

$ curl http://3.87.56.15:3000/health
{"status":"healthy","service":"technova-api"}

$ curl http://3.87.56.15:3000/orders
{"orders":[{"id":1,"product":"Widget A","status":"shipped"},{"id":2,"product":"Widget B","status":"processing"}]}

$ ssh -i ~/.ssh/technova-key ec2-user@3.87.56.15 "node --version && aws sts get-caller-identity"
v18.20.8
{
    "UserId": "AROAZER6RDLQ6CZWF5RFK:i-05a01183d64065fb6",
    "Account": "628270111457",
    "Arn": "arn:aws:sts::628270111457:assumed-role/LabRole/i-05a01183d64065fb6"
}
```

**Nota sobre o ambiente:** testado com credenciais do AWS Academy Learner Lab. A role `voclabs`
tem Deny explícito para `iam:CreateRole`, então — seguindo a orientação atualizada do
[Lab Parte 2](https://github.com/Sir-Jr/devops_20262/blob/main/aula-04/laboratorio-parte2.md) desta
aula — a EC2 usa o `LabInstanceProfile` pré-provisionado pela própria AWS Academy em vez de um IAM
Role customizado. O `aws sts get-caller-identity` executado por dentro da instância confirma o uso
da `LabRole` via Instance Profile, sem nenhuma access key hardcoded. Detalhes completos no
[`README.md`](https://github.com/Sir-Jr/unifaat-devops-portfolio/blob/main/aula-04/README.md) do
projeto.

O arquivo completo do projeto (`providers.tf`, `variables.tf`, `main.tf`, `outputs.tf`,
`user_data.sh`, `terraform-plan-output.txt`, `evidencia-api.txt`, `evidencia-ssh.txt`, `README.md`)
está versionado em
[`aula-04/`](https://github.com/Sir-Jr/unifaat-devops-portfolio/tree/main/aula-04).

`terraform destroy` foi executado ao final — nenhum recurso permanece rodando na AWS (`terraform
state list` retorna vazio).
