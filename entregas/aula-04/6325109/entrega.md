# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Carina Gonçalves dos Santos Dalpino
**RA:** 6325109
**Data:** 05/09/2026

---

## Repositório

- URL: https://github.com/CarinaDalpino/unifaat-devops-portfolio
- Pasta do projeto: `aula-04/`

---

## Evidências

- [x] VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs (us-east-1a e us-east-1b)
- [x] Internet Gateway + Route Tables configurados
- [x] Security Groups com menor privilégio (API: 22/3000; DB: 5432 apenas da VPC)
- [x] EC2 t3.micro com User Data (API rodando via systemd)
- [x] Instance Profile com IAM Role (`LabInstanceProfile` / `LabRole` — AWS Academy Learner Lab)
- [x] Tags nos recursos
- [x] `evidencia-plan.txt` com evidência do plano Terraform
- [x] README com diagrama da arquitetura Multi-AZ
- [x] `terraform destroy` executado após captura das evidências

> **Nota sobre instance type:** O requisito especifica `t2.micro`, porém na conta AWS Academy utilizada (us-east-1) o `t2.micro` não estava disponível como Free Tier elegível. Foi utilizado `t3.micro`, também elegível ao Free Tier e de geração mais recente. Decisão documentada no README do projeto.

---

## Evidência da API Rodando

Resposta do `curl http://<IP>:3000`:
```json
{"message":"TechNova API rodando na AWS!","version":"1.0.0","environment":"production","timestamp":"2026-09-03T00:16:05.179Z"}
```

Resposta do `curl http://<IP>:3000/health`:
```json
{"status":"healthy","uptime":56.354126053,"timestamp":"2026-09-03T00:16:05.490Z"}
```

---

## Evidência SSH + IAM Role

```bash
$ ssh -i technova-key.pem ec2-user@<IP> "node --version && aws sts get-caller-identity"

v18.20.8
{
    "UserId": "AROA6AE45F7JHCUFNKEDI:i-0b7377319096f94e6",
    "Account": "962401742802",
    "Arn": "arn:aws:sts::962401742802:assumed-role/LabRole/i-0b7377319096f94e6"
}
```

A instância utilizou o `LabInstanceProfile` (contendo a `LabRole`) — sem nenhuma access key hardcoded no código.
