# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Eloísa Brandão  
**RA:** 2325096  
**Data:** 06/09/2026

## Repositório

- Projeto: [unifaat-devops-portfolio](https://github.com/brandelas/unifaat-devops-portfolio)
- Código da Aula 04: [aula-04 no branch main](https://github.com/brandelas/unifaat-devops-portfolio/tree/main/aula-04)

## Evidências

- [x] VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs
- [x] Internet Gateway e Route Tables configurados
- [x] Security Groups com regras solicitadas pelo enunciado
- [x] EC2 t2.micro com User Data e API Node.js na porta 3000
- [x] Instance Profile: `LabInstanceProfile` do AWS Academy, sem credenciais no código
- [x] Tags nos recursos que suportam tags
- [x] [Plano Terraform](https://github.com/brandelas/unifaat-devops-portfolio/blob/main/aula-04/terraform-plan-output.txt)
- [x] [README com diagrama da arquitetura](https://github.com/brandelas/unifaat-devops-portfolio/blob/main/aula-04/README.md)
- [x] `terraform destroy` executado após as evidências; `terraform state list` retornou vazio

## Evidência da API Rodando

Os endpoints públicos `/`, `/health` e `/orders` foram validados após o `terraform apply`. As respostas registradas estão em [evidencia-api.json](https://github.com/brandelas/unifaat-devops-portfolio/blob/main/aula-04/evidencia-api.json).

A conexão SSH, a versão do Node.js e a identidade temporária do Instance Profile foram validadas e registradas em [evidencia-ssh.txt](https://github.com/brandelas/unifaat-devops-portfolio/blob/main/aula-04/evidencia-ssh.txt).

> Observação: no AWS Academy Learner Lab, a criação de IAM Roles é bloqueada. Por isso a instância usa o `LabInstanceProfile` pré-existente. O código também documenta o modo de role dedicada para uma conta AWS comum.
