# Entrega — Aula 01: Fundamentos de Git e Docker

**Aluno:** Marcos Eduardo dos Santos Sousa  
**RA:** 6325127  
**Data:** 2026-08-27

## Repositório

- URL: https://github.com/MarcosSantt/unifaat-devops-portfolio

## Evidências

- [x] Repositório público com estrutura completa
- [x] Mínimo de 5 commits demonstrando workflow Git
- [x] Dockerfile funcional
- [x] Container rodando (evidência abaixo)

## Evidência de Container Rodando

**`docker ps`:**

```text
CONTAINER ID   IMAGE                  COMMAND                  CREATED         STATUS         PORTS                                       NAMES
b09a1877f451   portfolio-aula01:1.0   "docker-entrypoint.s…"   9 minutes ago   Up 9 minutes   0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp   portfolio-test
```

**`curl http://localhost:3000`:**

```json
{"servico":"DevOps Portfolio API","aluno":"MARCOS EDUARDO DOS SANTOS SOUSA","ra":"6325127","aula":"01 - Fundamentos de Git e Docker","status":"online","timestamp":"2026-08-27T23:10:23.832Z"}
```

**`curl http://localhost:3000/health`:**

```json
{"status":"healthy","uptime":187.456147934,"version":"1.0.0"}
```
