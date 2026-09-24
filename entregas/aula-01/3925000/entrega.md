# Entrega — Aula 01: Fundamentos de Git e Docker

**Aluno:** Carollini Godoy
**RA:** 3925000
**Data:** 25/08/2026

## Repositório

* URL: https://github.com/caroll143/unifaat-devops-portfolio

## Evidências

* [x] Repositório público com estrutura completa
* [x] Mínimo de 5 commits demonstrando workflow Git
* [x] Dockerfile funcional
* [x] Container executado com sucesso
* [x] Branch `feature/aula-01-app` publicada no GitHub

## Evidência de Container Rodando

A evidência da execução do container está disponível no arquivo `aula-01/docker-logs.txt` do repositório do portfólio.

O container foi construído e executado com:

```bash
docker build -t portfolio-aula01:1.0 .
docker run -d --name portfolio-test -p 3000:3000 portfolio-aula01:1.0
```

A aplicação foi testada nos endpoints:

```text
http://localhost:3000
http://localhost:3000/health
```

O endpoint `/` retornou os dados da aplicação e o endpoint `/health` retornou o status `healthy`.
