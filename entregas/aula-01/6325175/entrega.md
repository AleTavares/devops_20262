# Entrega — Aula 01: Fundamentos de Git e Docker

**Aluno:** João Pedro Paulino Ferreira
**RA:** 6325175
**Data:** 18/08/2026

## Repositório

* URL: https://github.com/Joaoz007/unifaat-devops-portfolio

## Evidências

* [x] Repositório público com estrutura completa
* [x] Mínimo de 5 commits demonstrando workflow Git
* [x] Dockerfile funcional
* [x] Container rodando

## Evidência de Container Rodando

O container `portfolio-test` foi executado com sucesso utilizando a imagem `portfolio-aula01:1.0`.

```text
CONTAINER ID   IMAGE                  STATUS          PORTS
c16d888803fc   portfolio-aula01:1.0   Up              0.0.0.0:3000->3000/tcp
```

A API também foi testada com sucesso:

```text
GET /
status: online

GET /health
status: healthy
```

## Workflow Git

A aplicação foi desenvolvida na branch:

`feature/aula-01-app`

e posteriormente integrada à `main`.

O repositório possui 5 commits seguindo o padrão Conventional Commits.
