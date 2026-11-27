# Entrega — Aula 11 (TF)

**Aluno:** Marcos Eduardo dos Santos Sousa
**RA:** 6325127
**Data:** 27/11/2026

## Fork do projeto

- URL: https://github.com/MarcosSantt/implement_Moodle
- Commit desta semana: https://github.com/MarcosSantt/implement_Moodle/commit/bd146e9f1b6eae6c95d2ae97568197cbf0726256
- Evidências do deploy (prints): https://github.com/MarcosSantt/implement_Moodle/tree/main/evidencias/aula-11
- Documento de arquitetura: https://github.com/MarcosSantt/implement_Moodle/blob/main/docs/architecture-design.md
- Estimativa no AWS Pricing Calculator: https://calculator.aws/#/estimate?id=83b44311eac60f9c3c6f872c7e8f41e4fa144fe3

## O que foi feito nesta aula

- Fork e clone do `implement_Moodle`; validei o ambiente Docker local (`docker compose up -d` com PostgreSQL 15 em `http://localhost:8080`) e corrigi o `docker-compose.yml` para ler o `.env` em vez do `.env.example`.
- Criei a estrutura Terraform do zero: `versions.tf` (provider AWS `~> 5.0`), `main.tf`, `variables.tf`, `outputs.tf` e os módulos `networking`, `database` e `compute`.
- **networking:** VPC 10.0.0.0/16, subnet pública (EC2) e duas privadas em AZs diferentes (RDS), IGW, route table e SGs; o RDS aceita a porta 5432 só a partir do SG da EC2, e o SSH só do meu IP (com `validation` que bloqueia `0.0.0.0/0`).
- **database:** RDS PostgreSQL 15 `db.t3.micro`, 20 GB gp2, `publicly_accessible = false`, `storage_encrypted = true`, `skip_final_snapshot` para o Lab.
- **compute:** EC2 `t3.medium` com Amazon Linux 2023, `LabInstanceProfile` via data source (o Lab não deixa criar IAM), IMDSv2 obrigatório e disco encriptado.
- **user_data.sh:** instala Docker e Compose v2, clona o fork, gera o `.env` apontando para o RDS e sobe só o serviço `moodle` (`--no-deps`) na porta 80.
- Implementei o `terraform-plan.yml` (workflow_dispatch, credenciais do Learn Lab e senhas via secrets).
- `terraform validate` passou e `terraform plan` rodou na conta do Learn Lab: **16 recursos a criar**, data sources resolvidos (AMI e LabInstanceProfile).
- **Deploy na AWS:** rodei o `terraform apply` no Learn Lab. Os 16 recursos foram criados e o Moodle 4.1 abriu pelo DNS público da EC2, conectado ao RDS. O `scripts/health-check.sh` passou. Tirei prints da EC2 em execução, do RDS sem acesso público e do SG do RDS aceitando só o SG da EC2. Depois rodei o `terraform destroy` (16 recursos destruídos) para não consumir crédito do Lab.
- **Documento de arquitetura:** escrevi o `docs/architecture-design.md` a partir do template, com todas as seções preenchidas e sem `TODO`:
  - diagrama com ícones de serviço (VPC, subnets pública e privadas em 2 AZs, IGW, route table, EC2, RDS, os dois SGs e o fluxo Internet → IGW → EC2 → RDS);
  - justificativa de cada decisão de design e descrição de cada componente;
  - medidas de segurança e plano de escalabilidade para produção (ALB + Auto Scaling, EFS, RDS Multi-AZ, imagem no ECR);
  - custo estimado de **US$ 48,21/mês** no AWS Pricing Calculator (EC2 + EBS US$ 32,77, RDS US$ 15,44), mais US$ 3,65 de IPv4 público, com link e print da estimativa.
- **Ainda não está pronto:** os secrets do GitHub não estão configurados para rodar o `terraform-plan.yml` e não existe backend remoto S3/DynamoDB. O Moodle sobe, mas a instalação pelo assistente web ainda precisa ser concluída.
- **Próximo passo:** configurar os secrets e rodar os workflows no GitHub Actions, depois criar o backend S3 + DynamoDB.

## Dificuldades encontradas

- **Senhas inconsistentes no Docker local:** o compose carregava o `.env.example` no `env_file`, mas a interpolação `${...}` lia o `.env`. O Postgres subia com uma senha e o Moodle tentava conectar com outra. Resolvi usando o mesmo `.env` nos dois serviços.
- **Restrições do Learn Lab:** sem permissão de IAM, não dá para criar role ou instance profile. Usei `data "aws_iam_instance_profile"` para reaproveitar o `LabInstanceProfile`. O RDS também exige subnet group em 2 AZs, então criei duas subnets privadas.
- **Moodle na EC2 com RDS:** o compose do template sobe um contêiner `db` local. Na EC2 o banco é o RDS, então o `user_data.sh` gera o `.env` com o endpoint do RDS e usa `docker compose up --no-deps moodle`, mais um override para expor a porta 80.
- **Moodle não subia na EC2 (1ª tentativa):** o `apply` funcionou, mas o site não respondia e o health check falhou. Como a EC2 não tinha chave SSH, li o log de boot com `aws ec2 get-console-output` e achei o erro `compose build requires buildx 0.17.0 or later`: o Docker do Amazon Linux 2023 não traz o plugin buildx. Corrigi instalando o plugin no `user_data.sh`.
- **Script de boot morrendo sem mensagem clara (2ª tentativa):** para pegar a versão mais recente do buildx usei `curl ... | grep -m1`. Com `set -o pipefail`, o `grep` fecha o pipe depois da primeira linha, o `curl` recebe SIGPIPE e o `set -e` encerra o script. Fixei a versão do buildx (`v0.39.1`), o que também deixa o boot reproduzível. Na 3ª tentativa o Moodle respondeu em cerca de 4 minutos. Como o recurso tem `user_data_replace_on_change = true`, o Terraform recriou só a EC2 a cada correção e manteve o RDS e a rede.
- **Estimativa de custo com valores errados:** na primeira tentativa, a calculadora deu US$ 18,83 para a EC2 em "Leste dos EUA (Boston)". Boston é uma Local Zone, não a `us-east-1`, e a calculadora já vem com Compute Savings Plans marcado. No RDS ela vem com Multi-AZ, RDS Proxy, Database Insights e Suporte estendido ligados, o que passaria de US$ 80/mês. Refiz em N. da Virgínia, com Sob demanda e Single-AZ e essas opções desligadas, para refletir exatamente o Terraform.
- **Segredos no repositório:** percebi que o `.gitignore` do template não ignorava `.terraform/` nem o arquivo `tfplan`, que guarda as senhas em texto. Adicionei essas regras antes de commitar e conferi que nenhuma credencial entrou no commit.
