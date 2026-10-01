# Relatório do Processo — Prova do Primeiro Bimestre (DevOps)

**Aluno:** Daniel de Oliveira Tavares Junior
**RA:** 6325032
**Data:** 27/09/2026
**Ferramenta de IA utilizada:** ChatGPT (OpenAI) CLAUDE.ai

## Questão 1 — A Jornada Completa (Aulas 01 a 07)

A construção da solução foi feita em etapas, começando pela aplicação e pelo controle de versão e depois avançando para a containerização e para a infraestrutura em nuvem.

Na parte de Git, organizei a entrega dentro do repositório da disciplina, criei a branch `feature/prova-primeiro-bimestre` e utilizei commits para registrar a evolução da solução. Também utilizei `.gitignore` para evitar o versionamento de arquivos sensíveis e arquivos gerados localmente.

Na aplicação, desenvolvi uma API REST utilizando Node.js e Express. A API possui as operações de criação, consulta, atualização e exclusão de reservas, além da rota `/health`. O armazenamento das reservas é feito no PostgreSQL, e não em memória. A tabela `reservas` é criada pela aplicação quando necessário.

Na etapa de Docker, criei um Dockerfile para a API utilizando Node.js e também um `docker-compose.yml` para executar a API junto com um PostgreSQL. O Compose utiliza uma rede própria entre os containers, volume persistente para o banco e healthcheck para garantir que a API dependa de um banco disponível.

Depois de validar a aplicação localmente, passei para a infraestrutura AWS. A infraestrutura foi dividida em módulos Terraform para VPC, Security Groups, EC2 e RDS. A VPC possui duas sub-redes públicas e duas privadas distribuídas em duas zonas de disponibilidade. A EC2 fica em uma sub-rede pública e executa a API, enquanto o RDS PostgreSQL fica em sub-redes privadas.

No controle de acesso, utilizei o `LabInstanceProfile` disponibilizado pelo AWS Academy Learner Lab, sem criar um novo usuário ou role IAM. O Security Group da EC2 permite o acesso necessário à aplicação e o Security Group do RDS permite PostgreSQL apenas a partir do Security Group da EC2.

Na etapa do banco gerenciado, utilizei o Amazon RDS PostgreSQL em sub-redes privadas. O banco foi configurado com acesso público desabilitado e armazenamento criptografado.

Também configurei Remote State utilizando S3 e DynamoDB. Durante essa etapa encontrei uma restrição do ambiente do Learner Lab relacionada à configuração do bucket S3. A configuração foi ajustada utilizando as operações permitidas pelo ambiente, mantendo versionamento, criptografia e bloqueio de acesso público no bucket.

Por fim, validei a infraestrutura com `terraform validate` e `terraform plan`, subi a aplicação na EC2 e realizei testes reais contra o RDS. Depois de concluir as evidências, executei `terraform destroy`, que removeu os 19 recursos gerenciados pela infraestrutura principal.

## Questão 2 — O Processo com IA como Copiloto

Utilizei o ChatGPT como copiloto durante o desenvolvimento e a resolução dos problemas. Meu uso principal foi explicar o requisito da prova, apresentar os erros encontrados nos terminais e pedir ajuda para identificar a causa e montar os comandos ou alterações necessários.

Entre os prompts utilizados estavam solicitações para estruturar a API de reservas com Express e PostgreSQL, criar o Dockerfile, configurar o Docker Compose com PostgreSQL e healthcheck, modularizar o Terraform em VPC, Security Group, EC2 e RDS e configurar o Remote State com S3 e DynamoDB.

Também utilizei a IA durante os testes, enviando as mensagens de erro do Terraform, Docker, PostgreSQL e AWS para analisar o problema. Depois das sugestões, eu executava os comandos e conferia o resultado antes de considerar a etapa concluída.

Um problema que precisei corrigir durante a execução foi a conexão da aplicação da EC2 com o RDS. Inicialmente a aplicação não conseguia estabelecer a conexão corretamente porque o RDS exigia conexão criptografada. A configuração da aplicação foi ajustada para utilizar SSL por meio da variável `PGSSL=true`.

Outro problema aconteceu no `user_data` da EC2. A aplicação não estava no caminho que havia sido considerado inicialmente pelo script. A estrutura real do repositório colocava a API dentro da pasta da entrega, então corrigi o caminho utilizado pelo `git clone` e pelo `docker build`.

Também precisei conferir manualmente configurações do Terraform relacionadas à região, ao `LabInstanceProfile`, aos Security Groups, ao RDS privado e ao Remote State. A IA ajudou na interpretação dos erros, mas os resultados dos comandos executados foram utilizados para confirmar se as alterações realmente funcionavam.

