Entrega — Aula 11 (TF)
Aluno: Caio Akiyama RA: 6325124 Data: 14/11/2026

Link para commit
Fork: https://github.com/KeiouShim/implement_Moodle.git
Commit: https://github.com/KeiouShim/implement_Moodle/commit/f31677c01b56f9bfdbac62b95903acc177c97800
O que foi feito nesta aula
Fiz o fork do repositório implement_Moodle e o clonei localmente no Windows. Dentro da pasta docker/, executei docker compose up -d. O Docker baixou a imagem postgres:15, construiu a imagem do Moodle (cerca de 100 segundos) e criou a rede e os volumes (db_data, moodle_data e moodle_www). Os containers subiram: mostrando do banco saudável e o do Moodle que ficou iniciado. Também explorei a estrutura do repositório (CHALLENGE.md, docs/, testes/ e fluxos de trabalho): [resuma em 1 ou 2 linhas o que a prova pede]. Registrei o progresso em um commit no fork com um arquivo .md inicial. Próximo passo: [por exemplo, começar a infra com lab na AWS ou os arquivos pedidos no CHALLENGE.md].

Dificuldades
Ao tentar enviar minhas alterações com git push origin, o Git rejeitou o envio devido a conflitos de histórico e configuração entre o repositório original e o meu fork. Para resolver o problema de forma segura e sem corromper os commits, fiz um novo clone diretamente do meu repositório forkado, reapliquei as alterações e as configurações de ambiente, e executei o push novamente sem erros.