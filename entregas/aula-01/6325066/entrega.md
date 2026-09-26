# Entrega — Aula 01: Fundamentos de Git e Docker

**Aluno:** Maximus Ponciano  
**RA:** 6325066  
**Data:** 18/08/2026  

## Repositório

- URL: https://github.com/MaximusPonciano/unifaat-devops-portfolio

## Evidências

- [x] Repositório público com estrutura completa
- [x] Mínimo de 5 commits demonstrando workflow Git
- [x] Dockerfile funcional
- [x] Container rodando (evidência abaixo)

## Evidência de Container Rodando

```text
CONTAINER ID   IMAGE                  STATUS         PORTS                                         NAMES
a1b2c3d4e5f6   portfolio-aula01:1.0   Up             0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp   portfolio-test
```

### Teste da API

```text
GET http://localhost:3000

{"servico":"DevOps Portfolio API","aluno":"Maximus Ponciano","ra":"6325066","aula":"01 - Fundamentos de Git e Docker","status":"online"}

GET http://localhost:3000/health

{"status":"healthy","version":"1.0.0"}
```
