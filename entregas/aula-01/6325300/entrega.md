# Entrega - Aula 01: Fundamentos de Git e Docker

**Aluno:** Gabriel Carneiro da Silva  
**RA:** 6325300  
**Data:** 17/08/2026

## Repositorio

- URL: https://github.com/gcdsofc/unifaat-devops-portfolio

## Evidencias

- [x] Repositorio publico com estrutura completa
- [x] Minimo de 5 commits demonstrando workflow Git
- [x] Branch `feature/aula-01-app` criada e mantida como evidencia
- [x] Dockerfile funcional
- [x] Container rodando com API respondendo
- [x] Evidencia registrada em `aula-01/docker-logs.txt`

## Evidencia de Container Rodando

```text
NAMES            IMAGE                  STATUS          PORTS
portfolio-test   portfolio-aula01:1.0   Up 28 seconds   0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp
```

## Resposta da API

```json
{"servico":"DevOps Portfolio API","aluno":"Gabriel Carneiro da Silva","ra":"6325300","aula":"01 - Fundamentos de Git e Docker","status":"online","timestamp":"2026-08-17T23:32:32.850Z"}
```

## Health Check

```json
{"status":"healthy","uptime":18.478226574,"version":"1.0.0"}
```
