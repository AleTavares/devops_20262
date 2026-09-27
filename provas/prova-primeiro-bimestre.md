# Prova do Primeiro Bimestre — DevOps (Aulas 01 a 07)

**Análise e Desenvolvimento de Sistemas**  
**2026.2**

* **Professor:** Alexandre da Costa Tavares Jr
* **Disciplina:** DevOps
* **Abrangência:** Aulas 01 a 07 (Git, Docker, Docker Compose, Terraform, IAM, VPC, EC2, RDS, Remote State, Modules, IA como copiloto)
* **Formato:** Projeto prático (repositório próprio) + Relatório dissertativo
* **Entrega:** Enviada 1 semana antes e apresentada/entregue no dia da prova

## Como Funciona Esta Prova

Esta prova é **entregue no dia da prova**, mas o enunciado é liberado **1 semana antes** para que você tenha tempo de construir a solução com calma. Você vai:

1. Criar um **repositório próprio** no GitHub chamado `prova-primeiro-bimestre-devops`
2. Resolver o problema proposto na narrativa abaixo, construindo a solução com tudo que aprendeu nas Aulas 01 a 07
3. Escrever um **relatório** documentando como usou IA (Kiro ou outra LLM) no processo
4. Registrar a entrega via **Pull Request** no repositório da disciplina, na pasta `entregas/provaPrimeiroBi/SEU-RA/`

> **⚙️ Ambiente AWS:** 
>
> - Toda a parte de nuvem usa o **AWS Academy Learner Lab**. 
>
> - Credenciais são temporárias (com **Session Token**, via **AWS Details → AWS CLI**)
> 
> - Região sempre **us-east-1**
>
>  O Lab **não permite criar IAM users/groups/roles**, use a role pré-existente **`LabRole`** e o instance profile **`LabInstanceProfile`** quando precisar de permissões de serviço. 
> 
> **Sempre execute `terraform destroy`** ao final para não esgotar os créditos.

## Narrativa — O Desafio Final da TechNova

> **O Resgate da TechNova — Episódio Final do Bimestre: "Do Zero à Nuvem, Sozinho"**

A TechNova fechou um contrato com um novo cliente e precisa entregar um **ambiente completo e reproduzível** de uma nova API — a **API de Reservas**. O CTO Carlos Mendes reuniu a equipe:

> "Vocês passaram o bimestre aprendendo cada peça: versionamento, containers, orquestração, infraestrutura como código, rede, banco de dados, state remoto e módulos. Agora quero ver **tudo junto**, feito por vocês, do zero. Cada um vai montar o ambiente da API de Reservas sozinho, é assim que eu sei que vocês realmente aprenderam."

A consultora Marina complementou:

> "E não quero código jogado. Quero **histórico Git limpo**, a aplicação **containerizada**, o ambiente local subindo com **um comando**, e a infraestrutura na AWS **modularizada** com **state remoto**. Podem usar IA como copiloto, na verdade, quero que usem, mas cada decisão precisa ser entendida e validada por vocês. No final, me entreguem um **relatório** contando como foi."

Esse é o seu desafio: entregar a **API de Reservas** da TechNova, do commit inicial até a infraestrutura na nuvem, aplicando os 7 episódios do bimestre.

## O Que Construir

A **API de Reservas** é uma aplicação Node.js/Express que gerencia reservas (campos: `id`, `cliente`, `data`, `status`). Você vai entregar a jornada completa dela.

### Rotas obrigatórias (CRUD completo)

A API **deve** implementar o CRUD completo do recurso `reservas`, persistindo os dados no banco PostgreSQL:

| Método | Rota | Ação (CRUD) | Descrição |
|--------|------|-------------|-----------|
| `POST` | `/reservas` | **Create** | Cria uma nova reserva (valida os campos obrigatórios) |
| `GET` | `/reservas` | **Read** | Lista todas as reservas |
| `GET` | `/reservas/:id` | **Read** | Busca uma reserva pelo `id` (404 se não existir) |
| `PUT` | `/reservas/:id` | **Update** | Atualiza uma reserva existente |
| `DELETE` | `/reservas/:id` | **Delete** | Remove uma reserva |
| `GET` | `/health` | — | Health check (usado pelo healthcheck do Compose) |

