\# Entrega — Aula 04: VPC + EC2 Multi-AZ



\*\*Aluno:\*\* Matheus Gabriel Correa Braga Viana

\*\*RA:\*\* 6325053

\*\*Data:\*\* 18/09/2026



\## Repositório



\- URL: https://github.com/Matiasdocs/unifaat-devops-portfolio



\## Evidências



\- \[x] VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs

\- \[x] Internet Gateway + Route Tables configurados

\- \[x] Security Groups com menor privilégio

\- \[x] EC2 t2.micro com User Data (API rodando)

\- \[x] Instance Profile com IAM Role

\- \[x] Tags em todos os recursos

\- \[x] `terraform-plan-output.txt` com evidência do plano

\- \[x] README com diagrama da arquitetura

\- \[x] `terraform destroy` executado após evidências



\## Evidência da API Rodando



```text

{"message":"TechNova API - Rodando na AWS!","hostname":"ip-10-0-1-167.ec2.internal","timestamp":"2026-09-18T20:43:15.612Z"}

{"status":"healthy","service":"technova-api"}

{"orders":\[{"id":1,"product":"Widget A","status":"shipped"},{"id":2,"product":"Widget B","status":"processing"},{"id":3,"product":"Widget C","status":"delivered"}]}

```



\## Evidência do SSH e Instance Profile



```text

v18.20.8

{

&#x20;   "UserId": "AROAXCSSRTZJOPO7BQPNW:i-09236937c8b873958",

&#x20;   "Account": "486578167378",

&#x20;   "Arn": "arn:aws:sts::486578167378:assumed-role/LabRole/i-09236937c8b873958"

}

```



\## Observações



O AWS Academy Learner Lab bloqueia a criação de `aws\_iam\_role`/`aws\_iam\_instance\_profile`. Conforme documentado no próprio laboratório da aula (`laboratorio-parte2.md`), foi usado o instance profile pré-existente `LabInstanceProfile` (que contém a `LabRole`, com permissões incluindo S3ReadOnlyAccess) diretamente no `aws\_instance`, em vez de criar uma IAM Role nova — o que geraria erro `AccessDenied` nesse ambiente. A evidência de SSH acima confirma o uso da `LabRole` (`assumed-role/LabRole/...`), sem nenhuma access key fixa no código.



`terraform apply` criou 13 recursos com sucesso; `terraform destroy` removeu todos os 13 ao final, sem deixar nada rodando na conta AWS.

