# Entrega - Aula 02: Docker Compose + IA como Copiloto

**Aluno:** Weslley Lucas Souza Alves
**RA:** 6325226
**Data:** 20/08/2026

## Repositório

- URL: https://github.com/lucaskenway/unifaat-devops-portfolio.git

## Arquivos entregues nesta disciplina

- `trabalho-em-aula.md` com as respostas da discussão sobre Docker Compose e uso de IA.

## Evidências disponíveis

- [Build e inicialização da API e do PostgreSQL](../img/Captura%20de%20tela%202026-08-20%20204018.png)
- [Containers ativos com `docker compose ps`](../img/Captura%20de%20tela%202026-08-20%20204018.png)
- [Rede customizada e containers conectados](../img/Captura%20de%20tela%202026-08-20%20204136.png)
- [Volume nomeado `pgdata`](../img/Captura%20de%20tela%202026-08-20%20204209.png)
- [Variáveis de ambiente da API](../img/Captura%20de%20tela%202026-08-20%20204056.png)
- [Análise do uso do Kiro](../img/Captura%20de%20tela%202026-08-20%20211006.png)

## Evidências do Trabalho de Fixação

- [ ] `docker-compose.yml` com API, PostgreSQL e Redis. As capturas comprovam API e PostgreSQL; Redis não aparece.
- [x] Volume nomeado configurado para PostgreSQL (`pgdata`).
- [ ] Rede customizada conectando os três serviços. A rede e API/PostgreSQL estão comprovadas; Redis não aparece.
- [ ] Healthchecks configurados. Não há captura suficiente para confirmar o estado dos healthchecks.
- [x] Variáveis de ambiente via `.env`.
- [x] `ia-analise.md` preenchido com reflexão crítica.

## Evidência do ambiente rodando

As capturas disponíveis comprovam a execução da API com PostgreSQL, a rede customizada, o volume nomeado e a análise do uso de IA. Elas também registram problemas encontrados durante a validação: a tabela `pedidos` não existia e houve tentativa de executar o Compose fora da pasta que contém o arquivo de configuração. Não há evidência visual do Redis nem dos healthchecks.

## Observação

O trabalho em aula foi respondido em `trabalho-em-aula.md`. O TF exige também o projeto no repositório pessoal, contendo `app.js`, `package.json`, `Dockerfile`, `.dockerignore`, `docker-compose.yml`, `.env.example`, `.gitignore` e `ia-analise.md`. Antes de enviar, ainda é necessário confirmar no repositório pessoal a inclusão do Redis e dos healthchecks.