> **Importante:** as rotas de CRUD devem **ler e gravar no banco de dados PostgreSQL** (não em memória) — tanto no ambiente local (Docker Compose) quanto na nuvem (RDS).

### Parte 1 — Git e Versionamento (Aula 01)

- Repositório `prova-primeiro-bimestre-devops` público no GitHub
- Histórico com **no mínimo 6 commits** usando Conventional Commits (`feat:`, `docs:`, `fix:`, `chore:`)
- Uso de **feature branch** + merge (evidência de workflow Git)
- `README.md` na raiz com seu nome, RA e descrição do projeto
- `.gitignore` adequado (node_modules, .env, .terraform, *.tfstate, *.pem)

### Parte 2 — Docker (Aula 01)

- `Dockerfile` funcional da API de Reservas (multi-stage recomendado, usuário não-root)
- `.dockerignore` configurado
- Evidência de build e execução do container

### Parte 3 — Docker Compose (Aula 02)

- `docker-compose.yml` que sobe a **API + PostgreSQL**
- Volume nomeado para persistência do banco
- Rede bridge customizada, healthcheck no banco, `depends_on` com condição
- `.env.example` versionado (sem senhas reais) e `.env` no `.gitignore`

### Parte 4 — Infraestrutura AWS com Terraform, Módulos e Remote State (Aulas 03 a 06)

Provisione, com Terraform **modularizado**, no **AWS Academy Learner Lab**:

- **VPC** com subnets públicas e privadas em 2 AZs (módulo `vpc`)
- **Security Groups** com menor privilégio (módulo `security-group`): EC2 (22, 3000) e RDS (5432 apenas do SG do EC2)
- **EC2** t2.micro na subnet pública com a API (módulo `ec2`) — use o instance profile **`LabInstanceProfile`** se precisar de acesso a serviços
- **RDS** PostgreSQL db.t3.micro **provisionado e funcional** nas subnets privadas (módulo `rds`) — este é o **banco de dados da API na nuvem**, onde as rotas de CRUD gravam os dados. Deve ter `publicly_accessible = false`, `storage_encrypted = true`, `db_subnet_group_name` com as subnets privadas e ser acessível **apenas** a partir do Security Group da EC2 (porta 5432)
- **Remote State**: backend S3 (com versionamento e encriptação) + DynamoDB para locking
- Composição entre módulos (output de um alimenta input de outro)
- Tags em todos os recursos e outputs úteis (IP da EC2, endpoint do RDS, URL da API)

> **Importante (Learner Lab):** 
>
> NÃO crie IAM users/groups/roles — use `LabRole` / `LabInstanceProfile`. Região `us-east-1`. Rode `terraform destroy` após capturar evidências.

### Parte 5 — IA como Copiloto (Aulas 02 e 07)

- Use **Kiro (Spec-Driven)** ou outra LLM de sua escolha para gerar parte da solução (Dockerfile, docker-compose, módulos Terraform)
- Documente o processo no relatório (Parte 6)

### Parte 6 — Relatório (relatorio.md)

Um relatório dissertativo respondendo às 4 questões da seção "Relatório do Processo" (abaixo).

---

## Estrutura do Repositório do Aluno

No **seu** repositório `prova-primeiro-bimestre-devops`:

```
prova-primeiro-bimestre-devops/
├── README.md                     # Nome, RA, descrição do projeto
├── .gitignore
├── app/                          # API de Reservas
│   ├── src/
│   ├── package.json
│   ├── Dockerfile
│   └── .dockerignore
├── docker-compose.yml            # API + PostgreSQL (ambiente local)
├── .env.example
├── infra/                        # Terraform modularizado
│   ├── modules/
│   │   ├── vpc/
│   │   ├── security-group/
│   │   ├── ec2/
│   │   └── rds/
│   ├── main.tf                   # Composição dos módulos
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf              # Provider AWS + backend S3
│   └── backend/                  # S3 + DynamoDB para remote state
├── evidencias/
│   ├── docker-build.txt          # ou screenshot
│   ├── compose-ps.txt            # docker compose ps
│   ├── terraform-plan.txt
│   └── (screenshots opcionais)
└── relatorio.md                  # Relatório do processo com IA
```

