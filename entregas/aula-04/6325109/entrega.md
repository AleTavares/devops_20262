# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Carina Gonçalves dos Santos Dalpino  
**RA:** 6325109  
**Data:** 25/08/2026

## Repositório

- URL: https://github.com/CarinaDalpino/unifaat-devops-portfolio

## Evidências

- [x] VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs
- [x] Internet Gateway + Route Tables configurados
- [x] Security Groups com menor privilégio
- [x] EC2 t3.micro com User Data (API rodando)
- [x] Instance Profile com IAM Role
- [x] Tags em todos os recursos
- [x] `evidencia-plan.txt` com evidência do plano
- [x] README com diagrama da arquitetura
- [x] `terraform destroy` executado após evidências

## Evidência da API Rodando

```json
{"message":"TechNova API rodando na AWS!","version":"1.0.0","environment":"production","timestamp":"2026-08-26T23:00:48.915Z"}
{"status":"healthy","uptime":63.718748373,"timestamp":"2026-08-26T23:00:49.489Z"}
```

## Evidência do SSH

```
v18.20.8
{
    "UserId": "AROAZAOVPOXKRCHGRG66N:i-025ae5e650a218bb2",
    "Account": "619459868117",
    "Arn": "arn:aws:sts::619459868117:assumed-role/technova-ec2-role/i-025ae5e650a218bb2"
}
```

**Outputs do Terraform:**
```
api_url        = "http://44.195.79.186:3000"
ec2_public_ip  = "44.195.79.186"
vpc_id         = "vpc-08493734e9b3b1e97"
public_subnet_ids  = ["subnet-072ea228da6cd1373", "subnet-008144a3ee9ced578"]
private_subnet_ids = ["subnet-08544414352d3f293", "subnet-0617a0d60954f653b"]
```
