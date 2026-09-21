# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Matheus Mantovani  
**RA:** 20262  
**Data:** 18/09/2026

## Repositório

- Projeto: [unifaat-devops-portfolio](https://github.com/matheus-mantovani/unifaat-devops-portfolio)
- Código da Aula 04: [aula-04 no branch main](https://github.com/matheus-mantovani/unifaat-devops-portfolio/tree/main/aula-04)

## Evidências

- [x] VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs (us-east-1a e us-east-1b)
- [x] Internet Gateway e Route Tables configurados (RT pública associada às 2 subnets públicas)
- [x] Security Groups com princípio do menor privilégio (DB SG restrito ao CIDR da VPC)
- [x] EC2 t2.micro com User Data e API Node.js 18 na porta 3000 (via systemd)
- [x] Instance Profile: `LabInstanceProfile` do AWS Academy, sem credenciais no código
- [x] Tags em todos os recursos que suportam tags (Name, Project, Environment, ManagedBy, Owner)
- [x] [Plano Terraform](https://github.com/matheus-mantovani/unifaat-devops-portfolio/blob/main/aula-04/terraform-plan-output.txt)
- [x] [README com diagrama da arquitetura](https://github.com/matheus-mantovani/unifaat-devops-portfolio/blob/main/aula-04/README.md)
- [x] `terraform destroy` executado após as evidências

## Evidência da API Rodando

```bash
$ curl http://<EC2_PUBLIC_IP>:3000
{"message":"TechNova API - Rodando na AWS!","hostname":"ip-10-0-1-xxx","node_version":"v18.20.4","environment":"production"}

$ curl http://<EC2_PUBLIC_IP>:3000/health
{"status":"healthy","service":"technova-api","version":"1.0.0"}

$ curl http://<EC2_PUBLIC_IP>:3000/orders
{"orders":[{"id":1,"product":"Widget A","status":"shipped"},{"id":2,"product":"Widget B","status":"processing"}]}
```

> Observação: no AWS Academy Learner Lab a criação de IAM Roles é bloqueada por policy. A instância usa o `LabInstanceProfile` pré-existente (contém a `LabRole` com `AmazonS3ReadOnlyAccess` incluso). Essa abordagem está documentada no `laboratorio-parte2.md` da disciplina.
