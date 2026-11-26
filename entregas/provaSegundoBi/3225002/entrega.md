# Entrega — Prova do Segundo Bimestre (Parte Prática)

**Aluno:** José Henrique Teixeira Luiz
**RA:** 3225002
**Data de entrega:** 22/11/2026

## Fork do Desafio

- URL do fork: https://github.com/zzin742/implement_Moodle
- Branch principal com a solução: `ci/verifica-plan-na-pr` (aberta na PR #1 contra a `main` do próprio fork, porque o workflow do Entregável 4 só dispara em `pull_request`)
- Commit final: https://github.com/zzin742/implement_Moodle/commit/9569601fda7dfd07f6f4a396c349bffb3a702c00

## Evidências

### Entregável 1 — Docker Local

- [x] Screenshot do Moodle em `localhost:8080`: [01-moodle-local-navegador.png](https://github.com/zzin742/implement_Moodle/blob/ci/verifica-plan-na-pr/docs/img/01-moodle-local-navegador.png)
- [x] Containers no Docker Desktop: [02-docker-desktop-containers.png](https://github.com/zzin742/implement_Moodle/blob/ci/verifica-plan-na-pr/docs/img/02-docker-desktop-containers.png)
- [x] Saída do `docker compose ps`: [03-docker-compose-ps.png](https://github.com/zzin742/implement_Moodle/blob/ci/verifica-plan-na-pr/docs/img/03-docker-compose-ps.png)

O `.env` real não está commitado; ele é criado a partir do `.env.example` e está coberto pelo `.gitignore`.

Um defeito do template apareceu aqui: o `docker/docker-compose.yml` lia `env_file: - .env.example`, de modo que o healthcheck do Postgres rodava `pg_isready -U  -d ` com as variáveis vazias. Corrigido para `- .env`.

### Entregável 2 — Terraform

- [x] Módulo `networking`: [terraform/modules/networking/](https://github.com/zzin742/implement_Moodle/tree/ci/verifica-plan-na-pr/terraform/modules/networking)
- [x] Módulo `compute` (com `user_data.sh`): [terraform/modules/compute/](https://github.com/zzin742/implement_Moodle/tree/ci/verifica-plan-na-pr/terraform/modules/compute)
- [x] Módulo `database` (RDS privado): [terraform/modules/database/](https://github.com/zzin742/implement_Moodle/tree/ci/verifica-plan-na-pr/terraform/modules/database)
- [x] Screenshot `terraform validate`: [05-terraform-validate.png](https://github.com/zzin742/implement_Moodle/blob/ci/verifica-plan-na-pr/docs/img/05-terraform-validate.png)
- [x] Screenshot `terraform plan` sem erros: [06-terraform-plan.png](https://github.com/zzin742/implement_Moodle/blob/ci/verifica-plan-na-pr/docs/img/06-terraform-plan.png)

Além de `validate` e `plan`, a infraestrutura foi efetivamente aplicada no Learner Lab (`terraform apply`, 15 recursos criados, Moodle respondendo na porta 80 do IP público da EC2) e depois destruída (`terraform destroy`, `Destroy complete! Resources: 6 destroyed`, com `terraform state list` vazio na verificação final). Foi o `apply` que revelou os defeitos que o `validate` não pega — detalhados nas observações.

### Entregável 3 — Documento de Arquitetura

- [x] `docs/architecture-design.md`: [link direto no fork](https://github.com/zzin742/implement_Moodle/blob/ci/verifica-plan-na-pr/docs/architecture-design.md)

Contém o diagrama (VPC, duas subnets públicas e duas privadas em AZs diferentes, EC2, RDS, Security Groups e o fluxo do usuário até o banco), a descrição de cada recurso com a justificativa da configuração escolhida, as justificativas de segurança e a estimativa de custo mensal.

### Entregável 4 — CI/CD

- [x] `terraform-plan.yml`: [link para o arquivo no fork](https://github.com/zzin742/implement_Moodle/blob/ci/verifica-plan-na-pr/.github/workflows/terraform-plan.yml)
- [x] Execução no GitHub Actions: [run disparado pela PR #1](https://github.com/zzin742/implement_Moodle/actions/runs/44427098249) · screenshot: [07-actions-terraform-plan.png](https://github.com/zzin742/implement_Moodle/blob/ci/verifica-plan-na-pr/docs/img/07-actions-terraform-plan.png)
- [x] PR com o plan comentado: [zzin742/implement_Moodle#1](https://github.com/zzin742/implement_Moodle/pull/1)

O workflow dispara em `pull_request` e em `workflow_dispatch`, autentica com `aws-actions/configure-aws-credentials@v4` usando os três secrets (incluindo o `AWS_SESSION_TOKEN`, que o Learner Lab exige), roda `init`, `validate` e `plan -no-color`, e publica o plan como comentário na PR via `actions/github-script@v7`.

Duas decisões que mudam o comportamento:

- o step do `plan` usa `continue-on-error: true` para que o comentário seja postado mesmo quando o plan falha, e um step final `if: steps.plan.outcome == 'failure'` faz `exit 1`. Sem essa separação, um plan com erro abortaria o job antes de comentar, e o aluno não veria o motivo na PR.
- o comentário é truncado em 60.000 caracteres preservando o **fim** do plan, não o começo, porque é no fim que o Terraform imprime o erro e o resumo.

> **Nota sobre o último run da PR estar vermelho:** as credenciais do Learner Lab duram 4 horas, e os secrets `AWS_*` do repositório foram gravados em 13/11. Qualquer run disparado depois disso falha no step `Configurar credenciais AWS` com o token expirado — e falha com `exit code != 0`, que é precisamente o comportamento pedido no enunciado. O run verde com o plan comentado na PR é o [44427098249](https://github.com/zzin742/implement_Moodle/actions/runs/44427098249), feito enquanto a sessão estava válida, e é ele que o screenshot mostra.

### Entregável 5 — Kiro e Kiro Workflows

- [x] Spec do Kiro: [.kiro/specs/networking/](https://github.com/zzin742/implement_Moodle/tree/ci/verifica-plan-na-pr/.kiro/specs/networking) — `requirements.md`, `design.md` e `tasks.md`, com 40 das 51 tarefas marcadas como concluídas
- [x] Saída do Kiro Workflow `investigate`: [docs/analise-user-data-templatefile.md](https://github.com/zzin742/implement_Moodle/blob/ci/verifica-plan-na-pr/docs/analise-user-data-templatefile.md)
- [x] Screenshot do Kiro Workflow: [08-kiro-workflow.png](https://github.com/zzin742/implement_Moodle/blob/ci/verifica-plan-na-pr/docs/img/08-kiro-workflow.png) — os três tool calls expandidos e o artefato gerado
- [x] Rodapé de conclusão da mesma execução: [09-kiro-workflow-conclusao.png](https://github.com/zzin742/implement_Moodle/blob/ci/verifica-plan-na-pr/docs/img/09-kiro-workflow-conclusao.png) — `Est. Credits Used: 1,99` e `Elapsed time: 2m 6s`

**Descrição:** rodei o workflow `investigate` do Kiro sobre o `user_data.sh` depois que a EC2 subiu e o Moodle não respondeu. O workflow leu o módulo `compute`, o template e o `docker-compose.yml`, e localizou a causa: a regra de escape do `templatefile()` é mais estreita do que parece — `$${VAR}` virá `${VAR}`, mas `$$(` passa **literal**, porque o `$$` só escapa antes de `{`. O `$$(docker ...)` que eu tinha escrito chegava na instância como `$$(docker ...)`, que o bash lê como PID seguido de parêntese, e o script morria com erro de sintaxe. O relatório do workflow virou o `docs/analise-user-data-templatefile.md`; a correção foi usar `$(` para substituição de comando e reservar o `$$` só para variáveis de shell. Também usei o Kiro em modo Spec para o módulo `networking`, onde a Spec apontou a falta da segunda subnet pública (`public_1b`), exigida pelo DB Subnet Group.

### Entregável 6 — Organização

- [x] Screenshot `pytest -v` passando: [04-pytest-64-passed.png](https://github.com/zzin742/implement_Moodle/blob/ci/verifica-plan-na-pr/docs/img/04-pytest-64-passed.png) — 64 passed
- [x] Commits semânticos: [histórico de commits no fork](https://github.com/zzin742/implement_Moodle/commits/ci/verifica-plan-na-pr)
- [x] `.gitignore` cobrindo `.env`, `.terraform/`, `*.tfstate`, `*.tfplan` e `*.tfvars`: [.gitignore](https://github.com/zzin742/implement_Moodle/blob/ci/verifica-plan-na-pr/.gitignore)

Nenhuma credencial, senha, token ou estado do Terraform foi commitado. As variáveis sensíveis entram por `TF_VAR_*`, e no GitHub Actions por secrets do repositório.

Observação honesta sobre a suíte: o `test_git_ignores_sensitive_filenames` é intermitente. Ele usa `hypothesis` com `deadline` de 200 ms, e cada exemplo chama `git check-ignore` por subprocesso; no primeiro exemplo com o cache frio a chamada leva ~400 ms e o teste falha com `DeadlineExceeded`. Rodando três vezes seguidas na mesma máquina: 63 passed / 64 passed / 64 passed. É timing do teste, não do repositório, então não alterei o teste do template.

## Observações

O que ficou de aprendizado nesta prova não foi o Terraform em si, foi **quais verificações mentem**. O `terraform fmt`, o `validate` e o `pytest` ficaram verdes com sete defeitos ainda no `user_data.sh`, todos eles só visíveis depois do `apply`. Os mais caros:

1. **A regra de escape do `templatefile()`** — descrita no Entregável 5. Pior: eu tinha "verificado" o script com `bash -n` depois de renderizar o template com um `sed` que trocava `$$` por `$` globalmente, que **não** é o que o `templatefile()` faz. A verificação passou e estava errada, porque reproduzia uma regra inventada. Reescrevi o renderizador com a regra real para conferir de novo.
2. **`aws_db_instance.endpoint` devolve `address:port`**, não só o host. Passar o `endpoint` para o Moodle gerava `host:5432:5432`. O atributo certo é `address`.
3. **`user_data_replace_on_change = true`** — sem isso, o `apply` responde `No changes` depois de eu corrigir o script, e a instância continua rodando a versão velha do `user_data`. O `apply` verde era verdadeiro sobre o estado e falso sobre a realidade.
4. **`sensitive = true` propaga para atributos derivados** — marcar o CIDR de SSH como sensível redigiu o bloco de ingress inteiro no plan, o que atrapalha exatamente a revisão que o plan serve para fazer.
5. **Um `if:` de job com `hashFiles()`** faz o GitHub rejeitar o arquivo de workflow inteiro, porque a expressão é avaliada antes do checkout, quando não existe workspace.
6. **`gh secret set --body -`** trata o `-` como string literal, não como stdin. Os cinco secrets `TF_VAR_*` foram gravados com o valor `-`, e o plan falhou com `"***" is not a valid CIDR block` — mensagem que não aponta para a causa, porque o valor aparece redigido.
7. **O código de saída de um pipeline é o do último comando.** Um `terraform destroy | sed ...` reportou `exit code 0` enquanto o destroy havia falhado no meio do RDS com `lookup rds.us-east-1.amazonaws.com: no such host`. Só o `terraform state list` vazio provou que a infraestrutura tinha mesmo ido embora — e foi preciso um terceiro `destroy` para isso.

Três dos defeitos foram meus, e os três vieram de supor o comportamento de uma ferramenta em vez de medir. Duas previsões minhas também caíram: eu disse que o `t3.micro` com 1 GB de RAM morreria de OOM no passo `gd` do Moodle (rodou em ~300 s), e que o Elasticsearch do ambiente local comia 1-2 GB (medido: 7,3 MiB — o gargalo era CPU). Corrigi as duas afirmações no repositório em vez de deixá-las de pé.

Restrições do Learner Lab que mudaram o desenho: nada de IAM (o `LabRole` e o `LabInstanceProfile` entram por `data source`), `aws_s3_bucket` falha porque a SCP nega `s3:GetBucketObjectLockConfiguration`, não há ACM, CloudFront nem Route53, e as credenciais expiram em 4 horas — o que é o motivo de o workflow precisar do `AWS_SESSION_TOKEN`.

## Ferramentas de IA utilizadas

- **Kiro** (modo Spec e Workflow `investigate`) — evidenciado no Entregável 5. Gerou a Spec do módulo `networking` e o relatório `docs/analise-user-data-templatefile.md`.
- **Claude (Claude Code)** — usado na escrita dos módulos Terraform, do `user_data.sh`, do workflow de CI e desta documentação, e na depuração do `apply`.

Revisei tudo o que foi gerado, e as sete falhas listadas nas observações são justamente o que a revisão e a execução real encontraram depois de as ferramentas darem o trabalho por pronto. Consigo explicar cada arquivo entregue e cada decisão tomada.
