# Aula 01 — Fundamentos de Git e Docker

## O que aprendi

- [1- commit para registrar as alterações, 2- git add para adionar e alterar os arquivos para o commit, 3- gitignore para não deixar visilvel informaçãoes importantes]
- [1- image é o molde, 2- container é a image em execução, 3- é o arquivo de receita]
## Comandos Git praticados

- [git add + git commit ]

## Comandos Docker praticados

- [docker build -t, docker run -d, docker ps, docker stop, docker rm]

## Como executar este container

```bash
cd aula-01/app
docker build -t portfolio-aula01:1.0 .
docker run -d -p 3000:3000 portfolio-aula01:1.0
curl http://localhost:3000