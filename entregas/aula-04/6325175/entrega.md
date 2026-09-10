# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** [João Pedro Paulino Ferreira]
**RA:** [6325175]
**Data:** [10/09/2026]

## Repositório

* URL: https://github.com/Joaoz007/unifaat-devops-portfolio.git

## Evidências

* [x] VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs
* [x] Internet Gateway + Route Tables configurados
* [x] Security Groups com menor privilégio
* [x] EC2 t2.micro com User Data (API rodando)
* [x] Instance Profile com IAM Role
* [x] Tags em todos os recursos
* [x] `evidencia-plan.txt` com evidência do plano
* [x] README com diagrama da arquitetura
* [x] `terraform destroy` executado após evidências

## Evidência da API Rodando

A infraestrutura foi criada e testada no AWS Academy Learner Lab. Após a coleta das evidências, os recursos foram removidos com `terraform destroy`.

## Observação sobre o AWS Academy

Durante a execução, o acesso aos recursos de IAM necessários para a criação do Instance Profile apresentou restrições no ambiente do AWS Academy. A limitação foi relatada ao professor, que orientou que essa situação fosse apenas registrada no TF.

## Evidência do Terraform Plan

O arquivo `aula-04/evidencia-plan.txt` contém o resultado do `terraform plan`, demonstrando a infraestrutura prevista pelo Terraform.

## Evidência do Terraform Destroy

Após a coleta das evidências, foi executado:

```bash
terraform destroy
```

Resultado:

```text
Plan: 0 to add, 0 to change, 12 to destroy.
```

Os recursos foram destruídos com sucesso, incluindo:

* VPC
* 4 subnets
* Internet Gateway
* Route Table
* associações das subnets
* Security Groups
* Key Pair
