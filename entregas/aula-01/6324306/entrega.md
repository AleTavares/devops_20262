# Entrega — Aula 01: Fundamentos de Git e Docker

**Aluno:** Pedro Henrique Melo Santos
**RA:** 6324306
**Data:** 23/08/2026

## Repositório

* URL: https://github.com/devpedrohenriquemelo-coder/unifaat_devops_portifolio

## Evidências

* [x] Repositório público com estrutura completa
* [x] Mínimo de 5 commits demonstrando workflow Git
* [x] Dockerfile funcional
* [x] Container rodando com evidência

## Evidência de Container Rodando

O container da aplicação foi construído com a imagem:

`portfolio-aula01:1.0`

O container foi executado utilizando a porta `3000`:

```text
docker run -d --name portfolio-test -p 3000:3000 portfolio-aula01:1.0
```

O comando `docker ps` confirmou o container em execução:

```text
CONTAINER ID   IMAGE                  STATUS       PORTS
feb83104e00c   portfolio-aula01:1.0  Up           0.0.0.0:3000->3000/tcp
```

Também foi realizado o teste do endpoint:

`http://localhost:3000/health`

A API retornou status `healthy`.

A evidência visual está disponível no portfólio:

https://github.com/devpedrohenriquemelo-coder/unifaat_devops_portifolio/blob/main/aula-01/evidencia.png

## Workflow Git

A aplicação foi desenvolvida utilizando a branch:

`feature/aula-01-app`

Após o desenvolvimento, a branch foi integrada à `main`.

O histórico do projeto contém 6 commits, incluindo:

* `docs: estrutura inicial do portfólio DevOps`
* `feat: cria aplicação Express para aula 01`
* `feat: adiciona Dockerfile e .dockerignore para containerização`
* `docs: adiciona README com aprendizados da aula 01`
* `docs: adiciona evidência de container rodando`

## Estrutura do Projeto

```text
unifaat_devops_portifolio/
├── README.md
├── .gitignore
└── aula-01/
    ├── README.md
    ├── evidencia.png
    └── app/
        ├── server.js
        ├── package.json
        ├── Dockerfile
        └── .dockerignore
```