---

## Informações de Entrega

| Item | Detalhe |
|------|---------|
| **Liberação do enunciado** | 1 semana antes da prova |
| **Entrega** | No dia da prova, via Pull Request no repositório da disciplina |
| **Repositório do projeto** | `prova-primeiro-bimestre-devops` (repositório próprio, público) |
| **Pasta de entrega no fork** | `entregas/provaPrimeiroBi/RA/` (substitua RA pelo seu número de matrícula) |
| **Conteúdo do PR** | Apenas o arquivo `entrega.md` com link do repositório + evidências |

### Como Entregar via Pull Request

1. Construa a solução no seu repositório `prova-primeiro-bimestre-devops`
2. Faça um **fork** do repositório da disciplina (se ainda não fez)
3. Crie a pasta `entregas/provaPrimeiroBi/SEU-RA/`
4. Adicione **apenas** o arquivo `entrega.md` (modelo abaixo)
5. Faça commit e push para o seu fork
6. Abra um **Pull Request** para o repositório original

**Modelo do arquivo `entrega.md`:**

```markdown
# Entrega — Prova do Primeiro Bimestre (DevOps)

**Aluno:** [Seu nome completo]  
**RA:** [Seu RA]  
**Data:** [Data da prova]
**Ferramenta de IA utilizada:** [Kiro / ChatGPT / Claude / Copilot / outra]

## Repositório do Projeto

- URL: https://github.com/SEU-USUARIO/prova-primeiro-bimestre-devops

## Checklist de Evidências

- [ ] Repositório público com README (nome + RA) e .gitignore
- [ ] Mínimo de 6 commits com Conventional Commits + feature branch
- [ ] API com **CRUD completo** de reservas (POST, GET, GET/:id, PUT, DELETE) + /health
- [ ] Rotas de CRUD gravando no **banco PostgreSQL** (não em memória)
- [ ] Dockerfile funcional da API de Reservas
- [ ] docker-compose.yml (API + PostgreSQL) subindo com um comando
- [ ] Terraform modularizado (vpc, security-group, ec2, rds)
- [ ] **RDS PostgreSQL provisionado** nas subnets privadas (banco da API na nuvem)
- [ ] Remote State configurado (S3 + DynamoDB)
- [ ] Uso de LabRole/LabInstanceProfile (sem criar IAM próprio)
- [ ] terraform validate e terraform plan sem erros
- [ ] relatorio.md completo (4 questões)
- [ ] terraform destroy executado após evidências

## Evidências

[Cole aqui os outputs/screenshots: docker compose ps, terraform plan, etc.]
```

---

## Relatório do Processo (relatorio.md) — 4 Questões

Crie o arquivo `relatorio.md` no seu repositório. Responda de forma **dissertativa** (mínimo 10 linhas por questão), com base na sua experiência real. **Informe no início qual ferramenta de IA utilizou.**

### Questão 1 — A Jornada Completa (Aulas 01 a 07)

Descreva como você conectou as peças do bimestre para entregar a API de Reservas: do versionamento (Git) à infraestrutura na nuvem (Terraform + módulos + remote state). Explique a ordem que seguiu e por quê. Onde cada aula (01 a 07) apareceu na sua solução?

### Questão 2 — O Processo com IA como Copiloto

Qual ferramenta de IA você usou e como? Descreva os prompts principais, o que a IA gerou bem e o que precisou corrigir. Se usou Kiro Spec, descreva o fluxo requisitos → design → tarefas. Compare com fazer manualmente: onde a IA economizou tempo e onde atrapalhou?

### Questão 3 — Infraestrutura, Segurança e o Learner Lab

Explique a arquitetura AWS que você provisionou (pode incluir diagrama). Por que o RDS fica na subnet privada e a EC2 na pública? Como funcionou o uso do `LabRole`/`LabInstanceProfile` em vez de criar IAM próprio? Que ajustes o AWS Academy Learner Lab exigiu em relação ao que foi ensinado (credenciais temporárias, região, restrições de IAM)?

