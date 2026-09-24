\# Entrega — Aula 04: Terraform VPC + EC2 Multi-AZ



\*\*Aluno:\*\* Pablo Augusto Ramos Sobral

\*\*RA:\*\* 6325076

\*\*Disciplina:\*\* DevOps

\*\*Aula:\*\* 04 — Terraform VPC + EC2 Multi-AZ



\## Repositório



\[Portfólio no GitHub](https://github.com/Pablao02/unifaat-devops-portfolio)



\## Branch



`feature/aula-04-vpc-ec2`



\## Implementação



Foi implementada a infraestrutura TechNova utilizando Terraform e AWS, incluindo:



\* VPC `10.0.0.0/16`

\* DNS Support e DNS Hostnames habilitados

\* 2 Availability Zones

\* 2 subnets públicas

\* 2 subnets privadas

\* Internet Gateway

\* Route Table pública e privada

\* Security Group da API

\* Security Group para banco PostgreSQL futuro

\* Instância EC2 `t2.micro`

\* Amazon Linux 2023

\* Key Pair criado via Terraform

\* User Data para instalação e execução da API Node.js

\* IAM Instance Profile utilizando a infraestrutura disponibilizada pelo AWS Academy

\* Outputs Terraform

\* Evidências de `plan`, acesso SSH e funcionamento da API



\## API



A API TechNova foi implantada automaticamente na EC2 por meio do `user\_data.sh`.



Endpoints utilizados para validação:



\* `/`

\* `/health`



A API respondeu corretamente aos testes realizados via HTTP.



\## Evidências



As evidências estão disponíveis na pasta `aula-04` do portfólio:



\* `evidencia-plan.txt`

\* `evidencia-api.json`

\* `evidencia-ssh.txt`



Também foi incluído um `README.md` com a documentação da infraestrutura, arquitetura, comandos utilizados, decisões técnicas e instruções de destruição dos recursos.



\## Observação sobre IAM



Durante a implementação, o AWS Academy bloqueou a criação de novas roles IAM com `iam:CreateRole`.



Por essa razão, foi utilizado o `LabRole` e o `LabInstanceProfile` disponibilizados pelo ambiente AWS Academy, mantendo a instância EC2 integrada ao IAM permitido pelo laboratório.



\## Status



Infraestrutura validada com Terraform e API acessível via EC2.



