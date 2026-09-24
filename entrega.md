\# Entrega — Aula 01: Fundamentos de Git e Docker



\*\*Aluno:\*\* Pablo Augusto Ramos Sobral  

\*\*RA:\*\* 6325076  

\*\*Data:\*\* 18/09/2026



\## Repositório



\- URL: https://github.com/Pablao02/unifaat-devops-portfolio



\## Evidências



\- \[x] Repositório público com estrutura completa

\- \[x] Mínimo de 5 commits demonstrando workflow Git

\- \[x] Dockerfile funcional

\- \[x] Container rodando



\## Evidência de Container Rodando



```text

CONTAINER ID   IMAGE                  STATUS         PORTS                                         NAMES

8ec0dbd4d956   portfolio-aula01:1.0   Up             0.0.0.0:3000->3000/tcp, \[::]:3000->3000/tcp   portfolio-test



\### Teste da API



```text

GET http://localhost:3000



{"servico":"DevOps Portfolio API","aluno":"Pablo Augusto Ramos Sobral","ra":"6325076","aula":"01 - Fundamentos de Git e Docker","status":"online"}



GET http://localhost:3000/health



{"status":"healthy","version":"1.0.0"}



