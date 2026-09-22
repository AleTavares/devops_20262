# Entrega — Aula 01

**Aluno:** Fábio Panosian  
**RA:** 6325250  
**Data:** 21/09/2026  

## Repositório do projeto

[https://github.com/fabiopanosian-droid/unifaat-devops-portfolio]

## Evidências

- API implementada com Node.js e Express.
- Endpoints `/` e `/health` funcionando.
- Dockerfile criado e imagem Docker executada com sucesso.
- Branch de funcionalidade criada e publicada.
- Alterações versionadas com Git.

## Execução do container
 
abio@fabio-Aspire-4736Z:~/unifaat-devops-portfolio$ docker ps
CONTAINER ID   IMAGE                       COMMAND                  CREATED          STATUS                            PORTS                         NAMES
301259c20f1c   portfolio-aula01:1.0        "docker-entrypoint.s…"   18 minutes ago   Up 18 minutes                     0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp   portfolio-test
f84728af656d   proj-estoque-app:latest     "docker-entrypoint.s…"   2months ago     Up Less than a second             3000/tcp                         proj_estoque_app
72397f41133d   postgres:16-alpine          "docker-entrypoint.s…"   3months ago     Up Less than a second (healthy)   5432/tcp                         proj_estoque_db
9416f69bee94   simulado_projeto_web-auth   "/docker-entrypoint.…"   5months ago     Up Less than a second                         web-auth
29801f3dad03   postgres:alpine             "docker-entrypoint.s…"   5months ago     Up Less than a second                         db-auth
