# Entrega — Aula 04: VPC + EC2 Multi-AZ

**Aluno:** Matheus Maciel de Paula  
**RA:** 6325065  
**Data:** 10/09/2026  

## Repositório do Projeto

Código completo da infraestrutura:

https://github.com/mtmaciel1/unifaat-devops-portfolio

Diretório:

```text
aula-04/
Resumo da Implementação

Foi criada uma infraestrutura AWS utilizando Terraform, composta por:

1 VPC com CIDR 10.0.0.0/16
2 subnets públicas
2 subnets privadas
2 Availability Zones: us-east-1a e us-east-1b
1 Internet Gateway
1 Route Table pública
2 associações das subnets públicas à Route Table
1 Security Group para a API
1 Security Group para o banco de dados
1 Key Pair
1 instância EC2 t2.micro
Amazon Linux 2023
Node.js 18
API Express na porta 3000
User Data para configuração automática
Serviço systemd para inicialização automática da API
Arquitetura
                         INTERNET
                            |
                     Internet Gateway
                            |
                +-----------------------+
                |      TechNova VPC     |
                |      10.0.0.0/16      |
                +-----------------------+
                     /              \
                    /                \
             us-east-1a          us-east-1b
                |                    |
        +-------+-------+    +-------+-------+
        |               |    |               |
      Public          Private Public          Private
   10.0.1.0/24    10.0.2.0/24 10.0.3.0/24  10.0.4.0/24
        |                         |
        +------ Route Table ------+
                   |
               0.0.0.0/0
                   |
            Internet Gateway

EC2 TechNova API
        |
        +-- Subnet pública
        +-- t2.micro
        +-- Amazon Linux 2023
        +-- Node.js 18
        +-- Express
        +-- Porta 3000
Security Groups
API Security Group

Permite:

SSH na porta 22
API Node.js na porta 3000
Database Security Group

Permite:

PostgreSQL na porta 5432
Acesso somente a partir da rede interna 10.0.0.0/16
API

A aplicação possui os endpoints:

GET /
GET /health
GET /orders

A aplicação é configurada automaticamente pelo user_data.sh e utiliza um serviço systemd para permanecer ativa e iniciar automaticamente após reinicializações da EC2.

Instance Profile

O projeto foi executado no AWS Academy Learner Lab.

Devido às restrições de criação de recursos IAM existentes nesse ambiente, foi utilizado o Instance Profile disponibilizado pelo próprio laboratório:

LabInstanceProfile

A identidade AWS da instância foi verificada com:

aws sts get-caller-identity
Terraform

Os principais comandos utilizados foram:

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply

O plano inicial apresentou:

Plan: 13 to add, 0 to change, 0 to destroy.

Após o provisionamento:

Apply complete! Resources: 13 added, 0 changed, 0 destroyed.
Evidências

Os arquivos de evidência estão disponíveis no diretório aula-04 do repositório de portfólio:

aula-04/evidencia-plan.txt
aula-04/terraform-plan-output.txt
aula-04/evidencia-api.json
aula-04/evidencia-ssh.txt
Testes da API

Foram utilizados os comandos:

curl "$(terraform output -raw api_url)"
curl "$(terraform output -raw api_url)/health"
curl "$(terraform output -raw api_url)/orders"
Verificação via SSH

Foi realizado acesso à EC2 e utilizados os comandos:

node --version
aws sts get-caller-identity
Checklist
 VPC 10.0.0.0/16
 2 Availability Zones
 2 subnets públicas
 2 subnets privadas
 Internet Gateway
 Route Table pública
 Security Group da API
 Security Group do banco
 EC2 t2.micro
 Amazon Linux 2023
 Node.js 18
 API Express na porta 3000
 User Data
 Inicialização automática com systemd
 Instance Profile associado
 Tags configuradas
 Outputs Terraform
 API testada
 Acesso SSH testado
 Evidências armazenadas
 README criado
Limpeza da Infraestrutura

Após finalizar a atividade e coletar todas as evidências, a infraestrutura deve ser removida com:

terraform destroy

para que nenhum recurso da atividade permaneça ativo no AWS Academy.