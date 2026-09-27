# Infraestrutura — passo a passo

## 0. Pré-requisitos
- Sessão ativa no AWS Academy Learner Lab (Start Lab) e credenciais
  temporárias configuradas (`~/.aws/credentials` ou variáveis de ambiente),
  região `us-east-1`.
- Um Key Pair já criado no console EC2 (Key Pairs) — anote o nome.
- Seu repositório `prova-primeiro-bimestre-devops` já público no GitHub.

## 1. Backend remoto (uma vez só)
```bash
cd infra/backend
terraform init
terraform apply
```
Anote os outputs `bucket_tfstate_nome` e `tabela_lock_nome`.

## 2. Configurar o backend no projeto principal
Edite `infra/providers.tf` e troque `SUBSTITUA-bucket-tfstate-6325032` e
`SUBSTITUA-tf-locks-6325032` pelos nomes reais criados no passo 1
(ou mantenha os defaults se não alterou os nomes no passo 1).

## 3. Preencher variáveis
```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
# edite chave_ssh_nome, repo_url e db_password
```

## 4. Aplicar
```bash
terraform init
terraform validate
terraform plan -out=plano.tfplan
terraform apply plano.tfplan
```

## 5. Verificar
```bash
terraform output url_api
curl $(terraform output -raw url_api)/health
```
Pode levar 1-2 minutos após o apply para o `user_data` terminar de instalar
o Docker, clonar o repositório e subir o container.

## 6. Destruir ao final
```bash
terraform destroy
cd ../backend
terraform destroy   # só depois de garantir que nada mais usa esse backend
```
