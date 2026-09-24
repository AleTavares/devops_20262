\# Entrega — Aula 02 — Docker Compose + IA como Copiloto



\*\*Aluno:\*\* Pablo Augusto Ramos Sobral  

\*\*RA:\*\* 6325076  

\*\*Disciplina:\*\* DevOps  

\*\*Aula:\*\* 02 — Docker Compose + IA como Copiloto



\## Repositório do portfólio



https://github.com/Pablao02/unifaat-devops-portfolio



\## Branch da entrega



`entregas/aula-02/6325076`



\## Conteúdo desenvolvido



Foi implementado um ambiente multi-container utilizando Docker Compose, composto por três serviços:



\- API Node.js/Express

\- PostgreSQL 15

\- Redis 7



A aplicação utiliza uma rede bridge personalizada para comunicação entre os containers, volume nomeado para persistência do PostgreSQL, variáveis de ambiente por meio de `.env` e `.env.example`, além de healthchecks e `depends\_on` com condições de saúde.



A configuração inicial do `docker-compose.yml` foi gerada com auxílio da IA Kiro e posteriormente revisada e ajustada manualmente.



\## Validação



Os testes realizados foram:



\- `docker compose up -d --build`

\- `docker compose ps`

\- `curl.exe http://localhost:3000`

\- `curl.exe http://localhost:3000/health`

\- `docker compose exec postgres psql -U technova -d technova -c "SELECT 1;"`

\- `docker compose exec redis redis-cli ping`

\- `docker network inspect aula-02\_technova-network`

\- `docker compose down`



\### Resultados



\- API: \*\*OK\*\*

\- Endpoint `/health`: \*\*healthy\*\*

\- PostgreSQL: \*\*SELECT 1 executado com sucesso\*\*

\- Redis: \*\*PONG\*\*

\- Rede personalizada bridge: \*\*OK\*\*

\- API, PostgreSQL e Redis conectados à mesma rede: \*\*OK\*\*

\- Containers encerrados com `docker compose down`: \*\*OK\*\*



\## Arquivos desenvolvidos no portfólio



A implementação completa está na pasta `aula-02/` do repositório de portfólio, contendo:



\- `app.js`

\- `package.json`

\- `Dockerfile`

\- `.dockerignore`

\- `docker-compose.yml`

\- `.env.example`

\- `.gitignore`

\- `ia-analise.md`



O arquivo `.env` foi utilizado localmente e não foi versionado.



\## Evidências



A configuração foi validada localmente com Docker Compose e todos os testes previstos foram executados com sucesso.

