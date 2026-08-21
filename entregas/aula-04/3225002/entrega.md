# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** José Henrique Teixeira Luiz
**RA:** 3225002
**Data:** 20/08/2026

## Repositório

- URL: https://github.com/zzin742/unifaat-devops-portfolio
- Pasta da aula: https://github.com/zzin742/unifaat-devops-portfolio/tree/main/aula-04

## Evidências

- [x] VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs
- [x] Internet Gateway + Route Tables configurados
- [x] Security Groups com menor privilégio
- [x] EC2 com User Data (API rodando)
- [x] Instance Profile com IAM Role
- [x] Tags em todos os recursos
- [x] `terraform-plan-output.txt` com evidência do plano (`evidencia-plan.txt`)
- [x] README com diagrama da arquitetura
- [x] `terraform destroy` executado após evidências

## Arquitetura entregue

| Recurso | Qtd | Detalhe |
|---|---|---|
| VPC | 1 | `10.0.0.0/16`, DNS support + hostnames |
| Subnets públicas | 2 | `10.0.1.0/24` (us-east-1a), `10.0.3.0/24` (us-east-1b) |
| Subnets privadas | 2 | `10.0.2.0/24` (us-east-1a), `10.0.4.0/24` (us-east-1b) |
| Internet Gateway | 1 | + route table pública associada às 2 subnets públicas |
| Security Groups | 2 | API (22, 3000) e DB (5432 só de `10.0.0.0/16`) |
| Key pair | 1 | gerada pelo Terraform, privada salva em `~/.ssh` com `0400` |
| IAM Role + Instance Profile | 1 | `AmazonS3ReadOnlyAccess` |
| EC2 | 1 | AL2023, User Data com Node 18 + systemd |

**Total: 18 recursos.**

## ⚠️ Divergência justificada: t3.micro em vez de t2.micro

O enunciado especifica `t2.micro`. **Minha conta não consegue criar esse tipo.**

Ela usa o plano gratuito novo da AWS (créditos por 6 meses), que restringe o
`RunInstances` aos tipos *free-tier-eligible*, e o `t2.micro` saiu dessa lista.
O `apply` falha com:

```
Error: creating EC2 Instance: api error InvalidParameterCombination:
The specified instance type is not eligible for Free Tier. For a list of
Free Tier instance types, run 'describe-instance-types' with the filter
'free-tier-eligible=true'.
```

Rodando o comando que a própria AWS sugere:

```
$ aws ec2 describe-instance-types --filters "Name=free-tier-eligible,Values=true"
t3.micro   2 vCPU   1024 MiB   x86_64
t3.small   2 vCPU   2048 MiB   x86_64
t4g.micro  2 vCPU   1024 MiB   arm64
```

Usei **`t3.micro`** — equivalente direto do `t2.micro`: mesma 1 GiB de RAM e
2 vCPU, geração mais nova, igualmente dentro do Free Tier. A variável
`instance_type` tem bloco `validation` restringindo aos tipos elegíveis.

## Evidência 1 — terraform plan

```
Plan: 18 to add, 0 to change, 0 to destroy.
```

Output completo (702 linhas):
https://github.com/zzin742/unifaat-devops-portfolio/blob/main/aula-04/evidencia-plan.txt

## Evidência 2 — API rodando (curl)

```
$ curl http://100.48.223.141:3000
{
    "message": "TechNova API - Rodando na AWS!",
    "aluno": "Jose Henrique Teixeira Luiz",
    "ra": "3225002",
    "aula": "04 - VPC + EC2 Multi-AZ",
    "hostname": "ip-10-0-1-148.ec2.internal",
    "platform": "linux",
    "uptime": "84 segundos",
    "timestamp": "2026-08-21T00:21:12.837Z"
}

$ curl http://100.48.223.141:3000/health
{ "status": "healthy", "service": "technova-api" }
```

O hostname `ip-10-0-1-148` confirma que a instância está na subnet pública
`10.0.1.0/24`, em `us-east-1a`.

Arquivo: [`evidencia-api.json`](https://github.com/zzin742/unifaat-devops-portfolio/blob/main/aula-04/evidencia-api.json)

## Evidência 3 — SSH e Instance Profile

```
--- versoes ---
v18.20.8          (Node 18, conforme pedido)
git version 2.50.1

--- identidade via Instance Profile ---
{
    "Arn": "arn:aws:sts::065247282195:assumed-role/3225002-technova-ec2-role-a04/i-004a6aec37d889978"
}

--- menor privilegio: S3 e READ-ONLY ---
$ aws s3 mb s3://teste-negado-3225002
AccessDenied ... is not authorized to perform: s3:CreateBucket

--- credencial em disco? ---
$ ls ~/.aws
No such file or directory

--- servico ---
active
enabled
```

Isso demonstra os quatro pontos de uma vez: a instância se autentica como
**role assumida** (não usuário IAM), **lê** o S3, é **negada** ao tentar
escrever, e **não guarda credencial em disco**.

Arquivo: [`evidencia-ssh.txt`](https://github.com/zzin742/unifaat-devops-portfolio/blob/main/aula-04/evidencia-ssh.txt)

## Limpeza

```
Destroy complete! Resources: 18 destroyed.
```

Conta verificada após o destroy: nenhuma instância EC2, VPC não-default, key
pair, security group, volume EBS ou Elastic IP remanescente. Nada consumindo
Free Tier.