Essa experiência mostrou que a IA foi útil principalmente como ferramenta de diagnóstico e apoio à implementação, mas não substituiu a validação manual. As configurações precisaram ser testadas no ambiente real do AWS Learner Lab.

## prompt usado na claude

Análise e Desenvolvimento de Sistemas (ADS) — Centro Universitário UniFAAT Disciplina: DevOps Professor: Alexandre Tavares Instituição: Centro Universitário UniFAAT Semestre: 2026-2 Carga Horária: 80 horas A Narrativa: O Resgate da TechNova Você faz parte da nova equipe de Platform Engineer

pasted

claude quero que vc atue como um profissão na area de DEVOPS... estou com um problema para resolver e quero que vc me ajude sendo atenta em todos os dethalhes possiveis... vou te passar o problema e quero que vc me ajude a solucionar muito bem feito

Memória atualizada
Beleza, Tavares. Já dei uma olhada na ementa da disciplina — estrutura clara, com IaC, CI/CD, deploy Blue/Green/Canary e avaliação assistida por IA nos PRs. Estou pronto para entrar no modo DevOps com você.

Pode mandar o problema específico agora — de preferência me diga:

Qual aula/módulo é (ex.: aula-03, TF, laboratório parte 1/2, trabalho em aula)?
O enunciado completo (o TF.md ou laboratorio-partX.md correspondente), se tiver.
O que já está pronto no seu repositório e onde está travado.
Assim que eu tiver isso, reviso com o mesmo rigor que fiz na prova de Big Data: o que está certo, o que falta, riscos técnicos e o que precisa ajustar antes da entrega.


Prova do Primeiro Bimestre — DevOps (Aulas 01 a 07) Análise e Desenvolvimento de Sistemas 2026.2 Professor: Alexandre da Costa Tavares Jr. Disciplina: DevOps Abrangência: Aulas 01 a 07 (Git, Docker, Docker Compose, Terraform, IAM, VPC, EC2, RDS, Remote State, Modules, IA como copiloto) Forma

pasted

na verdade esquece essa pasta que eu te mandei, use de base essa

Updated memory
Okay, ignoring the previous syllabus — now the focus is on the First Semester Exam : Complete Reservation API, from Git to modularized Terraform with remote state in the Learner Lab. It's a large project (app + Docker + Compose + 4 Terraform modules + report), so before I start building everything, I need to know where you're starting from.

Q: Where are you starting from now? 
A: Nothing set up — starting from scratch.

Q: How long until the day of the exam? 
A: About 1 week

Created 35 files, executed 11 commands, and used 3 additional tools.
I've included the entire repository inside the zip file above — and not just the files: it already comes with real Git history (8 commits, Conventional Commits, feature branch feature/docker-composemerged with --no-ffthe original main), so you can extract it, run ` git pull`, git remote add origin <seu-repo-vazio>and `git push` git push, and Part 1 (Git) will be ready to go.

What's inside

