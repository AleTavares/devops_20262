# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Renan Dias

**RA:** 6325033

**Data:** 07/09/2026

---

## Repositório

- URL: https://github.com/diazrenan/unifaat-devops-portfolio

- Pasta do projeto: `aula-04/`

---

## Evidências

- [x] VPC `10.0.0.0/16` com 4 subnets (2 públicas + 2 privadas) distribuídas em 2 AZs

- [x] Internet Gateway + Route Table pública configurados

- [x] Security Groups configurados (API: 22/3000; DB: 5432 apenas da VPC)

- [x] EC2 `t2.micro` com User Data e API Node.js rodando na porta 3000

- [x] Instance Profile com IAM Role (`LabInstanceProfile` / `LabRole` — AWS Academy Learner Lab)

- [x] Tags de identificação nos recursos

- [x] `terraform plan` executado e validado

- [x] README com diagrama da arquitetura Multi-AZ

- [x] API validada através de `curl`

- [x] Acesso SSH + validação da IAM Role realizados

> **Nota sobre IAM:** O AWS Academy Learner Lab não permitiu a criação de uma nova IAM Role através do Terraform (`iam:CreateRole`). Por isso, foi utilizado o `LabInstanceProfile`, que referencia a `LabRole` disponibilizada pelo próprio ambiente AWS Academy.

---

## Infraestrutura

**VPC:** `10.0.0.0/16`

**VPC ID:** `vpc-06d35920d676b976f`

### Subnets públicas

- `10.0.1.0/24` — `subnet-074a9069144b9ed8b`
- `10.0.3.0/24` — `subnet-08a86df42986c573d`

### Subnets privadas

- `10.0.2.0/24` — `subnet-061d6183eb3091148`
- `10.0.4.0/24` — `subnet-0fab233b5b9aa89ff`

A infraestrutura foi distribuída entre duas Availability Zones, mantendo duas subnets públicas e duas privadas.

---

## Security Groups

### API

**Security Group:** `sg-0bc99eaf599a76751`

- TCP 22 — `0.0.0.0/0` — acesso SSH
- TCP 3000 — `0.0.0.0/0` — acesso à API

### DB

**Security Group:** `sg-03440bab5c0a78571`

- TCP 5432 — `10.0.0.0/16` — acesso PostgreSQL somente dentro da VPC

---

## EC2

Foi utilizada uma instância `t2.micro` em uma subnet pública.

A configuração da aplicação foi realizada automaticamente através do `user_data.sh`.

**IP público:** `34.234.96.233`

**API:** `http://34.234.96.233:3000`

A aplicação utiliza Node.js e disponibiliza os endpoints `/` e `/health`.

---

## Evidência da API Rodando

Resposta do:

```bash
curl http://34.234.96.233:3000
```

v18.20.8

{
"UserId": "AROASFPYGPBXNFG5IKIBC:i-0d185689dee91ca32",
"Account": "149233760366",
"Arn": "arn:aws:sts::149233760366:assumed-role/LabRole/i-0d185689dee91ca32"
}
