# Entrega - Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Gabriel Carneiro da Silva  
**RA:** 6325300  
**GitHub:** gcdsofc  
**Data:** 10/09/2026

## Repositorio do Projeto

- URL: https://github.com/gcdsofc/unifaat-devops-portfolio
- Pasta da Aula 04: https://github.com/gcdsofc/unifaat-devops-portfolio/tree/main/aula-04
- Branch feature: https://github.com/gcdsofc/unifaat-devops-portfolio/tree/feature/aula-04-vpc-ec2

## Evidencias

- `terraform-plan-output.txt`: https://github.com/gcdsofc/unifaat-devops-portfolio/blob/main/aula-04/terraform-plan-output.txt
- `README.md` com diagrama e instrucoes: https://github.com/gcdsofc/unifaat-devops-portfolio/blob/main/aula-04/README.md
- Reflexao do lab: https://github.com/gcdsofc/unifaat-devops-portfolio/blob/main/aula-04/spec-reflexao.md

> Observacao: o `terraform plan` foi gerado com `ami_id_override` porque a conta local usada nesta maquina nao possui permissao `ec2:DescribeImages`. O projeto mantem o data source do Amazon Linux 2023 como comportamento padrao, conforme pedido no TF.

## Checklist

- [x] VPC com 4 subnets (2 publicas + 2 privadas) em 2 AZs
- [x] Internet Gateway + Route Tables configurados
- [x] Security Groups para API e banco
- [x] EC2 `t2.micro` com User Data para API Node.js
- [x] IAM Role + Instance Profile com `AmazonS3ReadOnlyAccess`
- [x] Tags `Project`, `Environment`, `ManagedBy` e `Owner`
- [x] Outputs obrigatorios (`vpc_id`, subnets, SGs, IP, URL e SSH)
- [x] `terraform-plan-output.txt` com evidencia do plano
- [x] README com diagrama da arquitetura
- [ ] Evidencias de `apply`, `curl`, `SSH` e `destroy` devem ser capturadas no AWS Academy Learner Lab ativo, para nao usar uma conta AWS sem permissao/cota da aula.
