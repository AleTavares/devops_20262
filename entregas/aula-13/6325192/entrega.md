# Entrega — Aula 13 (TF)

**Aluno:** Emar Cristian Silva Teruo Ito
**RA:** 6325192
**Data:** 26/11/2026

## Fork do projeto

- URL: https://github.com/iHawlKz7/implement_Moodle
- Commit desta semana: https://github.com/iHawlKz7/implement_Moodle/commit/e43c50b

## O que foi feito nesta aula

Nesta etapa, avancei na implantação do Moodle utilizando Terraform e AWS Academy Learner Lab.

- Publiquei a imagem Docker personalizada do Moodle no Docker Hub.
- Configurei as variáveis de ambiente e as credenciais necessárias à infraestrutura.
- Executei `terraform validate` e `terraform plan` antes do provisionamento.
- Provisionei a VPC, as subnets, os Security Groups e o banco RDS PostgreSQL 15.
- Criei uma instância EC2 com Amazon Linux 2023 e inicialização automatizada.
- Corrigi incompatibilidades identificadas durante a execução do Terraform.
- Confirmei a instalação automática do Moodle e sua conexão com o PostgreSQL.
- Acessei a página inicial do Moodle pelo endereço público da EC2.
- Registrei uma captura da aplicação funcionando no repositório.
- Ainda faltam a validação do GitHub Actions e a revisão final da documentação da prova.
- O próximo passo será finalizar essas evidências e preparar a entrega acadêmica.

## Dificuldades encontradas

Durante o provisionamento, a AWS recusou descrições de recursos contendo caracteres incompatíveis, o que exigiu ajustes nos módulos Terraform.

Também identifiquei que o volume de 20 GB configurado para a EC2 era inferior ao tamanho mínimo de 30 GB exigido pela AMI selecionada.

Após corrigir essas configurações e ajustar a senha do PostgreSQL aos requisitos do RDS, consegui concluir a implantação. Inicialmente, a aplicação não respondia pela porta 80 porque a instalação do Moodle ainda estava sendo executada. A verificação dos logs do Docker permitiu confirmar sua conclusão e o início do Apache.
