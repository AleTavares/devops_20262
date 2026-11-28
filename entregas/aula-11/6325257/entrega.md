# Entrega — Aula 11 (TF)

**Aluno:** Luiza Carneiro Rolfsen
**RA:** 6325257
**Data:** 19/11/2026

## Fork do projeto

- URL: https://github.com/luizarolfsen/implement_Moodle
- Commit desta semana: https://github.com/luizarolfsen/implement_Moodle/commit/fd050773c8466e0d4ed7060de46f37ae81b6dbd1

## O que foi feito nesta aula

Copiei o .env.example para .env e preenchi as variáveis: nome do banco, usuário, senha do PostgreSQL e credenciais do administrador do Moodle. Em seguida, atualizei o docker-compose.yml para que os dois serviços (db e moodle) carregassem o .env real em vez do .env.example. Revisei o .gitignore e confirmei que o .env está listado — ele não é rastreado pelo git.

Subi o ambiente com docker compose up -d dentro do diretório docker/ e acessei http://localhost:8080 para iniciar o instalador do Moodle. Avancei pelas etapas do instalador confirmando os caminhos, selecionando PostgreSQL como banco de dados e preenchendo as credenciais conforme o .env. Ao final, o Moodle ficou acessível e os dados persistiram após docker compose restart.

## Dificuldades encontradas

Ao preencher as configurações do banco de dados no instalador web do Moodle, recebi o erro: "O PHP não foi configurado corretamente com a extensão PGSQL". O instalador exige a extensão nativa pgsql do PHP, que não estava instalada na imagem — apenas a pdo_pgsql havia sido incluída no Dockerfile. O Kiro identificou a causa e adicionou pgsql à lista do docker-php-ext-install no Dockerfile. Após reconstruir a imagem com docker compose build --no-cache e subir os containers novamente, o instalador aceitou a conexão com o PostgreSQL sem erros.