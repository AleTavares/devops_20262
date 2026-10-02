# Aula 04 — Terraform VPC + EC2 Multi-AZ

**Aluno:** Carollini Godoy  
**RA:** 3925000  
**Disciplina:** DevOps  
**Projeto:** TechNova

## Repositório de portfólio

https://github.com/caroll143/unifaat-devops-portfolio

## Entrega

Implementação da infraestrutura da TechNova utilizando Terraform, incluindo:

* VPC `10.0.0.0/16`;
* 2 sub-redes públicas em duas zonas de disponibilidade;
* 2 sub-redes privadas em duas zonas de disponibilidade;
* Internet Gateway e tabela de rotas pública;
* Tabela de rotas privada;
* Security Group para a API;
* Security Group para banco de dados;
* Instância EC2 `t2.micro`;
* Amazon Linux 2023;
* Key Pair criado via Terraform;
* Instance Profile do AWS Academy;
* Instalação e execução da API TechNova via User Data;
* Outputs de infraestrutura e acesso à aplicação.

## Evidências

* `aula-04/evidencia-plan.txt` — resultado do Terraform Plan.
* `aula-04/evidencia-api.json` — testes da API e do endpoint `/health`.
* `aula-04/evidencia-ssh.txt` — evidência do acesso SSH à EC2.

## Validação

A infraestrutura foi validada com:

```text
terraform fmt
terraform validate
terraform plan
terraform apply