### Questão 4 — Validação e Responsabilidade

Que checklist você aplicou antes de rodar `terraform apply` em código gerado por IA? Como validou que a infraestrutura estava correta e segura? O que aconteceria se você aceitasse o código da IA sem revisar? Como a evolução Git → Docker → Terraform → Modules preparou você para usar IA com responsabilidade?

---

## Critérios de Avaliação

| Componente | Peso | Descrição |
|------------|------|-----------|
| Git + Docker (Aulas 01) | 15% | Histórico limpo, Conventional Commits, Dockerfile funcional |
| Docker Compose (Aula 02) | 10% | API + PostgreSQL, volume, rede, healthcheck |
| Terraform + Módulos + Remote State (Aulas 03-06) | 25% | Modularização, composição, VPC/SG/EC2/RDS, S3+DynamoDB, uso de LabRole |
| Uso de IA como copiloto (Aulas 02, 07) | 10% | Uso documentado e crítico da IA |
| Relatório — Questão 1 (jornada) | 10% | Conexão entre as aulas, coerência |
| Relatório — Questão 2 (processo com IA) | 10% | Descrição do processo, comparação com manual |
| Relatório — Questão 3 (infra e Learner Lab) | 10% | Compreensão de arquitetura e restrições do Lab |
| Relatório — Questão 4 (validação) | 10% | Pensamento crítico, checklist, responsabilidade |

**Total:** 100% (10 pontos)

---

## Regras

1. **Prova individual** — cada aluno constrói sua própria solução
2. **É permitido** usar Kiro ou qualquer outra LLM (ChatGPT, Claude, Copilot, Gemini, etc.) — informe qual no relatório
3. **É permitido** consultar documentação oficial e os materiais das aulas (TA, labs, README)
4. **Não é permitido** copiar a solução de colegas — o histórico Git e o relatório devem refletir seu trabalho real
5. **AWS Academy Learner Lab:** use `LabRole`/`LabInstanceProfile`, região `us-east-1`, credenciais temporárias; **NÃO** crie IAM users/groups/roles
6. **Execute `terraform destroy`** após capturar evidências — recursos ativos consomem créditos do Lab
7. **`.gitignore` obrigatório** — nada de `.tfstate`, `.terraform/`, `.env` com senhas, `*.pem` no repositório
8. **Apenas UM Pull Request por aluno** — a prova permite **uma única submissão**. Um segundo PR de prova do mesmo RA será desconsiderado automaticamente.
9. **Entrega imutável após o envio** — depois de abrir o PR, **não faça novos commits nele**. Alterações posteriores (novos commits no PR) são bloqueadas e desconsideradas — valem apenas os commits presentes no momento da abertura. Revise tudo antes de abrir o PR.
10. **O Pull Request deve ser aberto no dia da prova** — construa a solução na semana anterior, mas **abra o PR somente no dia da prova**, presencialmente. PRs abertos antes da data da prova serão desconsiderados. Isso evita problemas de submissão antecipada e garante que todos entreguem no mesmo momento.

---

## Dicas

- Comece pelo Git e pela aplicação; containerize; suba local com Compose; só então vá para a AWS
- Reaproveite os módulos que você construiu na Aula 06 como base
- Crie o backend (S3 + DynamoDB) **antes** de configurar o `backend "s3"` no projeto principal
- Ao pedir código de infra para a IA, **diga explicitamente** que é AWS Academy Learner Lab e que deve usar `LabRole`/`LabInstanceProfile` sem criar IAM
- Se `terraform` der `ExpiredToken`, reinicie o Lab e atualize `~/.aws/credentials`
- O relatório vale tanto quanto o código — reserve tempo para escrevê-lo com honestidade
- Teste tudo antes do dia da entrega; no dia, foque em finalizar o `entrega.md` e abrir o PR

---

*Boa prova! Mostre que você percorreu toda a jornada da TechNova — do caos do código à infraestrutura modular e segura na nuvem — e que sabe usar IA como copiloto com responsabilidade.*
