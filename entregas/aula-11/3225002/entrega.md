# Entrega — Aula 11 (TF)

**Aluno:** José Henrique Teixeira Luiz
**RA:** 3225002
**Data:** 13/11/2026

**Ferramentas de IA utilizadas:** Kiro (Claude Sonnet 4.5) para gerar a spec e
todo o código Terraform; Claude Code para revisar o resultado e montar os
prompts de correção. O detalhamento de quem fez o quê está na seção "O
processo com a IA".

## Link do commit

- Fork: https://github.com/zzin742/implement_Moodle
- Commit: https://github.com/zzin742/implement_Moodle/commit/bacd02d

## O que foi feito nesta aula

Fiz o fork do `implement_Moodle`, clonei localmente, validei o ambiente Docker
e avancei até a infraestrutura Terraform completa e o documento de arquitetura.

**Ambiente Docker local.** Antes de subir qualquer coisa rodei
`docker compose config`, e a saída renderizada mostrou um problema que o `up`
esconderia:

```
- pg_isready -U  -d
```

O healthcheck do Postgres sai com os dois argumentos vazios. A causa é que o
`env_file` do template aponta para `.env.example`, e o `env_file` alimenta o
**contêiner** — não a interpolação `${POSTGRES_USER}` do próprio Compose, que
lê o `.env` do diretório do arquivo. Como o serviço `moodle` declara
`depends_on: db: condition: service_healthy`, um healthcheck malformado trava o
Moodle esperando um banco que nunca fica saudável. Corrigi apontando o
`env_file` para `.env` e criando o `docker/.env` a partir do `.env.example`,
com senhas geradas. O `.env` é gitignorado; o `.env.example` continua no
repositório só com placeholders.

**Infraestrutura Terraform.** Criei a estrutura inteira do zero em
`terraform/`: raiz (`versions.tf`, `variables.tf`, `main.tf`, `outputs.tf`,
`terraform.tfvars.example`, `backend.tf.example`) e os três módulos
`networking`, `compute` e `database`, com `main.tf`, `variables.tf` e
`outputs.tf` cada um, mais o `user_data.sh`. São 16 arquivos.

Resultado da validação na minha máquina:

```
terraform -chdir=terraform fmt -check -recursive   → exit 0
terraform -chdir=terraform validate                 → Success! The configuration is valid.
pytest -q                                           → 64 passed
```

A suíte do repositório saiu de **41 passed, 10 skipped** para **64 passed, 0
skipped**. Os 10 que pulavam eram exatamente os de estrutura de módulos, que
só rodam quando `terraform/modules/` existe.

**Documento de arquitetura.** `docs/architecture-design.md` preenchido a partir
do template, com as sete seções obrigatórias e diagrama próprio em
`docs/img/arquitetura-3225002.png`, cobrindo VPC, subnet pública, duas subnets
privadas, IGW, route table, EC2, RDS, os dois security groups e o fluxo
Internet → IGW → EC2 → RDS. É a entrega eliminatória do desafio — a ausência
dela desclassifica independentemente da pontuação no resto — então foi a que
tratei com mais cuidado.

**O que ainda não está pronto.** Não rodei `terraform apply`. O `validate`
confere sintaxe e tipos; ele não diz se a SCP do Learner Lab autoriza cada
chamada. O próximo passo é abrir o lab, aplicar, acompanhar o boot por
`/var/log/user-data.log`, validar com `scripts/health-check.sh <EC2_DNS>` e
rodar `terraform destroy`.

## O processo com a IA

Usei o **Kiro com Claude Sonnet 4.5**, no fluxo spec-driven. A sequência foi:

1. **Spec.** Um prompt único e longo, com todas as restrições do Learner Lab
   já dentro. Longo de propósito: cada restrição que falta vira uma pergunta
   do Kiro, e cada pergunta é mais crédito consumido. Custou 2,53 créditos.
2. **Implementação.** Pedi todos os arquivos de uma vez, em vez de task a
   task. Task a task gastaria dez turnos para produzir o mesmo resultado.
   Custou 4,87.
3. **Correção, duas rodadas.** 3,28 e 2,09.
4. **Documento de arquitetura.** 0,58 — barato porque ele só leu o código já
   pronto e descreveu.

Total: **13,35 de 50 créditos** do plano gratuito.

**Como validei.** Não deixei o Kiro rodar `terraform` nem `pytest`: rodei na
minha máquina, onde é de graça. Além dos três comandos do critério de aceite,
rodei `bash -n` sobre o `user_data.sh` com as variáveis do Terraform
substituídas — isso pega erro de sintaxe de shell que o `terraform validate`
não enxerga, porque para o Terraform o script é apenas uma string.

A revisão do código gerado e a redação dos prompts de correção foram feitas com
**Claude Code**, fora do Kiro. Registro isso porque a prova do bimestre pede
explicitamente que se informe qual ferramenta de IA foi usada, e porque os sete
defeitos abaixo não teriam sido encontrados só pelos três comandos de aceite —
todos os três passavam com o código defeituoso.

### O que a IA gerou bem

- Acertou as duas restrições do Learner Lab de primeira: `LabInstanceProfile`
  por `data "aws_iam_instance_profile"`, sem nenhum `resource "aws_iam_*"`.
- AMI por `data "aws_ami"` com filtro, nunca id fixo.
- `http_tokens = "required"`, `storage_encrypted`, `publicly_accessible = false`
  e o SG do RDS referenciando o SG da EC2 em vez de um CIDR.
