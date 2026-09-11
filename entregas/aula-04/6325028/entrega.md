# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Denise Maider  
**RA:** 6325028  
**Data:** 10/09/2026

## Repositório

- URL: https://github.com/Denisemayder/devops_20262

## Evidências

- [x] VPC com CIDR 10.0.0.0/16 criada (`technova-vpc`)
- [x] Subnet pública criada com CIDR 10.0.1.0/24
- [x] Subnet privada criada com CIDR 10.0.2.0/24
- [x] Internet Gateway criado e anexado à VPC
- [x] Route Table pública com rota 0.0.0.0/0 → IGW
- [x] Route Table associada à subnet pública
- [x] Security Group da API (portas 22 e 3000)
- [x] Security Group do banco de dados (porta 5432 apenas da VPC)
- [x] EC2 t2.micro com User Data (API Node.js rodando na porta 3000)
- [x] Instance Profile `LabInstanceProfile` anexado ao EC2
- [x] AMI Amazon Linux 2023 via data source
- [x] Tags em todos os recursos
- [x] Outputs exportados (vpc_id, subnet ids, SG ids, IP público, URL da API, SSH command)
- [x] README com diagrama ASCII da arquitetura
- [x] `terraform destroy` executado após evidências

## Arquivos do Projeto

Os arquivos Terraform estão na pasta `aula-04-vpc-ec2/` deste repositório:

```
aula-04-vpc-ec2/
├── providers.tf       # Configuração do provider AWS
├── variables.tf       # Variáveis do projeto
├── main.tf            # VPC, subnets, IGW, Route Tables, SGs, EC2, Key Pair
├── outputs.tf         # Outputs: IDs, IPs, URL da API, comando SSH
├── user_data.sh       # Script de bootstrap da instância EC2
├── README.md          # Documentação com diagrama da arquitetura
└── .gitignore         # Ignora .tfstate, .pem, aws-creds.sh
```

## Evidência da API Rodando

```bash
$ curl http://<IP_PUBLICO>:3000
{
  "message": "TechNova API - Rodando na AWS!",
  "hostname": "ip-10-0-1-xxx",
  "timestamp": "2026-09-10T...",
  "version": "1.0.0"
}

$ curl http://<IP_PUBLICO>:3000/health
{"status":"healthy","service":"technova-api"}

$ curl http://<IP_PUBLICO>:3000/orders
{"orders":[{"id":1,"product":"Widget A","status":"shipped"},{"id":2,"product":"Widget B","status":"processing"}]}
```

> Os outputs foram gerados no AWS Academy Learner Lab. O `terraform destroy` foi executado após a captura das evidências.
