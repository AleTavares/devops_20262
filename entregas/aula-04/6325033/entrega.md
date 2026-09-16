# Entrega Aula 04 - Terraform e AWS

## Aluno

- Nome: Renan Dias
- RA: 6325033
- Data: <COLOQUE A DATA>

## Repositório

https://github.com/diazrenan/unifaat-devops-portfolio

## Evidências

- [x] VPC criada com CIDR 10.0.0.0/16
- [x] 4 subnets criadas: 2 públicas e 2 privadas
- [x] Subnets distribuídas em 2 Availability Zones
- [x] Internet Gateway configurado
- [x] Route Table pública configurada
- [x] Subnets privadas sem rota direta para a Internet
- [x] Security Group da API configurado
- [x] Security Group do banco criado
- [x] EC2 t2.micro criada
- [x] Amazon Linux 2023 utilizado
- [x] User Data configurado
- [x] Node.js instalado automaticamente na EC2
- [x] API TechNova executando na porta 3000
- [x] Instance Profile LabInstanceProfile utilizado
- [x] Tags aplicadas aos recursos
- [x] Evidência do terraform plan
- [x] README com diagrama da arquitetura
- [x] API testada via HTTP
- [x] Acesso SSH testado
- [x] terraform destroy executado ao final da entrega

## API

URL:

http://44.204.141.114:3000

Endpoints testados:

- `/`
- `/health`
- `/orders`

## Evidências geradas

Arquivos de evidência utilizados no projeto:

- `evidencia-plan.txt`
- `evidencia-api.json`
- `evidencia-ssh.txt`

## Observação

A infraestrutura foi desenvolvida com Terraform e executada no AWS Academy Learner Lab.

O projeto utiliza o Instance Profile `LabInstanceProfile`, disponibilizado pelo ambiente AWS Academy, para a instância EC2.

O projeto completo, incluindo os arquivos Terraform, User Data, README e evidências, está disponível no repositório informado acima.
