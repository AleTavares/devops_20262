# Entrega — Aula 08: GitHub Actions e CI Pipelines

**Aluna:** Eloísa Brandão  
**RA:** 2325096  
**Data:** 11/10/2026

## Repositório do projeto

- [Portfólio `brandelas/unifaat-devops-portfolio`](https://github.com/brandelas/unifaat-devops-portfolio)
- [Aplicação da Aula 08](https://github.com/brandelas/unifaat-devops-portfolio/tree/main/aula-08/technova-api)
- [Workflow CI](https://github.com/brandelas/unifaat-devops-portfolio/blob/main/.github/workflows/ci-aula08.yml)
- [README com badge](https://github.com/brandelas/unifaat-devops-portfolio/tree/main/aula-08)

## Requisitos e evidências

- [x] **R1 — CI multi-stage:** workflow acionado por `push` em `main`, `pull_request` e execução manual; jobs ESLint → Jest → Docker build e smoke test.
- [x] **R2 — ESLint:** configuração com `semi`, `quotes` e `no-unused-vars`; lint passou localmente e na CI.
- [x] **R3 — Jest:** 9 testes para `/health` e `/api/orders`; passaram localmente e nos jobs Node 18 e 20.
- [x] **R4 — Docker:** build e smoke test de `/health` passaram na CI.
- [x] **R5 — Secret:** `AWS_REGION` está configurado e referenciado pelo workflow; o log confirma sua presença sem revelar o valor. Não são usadas credenciais AWS reais.
- [x] **R6 — Badge:** badge da CI incluído no README do projeto.
- [x] **R7 — Capturas:** capturas reais estão versionadas na pasta `aula-08/screenshots/` do portfólio.

### Execuções e capturas

- [Execução verde #2](https://github.com/brandelas/unifaat-devops-portfolio/actions/runs/38186757808): ESLint, Jest Node 18, Jest Node 20 e Docker concluíram com sucesso.
- [Falha intencional #4](https://github.com/brandelas/unifaat-devops-portfolio/actions/runs/38188874150): a expectativa temporária `418` falhou contra a resposta `200`; a alteração foi revertida e não está na `main`.
- [Log de verificação do secret](https://github.com/brandelas/unifaat-devops-portfolio/actions/runs/38186757808/job/114610744505): confirma presença sem mostrar o valor.
- [Pipeline verde](https://github.com/brandelas/unifaat-devops-portfolio/blob/main/aula-08/screenshots/screenshot-pipeline-passing.png)
- [Pipeline com falha intencional](https://github.com/brandelas/unifaat-devops-portfolio/blob/main/aula-08/screenshots/screenshot-pipeline-failing.png)
- [Tela de secret configurado, valor oculto](https://github.com/brandelas/unifaat-devops-portfolio/blob/main/aula-08/screenshots/screenshot-secrets-configured.png)
- [Captura do log de verificação do secret](https://github.com/brandelas/unifaat-devops-portfolio/blob/main/aula-08/screenshots/secret-verification-log.png)

## Bônus

- [x] **B1 — Matrix:** testes em Node 18 e 20.
- [x] **B2 — Cache:** `setup-node` usa cache npm; o log da [execução verde #2](https://github.com/brandelas/unifaat-devops-portfolio/actions/runs/38186757808) mostra `Cache hit` e `Cache restored successfully`.
- [ ] **B3 — Comentário em PR:** não implementado.
- [x] **B4 — Concurrency:** cancela execuções anteriores da mesma referência.
- [x] **B5 — Smoke test Docker:** inicia o container, verifica `/health` e remove o container ao final.

## Respostas conceituais

### 1. Qual a diferença entre CI e CD?

CI integra alterações frequentemente e executa verificações automatizadas, como lint e testes. CD pode significar entrega contínua, que mantém uma versão validada pronta para publicação, ou implantação contínua, que publica automaticamente após as verificações e aprovações definidas.

### 2. Por que separar lint, test e build em jobs?

A separação identifica qual etapa falhou, permite controlar dependências com `needs` e impede a construção da imagem se o lint ou os testes falharem. Também facilita acompanhar os resultados na aba Actions.

### 3. Como proteger secrets?

Guardar valores em GitHub Actions Secrets e referenciá-los como `${{ secrets.NOME }}`. Não registrar valores em arquivos do repositório nem imprimi-los nos logs. Também é importante limitar permissões e usar credenciais de escopo mínimo.

### 4. O que significa o pipeline ficar vermelho?

Uma etapa obrigatória falhou. Deve-se consultar o log do job, identificar a causa, corrigir o código ou a configuração e enviar uma nova alteração. Jobs dependentes não avançam quando uma etapa anterior falha.

### 5. O que faria em um projeto real?

Usaria actions revisadas, dependências fixadas pelo lockfile, permissões mínimas, testes adequados e aprovação para implantações em ambientes compartilhados. Esta pipeline valida a aplicação e não implanta recursos.