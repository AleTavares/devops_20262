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
- [x] `terraform-plan-output.txt` com evidência do plano
- [x] README com diagrama da arquitetura
- [x] `terraform destroy` executado após evidências

## Evidência da API Rodando

```json
{"message":"TechNova API rodando na AWS!","version":"1.0.0","environment":"production","timestamp":"2026-08-26T23:00:48.915Z"}
{"status":"healthy","uptime":63.718748373,"timestamp":"2026-08-26T23:00:49.489Z"}
```

**Outputs do Terraform:**
```
api_url        = "http://44.222.138.123:3000"
ec2_public_ip  = "44.222.138.123"
vpc_id         = "vpc-0fe88863318576cf2"
public_subnet_ids  = ["subnet-0000af303657a5215", "subnet-08eb1fe4275ff4cc6"]
private_subnet_ids = ["subnet-000ce86155be187dd", "subnet-048232018c73b0fa8"]
```
