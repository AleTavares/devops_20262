# Entrega — Aula 11 (TF)

**Aluno:** Carina Gonçalves dos Santos Dalpino
**RA:** 6325109
**Data:** 18/11/2026

## Fork do projeto

- URL: https://github.com/CarinaDalpino/implement_Moodle
- Commit desta semana: https://github.com/CarinaDalpino/implement_Moodle/commit/5894d7874fd6a3b271ed34d13b3004ec2e3059fd
- Evidências (print e saídas dos comandos): pasta `docs/` do fork, arquivos `evidencias-aula-11.md` e `img/print-moodle.png`

## O que foi feito nesta aula

Trabalhei no ambiente Docker local do desafio, partindo do template do `implement_Moodle`.
Subi o Moodle com `docker compose up -d` (Moodle com PHP 8.1 e PostgreSQL 15). A aplicação responde em http://localhost:8080 e redireciona para `/admin/index.php`.
Ao validar a imagem, vi que o instalador do Moodle não listava o PostgreSQL como opção de banco de dados.
O `Dockerfile` instalava apenas o driver `pdo_pgsql`, e o instalador do Moodle usa a extensão nativa `pgsql`.
Adicionei a extensão `pgsql` ao `docker-php-ext-install` em `docker/Dockerfile`, com um comentário explicando o motivo.
Depois do rebuild, as extensões `pgsql` e `pdo_pgsql` aparecem carregadas na imagem e os dois contêineres ficam `Up` (o banco como `healthy`).
O commit com a correção (`5894d78`) está na `main` do meu fork.
Ainda não está pronto: o módulo Terraform, o ambiente na AWS e o documento de arquitetura.
Próximo passo: provisionar a infraestrutura na AWS com Terraform: criar VPC, sub-redes públicas e privadas, grupos de segurança, uma instância EC2 e um banco RDS PostgreSQL, respeitando as restrições do AWS Learn Lab.

## Dificuldades encontradas

O instalador do Moodle não mostrava o PostgreSQL como banco disponível, mesmo com o `pdo_pgsql` instalado.
Percebi que o Moodle depende da extensão nativa `pgsql`, e não só do driver PDO.
A solução foi incluir a `pgsql` na lista de extensões do Dockerfile e reconstruir a imagem.
Outra dificuldade foi rodar o `docker compose` na pasta errada: o `docker-compose.yml` fica em `docker/`, então usei `-f docker/docker-compose.yml` ou entrei na pasta `docker/`.