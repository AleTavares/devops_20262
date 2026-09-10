# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Caroline Lejne Geli  
**RA:** 6325016  
**Data:** 09/09/2026

## Repositório

https://github.com/LejneGeli/unifaat-devops-portfolio/tree/main/aula-04

## Evidências

- [x] VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs
- [x] Internet Gateway + Route Tables configurados
- [x] Security Groups conforme as regras do enunciado
- [x] EC2 t2.micro com User Data e Node.js 18
- [x] Instance Profile anexado à EC2
- [x] Tags nos recursos AWS que suportam tags
- [x] terraform-plan-output.txt com evidência do plano
- [x] README com diagrama da arquitetura
- [x] terraform destroy executado: 16 recursos destruídos

## API Rodando

Resposta da raiz:

```json
{"message":"TechNova API online"}
```

Resposta de /health:

```json
{"status":"ok","service":"technova-api"}
```

## Arquivos de Evidência

- [Print da API](https://github.com/LejneGeli/unifaat-devops-portfolio/blob/main/aula-04/img-evidencia/evidencia-api.png)
- [Print do SSH](https://github.com/LejneGeli/unifaat-devops-portfolio/blob/main/aula-04/img-evidencia/evidencia-ssh.png)
- [Plano Terraform](https://github.com/LejneGeli/unifaat-devops-portfolio/blob/main/aula-04/terraform-plan-output.txt)
- [Destroy](https://github.com/LejneGeli/unifaat-devops-portfolio/blob/main/aula-04/evidencia-destroy.txt)

## Adaptação ao AWS Academy

A criação de IAM Roles foi bloqueada pelas permissões do Learner Lab.
Por isso, utilizei o LabInstanceProfile existente, associado à LabRole.
A identidade da Role foi confirmada via SSH com aws sts get-caller-identity.

Essa adaptação não equivale à criação de uma Role própria com
AmazonS3ReadOnlyAccess; fica registrada para avaliação do professor.