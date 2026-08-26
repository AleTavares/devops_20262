# Entrega — Aula 01: Fundamentos de Git e Docker

**Aluno:** Carollini Godoy
**RA:** 3925000
**Data:** 25/08/2026

## Repositório

* URL: https://github.com/caroll143/unifaat-devops-portfolio

## Evidências

* Repositório público com estrutura completa
* Mínimo de 5 commits demonstrando workflow Git
* Dockerfile funcional
* Container executado com sucesso

## Evidência de Container Rodando

A evidência da execução do container está disponível no arquivo `aula-01/docker-logs.txt` do repositório do portfólio.

O container foi executado utilizando:

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