app/— Express API with full CRUD functionality /reservas, /healthsaving to PostgreSQL ( pg), with connection retry on startup.
Dockerfilemulti-stage, non-root user, built-in healthcheck.
docker-compose.yml— API + Postgres, named volume, own bridge network, depends_on: condition: service_healthy.
infra/modules/— the 4 requested modules: vpc(2 AZs, public/private, intentionally without NAT Gatewaysecurity-group — RDS doesn't need internet access, which avoids extra cost/time in the Lab), (RDS rule only accepts EC2 SG, never an open CIDR), ec2(uses LabInstanceProfile, user_datainstalls Docker, clones your repo and starts the container pointing to RDS) and rds(private, encrypted, no public exposure).
infra/backend/— a separate bootstrap (versioned + encrypted S3, DynamoDB) that you apply before configuring the backend "s3"main project's bootstrap.
relatorio.md— outline , not a ready-made answer: it has the right technical structure for the 4 questions, but it is clearly marked for you to rewrite it in the first person with your real experience (prompts you actually used, what you corrected) — this is precisely what Question 4 assesses, and submitting it generically as it is would go against the very purpose of the exam.
evidencias/README.md— Checklist of what to photograph/paste before the PR.
What do you still need to do before the day of the exam?

Create an prova-primeiro-bimestre-devopsempty repository on GitHub, extract the zip file, and push it (this preserves the commits).
Run docker compose up --buildlocally and test the routes — generate evidence of docker-build.txtand compose-ps.txt.
In the Learner Lab: create an EC2 Key Pair, apply it infra/backend/first, paste the bucket/table names into infra/providers.tf, fill in terraform.tfvars(RA already embedded in the default names) and then terraform applythe infra/principal.
Rewrite it relatorio.mdbased on your real experience.
terraform destroy(of the two: the main one and then the backend) before closing the session.
On the day of the exam: open the single PR file, with entrega.md, in the folder entregas/provaPrimeiroBi/6325032/.
None of this has been tested against a real AWS server (I don't have access to it here) — I only validated the Node syntax and manually reviewed the HCL. When you run the terraform applyreal thing, let me know of any errors you encounter.


First semester DevOps exam
                                       *claude ai *
ZIP 

##  chat gpt 

https://chatgpt.com/share/6ab95dfc-7b3c-83e9-a720-dd1e28f13574


## Questão 3 — Infraestrutura, Segurança e Learner Lab

A arquitetura utiliza uma VPC com duas zonas de disponibilidade, duas sub-redes públicas e duas sub-redes privadas.

A EC2 fica em uma sub-rede pública porque a API precisa receber requisições externas. A instância utiliza o `LabInstanceProfile` disponibilizado pelo AWS Academy Learner Lab.

O RDS PostgreSQL fica nas sub-redes privadas e foi configurado com `publicly_accessible = false`. Dessa forma, o banco não fica diretamente exposto à internet.

O acesso ao PostgreSQL também foi restringido pelo Security Group. A porta 5432 do RDS não foi liberada para `0.0.0.0/0`; a regra permite acesso a partir do Security Group da EC2. Assim, a aplicação é responsável por acessar o banco.

O ambiente AWS Academy possui restrições de permissões IAM. Por esse motivo, não criei usuários, roles ou instance profiles personalizados. A EC2 utiliza o `LabInstanceProfile` existente no ambiente.

O Terraform utiliza estado remoto em S3, com DynamoDB utilizado para controle de lock do state. O bucket foi configurado com versionamento, criptografia do lado do servidor e bloqueio de acesso público.

Durante a execução também foi necessário considerar as credenciais temporárias do AWS Academy. O ambiente utiliza credenciais de curta duração, portanto problemas de autenticação podem ocorrer quando a sessão do laboratório expira.

A arquitetura final utilizada durante os testes foi:

```text
Internet
   |
   v
VPC
 |
 +-- Sub-rede pública
 |      |
 |      +-- EC2 / API
 |
 +-- Sub-redes privadas
        |
        +-- RDS PostgreSQL
```

O fluxo da aplicação foi:

```text
Cliente
   |
   v
EC2 / API Node.js
   |
   | PostgreSQL / 5432
   v
RDS PostgreSQL privado
```

## Questão 4 — Validação e Responsabilidade

Antes de considerar a infraestrutura pronta, realizei validações em diferentes níveis.

Primeiro, validei a aplicação localmente utilizando Docker Compose. Testei a rota `/health`, criação de reservas, listagem, consulta por ID, atualização e exclusão. Também consultei diretamente o PostgreSQL para verificar se as alterações realizadas pela API realmente estavam persistidas no banco.

Depois, realizei os mesmos testes na infraestrutura AWS. A rota `/health` confirmou que a API na EC2 conseguia se comunicar com o RDS. Em seguida, criei uma reserva, consultei a lista, consultei a reserva pelo ID, alterei seu status e confirmei a alteração diretamente no PostgreSQL. Depois excluí a reserva e confirmei no banco que o registro havia sido removido. Por fim, consultei novamente a reserva e a API retornou HTTP 404.

Antes do provisionamento também utilizei `terraform validate` para verificar a configuração Terraform e `terraform plan` para revisar os recursos que seriam criados. Conferi especialmente que não havia recursos IAM personalizados, que o RDS estava privado, que a porta 5432 não estava aberta para a internet e que a região utilizada era `us-east-1`.

Um exemplo concreto de correção durante o processo foi o problema de conexão entre a API e o RDS. Após a primeira execução na EC2, os logs indicaram que a conexão precisava utilizar SSL. A configuração do banco foi então ajustada e a aplicação passou a utilizar `PGSSL=true`. Depois dessa alteração, a aplicação conseguiu estabelecer a conexão com o RDS e o CRUD pôde ser testado diretamente na AWS.

Outro ajuste importante ocorreu no `user_data` da EC2, porque o caminho da aplicação dentro do repositório estava incorreto. O script foi corrigido para acessar a pasta correta antes de construir e executar o container.

Esses problemas mostraram a importância de não aceitar automaticamente uma configuração gerada por IA. O código precisava ser executado no ambiente real, os logs precisavam ser analisados e as configurações precisavam ser comparadas com a estrutura real do projeto e com as restrições do AWS Learner Lab.

Depois que todas as funcionalidades foram testadas e as evidências foram registradas, executei `terraform destroy`. O Terraform confirmou:

```text
Destroy complete! Resources: 19 destroyed.
```

Após a destruição, o `terraform state pull` confirmou que o state remoto da infraestrutura principal não possuía mais recursos:

```json
"outputs": {},
"resources": []
```

Dessa forma, a infraestrutura principal utilizada na prova foi efetivamente encerrada após a coleta das evidências.
