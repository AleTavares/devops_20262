# Entrega — Aula 01: Fundamentos de Git e Docker

**Aluno:** Matheus Mantovani  
**RA:** 1120245  
**Data:** 24/08/2026

## Repositório

- URL: https://github.com/Manntto/unifaat-devops-portfolio

## Evidências

- [x] Repositório público com estrutura completa
- [x] Mínimo de 5 commits demonstrando workflow Git
- [x] Dockerfile funcional
- [x] Container rodando (evidência abaixo)

## Evidência de Container Rodando

```
=== docker ps ===
CONTAINER ID   IMAGE                  STATUS          PORTS                                         NAMES
46fb4cc7ee1e   portfolio-aula01:1.0   Up 20 seconds   0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp   portfolio-test

=== GET / ===
{
    "servico": "DevOps Portfolio API",
    "aluno": "Matheus Mantovani",
    "ra": "1120245",
    "aula": "01 - Fundamentos de Git e Docker",
    "status": "online",
    "timestamp": "2026-08-24T22:46:37.079Z"
}

=== GET /health ===
{
    "status": "healthy",
    "uptime": 20.339943772,
    "version": "1.0.0"
}

=== docker logs ===
Portfolio API rodando na porta 3000
```

## Histórico de Commits (git log)

```
99299ce docs: adiciona evidência de container rodando (docker-logs.txt)
077bbb4 docs: adiciona README com aprendizados da aula 01
2bd570e feat: adiciona Dockerfile e .dockerignore para containerização
e9ab0cf feat: cria aplicação Express para aula 01
f0a114f docs: estrutura inicial do portfólio DevOps
```

## Estrutura do Repositório

```
unifaat-devops-portfolio/
├── README.md
├── .gitignore
└── aula-01/
    ├── README.md
    ├── docker-logs.txt
    └── app/
        ├── server.js
        ├── package.json
        ├── Dockerfile
        └── .dockerignore
```
