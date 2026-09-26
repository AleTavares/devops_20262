# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Maximus Ponciano  
**RA:** 6325066  
**Data:** 09/09/2026  

## Repositório

- URL: https://github.com/MaximusPonciano/unifaat-devops-portfolio
- Código do Projeto: [`aula-04/`](https://github.com/MaximusPonciano/unifaat-devops-portfolio/tree/main/aula-04)

## Evidências

- [x] VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs
- [x] Internet Gateway + Route Tables configurados
- [x] Security Groups com menor privilégio (api: 22/3000; db: 5432 só da VPC)
- [x] EC2 t2.micro com User Data (API Express rodando na porta 3000)
- [x] Instance Profile com IAM Role (LabRole / AmazonS3ReadOnlyAccess)
- [x] Tags em todos os recursos (Name, Project, Environment, ManagedBy, Owner)
- [x] `terraform-plan-output.txt` com evidência do plano (`Plan: 12 to add`)
- [x] README com diagrama da arquitetura (ASCII), decisões técnicas e tabela de recursos
- [x] `terraform destroy` executado após evidências

## Evidência da API Rodando

```json
GET /
{"servico":"TechNova API","aluno":"Maximus Ponciano","ra":"6325066","status":"online","az":"us-east-1a","timestamp":"2026-09-09T14:32:10.000Z"}

GET /health
{"status":"healthy","uptime":342,"version":"1.0.0"}
```

## Evidência do Terraform Plan

```text
Plan: 12 to add, 0 to change, 0 to destroy.

  # aws_vpc.main
  # aws_subnet.public_az1
  # aws_subnet.public_az2
  # aws_subnet.private_az1
  # aws_subnet.private_az2
  # aws_internet_gateway.main
  # aws_route_table.public
  # aws_route_table_association.public_az1
  # aws_route_table_association.public_az2
  # aws_security_group.api
  # aws_security_group.db
  # aws_instance.api
```
