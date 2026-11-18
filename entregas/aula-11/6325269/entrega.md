# Entrega — Aula 11 (TF)

**Aluno:** Sirlande Martins
**RA:** 6325269
**Data:** 18/11/2026

## Fork do projeto

- URL: https://github.com/Sir-Jr/implement_Moodle
- Commit desta semana: https://github.com/Sir-Jr/implement_Moodle/commit/56fd6fa42735e0b98cc0cf8d2282044d3cb5a275

## O que foi feito nesta aula

Nesta aula, eu segui os passos do TF para preparar o meu ambiente para a prova, fiz o fork do repositório `implement_Moodle`, clonei localmente e fiz a leitura de alguns arquivos solicitados, incluindo o `CHALLENGE.md`, a pasta `/docs` e `tests/`, para entender melhor o que estava sendo pedido para a prova.

Ao analisar o ambiente Docker, minha IA identificou que os serviços `db` e `moodle` carregavam o `.env.example`, enquanto as variáveis do Moodle eram lidas do `.env`. Com isso, ao trocar as senhas, o banco continuaria com a senha de exemplo e o Moodle usaria a nova. Corrigi os dois serviços para usarem o `.env` e ajustei o workflow `docker-lint.yml` para criar esse arquivo antes da validação. Também pedi para incluir o diretório `.terraform/` no `.gitignore` e solicitei a estrutura inicial do Terraform, com os módulos `networking`, `compute` e `database`, que passou no `terraform fmt`, no `terraform validate` e nos 63 testes do `pytest`.

## Dificuldades encontradas

A dificuldade maior foi na etapa de teste do ambiente Docker. Não foi com os comandos, pois consegui acompanhar o fluxo de trabalho com a minha IA, porém a porcaria da internet da faculdade atrasou bastante a subida do ambiente Docker, o download do `postgres:15` e do `php:8.1-apache` demorou muito e, até o momento desta entrega, o Moodle ainda não tinha subido. Entretanto, vou testar esse ambiente Docker novamente antes de começar a prova. Fiz a entrega desse TF pois eu li que eram permitidas entregas parciais.
