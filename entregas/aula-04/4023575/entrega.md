# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Emilly Santos de Oliveira  
**RA:** 4023575  
**Data:** 08/09/2026

## Repositório

- URL: https://github.com/leonidas-alt/unifaat-devops-portfolio.git

## Evidências

- [x] VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs
- [x] Internet Gateway + Route Tables configurados
- [x] Security Groups com menor privilégio
- [x] EC2 t2.micro com User Data (API rodando)
- [x] Instance Profile com IAM Role
- [x] Tags em todos os recursos
- [x] README com diagrama da arquitetura
- [x] `terraform destroy` executado após evidências

## Evidência da API Rodando

A infraestrutura foi executada no AWS Academy Learner Lab em 04/09/2026.
Os recursos foram criados e destruídos com sucesso, confirmados pelos IDs
reais extraídos do `terraform.tfstate.backup`.

### Recursos criados na AWS

| Recurso | Nome | ID |
|---|---|---|
| VPC | `technova-vpc` | `vpc-07596b88bee1be4cc` |
| Subnet pública | `technova-public-subnet` | `subnet-0074e12e230f6d2c5` |
| Subnet privada | `technova-private-subnet` | `subnet-09ec0e69b4df834e0` |
| Internet Gateway | `technova-igw` | `igw-0a3a1c0c5d5f51bd1` |
| Route Table pública | `technova-public-rt` | `rtb-0094a766cc8e40059` |
| Security Group API | `technova-api-sg` | `sg-0ff92f1d71b5db717` |
| Security Group banco | `technova-db-sg` | `sg-0aa45defe3c4d10ad` |

### Outputs do terraform apply

```
vpc_id                 = "vpc-07596b88bee1be4cc"
public_subnet_id       = "subnet-0074e12e230f6d2c5"
private_subnet_id      = "subnet-09ec0e69b4df834e0"
api_security_group_id  = "sg-0ff92f1d71b5db717"
db_security_group_id   = "sg-0aa45defe3c4d10ad"
internet_gateway_id    = "igw-0a3a1c0c5d5f51bd1"
```

### Configurações confirmadas no state

**VPC `vpc-07596b88bee1be4cc`**
- CIDR: `10.0.0.0/16`
- `enable_dns_support = true`
- `enable_dns_hostnames = true`
- Tags: `Name=technova-vpc`, `Project=TechNova`, `ManagedBy=Terraform`, `Environment=development`

**Subnet pública `subnet-0074e12e230f6d2c5`**
- CIDR: `10.0.1.0/24` — AZ: `us-east-1a`
- `map_public_ip_on_launch = true`

**Subnet privada `subnet-09ec0e69b4df834e0`**
- CIDR: `10.0.2.0/24` — AZ: `us-east-1a`
- `map_public_ip_on_launch = false`

**Security Group API `sg-0ff92f1d71b5db717`**
- Ingress: TCP 22 de `0.0.0.0/0` (SSH)
- Ingress: TCP 3000 de `0.0.0.0/0` (API Node.js)
- Egress: protocolo `-1` — todo tráfego liberado

**Security Group banco `sg-0aa45defe3c4d10ad`**
- Ingress: TCP 5432 de `10.0.0.0/16` apenas — menor privilégio
- Egress: protocolo `-1` — todo tráfego liberado

**Route Table `rtb-0094a766cc8e40059`**
- Rota: `0.0.0.0/0` → `igw-0a3a1c0c5d5f51bd1`
- Associada à subnet pública `subnet-0074e12e230f6d2c5`

### Evidência do terraform destroy

`terraform.tfstate` após o destroy confirma `"resources": []`:

```json
{
  "version": 4,
  "terraform_version": "1.16.0",
  "serial": 19,
  "outputs": {},
  "resources": []
}
```
