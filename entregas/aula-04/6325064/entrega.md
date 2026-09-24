## Entrega — Aula 04: VPC + EC2 Multi-AZ

Aluno: Henri da Silva Despezzi
RA: 6325064
Data: 09/09/2026

Repositório
URL: https://github.com/HenriSD/unifaat-devops-portfolio
Branch de desenvolvimento: feature/aula-04-vpc-ec2
Implementação disponível na pasta aula-04/
Evidências
 VPC com 4 subnets (2 públicas + 2 privadas) em 2 AZs
 Internet Gateway + Route Tables configurados
 Security Groups com menor privilégio
 EC2 t2.micro com User Data para execução da API na porta 3000
 Instance Profile com IAM Role e permissão AmazonS3ReadOnlyAccess
 Tags nos recursos conforme especificação
 Outputs Terraform configurados
 README com diagrama da arquitetura e instruções de uso
 .gitignore configurado para proteger credenciais, tfvars, chaves SSH e estado do Terraform
 terraform-plan-output.txt — não foi possível gerar devido à indisponibilidade do AWS Academy
 Evidência da API Rodando — não foi possível executar a EC2 devido à indisponibilidade do AWS Academy
 terraform destroy — não executado, pois o terraform apply não chegou a ser realizado
Arquitetura Implementada

A infraestrutura Terraform foi desenvolvida conforme os requisitos da atividade:

VPC 10.0.0.0/16
Duas Availability Zones
Subnet pública 10.0.1.0/24
Subnet privada 10.0.2.0/24
Subnet pública 10.0.3.0/24
Subnet privada 10.0.4.0/24
Internet Gateway
Route Table pública com rota 0.0.0.0/0
Security Group da API
Security Group para banco PostgreSQL futuro
EC2 t2.micro
Key Pair criado via Terraform
IAM Role e Instance Profile
User Data para instalação e execução da API Node.js
Evidência da Indisponibilidade do AWS Academy

A execução prática foi impedida por um erro no ambiente do AWS Academy Learner Lab.

Ao tentar iniciar o laboratório, o ambiente permaneceu no estado:

CREATE_FAILED

Mensagem apresentada:

CloudFormation did not receive a response from your Custom Resource. Please check your logs for requestId []. If you are using the Python cfn-response module, you may need to update your Lambda function code so that CloudFormation can attach the updated version.

Foi realizada uma tentativa de encerramento e reinicialização do Lab, porém o mesmo erro permaneceu.

Durante a tentativa de execução do Terraform, também foi identificado que as credenciais temporárias haviam expirado, resultando no erro:

ExpiredToken: The security token included in the request is expired

Por esse motivo, não foi possível realizar uma execução real do terraform apply no ambiente AWS Academy.

Validação do Projeto

A configuração Terraform foi formatada e validada localmente com sucesso:

terraform fmt
terraform validate

Success! The configuration is valid.


A implementação está disponível no repositório do portfólio, na pasta:

aula-04/

Observação

O User Data cria uma versão simplificada da API TechNova diretamente na instância EC2, pois não foi fornecido um repositório technova-api acessível para esta atividade.

A API utiliza Node.js/Express e disponibiliza os endpoints / e /health na porta 3000.

As evidências de execução no AWS Academy ficam condicionadas à disponibilidade do ambiente do laboratório.