# Entrega — Aula 11 (TF)

**Aluno:** Daniel de Oliveira Tavares Júnior  
**RA:** 6325032  
**Data:** 18/11/2026

## Link do commit

- **Fork:** https://github.com/danleltavarez/implement_Moodle
- **Commit:** https://github.com/danleltavarez/implement_Moodle/commit/2dd9152fe33931d3b2298f833692f8158f370301

## O que foi feito nesta aula

Durante o avanço do desafio Moodle, realizei melhorias na estrutura de implantação utilizando Docker e Terraform.

- Ajustei os arquivos Docker Compose para os ambientes local e AWS.
- Trabalhei na inicialização automática do Moodle por meio de um script de entrada.
- Aprimorei a configuração de segurança, incluindo permissões do arquivo `.env` e exigência de IMDSv2 na EC2.
- Revisei a comunicação entre os módulos Terraform de networking, database e compute.
- Configurei regras de segurança para permitir que o RDS PostgreSQL receba conexões somente da instância EC2.
- Executei os testes automatizados do projeto, obtendo 66 testes aprovados.
- Validei a configuração dos dois arquivos Docker Compose.
- Realizei o commit e enviei as alterações para o meu fork no GitHub.

Ainda não concluí a validação prática do build Docker nem a validação completa do Terraform. A infraestrutura AWS também não foi implantada. As estratégias de implantação Azul/Verde e Canário ainda precisam ser desenvolvidas.

## Dificuldades encontradas

Uma das principais dificuldades foi validar o ambiente de infraestrutura, pois o Docker Desktop estava sem o daemon em execução e o WSL apresentou um erro de falta de recursos ao tentar iniciar.

Com isso, não foi possível executar o build real da imagem Docker nem os comandos `terraform init` e `terraform validate`.

Também encontrei um ponto de atenção na segurança das senhas durante a instalação do Moodle: os argumentos utilizados pelo instalador PHP podem ficar visíveis na lista de processos durante a execução.

Como próximo passo, pretendo normalizar o ambiente local, concluir as validações pendentes e avançar nos conceitos de implantação Azul/Verde e Canário.
