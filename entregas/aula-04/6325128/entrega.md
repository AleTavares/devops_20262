# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Felipe Damasceno 
**RA:** 6325128  
**Data:** 03/09/2026

## Repositório

- URL: https://github.com/FelipeDesda/unifaat-devops-portfolio

## Evidências

- [x] VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs
- [x] Internet Gateway + Route Tables configurados
- [x] Security Groups com menor privilégio
- [x] EC2 t2.micro com User Data (API rodando)
- [x] Instance Profile com IAM Role
- [x] Tags em todos os recursos
- [x] `terraform-plan-output.txt` com evidência do plano
- [x] README com diagrama da arquitetura
- [x] `terraform destroy` executado após evidências

## Evidência da API Rodando

felip@SHASHUMGA:~/ADS/DEVOPS/unifaat-devops-portfolio/aula-04$ node --version && aws sts get-caller-identity
v18.19.1
{
    "UserId": "AROAVMO447UEWYI5M5A5E:user5369375=Felipe_Damasceno",
    "Account": "370367331593",
    "Arn": "arn:aws:sts::370367331593:assumed-role/voclabs/user5369375=Felipe_Damasceno"
}

felip@SHASHUMGA:~/ADS/DEVOPS/unifaat-devops-portfolio/aula-04$ curl http://$(terraform outputcurl http://$(terraform output -raw ec2_public_ip):3000
{"status":"ok","app":"technova-api","message":"API no ar!"}

felip@SHASHUMGA:~/ADS/DEVOPS/unifaat-devops-portfolio/aula-04$ curl http://$(terraform output -raw ec2_public_ip):3000/health
{"status":"ok","app":"technova-api","message":"API no ar!"}

felip@SHASHUMGA:~/ADS/DEVOPS/unifaat-devops-portfolio/aula-04$ terraform destroy

No changes. No objects need to be destroyed.

Either you have not created any objects yet or the existing objects were already deleted outside of Terraform.

Destroy complete! Resources: 0 destroyed.
