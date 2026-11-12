# Prova do Segundo Bimestre — Parte Prática

**Análise e Desenvolvimento de Sistemas**

- **Semestre:** 2026.2
- **Professor:** Alexandre da Costa Tavares Jr
- **Disciplina:** DevOps
- **Valor desta parte:** 50% da nota da prova (5,0 pontos)
- **Entrega:** Pull Request no repositório da disciplina até a data indicada no calendário

---

## Desafio: Moodle Docker AWS Challenge

Repositório template: [github.com/AleTavares/implement_Moodle](https://github.com/AleTavares/implement_Moodle)

### Contexto

Você foi contratado como engenheiro DevOps júnior de uma instituição de ensino que precisa disponibilizar o Moodle — plataforma de e-learning de código aberto — tanto para testes locais quanto para uso em produção na AWS. Sua tarefa é completar a infraestrutura que outro engenheiro deixou inacabada: o ambiente Docker local já vem funcional no template; o que falta é a infraestrutura AWS e a automação para tornar o deploy reproduzível.

Ao concluir este desafio, você terá aplicado na prática os principais conceitos vistos no segundo bimestre: containerização, infraestrutura como código com Terraform, pipelines de CI/CD com GitHub Actions e deploy seguro na AWS Academy Learner Lab.

---

## Entregáveis

Você deve entregar os itens abaixo:

| # | Entregável | Peso |
|:-:|-----------|:----:|
| 1 | Ambiente Docker local validado | 15% |
| 2 | Infraestrutura Terraform completa | 30% |
| 3 | Documento de arquitetura preenchido | 15% |
| 4 | Workflows de CI/CD funcionando | 15% |
| 5 | Uso do Kiro e Kiro Workflows | 15% |
| 6 | Organização, documentação e boas práticas | 10% |

**Total: 100% desta parte (equivale a 5,0 pontos na nota final da prova).**

---

## Como Realizar o Desafio

### 1. Preparação

1. Crie um **fork** do repositório [github.com/AleTavares/implement_Moodle](https://github.com/AleTavares/implement_Moodle) para a sua conta pessoal no GitHub.
2. Clone o fork localmente e leia o `README.md`, o `CHALLENGE.md` e os arquivos em `docs/` antes de começar.
3. Certifique-se de que possui os pré-requisitos instalados: Docker Engine 24+, Terraform 1.5+, AWS CLI 2.x, Git e Python 3.8+.
4. Abra uma sessão no AWS Academy Learner Lab, obtenha as credenciais temporárias e configure o AWS CLI conforme descrito em `docs/aws-learn-lab-setup.md`.

### 2. Entregável 1 — Ambiente Docker Local (15%)

O template já entrega o ambiente local funcional. Sua tarefa é:

- Executar `docker compose up -d` dentro do diretório `docker/` e confirmar que o Moodle está acessível em `http://localhost:8080`.
- Copiar o `.env.example` para `.env` e ajustar as variáveis necessárias sem expor senhas no repositório.
- Capturar evidência (screenshot) do Moodle rodando localmente com o status dos containers.

> **Atenção:** não commite o arquivo `.env` real. Verifique que ele está listado no `.gitignore`.

### 3. Entregável 2 — Infraestrutura Terraform (30%)

Esta é a parte central do desafio. Você deve criar os três módulos Terraform do zero dentro do seu repositório fork:

#### Módulo `networking`

- VPC com bloco CIDR documentado.
- Pelo menos 2 subnets públicas em Availability Zones diferentes (necessário para o DB Subnet Group).
- Pelo menos 2 subnets privadas em Availability Zones diferentes.
- Internet Gateway e Route Table associando as subnets públicas à saída para internet.
- Security Groups:
  - `sg-app`: permite entrada HTTP (80) e SSH (22 restrito ao seu IP) na EC2; permite saída irrestrita.
  - `sg-db`: permite entrada na porta 5432 **somente a partir do `sg-app`**; bloqueia toda origem externa.

#### Módulo `compute`

- Instância EC2 (`t3.micro`, AMI Amazon Linux 2023 ou Ubuntu 22.04) na subnet pública.
- `iam_instance_profile = "LabInstanceProfile"` (não crie roles IAM — o Learner Lab não permite).
- Script `user_data.sh` referenciado no módulo que:
  - Instala o Docker Engine e o Docker Compose v2.
  - Clona (ou copia via `templatefile`) o `docker-compose.yml` e o `.env` com as variáveis do banco.
  - Executa `docker compose up -d` para subir o Moodle no boot.
- Outputs: `public_ip`, `public_dns`.

#### Módulo `database`

- RDS PostgreSQL 15 (`db.t3.micro`) nas subnets privadas.
- `publicly_accessible = false`.
- DB Subnet Group com as subnets privadas de pelo menos 2 AZs.
- Parâmetros de conexão (host, porta, nome, usuário, senha) expostos como outputs para serem consumidos pelo módulo `compute`.
- Credenciais passadas via variáveis do Terraform; não devem aparecer em texto simples no código ou ser commitadas.

#### Validações obrigatórias

```bash
terraform fmt -check -recursive    # formatação consistente
terraform validate                 # sem erros de sintaxe
terraform plan                     # plan deve executar sem erros
```

Capture screenshots de cada validação como evidência.

> **Restrições do Learner Lab:** use sempre `us-east-1`. Não crie IAM users, groups ou roles. Use `LabRole` / `LabInstanceProfile` onde necessário. Confirme os serviços disponíveis na sua conta antes de prosseguir.

### 4. Entregável 3 — Documento de Arquitetura (15%) ⚠️ Obrigatório Eliminatório

Preencha o template `docs/architecture-design-template.md` gerando o arquivo `docs/architecture-design.md`. O documento deve conter:

- **Diagrama** da arquitetura (ASCII ou imagem) mostrando VPC, subnets públicas/privadas, EC2, RDS, Security Groups e o fluxo de dados do usuário até o banco.
- **Descrição dos componentes**: para cada recurso criado, explique sua função e por que foi configurado da forma que está.
- **Justificativas de segurança**: por que o RDS está em subnet privada, como as regras de Security Group limitam o acesso e como as credenciais são protegidas.
- **Estimativa de custo**: use a AWS Pricing Calculator ou os valores conhecidos do Learner Lab para estimar o custo mensal dos recursos criados (EC2 + RDS + VPC).

> **Atenção:** a ausência do arquivo `docs/architecture-design.md` no repositório desqualifica o desafio inteiro, independentemente da pontuação nas demais categorias.

### 5. Entregável 4 — Workflows de CI/CD (15%)

O template já entrega três workflows prontos. Você deve implementar o workflow que está como stub:

#### `terraform-plan.yml` (obrigatório)

Implemente o workflow para que, a cada Pull Request aberto no repositório, ele execute:

1. Checkout do código.
2. Configuração das credenciais AWS com `aws-actions/configure-aws-credentials@v4`, usando os secrets `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` e `AWS_SESSION_TOKEN`.
3. Setup do Terraform com `hashicorp/setup-terraform`.
4. `terraform init` apontando para o diretório raiz do Terraform.
5. `terraform validate`.
6. `terraform plan` com `-no-color` e saída publicada como comentário na PR (use `actions/github-script` ou o step de comentário do `hashicorp/setup-terraform`).

Garanta que o workflow falhe (exit code ≠ 0) se o `terraform plan` retornar erros.

Capture screenshot do workflow executando com sucesso na aba **Actions** do GitHub.

### 6. Entregável 5 — Uso do Kiro e Kiro Workflows (15%)

O Kiro foi apresentado no curso como copiloto DevOps. Neste entregável você deve demonstrar que o utilizou de forma produtiva no desenvolvimento do desafio.

#### Kiro Spec (obrigatório)

Crie uma **Spec do Kiro** para um dos módulos Terraform do desafio — de preferência o mais complexo que você implementou (`networking`, `compute` ou `database`). A Spec deve ter as três seções geradas pelo fluxo padrão do Kiro:

- **Requirements** — o que o módulo precisa fazer (recursos a criar, restrições do Learner Lab, outputs esperados).
- **Design** — decisões de arquitetura (blocos CIDR, tipos de instância, como as credenciais são passadas, etc.).
- **Tasks** — lista das tarefas de implementação, com pelo menos uma marcada como concluída.

Salve a Spec no fork em `.kiro/specs/<nome-do-modulo>/` e inclua o link no `entrega.md`.

#### Kiro Workflow (obrigatório)

Execute pelo menos **um Kiro Workflow** durante o desenvolvimento — por exemplo, o workflow `feature-pipeline` para gerar ou revisar um dos módulos Terraform, ou o workflow `investigate` para diagnosticar um problema encontrado. 

Evidencie o uso com **screenshot da interface do Kiro** mostrando o workflow em execução ou concluído, e inclua no `entrega.md` uma descrição de duas a cinco linhas sobre o que o workflow fez e como ele contribuiu para o resultado.

#### O que entregar

No `entrega.md`, na seção **Entregável 5 — Kiro**, inclua:

- Link para a pasta `.kiro/specs/` no fork com a Spec criada.
- Screenshot do Kiro Workflow em execução ou concluído.
- Descrição do que o workflow executou e qual problema ajudou a resolver.

> O uso de IA é transparente: relate o que foi gerado pelo Kiro, o que você ajustou manualmente e por quê. Não é necessário que o Kiro tenha feito tudo — o que vale é a evidência de uso real e consciente.

---

### 7. Entregável 6 — Organização e Boas Práticas (10%)

- `.gitignore` cobrindo: `.env`, `.terraform/`, `*.tfstate`, `*.tfstate.backup`, `*.tfvars` com segredos.
- `README.md` atualizado com: pré-requisitos, instruções para subir o ambiente local, instruções para aplicar o Terraform e como obter a URL pública do Moodle.
- Commits semânticos (`feat:`, `fix:`, `docs:`, `chore:`).
- Nenhuma credencial, senha ou token em texto simples nos arquivos commitados.
- Testes do template passando: `cd tests && pytest -v` (os testes validam a estrutura do repositório; corrija o que falhar).

---

## Como Entregar

### 1. Publicar no fork

Trabalhe no seu fork do `implement_Moodle`. Commite os arquivos do projeto (módulos Terraform, `user_data.sh`, `docs/architecture-design.md`, `.env.example` atualizado, etc.) diretamente no fork.

```bash
cd implement_Moodle
git checkout -b feature/terraform-aws
# ... desenvolva os módulos e documentação ...
git add docs/architecture-design.md terraform/ docker/ .gitignore README.md
git commit -m "feat: infraestrutura terraform aws e documento de arquitetura"
git push origin feature/terraform-aws
```

### 2. Registrar entrega no repositório da disciplina

Crie a pasta `entregas/provaSegundoBi/SEU-RA/` no fork do repositório da disciplina, adicione somente o arquivo `entrega.md` (modelo abaixo) e abra um Pull Request.

```bash
cd /caminho/para/fork-da-disciplina
git checkout -b prova2/SEU-RA
mkdir -p entregas/provaSegundoBi/SEU-RA
# Crie o entrega.md com o modelo abaixo
git add entregas/provaSegundoBi/SEU-RA/entrega.md
git commit -m "feat(prova2): entrega - SEU NOME (RA: SEU-RA)"
git push -u origin prova2/SEU-RA
```

**Título do PR:** `[Prova P2] RA: SEU-RA - SEU NOME`

---

### Modelo de `entrega.md`

```markdown
# Entrega — Prova do Segundo Bimestre (Parte Prática)

**Aluno:** [Nome completo]
**RA:** [Número de matrícula]
**Data de entrega:** [Data]

## Fork do Desafio

- URL do fork: https://github.com/SEU-USUARIO/implement_Moodle
- Branch principal com a solução: main (ou indicar branch)

## Evidências

### Entregável 1 — Docker Local
- [ ] Moodle acessível em localhost:8080 (screenshot anexado ou link)

### Entregável 2 — Terraform
- [ ] Módulo `networking` implementado
- [ ] Módulo `compute` implementado (com `user_data.sh`)
- [ ] Módulo `database` implementado (RDS privado)
- [ ] `terraform validate` passou (screenshot)
- [ ] `terraform plan` executado sem erros (screenshot)

### Entregável 3 — Documento de Arquitetura
- [ ] `docs/architecture-design.md` presente no fork
- [ ] Diagrama incluído
- [ ] Justificativas de segurança documentadas
- [ ] Estimativa de custo incluída

### Entregável 4 — CI/CD
- [ ] `terraform-plan.yml` implementado
- [ ] Workflow executando com sucesso na PR (screenshot ou link da execução)

### Entregável 5 — Kiro e Kiro Workflows
- [ ] Spec do Kiro criada em `.kiro/specs/<modulo>/` (link para a pasta no fork)
- [ ] Screenshot do Kiro Workflow em execução ou concluído
- [ ] Descrição do que o workflow fez e como contribuiu para o resultado

### Entregável 6 — Organização
- [ ] `.gitignore` cobrindo arquivos sensíveis
- [ ] `README.md` atualizado
- [ ] Commits semânticos
- [ ] Nenhuma credencial nos commits (`git log` sem segredos)
- [ ] `pytest -v` passando (screenshot)

## Observações

[Descreva dificuldades encontradas, decisões de arquitetura ou pontos que merecem atenção do professor]

## Ferramentas de IA utilizadas

[Indique as ferramentas usadas, incluindo o Kiro, ou "não utilizei"]
```

---

## Critérios de Avaliação Detalhados

| Critério | Peso | O que será avaliado |
|----------|:----:|---------------------|
| Docker local funcional | 15% | `docker compose up -d` sobe o Moodle; `.env` não commitado; screenshot |
| Módulo `networking` | 10% | VPC, subnets públicas e privadas, IGW, Route Tables, Security Groups corretos |
| Módulo `compute` | 10% | EC2 com `LabInstanceProfile`, `user_data.sh` sobe o Moodle no boot, outputs |
| Módulo `database` | 10% | RDS PostgreSQL privado, DB Subnet Group 2+ AZs, credenciais via variáveis |
| Documento de arquitetura | 15% | Diagrama coerente, descrição dos componentes, justificativas, estimativa de custo |
| Workflow `terraform-plan.yml` | 15% | Executa corretamente no PR, autentica com session token, falha se houver erros |
| Kiro Spec | 8% | Spec com Requirements, Design e Tasks para um módulo Terraform; salva em `.kiro/specs/` |
| Kiro Workflow | 7% | Screenshot do workflow em execução; descrição do que foi feito e o que ajudou |
| Organização e boas práticas | 10% | `.gitignore`, commits semânticos, sem credenciais, `pytest` passando |

---

## Regras

1. O desafio é individual. Cada aluno deve construir e entregar sua própria solução.
2. É permitido consultar a documentação oficial (AWS, Terraform, Docker), os materiais das aulas e reaproveitar código próprio do curso.
3. Não é permitido copiar a solução de colegas. O aluno deve conseguir explicar o que entregou.
4. É permitido — e incentivado — usar o **Kiro** e outras ferramentas de IA. O uso deve ser evidenciado no entregável 5 e informado no `entrega.md`.
5. Não inclua credenciais AWS, senhas, tokens, chaves privadas, arquivos `.env` reais ou estado Terraform no repositório.
6. Abra apenas um Pull Request de entrega. Revise os arquivos antes de enviar.
7. O documento `docs/architecture-design.md` é **eliminatório**: sua ausência zera a nota desta parte da prova.

## Checklist Final do Aluno

- [ ] Fork do `implement_Moodle` criado na minha conta GitHub.
- [ ] Moodle rodando localmente com `docker compose up -d`.
- [ ] Módulos Terraform `networking`, `compute` e `database` implementados.
- [ ] `terraform validate` e `terraform plan` executam sem erros.
- [ ] `docs/architecture-design.md` presente com diagrama e justificativas.
- [ ] Workflow `terraform-plan.yml` implementado e executando na PR.
- [ ] Kiro Spec criada em `.kiro/specs/` para um dos módulos Terraform.
- [ ] Screenshot do Kiro Workflow evidenciando uso real da ferramenta.
- [ ] `.gitignore` cobrindo `.env`, estado Terraform e arquivos sensíveis.
- [ ] Nenhuma credencial ou senha nos commits.
- [ ] `pytest -v` passando na pasta `tests/`.
- [ ] `entrega.md` preenchido com links e evidências de todos os entregáveis.
- [ ] Pull Request aberto no repositório da disciplina em `entregas/provaSegundoBi/SEU-RA/`.

Boa prova! Mostre o que aprendeu: infraestrutura segura, pipeline automatizado e documentação clara.