- O `# TODO:` em todos os 15 arquivos que precisavam — inclusive os
  `variables.tf` e `outputs.tf` dos módulos, que são os que costumam escapar.

### O que a IA errou

Sete defeitos, nenhum deles pego pelos comandos de aceite — porque nenhum dos
três executa o `user_data.sh`. Eles conferem sintaxe e estrutura de arquivo,
não comportamento.

| # | Defeito | Por que passa despercebido |
|---|---|---|
| 1 | `git clone https://github.com/SEU-USUARIO/...` — URL de placeholder | O `terraform validate` não sabe o que é uma URL válida |
| 2 | `\|\| { ... }` depois do clone | Anula o `set -euo pipefail`: o script segue com `/opt/moodle/docker` vazio e o erro só aparece no `docker compose up`, como `no configuration file provided` — apontando para o Compose, 40 linhas depois da causa |
| 3 | `.env` escrevia `MOODLE_DATABASE_PORT`, mas o Compose lê `MOODLE_DATABASE_PORT_NUMBER` | Nome parecido; ninguém relê o compose |
| 4 | `.env` não escrevia `MOODLE_USERNAME`, `MOODLE_PASSWORD` nem `MOODLE_SITE_NAME` | O Moodle subiria com administrador sem usuário nem senha |
| 5 | Aplicou `http_tokens = "required"` (IMDSv2) e depois consultou `http://169.254.169.254/latest/meta-data/public-hostname` **sem token** | Retorna HTTP 401; a linha final imprimiria `http://` e nada mais. A própria trava de segurança que ele configurou bloqueia o código que ele escreveu |
| 6 | Versão do Docker Compose vinda da API do GitHub sem autenticação, e `curl -SL` sem `-f` | Limite de 60 requisições/hora por IP. Se estourar, a variável fica vazia e o `curl` sem `-f` não falha em HTTP 404 — grava a página de erro e dá `chmod +x` nela |
| 7 | `cat > .env <<EOF`, sem aspas no delimitador | O pior dos sete, porque corrompe em silêncio (detalhado abaixo) |

### O defeito que mais ensinou

O sete. Sem aspas no `EOF`, o bash expande o conteúdo do heredoc. Depois que o
`templatefile()` renderiza, a senha do RDS é texto literal dentro do script —
e se ela contiver `$`, crase ou barra invertida, o bash come esses caracteres
na hora de escrever o arquivo. O `.env` sai com uma senha diferente da que o
Terraform configurou no RDS.

O sintoma seria cruel: o Moodle sobe, tenta conectar, devolve erro de
autenticação. Eu conferiria a senha no `terraform.tfvars`, ela estaria certa, e
o banco continuaria recusando.

A correção é `<<'EOF'`. E entender por que isso **não** quebra as variáveis do
Terraform foi o que fechou o conceito pra mim: as aspas impedem o **bash** de
expandir, mas o `${db_password}` já foi substituído pelo `templatefile()` antes
de o script chegar na instância. O bash nunca vê a variável — vê o valor.

### Onde a IA economizou e onde atrapalhou

**Economizou** na digitação e na memória de API: 16 arquivos com sintaxe
correta de primeira, e nenhum deles com erro que o `validate` pegasse.

**Atrapalhou** na confiança que ela mesma expressa. O Kiro escreveu scripts de
verificação próprios e imprimiu `✅ TODAS AS VERIFICAÇÕES PASSARAM` nas duas
rodadas — enquanto os sete defeitos estavam lá. As verificações que ele
escreveu testavam o que ele tinha acabado de fazer (o arquivo existe? tem
`# TODO:`?), não se o script funcionaria.

É o mesmo padrão dos três comandos de aceite: todos verdes, nada executado.

## Dificuldades encontradas

**A principal foi perceber que "verde" não é "funciona".** `fmt`, `validate` e
`pytest` passaram com os sete defeitos no código. Eles conferem formatação,
sintaxe e existência de arquivo. Nenhum deles roda o `user_data.sh`, que é onde
estava tudo. Foi o segundo caso nesta disciplina em que um comando verde
escondia um ambiente quebrado — o primeiro foi o `docker compose up -d`, que
não reclama de healthcheck malformado.

**Entender por que `aws_s3_bucket` e `aws_iam_role` não podem ser usados.** As
duas restrições do lab não aparecem no momento em que se escreve o código:
aparecem no meio do `apply`, depois que metade dos recursos já existe. No caso
do IAM, um `resource "aws_iam_role"` mataria o apply com `AccessDenied`
**depois** de criar VPC e RDS, deixando recursos órfãos consumindo crédito. Por
isso a `LabRole` entra por data source e os dois motivos estão comentados no
código, para não serem "corrigidos" depois por quem não souber.

**Decidir o que o `user_data.sh` deve subir.** O `docker-compose.yml` tem dois
serviços: `db` (Postgres local) e `moodle`. Na AWS o banco é o RDS, então subir
o `db` criaria um segundo Postgres ocioso — e, pior, o
`depends_on: db: condition: service_healthy` faria o Moodle esperar por ele. A
solução é `docker compose up -d --build --no-deps moodle`, que nomeia só o
serviço desejado e desliga a verificação de dependência.

**Uma dificuldade de ambiente, não de conteúdo:** o `terraform init` falhou
duas vezes com `operation timed out` baixando o provider AWS (~680 MB) enquanto
um build do Docker baixava imagens em paralelo. Resolvi apontando
`TF_PLUGIN_CACHE_DIR` para o cache local, que já tinha o provider de outro
projeto. Vale o registro: as duas falhas pareciam erro de configuração e eram
contenção de rede.
