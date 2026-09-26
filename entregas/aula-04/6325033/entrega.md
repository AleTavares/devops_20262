# Entrega Aula 04 - Terraform e AWS

## Aluno

- Nome: Renan Dias
- RA: 6325033
- Data: 19/09/2026

## Repositório

https://github.com/diazrenan/unifaat-devops-portfolio

## Estrutura da entrega

A infraestrutura da Aula 04 foi implementada utilizando Terraform e está organizada diretamente no diretório `aula-04/` do repositório de portfólio.

A entrega contém:

- Configuração do provider AWS
- VPC e subnets Multi-AZ
- Internet Gateway e tabela de rotas pública
- Security Groups
- Key Pair
- Instância EC2
- User Data
- Outputs do Terraform
- Evidências de execução
- README com documentação e diagrama da arquitetura

## Checklist da atividade

- [x] VPC criada com CIDR `10.0.0.0/16`
- [x] DNS Support e DNS Hostnames habilitados
- [x] 4 subnets criadas: 2 públicas e 2 privadas
- [x] Subnets distribuídas em 2 Availability Zones
- [x] Subnets públicas com atribuição automática de IP público
- [x] Internet Gateway configurado
- [x] Route Table pública configurada com rota `0.0.0.0/0` para o Internet Gateway
- [x] As duas subnets públicas associadas à Route Table pública
- [x] Subnets privadas sem rota direta para a Internet
- [x] Security Group da API configurado
- [x] Porta SSH `22` configurada no Security Group da API
- [x] Porta `3000` configurada no Security Group da API
- [x] Security Group do banco criado
- [x] Porta `5432` restrita ao CIDR da VPC no Security Group do banco
- [x] Instância EC2 `t2.micro` criada
- [x] Amazon Linux 2023 utilizado
- [x] User Data configurado
- [x] Node.js 18 instalado automaticamente pela User Data
- [x] API TechNova executando na porta `3000`
- [x] Instance Profile `LabInstanceProfile` utilizado
- [x] Key Pair configurado via Terraform
- [x] Tags aplicadas aos recursos
- [x] Evidência do `terraform plan` gerada
- [x] README com diagrama da arquitetura
- [x] API testada via HTTP
- [x] Acesso SSH testado
- [x] `terraform destroy` executado ao final da atividade

## API

A API foi executada na instância EC2 durante a validação da infraestrutura.

URL utilizada nos testes:

http://44.204.141.114:3000

Endpoints testados:

- `/`
- `/health`
- `/orders`

### Resultado dos testes

O endpoint `/` retornou o status da aplicação.

O endpoint `/health` confirmou que o serviço estava saudável.

O endpoint `/orders` retornou dados de exemplo da API.

Após a conclusão dos testes, a infraestrutura foi destruída com `terraform destroy`, conforme solicitado na atividade.

## Evidências geradas

### Terraform Plan

- `evidencia-plan.txt`
- `terraform-plan-output.txt`

### API

- `evidencia-api.json`

### SSH

- `evidencia-ssh.txt`

## Links diretos do código Terraform

- [providers.tf](https://github.com/diazrenan/unifaat-devops-portfolio/blob/feature/aula-04-terraform/aula-04/providers.tf)
- [main.tf](https://github.com/diazrenan/unifaat-devops-portfolio/blob/feature/aula-04-terraform/aula-04/main.tf)
- [variables.tf](https://github.com/diazrenan/unifaat-devops-portfolio/blob/feature/aula-04-terraform/aula-04/variables.tf)
- [outputs.tf](https://github.com/diazrenan/unifaat-devops-portfolio/blob/feature/aula-04-terraform/aula-04/outputs.tf)
- [key_pair.tf](https://github.com/diazrenan/unifaat-devops-portfolio/blob/feature/aula-04-terraform/aula-04/key_pair.tf)
- [user_data.sh](https://github.com/diazrenan/unifaat-devops-portfolio/blob/feature/aula-04-terraform/aula-04/user_data.sh)
- [.gitignore](https://github.com/diazrenan/unifaat-devops-portfolio/blob/feature/aula-04-terraform/aula-04/.gitignore)

## Links diretos das evidências

- [terraform-plan-output.txt](https://github.com/diazrenan/unifaat-devops-portfolio/blob/feature/aula-04-terraform/aula-04/terraform-plan-output.txt)
- [evidencia-plan.txt](https://github.com/diazrenan/unifaat-devops-portfolio/blob/feature/aula-04-terraform/aula-04/evidencia-plan.txt)
- [evidencia-api.json](https://github.com/diazrenan/unifaat-devops-portfolio/blob/feature/aula-04-terraform/aula-04/evidencia-api.json)
- [evidencia-ssh.txt](https://github.com/diazrenan/unifaat-devops-portfolio/blob/feature/aula-04-terraform/aula-04/evidencia-ssh.txt)

## Documentação

- [README.md](https://github.com/diazrenan/unifaat-devops-portfolio/blob/feature/aula-04-terraform/aula-04/README.md)

## Observação sobre o AWS Academy

A infraestrutura foi desenvolvida com Terraform e executada no AWS Academy Learner Lab.

O projeto utiliza o Instance Profile `LabInstanceProfile`, disponibilizado pelo ambiente AWS Academy, para a instância EC2.

A utilização desse Instance Profile evita a criação de uma nova Role IAM dentro do ambiente controlado do Learner Lab.

## Organização do projeto

Os arquivos Terraform e as evidências estão diretamente no diretório:

`aula-04/`

Não há mais uma pasta intermediária `aula-04/terraform/`.

Essa organização foi realizada para facilitar a avaliação do código e das evidências diretamente no repositório de portfólio.

## Conclusão

A infraestrutura proposta para a Aula 04 foi implementada com Terraform, validada no AWS Academy Learner Lab e documentada no README do projeto.

Foram realizados testes da API, acesso SSH e validação da infraestrutura, seguidos da execução do `terraform destroy` ao final da atividade.
