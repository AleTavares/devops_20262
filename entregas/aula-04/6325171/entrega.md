# Entrega - Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Nicolas Jesus e Silva  
**RA:** 6325171  
**Data:** 10/09/2026

## Repositorio

- URL: https://github.com/NxcolasDev/unifaat-devops-portfolio
- Pasta: `aula-04/`

## Evidencias

### Implementado no codigo Terraform

- [x] VPC `10.0.0.0/16` com quatro subnets em duas AZs
- [x] Internet Gateway e Route Table publica
- [x] Security Groups da API e do banco
- [x] EC2 `t2.micro` com User Data
- [x] Instance Profile com IAM Role
- [x] Tags obrigatorias, incluindo `Owner=6325171`
- [x] `terraform-plan-output.txt` com plano real: 16 recursos para criar, 0 alterar, 0 destruir
- [x] README com diagrama da arquitetura

### Execucao na AWS

- [ ] API testada via `curl` nos endpoints `/`, `/health` e `/orders`
- [ ] SSH testado na instancia EC2
- [ ] `terraform destroy` executado apos as evidencias

## Limitacao encontrada

O `terraform validate` e o `terraform plan` foram executados com sucesso. O `terraform apply` foi interrompido pela permissao da conta AWS Academy, que negou `iam:CreateRole` para a role `technova-ec2-role`. Por isso, a infraestrutura esta implementada e planejada no codigo, mas a API e o SSH ainda nao possuem evidencia de execucao real.

## Evidencia da API

Pendente por limitacao de permissao IAM da conta AWS Academy. Registrar aqui as respostas de `/`, `/health` e `/orders` e a evidencia do SSH caso o professor disponibilize uma conta ou role com permissao para criar IAM Role.

Este arquivo deve ser copiado para `entregas/aula-04/6325171/entrega.md` no fork da disciplina.
