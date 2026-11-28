# Entrega — Aula 11 (TF)

**Aluno:** Matheus Borali
**RA:** 6325135
**Data:** 15/11/2026

## Link do commit

- Fork: https://github.com/Matheus04810/implement_Moodle
- Commit: https://github.com/Matheus04810/implement_Moodle/commit/5bac9a2

## O que foi feito nesta aula

Fiz o fork do repositório implement_Moodle e o clonei localmente no Windows. Dentro da pasta `docker/`, executei `docker compose up -d`. O Docker baixou a imagem postgres:15, construiu a imagem do Moodle (cerca de 100 segundos) e criou a rede e os volumes (db_data, moodle_data e moodle_www). Os containers subiram: o do banco ficou Healthy e o do Moodle ficou Started.  Também explorei a estrutura do repositório (CHALLENGE.md, docs/, tests/ e workflows): [resuma em 1 ou 2 linhas o que a prova pede]. Registrei o progresso em um commit no fork com um arquivo de notas. Ainda não está pronto: Próximo passo: [por exemplo, começar a infraestrutura na AWS ou os arquivos pedidos no CHALLENGE.md].

## Dificuldades encontradas

Ao começar, usei o comando `ls` no Prompt de Comando do Windows e recebi erro, porque no CMD o equivalente é `dir`. Também tentei fazer um commit sem ter alterado nenhum arquivo e o Git informou "nothing to commit". Resolvi criando um arquivo de notas e repetindo o commit. 
