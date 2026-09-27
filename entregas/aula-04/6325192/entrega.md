# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Emar Cristian  
**RA:** 6325192  
**Data:** 10/09/2026

## Repositório

- URL: https://github.com/iHawlKz7/unifaat-devops-portfolio.git

## Evidências

- [x] VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs
- [x] Internet Gateway + Route Tables configurados
- [x] Security Groups configurados
- [x] EC2 t2.micro com User Data e API rodando
- [x] Instance Profile configurado no AWS Academy
- [x] Implementação de IAM Role com AmazonS3ReadOnlyAccess presente no código
- [x] Tags com Owner 6325192 nos recursos
- [x] `terraform-plan-output.txt` com evidência do plano
- [x] README com diagrama da arquitetura
- [x] `terraform destroy` executado após as evidências

## Evidência da API Rodando

```json
{"message":"TechNova API - Aula 04 Multi-AZ","status":"running","hostname":"ip-10-0-1-233.ec2.internal","environment":"AWS EC2"}
{"status":"healthy","service":"technova-api","timestamp":"2026-09-11T00:42:04.245Z"}
```

## Arquivos de Evidência

Os arquivos completos estão disponíveis no diretório `aula-04/` do repositório de portfólio:

- `terraform-plan-output.txt`
- `evidencia-plan.txt`
- `evidencia-output.txt`
- `evidencia-api.json`
- `evidencia-ssh.txt`
- `evidencia-subnets.txt`
- `evidencia-destroy.txt`

## Observação sobre IAM

O AWS Academy Learner Lab não permite a criação de novas IAM Roles. Por isso, a execução prática utilizou o `LabInstanceProfile` fornecido pelo ambiente.

O código Terraform contém também a implementação da IAM Role própria com `AmazonS3ReadOnlyAccess` e Instance Profile para demonstrar a configuração solicitada.
