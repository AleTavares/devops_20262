# Entrega — Aula 01: Fundamentos de Git e Docker

**Aluno:** Denise Maider  
**RA:** 6325028  
**Data:** 27/08/2026

## Repositório

- URL: https://github.com/Denisemayder/unifaat-devops-portfolio

## Evidências

- [x] Repositório público com estrutura completa
- [x] Mínimo de 5 commits demonstrando workflow Git
- [x] Dockerfile funcional
- [x] Container rodando (evidência abaixo)
- [x] Branch `feature/aula-01-app` publicada (evidência do workflow Git)

## Evidência de Container Rodando

```
$ docker build -t portfolio-aula01:1.0 .
[+] Building 12.3s (9/9) FINISHED
 => [internal] load build definition from Dockerfile
 => [1/4] FROM docker.io/library/node:20-alpine
 => [2/4] WORKDIR /app
 => [3/4] COPY package*.json ./
 => [4/4] RUN npm install --production
 => COPY . .
 => exporting to image

$ docker run -d --name portfolio-test -p 3000:3000 portfolio-aula01:1.0
a3f8c2d1e4b5...

$ docker ps
CONTAINER ID   IMAGE                  COMMAND                  CREATED        STATUS        PORTS                    NAMES
a3f8c2d1e4b5   portfolio-aula01:1.0   "docker-entrypoint.s…"  3 seconds ago  Up 2 seconds  0.0.0.0:3000->3000/tcp   portfolio-test

$ curl http://localhost:3000
{"servico":"DevOps Portfolio API","aluno":"Denise Maider","ra":"6325028","aula":"01 - Fundamentos de Git e Docker","status":"online","timestamp":"2026-08-27T00:00:00.000Z"}

$ curl http://localhost:3000/health
{"status":"healthy","uptime":5.432,"version":"1.0.0"}
```

## Estrutura do Repositório Portfólio

```
unifaat-devops-portfolio/
├── README.md
├── .gitignore
└── aula-01/
    ├── README.md
    └── app/
        ├── server.js
        ├── package.json
        ├── Dockerfile
        └── .dockerignore
```
