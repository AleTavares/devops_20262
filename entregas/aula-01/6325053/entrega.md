\# Entrega — Aula 01: Fundamentos de Git e Docker



\*\*Aluno:\*\* Matheus Gabriel Correa Braga Viana

\*\*RA:\*\* 6325053

\*\*Data:\*\* 18/09/2026



\## Repositório



\- URL: https://github.com/Matiasdocs/unifaat-devops-portfolio



\## Evidências



\- \[x] Repositório público com estrutura completa

\- \[x] Mínimo de 5 commits demonstrando workflow Git

\- \[x] Dockerfile funcional

\- \[x] Container rodando (evidência abaixo)



\## Evidência de Container Rodando



```text

Portfolio API rodando na porta 3000

\---

Container running:

CONTAINER ID   IMAGE                  COMMAND                  CREATED        STATUS         PORTS                                         NAMES

c8664eac39d3   portfolio-aula01:1.0   "docker-entrypoint.s..."   About a minute ago   Up 31 seconds   0.0.0.0:3000->3000/tcp, \[::]:3000->3000/tcp   portfolio-test

\---

API Response:

{"servico":"DevOps Portfolio API","aluno":"Matheus Gabriel Correa Braga Viana","ra":"6325053","aula":"01 - Fundamentos de Git e Docker","status":"online","timestamp":"2026-09-18T20:01:24.608Z"}

```



Log completo também disponível em `aula-01/docker-logs.txt` no repositório do portfólio.

